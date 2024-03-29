import "dart:convert";

import "package:omnimodel/omnimodel.dart";
import "package:omnimodel/src/common/logger.dart";

void showStringDistances(String s1, String s2) {
  var distance = s1.similarityConvolution(s2);
  printInfo("■ Similarity convolution distance ($s1) - ($s2) > $distance");
  distance = s1.levenshtein(s2);
  printInfo("■ Levenshtein distance ($s1) - ($s2) > $distance");
}

void main() {
  const map = {
    "first": 0,
    "second": "value",
    "third": {
      "key1": true,
      "key2": 0,
      "key3": [0, 1, 2, 3],
    },
    "fourth": [
      "tag1",
      "tag2",
      "tag3",
    ],
  };

  //* Run with
  //* dart run omnimodel_examples.dart

  // Create the model from the map
  var model = OmniModel.fromMap(map);

  // Uncomment to disable hints printing. Use this feature to conditionally disable printing in production.
  // OmniModelPerferences.enableHints = false;
  // Flutter:
  // OmniModelPreferences.enableHints = kDebugMode;
  printInfo("""
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
  printInfo("map ${JsonEncoder.withIndent(" ").convert(map)}");
  print("■" * 100);
  printInfo("■ map[first] > ${model.tokenOrNull("first")}\n${"-" * 100}");
  printInfo(
    "■ map[first] as String > ${model.tokenOrNull<String>("first")}\n${"-" * 100}",
  );
  printInfo(
    "■ map[second] as String > ${model.tokenOr("second", "not found")}\n${"-" * 100}",
  );
  printInfo(
    "■ map[second] as List > ${model.tokenOr<List>("second", List.empty())}\n${"-" * 100}",
  );
  printInfo(
    "■ map[third] as Map > ${model.tokenOrNull<Map>("third")}\n${"-" * 100}",
  );
  printInfo(
    "■ map[third][key3] with OmniModel concatenation > ${model.tokenAsModel("third").tokenOrNull("key3")}\n${"-" * 100}",
  );
  printInfo(
    "■ map[third][key3] with combined path > ${model.tokenOrNull("third.key3")}\n${"-" * 100}",
  );
  printInfo("■ map[fourth] as Map > ${model.tokenOr("fourth", {"new_key": 1})}\n${"-" * 100}");
  printInfo(
    "■ map[fourth] as List > ${model.tokenOrNull<List>("fourth")}\n${"-" * 100}",
  );
  printInfo(
    "■ map[fifth] (not exists) > ${model.tokenOrNull("fifth")}\n${"-" * 100}",
  );
  printInfo(
    "■ map[fifth] (not exists) with default value > ${model.tokenOr<String>("fifth", "not found")}\n${"-" * 100}",
  );
  printInfo(
    "■ map[fourth1] (mispelled key) > ${model.tokenOrNull("fourth1")}\n${"-" * 100}",
  );
  printInfo(
    "■ map[third][key4] (mispelled key) > ${model.tokenOrNull("third.key4")}\n${"-" * 100}",
  );
  printInfo("■ Similar");
  printInfo("\tmost similar to thirt > ${model.similar("thirt")}");
  printInfo("\tmost similar to secondly > ${model.similar("secondly")}");
  printInfo("\tmost similar to fifth > ${model.similar("fifth")}");

  printInfo("■ Iterate");
  model.json.forEach(
    (key, value) => printInfo("($key, $value)"),
  );
  print("■" * 100);
  printInfo("EXTENSIONS");

  showStringDistances("Hello World!", "Hello mad World!");
  showStringDistances("Hello World!", "Hello World!");
  showStringDistances("Hello World!", "Hello World.");
  showStringDistances("abba", "aaaa");
  showStringDistances("ab ba", "aaaa");

  var mapCopy = OmniModel.fromMap(map).json;
  printInfo("■ Deep update");
  printInfo("\tinitial map = $mapCopy");
  var edited = mapCopy.deepUpdate(["third", "key2"], "string!");
  printInfo('\tdeep updated [third, key2] < "string!" = $edited');
  edited = mapCopy.deepUpdate(["third", "key4"], ":D");
  printInfo('\tdeep updated [third, key4] < ":D" = $edited');
  edited = mapCopy.deepUpdate(["third", "key2", "new_key"], "newkey!");
  printInfo('\tdeep updated [third, key2, new_key] < "newkey!" = $edited');
}
