// ignore_for_file: avoid_print
import "package:tint/tint.dart";

enum Severity { info, warning, error }

void printInfo(Object? object) => omniPrint(object, Severity.info);

void printWarning(Object? object) => omniPrint(object, Severity.warning);

void printError(Object? object) => omniPrint(object, Severity.error);

void omniPrint(Object? object, Severity severity) {
  switch (severity) {
    case Severity.info:
      print("[omnimodel] $object".dim());
      break;
    case Severity.warning:
      print("[omnimodel] $object".yellow().dim());
      break;
    case Severity.error:
      print("[omnimodel] $object".red().dim());
      break;
    default:
  }
}
