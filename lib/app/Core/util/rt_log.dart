import 'package:flutter/foundation.dart';

/// Diagnostic log for realtime / attendance flows. Prints only in debug
/// builds, so release builds don't leak socket payloads or poll data.
void rtLog(String message) {
  if (kDebugMode) debugPrint(message);
}
