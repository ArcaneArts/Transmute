import 'package:fast_log/fast_log.dart';

bool verboseMode = false;

void v(dynamic msg) {
  if (verboseMode) {
    verbose(msg);
  }
}
