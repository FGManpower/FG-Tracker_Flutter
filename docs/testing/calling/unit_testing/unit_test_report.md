# Calling (1:1) — Unit Test Report

Feature guide: [`docs/02_CALLING_MODULE_FRONTEND.md`](../../../02_CALLING_MODULE_FRONTEND.md). Bugs: [`../bug_tracker.md`](../bug_tracker.md).

## Phase 1 (reliability) — Run 1, 2026-11-18

| | |
|---|---|
| Branch / HEAD | `46Solution` @ `3e16f524` + uncommitted Phase 1 changes (nothing committed) |
| Test file | [`test/call_qa/call_reliability_v1_test.dart`](../../../../test/call_qa/call_reliability_v1_test.dart) (new) |
| Fakes | [`test/call_qa/fakes/fake_call_platform.dart`](../../../../test/call_qa/fakes/fake_call_platform.dart) (new); socket server reused from `test/chat_qa/fakes/fake_socket_io_server.dart` (unchanged) |
| How | Real `socket_io_client` (`SignallingService`) against the local fake Socket.IO server. `CallPlatform.instance` replaced by `FakeCallPlatform` (no WebRTC, CallKit, wakelock, foreground service). The C22 case uses a real `GetMaterialApp` navigator. |
| Run | `flutter test test/call_qa/call_reliability_v1_test.dart` |
| Result | **19 / 19 pass** |
| Existing backup files | `test/calling_controller_backup.dart`, `test/backup_groupController.dart` left untouched, as asked |

### Cases

| ID | Bug | Test | Result |
|---|---|---|---|
| CT-01 | BUG-CALL-01 | End, missed (caller timeout), rejected by peer, `missedCall` from server: controller released every time; next call is a new instance with its own args; End reaches the peer on the 2nd call | Pass |
| CT-16 | — (regression guard) | Second End / missed after hang-up sends nothing more; service stopped once | Pass |
| CT-21 | BUG-CALL-21 | Live minimized call is not deleted by a new call; expand reuses it; after it ends a new call may start | Pass |
| CT-02 | BUG-CALL-02 | Socket re-created (login) after the controller was built: controller uses the new socket, `endCall` arrives at the server | Pass |
| CT-02b | BUG-CALL-02 | `ensureConnected` returns the live socket | Pass |
| CT-03 | BUG-CALL-03 | Incoming screen open/close + call start/end, 5 times each: global `callEnded`, `callRejected`, `newCall` handlers still fire exactly once | Pass |
| CT-03b | BUG-CALL-03 | `CallSocketHandlers.off` removes only its own handler | Pass |
| CT-04 | BUG-CALL-04 | In-app reject: `rejectCall.remoteUserId` = caller id | Pass |
| CT-11 | BUG-CALL-09 | CallKit End while connecting: call ended, `endCall` sent to the caller | Pass |
| CT-14 | BUG-CALL-14 | One incoming argument shape (`remoteUserId` = caller, both avatar keys) | Pass |
| CT-15a | BUG-CALL-15 | Foreground service started in `onInit` (voice / video), stopped once | Pass |
| CT-15b | BUG-CALL-15 | Service types: microphone, + camera only when granted, never phoneCall | Pass |
| CT-10 | BUG-CALL-08 | Caller timer = CallKit `duration` (45 s) | Pass |
| CT-12 | BUG-CALL-10 | `getCallStatus` returns the server status | Pass |
| CT-12b | BUG-CALL-24 | Error / non-200 / timeout = `null` (unknown), never "ended"; URL has no `//` | Pass |
| CT-12c | BUG-CALL-10/24 | `restoreActiveCalls`: offline keeps the ringing call, `missed` dismisses it | Pass |
| CT-18a | BUG-CALL-18 | `formattedDuration` has no side effect | Pass |
| CT-18b | BUG-CALL-18 | Tracking keep-alive runs once, through the no-prompt path | Pass |
| CT-22 | BUG-CALL-22 | End a minimized call while on another page: that page stays | Pass |

### Proof against the old code (mutation checks)

The new tests use new seams (`CallPlatform`, `CallSocketHandlers`, `call_kit_handlers.dart`), so they cannot compile against the old files. As in the chat report, each old behaviour was put back **one at a time** (script: `perl` replace, run, restore) and the guarding test was run:

| Mutation (old behaviour back) | Test | Failing assertion |
|---|---|---|
| M1 end path does not release the controller | CT-01 | `Get.isRegistered` Expected `false`, Actual `true` |
| M2 socket captured at construction | CT-02 | `identical(c.socket, current)` Expected `true`, Actual `false` |
| M3 `socket.off(event)` without handler | CT-03 | global handlers fired: Expected `true`, Actual `false` |
| M4 reject sends own id | CT-04 | Expected `'202'`, Actual `'101'` |
| M5 system End ignored while connecting | CT-11 | `Get.isRegistered` Expected `false`, Actual `true` |
| M6 `getCallStatus` stub | CT-12 | Expected `'ended'`, Actual `null` |
| M7 caller timer 40 s | CT-10 | Expected `45`, Actual `40` |
| M8 service started only on ICE connected | CT-15a | Expected `[false]`, Actual `[]` |
| M9 ringtone stop inside the getter | CT-18a | Expected empty, Actual `['stopRingtone']` |
| M10 force-delete before a new call | CT-21 | Expected `false`, Actual `true` |
| M11 exit pops while minimized | CT-22 | "chat page" found 0 widgets |
| M12 unknown status read as ended | CT-12b | Expected `null`, Actual `'ended'` |

CT-16 is a regression guard, not a bug proof: removing the new `_callFinished` guard still passes, because `onClose` keeps `_isCleaningUp` set after the release. Two layers protect the same rule.

### Not covered automatically (Phase 1)

| Item | Why | Covered by |
|---|---|---|
| Real WebRTC (offer / answer / ICE), `ensureConnected` wait inside `_setupPeer` | `mediaEnabled = false` in tests; a `CallMediaEngine` seam is planned for Phase 3 (ICE restart tests) | Code review + phone M-01, M-12 |
| Android foreground service on a device (types accepted, Hang up button, Android 14 rules) | Platform service | Phone M-08 |
| System End ignored during Android audio handover | `_audioHandover` is set only on Android with a live Telecom call | Code review + phone (accept from lock screen, Android) |
| Overlay widget itself | The test emulates minimize without the bubble widget | Phone |
| Location keep-alive real check (`Geolocator`) | Plugin | Phone: start a call with GPS off, no dialog must appear |

### Regression run
See the end of this file (filled after the full `flutter test` run).

**Full suite (`flutter test`, 2026-11-18, working tree with Phase 1):** 1076 pass, 45 skipped, **31 fail**. All 31 are in three files that do not touch calling: `permission_setup_flow_test.dart` (27), `language_selection_test.dart` (3), `chat_qa/chat_list_controller_qa_test.dart` (1).

**They fail on the clean HEAD too.** The same three files were run in a separate worktree of `3e16f524` without the Phase 1 changes: **+93 ~6 −31** there, **+93 ~6 −31** with Phase 1. Same count, same tests. So Phase 1 adds no failures. These failures are outside the calling module and were not changed.

`flutter analyze`: 0 errors project-wide; no new warnings in the files Phase 1 touched (remaining warnings in those files were there before, e.g. `isInitialized` in the screen-share code, unused `_remoteScreenStream`).

---

## Phase 2 (permissions on the calling screen) — Run 1, 2026-11-18

| | |
|---|---|
| Test file | [`test/call_qa/call_permissions_v1_test.dart`](../../../../test/call_qa/call_permissions_v1_test.dart) (new) |
| Fakes | [`test/call_qa/fakes/fake_call_permissions.dart`](../../../../test/call_qa/fakes/fake_call_permissions.dart) (new): scriptable device (status, dialog answer, what changes in Settings) and sheet answers |
| Result | **23 / 23 pass**; Phase 1 file still **19 / 19** (it now grants permissions through the fake) |

| ID | P-case | Test | Result |
|---|---|---|---|
| Policy | all | Decision table: outgoing, incoming, camera mid-call | Pass |
| PM-01 | P-01 | Explainer, then the system dialog, start only after grant | Pass |
| PM-01b | P-01 | "Not now" on the explainer: no system dialog, no call | Pass |
| PM-01c | P-01 | `CallService.prepareOutgoingCall` returns no call arguments before the mic is granted; video + camera blocked + "voice instead" gives a voice call | Pass |
| PM-02 | P-02 | Denied: sheet with Allow again; cancel = no call | Pass |
| PM-03 / PM-12 | P-03, P-12 | Blocked: Settings, re-check on return, call continues with one tap | Pass |
| PM-04 / 04b | P-04 | Video, camera blocked or refused: "Start voice call instead" | Pass |
| PM-05 | P-05 | Flow: one dialog at accept, no sheet, stop. Call screen: call ends through the normal end path, caller gets `endCall.reason = permission_denied` | Pass |
| PM-06 | P-06 | Accept video with camera blocked: voice for us, video call kept, chip shown, call live | Pass |
| PM-07 | P-07 | Camera mid-call blocked: sheet; Settings + return turns the chip off; call stays live | Pass |
| PM-08 | P-08 | Bluetooth asked only with a device on Android; denied = hidden; iOS never asks | Pass |
| PM-09 | P-09 | Ring readiness (notifications + Android 14 full-screen); banner widget shows and disappears after Allow | Pass |
| PM-10 | P-10 | Mic primer once, only if never asked | Pass |
| PM-11 | P-11 | Relaunch with an accepted CallKit call the server says ended: dismissed, not reopened | Pass |
| PM-12 | P-12 | `waitForResume` completes on the real lifecycle `resumed` | Pass |
| Sheet | — | Camera-blocked sheet: 3 localized buttons, returns the choice | Pass |

### Proof against the old code (mutation checks)

| Mutation (old behaviour back) | Test | Failing assertion |
|---|---|---|
| M14 no explainer before the mic dialog | PM-01 | Expected `[micExplain]`, Actual `[]` |
| M15 camera denied = no call (no voice option) | PM-04 | Expected `true`, Actual `false` |
| M16 no permission check at accept (old: silent drop in `getUserMedia`) | PM-05 | call not ended: Expected `true`, Actual `false` |
| M17 no reason sent to the caller | PM-05 | Expected `'permission_denied'`, Actual `null` |
| M18 camera denied at accept ends the call | PM-06 | Expected `true`, Actual `false` |
| M19 no Bluetooth permission request | PM-08 | Expected `false`, Actual `true` |
| M20 accepted call reopened after a kill | PM-11 | Expected `null`, Actual pending accept for call 77 |
| M21 Settings opened, no re-check (old `openAppSettings(); return`) | PM-03 | Expected `1` resume, Actual `0` |
| M22 call arguments returned without the mic | PM-01c | Expected `null`, Actual arguments |

### No new prompts elsewhere
Only call-module files use the new flow: `call_service.dart`, `calling_controller.dart`, `call_screen.dart` (Calls tab banner), the sheet, and `main.dart` (registers the sheet). Walkie-talkie, attendance selfie, screen share and the Permission Setup gate are not touched (checked with `grep`).

### Not covered automatically (Phase 2)
| Item | Covered by |
|---|---|
| Real system dialogs, Settings round trip, iOS lock-screen answer (P-10) | Phone M-11 |
| Android killing the app when a permission is revoked (P-11 trigger) | Phone M-11 |
| `getUserMedia` with `video: false` on a video call still receives the remote video | Phone M-02 / M-11 |

### Regression run (Phase 2)
`flutter test` (whole suite): **1099 pass**, 45 skipped, 31 fail. That is +23 passes (the new PM tests). The 31 failures are the same three files with the same counts as Phase 1 and as the clean HEAD (`permission_setup_flow_test.dart` 27, `language_selection_test.dart` 3, `chat_qa/chat_list_controller_qa_test.dart` 1). Phase 2 adds no failures. `l10n_completeness_test.dart` passes with the 12 new keys. `flutter analyze`: 0 errors.

---

## Phase 3 (WhatsApp / IMO parity) — Run 1, 2026-11-18

| | |
|---|---|
| Test file | [`test/call_qa/call_parity_v1_test.dart`](../../../../test/call_qa/call_parity_v1_test.dart) (new) |
| Result | **27 / 27 pass**. All call tests together: **69 / 69** (Phase 1: 19, Phase 2: 23, Phase 3: 27) |
| E2E (signaling) | `integration_test/call_signaling_e2e_test.dart` + `scripts/call_qa/call_bot.js` written; `flutter analyze` clean. **Not run**: no staging server, no test accounts, and Node.js is not installed on this PC |

| ID | Test | Result |
|---|---|---|
| CT-05 | Second call while in a call: `CallingStatus busy` (never "Ringing"), waiting banner, current call untouched | Pass |
| CT-06a | Decline the waiting call: `rejectCall {reason: busy}` to its caller | Pass |
| CT-06b | End & accept: current call ends, a new controller opens with the waiting caller's args | Pass |
| CT-07 | Link monitor: Reconnecting, ICE restart after 2 s, retry, recovered, nothing after | Pass |
| CT-08 | `failed`: restart at once; give up after 25 s, nothing after | Pass |
| CT-08b | Connection lost: `endCall.reason = connection_lost`, end screen info | Pass |
| — | Callee waits longer before its own ICE restart; restart on signaling reconnect only while down | Pass |
| CT-09 | Network drop: client reconnects, `rejoinCall` sent, a later `callEnded` ends the call exactly once | Pass |
| CT-10b / UI-01 | Outcomes: timeout = No answer, `callRejected reason busy` = On another call, plain = Declined, user cancel = no end screen | Pass |
| — | Caller: `callStatus busy` shows "On another call" and keeps waiting | Pass |
| CT-13 | VoIP token uploaded once per new token; a failed upload is retried | Pass |
| CT-14 | Media state both ways (relay + dedicated event); CallKit mute applies without echo; in-app mute syncs CallKit; mapping of CallKit system actions; UUID format | Pass |
| — | CallKit hold mutes and restores | Pass |
| — | Quality: stats reader (loss from deltas, RTT, jitter), evaluator hysteresis, camera tip once, badge on the call screen | Pass |
| — | TURN: endpoint credentials used and cached; 404 = static fallback incl. `turns:…:443`; bad body rejected | Pass |
| — | iOS outgoing call reported to CallKit | Pass |
| — | Push of a second call while in a call goes to the banner, no system incoming UI | Pass |
| — | Waiting-call and push parsers; reject outcome; media-state payload; auto-PiP policy | Pass |
| UI-01 | End screen widget: name, reason, Call again, Cancel | Pass |
| BUG-CALL-37/38 | Late `callEnded` / `callRejected` of an older call ignored; live session id kept | Pass |

### Proof against the old code (mutation checks)

| Mutation (old behaviour back) | Test | Failing assertion |
|---|---|---|
| M23 no ICE restart | CT-07 | Expected `iceRestart`, Actual `showReconnecting` |
| M24 fake "Ringing" to the second caller | CT-05 | Expected `'busy'`, Actual `'Ringing'` |
| M25 decline without reason | CT-06a | Expected `'busy'`, Actual `null` |
| M26 connection lost without reason | CT-08b | Expected `'connection_lost'`, Actual `null` |
| M27 no rejoin on reconnect | CT-09 | Expected `true`, Actual `false` |
| M28 timeout without outcome | UI-01 | Expected `noAnswer`, Actual `null` |
| M29 remote media state not applied | CT-14 | Expected `true`, Actual `false` |
| M31 VoIP token uploaded every time | CT-13 | Expected `1` upload, Actual `2` |
| M32 no TLS 443 TURN | TURN fallback | Expected `true`, Actual `false` |
| M33 push of a second call shows the system UI | push test | Expected `'902'`, Actual `null` |
| M34 end events not matched to the call | BUG-CALL-37 | call ended: Expected `true`, Actual `false` |
| M35 live session id overwritten | BUG-CALL-37 | the live call took the foreign `callEnded` as its own and ended |
| M36 End & accept without opening the new call | CT-06b | no new controller |

### Not covered automatically (Phase 3)
| Item | Covered by |
|---|---|
| Real ICE restart on Wi-Fi ↔ 4G | Phone M-06 |
| TURN over TLS 443 | Phone M-07 (needs backend B-09) |
| Android PiP window, notification Hang up | Phone M-08 |
| iOS CallKit outgoing audio, lock-screen mute, cellular hold, headset button | iPhone M-09, M-10 (**the iOS code was not compiled here**) |
| Tones playing | Phone M-03, M-04, M-05 |
| Signaling E2E against a real server | `integration_test/call_signaling_e2e_test.dart` + bot, needs staging |

### Regression run (Phase 3)
`flutter test` (whole suite): **1126 pass**, 45 skipped, 31 fail. That is +27 passes (the new Phase 3 tests). The 31 failures are the same pre-existing set as on the clean HEAD (`permission_setup_flow_test.dart` 27, `language_selection_test.dart` 3, `chat_qa/chat_list_controller_qa_test.dart` 1). `flutter analyze`: 0 errors project-wide.
