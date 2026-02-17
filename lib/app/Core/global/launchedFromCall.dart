class CallSessionState {
  static bool isCallActive = false;
  static bool launchedFromCall = false;
  static String? currentCallKitId;


  static Map<String, dynamic>? pendingCallData;

  static void reset() {
    isCallActive = false;
    launchedFromCall = false;
    pendingCallData = null;
    currentCallKitId = null;
  }
}
