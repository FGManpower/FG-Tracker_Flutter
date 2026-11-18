# 1:1 call signaling E2E (bot + app)

Signaling-level end-to-end tests for 1:1 calls on the `/callSignaling`
namespace. **No media flows**: every SDP / ICE value is fake and marked
`FG-CALL-QA FAKE SDP - signaling test only, NO media`.

> **Status: written, NOT run yet.** It needs a staging server and two test
> accounts, and nobody has run it against one. Expect to tune timeouts
> on the first run.

| Part | File | Role |
|---|---|---|
| Bot | `scripts/call_qa/call_bot.js` | Node, plays the OTHER user (user B) |
| App side | `integration_test/call_signaling_e2e_test.dart` | Runs the app's own `SignallingService` + `CallingController` on a device as user A |

## What is real and what is faked

- Real: the staging `/callSignaling` server, the app's `SignallingService`,
  `CallingController` socket handlers (`callCreated`, `callStatus`,
  `callRejected`, `callEnded`, `missedCall`, the `connect` → `rejoinCall`
  re-sync), its `endCall` / `missCall` emits and the controller release.
- Faked: media. `CallPlatform.instance` is a no-media fake
  (`mediaEnabled = false`) and `CallPermissionBackend.instance` grants
  everything (`test/call_qa/fakes/`). With media off the controller skips
  `_setupPeer`, so the harness sends the emits that come from it
  (`makeCall`, `answerCall`, `acceptCallFromCallKit`, `IceCandidate`, and
  the missed-call timer start) with the same payload shapes as
  `calling_controller.dart`.
- Not covered: audio / video, TURN, ICE restart on a real link, push /
  CallKit when the app is killed. Those stay in the manual matrix
  (docs/testing/calling).

## Requirements

- A **staging** server (never production) with `/callSignaling`.
- **Two test accounts**: A = the app on the device, B = the bot. No real
  user data.
- Node.js 18+ for the bot, a device or emulator for the app.
- Tokens: the app socket sends only `query.callerId` (like the app today).
  The bot sends `BOT_TOKEN` as `auth.token` if you set it. Put secrets only
  in environment variables, never in files or commits.

## Install

```bash
cd scripts/call_qa
npm install
npm run check     # node --check call_bot.js
```

## Run both together (two terminals)

Start the bot first, then the app test. `MODE=suite` runs the same
sequence as the Dart test: 9 cases x 3 runs (about 15 minutes, the timeout
case alone rings 45 s per run).

**Terminal 1 (bot = user B):**

```bash
cd scripts/call_qa
SIGNALING_URL=https://<staging-host> \
BOT_USER_ID=<user B id> \
APP_USER_ID=<user A id> \
MODE=suite \
node call_bot.js
```

PowerShell:

```powershell
cd scripts/call_qa
$env:SIGNALING_URL="https://<staging-host>"; $env:BOT_USER_ID="<user B id>"
$env:APP_USER_ID="<user A id>"; $env:MODE="suite"
node call_bot.js
```

**Terminal 2 (app = user A, on a device / emulator):**

```bash
flutter test integration_test/call_signaling_e2e_test.dart -d <device> \
  --dart-define=SIGNALING_URL=https://<staging-host> \
  --dart-define=APP_USER_ID=<user A id> \
  --dart-define=PEER_USER_ID=<user B id>
```

`SIGNALING_URL` is the base URL; both sides append `/callSignaling`.
Without `SIGNALING_URL` every app case is skipped with a message.

Both sides must pass: the bot exits `0` only when every step had the
expected outcome, the Flutter test fails a case when any of its 3 runs
fails ("one failure = flaky = fail").

### One case at a time

Pair one Dart case with the matching bot mode (`REPEAT=3`):

| Dart case (`E2E_CASES`) | Bot `MODE` | Checks |
|---|---|---|
| `outgoing-answer` | `answer` | callCreated → callAnswered, ICE relayed both ways, app hangs up: one `endCall` to B, controller released |
| `outgoing-reject` | `reject` | `rejectCall(declined)` → `callRejected`, app releases, no echo `endCall`, end outcome "declined" |
| `outgoing-busy` | `busy` | `CallingStatus busy` + `rejectCall(busy)`, end outcome "busy" |
| `outgoing-timeout` | `timeout` | app rings 45 s, sends `missCall` + `endCall` (or gets server `missedCall`), outcome "no answer"; bot fails if the caller gave up before `MIN_RING_SECONDS` |
| `outgoing-peer-ends` | `answer-then-end` | bot hangs up after `HOLD_SECONDS`, app gets `callEnded` |
| `peer-drop` | `answer-then-drop` | bot socket down `DROP_SECONDS`, reconnects, `rejoinCall`; call must survive, then bot ends |
| `app-drop` | `answer` | app transport closed `APP_DROP_SECONDS`, auto reconnect, same socket, call still live, app sends `rejoinCall`, no `callEnded` from the server, then app hangs up |
| `incoming-accept` | `call-app:accept` | bot calls A; app answers (`answerCall`, or `acceptCallFromCallKit` → `sdpOfferFromCaller` → `answerCall`), bot ends after hold |
| `incoming-decline` | `call-app:decline` | app sends `rejectCall {remoteUserId: caller}`, bot must get `callRejected` |

Example:

```bash
MODE=reject REPEAT=3 SIGNALING_URL=... BOT_USER_ID=... APP_USER_ID=... node call_bot.js
flutter test integration_test/call_signaling_e2e_test.dart -d <device> \
  --dart-define=SIGNALING_URL=... --dart-define=APP_USER_ID=... \
  --dart-define=PEER_USER_ID=... --dart-define=E2E_CASES=outgoing-reject
```

`MODE` also takes a list with repeats, e.g. `MODE="answer*3,call-app:decline*3"`.

## Bot settings

| Variable | Default | Meaning |
|---|---|---|
| `SIGNALING_URL` | (required) | base URL of the staging server |
| `SIGNALING_NAMESPACE` | `/callSignaling` | |
| `BOT_USER_ID` | (required) | user B |
| `BOT_TOKEN` | – | sent as `auth.token`; `BOT_TOKEN_IN_QUERY=1` also adds `query.token` |
| `APP_USER_ID` | – | user A; required for `call-app`; calls from others are ignored |
| `MODE` / `REPEAT` / `EXPECT` | – / 1 / any | see above |
| `ANSWER_DELAY_SECONDS` | 2 | ring time before answer / reject |
| `HOLD_SECONDS` | 5 | answered call length (match `--dart-define=BOT_HOLD_SECONDS`) |
| `DROP_SECONDS` | 5 | outage in `answer-then-drop` (match `BOT_DROP_SECONDS`) |
| `DROP_KIND` | `transport` | `transport` = engine closed like a network loss; `client` = `socket.disconnect()` |
| `RING_TIMEOUT_SECONDS` | 60 | `call-app` ring limit; `timeout` mode waits this + 30 s |
| `MIN_RING_SECONDS` | 30 | `timeout` mode fails if the caller gives up earlier |
| `WAIT_CALL_SECONDS` | 300 | callee steps: wait for `newCall` |
| `END_WAIT_SECONDS` | 180 | `answer`: wait for the app's hang-up |
| `STEP_GAP_SECONDS` | 8 | pause before each `call-app` step |
| `IS_VIDEO` | 0 | `1` = `call-app` places a video call |
| `TIMEOUT_SECONDS` | 3600 | hard limit for the run |

App-side defines: `BOT_HOLD_SECONDS`, `BOT_DROP_SECONDS`, `APP_DROP_SECONDS`
(default 5 each), `E2E_CASES`, `E2E_EXPECT_REJOIN` (default `true`; `false`
turns a missing `rejoinCall` into a warning).

## Logs

Every event is logged with a timestamp, both sides (`[call-bot]` /
`[E2E hh:mm:ss.mmm]`, `->` sent, `<-` received). Tokens and secrets are
redacted; SDP and ICE candidates are logged as their length only.

## Known limits

- The app test shows the system incoming-call UI (CallKitService reacts to
  `newCall`); do not tap it. Each incoming run ends with
  `CallKitService.dismissAll()`.
- In `app-drop` the bot (mode `answer`) cannot tell whether the server
  ended the call to B during the app's outage; check the bot log: its
  `callEnded` must come after the app's hang-up.
- Whether the server handles `rejoinCall`, keeps `reason` on
  `callRejected` and relays `callStatus busy` is a backend question
  (doc 02 §5.3); a failing case may be a backend gap, not an app bug.
