# App Cache — Unit / Widget Test Report

| | |
|---|---|
| Last updated | 2026-11-17 (Run 1) |
| Branch | `46Solution`, uncommitted |
| Command | `flutter test` (whole suite) and `flutter test test/app_cache` |
| Guide | [07_APP_CACHE_FRONTEND.md](../../../07_APP_CACHE_FRONTEND.md) |

## Results

| Suite | Pass | Fail | Notes |
|---|---|---|---|
| `test/app_cache/` (new) | **59** | 0 | 8 files, below |
| `test/chat_qa/chat_message_cache_test.dart` (chat cache) | 19 | 0 | Unchanged, still passing after the shared key / registry change |
| Whole project | 975 + the 11 status tests re-run after the fix | **31, all pre-existing** | See "Failures" |

### Failures in the full run
- **11 status tests failed in the first full run, caused by this work.**
  - Cause: `StatusFeedController._currentUser()` read storage before it was initialised.
  - Fixed with a try / catch, so the cache stays off when storage is not ready.
  - After the fix, `status_controllers_test`, `status_section_widget_test` and `status_cache_test` pass (32 / 32).
- **The other 31 failures existed before this work:**
  - `permission_setup_flow_test` (27);
  - chat list / chat screen / socket QA tests, which also fail on the untouched branch (baseline run of 2026-11-17);
  - several of them fail only when the whole suite runs (time / order dependent) and pass alone.
- **No test that passed before fails now.**

## New tests

| File | Tests | Covers |
|---|---|---|
| `app_cache_test.dart` | 21 | AC-01 round trip · AC-02 version bump clears one area · AC-03 corrupt entry · AC-04 per-user isolation · AC-05 logout clears every box + key · AC-06 never throws, 3 s cap · AC-07 size cap · AC-08 lost key · AC-09 chat cache untouched · AC-10 one shared key · AC-11 empty never wipes · AC-12 debounced snapshot · **SC-06** logout with a pending write · AC-13 stale uid / generation refused · AC-14 > 64 KB off the UI thread · AC-15 merge (live wins, newer cached wins, new list) · AC-16 encrypted at rest · AC-17 no user · AC-18 clearArea · AC-19 readAs · AC-20 warmUp |
| `chat_list_cache_test.dart` | 11 | CL-01 lossless codec · CL-02 cache first · CL-03 offline + retry · **SC-01** socket before cache read · **SC-02** socket after cache → UI + cache · **SC-03** older cache never overwrites newer · **SC-05** remove / clear → UI + cache (main + Archived) · **SC-08** unread 5 → 2 · CL-04 bad Archived payload · CL-05 early 1-row change never overwrites 50 · CL-06 version bump |
| `contacts_cache_test.dart` | 4 | CT-01 cache + offline · CT-02 old error view · CT-03 account switch · CT-04 same user |
| `groups_cache_test.dart` | 6 | GR-01 round trip · GR-02 cache first · GR-03 offline keeps list · GR-04 old error view · GR-05 write-through · GR-06 live wins |
| `call_history_cache_test.dart` | 5 | CH-01 round trip · CH-02 cache + offline · CH-03 other day dropped · CH-04 clear-all saved · **SC-04** resume runs the catch-up API |
| `status_cache_test.dart` | 5 | ST-01 round trip, no viewers · ST-02 expired never shown · ST-03 delete → UI + cache · ST-04 logout empties permanent controllers · ST-05 account switch |
| `walkie_channels_cache_test.dart` | 2 | WK-01 cache + offline (fallback no longer wipes) · WK-02 live speaking state never saved |
| `notifications_cache_test.dart` | 5 | NT-01 round trip · NT-02 cache first · NT-03 offline · NT-04 read / clear-all saved · **SC-07** open / close 10× (one listener, one row) |

### Socket + cache (SC-01 … SC-08)

| ID | Test | Result |
|---|---|---|
| SC-01 | Event before the cache read finishes is kept | Pass (chat list) |
| SC-02 | Event after the cache → UI and cache updated | Pass (chat list) |
| SC-03 | Older data never overwrites newer | Pass. Checked on the cache → live merge. The API → socket merge is the existing `_mergePrivateChat(fromServer)` logic, unchanged |
| SC-04 | Resume → catch-up API + cache | Pass (call history) |
| SC-05 | Delete / remove → gone from UI and cache | Pass (chat list, status, call history, groups) |
| SC-06 | Logout with a pending write → nothing in the next user's box | Pass |
| SC-07 | Open / close 10× → listeners once, one event once | Pass |
| SC-08 | Unread cached 5, server 2 → 2 | Pass |

Socket events are driven through the controllers' handlers (the same functions the socket service calls), as in the existing chat-list tests. The fake Socket.IO server (`test/chat_qa/fakes/`) was not needed for these cases.

## Coverage (new / changed cache files)

| File | Lines | Coverage |
|---|---|---|
| `lib/app/Data/Services/app_cache.dart` | 143 / 151 | **94.7 %** |
| `lib/app/modules/Messages/Controller/chat_list_cache_codec.dart` | 57 / 60 | **95.0 %** |
| `lib/app/Data/Services/chat_message_cache.dart` | 156 / 178 | **87.6 %** |

Target ≥ 80 %: met. (Generated with `flutter test --coverage`; the tracked `coverage/lcov.info` was restored afterwards and not changed.)

## Limits
- No device in this run. Time to first content and the manual cases are in [manual_testing/manual_checklist.md](../manual_testing/manual_checklist.md).
- Unit tests run without a server, which is also the offline case. API success paths (server data merged over the cache) are covered by the existing merge tests and by the phone checks.

## Run 2 (2026-11-18): "Couldn't refresh" rules (C-1.0.1 / F-1.2.9)

- The chat list now uses `RefreshBarState`; its tests are in `test/chat_qa/chat_list_refresh_bar_test.dart` (18, pass) — see the chatting report §R3.
- `CL-03` updated: a 4xx (flutter_test's HTTP mock answers 400) is a real answer, not "Couldn't refresh" → no bar; the offline bar is RB-L03. `test/app_cache/` 59 → still 59, all pass.
