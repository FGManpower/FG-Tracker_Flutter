# Chatting — Bug Tracker

| | |
|---|---|
| Last updated | 2026-11-17 (Run 2) |
| Branch / code | `46Solution`. Start: HEAD `8684404b` + uncommitted F-1.2.1 … F-1.2.5. During the run another session committed `d892094c` (20:09, F-1.2.4 … F-1.2.6) and kept changing `lib/` (chat-list / app cache, uncommitted). Details: unit test report R2.1 |
| Previous run | Run 1, 2026-11-16, branch `multi-language` |
| Rule | Testing only: **no app code was changed**. Every fix needs the user's approval first. |

Security findings are tracked separately in [pentesting/pentest_report.md](pentesting/pentest_report.md) (SEC-xx).

**Status values (Run 2):**
- `Fixed (test + phone)`: the automated test passes **and** the phone case passed. *(None yet: no phone run in Run 2.)*
- `Fixed in code — phone check pending`: the automated test passes now; still to confirm on a phone.
- `Still open`: the test still fails (or the code is unchanged for code-only findings).
- `Needs decision`: product or backend must decide what is correct.
- `Suspected`: not proven by a test; needs a device check.

**Found by:**
- **Test**: an automated test fails. It is kept with `skip: 'BUG-xx'` until the fix. Proof = `flutter test test/chat_qa --run-skipped` (Run 2, 2026-11-17).
- **Code**: found by reading the code; no test can reach it without an app change. Re-checked against today's code (file:line below is today's).

**ID prefixes:** RT = real-time / socket · CL = chat list · CS = chat screen · TS = translation.

---

## Summary (Run 2)

| | Count |
|---|---:|
| Bugs from Run 1 (+ BUG-CS-18 added 2026-11-17) | 39 |
| Fixed in code — phone check pending | 8 (BUG-CS-01 partly, BUG-CS-05, BUG-CS-13, BUG-CS-15, BUG-CS-16, BUG-CS-18, BUG-RT-03, BUG-CL-03 — the last one only in uncommitted code) |
| Still open | 27 |
| Needs decision | 2 (BUG-CS-04, BUG-CL-08) |
| Suspected (device check) | 2 (BUG-RT-09, BUG-RT-11) |
| Fixed (test + phone) | 0 |
| **New in Run 2** | **6** (BUG-CS-19 … BUG-CS-23, BUG-CL-09) |

Two of the new ones are **regressions** in code that passed in Run 1: BUG-CS-19 (duplicate bubbles) and BUG-CS-20 (attendance delete). Both come from developer commits on 2026-11-16, after Run 1.

---

## New in Run 2

| ID | Area | Steps | Expected | Actual | Delay | Root cause (file:line) | Suggested fix | App / Backend | Severity | Proof (test) | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| BUG-CS-19 | History merge — **regression** | A history or sync page that holds the same message twice (the server sends some messages under several event names / rooms, guide §11.3) | Each message once | The message is added twice → two identical bubbles until reopen | Immediate | Commit `271d63a3` (2026-11-16) rewrote `ChatScreenRules.merge`: `known` is filled but never checked, so duplicates **inside** the incoming page are not dropped (`chat_screen_logic.dart:114-115`). Run 1 passed this test. | `if (key != null && !known.add(key)) continue;` before `added.add(m)` | App | Medium | `chat_screen_rules_qa_test` "a message delivered twice in the same page shows once" (fails: `[1, 1, 2]`), "a duplicate inside a page next to messages already on screen shows once" (fails) | Still open (new) |
| BUG-CS-20 | Long-press menu — **regression** | Long-press an attendance card (mine or someone else's) | No Delete for me / Delete for everyone (guide §5.1: "not attendance") | Both delete options shown | — | Commit `e761f45a` (2026-11-16) removed the `isAttendance` rule from `menuOptions` (`chat_screen_logic.dart:210-225`) | Product decides. If the guide is right, restore the attendance rule; if the change was intended, update guide §5.1 and the test | App (product) | Medium | `chat_screen_rules_qa_test` "attendance_poll: no delete of any kind, even for the creator" (fails) | Needs decision |
| BUG-CS-21 | History merge | Send a text that is exactly "This message was deleted"; then any refresh (resume / reconnect / reopen) | Shown as a normal text | Turned into a deleted message (italic, no menu) | On the next refresh | `merge()` treats the English placeholder text as a delete flag: `m.content == 'This message was deleted'` (`chat_screen_logic.dart:101-103`, commit `0ccd9c47`) | Use only the server flags (`isDeleted`, `isDeletedForEveryone`) | App | Low | `chat_screen_rules_qa_test` "a message whose text is literally …" (fails) | Still open (new) |
| BUG-CS-22 | Edit while offline | A edits a message twice; B is offline for the second edit; B comes back (resume / reconnect re-read) | B sees the second text | B keeps the first edited text until reopen | Until reopen | `merge()` copies the text only when the loaded copy is not edited yet (`chat_screen_logic.dart:107`) | Compare `content` / `editedAt` instead of the flag | App | Low | `chat_screen_rules_qa_test` "a SECOND edit made while offline is applied on the re-read" (fails) | Still open (new). Rest of BUG-CS-01 is fixed |
| BUG-CS-23 | Hive cache after logout | Logout while the Keystore / Keychain call hangs (> 3 s), then log in and open a chat | Cache usable at once | Every cache call waits until the stuck call ends (forever if it never ends). The chat still opens from the API, but without the cache | Measured 3.0 s extra with a 6 s hang | `clearAll()` puts its 3 s timeout on the caller only; the serial queue `_queue` still waits for the task (`chat_message_cache.dart:91-95, 381-398`) | Put the timeout inside the queued task, or reset `_queue` after a timeout | App | Low | `chat_message_cache_test` HC-25 (fails: 3,036 ms, expected < 1 s) | Still open (new) |
| BUG-CL-09 | Archive order | Archive 3 chats; the peer of the oldest one reads it (seen update repeats its last message with a newer time) | Archive order unchanged (as in the main list) | That chat jumps to the top of Archive | Immediate | The archived branch of the realtime handler always re-sorts (`chat_list_controller.dart:1239`); the main list re-sorts only for a new message or a pin change (`1287-1292`) | Same rule as the main list: re-sort only when `isNewMessage` or the pin changed | App | Low | `chat_list_controller_realtime_test` "a seen update (same last message, newer time) keeps the archived order" (was T-03; fails) | Still open (new) |

---

## High — makes chat look "not real time"

| ID | Area | Problem (what the user sees) | Root cause (today's code) | Suggested fix | Found by | Run 2 proof | Status |
|---|---|---|---|---|---|---|---|
| BUG-RT-01 | Chat list | New messages / new chats / unread often don't show until the list is reopened | The list adds its listeners before its `/privateChat` socket exists. **Run 2: 6 of 9 list events now arrive** (Run 1: 2). Still lost: `private_chat_list_updated`, `common_chat_list_updated`, `unified_chat_list_updated`. `chat_list_controller.dart:956-1003`, `Socket_Message_Services.dart` list listeners | Register the list listeners inside the list socket's `onConnect`, or after `initPrivateChatListSocket` | Test | RT-01 fails (`--run-skipped`); RT-01b updated to 6 of 9, passes | Still open (better) |
| BUG-RT-06 | Online / last seen | "Online" / "Last seen" changes only after reopening the chat | Still no presence listener. Status is read once from the API; the old listener is still commented out (`MessageController.dart:829-852`) | App: listen to the server presence event. Backend: confirm / add the event + heartbeat timeout | Code | Code unchanged | Still open (app + backend) |
| BUG-RT-04 | Reconnect | After a long background or a server restart, group updates and group typing stop until a group is opened | `ensureChatSocket` returns when `_socket != null`, even if that socket is dead (`Socket_Message_Services.dart:824-826`) | Return only if connected; otherwise `connect()` or rebuild | Test | RT-15 fails; RT-15b passes | Still open |
| BUG-RT-09 | Reconnect | After 5+ minutes without internet, chat may stay dead | `/dashboard` is created with `reconnectionAttempts: 10` (`Socket_Dashboard_Service.dart:80`); `socket_io_client` shares one Manager per host, so chat sockets get the same 10-try limit; no `reconnect_failed` handler | Own Manager / unlimited retries for chat sockets; reconnect on connectivity change | Code | Not run on a device (manual CN-04) | Suspected |
| BUG-CS-01 | Ticks after reconnect | Ticks, edits and deletes missed while offline stay old until the chat is reopened | **Fixed in code by commit `271d63a3`:** `merge()` now upgrades `isDelivered`, `seenCount`, `seenBy`, delete and the first edit of messages already loaded. A second edit is still missed → split out as **BUG-CS-22** | — | Test | "a re-read page with newer tick state upgrades the loaded copy" passes (skip removed); new "a re-read page upgrades delivered, delete and first edit" passes | Fixed in code — phone check pending (CN-01, CS-14) |
| BUG-RT-10 | Offline send (group) | Group message sent while offline shows one tick forever and is lost | `sendGroupMessage` still returns silently when disconnected (`Socket_Message_Services.dart:600-603`) | Mark the bubble failed with Retry; outbox keyed by `clientMessageId` | Code | Code unchanged | Still open |
| BUG-RT-11 | Chat list | List may stop updating after going Home through a call or walkie screen | `ChatListController` still put without `permanent: true` (`home_controller.dart:108`, `chatlist_screen.dart:43`) | `Get.put(..., permanent: true)` and delete on logout | Code | Not run on a device (manual CN-09) | Suspected |
| BUG-CS-18 | Group chat messages go blank | Whole list goes empty after add / remove member, rename / icon, resume or reconnect | `merge()` returned the caller's own list (guide §10) | Fixed (F-1.1.9): `merge()` always returns a copy | Test | `group_chat_blank_messages_test` 11 / 11 pass | Fixed in code — phone check pending (CS-11 … CS-15) |

## Medium

| ID | Area | Problem | Root cause | Suggested fix | Found by | Run 2 proof | Status |
|---|---|---|---|---|---|---|---|
| BUG-RT-02 | Group rename / icon in list | After opening any group once, the list stops showing renames / new icons | `off("group_updated")` with no handler removes the list's listener (`Socket_Message_Services.dart:2191, 2195`); the list also registers before `/chat` exists | Keep handlers by reference and `off(event, handler)` | Test | RT-08 fails; RT-08b passes | Still open |
| BUG-RT-03 | Group seen ticks | Group "seen" handler silently replaced | Fixed in F-1.2.0: one app-level receipt listener per `/chat` socket (`groupReceipts`); old `listenGroupMessageSeen` removed | — | Test | RT-09 … RT-09f pass (receipts stream, dedupe across event names, `mark_seen` ids, delivered once) | Fixed in code — phone check pending (RS-10, MI-03/04) |
| BUG-RT-05 | List typing / deactivated badge | "typing…" and "Deactivated" on list rows don't appear until something else redraws the list | `typingLabelFor(chat)` is still read inside `itemBuilder` (`chatlist_screen.dart:595`), outside an `Obx` | Wrap the label / badge in its own `Obx` | Code | Code unchanged; needs testability change to test (screen needs a live controller) | Still open |
| BUG-RT-07 | Last seen | Opening a chat from a profile (no chatId) shows an empty subtitle for an offline user | The "by peer" path sets `isPeerOnline` only (`MessageController.dart:2004`); the by-chatId path sets `peerLastSeen` too (`2089-2105`) | Reuse the same block | Code | Code unchanged | Still open |
| BUG-RT-08 | Ticks | ✓✓ can drop back to ✓ | `message_sent` handler sets `msg.isDelivered = false` (`MessageController.dart:1309`) | Status may only go up | Code | Code unchanged | Still open |
| BUG-CS-04 | Private blue ticks | Blue ticks don't show live if the server's "seen" update has no message ids | `applyPrivateSeen()` (still used, `MessageController.dart:1069`) ignores empty `messageIds`; private `mark_seen` still sends only `chatId` (RT-13 private passes). F-1.2.0 changed only the **group** `mark_seen` | Treat empty ids + matching chat as "all mine"; backend: always send ids | Test | "chat-wide seen update (empty messageIds) marks all my messages" fails | Needs decision (backend contract) |
| BUG-CS-05 | Group Seen by | A `{userId}` map entry isn't recognised, so a duplicate is added | The old `applyGroupSeen()` still has the bug, but **the app no longer calls it** (no caller in `lib/`); group seen now goes through `MessageReceipts` with `normalizeReceiptId` | Delete the dead function (optional) | Test | Old unit test still fails on the dead function; the live path passes ("ids in readBy as maps / ints / strings all match", RT-09b) | Fixed in code — phone check pending (MI-03/04) |
| BUG-CS-13 | Group blue tick | Blue tick never shows when `seenBy` holds `{userId}` maps | Fixed in F-1.2.0: tick = `MessageReceipts.groupTick` | — | Test | "seen by all, entries as {userId} maps: purple double tick" passes; 6 new "bubble tick matches Message Info" tests pass | Fixed in code — phone check pending |
| BUG-CS-02 | Group duplicates | A history / sync page racing the send ack can show two bubbles | `merge()` dedupes by id only, not `clientMessageId` | Also dedupe by `clientMessageId` | Test | "temp bubble and its server copy (same clientMessageId) show once" fails | Still open |
| BUG-CS-03 | Edit after delete | An edit event arriving after delete-for-everyone brings the text back | `applyEdit()` does not check `isDeleted` | Ignore edits on deleted messages | Test | "a late edit event never brings back a message deleted for everyone" fails | Still open |
| BUG-CL-01 | List order | A row doesn't move to the top when the update has no time | Update keeps the old row time | Use the message time, else now() | Test | "a new message whose payload carries no time still moves the row to the top" fails | Still open |
| BUG-CL-02 | List row id | A `receive_message` can replace the row id with a message id | `PrivateChatModel` + merge | Never overwrite an existing row id from a message payload | Test | "a receive_message event does not overwrite the chat id with the message id" fails | Still open |
| BUG-CL-06 | Unread badge | Badge stays 0 for a `receive_message` whose sender is only at the top level | Only `lastMessage.senderId` is read | Also read top-level `senderId` | Test | "a receive_message from the peer (no server count) adds 1" fails | Still open |
| BUG-CL-07 | Deleted preview | A later partial update brings back the old text of a deleted last message | `fromJson` defaults missing `isDeletedForEveryone` to false | Keep it null when missing | Test | "a later presence-only update keeps the deleted flag …" fails | Still open |
| BUG-CL-03 | Archive | An `archived_private_chats` reply without a data list empties the whole Archive | Was: `_handleArchivedPrivateChats` cleared Archive on a non-list reply. **Fixed in the uncommitted parallel change** to `chat_list_controller.dart` (chat-list cache work, 2026-11-17 ~20:30): the reply is now ignored | — | Test | "an error/malformed archived reply does not wipe the Archive list": failed at 19:50, **passes at 20:45**; skip removed | Fixed in code (uncommitted) — re-check after commit; phone check pending |
| BUG-CL-04 | Mute | Mute / unmute errors are swallowed with no rollback | No rollback on API error | Roll back like pin / archive | Test | "mute failure rolls the mute back" fails | Still open |
| BUG-CL-05 | Mark unread | Marking one chat unread can also mark another chat | Manual-unread keys mix user ids and chat ids | One key format | Test | "marking one private chat unread does not mark another person …" fails | Still open |
| BUG-CL-08 | Clear chat | After "clear chat" the list row still shows the old last message | `syncLastMessageFromChat(last: null)` returns early on purpose | Pass an explicit "cleared" flag from the clear action | Test | "open chat cleared (no messages) empties the row preview" fails (not skipped) | Needs decision |
| BUG-CS-06 | Forward label | A forward wrapped as `data.forwardedMessage` loses the "Forwarded" label | Only top-level keys checked | Also read the nested key | Test | "forwarded {data:{forwardedMessage:{...}}} shows the Forwarded label" fails | Still open |
| BUG-CS-07 | Edited label | `isEdited` sent as `1` / `"1"` / `"true"` never shows "Edited" | Stored raw | Parse to bool | Test | 3 "isEdited = …" tests fail | Still open |
| BUG-CS-08 | Deleted parsing | `"true"` / `deletedForEveryone:1` show the old text | Accepts only `true` / `"1"` | Parse to bool | Test | "isDeleted from "true" / deletedForEveryone 1" fails | Still open |
| BUG-CS-09 | Seen by | `seenBy` sent as a JSON string gives an empty "Seen by" | Still stored raw (`GetMessage.dart:658`); `MessageReceipts.readMap` reads only a List | Decode JSON strings | Test | "seenBy sent as a JSON string is counted" fails | Still open |
| BUG-CS-15 | Message Info | Info says "Delivered" for a message that shows one grey tick | Fixed in code (not in the change log) | — | Test | "a sent-but-not-delivered message says "Not delivered yet"" passes (skip removed) | Fixed in code — phone check pending (MH-13) |
| BUG-CS-16 | Message Info (group) | Shows "(2 of 2) Delivered" when the info API returns nothing | Fixed in F-1.2.0 | — | Test | "undelivered group message is not listed as delivered to all" passes | Fixed in code — phone check pending (MI-02) |
| BUG-TS-01 | Translate | An edited message keeps showing the translation of its old text | Cache key `<messageId>_<lang>` never cleared | Clear the entry on edit | Test | "edited message text gets a fresh translation" fails | Still open |

## Low

| ID | Area | Problem | Root cause | Suggested fix | Found by | Run 2 proof | Status |
|---|---|---|---|---|---|---|---|
| BUG-CS-10 | Forward list | Pinned-first order lost when `isPinned` is `1` / `"true"` | `ForwardMessageModel.dart:158` | Parse to bool | Test | "isPinned sent as 1 / "true" still sorts the chat as pinned" fails | Still open |
| BUG-CS-11 | Message Info | Attendance message shows raw text in Info | No attendance case in the preview switch | Use `MessagePreviewBuilder` | Test | "attendance message never shows raw JSON" fails | Still open |
| BUG-CS-12 | Message Info | Voice / media message shows the raw file path in Info | Same switch | Use `MessagePreviewBuilder` | Test | "voice message never shows the raw file path" fails | Still open |
| BUG-CS-14 | Message Info | Tap ripple on a member row is invisible (debug assert) | White `Container` between the sheet's Material and the ListTiles | Use `Material` / `Ink` | Test | "member row renders without the ListTile ink assertion" fails | Still open |
| BUG-CS-17 | Language | "Delivered", "Not delivered yet", "Sent:" are always English (private Info) | Hard-coded in `MessageInfoSheet.dart` | Move to l10n | Test | "sheet labels follow the app language (Hindi)" fails | Still open |
| BUG-TS-02 | Translate | "नमस्ते, दोस्त" gives a double space | Greeting regex | Trim the following space | Test | "greeting rewrite keeps a single space after punctuation" fails | Still open |

---

## Test-suite issues (not app bugs)

| ID | Test | Problem | Action in Run 2 | Status |
|---|---|---|---|---|
| T-01 | `test/chat_list_controller_realtime_test.dart` "pin / archive while offline is rolled back" | Expected the rollback at once; the app rolls back after the API fails (doc §5.2) | Rewritten: checks the instant change, then the rollback after the failed call | Fixed (passes) |
| T-02 | `test/chat_list_logic_test.dart` "no ids: falls back to a strictly newer time" | Old rule | Rewritten to the F-1.1.5 anti-shuffle rule (same text = not new; different text = new unless > 5 s older) | Fixed (passes) |
| T-03 | `test/chat_list_controller_realtime_test.dart` "archived server push in any order is shown sorted and stays stable" | The **second** assertion failed. Not a test problem: real app difference → **BUG-CL-09** | Split: "shown sorted" passes; "seen update keeps the archived order" kept with `skip: 'BUG-CL-09'`. Also waits for the controller's initial loads in `setUp`, like the QA test | Closed → BUG-CL-09 |
| T-04 | `test/chat_qa/status_section_widget_test.dart` | Flaky in the full suite in Run 1 | `setUp` now resets GetX first and fixes the locale to English | Fixed — see the 3-run flaky table in `unit_testing/unit_test_report.md` |
| T-05 | `test/typing_indicator_test.dart` | Copied the logic; tested no app code | Rewritten against the real `ChatTypingTracker` and the real `ChatListController` typing handlers (11 tests). Also removes 2 analyzer infos (`fake_async`, `clock`) | Fixed (passes) |
| T-06 | `test/last_seen_formatter_test.dart` | Ran only on an IST machine | New zone-independent test builds the UTC instant from the machine's own zone; the IST example stays as an extra | Fixed (passes on any zone) |
| T-07 (new) | `test/chat_qa/group_open_during_build_test.dart` | Set `HttpOverrides.global = null` (removes flutter_test's HTTP mock) and opens `GroupMessageController`, whose `initializeGroupChat()` calls the API host — the **production** constant `ConstRes.aBaseUrl`. Proven by GUARD-01 in `group_mark_seen_test.dart` (host `89.116.23.2` requested). Whether a request finished inside `testWidgets` was not proven | Guard added: only loopback allowed, every other host goes to a dead proxy | Fixed |
| T-08 (new, tooling) | Working tree | After `flutter pub get` in this session the 20 generated `lib/l10n/app_localizations*.dart` files (tracked in git) were missing from disk → 78 analyzer errors. Cause not proven (pub get or a parallel process) | Regenerated with `flutter gen-l10n` from the ARB files → back to the session-start state (same `M` files) | Watch: run `flutter gen-l10n` after `pub get` if it happens again |
