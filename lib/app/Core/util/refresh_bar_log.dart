import 'package:flutter/foundation.dart';

// "Couldn't refresh · Retry" flag changes (chat list + chat screens), debug
// builds only: `[REFRESH-BAR] <screen> <key> trigger=<reason> +<ms>ms <event>`.
// Never logs a token, a response body or message text.

final Stopwatch _clock = Stopwatch()..start();

void refreshBarLog(String screen, String key, String trigger, String event) {
  if (!kDebugMode) return;
  debugPrint('[REFRESH-BAR] $screen $key trigger=$trigger '
      '+${_clock.elapsedMilliseconds}ms $event');
}
