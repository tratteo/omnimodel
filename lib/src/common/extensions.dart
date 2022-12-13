import "dart:math";

extension StringExtensions on String {
  /// Calculate the Levenshtein distance between two arbitrary strings
  int levenshtein(String t, {bool caseSensitive = true}) {
    var s = this;
    if (!caseSensitive) {
      s = s.toLowerCase();
      t = t.toLowerCase();
    }
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i < i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < t.length + 1; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }
}

extension MapExtensions on Map {
  /// Perform a *ueep update* of a map
  Map deepUpdate<T>(List<String> keyPaths, T value) {
    return _deepUpdateRecursive(keyPaths, this, value);
  }

  dynamic _deepUpdateRecursive<T>(List keyPath, dynamic data, T value, [int i = 0]) {
    if (i == keyPath.length) {
      return value;
    }
    if (data is! Map) {
      data = Map.identity();
    }
    data = Map.from(data);
    data[keyPath[i]] = _deepUpdateRecursive(keyPath, data[keyPath[i]], value, ++i);
    return data;
  }
}
