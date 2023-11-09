import "dart:convert";

import "package:omnimodel/src/common/extensions.dart";

import "package:omnimodel/src/common/logger.dart";

enum SimilarityBackend {
  levenshtein,
  convolution,
}

enum JsonType { array, map, number, string, bool, nil }

class OmniModelPerferences {
  /// Toggle console hints about mispelled keys and mismatched types
  static bool enableHints = true;

  /// Enforce the keys of every [OmniModel] to be lowercase. This automatically changes the keys to lowercase when creating and accessing the [OmniModel]
  static bool enforceLowerCaseKeys = false;

  /// Edit the algorithm used for calculating similarity among strings.
  static SimilarityBackend similarityBackend = SimilarityBackend.convolution;
}

/// Wrap data and access it safely: forget about errors or missing keys
class OmniModel {
  /// Empty model
  factory OmniModel.empty() => OmniModel._({});

  /// Try to create from a dynamic type.
  /// - Any map type will be converted to `Map<String, dynamic>` by using `toString()` on keys
  factory OmniModel.fromDynamic(dynamic value) => value is OmniModel
      ? value.clone()
      : value is Map
          ? OmniModel.fromEntries(
              value.entries.map((e) => MapEntry(e.key.toString(), e.value)),
            )
          : OmniModel.empty();

  /// Create the model from a map
  ///
  /// Any map type will be converted to `Map<String, dynamic>` by using `toString()` on keys
  factory OmniModel.fromMap(Map map) => OmniModel._(map);

  /// Create a new model from the string representation of a map. Returns an empty model on error
  factory OmniModel.fromRawJson(String rawJson) {
    try {
      var jsonMap = jsonDecode(rawJson);
      return OmniModel.fromDynamic(jsonMap);
    } catch (error) {
      return OmniModel.empty();
    }
  }

  /// Create the model from the entries of a map
  factory OmniModel.fromEntries(Iterable<MapEntry<String, dynamic>> entries) => OmniModel._(Map.fromEntries(entries));
  OmniModel._(Map map)
      : _data = map.map(
          (key, value) => MapEntry(
            OmniModelPerferences.enforceLowerCaseKeys ? key.toString().toLowerCase() : key.toString(),
            value,
          ),
        );

  Map<String, dynamic> toJson() => json;

  static const String _defaultDelimiter = ".";
  static final RegExp _delimiters = RegExp(r"\.+|\/+|\|+|\\+|\,+");

  Map<String, dynamic> _data;

  /// The length of the keys of the map
  int get length => _data.entries.length;

  /// Whether it has no keys
  bool get isEmpty => length <= 0;

  /// Whether it has keys
  bool get isNotEmpty => !isEmpty;

  void _displayKeyHints(String original, Map map) {
    if (!OmniModelPerferences.enableHints) return;
    var closeMatches = map.keys.where(
      (element) => element is String && original.activeSimilarity(element, caseSensitive: false) > 0.8,
    );
    if (closeMatches.isNotEmpty) {
      var text = "$original not found -> maybe one of [${closeMatches.join(", ")}] ?";
      printWarning(text);
    }
  }

  /// Return the [JsonType] of the element at the provided path.
  ///
  /// If the element does not exist, returns [JsonType.nil]
  JsonType tokenType(String path) {
    if (OmniModelPerferences.enforceLowerCaseKeys) {
      path = path.toLowerCase();
    }
    var fields = path.trim().replaceAll(_delimiters, _defaultDelimiter).split(_defaultDelimiter);
    dynamic current = _data;
    for (final field in fields) {
      if (current is! Map) return JsonType.nil;
      current = current[field];
      if (current == null) {
        return JsonType.nil;
      }
    }
    if (current == null) return JsonType.nil;
    if (current is List) return JsonType.array;
    if (current is num) return JsonType.number;
    if (current is bool) return JsonType.bool;
    if (current is String) return JsonType.string;
    if (current is Map) return JsonType.map;
    return JsonType.nil;
  }

  /// Return the entry with the most similar key as the provided one.
  ///
  /// Uses the [OmniModelPreferences.similarityBackend] as similarity algorithm
  ///
  /// Returns null if the map is empty
  MapEntry<String, dynamic>? similar(String key) {
    double max = 0;
    MapEntry<String, dynamic>? res;
    for (final entry in entries) {
      var d = entry.key.activeSimilarity(key);
      if (d > max) {
        max = d;
        res = entry;
      }
    }
    return res;
  }

  /// Get a copy of the entries
  Iterable<MapEntry<String, dynamic>> get entries => _data.entries.toList();

  /// Get a copy of the underlying map
  Map<String, dynamic> get json => Map.from(_data);

  /// String encoding of the model
  String toRawJson({String? indent}) => JsonEncoder.withIndent(indent).convert(json);

  /// Clone the model and get a new instance
  OmniModel clone() => OmniModel.fromMap(json);

  @override
  String toString() => toRawJson();

  /// Copy the model into a new model modifying the specified fields. Add the fields if not present in the original model.
  /// Supports deep pathing.
  /// -----
  /// Example
  ///
  /// ```dart
  /// {
  ///   "field": 0, "data.entry.payload": "dummy"
  /// }
  /// ```
  ///
  /// A new [OmniModel] will be created with the `["field"]` value to 0 and the field corresponding to `["data"]["entry"]["payload"]` to "dummy"
  OmniModel copyWith(Map<String, dynamic> fieldPaths) {
    Map newJson = json;
    for (final element in fieldPaths.entries) {
      var key = OmniModelPerferences.enforceLowerCaseKeys ? element.key.toLowerCase() : element.key;
      newJson = newJson.deepUpdate(
        key.trim().replaceAll(_delimiters, _defaultDelimiter).split(_defaultDelimiter),
        element.value,
      );
    }
    var newMap = Map<String, dynamic>.from(newJson);
    return OmniModel.fromMap(newMap);
  }

  /// Edit the current model in place. Add the fields if not present in the original model.
  /// Supports deep pathing.
  /// -----
  /// Example
  ///
  /// ```dart
  /// {
  ///   "field": 0, "data.entry.payload": "dummy"
  /// }
  /// ```
  ///
  /// In this case the [OmniModel] will be modified by changing the `["field"]` value to 0 and the field corresponding to `["data"]["entry"]["payload"]` to "dummy"
  void edit(Map<String, dynamic> fieldPaths) {
    Map newJson = json;
    for (final element in fieldPaths.entries) {
      var key = OmniModelPerferences.enforceLowerCaseKeys ? element.key.toLowerCase() : element.key;
      newJson = newJson.deepUpdate(
        key.trim().replaceAll(_delimiters, _defaultDelimiter).split(_defaultDelimiter),
        element.value,
      );
    }
    _data = Map<String, dynamic>.from(newJson);
  }

  /// Try to get the specified field as an underlying [OmniModel], returns the empty map in case of not found or if the field is not a `Map`
  OmniModel tokenAsModel(String path) => tokenOr<OmniModel>(path, OmniModel.empty());

  /// Force the default value to a non nullable type
  T tokenOr<T>(String path, T defaultValue) => tokenOrNull<T>(path) ?? defaultValue;

  /// Safely access a map with a combined path. The path will be converted to lower case.
  /// Examples paths:
  /// - `first.second`
  /// - `first.second\third` <- ugly but works
  /// - `first|second\third,fourth` <- super ugly but works
  ///
  /// Supported delimiters: <code>. \ / | ,</code>
  T? tokenOrNull<T>(String path) {
    if (OmniModelPerferences.enforceLowerCaseKeys) {
      path = path.toLowerCase();
    }
    var fields = path.trim().replaceAll(_delimiters, _defaultDelimiter).split(_defaultDelimiter);
    dynamic current = _data;
    String key = "";
    for (final field in fields) {
      key = field;
      if (current is! Map) return null;
      var checkpoint = current;
      current = current[field];
      if (current == null) {
        _displayKeyHints(field, checkpoint);
        return null;
      }
    }
    //logInfo("${T == Model}, ${current is Map}");
    if (T == OmniModel) {
      if (current is Map) {
        return OmniModel.fromEntries(
          current.entries.map((e) => MapEntry(e.key.toString(), e.value)),
        ) as T;
      } else {
        return null;
      }
    }
    if (current is T) {
      return current;
    } else if (OmniModelPerferences.enableHints) {
      printWarning(
        "tried to retrieve $key as $T but value is of type ${current.runtimeType}",
      );
    }
    return null;
  }
}
