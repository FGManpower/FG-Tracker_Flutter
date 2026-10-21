import 'package:fgtracker/app/Core/util/IncommingCallKit/callkit_service.dart:.dart';

class CallSessionState {
  static String? sessionId;
  static void reset() => sessionId = null;
}


Future<void> callEnded(String sessionId, {String? type}) async {
  if (sessionId.isEmpty) return;
  await CallKitService.dismiss(sessionId);
}
