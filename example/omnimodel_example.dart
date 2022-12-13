import "dart:convert";

import "package:omnimodel/omnimodel.dart";
import "package:omnimodel/src/common/logger.dart";

void main() {
  const map = {
    "first": 0,
    "second": "value",
    "third": {
      "key1": true,
      "key2": 0,
      "key3": [0, 1, 2, 3]
    },
    "fourth": [
      "tag1",
      "tag2",
      "tag3",
    ]
  };

  //* Run with
  //* dart run omnimodel_examples.dart

  // Create the model from the map
  var model = OmniModel.fromMap(map);

  // Uncomment to disable hints printing. Use this feature to conditionally disable printing in production.
  // OmniModelPerferences.enableHints = false;
  // Flutter:
  // OmniModelPreferences.enableHints = kDebugMode;
  logInfo(
      """
\n
░█████╗░███╗░░░███╗███╗░░██╗██╗███╗░░░███╗░█████╗░██████╗░███████╗██╗░░░░░
██╔══██╗████╗░████║████╗░██║██║████╗░████║██╔══██╗██╔══██╗██╔════╝██║░░░░░
██║░░██║██╔████╔██║██╔██╗██║██║██╔████╔██║██║░░██║██║░░██║█████╗░░██║░░░░░
██║░░██║██║╚██╔╝██║██║╚████║██║██║╚██╔╝██║██║░░██║██║░░██║██╔══╝░░██║░░░░░
╚█████╔╝██║░╚═╝░██║██║░╚███║██║██║░╚═╝░██║╚█████╔╝██████╔╝███████╗███████╗
░╚════╝░╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝╚═╝░░░░░╚═╝░╚════╝░╚═════╝░╚══════╝╚══════╝

█▀▀ ▀▄▀ ▄▀█ █▀▄▀█ █▀█ █░░ █▀▀ █▀
██▄ █░█ █▀█ █░▀░█ █▀▀ █▄▄ ██▄ ▄█                                                       
""");
  logInfo("map ${JsonEncoder.withIndent(" ").convert(map)}");
  logInfo("■" * 100);
  logInfo("■ map[first] > ${model.tokenOrNull("first")}\n${"-" * 100}");
  logInfo("■ map[first] as String > ${model.tokenOrNull<String>("first")}\n${"-" * 100}");
  logInfo("■ map[second] as String > ${model.tokenOr("second", "not found")}\n${"-" * 100}");
  logInfo("■ map[second] as List > ${model.tokenOr<List>("second", List.empty())}\n${"-" * 100}");
  logInfo("■ map[third] as Map > ${model.tokenOrNull<Map>("third")}\n${"-" * 100}");
  logInfo(
    "■ map[third][key3] with OmniModel concatenation > ${model.tokenAsModel("third").tokenOrNull("key3")}\n${"-" * 100}",
  );
  logInfo("■ map[third][key3] with combined path > ${model.tokenOrNull("third.key3")}\n${"-" * 100}");
  logInfo("■ map[fourth] as Map > ${model.tokenOr("fourth", {"new_key": 1})}\n${"-" * 100}");
  logInfo("■ map[fourth] as List > ${model.tokenOrNull<List>("fourth")}\n${"-" * 100}");
  logInfo("■ map[fifth] (not exists) > ${model.tokenOrNull("fifth")}\n${"-" * 100}");
  logInfo(
    "■ map[fifth] (not exists) with default value > ${model.tokenOr<String>("fifth", "not found")}\n${"-" * 100}",
  );
  logInfo("■ map[fourth1] (mispelled key) > ${model.tokenOrNull("fourth1")}\n${"-" * 100}");
  logInfo("■ map[third][key4] (mispelled key) > ${model.tokenOrNull("third.key4")}\n${"-" * 100}");
  logInfo("■ Iterate");
  model.json.forEach(
    (key, value) => logInfo("- ($key, $value)"),
  );
  logInfo("■" * 100);
  logInfo("EXTENSIONS");

  var s1 = "Hello World!";
  var s2 = "Hello mad World!";
  var distance = s1.levenshtein(s2);
  logInfo("■ Levenshtein distance ($s1) - ($s2) > $distance");

  var mapCopy = OmniModel.fromMap(map).json;
  logInfo("■ Deep update");
  logInfo("\tinitial map = $mapCopy");
  var edited = mapCopy.deepUpdate(["third", "key2"], "string!");
  logInfo('\tdeep updated [third, key2] < "string!" = $edited');
  edited = mapCopy.deepUpdate(["third", "key4"], ":D");
  logInfo('\tdeep updated [third, key4] < ":D" = $edited');
  edited = mapCopy.deepUpdate(["third", "key2", "new_key"], "newkey!");
  logInfo('\tdeep updated [third, key2, new_key] < "newkey!" = $edited');
}
