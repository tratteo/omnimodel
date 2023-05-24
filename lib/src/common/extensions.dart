import "dart:math";

import "package:omnimodel/src/omnimodel.dart";

extension StringExtensions on String {
  /// Returns a value between in range `[0,1]` indicating the similarity ratio of the two substrings using the active similarity algorithm defined in [OmniModelPreferences.similarityBackend]
  double activeSimilarity(String t, {bool caseSensitive = false}) {
    switch (OmniModelPerferences.similarityBackend) {
      case SimilarityBackend.levenshtein:
        return t.levenshtein(this, caseSensitive: caseSensitive);
      case SimilarityBackend.convolution:
        return t.similarityConvolution(this, caseSensitive: caseSensitive);
    }
  }

  /// Returns a value between in range `[0,1]` indicating the similarity ratio of the two substrings
  double similarityConvolution(String t, {bool caseSensitive = false}) {
    var minSeq = length < t.length
        ? caseSensitive
            ? this
            : toLowerCase()
        : caseSensitive
            ? t
            : t.toLowerCase();
    var maxSeq = length < t.length
        ? caseSensitive
            ? t
            : t.toLowerCase()
        : caseSensitive
            ? this
            : toLowerCase();

    var maxMatch = 0;
    // Convolution
    for (var i = 0; i < maxSeq.length; i++) {
      var cost = 0;
      if (i + minSeq.length > maxSeq.length) return maxMatch / minSeq.length;
      for (var j = 0; j < minSeq.length; j++) {
        cost += maxSeq[i + j] == minSeq[j] ? 1 : 0;
      }
      maxMatch = max(maxMatch, cost);
    }
    return maxMatch / minSeq.length;
  }

  /// Calculate a coefficient based on the *Levenshtein* distance between two arbitrary strings
  double levenshtein(String t, {bool caseSensitive = true}) {
    var s = this;
    if (!caseSensitive) {
      s = s.toLowerCase();
      t = t.toLowerCase();
    }
    var maxLen = max(t.length, length);
    if (s == t) return 0;
    if (s.isEmpty) return 1 - (t.length / maxLen);
    if (t.isEmpty) return 1 - (s.length / maxLen);

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

    return 1 - (v1[t.length] / maxLen);
  }
}

extension MapExtensions on Map {
  /// Perform a *deep update* of a map
  Map deepUpdate<T>(List<String> keyPaths, T value) {
    return _deepUpdateRecursive(keyPaths, this, value);
  }

  dynamic _deepUpdateRecursive<T>(
    List keyPath,
    dynamic data,
    T value, [
    int i = 0,
  ]) {
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
