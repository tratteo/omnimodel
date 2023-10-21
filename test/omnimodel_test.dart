// ignore_for_file: cast_nullable_to_non_nullable

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
    },
  };
  group("factories", () {
    test("empty", () {
      var model = OmniModel.empty();
      expect(model.json, {});
    });
    test("from dynamic", () {
      var model = OmniModel.fromDynamic(-1);
      expect(model.json, {});
      model = OmniModel.fromDynamic(testMap);
      expect(model.json, testMap);
      var newModel = OmniModel.fromDynamic(model);
      expect(model.json, newModel.json);
    });
    test("from map", () {
      var model = OmniModel.fromMap({});
      expect(model.json, {});
      model = OmniModel.fromMap(testMap);
      expect(model.json, testMap);
    });
    test("from entries", () {
      var model = OmniModel.fromEntries([]);
      expect(model.json, {});
      model = OmniModel.fromEntries(testMap.entries);
      expect(model.json, testMap);
    });

    test("from raw json", () {
      var model = OmniModel.fromRawJson("");
      expect(model.json, {});
      model = OmniModel.fromRawJson(jsonEncode(testMap));
      expect(model.json, testMap);
    });
  });
  group("properties", () {
    test("length", () {
      var model = OmniModel.empty();
      expect(model.length, 0);
      model = OmniModel.fromMap(testMap);
      expect(model.length, testMap.entries.length);
    });
    test("is empty", () {
      var model = OmniModel.empty();
      expect(model.isEmpty, true);
      model = OmniModel.fromMap(testMap);
      expect(model.isEmpty, testMap.isEmpty);
    });
    test("is not empty", () {
      var model = OmniModel.empty();
      expect(model.isNotEmpty, false);
      model = OmniModel.fromMap(testMap);
      expect(model.isNotEmpty, testMap.isNotEmpty);
    });

    test("json copy", () {
      var model = OmniModel.empty();
      expect(model.json, {});
      model = OmniModel.fromMap(testMap);
      expect(model.json, testMap);
      var jsonCopy = model.json;
      jsonCopy[testMap.entries.first.key] = null;
      expect(
        model.json[testMap.entries.first.key],
        testMap.entries.first.value,
      );
    });
  });
  group("methods", () {
    setUp(() {});
    test("clone", () {
      var model = OmniModel.fromMap(testMap);
      var clone = model.clone();
      expect(model.json, clone.json);
      model.edit({"l11": 100});
      expect(model.json, isNot(clone.json));
    });
    test("to raw json", () {
      var model = OmniModel.fromRawJson(jsonEncode(testMap));
      expect(model.toRawJson(), jsonEncode(testMap));
      expect(model.toRawJson(indent: "\t"), JsonEncoder.withIndent("\t").convert(model.json));
    });
    test("json automatic conversion", () {
      var model = OmniModel.fromMap(testMap);
      expect(jsonEncode(model), jsonEncode(testMap));
      model.edit({
        "new_model": OmniModel.fromMap({"new_id": 0, "another_id": 1}),
      });
      expect(jsonEncode(model), jsonEncode(model.json));
    });
    test("token as model", () {
      var model = OmniModel.fromMap(testMap);

      expect(
        model.tokenAsModel("l13.l22").json,
        (testMap["l13"] as Map)["l22"],
      );

      expect(
        model.tokenAsModel("l13/l22").json,
        (testMap["l13"] as Map)["l22"],
      );
      expect(
        model.tokenAsModel("l13,l22").json,
        (testMap["l13"] as Map)["l22"],
      );
      expect(
        model.tokenAsModel(r"l13\l22").json,
        (testMap["l13"] as Map)["l22"],
      );
      expect(
        model.tokenAsModel("l13|l22").json,
        (testMap["l13"] as Map)["l22"],
      );
    });

    test("token or", () {
      var model = OmniModel.fromMap(testMap);
      expect(model.tokenOr("l11", 1), testMap["l11"]);
      expect(model.tokenOr("invalid", 1), 1);
      expect(
        model.tokenOr<Map>("l13.l22", {}),
        (testMap["l13"] as Map)["l22"],
      );
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
    test("edit", () {
      var model = OmniModel.fromMap(testMap).copyWith({"l11": 1});
      expect(model.tokenOrNull("l11"), 1);
      model.edit({"l13.l22": 1});
      expect(model.tokenOrNull("l13.l22"), 1);
      model.edit({"new": 1});
      expect(model.tokenOrNull("new"), 1);
    });
  });
  group("preferences", () {
    setUp(() {
      OmniModelPerferences.enableHints = false;
    });

    test("lower case keys", () {
      var newMap = testMap.deepUpdate(["Key"], "value");
      OmniModelPerferences.enforceLowerCaseKeys = true;
      var model = OmniModel.fromMap(newMap);
      expect(model.tokenOrNull("key"), isNot(null));
      expect(model.tokenOrNull("Key"), isNot(null));
      OmniModelPerferences.enforceLowerCaseKeys = false;
      model = OmniModel.fromMap(newMap);
      expect(model.tokenOrNull("key"), null);
      expect(model.tokenOrNull("Key"), isNot(null));
    });
  });
}
