import "dart:convert";

import "package:omnimodel/omnimodel.dart";
import "package:test/test.dart";

void main() {
  const testMap = {
    "l11": 0,
    "l12": 0,
    "l13": {
      "l21": 0,
      "l22": {
        "l31": 0,
        "l32": 0,
      },
    }
  };
  group("factories", () {
    test("identity", () {
      var model = OmniModel.identity();
      expect(model.json, Map.identity());
    });
    test("from dynamic or identity", () {
      var model = OmniModel.fromDynamicOrIdentity(-1);
      expect(model.json, Map.identity());
      model = OmniModel.fromDynamicOrIdentity(testMap);
      expect(model.json, testMap);
    });
    test("from map", () {
      var model = OmniModel.fromMap(Map.identity());
      expect(model.json, Map.identity());
      model = OmniModel.fromMap(testMap);
      expect(model.json, testMap);
    });
    test("from entries", () {
      var model = OmniModel.fromEntries([]);
      expect(model.json, Map.identity());
      model = OmniModel.fromEntries(testMap.entries);
      expect(model.json, testMap);
    });

    test("from raw json", () {
      var model = OmniModel.fromRawJson("");
      expect(model.json, Map.identity());
      model = OmniModel.fromRawJson(jsonEncode(testMap));
      expect(model.json, testMap);
    });
  });
  group("properties", () {
    test("length", () {
      var model = OmniModel.identity();
      expect(model.length, 0);
      model = OmniModel.fromMap(testMap);
      expect(model.length, testMap.entries.length);
    });
    test("is empty", () {
      var model = OmniModel.identity();
      expect(model.isEmpty, true);
      model = OmniModel.fromMap(testMap);
      expect(model.isEmpty, testMap.isEmpty);
    });
    test("is not empty", () {
      var model = OmniModel.identity();
      expect(model.isNotEmpty, false);
      model = OmniModel.fromMap(testMap);
      expect(model.isNotEmpty, testMap.isNotEmpty);
    });

    test("json copy", () {
      var model = OmniModel.identity();
      expect(model.json, Map.identity());
      model = OmniModel.fromMap(testMap);
      expect(model.json, testMap);
      var jsonCopy = model.json;
      jsonCopy[testMap.entries.first.key] = null;
      expect(model.json[testMap.entries.first.key], testMap.entries.first.value);
    });
  });
  group("methods", () {
    setUp(() {});

    test("to raw json", () {
      var model = OmniModel.fromRawJson(jsonEncode(testMap));
      expect(model.toRawJson(), jsonEncode(testMap));
    });
    test("token as model", () {
      var model = OmniModel.fromMap(testMap);
      // ignore: cast_nullable_to_non_nullable
      expect(model.tokenAsModel("l13.l22").json, (testMap["l13"] as Map)["l22"]);
      // ignore: cast_nullable_to_non_nullable
      expect(model.tokenAsModel("l13/l22").json, (testMap["l13"] as Map)["l22"]);
      // ignore: cast_nullable_to_non_nullable
      expect(model.tokenAsModel("l13,l22").json, (testMap["l13"] as Map)["l22"]);
      // ignore: cast_nullable_to_non_nullable
      expect(model.tokenAsModel(r"l13\l22").json, (testMap["l13"] as Map)["l22"]);
      // ignore: cast_nullable_to_non_nullable
      expect(model.tokenAsModel("l13|l22").json, (testMap["l13"] as Map)["l22"]);
    });

    test("token or", () {
      var model = OmniModel.fromMap(testMap);
      expect(model.tokenOr("l11", 1), testMap["l11"]);
      expect(model.tokenOr("invalid", 1), 1);
      // ignore: cast_nullable_to_non_nullable
      expect(model.tokenOr<Map>("l13.l22", Map.identity()), (testMap["l13"] as Map)["l22"]);
    });
    test("token or null", () {
      var model = OmniModel.fromMap(testMap);
      expect(model.tokenOrNull("l11"), testMap["l11"]);
      expect(model.tokenOrNull("invalid"), isNull);
    });
    test("copy with", () {
      var model = OmniModel.fromMap(testMap).copyWith({"l11": 1});
      expect(model.tokenOrNull("l11"), 1);
      model = model.copyWith({"l13.l22": 1});
      expect(model.tokenOrNull("l13.l22"), 1);
      model = model.copyWith({"new": 1});
      expect(model.tokenOrNull("new"), 1);
    });
  });
}
