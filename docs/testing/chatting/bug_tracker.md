# Chatting — Bug Tracker

| | |
|---|---|
| Last updated | 2026-11-16 |
| Branch | `multi-language` |
| Rule | Testing only: **no app code was changed**. Every fix needs the user's approval first. |

Security findings are tracked separately in [pentesting/pentest_report.md](pentesting/pentest_report.md) (SEC-xx).

**Status values:**
- `Open`: found, not fixed.
- `Fixed`: fix merged and the skipped test turned back on and passing.
- `Won't fix`: owner decided.
- `Needs decision`: product or backend must decide.
- `Suspected`: not proven by a test yet.

**Found by:**
- **Test**: an automated test fails. It is kept with `skip: 'BUG-xx'` until the fix.
- **Code**: found by reading the code; no test can reach it without an app change.

**ID prefixes:** RT = real-time / socket · CL = chat list · CS = chat screen · TS = translation.

---

## High — makes chat look "not real time"

| ID | Area | Problem (what the user sees) | Root cause | Suggested fix | Found by | Status |
|---|---|---|---|---|---|---|
| BUG-RT-01 | Chat list | New messages / new chats / unread often don't show until the list is reopened | The list adds its listeners **before** its `/privateChat` socket exists. Only `chat_list_updated` and `conversation_updated` are heard. The other 7 list events (`private_/group_/common_/unified_chat_list_updated`, `chat_list`, `common_chat_list`, `unified_chat_list`) are dropped. `chat_list_controller.dart:956-1003`, `Socket_Message_Services.dart:1248-1358` | Register the full list listeners inside the list socket's `onConnect`, or call the listen methods after `initPrivateChatListSocket` | Test RT-01 (fails), RT-01b, RT-02 | Open |
| BUG-RT-06 | Online / last seen | "Online" / "Last seen" changes only after reopening the chat | No presence listener anywhere in chat code. Status is read once from the API when the chat opens. The old listener is commented out (`MessageController.dart:640-690`). | App: listen to the server presence event and update `isPeerOnline` / `peerLastSeen` and list rows. Backend: confirm or add the presence event + heartbeat timeout. | Code | Open (app + backend) |
| BUG-RT-04 | Reconnect | After a long background or a server restart, group updates and group typing stop until a group is opened | `ensureChatSocket` returns when `_socket != null`, even if that socket is dead (`Socket_Message_Services.dart:622-625`) | Return only if connected; otherwise `connect()` or rebuild | Test RT-15 (fails), RT-15b | Open |
| BUG-RT-09 | Reconnect | After 5+ minutes without internet, chat may stay dead | `/dashboard` is created first with `reconnectionAttempts: 10` (`Socket_Dashboard_Service.dart:80`). `socket_io_client` shares one Manager per host, so `/chat` and the first `/privateChat` socket get the same 10-try limit. There is no `reconnect_failed` handler. | Own Manager / unlimited retries for chat sockets; reconnect on `reconnect_failed` and on connectivity change | Code (Manager sharing confirmed in `socket_io_client` 3.1.6 `_lookup`) | Suspected — confirm on device (manual CN-04) |
| BUG-CS-01 | Ticks after reconnect | Ticks, edits and deletes missed while offline stay old until the chat is reopened | `merge()` always keeps the loaded copy; reconnect sync only appends new messages | After reconnect, update status / edit / delete of messages already loaded | Test | Open |
| BUG-RT-10 | Offline send (group) | Group message sent while offline shows one tick forever and is lost | `sendGroupMessage` silently returns when disconnected (`Socket_Message_Services.dart:434-437`); no failed state, no retry | Check the connection before the optimistic bubble, or mark it failed with Retry; outbox keyed by `clientMessageId` | Code | Open |
| BUG-RT-11 | Chat list | List may stop updating after going Home through a call or walkie screen | `ChatListController` is put without `permanent: true` (`home_controller.dart:108`, `chatlist_screen.dart:42`); if GetX deletes it, `onClose` closes the list socket | `Get.put(..., permanent: true)` and delete on logout. Add a log in `onClose` first to confirm. | Code | Suspected — confirm on device (manual CN-09) |

## Medium

| ID | Area | Problem | Root cause | Suggested fix | Found by | Status |
|---|---|---|---|---|---|---|
| BUG-RT-02 | Group rename / icon in list | After opening any group once, the list stops showing renames / new icons | `listenGroupUpdated` and `releaseGroupChatEvents` call `off("group_updated")` with no handler, removing the list's listener. The list also registers it before `/chat` exists. (`Socket_Message_Services.dart:1932-1946, 1713-1745`) | Keep handlers by reference and `off(event, handler)`, as typing does; re-register in `init()` | Test RT-08 (fails), RT-08b | Open |
| BUG-RT-03 | Group seen ticks | Group "seen" handler from `listenSeenUpdate` is silently replaced | `listenGroupMessageSeen` calls `off("messages_seen_update")` (`Socket_Message_Services.dart:1919-1929`) | Register `messages_seen_update` once | Test RT-09 (fails) | Open |
| BUG-RT-05 | List typing / deactivated badge | "typing…" and "Deactivated" on list rows don't appear until something else redraws the list | `typingLabelFor(chat)` and `groupDeactivated` are read inside `ListView.itemBuilder` (`chatlist_screen.dart:600`), outside the `Obx` at line 554 | Wrap the label / badge in its own `Obx` | Code | Open |
| BUG-RT-07 | Last seen | Opening a chat from a profile (no chatId) shows an empty subtitle for an offline user | The "by peer" history path sets `isPeerOnline` but not `peerLastSeen` (`MessageController.dart:1830` vs `1911-1916`) | Reuse the same online / last-seen block | Code | Open |
| BUG-RT-08 | Ticks | ✓✓ can drop back to ✓ | `message_sent` handler sets `msg.isDelivered = false` (`MessageController.dart:1136`) | Status may only go up | Code | Open |
| BUG-CS-04 | Private blue ticks | Blue ticks don't show live if the server's "seen" update has no message ids | `applyPrivateSeen()` ignores an empty `messageIds`; the app's `mark_seen` sends only `chatId` (test RT-13 confirms the payload) | Treat empty ids + matching chat as "all mine"; backend: always send ids | Test | Needs decision (backend contract) |
| BUG-CS-05 | Group Seen by | A `{userId}` map entry isn't recognised, so a duplicate is added | `applyGroupSeen()` compares `entry.toString()` | Normalise entries to ids | Test | Open |
| BUG-CS-13 | Group blue tick | Blue tick never shows when `seenBy` holds `{userId}` maps | `ChatItem.dart:3211` `_areAllMembersSeen` uses `toString()` | Normalise entries | Test | Open |
| BUG-CS-02 | Group duplicates | A history / sync page racing the send ack can show two bubbles | `merge()` dedupes by id only, not `clientMessageId` (doc §0.3) | Also dedupe by `clientMessageId` | Test | Open |
| BUG-CS-03 | Edit after delete | An edit event arriving after delete-for-everyone brings the text back | `applyEdit()` does not check `isDeleted` | Ignore edits on deleted messages | Test | Open |
| BUG-CL-01 | List order | A row doesn't move to the top when the update has no time | Update keeps the old row time (`chat_list_controller.dart:1643-1651`) | Use the message time, else now() for a new message | Test | Open |
| BUG-CL-02 | List row id | A `receive_message` can replace the row id with a message id; later remove / clear miss the row | `PrivateChatModel.dart:294-300` + merge at `chat_list_controller.dart:1654` | Never overwrite an existing row id from a message payload | Test | Open |
| BUG-CL-06 | Unread badge | Badge stays 0 for a `receive_message` whose sender is only at the top level | Only `lastMessage.senderId` is read (`PrivateChatModel.dart:266`) | Also read top-level `senderId` | Test | Open |
| BUG-CL-07 | Deleted preview | A later partial update brings back the old text of a deleted last message | `fromJson` defaults missing `isDeletedForEveryone` to false (`PrivateChatModel.dart:333-339`) | Keep it null when missing | Test | Open |
| BUG-CL-03 | Archive | An `archived_private_chats` reply without a data list empties the whole Archive | `chat_list_controller.dart:2267-2279` replaces instead of merging (doc §6.1 says merge) | Ignore malformed replies | Test | Open |
| BUG-CL-04 | Mute | Mute / unmute errors are swallowed with no rollback | `chat_list_controller.dart:1733-1739, 1764-1770` | Roll back like pin / archive (doc §5.2) | Test | Open |
| BUG-CL-05 | Mark unread | Marking one chat unread can also mark another chat (user id vs chat id) | Manual-unread keys mix user ids and chat ids (`chat_list_controller.dart:219-224`) | Use one key format (`ChatListRules.chatKey`) | Test | Open |
| BUG-CL-08 | Clear chat | After "clear chat" the list row still shows the old last message | `syncLastMessageFromChat(last: null)` now returns early on purpose (`chat_list_controller.dart:581-584`), so the clear case is not handled. Doc §6.3 says a clear empties the row. | Pass an explicit "cleared" flag from the clear action | Test (existing `chat_list_controller_qa_test` "open chat cleared…" fails) | Needs decision |
| BUG-CS-06 | Forward label | A forward wrapped as `data.forwardedMessage` loses the "Forwarded" label | `GetMessage.dart:816` checks only top-level keys | Also read the nested key | Test | Open |
| BUG-CS-07 | Edited label | `isEdited` sent as `1` / `"1"` / `"true"` never shows "Edited" | Stored raw (`GetMessage.dart:652`); UI checks `== true` | Parse to bool | Test | Open |
| BUG-CS-08 | Deleted parsing | `"true"` / `deletedForEveryone:1` show the old text | `GetMessage.dart:846` accepts only `true` / `"1"` | Parse to bool | Test | Open |
| BUG-CS-09 | Seen by | `seenBy` sent as a JSON string gives an empty "Seen by" | Stored raw (`GetMessage.dart:650`) | Decode JSON strings | Test | Open |
| BUG-CS-15 | Message Info | Info says "Delivered" for a message that shows one grey tick | `MessageInfoSheet.dart:545` treats any timestamp as delivered | Use the delivered flag | Test | Open |
| BUG-CS-16 | Message Info (group) | Shows "(2 of 2) Delivered" when the info API returns nothing | `MessageInfoSheet.dart:74` fills every member | Show "Not delivered yet" | Test | Open |
| BUG-TS-01 | Translate | An edited message keeps showing the translation of its old text | Cache key `<messageId>_<lang>` never cleared (`chat_translation_service.dart:48-53`) | Clear the cache entry on edit | Test | Open |

## Low

| ID | Area | Problem | Root cause | Suggested fix | Found by | Status |
|---|---|---|---|---|---|---|
| BUG-CS-10 | Forward list | Pinned-first order lost when `isPinned` is `1` / `"true"` | `ForwardMessageModel.dart:158` | Parse to bool | Test | Open |
| BUG-CS-11 | Message Info | Attendance message shows raw text in Info | `MessageInfoSheet.dart:273` has no attendance case | Use `MessagePreviewBuilder` | Test | Open |
| BUG-CS-12 | Message Info | Voice / media message shows the raw file path in Info | Same switch misses voice / media | Use `MessagePreviewBuilder` | Test | Open |
| BUG-CS-14 | Message Info | Tap ripple on a member row is invisible (debug assert) | White `Container` between the sheet's Material and the ListTiles (`MessageInfoSheet.dart:157`) | Use `Material` / `Ink` | Test | Open |
| BUG-CS-17 | Language | "Delivered", "Not delivered yet", "Sent:" are always English | Hard-coded in `MessageInfoSheet.dart:248/255/339` | Move to l10n | Test | Open |
| BUG-TS-02 | Translate | "नमस्ते, दोस्त" gives a double space | Greeting regex (`chat_translation_service.dart:155-160`) | Trim the following space | Test | Open |

---

## Test-suite issues (not app bugs)

| ID | Test | Problem | Suggested action | Status |
|---|---|---|---|---|
| T-01 | `test/chat_list_controller_realtime_test.dart` "pin while offline is rolled back" and "archive while offline is rolled back" | Expect the rollback at once. The app now changes the UI first and rolls back when the API fails (doc §5.2), which the newer `chat_qa` tests check with `async`. | Update or remove the old tests | Open |
| T-02 | `test/chat_list_logic_test.dart` "no ids: falls back to a strictly newer time" | Uses the same text with a newer time. The anti-shuffle rule now treats that as "not new" (covered by `chat_list_rules_qa_test`). | Update the old test | Open |
| T-03 | `test/chat_list_controller_realtime_test.dart` "archived server push in any order is shown sorted" | Fails (order unchanged), while the newer QA test of the same rule passes. Probably a different payload shape. | Investigate | Open |
| T-04 | `test/chat_qa/status_section_widget_test.dart` (6 tests) | Pass when run alone, fail in the full suite (test order / shared state) | Isolate state in `setUp` | Open |
| T-05 | `test/typing_indicator_test.dart` | Copies the logic into the test; does not test app code | Rewrite against `ChatTypingTracker` | Open |
| T-06 | `test/last_seen_formatter_test.dart:62` | Runs only on a computer set to India time | Inject the time zone | Open |
