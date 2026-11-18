// There used to be a second `CallSessionState` class and a second top-level
// `callEnded()` here. The call screen read this copy while main.dart,
// SignallingService and CallKit wrote the other one, so the session id was
// split in two (BUG-CALL-18 / BUG-CALL-31). Kept as a re-export so existing
// imports keep working.
export 'package:fgtracker/app/Core/global/launchedFromCall.dart'
    show CallSessionState;
