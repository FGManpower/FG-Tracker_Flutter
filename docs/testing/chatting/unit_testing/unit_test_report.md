# Chatting — Unit, Widget and Real-time Test Report

| | |
|---|---|
| Last run | **Run 2 — 2026-11-17**, branch `46Solution` (see "What was tested" below) |
| Rule | Tests only. **No app code (`lib/`) was changed by testing.** |
| Bugs | [../bug_tracker.md](../bug_tracker.md) · Security: [../pentesting/pentest_report.md](../pentesting/pentest_report.md) · Phone checklist: [../manual_testing/manual_checklist.md](../manual_testing/manual_checklist.md) |

---

# Run 2 — 2026-11-17, branch 46Solution, F-1.2.5

## R2.1 What was tested (baseline)

| | |
|---|---|
| Date | 2026-11-17, 19:32 – 20:56 IST |
| Flutter | 3.47.2 (stable, framework `d3b14c8769`), Dart 3.13.2, Windows 11 |
| Branch | `46Solution` |
| Code at the start | HEAD `8684404b` **plus uncommitted F-1.2.1 … F-1.2.5** changes in the working tree |
| Code at the end | HEAD **`d892094c`** ("Bug", 2026-11-17 20:09, git user `saritadalai`). That commit took the F-1.2.4 / F-1.2.5 app code **and nine of this run's test files that were still being edited**. Testing did not commit; the commit came from another session. The guide is now F-1.2.6 (chat bubble look, UI only) |
| Parallel work during the run | Another session kept changing `lib/` (uncommitted): a new chat-list / app cache (`app_cache.dart`, `chat_list_cache_codec.dart`, changes in `chat_list_controller.dart`, `chatlist_screen.dart`, `chat_message_cache.dart`, `newChat_controller.dart`, `new_chat_screen.dart`, `Group_Controller.dart`, `groups_list_screen.dart`, `main.dart`) and `test/app_cache/`. Results below say which code they ran on |
| `flutter pub get` | OK. Afterwards the 20 generated `lib/l10n/app_localizations*.dart` files were missing (78 analyzer errors); regenerated with `flutter gen-l10n` from the ARB files, back to the start state (T-08) |
| `flutter analyze` (whole project) | **977 issues: 0 errors, 207 warnings, 770 info** (after the l10n restore) |
| `flutter analyze` on the chat test files | Before: 3 info. After: **1 info** (pre-existing `fake_async` import in `chat_list_rules_qa_test.dart`). **Test files add 0 new issues**; 2 removed by the T-05 rewrite |

## R2.2 Results

| Run | Scope | Code | Passed | Skipped | Failed |
|---|---|---|---:|---:|---:|
| Baseline | `test/chat_qa` + `group_chat_blank_messages_test` | start state | 488 | 29 | 4 |
| Baseline `--run-skipped` | same | start state | 490 | — | 31 |
| Full 1 (`--coverage`) | whole project | ≈ `d892094c` | 926 | 45 | 32 |
| Full 2 | whole project | `d892094c` + app-cache WIP (+21 `app_cache` tests) | 947 | 45 | 32 |
| Full 3 | whole project | same | 947 | 46 | 31 |
| `--run-skipped` (chat files) | chat_qa + old chat tests | same | 571 | — | 34 (all = known bug IDs) |
| **Final chat suite** (20:47) | `test/chat_qa` + 16 older chat test files (35 files) | `d892094c` + WIP | **689** | **34** | **3** |

The 3 failures of the final chat run:
1. `chat_list_controller_qa_test` "open chat cleared (no messages) empties the row preview": **BUG-CL-08** (needs decision; left un-skipped since Run 1).
2. `block_realtime_test`: **did not compile**. The uncommitted `newChat_controller.dart` from the parallel session was mid-edit. Re-run at 20:56: **7 / 7 pass**.
3. `chat_message_cache_test` HC-23: logout took 7.5 s, cap 3.8 s, in a run where the compiler crashed (CPU starved). Run alone twice: **pass**. → flaky under load.

Whole-project failures outside chat: 27 `permission_setup_flow_test` (same as Run 1, out of scope), and **3 new** in `language_selection_test` (Settings → Language; out of scope, not investigated).

### Flaky tests (3 full runs)

| Test | Run 1 | Run 2 | Run 3 | Verdict |
|---|---|---|---|---|
| T-04 `status_section_widget_test` (6) | Pass | Pass | Pass | Not flaky any more (state isolated in `setUp`) |
| RT-18 network drop: open group re-joined | Pass | Pass | Pass | Not flaky in Run 2 |
| HC-23 logout ≤ 3 s with a stuck Keystore | Pass | Pass | Pass (full) / **Fail** (final chat run, 7.5 s) | **Flaky under heavy load** (timing bound) |
| `chat_screen_logic_test` attendance menu | Fail | Fail | Skipped | Not flaky: real regression BUG-CS-20, skipped with its ID between run 2 and run 3 |

Every other test had the same result in all three runs.

## R2.3 Known bugs re-checked (A3)

| Bug | Test | Run 2 result | Status |
|---|---|---|---|
| BUG-CS-18 blank group list | `group_chat_blank_messages_test` (11) | Pass | Fixed in code — phone check pending |
| BUG-RT-03 group seen handler replaced | RT-09 … RT-09f | Pass | Fixed in code — phone check pending |
| BUG-CS-13 blue tick with `{userId}` maps | widget tick tests + 6 tick ↔ Info tests | Pass | Fixed in code — phone check pending |
| BUG-CS-16 fake "Delivered" in group Info | "undelivered group message is not listed as delivered to all" | Pass | Fixed in code — phone check pending |
| BUG-CS-15 "Delivered" for a one-tick message | was `skip: true` → **now passes, skip removed** | Pass | Fixed in code — phone check pending |
| BUG-CS-01 ticks / edits missed while offline | was skipped → **now passes, skip removed**; new test "re-read page upgrades delivered, delete and first edit" passes | Pass | Fixed in code (commit `271d63a3`); second edit split out as BUG-CS-22 |
| BUG-CL-03 malformed archive reply wipes Archive | was skipped → **now passes, skip removed** | Pass | Fixed in code **in the uncommitted parallel change** — re-check after it is committed |
| BUG-RT-01 list events lost | RT-01 (skipped) fails; **RT-01b updated: 6 of 9 heard** | Partly better | Still open. Lost: `private_chat_list_updated`, `common_chat_list_updated`, `unified_chat_list_updated` |
| BUG-CS-04 private seen without ids | "chat-wide seen update (empty messageIds)" | Fail | Needs decision. Group `mark_seen` now sends ids; private does not (RT-13 private) |
| BUG-CS-05 `{userId}` duplicate in Seen by | old `applyGroupSeen` test | Fail | Dead code: the app no longer calls `applyGroupSeen`; the live path (`MessageReceipts`) passes → Fixed in code |
| BUG-CS-09 `seenBy` as a JSON string | "seenBy sent as a JSON string is counted" | Fail | Still open (`GetMessage.dart:658`) |
| All other test-proven bugs | their skipped tests (`--run-skipped`) | Fail | Still open (list in the bug tracker) |
| New: BUG-CS-19, -20, -21, -22, -23, BUG-CL-09 | new / split tests, kept with `skip: 'BUG-xx'` | Fail | New (bug tracker) |

## R2.4 Test-suite issues (A4)

| ID | What was done | Result |
|---|---|---|
| T-01 | Old pin / archive rollback tests now check the instant change, then the rollback after the failed API call | Pass |
| T-02 | Old `isNewMessage` test rewritten to the anti-shuffle rule (2 tests) | Pass |
| T-03 | Root cause found: a **real app difference** (archived list re-sorts on every update) → BUG-CL-09. Test split; `setUp` waits for the controller's initial loads | "shown sorted" Pass; "seen update keeps order" skipped (BUG-CL-09) |
| T-04 | `setUp` resets GetX and fixes the locale | Pass in all 3 runs |
| T-05 | `typing_indicator_test.dart` rewritten against `ChatTypingTracker` + `ChatListController` typing handlers (10 tests) | Pass |
| T-06 | Zone-independent version of the UTC → local "Today" test | Pass on any time zone |
| T-07 (new) | `group_open_during_build_test` removed flutter_test's HTTP mock while opening a controller that calls the production API host → loopback-only guard added | Pass |

## R2.5 What is tested, by feature (new and changed in Run 2)

| Feature (version) | Test file | Tests | Status | Known bugs |
|---|---|---:|---|---|
| Real-time block (F-1.1.8) | `chat_qa/block_realtime_test.dart` | 7 | Pass | — |
| Blank group list (F-1.1.9) | `group_chat_blank_messages_test.dart` | 11 | Pass | — |
| Message Info + receipts (F-1.2.0) | `chat_qa/message_receipts_test.dart` | 24 (+5 Run 2) | Pass | — |
| Message Info sheet + bubble tick | `chat_qa/chat_screen_widgets_qa_test.dart` | 19 pass + 4 skipped | Pass + bugs | BUG-CS-11, -12, -14, -17 |
| Receipts over the socket | `chat_qa/realtime_socket_qa_test.dart` RT-09 … RT-09f, RT-12 … RT-14 | 9 | Pass | — |
| "X left" live (F-1.2.1) | `chat_qa/group_member_left_test.dart` | 3 | Pass | — |
| Crash opening a group (F-1.2.2) | `chat_qa/group_open_during_build_test.dart` | 1 | Pass | — |
| Archived group opens (F-1.2.3) | — | 0 | **Manual only (RS-13)** — the archive screen needs live controllers; no test without an app change | — |
| Hive cache (F-1.2.4) | `chat_qa/chat_message_cache_test.dart` | 24 pass + 1 skipped (+6 Run 2) | Pass + bugs | BUG-CS-23; HC-23 flaky under load |
| `mark_seen` once per open (F-1.2.5) | `chat_qa/group_mark_seen_test.dart` (new) | 6 | Pass | — |
| History merge | `chat_qa/chat_screen_rules_qa_test.dart` | 58 pass + 9 skipped | Pass + bugs | BUG-CS-02, -03, -04, -05, -19, -20, -21, -22 |
| Typing (list) | `typing_indicator_test.dart` (rewritten) | 10 | Pass | BUG-RT-05 (redraw, not testable) |

### Hive cache tests (A5) — `chat_message_cache_test.dart`

| Requirement | Test(s) | Result |
|---|---|---|
| Merge by id, no duplicates | HC-03 | Pass |
| Newest 50 saved; pending (no id) not saved | HC-04, HC-05 | Pass |
| 30-chat LRU | HC-06, HC-07 | Pass |
| Empty / partial API response never wipes the copy | HC-08 | Pass |
| Edit / delete / tick saved | HC-09 | Pass |
| Reaction saved | HC-20, HC-21 (new) | Pass |
| Pin saved | — | Not applicable: pin is chat-level state (`pinnedMessage`), not a `MessageData` field, so it is not in the cache; the banner comes from the API |
| Group receipts survive a restart (`readBy` / `deliveredTo`) | HC-20 (new) | Pass |
| Logout `clearAll()`: boxes, registry, key deleted | HC-12, HC-22 (new) | Pass |
| Logout capped at 3 s, never throws | HC-23, HC-24 (new) | Pass (HC-23 flaky under load) |
| Next login after a capped logout | HC-25 (new) | **Fail → BUG-CS-23** (skipped) |
| `cacheVersion` mismatch clears | HC-13 | Pass |
| Another account never sees the copy | HC-14, HC-22 | Pass |
| Corrupt entry → empty, no crash | HC-19 | Pass |
| Old `private_chat_cache_*` keys imported once, then deleted | HC-18 | Pass |
| After Back, a late API response can't overwrite the saved 50 | HC-26 in `group_mark_seen_test.dart` (new; real `GroupMessageController`) | Pass (group). Private: needs testability change (below) |
| File encrypted on disk | HC-15 (+ real phone, pentest §E) | Pass |

### Group `mark_seen` (A5) — `group_mark_seen_test.dart` (new)

The real `GroupMessageController` connects to the fake Socket.IO server (test sets `Get.routing.args` and `ConstRes.socketUrl`; no app change). Every non-loopback host is blocked.

| ID | Check | Result |
|---|---|---|
| SL-MS-01 | One open → exactly 1 `mark_seen` (with `groupId`, `readAt`) | Pass |
| SL-MS-02 | Close with nothing new read → 0 `mark_seen` | Pass |
| SL-MS-03 | Open / close 5× → 5 `mark_seen` | Pass |
| SL-MS-04 | Message from another member while open → 1 `mark_seen` with `messageIds: [500]`; close → none | Pass |
| HC-26 | After Back, a late 5-message response does not replace the saved 50 | Pass |
| GUARD-01 | Opening a group requests the API host `89.116.23.2` (blocked here) | Pass |

## R2.6 Coverage (A6)

From `flutter test --coverage` (full run 1). Chat module = `lib/app/modules/Messages/**`, `lib/app/modules/status/**`, `Socket_Message_Services.dart`, `status_socket_service.dart`, `chat_translation_service.dart`, `chat_message_cache.dart`, `active_chat_tracker.dart`, `MessageInfoSheet.dart`, models `GetMessage`, `PrivateChatModel`, `ForwardMessageModel`, `status_model`. Run 1 did not record its exact file list, so Run 1 vs Run 2 is approximate.

| Scope | Run 1 (2026-11-16) | Run 2 (2026-11-17) |
|---|---:|---:|
| All app files loaded by any test | 7,749 / 125,739 = 6.2 % | 9,346 / 130,546 = **7.2 %** |
| Chat module | 3,653 / 19,913 = 18.3 % | 4,598 / 20,709 = **22.2 %** |

| File | Run 1 % | Run 2 % | Lines hit / total (Run 2) |
|---|---:|---:|---:|
| `message_receipts.dart` (new) | — | **98.2** | 112 / 114 |
| `chat_list_logic.dart` | 94.4 | 94.4 | 117 / 124 |
| `chat_screen_logic.dart` | 97.0 | 92.7 | 178 / 192 |
| `PrivateChatModel.dart` | 89.9 | 90.3 | 251 / 278 |
| `ForwardMessageModel.dart` | 82.0 | 82.0 | 100 / 122 |
| `GetMessage.dart` | 71.1 | 81.6 | 524 / 642 |
| `chat_message_cache.dart` (new) | — | **81.4** | 144 / 177 |
| `chat_translation_service.dart` | 76.0 | 79.2 | 99 / 125 |
| `chat_translation_widgets.dart` | 88.6 | 75.0 | 102 / 136 (file grew) |
| `MessageInfoSheet.dart` | 84.0 | 74.9 | 358 / 478 (file grew: group Info) |
| `Socket_Message_Services.dart` | 42.0 | **61.8** | 757 / 1,225 |
| `chat_list_controller.dart` | 60.3 | 60.6 | 773 / 1,275 |
| `GroupChatController.dart` | 0.1 | **15.7** | 235 / 1,493 (new controller test) |
| `ChatInputArea.dart` | 14.9 | 14.9 | 87 / 582 |
| `ChatItem.dart` | 6.3 | 5.5 | 101 / 1,836 |
| `MessageController.dart` | 0 | 0 | 0 / 1,434 |
| `Chat_Screen.dart` / `GroupChatScreen.dart` | 0 / 0 | 0 / 0 | 0 / 404, 0 / 335 |
| `chatlist_screen.dart` | 0.1 | 0.1 | 1 / 780 |
| `ArchivedChatsScreen.dart` | — | 0.4 | 1 / 266 |

## R2.7 Needs testability change / needs Key

Nothing was changed. Each item needs an app change and the user's OK.

**Needs testability change:**
- Private chat controller in tests: `MessageController.onInit` calls `GroupTrackingController.instance.initializeLocation()` (`MessageController.dart:~696`, a protected module) and needs a `MemberData` argument. To test "after Back, no overwrite" and the screen typing timer for **private** chats, inject the location / tracking dependency or move `_scheduleCacheSave` / `onRoutePopped` gating into a small testable class.
- List row redraw (BUG-RT-05): `typingLabelFor(chat)` read in `itemBuilder` outside `Obx` (`chatlist_screen.dart:595`); a widget test needs the chat list screen with a fake controller (`Get.put` before build) — possible, but the screen also starts sockets in `onInit`.
- Archived group open (F-1.2.3, RS-13): `ArchivedChatsScreen` builds live controllers; needs an injectable controller.
- Presence (BUG-RT-06): no listener exists; nothing to test until one is added.
- `formatLastSeenWith` takes `now` but not a time zone (`last_seen_formatter.dart:28-32`); T-06 is solved by building the instant from the machine zone, a `toLocal` seam would make it exact.

**Needs Key (for E2E finders):** see R2.9 D0 item 4.

## R2.8 How to run (Run 2)

```bash
# chat suite (unit + widget + real-time socket), ~2 min
flutter test test/chat_qa test/group_chat_blank_messages_test.dart \
  test/chat_list_controller_realtime_test.dart test/chat_list_logic_test.dart \
  test/typing_indicator_test.dart test/last_seen_formatter_test.dart test/chat_screen_logic_test.dart

# only the new Run 2 files
flutter test test/chat_qa/group_mark_seen_test.dart test/chat_qa/chat_message_cache_test.dart \
  test/chat_qa/message_receipts_test.dart

# which known bugs are still there (runs the skipped tests too)
flutter test test/chat_qa --run-skipped

# whole project + coverage (coverage/lcov.info is TRACKED in git: restore it afterwards)
flutter test --coverage
git checkout -- coverage/lcov.info

# if lib/l10n/app_localizations*.dart disappear after `flutter pub get`
flutter gen-l10n
```

Rules for every test that talks to a socket: it uses the local fake server (`test/chat_qa/fakes/fake_socket_io_server.dart`). A test that removes flutter_test's HTTP mock (`HttpOverrides.global = null`) must install a **loopback-only** guard, because the API host is the production constant (see `group_mark_seen_test.dart` `LoopbackOnlyHttp`).

## R2.9 E2E (integration_test) — D0 plan (not built; waiting for approval)

1. **Which server, and can it be staging without changing `lib/`? → No. STOP.**
   - `ConstRes.production = 'http://89.116.23.2:3000/'`, `aBaseUrl`, `aImageBaseUrl` are `static const` (`const_res.dart:14-17`). Every endpoint in `urls.dart` is a const string built from it (`urls.dart:6…`). Only `socketUrl` is a mutable static (`const_res.dart:18`). No flavors, no `--dart-define`.
   - A test-only workaround exists: an `HttpOverrides` proxy in the test that rewrites `89.116.23.2:3000` to staging. It covers Dio, Socket.IO and `cached_network_image`, but **not** native traffic (FCM, video player, maps, native image loaders). One miss = test traffic on **production**. Not recommended.
   - **Recommended:** one approved line in `const_res.dart`: `static const String production = String.fromEnvironment('API_ORIGIN', defaultValue: 'http://89.116.23.2:3000/');` (normal builds unchanged), plus the staging URL from the backend team (the commented `10.57.204.163:4000` is a LAN address).
2. **Test login without the OTP files.** Startup goes straight to Home when `user_token_key` is set and `isRegistered == "true"` (`InitiateController.dart:128-140`). **Recommended:** the test writes the session into SharedPreferences before `app.main()` (`userId`, `user_token_key`, `isRegistered`), with a staging JWT that the bot tool gets for test account A through the staging REST login. Needs a **fixed test OTP on staging** (backend), used by the bot only, never through the app UI. The permission gate then needs Location + Notifications granted (`adb shell pm grant` before the run, or Patrol).
3. **Bot design.** `scripts/chat_qa/e2e_bot/` — Node 20, `socket.io-client`, built-in `fetch` + `http`. Users B, C, D from `scripts/chat_qa/e2e_bot/.env` (phone numbers + staging origin; tokens fetched at start, never written to the repo). A folder `.gitignore` with `.env` is added (the root `.gitignore` has no `.env` rule). Each bot connects `/privateChat` and `/chat` with `auth: {token}` (`chat_socket.test.js` today sends only `{userId}`; its connect code is reused). HTTP control API on `127.0.0.1:<port>` (`0.0.0.0` only for a real phone on the LAN): `/bot/:u/send`, `/typing`, `/read`, `/edit`, `/delete`, `/block`, `/unblock`, `/group/send`, `/group/rename`, `/group/add-member`, `/group/remove-member`, `/group/leave`, `/bot/:u/inbox?since=` (what the bot received, with server timestamps for delays), `/reset` (deletes test data). Reachable at `10.0.2.2:<port>` (Android emulator), `localhost:<port>` (iOS Simulator), LAN IP (real phone). **Safety:** the bot refuses to start when the origin is `89.116.23.2` unless `ALLOW_PRODUCTION=yes` (never set without your written OK).
4. **Finders — needs Key** (existing Keys: `chat_send_button`, `chat_mic_button`, `chat_list_<chatId>`, `group_chat_list_<groupId>`, `chat_typing_text`, `chat_refresh_failed_bar`, `chat_history_retry`, `msg_info_*`, `archived_entry_title` / `_badge`, `search_icon`):
   - needs Key: chat list row per chat — `_chatRow`, `chatlist_screen.dart:887` (a name finder is ambiguous with search results)
   - needs Key: unread badge — `chatlist_screen.dart:1369-1379`
   - needs Key: message bubble per message id — `ChatBubble` `ChatItem.dart:629`, `GroupChatBubble` `ChatItem.dart:2056`
   - needs Key: tick icon per message — `ChatItem.dart:1000-1001` (private), `ChatItem.dart:2503` (group)
   - needs Key: pinned banner — `Chat_Screen.dart:80-85`
   - recommended Key: message input — `TextField` `ChatInputArea.dart:400` (works with `find.byType` on the chat screen today)
   - text finders are enough (via l10n strings): long-press menu items, block banner (`Chat_Screen.dart:230`), "X left", "Couldn't refresh".
5. **Patrol vs host scripts vs manual.** Patrol (changes `android/` and `ios/` build files → **needs your OK**): tap a notification (E2E-09), app kill + cold start (E2E-07, CS-16), system permission dialogs, gallery / camera picker. Host script (Android only, no build change): network off / on (`adb shell cmd connectivity airplane-mode enable|disable`, `svc wifi`), background (`input keyevent HOME`), force stop. Manual only: real camera capture, iOS notifications without Patrol, the three-phone journeys J1 … J7.
6. **Time estimate** (once staging + test accounts + fixed OTP exist): bot tool 1 day; harness + E2E-01 … E2E-06 2–3 days; E2E-07 … E2E-10 with Patrol 2 days; 3 runs × 3 platforms + flake fixes 1–2 days → **about 6–8 working days**. iOS needs a Mac (none here).

---

# Run 1 — 2026-11-16, branch multi-language (history)

| | |
|---|---|
| Last run | 2026-11-16 · `flutter test --coverage` (whole project) · Flutter 3.47.2 |
| Branch | `multi-language` |

## 1. Result of the last run

| Scope | Passed | Skipped (known bug) | Failed |
|---|---:|---:|---:|
| Whole project | 800 | 43 | 32 |
| Of the 32 failures: chat | — | — | **5** (see §4) |
| Of the 32 failures: permission setup screen (not chat) | — | — | 27 (`test/permission_setup_flow_test.dart`, out of scope) |

- Every skipped chat test is skipped on purpose with `skip: 'BUG-xx'`. It checks the **correct** behaviour and will pass once that bug is fixed. Turn it back on when you fix the bug.
- `flutter analyze` on the new test files: **No issues found.**
- In the first full run, the 6 status widget tests failed. They pass alone and passed in the final run, so they are **flaky** (see T-04 in the bug tracker).

## 2. What is tested, by feature

Status values:
- `Pass`: all tests for the feature pass.
- `Pass + bugs`: tests pass, but some are skipped because of known bugs.
- `Fail`: a test fails.
- `Not covered`: no automated test.

### Chat list

| Feature | Test file(s) | Status | Known bugs |
|---|---|---|---|
| New message → row to top, preview, time | `chat_qa/chat_list_controller_qa_test.dart`, `chat_list_controller_realtime_test.dart` | Pass + bugs | BUG-CL-01, BUG-CL-02 |
| Unread badge (server count, +1, dedupe, open chat = 0, read grace) | `chat_qa/chat_list_controller_qa_test.dart`, `chat_qa/chat_list_rules_qa_test.dart` | Pass + bugs | BUG-CL-06 |
| Delete for everyone / for me → preview | `chat_qa/chat_list_controller_qa_test.dart` | **Fail** (1) + bugs | BUG-CL-07, BUG-CL-08 |
| Archive / Unarchive (optimistic + rollback) | `chat_qa/chat_list_controller_qa_test.dart` | Pass + bugs | BUG-CL-03; old tests T-01, T-03 |
| Pin / Unpin | same | Pass | old test T-01 |
| Mute / Unmute | same | Pass + bugs | BUG-CL-04 |
| Mark as read / unread (incl. other device, restart) | same | Pass + bugs | BUG-CL-05 |
| Delete chat | same | Pass | — |
| Search | same | Pass | — |
| Sorting (pinned, time, tie-break) | `chat_qa/chat_list_rules_qa_test.dart`, `chat_list_logic_test.dart` | Pass (1 old test fails) | old test T-02 |
| Typing label (private + group) | `chat_qa/chat_list_controller_qa_test.dart`, `chat_qa/chat_list_rules_qa_test.dart` | Pass | Row redraw: BUG-RT-05 (not testable without an app change) |
| Row model parsing (ids, flags, last message, online) | `chat_qa/private_chat_model_qa_test.dart` | Pass | — |
| Row widgets (typing one line, archived badge, big font) | `chat_list_widgets_test.dart` | Pass | — |
| Red-dot markers | `notification_marker_chatting_test.dart` | Pass | — |
| Status / Updates section | `chat_qa/status_model_test.dart`, `chat_qa/status_controllers_test.dart`, `chat_qa/status_section_widget_test.dart` | Pass (widget tests flaky) | T-04 |

### Chat screen

| Feature | Test file(s) | Status | Known bugs |
|---|---|---|---|
| History merge, dedupe, order, paging | `chat_qa/chat_screen_rules_qa_test.dart`, `chat_screen_logic_test.dart` | Pass + bugs | BUG-CS-01, BUG-CS-02 |
| Hold-press menu options per message type | `chat_qa/chat_screen_rules_qa_test.dart` (Long-press menu) | Pass | — |
| Reply (preview bar + quoted bubble) | `chat_qa/chat_screen_preview_forward_qa_test.dart`, `reply_preview_test.dart` | Pass | — |
| Forward (selection, search, payload, parsing) | `chat_qa/chat_screen_preview_forward_qa_test.dart`, `forward_message_whatsapp_test.dart` | Pass + bugs | BUG-CS-06, BUG-CS-10 |
| Edit | `chat_qa/chat_screen_rules_qa_test.dart` | Pass + bugs | BUG-CS-03, BUG-CS-07 |
| Delete for me / for everyone | same | Pass + bugs | BUG-CS-08 |
| Ticks: private seen / group Seen by | same + `chat_qa/chat_screen_widgets_qa_test.dart` | Pass + bugs | BUG-CS-04, BUG-CS-05, BUG-CS-13 |
| Message Info sheet | `chat_qa/chat_screen_widgets_qa_test.dart` | Pass + bugs | BUG-CS-11, -12, -14, -15, -16, -17 |
| Message parsing (all media, location, contact, attendance) | `chat_qa/chat_screen_parsing_qa_test.dart` | Pass + bugs | BUG-CS-09 |
| Translate + Listen (endpoint chain, cache, swipe) | `chat_qa/translation_service_test.dart`, `chat_qa/translation_widgets_test.dart` | Pass + bugs | BUG-TS-01, BUG-TS-02 |
| Last seen text + dates (local time) | `chat_qa/chat_screen_preview_forward_qa_test.dart`, `last_seen_formatter_test.dart` | Pass | T-06 |
| Typing indicator | `typing_indicator_test.dart` | Pass (copied logic) | T-05 |
| Input bar / keyboard / big font | `chat_screen_widgets_test.dart` | Pass | — |
| Send / receive UI, media playback, camera, location picker | — | Not covered | Manual only |

### Real-time (sockets) — new in this run

File: `test/chat_qa/realtime_socket_qa_test.dart`.

**How it works:** a small fake Socket.IO server (`test/chat_qa/fakes/fake_socket_io_server.dart`) runs inside the test, on the local computer. The real `SocketMessageService` connects to it, so the app's actual socket code is tested without a backend.

| ID | What is checked | Result |
|---|---|---|
| RT-01 | Real app order: all 9 chat-list events reach the list on `/privateChat` | **Skipped — BUG-RT-01** (only 2 of 9 arrive) |
| RT-01b | Records today's behaviour: only `chat_list_updated` + `conversation_updated` | Pass (evidence) |
| RT-02 | Listeners added after the socket exists hear all 9 (shows the fix works) | Pass |
| RT-03 | `receive_message` on the list socket reaches the list | Pass |
| RT-04 | One list event is handled once (no double listeners) | Pass |
| RT-05 | All list events on `/chat` reach the list | Pass |
| RT-06 | Private typing reaches the list | Pass |
| RT-07 | Group typing still reaches the list after a group screen opened and closed | Pass |
| RT-08 | List still gets `group_updated` after a group screen opened and closed | **Skipped — BUG-RT-02** |
| RT-08b | Records: `group_updated` registered before `/chat` exists is lost | Pass (evidence) |
| RT-09 | Group seen handler survives a second seen listener | **Skipped — BUG-RT-03** |
| RT-10 | Open / close the same chat 10×, then 1 message → handled once | Pass |
| RT-11 | A group message, or another user's message, is not shown in a private chat | Pass |
| RT-12 | `join` is sent on open with `userId` + `receiverId` | Pass |
| RT-13 | `mark_seen` payload has no `messageIds` (contract check for BUG-CS-04) | Pass |
| RT-14 | Typing payload has `userId` and `chatId` | Pass |
| RT-15 | A `/chat` socket closed by the server comes back on `ensureChatSocket` | **Skipped — BUG-RT-04** |
| RT-15b | Records: after a server kick, `/chat` stays down | Pass (evidence) |
| RT-16 | Network drop: list socket reconnects and asks for a resync | Pass |
| RT-17 | Network drop: open private chat re-sends `join` | Pass |
| RT-18 | Network drop: open group is joined again | Pass |
| SEC-RT-01 | Token is sent in the handshake, not the URL | Pass |
| SEC-RT-02 | Reconnect sends the current (rotated) token | Pass |
| SEC-RT-03 | Logout closes every chat socket; no event is handled after | Pass |

**Not testable without an app change:**
- Presence (online / last seen): the app has no listener at all (BUG-RT-06).
- The list row redraw for typing (BUG-RT-05).
- The 10-try reconnect limit (BUG-RT-09) needs a long network outage.

These are in the manual checklist.

### Block in real time + local chat copy (F-1.1.8, run 2026-11-17)

File: `test/chat_qa/block_realtime_test.dart` (same fake Socket.IO server). Pure Dart, no platform channel (the toast channel is mocked), so the result holds for Android and iOS. Result: **14 / 14 pass.**

| ID | What is checked | Result |
|---|---|---|
| BLK-01 | `user_blocked {blockerId, blockedUserId}` → "peer blocked me" event | Pass |
| BLK-02 | `user_unblocked` → unblocked | Pass |
| BLK-03 | Alias events (`block_status_changed` / `block_status_updated`) with `action` or `isBlocked`, aliased id keys | Pass |
| BLK-04 | Payload without ids or state, or not a map → ignored | Pass |
| BLK-05 | Chat-list event (`chat_list_updated`, nested `data` / `chat`) names the chat ids → open chat re-checks at once | Pass |
| BLK-06 | Send ack `{ok:false, code:"BLOCKED"}` → "peer blocked me" | Pass |
| BLK-07 | Other rejected sends (`SEND_FAILED`) do not report a block | Pass |
| CACHE-01 | Save / load keeps text, voice `audioUrl`, `clientMessageId`, order | Pass |
| CACHE-02 | Only the newest 50; unsent messages (no id) skipped | Pass |
| CACHE-03 | Saving an empty list never wipes the copy | Pass |
| CACHE-04 | Clear chat removes the copy | Pass |
| CACHE-05 | Only the 20 most recent chats kept (prefs size on Android / iOS) | Pass |
| CACHE-06 | Another account on the same phone never sees the copy | Pass |
| CACHE-07 | Corrupt stored value → empty, no crash | Pass |

Not automated (manual RS-11a…d): the 4 s check timing, resume / background on a device, banner UI.

### "X left" in archived groups (F-1.2.1, run 2026-11-17)

File: `test/chat_qa/group_member_left_test.dart` (fake Socket.IO server, `/chat`). Result: **3 / 3 pass.**

| ID | What is checked | Result |
|---|---|---|
| GML-01 | `member_left`, `member_removed` (`group_id` as string), `group_left` → group id on `groupMemberChanges` | Pass |
| GML-02 | Other events, payload without group id, non-map payload → ignored | Pass |
| GML-03 | Still works after `listenGroupExit` / `listenMemberRemoved` call `off(event)` without a handler | Pass |

Not automated (manual RS-12): the actual fetch of the system message from the server and its bubble.

Side effects seen in the same run of the older files (not caused by this change: it only adds a separate stream):
- **RT-01b** (evidence test) now hears 6 of 9 list events, not 2. The behaviour got better (BUG-RT-01 partly fixed elsewhere), so the evidence expectation needs updating.
- **RT-18** failed once and passed once: flaky.
- **T-01, T-03**: same old failures as §4.

## 3. Coverage (line coverage, from `coverage/lcov.info`)

| Scope | Lines hit / total | % |
|---|---:|---:|
| All app files loaded by any test | 7,749 / 125,739 | 6.2 % |
| Chat module files (Messages, chat socket, chat models, translation, status) | 3,653 / 19,913 | **18.3 %** |

**Well covered (logic):**

| File | % |
|---|---:|
| `chat_screen_logic.dart` | 97.0 |
| `chat_list_logic.dart` | 94.4 |
| `message_preview_builder.dart` | 93.1 |
| `PrivateChatModel.dart` | 89.9 |
| `chat_translation_widgets.dart` | 88.6 |
| `MessageInfoSheet.dart` | 84.0 |
| `ForwardMessageModel.dart` | 82.0 |
| `chat_translation_service.dart` | 76.0 |
| `GetMessage.dart` | 71.1 |
| `chat_list_controller.dart` | 60.3 |
| `Socket_Message_Services.dart` | 42.0 |

**Not covered (needs a phone, or an app change to test):**

| File | % |
|---|---:|
| `MessageController.dart` | 0 |
| `GroupChatController.dart` | 0.1 |
| `Chat_Screen.dart` | 0 |
| `GroupChatScreen.dart` | 0 |
| `chatlist_screen.dart` | 0.1 |
| `ChatItem.dart` | 6.3 |
| `ChatInputArea.dart` | 14.9 |
| Media / camera / location / voice controllers | 0 |

The two chat screen controllers are about 2,700 lines with no unit coverage. Their behaviour is covered only by the manual checklist. Testing them directly would need a small testability change in the app (for example, injecting the socket service and the repository), which needs approval.

## 4. Chat failures in the last run

| Test | Why it fails | Type | Tracker |
|---|---|---|---|
| `chat_qa/chat_list_controller_qa_test.dart` "open chat cleared (no messages) empties the row preview" | After "clear chat", the row keeps the old preview | **App bug** | BUG-CL-08 |
| `chat_list_controller_realtime_test.dart` "pin while offline is rolled back" | Old test expects an instant rollback; the app now rolls back after the API fails | Old test | T-01 |
| `chat_list_controller_realtime_test.dart` "archive while offline is rolled back to the main list" | Same | Old test | T-01 |
| `chat_list_controller_realtime_test.dart` "archived server push in any order is shown sorted" | Order unchanged; the newer QA test of the same rule passes | Needs investigation | T-03 |
| `chat_list_logic_test.dart` "no ids: falls back to a strictly newer time" | The anti-shuffle rule changed; the newer QA test covers it | Old test | T-02 |

## 5. How to run

```bash
# all chat QA tests (fast)
flutter test test/chat_qa

# only the real-time socket tests
flutter test test/chat_qa/realtime_socket_qa_test.dart

# see which known bugs are still there (runs the skipped tests too)
flutter test test/chat_qa --run-skipped

# whole project + coverage
flutter test --coverage
```

When a bug is fixed:
1. Remove its `skip:`.
2. Run the test, and if there is an "evidence" test (RT-01b, RT-08b, RT-15b), update it as well.
3. Set the bug to `Fixed` in [../bug_tracker.md](../bug_tracker.md) and update this report.
