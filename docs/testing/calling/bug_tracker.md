# Calling (1:1) — Bug Tracker

Testing-only file. The feature guide is [`docs/02_CALLING_MODULE_FRONTEND.md`](../../02_CALLING_MODULE_FRONTEND.md) (Part 0 flows and plan are in §5 there).

| | |
|---|---|
| Last updated | 2026-11-18 — Part 0 audit + **Phase 1 fixes (uncommitted)** |
| Branch / HEAD | `46Solution` @ `3e16f524`, working tree clean at audit time |
| App code changed | Phase 1 only (see "Status after Phase 1"); nothing committed |
| Proof type | **Code path** = confirmed by reading the code (file:line). **Device** = reproduced on a phone. **Test** = failing unit test. Part 0 has code-path proof only; device runs and failing tests come in Phase 1 (each fix gets a test that fails on the old code). |

Paths are under `lib/app/` unless they start with `lib/main.dart`, `android/`, `ios/` or `test/`. Line numbers are for `3e16f524`.

**Status values:** Confirmed · Partly confirmed (true, but narrower than first thought) · Not confirmed · Open (needs backend / device).

---

## Summary

| ID | Bug | Status | Severity | Phase |
|---|---|---|---|---|
| BUG-CALL-01 (C1) | Stale permanent `CallingController` reused after hang-up / missed / overlay end / CallKit end | **Confirmed** | Critical | 1 |
| BUG-CALL-02 (C2) | Controller holds the socket captured at construction | **Partly confirmed** | High (only together with C1) | 1 |
| BUG-CALL-03 (C3) | `socket.off(event)` with no handler removes global handlers | **Partly confirmed** | Medium | 1 |
| BUG-CALL-04 (C4) | In-app reject sends own id as `remoteUserId` | **Confirmed** | High | 1 |
| BUG-CALL-05 (C5) | Busy / second call: fake "Ringing", handler hijack, auto-end after 2 s | **Confirmed** | High | 3 (needs backend) |
| BUG-CALL-06 (C6) | No ICE restart / network-change recovery | **Confirmed** | High | 3 |
| BUG-CALL-07 (C7) | Production TURN has no `turns:443`; static TURN credentials in the app | **Confirmed** | High (security + reach) | 3 (needs backend) |
| BUG-CALL-08 (C8) | Ring timeout 40 s (caller) vs 45 s (callee CallKit) | **Confirmed** | Medium | 1 (client) / 4 (server) |
| BUG-CALL-09 (C9) | System "End" ignored while connecting | **Confirmed** | High | 1 |
| BUG-CALL-10 (C10) | `getCallStatus` stub → stale ringing never cleared | **Confirmed** | Medium | 1 |
| BUG-CALL-11 (C11) | iOS VoIP token updates never uploaded; `OtpController` early return | **Confirmed** | High (iOS killed-app ringing) | 3 (+ protected-file question) |
| BUG-CALL-12 (C12) | Outgoing calls not in CallKit; CallKit mute/hold unmapped | **Confirmed** | Medium | 3 |
| BUG-CALL-13 (C13) | Permissions checked only for outgoing; denied camera drops whole call | **Confirmed** | High | 2 |
| BUG-CALL-14 (C14) | Two incoming UIs with different argument shapes | **Confirmed** | Medium | 1 |
| BUG-CALL-15 (C15) | Android FGS starts only after ICE connects; no `camera` type | **Confirmed** | High (Android 14) | 1 |
| BUG-CALL-16 (C16) | No system PiP | **Confirmed** | Low (feature) | 3 |
| BUG-CALL-17 (C17) | Missing WhatsApp states / end screen / tones; hard-coded English | **Confirmed** | Medium | 3 |
| BUG-CALL-18 (C18) | Hygiene: duplicate `callEnded()`, getter side effect, location init during call, backup files | **Confirmed** | Medium (location prompt mid-call) | 1 |
| BUG-CALL-19 (C19) | Guide 02 out of date (now also wrong about prod TLS 443) | **Confirmed** | Low | Docs |
| BUG-CALL-20 (C20) | `/callSignaling` connects with `callerId` only, no token | **Confirmed (client)** · backend **Open** | Critical if backend trusts it | 4 |
| BUG-CALL-21 (new) | Starting a call force-deletes a live minimized call → zombie call | **Confirmed** | High | 1 |
| BUG-CALL-22 (new) | End from the overlay pops the user's current screen | **Confirmed** | Medium | 1 |
| BUG-CALL-23 (new) | iOS Recents call-back handler never registered | **Confirmed** | Low | 3 |
| BUG-CALL-24 (new) | `CallRepo.isCallActive`: no timeout, `false` on error, double slash in URL | **Confirmed** | Medium (blocks C10 fix) | 1 |
| BUG-CALL-25 (new) | iOS: PushKit push with nil plugin instance → no CallKit report, app killed; `aps-environment=development` for all configs | **Confirmed** | High (iOS) | 3 |
| BUG-CALL-26 (new) | System End while Dart is dead sends nothing to the server | **Confirmed** | Medium | 3 |
| BUG-CALL-27 (new) | Android manifest: phantom exported receiver, dead ConnectyCube service, invalid app-level FGS attr | **Confirmed** | Medium (crash vector) | 1 |
| BUG-CALL-28 (new) | Native reject API over cleartext HTTP; response body logged | **Confirmed** | Medium (security) | 3 |
| BUG-CALL-29 (new) | iOS accept force-enables WebRTC audio after 0.75 s, outside CallKit `didActivate` | **Confirmed (code)** · effect **Open** (device) | Medium | 3 |
| BUG-CALL-30 (new) | Direct `Routes.callScreen` entry points skip the permission check | **Confirmed** | Medium | 2 |

---

## Status after Phase 1 (2026-11-18, uncommitted)

"Fixed" = fixed in code, unit test passes, the test fails when the old behaviour is put back (see [unit_testing/unit_test_report.md](unit_testing/unit_test_report.md)). **Phone check pending for all of them.**

| ID | Status | Fix | Test |
|---|---|---|---|
| BUG-CALL-01 | Fixed | One end path `_finishCall` releases the controller on every end; `StreamBinding` reuses only a live call; args read in `onInit`; call screen never creates a controller | CT-01 |
| BUG-CALL-02 | Fixed | `socket` is a getter on both controllers and in `main.dart`; `SignallingService.ensureConnected()` before the call starts (nothing is sent if it fails; user sees "Unable to connect to call server") | CT-02 |
| BUG-CALL-03 | Fixed | `CallSocketHandlers`: each controller removes only its own handlers | CT-03 |
| BUG-CALL-04 | Fixed | `rejectCallPayload` (caller id) | CT-04 |
| BUG-CALL-08 | Fixed (client) | `kCallRingTimeout` = 45 s for the caller timer and CallKit `duration`; server ownership is Part 4 | CT-10 |
| BUG-CALL-09 | Fixed | `handleSystemEndCall`: always ends; only the Android audio-handover End is ignored | CT-11 |
| BUG-CALL-10 | Fixed | `getCallStatus` → `CallRepo.fetchCallStatus` | CT-12 |
| BUG-CALL-14 | Fixed (arguments) | `incomingCallArgs` used by in-app accept, CallKit accept and the second-call path. Two screens still exist; the shared permission check is Phase 2 | CT-14 |
| BUG-CALL-15 | Fixed (code), phone check pending | `CallForegroundService`: started in `onInit`, `microphone` (+`camera` when granted), Hang up button, localized texts, stops only what it started; manifest adds `camera` | CT-15a/b |
| BUG-CALL-18 | Fixed | One `CallSessionState` (re-export), getter without side effect, location keep-alive kept but never prompts (`CallPlatform.keepTrackingAlive`); backup files untouched | CT-18a/b |
| BUG-CALL-21 | Fixed | `CallingController.prepareForNewCall()` replaces every force-delete; a live call shows "You're already on a call" and is brought back | CT-21 |
| BUG-CALL-22 | Fixed | `_exitCallScreen` does not pop while minimized | CT-22 |
| BUG-CALL-24 | Fixed | `fetchCallStatus`: 4 s timeout, `null` = unknown, URL fixed (`isCallActive` left as is, unused) | CT-12b/c |
| BUG-CALL-27 | Fixed (manifest) | Phantom receiver, ConnectyCube service and the invalid application attribute removed | Build + phone |
| BUG-CALL-31 (new) | Fixed | Two `CallSessionState` classes: the call screen read one copy, main / SignallingService / CallKit wrote the other | CT-01 (indirect) |
| BUG-CALL-32 (new) | Fixed | Call end stopped **any** running foreground service, incl. walkie-talkie's; after a screen share the call had no service | Code review |
| BUG-CALL-33 (new) | Fixed | `endCall` was sent twice after a reconnect (buffered emit + `once("connect")` re-emit) | Code review |
| BUG-CALL-34 (new) | Fixed | A navigation error in the end path skipped the rest of the cleanup (service, CallKit, wakelock stayed on); a renderer error skipped peer cleanup | Found by CT-15a |
| BUG-CALL-35 (new) | Fixed | Video renderers were never disposed (hidden by the permanent controller) | Code review |

### Phase 2 (permissions), 2026-11-18, uncommitted

| ID | Status | Fix | Test |
|---|---|---|---|
| BUG-CALL-13 | Fixed (code), phone check pending | `CallPermissionPolicy` + `CallPermissionFlow` used by every entry point: outgoing (`CallService`), accept (in-app and CallKit, on the call screen), camera on mid-call, "Camera off · Allow" chip, route sheet (Bluetooth). Refused mic at accept ends cleanly with `reason: permission_denied` and a toast; refused camera = voice with camera off. No hard-coded English (12 new keys × 20 locales). `BLUETOOTH_CONNECT` asked on Android 12+. Re-check after Settings. | PM-01 … PM-12 |
| BUG-CALL-30 | Fixed | Profile screen and tracking map now go through `CallService` | PM-01c (CallService) + code review |
| BUG-CALL-36 (new) | Fixed | After the app was killed during an accepted call, relaunch reopened it (`_recoverAcceptedCall`); now dismissed when the server says the call ended | PM-11 |

### Phase 3 (WhatsApp / IMO parity), 2026-11-18, uncommitted

| ID | Status | Fix | Test |
|---|---|---|---|
| BUG-CALL-05 | Fixed (client); **BE B-04** for the caller's "busy" | Waiting banner (End & accept / Decline), `CallingStatus busy` instead of fake "Ringing", no system UI over a call, system-UI accept ends the current call first, old 2 s auto-switch removed | CT-05, CT-06a/b, push test |
| BUG-CALL-06 | Fixed (client); **BE B-06** for rejoin | `CallLinkMonitor`: Reconnecting…, ICE restart over `upgradeToVideo`, retry every 6 s, give up after 25 s with `connection_lost`; `rejoinCall` after a socket reconnect | CT-07, CT-08, CT-08b, CT-09 |
| BUG-CALL-07 | Partly: client done; **BE B-09** (endpoint, TLS listener, rotation) | `TurnCredentialService` + `turns:…:443` fallback | TURN tests |
| BUG-CALL-11 | Fixed (client); **BE B-10** endpoint | `VoipTokenUploader` once per new token; full token no longer logged | CT-13 |
| BUG-CALL-12 | Fixed in code; **iOS not compiled / run here** | Outgoing calls in CallKit, `prepareCallKitAudio` (same audio path, 2 s safety net), CallKit mute / hold → controller, in-app mute synced to CallKit, `supportsHolding` | CT-14, hold test |
| BUG-CALL-16 | Android done (native, no plugin); iOS not done (entitlement) | `MainActivity` PiP + `CallPip` auto-PiP for a connected visible video call | PiP policy test + phone |
| BUG-CALL-17 | Fixed | Quality badge + bitrate drop + camera tip, "X muted" / "Video paused" / "On hold" pills, end screen with Call again, end / busy tones, missed-call Call back | quality tests, CT-14, UI-01 |
| BUG-CALL-19 | Fixed | Guide v1.4.0 | — |
| BUG-CALL-37 (new, from the E2E work) | Fixed | `callEnded` / `callRejected` naming another call ended the current one | BUG-CALL-37 test |
| BUG-CALL-38 (new) | Fixed | `SignallingService` overwrote the live session id with the id of any `callEnded` | same test (mutation M35) |

**Found during E2E tooling, not changed in the app (listed for the backend or later):** mixed `remoteUserId` types (B-14); in-app accept has no `sessionId` because `IncomingCallModel` has none (needs `session_id` in the push `callData`); `missCall` payload has no `callerId` / `sessionId`; `requestVideoUpgrade` / `needKeyframe` traffic is not in the protocol table.

Still open after Phase 3:
- Backend: BUG-CALL-20 (B-01 / B-02) and the BE parts above.
- App, decision needed: BUG-CALL-25 (iOS nil plugin path), BUG-CALL-26 (native End with Dart dead), BUG-CALL-28 (native decline over HTTP; needs B-13), BUG-CALL-29 (forced audio after 0.75 s; needs an iPhone).
- iOS: PiP (entitlement), BUG-CALL-23 (Recents call-back).

Still open after Phase 2: BUG-CALL-05, -06, -07, -11, -12, -16, -17, -20, -23, -25, -26, -28, -29 (Phase 3 / backend), BUG-CALL-19 (docs v1.4.0).

**Side effect to know about (walkie-talkie).** `flutter_foreground_task` delivers notification-button presses to the app only after `initCommunicationPort()`, which the app never called, so walkie's "Open walkie" button only did `launchApp`. The call service now calls it (needed for Hang up). After the first call, walkie's own handler also runs; it already checks the current route, so the walkie screen is not opened twice. Check on a phone (M-14).

---

## Details

### BUG-CALL-01 (C1) — stale permanent controller · Confirmed
- **Root cause.** `StreamBinding` puts `CallingController` with `permanent: true` (`modules/mediaStream/Bindings/call_binding.dart:12-18`; same in `Views/calling_screen.dart:24-27`). The only `Get.delete` inside the controller is in `_cleanupCall` (`calling_controller.dart:1002-1004`).
- **Paths that do *not* delete it:** `endCall` (`:2435-2471`: own hang-up, CallKit end via `main.dart:207`, overlay End via `in_app_call_overlay_service.dart:41`, `missedCall()` via `:2662`), and `_onMissedCall` (`:1614-1651`). Only `callEnded` from the remote, `callRejected`, `callStatus` terminal, `callError`, `callBlocked` and init failure go through `_cleanupCall`.
- **Effect (code path).** On the next call from Chat / Calls tab / Recent / Contacts (`CallService.startOutGoingCall`, none of them delete first) the binding finds the old instance, `onInit` does not run, so `_setupPeer` never runs and **no `makeCall` is sent**. `args` (`:95`) is the old call's. `_remoteEndSent` (`:84`) and `_hasExitedScreen` (`:83`) stay `true`, so End neither reaches the other side (`:542`) nor closes the screen (`:581`). After an overlay End, `isMinimized` also stays `true`, so `onClose` returns early (`:3218-3221`) if it is deleted later.
- **Workaround already in code.** `DialogBox.dart:1554,1632`, `UserProfileScreen.dart:419` and `Tracking_screen.dart:3418,3443` force-delete before calling. This is what makes calls from those screens work, and it causes BUG-CALL-21.
- **Proof needed in Phase 1:** CT-01 (3 calls in a row) and a device run (Part 0 step 5).

### BUG-CALL-02 (C2) — captured socket · Partly confirmed
- `final socket = SignallingService.instance.socket;` at construction (`calling_controller.dart:51`, `incoming_call_controller.dart:15`, plus an unused top-level copy in `lib/main.dart:50`).
- `SignallingService.init` disposes and replaces the socket (`Data/Services/Socket/Socket_SignallingService.dart:24-40`) at app start (`main.dart:308`) and at OTP login (`OtpController.dart:276`). Logout sets it to `null` (`logoutuser.dart:144` → `:137-143`).
- A **fresh** controller always reads the current socket, so on its own this is harmless. It bites when the controller outlives the socket. That happens only with BUG-CALL-01: hang up, log out, log in, call again, and the reused controller holds a disposed socket. Normal socket reconnects keep the same `Socket` object, so they are not affected.
- Fix stays as planned (a getter on `SignallingService`, plus wait-for-connect with a timeout before `makeCall`).

### BUG-CALL-03 (C3) — `off(event)` without a handler · Partly confirmed
- Removes **all** handlers: `incoming_call_controller.dart:43, 58, 74-76, 82-84, 97-99` (`callEnded`, `missedCall`, `newCall`); `calling_controller.dart:1666, 1670-1671, 1673-1680` and `onClose :3233-3245` (`callRejected`, `callStatus`, `sdpOfferFromCaller`, `callError`, `callBlocked`, `screen_share_*`, `upgradeToVideo*`), `:2068-2069, 2153-2154` (`IceCandidate`, `callAnswered`).
- **Narrower than first thought:** `CallKitService.bindSocket` listens with `socket.onAny(_hAny)` (`Data/Services/IncommingCallKit/callkit_service.dart:1116-1119`; `socket_io_client` 3.1.1). `onAny` is not touched by `off(event)`, so CallKit dismiss on `callEnded` / `callRejected` / `missedCall` / terminal `callStatus` and the foreground `newCall` → CallKit UI **keep working**.
- **What is lost:** the named handlers in `SignallingService.init`: `callRejected` (`:57-72`, dismiss + `CallSessionState.reset`), `callEnded` (`:74-81`), and `newCall` (`:91-127`, itself buggy, see C5). If the in-app incoming screen opens during a call, its `off("callEnded")` also removes the active `CallingController._onCallEnded`, so a remote hang-up would not close the call.
- The fix is still needed (own handler references only), but the user-visible effect is mostly a stale `CallSessionState`, not missed dismissals.

### BUG-CALL-04 (C4) — reject sends own id · Confirmed
- `incoming_call_controller.dart:85-89`: `"remoteUserId": myId`. The CallKit decline path sends the caller id correctly (`main.dart:188-191`), so only the in-app screen is wrong. The caller keeps ringing until 40 s and the call is logged as missed.

### BUG-CALL-05 (C5) — busy / second call · Confirmed
1. `_onNewCall` (`calling_controller.dart:1600-1606`) answers every `newCall` during a call with `CallingStatus: "Ringing"`.
2. `SignallingService` `newCall` (`:91-127`) overwrites the global `CallKitService.onAcceptCall` while on the call screen. Accepting ends the current call and opens the new one after a fixed 2 s. The handler is never restored, so later CallKit accepts also take this path.
3. `main.dart:162-165` ignores an accept while on the call screen (if 2 did not run).
4. In the foreground, `CallKitService._hNewCall` (via `onAny`) also shows the system incoming UI for the second call (`callkit_service.dart:976-1003`), so all three paths can fire for one event.
- No busy signal exists on the client. The server contract is needed (Part 4).

### BUG-CALL-06 (C6) — no network recovery · Confirmed
- `_startPeerDisconnectTimer` (`calling_controller.dart:2110-2133`): 30 s on `disconnected`, 12 s on `failed` (`:2190-2198, 2217-2224`), then `_handlePeerDisconnected` → `_cleanupCall(notifyRemote: true)`. No `restartIce`, no `iceRestart` offer, no connectivity listener (no connectivity plugin in `pubspec.yaml`), no re-sync on socket `connect` (only `CallKitService._hConnect` → `restoreActiveCalls`, which is a no-op, see C10).
- "Reconnecting..." text exists (`:2116`) but is a hard-coded English string.

### BUG-CALL-07 (C7) — TURN · Confirmed
- `Core/constant/urls.dart:71-97`: production list = `stun:` + `turn:…:3478` UDP/TCP only. **No `turns:…:443`** (staging has one). Guide §0.1 says prod has TLS 443, which is wrong (see C19).
- Username and credential are compile-time constants for both production and staging. The screen-share peer uses the same values (`calling_controller.dart:1836-1847`). Values are **not** reproduced here.

### BUG-CALL-08 (C8) — ring timeout mismatch · Confirmed
- Caller: `missCallDurationSeconds = 40` (`calling_controller.dart:102, 2638`). Callee: CallKit `duration: 45000` (`callkit_service.dart:589`). Guide says 45 s.

### BUG-CALL-09 (C9) — system End ignored while connecting · Confirmed
- `main.dart:197-209`: returns when `fromCallKit` and the timer has not started. The CallKit UI is already gone, so the user has no way to end the call, and the other side keeps connecting.

### BUG-CALL-10 (C10) — `getCallStatus` stub · Confirmed
- `main.dart:215`: `getCallStatus = (callId) async => null;`. `restoreActiveCalls` (`callkit_service.dart:1301-1328`) dismisses only when the status is non-null and not `ringing`, so nothing is ever dismissed. See BUG-CALL-24 before wiring `CallRepo.isCallActive`.

### BUG-CALL-11 (C11) — iOS VoIP token · Confirmed
- Native forwards token updates to Dart (`ios/Runner/AppDelegate.swift:308-317`). Dart routes `actionDidUpdateDevicePushTokenVoip` and the startup read (`callkit_service.dart:402-412, 1210-1212`) to `onVoipToken`, which **only logs** (`main.dart:217-219`). Logging the full token is itself a log-hygiene issue.
- **Protected file:** `modules/auth/Controller/OtpController.dart:96-104` returns before the FCM token is read when the VoIP token is `null` on iOS. Not edited; the user must decide (see the guide §5.5).

### BUG-CALL-12 (C12) — CallKit integration · Confirmed
- `FlutterCallkitIncoming.startCall` is not used anywhere in `lib/`. `_onEvent` (`callkit_service.dart:1158-1217`) handles accept / decline / timeout / ended / VoIP token. Mute, hold, DTMF and audio-session toggles fall into `default: 'EVENT not handled'`. `supportsHolding: false` (`:625`).
- AppDelegate uses manual audio for incoming calls only (`AppDelegate.swift:479-506, 551-576, 1129-1134`). Outgoing calls use WebRTC's own audio session.

### BUG-CALL-13 (C13) — permissions · Confirmed
- Only `Data/Services/call_service.dart:20-41` checks mic / camera. Its toasts are hard-coded English (`:27, :37`), and a permanent denial opens Settings without any continuation.
- In-app accept (`incoming_call_controller.dart:94-114`), CallKit accept (`main.dart:151-181`) and overlay expand go straight to the call screen. `getUserMedia` (`calling_controller.dart:2235-2242`) throws, and `_initializeCall` catch → `_cleanupCall(notifyRemote: true)` (`:948-951`). The call drops with no reason. A denied camera on a video call fails the whole `getUserMedia` (audio + video in one request).
- No `Permission.bluetoothConnect` request anywhere in `lib/` (the manifest declares it).

### BUG-CALL-14 (C14) — two incoming UIs · Confirmed
- In-app (`Data/Services/NotificationServices.dart:974-986` → `IncomingCallController.acceptCall`): `remoteUserId` = **me**, `callerProfile`, no `sessionId`, no `fromCallKit`.
- CallKit (`main.dart:169-180`): `remoteUserId` = caller, `profileImage`, `sessionId`, `fromCallKit: true`.
- The controller copes through the "target = whichever id is not me" logic (`calling_controller.dart:545-548, 797-805`), but status, CallKit and audio-handover branches differ (`:2268, 2315-2325, 2394-2398`).

### BUG-CALL-15 (C15) — Android foreground service · Confirmed
- Started only on ICE / peer `connected` (`calling_controller.dart:2186, 2212`; the earlier call is commented out at `:2233`). Types: `microphone + phoneCall`, falling back to `microphone` (`:1055-1071`). No `camera` type, and the manifest service declares `microphone|phoneCall|mediaProjection` only (`AndroidManifest.xml:140-145`). Notification title and text are hard-coded English (`:1051-1054`).
- The CallKit plugin's own `CallkitNotificationService` (merged manifest, `phoneCall|microphone|camera`) runs only while the CallKit call is up. On Android the handover releases it (`:2394-2433`).

### BUG-CALL-16 (C16) — no system PiP · Confirmed
- No `supportsPictureInPicture` on `MainActivity` (`AndroidManifest.xml:64-76`), no `AVPictureInPictureController`, no multitasking-camera entitlement. Only in-app overlays (`InAppCallOverlayService`, `flutter_in_app_pip` 1.7.5).

### BUG-CALL-17 (C17) — missing states / sounds · Confirmed
- `_logStats` (`calling_controller.dart:755-794`) is logging only. There is no muted / video-paused signal (`toggleMic` `:2478-2482` is local only), no end screen (`_cleanupCall` exits at once), no busy / end tones (only `Assets.music.ringing` `:2681`), and missed-call notification `isShowCallback: false` (`callkit_service.dart:591-595`).
- `callStatus` values (`"Calling"`, `"Connecting..."`, `"Reconnecting..."`, server strings) are raw English. Check how `calling_screen.dart` maps them before Phase 3.

### BUG-CALL-18 (C18) — hygiene · Confirmed
- Two top-level `callEnded()`: `Socket_SignallingService.dart:157` and `IncommingCallKit/call_session.dart:10`. Also two `CallSessionState` classes (`Core/global/launchedFromCall.dart:1`, `call_session.dart:4`).
- `formattedDuration` stops the ringtone (`calling_controller.dart:2613-2623`).
- `onInit` → `GroupTrackingController.instance.initializeLocation()` (`:703-707`) → `LocationService.initLocationTracking` → `handleLocationPermission()` and `_location.requestService()`. **This can show a location permission or "turn on location" dialog during a call.** Removing it needs no change in the protected methods (`initializeLocation` is not on the protected list), but it touches tracking start-up, so I will ask before removing it.
- `test/calling_controller_backup.dart`, `test/backup_groupController.dart` exist.

### BUG-CALL-19 (C19) — guide out of date · Confirmed
- On top of the listed items: the guide header was bumped to v1.3.0 on 2026-11-18 by another session and still says "Status: In Production / Stable". §0.1 claims prod Coturn TLS 443, which the app does not use. `missCall` is documented as 45 s.

### BUG-CALL-20 (C20) — signaling auth · Client confirmed, backend Open
- `Socket_SignallingService.dart:31-39`: `query: {callerId}`, no token / `auth`. **Backend check pending** (Part 0 step 6).

### BUG-CALL-21 (new) — force-delete kills a minimized call into a zombie · Confirmed
- `DialogBox.dart:1554,1632`, `UserProfileScreen.dart:418-420`, `Tracking_screen.dart:3418,3443` call `Get.delete<CallingController>(force: true)` before a new call, without checking for a live call. If a call is minimized, `onClose` returns at once (`calling_controller.dart:3218-3221`): the peer, mic, socket handlers and overlay all stay alive, and the new controller replaces the old one in the registry.

### BUG-CALL-22 (new) — overlay End pops the wrong screen · Confirmed
- Minimize already popped the call route (`calling_controller.dart:617-622`). Overlay End → `endCall` → `_exitCallScreen` (`:580-611`) pops again: the user's **current** page (chat, map…). `isMinimized` is never reset on this path.

### BUG-CALL-23 (new) — iOS Recents call-back ignored · Confirmed
- `CallKitService.onRecentsCallback` is never set (`callkit_service.dart:41, 452-455`). Tapping an FG Tracker call in the iPhone Recents list does nothing.

### BUG-CALL-24 (new) — `isCallActive` unsafe · Confirmed
- `Data/Repositories/call_repo.dart:50-78`: no timeout on `http.get`; returns `false` ("not active") on any error or non-200, so a naive C10 wiring would **dismiss real ringing calls** when offline. URL is `'${aBaseUrl}/getCallDetail'` with `aBaseUrl` ending in `api/` (`Core/constant/const_res.dart:31`), giving `api//getCallDetail`.

### BUG-CALL-25 (new) — iOS PushKit edge · Confirmed
- `ios/Runner/AppDelegate.swift:463-466`: if the CallKit plugin instance is nil, it only logs. No `reportNewIncomingCall`, no `completion()`. iOS 13+ kills the app and can stop VoIP delivery.
- `ios/Runner/Runner.entitlements`: `aps-environment=development` used by Debug, Release and Profile. Check how App Store / TestFlight builds are signed and which APNs environment the backend uses.

### BUG-CALL-26 (new) — system End with Dart dead · Confirmed
- iOS `onEnd` (`AppDelegate.swift:525-543`) and Android END (`MainApplication.kt`) clean up audio only. No server call, so the other side waits until its own timeout. Decline has a native REST path; End does not.

### BUG-CALL-27 (new) — Android manifest · Confirmed
- `AndroidManifest.xml:174-188`: exported `com.hiennv.flutter_callkit_incoming.CallkitIncomingReceiver` with no permission. The class does not exist in plugin 3.1.6, so an explicit broadcast from any app crashes ours (ClassNotFound).
- `:135-138`: ConnectyCube `CallService` declared but the plugin is commented out (`pubspec.yaml:81`).
- `:50`: `android:foregroundServiceType` on `<application>` is ignored by Android.

### BUG-CALL-28 (new) — native reject transport · Confirmed
- `CallDeclineReceiver.kt:73-79, 151` and `AppDelegate.swift:17, 1244-1301`: `GET http://…/api/callRejected` over **cleartext HTTP** with a Bearer token; the response body and URL are logged (`CallDeclineReceiver.kt:79, 99`). `usesCleartextTraffic=true`, iOS `NSAllowsArbitraryLoads=true`.

### BUG-CALL-29 (new) — iOS forced audio activation · Code confirmed, effect Open
- `AppDelegate.swift:489-495`: if CallKit has not activated the audio session 0.75 s after accept, WebRTC audio is force-enabled. This can cause silent or one-way audio on some devices. Needs a device run.

### BUG-CALL-30 (new) — direct call-screen entry points skip permissions · Confirmed
- `UserProfileScreen.dart:422-433` (no chat controller branch) and `Tracking_screen.dart:3421, 3446` call `Get.toNamed(Routes.callScreen)` directly, skipping `CallService` and its permission check. Phase 2 routes them through the policy.
