import "dart:convert";

import "package:omnimodel/src/common/extensions.dart";

import "package:omnimodel/src/common/logger.dart";

class OmniModelPerferences {
  /// Toggle console hints about mispelled keys and mismatched types
  static bool enableHints = true;

  /// Enforce the keys of every [OmniModel] to be lowercase. This automatically changes the keys to lowercase when creating and accessing the [OmniModel]
  static bool enforceLowerCaseKeys = true;
}

class OmniModel {
  OmniModel._(Map<String, dynamic> map)
      : _map = map.map((key, value) => MapEntry(OmniModelPerferences.enforceLowerCaseKeys ? key.toLowerCase() : key, value));

  /// Empty model
  factory OmniModel.identity() => OmniModel._(Map.identity());

  /// Try to create from a dynamic type. If the type is not `Map<String, dynamic>`, returns an empty model
  factory OmniModel.fromDynamicOrIdentity(dynamic value) =>
      value is Map ? OmniModel.fromEntries(value.entries.map((e) => MapEntry(e.key.toString(), e.value))) : OmniModel.identity();

  /// Create the model from a map
  factory OmniModel.fromMap(Map<String, dynamic> map) => OmniModel._(Map.from(map));

  /// Create a new model from the string representation of a map
  factory OmniModel.fromRawJson(String rawJson) {
    try {
      var jsonMap = jsonDecode(rawJson);
      return OmniModel.fromDynamicOrIdentity(jsonMap);
    } catch (error) {
      return OmniModel.identity();
    }
  }

  /// Create the model from entries of a map
  factory OmniModel.fromEntries(Iterable<MapEntry<String, dynamic>> entries) => OmniModel._(Map.fromEntries(entries));
  static const String _defaultDelimiter = ".";
  static final RegExp _delimiters = RegExp(r"\.+|\/+|\|+|\\+|\,+");

  final Map<String, dynamic> _map;

  /// The length of the keys of the map
  int get length => _map.entries.length;

  /// Whether it has no keys
  bool get isEmpty => length <= 0;

  /// Whether it has keys
  bool get isNotEmpty => !isEmpty;

  void _displayKeyHints(String original, Map map) {
    if (!OmniModelPerferences.enableHints) return;
    var closeMatches = map.keys.where(
      (element) => element is String && original.levenshtein(element, caseSensitive: false) < original.length / 2,
    );
    if (closeMatches.isNotEmpty) {
      var text = "$original key not found X( -> maybe one of [${closeMatches.join(", ")}] ?";
      logWarning(text);
    }
  }

  /// Get a copy of the entries
  Iterable<MapEntry<String, dynamic>> get entries => _map.entries.toList();

  /// Get a copy of the underlying map
  Map<String, dynamic> get json => Map.from(_map);

  /// String encoding of the model
  String toRawJson() => jsonEncode(json);

  @override
  String toString() => toRawJson();

  /// Copy the model into a new model modifying the specified fields. Add the fields if not present in the original model.
  /// Supports deep pathing.
  /// ___
  /// `{"field": 0, "data.entry.payload": "dummy"}`
  ///
  /// In this case the [OmniModel] will be modified by changing the `["field"]` value to 0 and the field corresponding to `["data"]["entry"]["payload"]` to "dummy"
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

  /// Try to get the specified field as an underlying [OmniModel], returns the identity in case of not found or if the field is not a `Map<String, dynamic>`
  OmniModel tokenAsModel(String path) => tokenOr<OmniModel>(path, OmniModel.identity());

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
    dynamic current = _map;
    String key = "";
    for (final t in fields) {
      key = t;
      if (current is! Map) return null;
      var checkpoint = current;
      current = current[t];
      if (current == null) {
        _displayKeyHints(t, checkpoint);
        return null;
      }
    }
    //logInfo("${T == Model}, ${current is Map}");
    if (T == OmniModel) {
      if (current is Map) {
        return OmniModel.fromEntries(current.entries.map((e) => MapEntry(e.key.toString(), e.value))) as T;
      } else {
        return null;
      }
    }
    if (current is T) {
      return current;
    } else if (OmniModelPerferences.enableHints) {
      logWarning("tried to retrieve $key as $T but value is of type ${current.runtimeType}");
    }
    return null;
  }
}
