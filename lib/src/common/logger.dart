// ignore_for_file: avoid_print
enum Severity { info, warning, error }

void logInfo(Object? object) => log(object, Severity.info);

void logWarning(Object? object) => log(object, Severity.warning);

void logError(Object? object) => log(object, Severity.error);

void log(Object? object, Severity severity) {
  switch (severity) {
    case Severity.info:
      print("[omnimodel] - $object");
      break;
    case Severity.warning:
      print("[omnimodel warning] - $object");
      break;
    case Severity.error:
      print("[omnimodel error] - $object");
      break;
    default:
  }
}
