// ignore_for_file: avoid_print
enum Severity { info, warning, error }

void logInfo(Object? object) => log(object, Severity.info);

void logWarning(Object? object) => log(object, Severity.warning);

void logError(Object? object) => log(object, Severity.error);

void log(Object? object, Severity severity) {
  switch (severity) {
    case Severity.info:
      print(object);
      break;
    case Severity.warning:
      print("\x1B[33m\x1B[1m[W]\x1B[0m\x1B[33m - $object\x1B[0m");
      break;
    case Severity.error:
      print("\x1B[31m\x1B[1m[E]\x1B[0m\x1B[33m - $object\x1B[0m");
      break;
    default:
  }
}
