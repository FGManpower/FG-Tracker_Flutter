# Chatting — Unit, Widget and Real-time Test Report

| | |
|---|---|
| Last run | 2026-11-16 · `flutter test --coverage` (whole project) · Flutter 3.47.2 |
| Branch | `multi-language` |
| Rule | Tests only. **No app code (`lib/`) was changed.** |
| Bugs | [../bug_tracker.md](../bug_tracker.md) · Security: [../pentesting/pentest_report.md](../pentesting/pentest_report.md) |

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
