# Calling (1:1) — Manual Test Checklist

| | |
|---|---|
| Module | 1:1 voice / video calling: outgoing, incoming (in-app, CallKit, full-screen), decline, missed, busy, network change, background / lock, audio route, permissions |
| Last updated | 2026-11-18 (sheet created, Phase 1 + Phase 2 code, uncommitted) |
| Branch | `46Solution` @ `3e16f524` + uncommitted Phase 1 / Phase 2 changes |
| Feature guide (reference) | [`docs/02_CALLING_MODULE_FRONTEND.md`](../../../02_CALLING_MODULE_FRONTEND.md) (§5 flows and gaps, §6 permissions) |
| Bugs | [../bug_tracker.md](../bug_tracker.md) · Unit tests: [../unit_testing/unit_test_report.md](../unit_testing/unit_test_report.md) · Security: [../pentesting/pentest_report.md](../pentesting/pentest_report.md) |

> **Update 2026-11-18 (Phase 3 code):** the "Known" column below was written before Phase 3. These are now expected to **pass** on the new build:
> - M-04: missed-call notification with Call back.
> - M-05: busy / waiting banner. The caller-side "On another call" needs backend B-04.
> - M-06: "Reconnecting…" and ICE restart.
> - M-08: Android PiP and "Video paused". iOS has no PiP.
> - M-10: iOS hold.
>
> M-07 (TURN 443) still needs backend B-09. See guide §7 and §8.

## Status: NOT RUN YET

**No case on this sheet has been run.** This session had no human tester, no test phones (Android or iPhone), no test accounts and no Mac. Every result cell says **Not run**. Nothing in a result column is a prediction.

The "Known" column says what to expect on the current build from the bug tracker. A case marked "Expect Fail" is still run and recorded; it tells the tester a failure there is already known.

---

## How to use this sheet

**Phones and accounts.**
- Two Android phones (A1, A2) and two iPhones (I1, I2). Accounts **A** (caller), **B** (callee), **C** (third user, for busy / waiting).
- Android: at least one Android 14+. If you have them, also a Xiaomi, an Oppo and a Vivo (aggressive battery managers).
- iPhone: a real device. The Simulator cannot receive VoIP pushes or use CallKit fully.

**Device-pair columns** (caller → callee):

| Column | Meaning |
|---|---|
| **A↔A** | Android → Android, then swap phones and run again (both directions) |
| **i↔i** | iPhone → iPhone, then swap (both directions) |
| **A→i** | Android calls iPhone |
| **i→A** | iPhone calls Android |

Write one status per cell. If the two directions of A↔A or i↔i differ, write both, e.g. `Pass / Fail`.

**Status values:** `Not run` · `Pass` · `Fail` · `Blocked` (cannot run, write why) · `N/A` (does not apply to this pair).

**Build.** Debug or profile build, full rebuild (stop + `flutter run`), never a hot restart. Keep logcat / Xcode console open and filter for `[CALL]`, `[CK]`, `[CAM]`, `[SDP]`, `[SHARE]`.

**Server.** The app talks to the production host by default (`ConstRes.isProduction`, `IS_PROD` defaults to `true`). Calls between test accounts on production need the team's OK. A staging build uses `--dart-define=IS_PROD=false`. Write which one you used in the run log.

**For every case** write in Notes: build number, phone models, OS versions, network (Wi-Fi / 4G / throttled). Screen-record both phones for any Fail. Use a stopwatch for timed cases.

---

## 1. Core cases M-01 … M-14

| ID | Steps | Expected | Known | A↔A | i↔i | A→i | i→A | Notes |
|---|---|---|---|---|---|---|---|---|
| M-01 | A starts a **voice** call to B. Stopwatch from tap "Call" to ring on B. B answers. Talk 1 min. Both hang up from A. | B rings within **3 s**. Call connects. Audio both ways, no echo. Timer starts at connect and shows the same time on both phones (±1 s). Both screens close on hang-up. | Fixed in code: BUG-CALL-01 (fresh controller per call). Phone check pending. | Not run | Not run | Not run | Not run | |
| M-02 | A starts a **video** call, B answers. Flip camera on both. Camera off, then on, on both. New voice call: A switches to video (sends the request), B accepts. | Video both ways. Flip works. Camera off shows the other side as camera off, on brings it back. Voice → video only after B accepts the request; audio never drops. | — | Not run | Not run | Not run | Not run | |
| M-03 | A calls B. B taps **Decline** (test both: in-app incoming screen, and system / CallKit screen). | A sees **Declined** at once (≤ 2 s) and the call screen closes. B's ringing stops. | Fixed in code: BUG-CALL-04 (in-app decline went to the wrong user). | Not run | Not run | Not run | Not run | |
| M-04 | A calls B. Nobody answers. Stopwatch. | Both sides stop at the **same 45 s** timeout. B gets a missed-call notification with **Call back**; tapping it calls A. | Client timer fixed (BUG-CALL-08, 45 s both sides). **Expect Fail** on Call back: `isShowCallback: false` (BUG-CALL-17, Phase 3). | Not run | Not run | Not run | Not run | |
| M-05 | B is on a call with C. A calls B. | A sees **"On another call"**. B sees a waiting-call banner with **End & accept** / **Decline**. End & accept ends B↔C and connects A↔B. Decline: A sees Declined, B↔C continues. | **Expect Fail**: BUG-CALL-05 open (fake "Ringing", needs backend busy event, Phase 3). | Not run | Not run | Not run | Not run | |
| M-06 | During a call, turn Wi-Fi off on one phone so it moves to 4G. Then back. | "Reconnecting…" shows, then the call continues with audio (and video) both ways. Call is not dropped. | **Expect Fail**: no ICE restart (BUG-CALL-06, Phase 3). Today the call drops after 12–30 s. | Not run | Not run | Not run | Not run | |
| M-07 | Put one phone on a network that blocks UDP/TCP 3478 (firewall rule or a corporate Wi-Fi). Call. | Call connects through TURN on **443 (TLS)**. | **Blocked** until the backend enables `turns:` on 443 and the app adds it (BUG-CALL-07). Run once the backend confirms. | Not run | Not run | Not run | Not run | |
| M-08 | During a call: lock the phone, wait 1 min, unlock. Then press Home (leave the app) for 1 min. Do this on a voice call and a video call. | Audio continues the whole time. **Android:** an ongoing-call notification with **Hang up**; Hang up ends the call on both sides. Video pauses, or goes to picture-in-picture (Android). The other side shows **"Video paused"**. | Ongoing notification + Hang up fixed in code (BUG-CALL-15). **Expect Fail** on PiP (BUG-CALL-16) and "Video paused" (BUG-CALL-17), Phase 3. | Not run | Not run | Not run | Not run | Android 14: check the call keeps the mic while locked |
| M-09 | Connect a Bluetooth headset to B. Call. Switch route: headset → speaker → earpiece → headset. Press the headset button. | Route changes each time and audio follows. Headset button ends the call (both sides). | Android 12+: Bluetooth permission asked at the route sheet (P-08). | Not run | Not run | Not run | Not run | Headset model: |
| M-10 | During an app call, B receives a normal **cellular** call. Try: hold & accept, end & accept, decline. | Like WhatsApp. iOS: system offers hold / end. After the cellular call ends, app-call audio comes back both ways. | **Expect Fail** on iOS hold: CallKit hold / mute not mapped (BUG-CALL-12, Phase 3). | Not run | Not run | Not run | Not run | Needs a SIM in the callee phone |
| M-11 | Permissions P-01 … P-12 | See §2 (one row per P case) | Fixed in code: BUG-CALL-13, -30, -36 (Phase 2) | see §2 | see §2 | see §2 | see §2 | |
| M-12 | Make **5 calls in a row** without restarting the app: voice, video, declined, missed, voice. Mix caller / callee. | Every call rings, connects (or ends) normally. No silent call, no stuck screen, End always reaches the other side. | Fixed in code: BUG-CALL-01, -02, -03 (CT-01, CT-03). | Not run | Not run | Not run | Not run | |
| M-13 | On B's phone: log out, log in as account **C**. A calls C, then A calls B. | C's phone rings for C. A call to B does **not** ring on this phone. | Fixed in code: BUG-CALL-02 (socket after login). iOS: VoIP token upload (BUG-CALL-11) open, killed-app ringing may fail. | Not run | Not run | Not run | Not run | |
| M-14 | After one 1:1 call: run a group call, a walkie-talkie session (incl. tapping **Open** in its notification), a screen share during a call, and the attendance selfie. | All unchanged. Walkie notification **Open** opens the walkie screen **once** (not twice). Screen share works and the call keeps its ongoing notification. Selfie camera works. | Side effect to check: walkie notification buttons now reach the app (bug tracker, "Side effect"). BUG-CALL-32 fixed. | Not run | Not run | Not run | Not run | |

### 1a. Phase 1 checks

| ID | Steps | Expected | Known | A↔A | i↔i | A→i | i→A | Notes |
|---|---|---|---|---|---|---|---|---|
| P1-01 | B's phone locked. A calls, B accepts from the lock screen, then taps **End** in the system call UI **while it still says Connecting**. | Call ends on both sides. A sees the call end. | Fixed in code: BUG-CALL-09 (CT-11). | Not run | Not run | Not run | Not run | |
| P1-02 | Turn **GPS off** on both phones (location permission granted). Make a call and talk 1 min. Repeat with location permission not granted. | No location permission dialog and no "turn on location" dialog appears during the call. | Fixed in code: BUG-CALL-18 (`CallPlatform.keepTrackingAlive`). | Not run | Not run | Not run | Not run | |
| P1-03 | On a call, minimize it (floating bubble). Go to chat / profile / tracking map and try to start a **new** call to someone else. | Toast **"You're already on a call"**, and the running call comes back full screen. The running call is not killed. | Fixed in code: BUG-CALL-21 (CT-21). | Not run | Not run | Not run | Not run | Try from chat, Calls tab, profile, tracking map |
| P1-04 | Minimize a call, open a chat (or the map). End the call from the **floating bubble**. | The call ends on both sides. You stay on the chat / map page (it is not closed). | Fixed in code: BUG-CALL-22 (CT-22). | Not run | Not run | Not run | Not run | |

---

## 2. M-11 — Permissions P-01 … P-12

Cases from guide §6. Reset permissions before each case (Android: Settings ▸ Apps ▸ FG Tracker ▸ Permissions; iOS: delete and reinstall to get "never asked"). "Blocked" = Android "Don't allow" twice / "Don't ask again", or iOS after one "Don't Allow".

| ID | Steps | Expected | A↔A | i↔i | A→i | i→A | Notes |
|---|---|---|---|---|---|---|---|
| P-01 | Caller, mic never asked. Start a voice call. Try once with **Allow**, once with **Not now**. | Sheet "Allow microphone" → system dialog → call starts only after grant. "Not now": no dialog, no call, nothing reaches B. | Not run | Not run | Not run | Not run | |
| P-02 | Caller, mic denied once (not blocked). Start a call. | Same sheet again with Allow. Cancel = no call. | Not run | Not run | Not run | Not run | |
| P-03 | Caller, mic blocked. Start a call, tap **Open Settings**, turn the mic on, come back. | Settings opens. On return the mic is re-checked and the call starts by itself. | Not run | Not run | Not run | Not run | |
| P-04 | Caller, camera refused or blocked. Start a **video** call. | Sheet: Start voice call instead / Open Settings / Cancel. "Voice instead" starts a voice call. | Not run | Not run | Not run | Not run | |
| P-05 | Callee, mic not granted. A calls, B accepts. Refuse the mic (and once: blocked + Cancel). | System dialog on the call screen. Refused: call ends normally on both sides, A's side ends (server gets `reason: "permission_denied"`), B sees toast "Microphone access is needed to answer calls". No stuck screen. | Not run | Not run | Not run | Not run | |
| P-06 | Callee, camera refused. A makes a **video** call, B accepts. | B joins as voice (own camera off). B still sees A's video. Chip **"Camera off · Allow"** shown. | Not run | Not run | Not run | Not run | |
| P-07 | During a call, camera not granted. Tap camera on (or the chip). | Dialog, or a sheet with Open Settings. The call always continues. | Not run | Not run | Not run | Not run | |
| P-08 | Android 12+, Bluetooth device paired. Open the audio route sheet. Refuse once, allow once. | `BLUETOOTH_CONNECT` asked when the sheet opens. Refused = Bluetooth hidden in the list. Allowed = Bluetooth listed. iOS never asks. | Not run | N/A | Not run | Not run | Run on the Android phone of the pair |
| P-09 | Turn notifications off (and on Android 14, full-screen intent off). Open the Calls tab. | Banner "Incoming calls may not ring · Allow". Calling out still works (banner never blocks). | Not run | Not run | Not run | Not run | |
| P-10 | iPhone callee, fresh install, mic never asked. Open Calls tab once. Lock the phone. A calls, B answers from the lock screen. | One-time sheet "Be ready to answer calls" on the first Calls visit. At accept the mic dialog appears after unlock. No crash, no ghost call. | N/A | Not run | Not run | N/A | iPhone callee only |
| P-11 | Android callee. During a call, open Settings and revoke the mic (Android kills the app). Reopen the app. | The call is checked with the server. Ended → not reopened, no ghost call. Offline → old behaviour (write what happened). | Not run | N/A | Not run | Not run | Run on the Android phone |
| P-12 | Any case that sends the user to Settings (P-03, P-07). Come back with the app switcher, and once with the back gesture. | The pending step continues by itself after return. | Not run | Not run | Not run | Not run | |

---

## 3. Callee state matrix

Run **M-01** (ring + answer), **M-03** (decline) and **M-04** (missed) with the callee in each state. Write the three results in one cell, e.g. `P / P / F`.

| ID | Callee state | A↔A | i↔i | A→i | i→A | Notes |
|---|---|---|---|---|---|---|
| ST-01 | App open (foreground) | Not run | Not run | Not run | Not run | |
| ST-02 | App in background (Home pressed, 1 min) | Not run | Not run | Not run | Not run | |
| ST-03 | Phone locked (2 min) | Not run | Not run | Not run | Not run | |
| ST-04 | App killed (swiped away) | Not run | Not run | Not run | Not run | iOS: depends on VoIP push (BUG-CALL-11, -25) |
| ST-05 | Battery saver on | Not run | Not run | Not run | Not run | |
| ST-06 | Android: Xiaomi / Oppo / Vivo, app killed, default battery settings | Not run | N/A | N/A (callee iPhone) | Not run | Write the brand and OS skin. If available only |

M-04 in ST-04: both sides still stop at 45 s and the missed-call notification appears on the callee.

---

## 4. Run log

One row per session. Add rows; do not overwrite old ones.

| Date | Tester | Device / OS (caller → callee) | App build | Server (prod / staging) | Network | Cases run | Result (Pass / Fail / Blocked counts) | Notes |
|---|---|---|---|---|---|---|---|---|
| 2026-11-18 | — | — | — | — | — | none | Not run | Sheet created. No tester, no phones in this session. |
| | | | | | | | | |

---

## 5. Result summary

| Area | Cases | Pass | Fail | Blocked | Not run |
|---|---:|---:|---:|---:|---:|
| Core M-01 … M-14 (M-11 counted in §2) | 13 | 0 | 0 | 0 | 13 |
| Phase 1 checks P1-01 … P1-04 | 4 | 0 | 0 | 0 | 4 |
| Permissions P-01 … P-12 | 12 | 0 | 0 | 0 | 12 |
| Callee states ST-01 … ST-06 | 6 | 0 | 0 | 0 | 6 |
| **Total** | **35** | **0** | **0** | **0** | **35** |

Counted per case (any pair). Update after each run.
