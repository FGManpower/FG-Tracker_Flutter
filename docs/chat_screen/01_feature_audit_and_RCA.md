# Chat Screen (private + group): Feature Audit and Root Cause Analysis

Branch: `46Solution` · Date: 2026-11-03 · Scope: private chat (`Chat_Screen.dart` + `MessageController`) and group chat (`GroupChatScreen.dart` + `GroupMessageController`), Android and iOS.

## How to read this report

- **Evidence: code** means the cause is visible in the Flutter source at the cited line, so it is certain on the Flutter side.
- **Evidence: needs live capture** means the code allows the bug, but confirming it needs real API or socket payloads from two logged-in users. No devices or test accounts were available on the development machine, so **no live traffic was captured** for this report. Section 5 has the capture procedure. Run it and paste the payloads under the matching issue before closing it.
- Feature statuses come from reading the code, not from running the app. "Working (code)" means the code path is complete and correct as written.
- Line numbers refer to the code **before** this fix unless they say "now".

---

## 1. Feature inventory

Sockets:
- Private chat uses `/privateChat`, created in `Socket_Message_Services.dart:739`.
- Group chat uses `/chat`, created at `:109`.

Shared rules for both chat types now live in `lib/app/modules/Messages/Controller/chat_screen_logic.dart`.

| Feature | P/G | API / socket event | Permissions | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| Load history on open | P | `GET /private-chat/:chatId/messages?page&limit` (`GetMessageRepo.dart:32`). `chatId` comes from route args or socket `join` → `joined {chatId}` (`SMS:845`, `:778`) | – | **Fixed** (was Broken from 2 entry points) | **Fixed** | See Issue 1 |
| Load history on open | G | `GET /getGroupMessageHistory?groupId&page&limit` (`GetMessageRepo.dart:44`) | – | **Fixed** | **Fixed** | See Issue 1 |
| Older messages (pagination) | P/G | Same endpoints, `page=N`, `limit=20` (now) | – | **Fixed** | **Fixed** | See Issue 3 |
| Send/receive text | P | emit `send_message` (`SMS:884`); listen `receive_message` + 4 forward events | – | Partial (code) | Partial (code) | Offline sends are dropped and the draft is still cleared (audit #A1) |
| Send/receive text | G | emit `send_group_message` (`SMS:391`); listen `receive_group_message`, `group_forward_message` | – | Working (code) | Working (code) | Buffered by socket.io while offline. No pending state |
| Image / bulk images / mixed media | P/G | `POST /uploadChatImage`, then `messageType image` / `media` | none (Photo Picker / PHPicker) | Working (code) | Working (code) | If every upload fails, the caption is cleared anyway |
| Video | P/G | `POST /uploadVideo`; content `url‖thumb‖duration` | none | Working (code) | Working (code) | |
| Document | P/G | `POST /uploadDocument` | none (SAF / UIDocumentPicker) | Partial (code) | Partial (code) | `result.originalName!` throws if null (`MC:1387`, `GC:1148`) |
| Voice note | P/G | `POST /uploadAudio` | Microphone | Working (code) | Working (code) | Permission handled in `voice_input_sheet.dart` |
| Camera capture | P/G | `Routes.cameraScreen` | Camera + Microphone | Partial (code) | Partial (code) | `enableAudio:true`: if the mic is denied, photos fail too. Endless spinner on failure, no Settings link (audit #A12) |
| Gallery pick | P/G | `pickMultipleMedia` (`file_services.dart:84`) | none | Working (code) | Working (code) | |
| Location share | P/G | `messageType location` | Location (when in use) | Partial (code) | Partial (code) | `deniedForever` unhandled; `Get.back()` only closes the snackbar (audit #A13) |
| Contact share | P/G | `messageType contact` | Contacts | Partial (code) | Partial (code) | No Settings path when denied (audit #A13) |
| Contact bubble "Call" | P/G | `canLaunchUrl(tel:)` | – | **Broken (code)** | Working (code) | Manifest `<queries>` has no `tel` entry (audit #A14) |
| Poll | G | – | – | Absent | Absent | The only poll is the Attendance poll |
| Attendance | G | `POST /groups/:id/attendance`; vote, close; `attendance:*` events | Location / camera (selfie) | Working (code) | Working (code) | Delete removed, see Issue 2 |
| Reply (incl. reply-jump) | P/G | `replyId` etc. in the send payload | – | **Fixed** | **Fixed** | Jumping to an unloaded original now pages back, or shows "Message not available" |
| Forward | P/G | `POST /forward/message` + socket `forward_message` | – | Partial (code) | Partial (code) | REST and socket both fire, so duplicates are possible (backend check). Single forward into the same chat type doesn't open the target (audit #A2) |
| Copy | P/G | Clipboard | – | Working (code) | Working (code) | Text only |
| Delete for me / everyone | P/G | emit `delete_message {messageId,userId,deleteType,otherUserId}`; listen `message_deleted` | – | Partial (code) | Partial (code) | The `for_me` handler doesn't check who deleted (audit #B1). Private delete-for-everyone keeps images and pin (audit #A9) |
| Edit | P/G | `editMessage` / `messageEdited` | – | Partial (code) | Partial (code) | Private handler matches on `id`, group on `messageId` (audit #A7) |
| Reactions, Star | – | – | – | Absent | Absent | Not implemented; out of scope (no new features) |
| Pin | P/G | `pin_message` / `unpin_message`; `message_pinned` / `message_unpinned` | – | Partial (code) | Partial (code) | Private unpin needs `senderId` (audit #A8) |
| Translation | P/G | Unofficial Google endpoints | – | Partial (code) | Partial (code) | Keyless and can be rate-limited |
| Mentions | G | Client only | – | Partial (code) | Partial (code) | Multi-word names can't be matched |
| Links | P/G | Linkify + `launchUrl` | – | Working (code) | Working (code) | No rich preview (none was built) |
| Sent / delivered / seen ticks | P | `mark_delivered` / `messages_delivered`; `mark_seen` / `messages_seen_update` | – | **Fixed** | **Fixed** | Seen count was +1 per event; a string `seenCount` crashed the tick. Receipts were sent for my own messages and while in background |
| Seen ticks | G | `mark_seen` / `messages_seen_update` | – | **Fixed** | **Fixed** | See Issue 5 |
| Message Info / "Seen by" | P/G | Local data (`MessageInfoSheet.dart`) | – | **Fixed** | **Fixed** | See Issue 5. Shows no seen *time*: the API sends none (backend #3) |
| Typing | P/G | `typing` / `stop_typing`, `group_typing` / `group_stop_typing` | – | Working (code) | Working (code) | Bubble UI from the previous change |
| Online / last seen | P | From the history API only | – | Partial (code) | Partial (code) | Live presence listener is commented out (`MC:565-626`) |
| Group info | G | `/chat/profile-details?type=group`, `/getMembers` | – | Working (code) | Working (code) | |
| Block / unblock | P | `POST /blockUser`, `/unblockUser` | – | Partial (code) | Partial (code) | State only refreshes on history load |
| Search in chat | P/G | Local | – | Partial (code) | Partial (code) | Only searches loaded pages |
| Download / open files | P/G | Dio + `OpenFile` | none | Partial (code) | Partial (code) | `DocumentViewerController` always sets `fileExists=false` (audit #A19) |
| Media missing card | P/G | HEAD check (`media_availability_service.dart`) | – | Working (code) | Working (code) | Previous change |
| Open chat from notification | P/G | `NotificationServices.handleMessage` (`NS:819-858`) | Notifications | **Broken (code)** in 2 cases | Partial (code) | Local-notification taps with `groupId` open Walkie (`NS:193`, `NS:670`). A tap while another private chat is open is ignored (audit #A2, #A3) |
| Mark read on open | P/G | `mark_seen`, `mark_private_chat_read` | – | Working (code) | Working (code) | |
| Socket reconnect | P | `onConnect` → `join` → `joined` | – | **Fixed** (backfill) | **Fixed** | Missed messages are now fetched on `joined`. Wrong-receiver re-join still open (audit #A5) |
| Socket reconnect | G | `onConnect` → join + `mark_seen` | – | **Fixed** (backfill) | **Fixed** | Through the existing `listenAttendanceEvents(onReconnect)` hook, so no new listener |
| App resume | P/G | Lifecycle observer | – | **Fixed** | **Fixed** | Now fetches newer messages on resume |
| Keyboard | P/G | – | – | **Fixed** (gaps) | **Fixed** (gaps) | See Issue 4 |

## 2. Permissions (chat features)

| Permission | Android manifest | iOS Info.plist | Requested when | Denied | Permanently denied | Status |
|---|---|---|---|---|---|---|
| Camera | `CAMERA` present (`:28`). `uses-feature camera` lacks `required="false"` | `NSCameraUsageDescription` present | Implicitly by `CameraController.initialize()` when the camera screen opens | Silent; endless spinner | No Settings path | **Gap** (audit #A12): waiting for your approval |
| Microphone | `RECORD_AUDIO` present | `NSMicrophoneUsageDescription` present | Tap mic (`voice_input_sheet.dart:32`) | Explanation dialog | `openAppSettings()` | OK. After returning from Settings it doesn't re-check (`:101`) |
| Photos / gallery | No `READ_MEDIA_*`, which is correct | `NSPhotoLibrary(Add)UsageDescription` present | Never (Photo Picker / PHPicker need none) | n/a | n/a | OK. Android 14 "Select photos" and iOS "Limited" don't apply |
| Files / storage | No storage permission, which is correct; `requestLegacyExternalStorage` is a no-op on SDK 36 | – | Never (SAF / UIDocumentPicker; downloads go to app dirs) | n/a | n/a | OK |
| Location (share) | FINE / COARSE / BACKGROUND present | `NSLocationWhenInUseUsageDescription` present | Opening the location picker | `Get.back()` closes the snackbar only | Not handled | **Gap** (audit #A13): waiting for your approval |
| Contacts | `READ_CONTACTS` present | `NSContactsUsageDescription` present | Opening the contact picker | Snackbar; picker stays open | No Settings path | **Gap** (audit #A13): waiting for your approval |
| Notifications | `POST_NOTIFICATIONS` | – | Compulsory permission gate (untouched) | Gate UI | Gate `openAppSettings()` | OK |

Build settings:
- compileSdk and targetSdk are 36, so edge-to-edge is enforced on Android 15+.
- `windowSoftInputMode="adjustResize"` (`AndroidManifest.xml:72`).
- Flutter 3.47.2.

## 3. Root cause per issue

### Issue 1: Old chat history doesn't show when the chat opens

| | |
|---|---|
| Symptom | A chat that has history opens as "No messages here yet", or as an empty screen. |
| Root cause A (main) | `MessageController._initializeChat` (`:470-474`) decided private vs group from `type == 'chatScreen'`, `chatType == 'private'` or `groupId == 0`. Two entry points open the private route with `"type": ""` and a **real group id**: **Group → Members** (`MemberScreen.dart:432`, `:709`) and **Track → Search Members** (`Search_Members.dart:197`, `groupId: data.groupId`). `isPrivateChat` became false, and the group branch was an empty `else {}` (`:967`). So there was no history call, no socket join and no listeners, and the chat was always empty. |
| Root cause B | `GetMessage.fromJson` assigns raw JSON into typed fields: `int? id` (`:351`), `bool? isCreator` (`:35`), `int? pinnedMessageId` (`:36`), every `MessagePagination` field (`:174-179`), and `BlockStatus` (`:142-144`). A string id (`"123"`), a `0/1` boolean or `"1"` for `hasNextPage` throws a `TypeError`. The exception is caught in `getPrivateMessageHistory` / `getGroupMessages` and the list is cleared. The **whole** history disappears because of one field. |
| Root cause C | On any load failure, or when the socket `joined` never arrives (entry points without `chatId`, `:506-510`), the list showed the **empty state** ("No messages here yet" — `ChatList.dart:44`). That looks identical to a chat with no history, and there was no retry. |
| Root cause D | `getPrivateMessageHistory` and `getGroupMessages` **cleared** the list before inserting the API page (`MC:1625`, `GC:1274`). A socket message that arrived before the response was wiped. |
| Checked, not the cause | Date parsing uses `DateTime.tryParse`, which is null-safe. Private and group use different endpoints, but both now share the same merge path. The socket doesn't reset state on its own; only the history call did (D). |
| Entry points checked | Chat list, Archived, New chat, Notification list (all pass `chatId`). Status, Tracking, DialogBox (pass `chatId` when known). BottomSheetUi, NotificationServices push tap, UserProfileScreen, Forward (no `chatId`, so the socket join is used). MemberScreen and Search_Members hit cause A. Group: chat list, groups list, Walkie, calls, contact profile (all pass `groupId`). |
| Evidence | Code: A, C and D are certain. B is certain in code; **whether the live API actually sends string ids or 0/1 booleans needs live capture**. |
| Side | Flutter. Backend item #2 (a REST way to resolve the chat id) makes the socket-less path robust. Backend #5 (stable types) prevents B at the source. |
| Fix done | (A) The route is always private unless `chatType == 'group'`. (B) Tolerant parsing (`parseIntOrNull`, `_parseBool`) and a per-row try/catch. A row that still fails becomes an "unsupported message" placeholder, so the rest renders. (C) A new "Couldn't load messages · Retry" state; the join timeout shows it after 10 s instead of the empty state. (D) First load merges and dedupes by id instead of replacing. |

### Issue 2: Delete on Attendance messages

| | |
|---|---|
| Symptom | Attendance messages could be deleted from the chat. |
| Root cause | Two paths. (1) The long-press menu added "Delete for Everyone" (sender) and "Delete for Me" (everyone) for **every** message type (`ChatItem.dart:1371-1413` private, `:2855-2897` group). (2) The card's own admin menu had "Delete attendance" (`attendance_chat_card.dart:649-665`), which calls `DELETE /attendance/:pollId`. Swipe is reply-only, and there is no multi-select in chat (checked). |
| Evidence | Code. |
| Side | Flutter, plus backend #4 (the server must refuse it too). |
| Fix done | Menu options now come from `ChatScreenRules.menuOptions()`: no delete options for `attendance` / `attendance_poll`, for any user, in either chat type. Other types are unchanged (unit tested). The card menu now only offers "Close attendance" and is hidden once the poll is closed. A poll deleted elsewhere still shows the "deleted" card. |

### Issue 3: Pagination

| | |
|---|---|
| Symptom | Scrolling up doesn't load more, keeps reloading the same messages, shows duplicates, or jumps. |
| Root cause | (1) **Group:** when a page contained only messages already loaded, `groupCurrentPage` was **not advanced** (`GC:1953` sits inside `if (newOlder.isNotEmpty)`). Once a few new messages had shifted the offsets, the same page was fetched forever and paging got stuck. (2) **Private:** older pages were inserted with **no dedupe** (`MC:2145`), so offset shifts produced duplicate bubbles. (3) The APIs are page-number based (`page=&limit=`), not cursor based, so offsets move whenever messages are added or deleted. (4) There was no loader at the top. (5) Scroll was restored with `jumpTo(index)` and no alignment, so the view jumped by the partial item offset. (6) No catch-up after reconnect or resume. (7) A reply-jump to an unloaded message did nothing. |
| Evidence | Code. |
| Side | Both. Flutter is fixed. A true cursor needs backend #1; until then, deletions can still skip a message across a page boundary. |
| Fix done | A shared `HistoryPager`: one call at a time, the page **always** advances on success, stops on `hasNextPage=false` or an empty page, and backs off 3 s after a failure. Every page goes through `ChatScreenRules.merge` (dedupe by id, stable time order, so date separators stay right). The view is restored with `jumpTo(index + prepended, alignment: leadingEdge)`, so it doesn't move. Page size is 20. There is a top loader. Reconnect and resume fetch newer pages until they overlap the loaded ones (max 5). The reply-jump loads up to 10 older pages, then shows "Message not available". The existing "New messages" button / unread-below counter is reused for messages that arrive while scrolled up. |
| Deviation | The brief suggests a reversed ListView. The screens use `ScrollablePositionedList` (needed by search, pinned and reply jumps). Rewriting every index-based jump for a reversed list is a large, risky change. The anchor restore gives the same "no jump" result. |

### Issue 4: Keyboard handling (Android + iOS)

| | |
|---|---|
| Checked and already correct | `windowSoftInputMode="adjustResize"`. `Scaffold(resizeToAvoidBottomInset: true)` with no outer scroll view. The input bar has its own `SafeArea` (bottom), so the home indicator and nav bar are respected under Android 15 edge-to-edge (Flutter 3.47 applies the insets). Drag on the list dismisses the keyboard (UserScrollNotification) and so does tapping the list. `maxLines: 5` / `minLines: 1`. Send is hidden for whitespace-only text (`trim()`). The controller never unfocuses after send, so focus stays. Keyboard-open auto-scrolls only when the user was at the bottom (`didChangeMetrics`). |
| Root cause found | The emoji panel had a fixed `300.h` height (`ChatInputArea.dart:692-700`). On small phones or with a large font scale it pushed the list and input past the screen (overflow risk). Swapping keyboard ↔ emoji made the screen jump, because the two heights differ. |
| Not reproducible in this app | Landscape and Android split-screen: the app is locked to portrait (`global.dart:12`). **iPad** allows all orientations in Info.plist, and iPad Split View ignores the lock, so the iPad sizes are covered by the layout tests and manual cases. |
| Evidence | Code. Widget tests simulate a 300 px keyboard on 360×640 and 430×932, a home indicator, and a 1.6× font scale. All pass with no overflow. |
| Side | Flutter. |
| Fix done | The emoji panel height is now the last real keyboard height (read from the `View`, because the Scaffold strips the inset from the body), clamped to 180 px .. 40% of the screen (`ChatScreenRules.emojiPanelHeight`). |

### Issue 5: The logged-in user appears in "Seen by"

| | |
|---|---|
| Symptom | Message Info → Seen lists me, and the count includes me. |
| Root cause | (1) On open, the group screen emits `mark_seen` for me (`GC:207`). The server answers with `messages_seen_update {userId: me}`, and the listener (`GC:210-229`) added that `userId` to the `seenBy` of **every** loaded message, including my own, with no check on who the reader was. (2) `MessageInfoSheet._getSeenMembers` / `_getSeenCount` (`:115-149`) never excluded me or the sender. (3) Private: every `messages_seen_update` did `seenCount + 1` on any listed message, including the peer's messages, so the count grew past 1. |
| Evidence | Code for (1)–(3). **Whether the API's `seenBy` array itself includes the sender needs live capture** (the Flutter filter covers it either way). |
| Side | Flutter is fixed. Backend #3 (send the reader id and never include the sender) removes the guesswork. |
| Fix done | `ChatScreenRules.seenByOthers()` filters out me and the sender by **user id**. The count is "Seen (X of Y)", where Y = group members minus the sender. Group seen updates ignore my own echo and never record a reader on their own message. Private seen updates only touch **my** messages, set the count to 1 (not +1), and ignore a reader id equal to mine. Opening a chat no longer sends delivered/seen for my own messages, and "seen" is no longer sent while the app is in the background (it's sent on resume). |

## 4. Other bugs found in the audit

**Fixed (Flutter-only, low risk, inside this work):**

| # | Bug | Fix |
|---|---|---|
| F1 | `(message.seenCount ?? 0) > 0` on a dynamic value throws if `seenCount` is a string (`ChatItem.dart:514`, `:1914`) | `int.tryParse` helper |
| F2 | Private receipts were sent for my own messages, and "seen" was sent while in background (`MC:708`, `:716`) | Peer messages only; foreground only |
| F3 | Private seen callback indexed `data[...]` without an `is Map` check | Guard added |
| F4 | The hidden pagination spinner would animate forever (found by the new widget test) | Not built when hidden |

**Fixed in the second pass (approved 2026-11-03):**

| # | Bug | Where (before) | Fix |
|---|---|---|---|
| A1 | Offline private send dropped silently; draft and attachments cleared | `SMS:864`, `MC:1264` | Every private send path checks the socket first. When offline: toast "You're offline. Message not sent." and the draft stays. If every image upload fails, the images and caption stay (private and group) |
| A2 | Opening chat X from chat Y (forward, push tap) ignored by `preventDuplicates`; untagged `lazyPut` would reuse Y's controller | `ForwardMessageController.dart:371`, `NS:837` | New `ChatNavigation.openPrivateChat` / `openGroupChat`: same chat → stay; other chat → close the current chat screen, let GetX dispose it, then open |
| A3 | Group-chat local-notification taps opened Walkie (any `groupId` counted as Walkie). `onMessageOpenedApp` was registered twice, so each background tap was handled twice | `NS:193`, `NS:670`, `NS:560` + `NS:780` | `isWalkieNotificationPayload()`: Walkie only when screen_name is Walkie, or there's no screen_name at all (legacy). One registration (in `initialized()`); the launch message is handled once per run. `int.parse` on the notification id / groupId replaced with `tryParse` |
| A5 | Reused private socket re-joined the **first** chat after a network blip | `SMS:755-771` | Reconnect joins the currently open chat (or none after leave) |
| A7 | Private live edit matched `id` only and replaced the whole message (ticks reset) | `MC:907-924` | Shared `ChatScreenRules.applyEdit` (accepts `messageId`/`id`) updates in place; used by private and group |
| A8 | Private unpin ignored when the payload has no `senderId` | `MC:1017` | Same null-safe rule as pin |
| A9 | Private delete-for-everyone kept images, caption and the pin banner | `MC:959` | Shared `markDeletedForEveryone` + pin banner cleared |
| A10 | `private_chat_cleared` wiped the open chat without checking ids | `MC:2022` | Ignored when the id differs from the open chat, unless this screen just asked for the clear |
| A12 | Camera: a denied mic broke photos; endless spinner; no Settings | `CameraControllerX.dart:95`, `cameraScreen.dart:26` | Mic denied → retry without audio. Camera denied → reason + Try again + Open Settings |
| A13 | Location `deniedForever` unhandled; `Get.back()` after a snackbar left the picker stuck (location, contacts) | `location_picker_controller.dart`, `contact_picker_controller.dart` | In-page reason + Try again + Open Settings; service-off handled |
| A14 | Android contact "Call" did nothing | `AndroidManifest.xml`, `ContactBubbleWidget.dart` | `<queries>` DIAL/tel entry; phone number sanitised |
| A15 | Private chat blocked the iOS swipe-back | `Chat_Screen.dart:51` | `PopScope(canPop: true)`; leave/cleanup runs once after any pop |
| A17/A18 | Chat screens overwrote each other's edit/delete/pin listeners (registered on both sockets); group `onClose` left listeners attached | `SMS:1416-1610`, `GC:1858` | Listeners scoped per socket (`ChatSocketScope`). Owner claim/release: a closing screen removes only listeners it still owns |
| A19 | Document viewer always set `fileExists=false`; extension broke on URLs with a query string | `DocumentViewerController.dart:57-75` | Correct flag; extension from the URL path or document name; clear message if the download failed |
| A20 | `originalName!` / audio `filename!` null assertions | `MC:1387`, `GC:1087`, `GC:1148` | Fallback to the local file name; audio send skipped with a toast |
| A22 | Lost-data recovery treated every file as a video | `MC:298-305` | Uses the picker's type (or extension); images go back to the image tray |
| — | Group socket reconnect sent `mark_seen` while the app was in the background | `SMS:150` | Only in the foreground (the screen sends it on resume) |
| B1 (Flutter half) | A `for_me` delete event naming another user removed my copy | `MC:956`, `GC:390` | Ignored when the event's `userId` isn't me. The backend should still send it only to the requester |

**Checked, no change needed:**
- A16: `Get.put(GroupController())` returns the existing instance when one is registered, so nothing is duplicated.
- Voice-note mic permission: the audit said it returns `true` after Settings without re-checking. It does re-check: the dialog only returns `true` after re-reading the status on resume (`voice_input_sheet.dart:164-171`).

**Not done (needs a product decision or new feature):**
- Video "download" saves to the app folder (`VideoController.dart:146`). Saving to the gallery needs a new plugin and a photo-library write permission, i.e. a new feature.

**Needs backend** (see `02_backend_requirements.md`):
- B1: `for_me` delete may be broadcast to the other user (Flutter now ignores it when the event names another user).
- B2: forward is sent over REST and socket, so it may duplicate.
- B3: no send ack.
- B4: presence and block state are not live.
## 5. Live capture procedure (to close the "needs live capture" items)

1. Run a debug build on two devices with users A and B (see `03_manual_test_cases_android_ios.md`, Setup).
2. The controllers already log with `log()`. Filter `flutter logs` for these lines:
   - `HISTORY DEBUG`, to see the parsed result of the history API.
   - `RAW SOCKET DATA`, `JOINED RAW DATA`, `GROUP RECEIVE EVENT`, `GROUP SEEN UPDATE`, `RECEIVED private typing`.
   - `/chat <=` (RT_DEBUG).
3. For the raw JSON, temporarily add `debugPrint(jsonEncode(response))` in `MessageRepo.privateChatHistory` / `groupMessageHistory`.
   - **Never log the auth header or token.**
   - Remove the line afterwards.
4. Capture these in order:
   1. A opens the chat with B, from the chat list and from Group → Members.
   2. B sends a text and an image.
   3. A reads them.
   4. A opens Message Info on their own message.
   5. A deletes a message for everyone.
5. Paste the payloads under Issues 1 and 5, and under audit item A7.
