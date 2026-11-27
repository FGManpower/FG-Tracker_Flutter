# FG Tracker Chat Module: Flutter (Frontend) Implementation Guide

> **Document version:** `F-1.3.1` · **Date:** 2026-11-26 · **Branch:** `46Solution`
> **Pairs with:** backend `FLUTTER_CHAT_INTEGRATION_GUIDE.md` **v2.8.0**
> **Scope:** chat module only (private chat, group chat, chat notifications, forwarding, long-press options, chat list, group membership: create / join / add / remove / exit and their success sheets).
> **Owner:** Flutter team. **Readers:** Flutter + Node.js developers.

This is the **frontend half** of the chat contract. The backend guide says what the server sends. This guide says what the app sends, what it listens to, which fields it reads and the rules it applies. Keep both in step.

### How to maintain this document
1. **Any change to a chat event, endpoint, payload field or rule → update this file in the same PR.** Bump the version (`F-1.0.1`, …) and add a line to the change log (§9).
2. **Backend changes a payload or event** → backend updates their guide; Flutter updates the matching section here and §7 (Open items).
3. **New open question for the other side** → add it to §7 with an owner and status. Don't leave it only in chat messages.
4. Event and endpoint names here are copied from the code. Never rename one in only one place.

---

## 0. Architecture overview

### 0.0 Module Overview & UI Flow
```
                  ┌───────────────────────────────────────────────┐
                  │              CHAT LIST SCREEN                 │
                  │   (GET /api/chat-list & socket updates)       │
                  └───────────────┬───────────────┬───────────────┘
                                  │               │
                     Tap Private  │               │ Tap Group
                     Chat Item    ▼               ▼ Chat Item
                 ┌────────────────────┐       ┌────────────────────┐
                 │ 1-ON-1 CHAT SCREEN │       │ GROUP CHAT SCREEN  │
                 │  - Socket:         │       │  - Socket:         │
                 │    /privateChat    │       │    /chat           │
                 │  - Messages REST:  │       │  - Messages REST:  │
                 │    /api/private-   │       │    /api/getGroup-  │
                 │    chat/:id/msgs   │       │    MessageHistory  │
                 └─────────┬──────────┘       └─────────┬──────────┘
                           │                            │
                           ▼                            ▼
                 ┌─────────────────────────────────────────────────┐
                 │             CHAT PROFILE DETAILS SCREEN         │
                 │       (GET /api/chat/profile-details)           │
                 │  - Media, Docs, Links, Group Members list       │
                 │  - Mute, Pin, Clear Chat, Archive actions       │
                 └─────────────────────────────────────────────────┘
```

### 0.0.1 WhatsApp-Style Management Operations
| Action | Recommended REST Endpoint | Socket Alternative | Client UI Behavior |
|---|---|---|---|
| **Pin Chat** | `POST /api/pin` `{ "chatId": 18, "isPinned": true }` | `pin_chat` | Moves conversation to top with pin icon. |
| **Mute Chat** | `POST /api/mute` `{ "chatId": 18, "isMuted": true }` | `mute_chat` | Suppresses FCM notifications for this chat. |
| **Archive Chat** | `POST /api/archive` `{ "chatId": 18, "isArchived": true }` | `archive_chat` | Moves conversation to Archived Chats screen. |
| **Clear Chat** | `POST /api/delete` `{ "chatId": 18, "chatType": "group" }` | `clear_group_chat` | **Explicit user action only!** Erases history before current moment for caller only. |
| **Delete for Me** | `POST /api/delete-message` `{ "messageId": 1420, "deleteType": "for_me" }` | `delete_message` | Message removed from caller's screen only. |

### 0.1 Sockets (Socket.IO, `socket_io_client` 3.1.x)
| Connection | Namespace | Created by | Used for |
|---|---|---|---|
| `_socket` | `/chat` | `GroupMessageController.onInit` → `SocketMessageService.init` | Group chat, attendance, group typing, group status, chat-list events |
| `_privateChatSocket` | `/privateChat` | `MessageController` → `initPrivateChat` | One open private chat (join / send / receive / ticks / typing) |
| `_privateChatListSocket` | `/privateChat` | `ChatListController.onInit` → `initPrivateChatListSocket` | Chat list, archive, list typing, list actions |

- **Auth:** `auth` is sent as a **callback**, so the token stored at that moment is read on **every** connect and reconnect: `{ token, userId }` for `/privateChat`, `{ token, attendanceSupported: "1" }` for `/chat`. Query: `{ attendanceSupported: "1" }` on `/chat`.
- **`connect_error` with `TOKEN_EXPIRED`** (backend v2.8.0: no refresh endpoint, 90-day token):
  - first rejection → one retry with the stored token after 3 s (a token renewed by a fresh login reconnects);
  - rejected again within 60 s → `LogoutUser().handleForceLogout("Your session has expired. Please log in again.")`, the same logout the HTTP 401 handler uses. It is ignored when no one is logged in, when already on the login / OTP screens, and during the new-login grace period.
- **Listener ownership:**
  - Chat screens register edit / delete / pin listeners **scoped to their own socket** (`ChatSocketScope.private` / `.group`).
  - A closing screen removes only the listeners it still owns (`claim…Events` / `release…Events`), so screens never steal each other's events.
- **Reconnect:** the private socket re-joins the chat that is **currently open**, not the first one ever opened. On reconnect, the `/chat` socket re-joins the active group, but only sends `mark_seen` while the app is in the foreground.

### 0.2 Key files
| Area | Files |
|---|---|
| Socket service | `lib/app/Data/Services/Socket/Socket_Message_Services.dart` |
| Private chat | `Messages/Controller/MessageController.dart`, `Messages/Views/Chat_Screen.dart` |
| Group chat | `Messages/Controller/GroupChatController.dart`, `Messages/Views/Group/GroupChatScreen.dart` |
| Message bubbles / list | `Messages/widgets/ChatItem.dart`, `ChatList.dart`, `ChatInputArea.dart`, `MessageContextMenu.dart` |
| Shared chat rules | `Messages/Controller/chat_screen_logic.dart` (merge, paging, menu, seen-by, edit/delete) |
| Chat screen cache (Hive) | `Data/Services/chat_message_cache.dart` (`ChatMessageCache`, `ChatOpenPerf`), `Messages/widgets/chat_history_widgets.dart` (`ChatRefreshFailedBar`) — §12 |
| Chat list | `Messages/Controller/chat_list_controller.dart`, `chat_list_logic.dart`, `Views/chatlist_screen.dart`, `Views/ArchivedChatsScreen.dart` |
| Message model | `Model/GetMessage.dart` (`MessageData`), `Model/PrivateChatModel.dart` (list row) |
| Previews (list, reply, pin) | `Core/util/message_preview_builder.dart` |
| Navigation into a chat | `Core/util/chat_navigation.dart` |
| Notifications | `Data/Services/NotificationServices.dart` |
| Forwarding | `Messages/Controller/ForwardMessageController.dart`, `Model/ForwardMessageModel.dart` |
| Attendance in chat | `Attendance/controller/attendance_controller.dart`, `Attendance/widgets/attendance_chat_card.dart` |
| Open-chat tracking | `Data/Services/active_chat_tracker.dart` |
| Media availability | `Data/Services/media_availability_service.dart`, `Messages/widgets/missing_media_widget.dart` |

### 0.3 Global rules (apply everywhere)
- **Chat key:** `private_<id>` / `group_<groupId>`. A private chat and a group with the **same number** are never treated as the same chat (list rows, typing, archive, selection, forward).
- **Tolerant parsing:**
  - `MessageData.fromJson` accepts string or int ids, `0/1/"true"` booleans, lists sent as JSON strings, and nested `message` / `data` / `forwardedMessage` wrappers.
  - A row that still fails becomes an **"unsupported message"** placeholder; the rest of the history renders.
- **Duplicates:** a message is merged by `id` (and by `clientMessageId` in groups). The same event twice never creates two bubbles or counts twice.
- **Times:** parsed with `DateTime.tryParse`; send UTC ISO-8601 (`…Z`).
- **Media URLs:** a relative path is joined to `ConstRes.aImageBaseUrl` (`http://89.116.23.2:3000/`). An absolute `fgtracker.in` URL is used as sent (that domain has a dead DNS record; see §7, #12).

---

## 1. Private chat

### 1.1 Opening a chat
- **Entry points:** chat list, Archived, New chat, contact profile, Group → Members, Track → Search Members, notification tap, forward.
- **Route:** `Routes.chatScreen`, args `{ userData: MemberData, chatId?, type: "chatScreen", chatType: "private" }`. The screen is **always private** unless `chatType == "group"`.
- **Chat id:**
  - Uses `chatId` from the args when given. `ChatNavigation` fills it from the chat list when it is missing.
  - Otherwise: emit `join {userId, receiverId}` → wait for `joined {chatId}`.
  - No `joined` within 10 s → "Couldn't load messages · Retry".
- **Opening a chat from inside another chat** (forward, notification) → `ChatNavigation.openPrivateChat`:
  - the same chat stays open;
  - a different chat closes the current one, then opens the new one.

### 1.2 History and paging
- **Cached copy first (F-1.2.4, §12):**
  - On open the last 50 messages saved on the device (`private_<peerId>`) are shown at once, with no skeleton.
  - The API request below starts at the same time. It doesn't wait for the cache or the socket.
  - Times out after **10 s** (`ChatScreenRules.historyTimeout`).
- **`GET /private-chat/:chatId/messages?page=N&limit=20`**, newest first.
- First load **merges** with what is already shown, whether cached or received over the socket (dedupe by id, oldest-first order). An empty or failed response never removes cached messages.
- **API failed or timed out** (rules in §12.2.1, F-1.2.9):
  - nothing on screen → "Couldn't load messages" + Retry (as before);
  - cached messages on screen → they stay; only if the server really could not be reached twice (one quiet retry first) does a small **"Couldn't refresh · Retry"** bar appear **above** the messages (`ChatRefreshFailedBar`). Any later sync hides it by itself.
  - After 10 s the loader stops (soft timeout); a late answer is still applied.
- Older messages load at the top of the list:
  - **`before=<oldest message id shown>&limit=20`** (backend v2.8.0);
  - one request at a time;
  - stops at `pagination.hasMore:false` (or `hasNextPage:false`) or an empty batch;
  - the visible message keeps its position;
  - **Fallback:** if the server returns messages that aren't older than the cursor (it ignored `before`), that chat switches to `page=N` paging for the rest of the session.
- **Reconnect / app resume:**
  - `after=<newest message id shown>&limit=50`, repeated while `hasMore` (max 5 rounds);
  - if that fails or is ignored, pages 1–5 are re-read until they overlap what is shown.
- **Reply jump:** if the quoted message isn't loaded, up to 10 older pages load, then "Message not available".
- Load error with nothing shown → "Couldn't load messages" + Retry (never a false "No messages here yet").

### 1.3 Sending
- **Socket:** `send_message` on `/privateChat` via **`emitWithAck`**.
  ```json
  { "senderId": "42", "receiverId": "9", "messageType": "text|image|media|video|audio|document|location|contact",
    "content": "...", "images": ["uploads/..."], "videos": [{"videoUrl":"","thumbnail":"","duration":""}],
    "caption": "...", "replyId": 1530, "replyMessage": "...", "replyType": "image", "replySender": "Asha" }
  ```
- **Ack:**
  - `status:false` / `ok:false` → toast with the server's message (`BLOCKED`, `INVALID_DATA`, `SEND_FAILED`).
  - Success needs nothing; the message arrives via `receive_message`.
- **Offline:** the socket isn't connected → toast "You're offline. Message not sent." **The draft is kept.**
- **Uploads before sending:**

  | Type | Endpoint | Field | Value sent as `content` |
  |---|---|---|---|
  | Image / bulk | `POST /uploadChatImage` | `chatImage` | `images[]` (bulk = `messageType:"media"`) |
  | Voice / audio | `POST /uploadAudio` | `chatAudio` | file path |
  | Video | `POST /uploadVideo` | `chatVideo` + `thumbnail` | `"videoUrl\|\|thumbnail\|\|duration"` |
  | Document | `POST /uploadDocument` | `chatDocument` | `"path\|\|originalName"` |

  If every image upload fails, the images and caption stay in the composer.

### 1.4 Receiving
- **Listens on `/privateChat`:** `receive_message`, `forward_message`, `receive_forward_message`, `message_forwarded`, `forwarded_message`. Only messages for the open pair are accepted.
- **Same id arrives twice** → one bubble. The second event may **fill missing attachment fields** (images, video, audio URL); it never replaces content that is already there.
- **Audio location:** `audioUrl` → `audios[0].audioUrl` → `mediaUrls[0]` (audio only) → `content`.
- **Images fallback:** `images[]` → `mediaUrls[]` (image types only). **Video fallback:** `videoUrl` / `fileUrl`. **Document fallback:** `files[0]`.
- **Missing sender name** → filled with the contact's name.
- **Missing media:** each media URL is checked once with `HEAD`. A 403, 404 or 410 that persists for ~11 s shows **"Media is missing"**; offline never counts as missing.

### 1.5 Ticks (sent / delivered / seen)
| App emits | When |
|---|---|
| `mark_delivered {messageIds, userId, otherUserId}` | Each **peer** message received (never for own messages) |
| `mark_seen {chatId, userId, otherUserId}` | Chat open **and app in foreground** (sent on resume otherwise) |
| `mark_private_chat_read {userId, chatId}` | Debounced 400 ms while open, and on close |

| App listens | Effect |
|---|---|
| `messages_delivered {chatId, messageIds}` | Double grey tick |
| `messages_seen_update {chatId, messageIds, seenBy?}` | Purple tick, **only on my messages**, count capped at 1; my own read echo is ignored |

### 1.6 Typing, edit, delete, pin
- **Typing:**
  - Emits `typing` / `stop_typing {userId, receiverId, chatId}`, throttled 2.5 s; stops after 2.5 s idle.
  - Listens to `typing` / `stop_typing` and shows a **typing bubble**; auto-clears after 4 s.
- **Edit:**
  - Emits `editMessage`: for attachments (`audio`, `voice`, `image`, `video`, `document`, `file`), preserves the media URL in `content` and `mediaUrl` while placing the edited text in `caption`. For text messages, updates `content`.
  - Listens to **both** `messageEdited` and `message_edited`, keyed by `messageId` or `id`; text/caption is updated in place, while `audioUrl` and media content remain protected (ticks kept).
- **Delete:**
  - Emits `delete_message {messageId, userId, deleteType: "for_me|for_everyone", otherUserId}`.
  - `message_deleted` with `for_me` removes the bubble **only if `userId` is me**.
  - `for_everyone` → "This message was deleted": text, media, caption and reply cleared, pin banner removed.
- **Pin:** emits `pin_message` / `unpin_message`; listens to `message_pinned` / `message_unpinned`.
- **Clear chat:**
  - Emits `clear_private_chat {chatId}` and unpins any active pinned message (`unpin_message`).
  - Optimistically and upon `private_chat_cleared`, wipes `messageData`, clears `pinnedMessage.value` and hides `showPinnedBanner.value` immediately in real time.
- **Block:** `POST /blockUser`, `POST /unblockUser`. Block state comes from the history response (`blockStatus`).
- **Block in real time (F-1.1.8):** the open private chat swaps the input bar for the "blocked" banner without reopening the chat. Sources, all published on `SocketMessageService.blockStatusEvents`:
  - **`BLOCKED` send ack:** the contact blocked me → banner shows on the first rejected send (before, only a toast; the next sends failed silently until the chat was reopened).
  - **Backend events** on `/chat`, `/privateChat` and the chat-list socket: `user_blocked` / `user_unblocked` (also accepted: `block_status_changed`, `block_status_updated`, `blockStatusChanged` with `isBlocked` or `action`). Payload `{blockerId, blockedUserId}` (aliases `blockedBy`, `userId`, `blockedId`, `targetUserId`). **Needs backend support, item #25.**
  - **Resume and socket reconnect:** `blockStatus` is re-read from history (`page=1&limit=1`).
  - **Chat-list events:** a `chat_list_updated` / `conversation_updated` / `private_chat_updated` that names the open `chatId` triggers the same read at once (`SocketMessageService.privateChatTouched`).
  - **4 s check while the chat is open** (app in foreground only, one request at a time): the same `limit=1` read, so the person who gets blocked sees the banner within ~4 s without sending anything. Stop-gap until #25; remove it once `user_blocked` is pushed. The back / exit path (`onRoutePopped`) is not changed; the timers stop in `onClose` and skip once the chat is left.
  - Every event is applied at once and then confirmed with that same history read (debounced 400 ms), so duplicate events and two-sided blocks end in the server's state.
- **Old messages stay after a block (F-1.1.8, moved to Hive in F-1.2.4):**
  - The server may return an empty history for a blocked pair.
  - The device keeps the newest 50 messages of each chat in the encrypted Hive chat cache (§12): `ChatMessageCache`, box per user, key `private_<peerId>`. It is saved 1 s after each change from a snapshot, so leaving the chat never loses the last change.
  - The **30 most recently used chats** are kept.
  - Those messages are already on screen when the chat opens. If a block is in place and the server sends no messages, the copy read at open (`_historyOrCache`) is used.
  - Cleared by Clear chat and by logout.
  - The old SharedPreferences copy (`private_chat_cache_*`, `PrivateChatCache`) was imported once and deleted; `private_chat_cache.dart` is gone.
  - Fix on the server: #26.
- **Android and iOS:** the block logic is Dart only (socket events, timers); no new native code or platform channel. The chat cache uses Hive files (app documents folder) and the AES key in `flutter_secure_storage` (Android Keystore / iOS Keychain, `first_unlock_this_device`). Platform behaviour:
  - Background: iOS suspends the app and both platforms drop the socket; the 4 s check skips while not `resumed` (this includes iOS `inactive`: Control Centre, incoming-call banner). On resume and on socket reconnect the block status is re-read at once.
  - The same code path and the same tests (`test/chat_qa/block_realtime_test.dart`, 14 tests) cover both platforms; device checks are RS-11a…d in `docs/testing/chatting/manual_testing/manual_checklist.md`.

### 1.7 Screen behaviour
- **Keyboard:** `adjustResize`, input above the keyboard. The emoji panel matches the last keyboard height (max 40% of the screen).
- **Back / swipe:** closes the emoji panel first; the iOS swipe-back works.
- **Swipes:** right = reply; **left on a received text or caption = translate** (Hindi ↔ English). **Listen** (text-to-speech) is under received messages.
- **Search** in chat searches loaded messages only.
- **App bar tap target (F-1.1.7):** the whole area between Back and the call buttons (photo, name, status line **and the gaps between them**) opens the profile. The `GestureDetector` uses `HitTestBehavior.opaque`; before, only the text and photo reacted. Same in group chat (§2.1). Files: `Chat_Screen.dart`, `GroupChatScreen.dart`.

---

## 2. Group chat

### 2.1 Opening
- **Route:** `Routes.groupChatScreen`, args `{ groupId, groupName, groupImage|groupProfile, groupCode?, isCreator?, isActive?, groupStatus? }`.
- **On open:**
  - socket `init` (`/chat`);
  - `join_group_chat` and `join {userId, groupId}`;
  - `mark_seen {userId, groupId}`;
  - `GET /getMembers?groupId=` (members, admin flag);
  - history.
- **Open order (F-1.2.2):**
  - `GroupMessageController` is `lazyPut`, so it is created while `GroupChatScreen` is **building**.
  - `onInit` sets only its own fields (group id, name, image).
  - The steps that change other screens' Rx values run **right after that frame** (`_runAfterBuild`): translation visibility reset, chat-list manual unread, sockets / history / receipts (`initializeGroupChat`).
  - Before, they ran mid-build. When another chat was already on screen, its `Obx` was marked dirty during the build → red screen **"setState() or markNeedsBuild() called during build … Obx … GroupChatScreen"**. This was seen sometimes when opening a group from a notification.
  - Test: `test/chat_qa/group_open_during_build_test.dart`. It reproduces the error with the old order.

### 2.2 History, paging, sync
- **`GET /api/getGroupMessageHistory`** (aliases: `/api/messages`, `/api/group-messages`, `/api/group/:groupId/messages`, `/api/chats/:chatId/messages`).
- **Query Parameters Accepted (Auto-Resolved):**
  - Group Identifier: `groupId`, `chatId`, `conversationId`, or `id`.
  - Cursor Pagination: `before=<messageId>` (older messages) or `after=<messageId>` (newer messages).
  - Page Pagination: `page=1`, `limit=30` (max: 100).
- Same merge / paging / resume rules as §1.2.
- **Cached copy first (F-1.2.4, §12):**
  - `onInit` starts reading `group_<groupId>` from the Hive cache straight away. The file read completes after the build, so no Rx changes happen mid-build (§2.1).
  - `getGroupMessages` runs at the same time, with a 10 s timeout.
  - Failure over cached messages → "Couldn't refresh · Retry" bar.
  - `group_updated` / member added / removed events never touch the message list or the cache. Member changes only fetch newer messages (`after=`), which are merged.
  - Clear chat (`clearGroupChat`, `group_chat_cleared`) clears the cached copy too.
- **Reconnect** (`connect` on `/chat`) → re-sync attendance polls + fetch newer messages.

### 2.2.1 Screen Lifecycle: Correct "Back" & "Exit" Implementation (v2.5.0)

> [!CAUTION]
> **CRITICAL LIFECYCLE WARNING:**  
> When the user leaves or presses Back on a chat screen, **NEVER** emit `clear_chat`, `delete_chat`, or call `POST /api/delete`!  
> Those actions permanently set `lastClearedMessageId` to the latest message, erasing the conversation from the user's history!

#### Correct Flutter Chat Screen Controller Pattern:
```dart
class GroupChatController extends GetxController {
  final int groupId;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  late IO.Socket chatSocket;

  GroupChatController({required this.groupId});

  @override
  void onInit() {
    super.onInit();
    // 1. Initial history fetch from REST API:
    loadMessageHistory();

    // 2. Connect socket & join group room:
    chatSocket = IO.io('https://api.fgtracker.com/chat', IO.OptionBuilder().setTransports(['websocket']).build());
    chatSocket.emit('join_group', {'groupId': groupId, 'userId': currentUserId});

    // 3. Listen to incoming real-time messages:
    chatSocket.on('receive_group_message', (data) {
      if (data['groupId'] == groupId) {
        messages.insert(0, ChatMessage.fromJson(data));
      }
    });
  }

  Future<void> loadMessageHistory() async {
    final history = await ChatApiService.fetchGroupMessages(groupId);
    messages.assignAll(history);
  }

  @override
  void onClose() {
    // 4. On Back / Screen Exit: ONLY leave the socket room. DO NOT clear chat!
    chatSocket.emit('leave_group_chat', {'groupId': groupId});
    chatSocket.off('receive_group_message');
    super.onClose();
  }
}
```

### 2.3 Sending (temp bubble + ack)
- **Socket:** `send_message` on `/chat` via `emitWithAck`, with **`clientMessageId: "c_<micros>"`**, `groupId`, and the §1.3 fields plus `duration` for audio.
- **Temp bubble:**
  - A temp bubble (no `id`) appears straight away.
  - `message_sent {clientMessageId, id}` / `receive_*` with the same `clientMessageId` → **replaced in place by the server copy** (server attachment, audio URL and duration win).
  - Fallback match: my newest temp bubble of the same type.

### 2.4 Receiving
- **Listens on `/chat`:** `receive_group_message`, **`receive_message`**, `group_forward_message` and the forward aliases.
- **The server sends both events for one message**; the app de-duplicates (§7, #5).
- A missing sender name / avatar is filled from the member list.

### 2.5 Seen ticks and "Seen by"
- **Emits** `mark_seen {userId, groupId}`, debounced, foreground only.
  - **Once per trigger (F-1.2.5):** on open, only `SocketMessageService.init` sends it (immediately when connected, otherwise from the connect handler). The controller no longer sends a second identical one.
  - After history loads it is sent again with `messageIds`.
  - Later sends (new message, resume, close) only go out when there are **new** ids from others; on close with nothing new, nothing is sent.
  - Before this change, one open + close sent 3–4 `mark_seen`.
- **Listens** `messages_seen_update` / `group_message_seen {groupId, userId|seenBy, messageIds?}`.
- **Never recorded:**
  - my own read echo;
  - a reader on their own message.
- **Blue tick only when all other members have seen.**
- **Message Info → "Seen (X of Y)":** excludes me and the sender, matched by user id. Y = members − sender.

### 2.6 Typing
- **Emits** `group_typing` / `group_stop_typing {groupId, userId, userName}`.
- **Listens** to the same events. Shows a typing bubble labelled "Name is typing" / "A, B are typing" / "N people are typing".

### 2.7 Members (live)
- **Listens** `member_removed` / `member_left {groupId, userId, removedBy, isKicked}` on `/chat`:
  - removes the member from the chat's list (header count, @mentions, attendance);
  - quietly reloads Group Info and the Members screen if they are open for that group.
- Members are refetched on app resume.
- **Removed / left user (me):**
  - also listens to `user_removed_from_group` and `group_left` on `/chat` (backend v2.8.0);
  - an event with `userId` = me for the open group → `removedFromGroup = true`;
  - on open / resume: if `GET /getMembers` loads a non-empty list without me → `removedFromGroup = true`; with me → false (re-added). An empty or failed list changes nothing;
  - while `removedFromGroup`: the input bar is replaced by "ℹ️ You're no longer a member of this group" and every send is blocked (same guard as deactivated groups);
  - history stays readable and the group stays in the chat list.
- **Member added:** the backend sends `group_updated` / `group_info_updated` (no dedicated event). Open chats pick up the new member when members are refetched.
- **"X left" message in the open chat, archived groups too (F-1.2.1):** the server stores the "X left / X was removed" system message but doesn't push it live to every member (seen for **archived** groups: the chat only showed it after reopening). Now any `member_left` / `member_removed` / `group_left` / `user_removed_from_group` for the open group makes the chat fetch newer messages (`syncNewerMessages`, `after=<newest id>`) at 0.8 s and again at 3 s. The merge dedupes by id, so a message that did arrive live is not shown twice.
  - App-level stream `SocketMessageService.groupMemberChanges` (group id), registered with **`onAny`** on `/chat`: other code calls `off(event)` without a handler for these events, which removes every `on()` handler but not an any-listener.
  - Additive only: `_onMemberRemoved`, `listenMemberRemoved`, `listenGroupExit` and the chat-list exit handling are unchanged. Not run once I am the one removed (`removedFromGroup`).
  - Same Dart code on Android and iOS. Tests: `test/chat_qa/group_member_left_test.dart` (GML-01…03). Server fix: #27.

### 2.8 Deactivated groups (backend v2.5.0)
- **Read from** `/chat-list` rows (`groupStatus`, `isDeactivated`, also inside `group`) and the open arguments (`groupStatus`, `isDeactivated`, `isActive:"false"`).
- **Live:** `group_status_updated {groupId, isDeactivated, groupStatus, isActive}` on **all three sockets** (one shared map; the live value wins).
- **UI:**
  - The input bar becomes "ℹ️ This group has been deactivated by the Admin".
  - All sends (text, voice, file, video, location, contact) are blocked.
  - The chat list shows a grey **"Deactivated"** chip.
- **Admin Activation & Deactivation Action (`POST /deActivateGroup`):**
  - **Caller:** `GroupController.updateGroup()` triggered from the Active/Inactive `CupertinoSwitch` in `groups_list_screen.dart`, `CreatedGroupUi.dart`, and `NewlyGroupUi.dart`.
  - **Auth:** `GroupRepo.updateGroupStatus()` uses `HttpUtil().Authpost` with the JWT Bearer token so the server verifies Admin privileges.
  - **Payload:** Strict string payload sending `groupId` (String) and `isActiveGroup` (String `"true"` / `"false"`), conforming to backend Joi string validation.
  - **Optimistic UI:** Immediately toggles `isActive` in `groupData` and updates `SocketMessageService.instance.groupDeactivated[groupId]` for instant responsive feedback, automatically reverting on server failure.
  - **Type-Safe Parsing (Fix for `type 'String' is not a subtype of type 'bool'`):**
    - `CommonResponse.fromJson` safely converts string statuses (`"deactivated"`, `"active"`, `"success"`, `"true"`, `"false"`, etc.) and integers (`1`, `0`) to boolean `status` and `isSuccess`, eliminating Dart runtime `TypeError` popups in dialogs.
    - `GroupRes.fromJson` & `GroupsResData.fromJson` safely parse `isActive`, `isCreator`, `status`, and `memberCount` against mixed JSON types returned by the backend.

### 2.9 Attendance poll in chat
- **REST:** `POST /groups/:groupId/attendance` (create), `POST /attendance/:pollId/vote`, remove vote, `POST /attendance/:pollId/close`, `GET /attendance/:pollId`.
- **Socket (`/chat`):**
  - listens `attendance:created|updated|my_vote|edited|closed|deleted`;
  - emits `attendance:subscribe|unsubscribe|sync`.
- **Rules:**
  - Votes are optimistic, with rollback on failure.
  - Counts from the server win.
  - Older `version` events are dropped.
  - An event without counts triggers a refetch, queued so concurrent votes aren't lost.
  - **Fallback refresh:** every 5 s per visible poll; 30 s only for polls that already received a live event.
- **Delete:** attendance **cannot be deleted from chat** (no Delete in the long-press menu or the card). The admin's card menu offers only "Close attendance".
- **Pinned banner / reply preview:** shows "📊 <title>", never the raw JSON.

### 2.10 Group info, mentions, clear
- **Group info:** `GET /chat/profile-details?groupId=` (media, links, docs, members).
- **Group info app bar (F-1.1.7, `ChatGroupProfile_Screen.dart`):** Back and Edit (✏, group creator only) are the same white rounded 44×44 buttons (`_roundBtn`), centred in a 64.h bar, and the whole square is tappable. Edit used to shrink to the icon's size inside the app bar actions.
- **Add Members sheet (admin / creator, `_AddGroupMemberSheet`):**
  - **Who is listed:** saved phone contacts and members of your other groups, minus people already in this group and yourself. Saved contacts come first, then A–Z. Data: device contacts + `getGroupMember(filter: all)` + `getCoGroupMemberIds` + `getAllUserData`, loaded together.
  - **Loading (F-1.1.7):** a `Skeletonizer` list with the same rows (8 rows) instead of a spinner. Key `add_member_skeleton`.
  - **Row (F-1.1.7):** photo (or first letter), name and phone on the left; on the right a small "Saved contact" / "Your groups" / "Contact • Group" label (`_CandidateMember.shortTag`) above a filled purple **Add** button. Two lines per row. The whole row is tappable → confirm dialog → `GroupController.addGroupMember`.
  - **Error (F-1.1.7):** icon, "Couldn't load members", "Check your internet and try again." and a rounded **Retry** button (key `add_member_retry`) instead of the raw exception text.
  - **No contacts permission:** a yellow note "Showing members from your groups only" with **Enable** (opens app settings).
  - **Keyboard (F-1.2.3):** typing in search no longer lags, and the list stays above the keyboard.
    - Cause: the sheet read `MediaQuery.of(context).size`, which also depends on the keyboard inset, so the whole sheet (header, search, list) was rebuilt on **every frame** of the keyboard animation. The fixed 75% height also left the lower rows under the keyboard. Behind it, the Group Info page re-laid out every frame too.
    - Now: height from `MediaQuery.sizeOf` (75%); the small `_KeyboardAwareSheet` wrapper is the only widget that reads `viewInsetsOf`, adds bottom padding = keyboard height and shrinks the sheet when room is short; its child is the same instance each frame, so it is only laid out again. The list is `Expanded`, so it gets shorter and stays scrollable. Group Info's `Scaffold` has `resizeToAvoidBottomInset: false` (that page has no text field; its sheets handle the keyboard).
    - Search, filter, add and confirm logic unchanged. Same on Android and iOS.
  - The sheet's texts are English only; they are not in the ARB files yet (open item).
- **Clear chat:** `POST /clearGroupChat`. On success the profile's media is emptied immediately and refetched.
- **@mentions:** client-side list from `groupMembers`; no server payload.

### 2.11 Group membership: create, join, add, remove, exit (rechecked 2026-11-07)

All group APIs are in [GroupRepo.dart](../lib/app/Data/Repositories/GroupRepo.dart) and return `CommonResponse` (`status`, `message` only, **no group details**). Errors always go to `CommonDialog.errorMessage(message)`.

| Action | Entry point(s) | API | On success today |
|---|---|---|---|
| **Create** | Home "Create Group" button and Walkie Group Select → `showCreateGroupSheet()` ([bottom_actions_bar.dart](../lib/app/Core/constant/BottomSheet/bottom_actions_bar.dart)) | `POST /createGroup` `{groupName, groupDesc}` (+ `groupProfile` file → form-data) | Sheet closes, the user **stays on the screen they created from** (Home or Walkie Group Select), list refreshes, **"Group created" sheet** |
| **Join** | J1 code entry, J2 QR from gallery ([DialogBox.dart](../lib/app/Core/values/Dialog/DialogBox.dart)), J3 camera scanner ([QrScanController.dart](../lib/app/modules/Group/controller/QrScanController.dart)) → `JoinGroupController.joinGroup` | `POST /joinGroup` `{groupCode}`. Location permission **and** location service are required first | Join sheet closes (J1) / scanner closes (J3), list refreshes, **"Joined" sheet** |
| **Add member** (admin) | Member screen ＋ button → user picker → `SearchUserController.joinGroup` | `POST /joingGroupMember` `{groupCode, userId}` | Toast with server message, member list reloads (no sheet; it is not the current user) |
| **Remove member** (admin) | Member sheet, chat Group Info, chat screen → `GroupController.deleteGroupMember` | `POST /deleteGroupMember` | Unchanged; the removed user sees the "no longer a member" banner (§2.7) |
| **Delete group** (admin) | Member screen ⋮ → Group Delete (the Member screen is opened from a "MemberPage" notification) → `MemberController.deleteGroup` | `POST /deleteGroup` `{groupId}`, then `GroupTrackingController.deleteGroup` (tracking socket, protected module, not edited) | Toast "Group deleted successfully", then the **same navigation as exit** (`navigateAfterLeave`, see below); it used to reset the app to Home (`Get.offAllNamed`) |
| **Exit** | see table below → `MemberController.exitGroup` | `POST /exitGroup` `{groupId, userId}`, then `GroupTrackingController.exitGroup` leaves the tracking socket room (protected module, not edited) | per entry point below |

**Exit entry points** (all use the existing "Are you sure?" `CommonDialog.ConfirmationDialog`):

| # | Where | "Left" sheet |
|---|---|---|
| L1 | Member screen (Group Info, opened from the Home cards / a notification) ⋮ → Exit Group | ✅ |
| L2 | Home "joined groups" card → Exit | ✅ |
| L3 | Home "created groups" card (not creator) → Exit | ✅ |
| L4 | All Group List (`Routes.GroupsList`) card → Exit | ✅ |
| L5 | Group chat → Group Info (`GroupProfileScreen`, chat side) → Exit Group | ✅ |

The group chat screen itself has no exit option (the menu item is commented out in `message_Widgets.dart`, open item #23), so exiting from the chat side always goes through Group Info.

**Navigation rule (F-1.1.1): finish where you started.** Create, join, Open Group and exit never open a screen the user did not come from, and Back always returns to the screen they started on. There are four start screens:

| Start screen | After create / join | **Open Group →** (created / joined sheet) | After exit |
|---|---|---|---|
| **Home** | stays on Home + sheet | Home → Group Chat (Back → Home) | back to **Home** |
| **All Groups** (`/groups-list`) | — (no create / join here) | — | stays on / back to **All Groups** |
| **Chatting** (Chat List) | — (no create / join here) | — | back to the **Chat List** (refreshed) |
| **Walkie-Talkie** (Group Select) | stays on Walkie Group Select (new group appears in its list) + sheet | Walkie Group Select → Group Chat (Back → Walkie Group Select) | back to **Walkie Group Select** (the left group's walkie screen is closed) |

**Navigation after a successful exit or delete** — `GroupMembershipSheet.navigateAfterLeave(groupId)`, used by L1, L2, L3, L5 (L4 is already on the list) and by delete group:
- It reads the route stack (no `source` argument): it pops from the top until the **nearest start screen**:
  - Chat List (`/ChatListScreen`, the name GetX gives `Get.to(() => ChatListScreen())`);
  - All Group List (`/groups-list`);
  - Walkie Group Select (`/walkie-group-select`, or `/WalkieGroupSelectScreen` when opened with `Get.to` after a purchase);
  - Home (`/Home_Screen`); otherwise the first route.
- **Chat List** → stays there and calls `ChatListController.refreshChats()`.
- **Any other start screen** → removes the group from `GroupController.groupData` at once and refreshes it. All Groups and Walkie Group Select both read that list. **No new screen is opened** (it used to open the All Group List on top of Home).
- Every screen of the left group above the start screen (chat, info, members, walkie screen, dialogs) is closed. A 1 s guard stops a second call. Then the "left" sheet shows (600 ms later).

| Path | Lands on | Back |
|---|---|---|
| Home → Chat List → Group Chat → Info → Exit | Chat List (refreshed) | Home |
| Home → All Group List → Group Chat → Info → Exit | All Group List | Home |
| Home → (Total Groups) Group Chat → Info → Exit | Home | — |
| Home → Walkie Group Select → Walkie screen → Group Chat → Info → Exit | Walkie Group Select | Home |
| Home → Created / joined sheet → Open Group → Info → Exit | Home | — |
| Member screen from a notification → Exit / Delete group | the screen under it (Home, Chat List, All Groups or Walkie Group Select) | — |
| All Group List card → Exit | stays on All Group List | Home |

**Navigation after create / join:**
- **Create success** → the create sheet closes and the user **stays where they are** (Home or Walkie Group Select), then the "Group created" sheet.
- **Join success** (Home only) → stays on Home, then the "Joined" sheet.
- **Open Group** (joined and created sheets) → `Get.toNamed(Routes.groupChatScreen, …)` **on top of the current screen**, with the **same arguments and `.then` refresh as the All Group List tap** (`groupId`, `groupName`, `groupImage`, `groupDesc`, `groupCode`, `isCreator`, `isActive`). If the group is not found / inactive, it opens the All Group List on top instead (unless already there). **Done** only closes the sheet.
- Covered by `test/group_flow_navigation_test.dart` (Chat List, All Groups, Walkie, Home, nearest-start-screen cases).

**Success sheet** — [group_membership_sheet.dart](../lib/app/modules/Group/widgets/group_membership_sheet.dart), `GroupSheetType { joined, left, created }`:
- One modal bottom sheet for all three. It shows the user's name (`PrefConst.userName`), group name, image or initials, member count, and the location row only when `PrefConst.locationSharing` is on (read-only; it is the user's setting, not per group).
- **Joined:** "Joined successfully!", **Open Group →** opens that group's chat (see navigation above).
- **Created:** "Group created!", shows the **group code with a copy button** and "You are the admin", **Open Group →** opens the group's chat.
- **Left:** "You left the group", the member count without you. **Only one button: Done** (filled, key `group_sheet_left_done`), which closes the sheet. Since F-1.1.7 there is **no "Open Group" / "Go to Groups" button** after an exit or removal. Joined and Created sheets keep **Open Group →**.
- Because join / create return no group details, the sheet waits for the list refresh the caller already started (max 8 s) and finds the group by **code** (join) or by **name among groups you created, newest first** (create). If not found, it shows the code / typed name and **Open Group** goes to the Group List.
- It replaces the old success toasts ("Group Exit successfully", the join / create server message). It is shown **by the caller after its own navigation** (so `Get.back()` / `Get.offAllNamed` cannot close it), only on `status == true`, and only once at a time.
- `DialogBox.showCreateGroupBottomSheet` (older create sheet) also shows the created sheet, but nothing opens it today.

---

## 3. Chat notifications and redirect into a chat

### 3.1 Push payload (FCM `data`) the app expects
| `screen_name` | Required fields | Opens |
|---|---|---|
| `chatScreen` | `memberData` (JSON string of the sender, `MemberData`), `notificationId` | Private chat with that user |
| `groupChatScreen` | `groupId`, `groupName`, `notificationId` | That group chat |
| `group_walkie` / `groupWalkie` | `groupId`, `groupName`, `speakerName`, `speakerImage` | Walkie screen (not chat) |

**Backend:** always send `screen_name`. A payload with a `groupId` but **no** `screen_name` is treated as Walkie, for older builds.

> ⚠️ **Mismatch with backend v2.8.0 §14.3:** the backend's private payload example has `chatId`, `conversationId`, `senderId` and `receiverId`, but **no `memberData`**. The app opens a private chat **only** from `memberData`. Without it, tapping the notification does nothing (§7, #15).

### 3.1.1 Foreground notifications (current behaviour vs backend v2.8.0 §14.2)
- **Android, app open:** `onMessage` → `_isChatNotificationForOpenChatOrSelf` decides whether to show a chat notification (`chatScreen` / `groupChatScreen` only):
  - **no notification** when the sender is me (`senderId`, or `memberData.id` if `senderId` is missing);
  - **no notification** for the chat open on screen (`ActiveChatTracker.isViewing`: group by `groupId`; private by `chatId` / `conversationId` or the sender's user id);
  - every other chat, and every non-chat type (calls, walkie, force logout), shows as before.
- **iOS, app open:** same rules, applied natively:
  - `ActiveChatTracker` sends `{groupId, chatId, peerId, myUserId}` to iOS on every open / close over the `fgtracker/active_chat` channel;
  - `AppDelegate.userNotificationCenter(_:willPresent:)` → `shouldHideChatBanner` returns no banner and no sound for a match;
  - anything else goes to Firebase as before (`alert, badge, sound: true`).
- **App in background or closed:** unchanged; the system shows every notification.

### 3.2 Tap handling
- **Background tap:** `FirebaseMessaging.onMessageOpenedApp`, registered **once** in `initialized()`.
- **Killed app:** `getInitialMessage()` handled **once** per app run (`setupInteractMessage`).
- **Local notification tap** (foreground / Android): `isWalkieNotificationPayload()` decides Walkie vs chat. Group chat payloads are **not** sent to Walkie.
- **Routing:** `handleMessage` → `ChatNavigation.openPrivateChat` / `openGroupChat`:
  - the same chat stays open;
  - another chat replaces it;
  - `chatId` is resolved from the chat list when missing.
- `notificationId` → marked read via the notifications API (`int.tryParse`; a bad id never crashes).

### 3.3 Badges
- **Chat list header:** number of main-list chats with unread (archived excluded).
- **Archive row:** its own unread total.
- **Home "Chatting" dot:** `NotificationMarkerService`, set from chat-list unread (private / group).
- `/getUnreadCount` (notifications) is **never** used for chat counts.
- `POST /mark-viewed` is called every time the Chats screen opens (`onChatListOpened`); it clears the home dot on all devices, not per-chat counts.

---

## 4. Message forwarding

### 4.1 Target list
- **`GET /forward/list`** (no paging yet). The app reads `data.recentChats`, `data.users` / `people` / `private`, `data.groups`.
- **Row parsing:**
  - Flat fields (`type|chatType`, `userId`, `groupId`, `name`, `mobileNo`, `image|avatar`, `profileImage|groupProfile`).
  - **Also the `/chat-list` shape:** `user.id` (forward target), `user.mobileNo`, `user.name`, `group.id`, `group.groupName`.
  - Plus `isPinned` and `lastMessageAt|timestamp`.
- **Recent chats:**
  - **all** recent chats from the server;
  - phone contacts only replace the display name;
  - one row per chat key;
  - sorted pinned first, then newest (server order if no time).
- **My contacts:** private users whose number is in the phone contacts. Groups are shown as sent.
- **Search:** name or number; an empty query shows everything.

### 4.1.1 Forward screen look (F-1.3.0, 2026-11-18, UI only)
File: `Messages/Views/ForwardMessageScreen.dart`. Controller, API and socket are unchanged.
- **App bar:** same look as the Calls screen header: background `#F6F7FB`, the shared `AppBackButton` (`AppBarStyle.leading`), title "Forward to…" left-aligned (`#1E1B4B`, Inter Bold 19), purple "N selected" under it once something is picked. No search icon in the app bar.
- **Search:** one always-visible rounded field under the app bar ("Search name or number"), with a clear (×) button. Scrolling the list hides the keyboard.
- **Back (app bar or phone):** if a search is typed, the first Back clears it; the next Back leaves the screen.
- **Selected strip:** small avatars with an × badge and first name, above the search; tap one to unselect.
- **Rows:** coloured initial avatars (photo when there is one; groups show the group icon), bold name, number or "Group" under it, round check on the right. A selected row gets a light purple background.
- **Sections:** Recent chats, Groups, My contacts, Other contacts (same data and order as before).
- **Send:** round purple floating button bottom-right, only while something is selected; shows a spinner while forwarding.

### 4.2 Sending a forward
- **REST:** `POST /forward/message`.
  ```json
  { "messageId": 183180, "sourceType": "private|group",
    "targets": [ { "type": "private", "userId": 3 }, { "type": "group", "groupId": 12 } ] }
  ```
- **Plus socket** `forward_message` per target (legacy). **Duplicate risk, see §7, #10.**
- **After a single-target forward:** opens that chat via `ChatNavigation`. After multiple targets: goes back.
- Forwarded bubbles show the italic **"Forwarded"** label (`isForwarded`, `forwardedLabel`).

---

## 5. Long-press (hold) options

### 5.1 Message bubble (private + group): `ChatScreenRules.menuOptions`
| Option | Shown for | Action |
|---|---|---|
| Reply | All (not deleted) | Sets the reply bar |
| Copy | Text messages | Clipboard |
| Forward | All, **not attendance** (`attendance` / `attendance_poll`) | Forward screen (§4) |
| Edit | **My** text messages | `editMessage` |
| Pin / Unpin message | All | `pin_message` / `unpin_message` |
| Message Info | **My** messages | "Seen" sheet (§2.5) |
| Delete for everyone | **My** messages, **not attendance** | `delete_message for_everyone` |
| Delete for me | All, **not attendance** | `delete_message for_me` |

- **Swipes:** right = reply; left on a received text or caption = translate.
- **Deleted messages** have no menu.
- **Attendance card (admin, open poll):** ⋮ → **Close attendance** only.

### 5.2 Chat list row
| Option | REST (primary) | Socket (private, legacy) |
|---|---|---|
| Pin / Unpin chat | `POST /pin {chatId|groupId, chatType, isPinned}` | `pin_private_chat` / `unpin_private_chat` |
| Mark as read | `POST /mark-read {chatId|groupId, chatType}` | `mark_private_chat_read` / `mark_seen` |
| Mark as unread | `POST /mark-unread {chatId|groupId, chatType}` + local mark (kept if the call fails). Dot also shows for `isMarkedUnread: true` from the server (set on another device); cleared on open / read | none |
| Mute (with duration) | `POST /mute {…, isMuted, mutedUntil}` | `mute_private_chat` / `unmute_private_chat` |
| Archive / Unarchive | `POST /archive {…, isArchived}` | `archive_private_chat` / `unarchive_private_chat` |
| Delete (clear) chat | `POST /delete {chatId|groupId, chatType}` | `delete_private_chat` |

- All actions are **optimistic**.
- A thrown error **or** `status:false` → rollback + "couldn't update" message.
- **Archived screen:** Unarchive.

---

## 6. Chat list: API and socket

### 6.1 Loading
- **`GET /chat-list?page=N&limit=20&type=all&includeArchived=false`** (+ `search`).
- **Kept rows:** at least one message, a valid identity, not archived.
- **Merged by chat key** with local state; a chat open on screen always shows 0 unread.
- **Archive list:**
  - **`GET /archived?page=N&limit=100`**, all pages (max 5) (backend v2.8.0);
  - if `/archived` fails: `GET /chat-list?page=1&limit=50&type=all&includeArchived=true`, filtered by `isArchived`;
  - **plus** socket `get_archived_private_chats` → `archived_private_chats`;
  - all are **merged** (never replace, so archived groups are never dropped). A chat unarchived on another device leaves Archive through chat-list events, not through `/archived`.
- **Server snapshot of the main list:** a chat archived here is not re-added. If the server lists it as not archived (unarchived elsewhere), it moves back to the main list.

### 6.2 Realtime events (list socket and `/chat`)
- **Row updates:** `chat_list_updated`, `conversation_updated`, `private_chat_list_updated`, `group_chat_list_updated`, `common_chat_list_updated`, `unified_chat_list_updated`, and **`receive_message`** (heard by the list socket too).
- **Full list:** `chat_list`, `common_chat_list`, `unified_chat_list`, `private_chat_updated`.
- **Other:** `private_chat_removed`, `private_chat_cleared`, `private_chat_action_error`, `archived_private_chats`, `group_updated`, `group_info_updated`, `group_chat_cleared`, `group_status_updated`.
- **Typing:** `typing` / `stop_typing` (list socket), `group_typing` / `group_stop_typing` (`/chat`).

**Row update rules:**
1. **Archive:** a chat archived here stays archived; an event never un-archives it. Updates to it apply inside the Archive list only.
2. **New message & anti-shuffling:**
   - A **new message** requires a newer last-message ID or a truly different content payload (`ChatListRules.isNewMessage`).
   - Read receipts (`mark-read`, `mark_seen`), presence changes, and server touches that update conversation `updatedAt` without changing the last message ID or text evaluate `isNewMessage = false`.
   - Equal or older message IDs and identical previews **never** bump the unread badge or move/shuffle the row.
   - When merging updates (`_mergePrivateChat`), `takeUpdatedTime` is `false` if the message did not change, preserving the chat's original message creation timestamp.
   - Server full-list events (`_handleFullChatListSocket`) and search/page-2 API loads share the same `_mergeServerRow` pipeline (`_mergePrivateChat(..., fromServer: true)` + `_wasReadLocally` guard), keeping both Private and Group unread badges intact.
   - Raw `receive_group_message` / `receive_message` payloads parse top-level `senderId`/`senderName` (`PrivateChatModel.fromJson`), populate `lastMessageData`, and initialize `unreadCount = 1` for new unseen rows (`_prepareNewRow`).
   - Group listener scoping: `releaseGroupChatEvents` detaches only open-screen handlers by reference, so `ChatListController` never loses `group_updated`, `group_info_updated`, `group_chat_cleared`, `member_removed`, `member_left`, `user_removed_from_group`, or `group_left` listeners after closing a group chat.
3. **Unread:**
   - The server's `unreadCount` wins when present.
   - Otherwise +1 only for a new message from **another known user**, counted **once per message id**, never for a deleted message.
   - The chat open on screen = 0.
   - A chat read on this device keeps 0 against an older server count for 15 seconds (covers a refetch that reaches the server just before the read; a newer message always counts).
4. **Delete:**
   - `lastMessage: null` → the preview is cleared (main and Archive).
   - `isDeletedForEveryone` → "This message was deleted"; on my own row, **"You deleted this message"**.
5. **Typing** is keyed by chat:
   - group events → `group_<groupId>` ("Name is typing…");
   - private → the exact chat (`chatId` first), "typing…";
   - a `typing` event carrying `groupId` / `chatType:"group"` goes to the group row;
   - auto-clears after 5 s and when that user's message arrives.
6. **Re-sync:** on reconnect and resume, `GET /chat/sync?since=<last sync ISO>` is merged in place; full page-1 refetch if it fails.
7. **Sorting stability & tie-breakers:**
   - Pinned chats sort by `pinnedAt` descending, then by message creation timestamp descending (`lastMessageTime` checks `lastMessageData` timestamps before falling back to `timestamp`/`time`), with a deterministic tie-breaker `chatKey(a).compareTo(chatKey(b))`.
   - Unpinned chats sort by `lastMessageTime` descending with the same deterministic tie-breaker.
   - Opening and returning from a chat leaves list order 100% stable unless an actual new message was sent/received.

### 6.3 Open chat ↔ list
- The open chat pushes its real last message to its list row after a **delete**, a **clear**, and on **close**.
- `syncLastMessageFromChat`: retains `row.lastMessageData` (message `createdAt`, `id`, `content`, `senderId`) and syncs `row.time` and `row.timestamp` with the message's `createdAt`, preventing conversation `updatedAt` from corrupting sorting.
- On close: unread for that chat → 0 locally; `mark_private_chat_read` / `mark_seen` are sent. Opening a group chat also calls `clearManualUnreadForGroup` and `clearUnreadForOpenedChat` immediately after frame, syncing `NotificationMarkerService`.
- **Archived group opens on tap (F-1.2.3):** `ArchivedChatsScreen._openChat` only opened private chats; a group row has no `userId`, so a tap did nothing (also "Message" in the group quick profile). Group rows (`isGroup` / `chatType: "group"`) now go to `_openArchivedGroup`, which opens `Routes.groupChatScreen` with the **same arguments as the main Chats list** (`groupId`, name, image, `groupCode` / `isCreator` / `isActive` from `GroupController`, `groupStatus: "deactivated"` when deactivated) and marks it read. The group stays archived. Private rows unchanged.

### 6.4 Status & Stories Section (WhatsApp-Style Updates)
- Rendered via `StatusSection` inside `ChatListScreen` (Updates / Status tab).
- **"My Status" popup:**
  - Uses standard Flutter modal route (`showGeneralDialog`) with `barrierDismissible: true` and barrier tap dismissal.
  - Replaces non-modal `OverlayEntry` to eliminate gesture arena conflicts that previously caused the screen to become unresponsive or require multiple clicks.
  - Dismisses cleanly on tap anywhere outside or on system back button, matching professional WhatsApp UX.

---

## 7. Open items between frontend and backend

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | `attendance:updated` with counts to `group_{groupId}` on every vote / change / removal | Backend ✅ v2.8.0 → Flutter QA | **Answered.** The app already listens and reads `poll.counts.byOption` + `version`. Verify on device; then the 5 s fallback can be relaxed |
| 2 | `member_removed` / `member_left` still sent; member-added event | Backend ✅ v2.8.0 | **Answered.** The app already handles both. Added = `group_updated` / `group_info_updated` |
| 3 | Token expiry handling | Backend ✅ v2.8.0 → Flutter (touches Login flow, needs approval) | **Answered:** no refresh endpoint, 90-day token. **Done** (F-1.0.7, approved by the user): a second `TOKEN_EXPIRED` within 60 s → logout to OTP login |
| 4 | `GET /archived`: private + group, same fields, paging | Backend ✅ v2.8.0 → Flutter switch | **Done** (F-1.0.5): Archive uses `/archived`, with `/chat-list` fallback |
| 5 | One group message sent as both `receive_group_message` and `receive_message` | Backend ✅ v2.8.0 | **Closed.** Kept on purpose for old builds; the app dedupes by `id` / `clientMessageId` |
| 6 | Cursor history `before=<id>` and catch-up `after=<id>` for private + group | Backend ✅ v2.8.0 → Flutter switch | **Done** (F-1.0.5): `before` for older, `after` for catch-up; page paging kept as automatic fallback |
| 7 | `chat_list_updated` with the real `isArchived`; unread reset to 0 on read | Backend | ✅ Done in v2.6.0. Flutter read guard cut from 2 min to 15 s (F-1.0.6) |
| 8 | Mark as unread across devices (`POST /mark-unread`, `isMarkedUnread`) | Backend ✅ v2.8.0 → Flutter | **Done** (F-1.0.6) |
| 9 | Call `POST /mark-viewed` when the Chats screen opens | Backend ✅ v2.8.0 → Flutter | **Done** (F-1.0.6): called when the Chats screen opens |
| 10 | Forward: REST `/forward/message` **and** socket `forward_message` both sent; confirm no double storage | Backend | **Open** (not answered in v2.8.0) |
| 11 | `/forward/list`: same fields as `/chat-list`, `page` / `limit`, exclude blocked users and groups left | Backend | **Open** (not answered in v2.8.0) |
| 12 | Socket/media payloads should use relative paths; absolute `fgtracker.in` URLs hit a dead DNS record | Backend | **Open** (not answered in v2.8.0) |
| 13 | Group status: authoritative field, event reach | Backend ✅ v2.8.0 | **Closed.** `groupStatus` is authoritative; `group_status_updated` goes to the group room, and members' personal rooms get `chat_list_updated` with `groupStatus`. The app reads both |
| 14 | Removed member's own screen ("You're no longer a member") | Product decision → Flutter | **Done** (F-1.0.8): banner, history kept (§2.7). Relies on `/getMembers` returning every member including the caller |
| 15 | Private chat push payload: v2.8.0 example has no `memberData`; the app needs it to open the chat | Backend confirm | **Open, urgent** |
| 16 | Foreground notifications: hide for the chat that is open and when `senderId` is me (backend v2.8.0 §14.2) | Flutter | **Built** (Android F-1.0.3, iOS F-1.0.4). Device QA pending; the iOS build is not yet verified |
| 17 | Forward target key: v2.8.0 example uses `receiverId`; the app sends `userId` | Backend confirm | **Open** |
| 18 | `GET /getMembers` returns **all** members incl. the caller (no paging)? `user_removed_from_group` / `group_left` sent on `/chat`? | Backend confirm | **Open** |
| 19 | "Left" sheet missing on exit from Group List (L4) and chat Group Info (L5), §2.11 | Flutter | **Done** (F-1.1.0). Device QA pending |
| 20 | Navigation after create / leave / Open Group (§2.11) | Flutter | **Done** (F-1.1.1, "finish where you started"): create / join stay on Home or Walkie Group Select; Open Group opens the chat on top of the current screen; exit → nearest Chat List / All Group List / Walkie Group Select / Home, nothing new opened. Device QA pending (Android + iOS) |
| 23 | The group chat screen has no "Exit group" option (commented out in `message_Widgets.dart`); exit from the chat side is only via Group Info | Product decision | **Open** — re-enable only if product wants it (UI change) |
| 24 | After exit, does `/chat-list` still return the left group? The app only calls `refreshChats()` (no local remove), so the row disappears only if the server drops it | Backend confirm | **Open** |
| 25 | Real-time block: emit `user_blocked` / `user_unblocked` to **both** users' personal rooms on `POST /blockUser` / `POST /unblockUser` | Backend | **Open** — Flutter already listens (F-1.1.8, §1.6); until then the blocked side updates via chat-list events, the 4 s check, the first `BLOCKED` ack, resume or reconnect |
| 27 | Send the "X left / removed" system message live to all members, also those who archived the group | Backend | **Open** — Flutter fetches it on `member_left` / `member_removed` meanwhile (F-1.2.1, §2.7) |
| 26 | Block must not hide history: `GET /private-chat/:chatId/messages` and `/private-chat/peer/:id/messages` keep returning the old messages (with `blockStatus`) for a blocked pair | Backend | **Open** — Flutter shows a local copy of the last 50 messages meanwhile (F-1.1.8) |
| 21 | Join with a code you already belong to: does `/joinGroup` return `status: false`? (`true` would show the "Joined" sheet) | Backend confirm | **Open** |
| 22 | Clean-ups found in the recheck (not scheduled): `GroupController.exitGroup` sends the pref key `"userId"` instead of the id (dead code, `confirmAndExitGroup` unused); `handleJoinGroup` is empty; camera QR join refreshes the list twice; `Routes.GroupsList` registered twice in `app_pages.dart`; `DialogBox.showCreateGroupBottomSheet` unused; `CreatedGroupUi` / `NewlyGroupUi` (Home cards L2 / L3) are not rendered anywhere (2026-11-07 recheck) (delete group now follows the §2.11 rule, F-1.1.2) | Flutter | **Open** (list only, no change) |

### 7.1 Detailed questions / requests for the backend

When an item is answered, write the answer under it, update its status in the table above, and keep the entry until the change has shipped.

**#1 Attendance vote counts in real time.**
- When a member votes, changes or removes a vote, which event is sent, and to which room?
- Does every group member receive it, or only the admin who opened "View Attendance" (`attendance:subscribe`)?
- **Needed:** on every change, emit to `group_{groupId}`. `version` must increase on every change.
  ```json
  // event: "attendance:updated"
  { "pollId": 31, "groupId": 12, "version": 7,
    "poll": { "id": 31, "counts": { "total": 5, "byOption": { "opt_1": 3, "opt_2": 2 } } } }
  ```

**#2 Member events.**
- Is `member_removed` / `member_left` still sent to `group_{groupId}`, with `{groupId, userId, removedBy, isKicked, message, timestamp}`?
- Is it also sent to the removed user?
- Which event and payload are used when a member is **added**?

**#3 Refresh token.**
- Does the login / OTP-verify response return a refresh token, and in which field?
- What is the exact refresh endpoint, method, body, response (new access token field, expiry)?
- What does it return when the refresh token itself has expired?

**#4 `GET /archived`.**
- Does it return private **and** group chats, with the same fields as `/chat-list` (incl. `groupStatus`, `unreadCount`) and `isArchived: true`?
- Is paging the same as `/chat-list` (`page`, `limit`, `pagination.hasNextPage`)? What is the max `limit`?

**#5 Group message sent twice.** One group message arrives as both `receive_group_message` and `receive_message` on `/chat`. Can a client opt in to only `receive_group_message`, for example with a handshake flag?

**#6 Cursor history and catch-up.** Keep `page` for old builds and add:
```
GET /private-chat/:chatId/messages?before=<oldestId>&limit=20   (newest first, pagination.hasMore, oldestId)
GET /getGroupMessageHistory?groupId=12&before=<oldestId>&limit=20
GET /private-chat/:chatId/messages?after=<newestId>&limit=50    (oldest first, pagination.hasMore)
GET /getGroupMessageHistory?groupId=12&after=<newestId>&limit=50
```

**#8 Mark as unread.** After `POST /mark-unread`, does `/chat-list` return `isMarkedUnread: true` on all of the user's devices? Is it cleared automatically on `mark_seen` / `POST /mark-read`?

**#9 `POST /mark-viewed`.** What exactly does it clear: only the home "Chatting" dot, or also `unreadTotalCount` / per-chat counts? Is there an event so a second device clears its dot too?

**#10 Forward storage.** The app calls `POST /forward/message` **and** emits socket `forward_message` per target. Confirm the server never stores the forward twice, and tell us which one to keep.

**#11 `/forward/list`.** Return `recentChats` with the same fields as `/chat-list` (`chatType`, `chatId`, `groupId`, `user.id`, `name`, `profileImage`, `isPinned`, `isArchived`, `isBlocked`, `lastMessageAt`) plus `page` / `limit`. Leave out blocked users and groups the user has left.

**#12 Media URLs.** Send relative paths (`uploads/...`) in socket and API payloads. Absolute `fgtracker.in` URLs hit a dead DNS record and time out.

**#13 Group status.**
- Is `groupStatus` (`"active"` / `"deactivated"`) the field to trust, and can `isActive`, `isDeactivated`, `status` and `groupStatus` never disagree?
- In `group_status_updated`, is `status` a boolean or a string? The v2.6.0 example has the key twice.
- Is the event also sent to members' personal rooms (members who don't have the group open)?

**#15 Private chat push payload (urgent).**
- The v2.8.0 §14.3 private example sends `chatId`, `conversationId`, `senderId`, `receiverId`, but **no `memberData`**.
- The app builds the chat screen from `memberData` (JSON string of the sender: `id`, `name`, `mobileNo`, `profileImage`). Without it, tapping a private notification does nothing.
- **Question:** is `memberData` still sent in production? If yes, please add it to the guide's example. If not, please add it back (or send `senderName` + `senderImage` + `senderMobileNo`, and we'll build from those).

**#17 Forward target key.**
- The v2.8.0 §6.2 example uses `{ "type": "private", "receiverId": 3 }`. The app sends `{ "type": "private", "userId": 3 }` (and it works today).
- **Question:** does the server accept both keys? Which one should new builds send?

**#18 Removed member detection.**
- The app shows "You're no longer a member" when `GET /getMembers?groupId=` returns a non-empty list without the caller. Does it always return **every** member, including the caller, with no paging or limit?
- Are `user_removed_from_group` and `group_left` emitted on the `/chat` namespace (that's where the app listens)?

**#25 Real-time block / unblock.**
- Today a blocked user only learns about the block when a send is rejected (`BLOCKED`) or the chat is reopened.
- **Needed:** after `POST /blockUser` / `POST /unblockUser` succeeds, emit to the personal rooms of **both** users (any of `/chat`, `/privateChat` or the chat-list namespace; the app listens on all three):
  ```json
  // event: "user_blocked" | "user_unblocked"
  { "blockerId": 42, "blockedUserId": 9, "chatId": 77, "timestamp": "2026-11-17T10:00:00Z" }
  ```
- Also keep `isBlocked` / `blockedByMe` correct per user in `chat_list_updated` and `GET /private-chat/:chatId/messages` (`blockStatus`).

**#26 Block must not hide history.**
- After a block, reopening the chat shows no old messages on either side: the history endpoints seem to return an empty list for a blocked pair.
- **Needed:** like WhatsApp, a block only stops **new** messages. `GET /private-chat/:chatId/messages` and `GET /private-chat/peer/:peerUserId/messages` must return the existing messages (normal paging, `before` / `after`) plus `blockStatus` for both users.
- Please confirm what the endpoints return today for a blocked pair (empty list, `status:false`, or 403?).

**#27 "X left" system message to every member, archived too.**
- When a member leaves or is removed, the "X left" system message reaches normal groups live, but members who **archived** the group only see it after reopening the chat.
- **Needed:** emit the system message (`receive_group_message`, `messageType: "system"`) to the group room `group_{groupId}` for **all** members, whatever their archive / mute state. Archive must only affect the chat list, never message delivery.

**Still waiting for answers (not covered in v2.8.0):** #10 (forward double storage), #11 (`/forward/list` fields + paging), #12 (relative media URLs).

#### Answers received (backend v2.8.0, 2026-11-06)
| # | Answer | Flutter follow-up |
|---|---|---|
| 1 | `attendance:updated` goes to `group_{groupId}` and `user_{userId}`; 200 ms debounce; `version` always increases. Payload: `poll.counts.total` / `byOption`. Admin detail room sends `attendance:vote_changed`. | Already supported. Verify on device. |
| 2 | Removed: `member_removed` to the group; `user_removed_from_group` + `member_removed` to the removed user. Left: `member_left` to the group, `group_left` to the leaver. Added: `group_updated` / `group_info_updated` + `chat_list_updated` to the new member. | Group side already supported. Removed-user screen: #14. |
| 3 | No refresh token. Single 90-day JWT. On `TOKEN_EXPIRED`, send the user to OTP login. | Replace the retry with logout → OTP login (needs approval: Login flow). |
| 4 | `GET /archived`: private + group, same DTO as `/chat-list`, `isArchived: true`, `archivedAt`, standard pagination, `limit` max 100. | Switch Archive screen. |
| 5 | Dual emission is kept. Listen to `receive_group_message` only, or dedupe. | Already dedupes. Closed. |
| 6 | `before=<id>` (older, `pagination.hasMore`, `oldestId`) and `after=<id>` (newer) on both history endpoints; `page` stays. | Switch paging + resync. |
| 8 | `POST /mark-unread` stored in DB, `isMarkedUnread: true` on all devices, cleared by `mark_seen` / `POST /mark-read`. | Build server mark-unread. |
| 9 | `POST /mark-viewed` clears only the home Chats dot (not per-chat counts); other devices are told via `/location`. | Call it when the Chats screen opens. |
| 13 | `groupStatus` is authoritative; booleans always match. `group_status_updated` → group room; personal rooms get `chat_list_updated` with `groupStatus`. | Already supported. Closed. |
| — | §14: server never notifies the sender (user id, receiver id and device token checks) and skips muted groups. App should hide the banner for the open chat and for `senderId == me`. | #16. |

### 7.2 Old working notes

Earlier analyses, one-off backend requests, test cases and question lists are kept for history in `docs/archive/chat/`. **They are not maintained.** Everything still current is in this guide.

---

## 8. Temporary diagnostics (remove after device QA)

Debug-build-only logs, all marked with a `TODO(...)` tag. Filter with `flutter logs | grep "<prefix>"`.

| Prefix | Tag | Covers |
|---|---|---|
| `[RT]` | `TODO(rt-diagnostics)` | Live attachments / voice (upload responses, socket payloads, play) |
| `[CL]` | `TODO(cl-diagnostics)` | Chat list counts, archive, typing, delete |
| `[GC]` | `TODO(gc-diagnostics)` | Group member removal, attendance live events |
| `[FWD]` | `TODO(fwd-diagnostics)` | Forward list |
| `[VM]` | — | Voice player (`GlobalAudioController`) |
| `arcLog` | `TODO(arc-diagnostics)` | Archive actions |

Remove them all in one cleanup commit after QA, by searching for `TODO(` plus the tag.

---

## 9. Change log
| Version | Date | Change |
|---|---|---|
| F-1.3.1 | 2026-11-26 | **Group Chat List & Home Red-Dot Parity (§6.2, §6.3):**<br>1. **Group unread preservation (`seenAt IS NOT NULL` on Backend):** Delivery creates rows in `message_reads` with `seenAt: null`, which previously caused `getUnreadCount`, `getBatchUnreadCounts`, `getGroupChats`, `getGroupChatList`, and `hasUnreadGroupMessages` to return `0` / `false` for online members while Private chats stayed unread (`status IN ('sent','delivered')`). All five queries now filter `seenAt IS NOT NULL` (and `getGroupChats` / `getGroupChatList` exclude `system` messages, `isDeletedForEveryone`, and pre-`joinedAt` messages).<br>2. **Unified group vs private chat list handling (Frontend):** `ChatListController` and `ChatListScreen` now use `_isGroupChat` / `ChatListRules.isGroup` across all list actions (`mute`, `unmute`, `pin`, `unpin`, `archive`, `unarchive`, `markChatAsRead`, `deleteChat`), row taps, and marker sync; `_handleFullChatListSocket` and search/page-2 API merges now go through `_mergeServerRow` (`_mergePrivateChat` + `_wasReadLocally` guard) so group unread badges are never dropped on sync or socket pushes.<br>3. **Raw group message & listener safety:** `PrivateChatModel.fromJson` reads top-level `senderId`/`senderName`; `_prepareNewRow` sets initial `unreadCount = 1` for new raw peer/group messages; `SocketMessageService.releaseGroupChatEvents` removes only group-screen handlers by reference so `ChatListController` keeps receiving `group_updated`, `group_info_updated`, `group_chat_cleared`, `member_removed`, `member_left`, `user_removed_from_group`, and `group_left` (plus unified `chat_removed`/`chat_cleared` scoping via `_matchesRemovalPayload`).<br>4. **Group marker sync:** `clearManualUnreadForGroup`, `markChatAsUnread`, chat removals/clears, and `GroupMessageController.onInit` (`clearUnreadForOpenedChat`) keep `NotificationMarkerService` synchronized identically for Private and Group chats. |
| F-1.3.0 | 2026-11-18 | **Forward screen new look (§4.1.1, UI only):** Calls-style app bar with the shared back button, one search field in the body (no app-bar search icon), Back clears an active search first, selected strip, coloured initial avatars, selected-row highlight, floating send button. **Attendance cards can't be forwarded (§5.1):** `ChatScreenRules.menuOptions` leaves out Forward for `attendance` / `attendance_poll`; both long-press menus (private + group) read it. Test: `test/chat_screen_logic_test.dart` "attendance cards have no Forward option". **Voice to text:** the "Speak now…" hint and warnings under "Listening…" (`features/voice_input/widgets/listening_view.dart`) and the "Your message" box + hint on the review card (`text_review_view.dart`) are removed. |
| F-1.2.9 | 2026-11-18 | **False "Couldn't refresh · Retry" fixed for real (§12.2.1, §1.2; BUG-CL-10…16, BUG-CS-24…31).** Part 0 root causes: the chat list had none of the F-1.2.8 rules and one try/catch around API + processing; only a full page-1 load cleared its flag (sync / socket list never did); search raised the main bar; the group `/chat` connect handler (fires on the FIRST connect) started a second parallel first-page load (F-1.2.8 regression); the join timer ignored a loaded new chat; socket "joined" without chatId + the API failure counted twice; a failure before the cache read showed an instant bar; `Future.timeout` threw late answers away. Fix: one shared `RefreshBarState` + soft timeout + in-flight guards + `HttpGetException` (same message, plus the real Dio type / status) + bar above the list. Tests: 68 new (refresh_bar_state, chat_list_refresh_bar, chat_refresh_bar RB-C, refresh_bar_widget), every rule proven by a mutation check. E2E file `integration_test/chat_refresh_bar_e2e_test.dart` (not run: no device). Also: 3 tests broken by the env commit (const `socketUrl`) compile again via `SocketMessageService.debugSocketUrlOverride`. |
| F-1.2.8 | 2026-11-17 | **Fix: "Couldn't refresh · Retry" appeared inside an open chat after ~10 s** although the chat worked (§12.2.1). Cause: the history request now has a 10 s timeout; one slow or failed request showed the bar, and a late failure could show it even after another load had succeeded. Now: no bar once a load succeeded; with messages on screen the first failure retries quietly after 2 s and the bar shows only if that fails too; an empty chat still gets the full error at once; a group reconnect loads the history if it never loaded (the bar then hides). Files: `MessageController.dart`, `GroupChatController.dart`. Test `test/chat_qa/chat_refresh_bar_test.dart` (3, fails with the old behaviour). |
| F-1.2.7 | 2026-11-17 | **App cache for the chat list, Archived, New chat and the Status strip (guide 07, §13 here):** last list shown at once, API refresh merged by id (10 s timeout, "Couldn't refresh · Retry"). Chat-list socket fixes: `private_chat_removed` / `_cleared` also remove Archived rows; a bad `archived_private_chats` payload no longer clears Archive; the full-list event keeps rows with a pending action and never re-adds a pending delete; a failed load is no longer swallowed. New-chat static contact cache tied to the user (account switch). Status: expired items never shown from the cache; the permanent controller is emptied on logout. Chat screen cache (§12) unchanged. |
| F-1.2.6 | 2026-11-17 | **Chat screen look, WhatsApp style (UI only, private + group; no API, socket or logic change):** my bubbles light lavender with a purple outline, received white, all corners rounded (no tail); no avatars beside received bubbles (private: app bar opens the profile; group: tap the sender name); group sender names in a fixed colour per sender (`senderNameColor`); name shown only on the first message of a run by the same person (run ends at another sender, a system / call-log line or a new day; was: within 60 s); speaker icon inside received text bubbles before the time (`ChatInlineListenButton`, same `playAudio`), the "Listen" row under the bubble now only for captions / documents (`ChatMessageActionRow.showListen`); system lines ("X added Y") white pill with names bold; date chip white; deleted message lighter grey. **Images no longer squashed:** `memCacheHeight` removed (width + height forced every photo into a 600×600 / 150×150 square); a single photo is shown in its own shape (`ChatImageAspectBox`, ratio 0.55–1.4, remembered per URL) instead of a fixed 220×200 box. Files: `ChatItem.dart`, `ChatList.dart`, `chat_translation_widgets.dart`. Tests: chat suites, no new failures. |
| F-1.2.5 | 2026-11-17 | **Device check of the cache + fewer `mark_seen` (§12.4.1, §2.5):** log from the CPH2381 confirmed the cache works (group 252: cache shown at 124 ms, API ~2 s). Cache / perf logs switched to `debugPrint` (they were in DevTools only) and the box is opened at app start (`ChatMessageCache.warmUp()` in `main.dart`). Group `mark_seen`: removed the second identical emit on open (`initializeGroupChat`; `init()` already sends it) and nothing is sent when there are no new ids (close). Release logs already off (`main.dart` silences `debugPrint` in release; Dio logger and `[ARC]` / `[CL]` / `[SEEN-DBG]` are debug only). Repeated seen / chat-list events come from the server (several event names × two namespaces) → backend items below. |
| F-1.2.4 | 2026-11-17 | **Chat screen Hive cache (§12, §1.2, §1.6, §2.2):** private and group chats open instantly from an encrypted on-device copy (last 50 messages per chat, 30 chats LRU, `cacheVersion`); the API refreshes in the background (10 s timeout) and is merged by id; "Couldn't refresh · Retry" bar instead of a spinner when it fails. Socket changes are saved via `updateMessageStream`. `PrivateChatCache` (SharedPreferences) migrated and removed. Logout wipes the boxes + key (one call in `LogoutUser.clearSessionAndSockets`, approved). `private_chat_cleared` on the list socket also drops that chat's copy (list callback unchanged). Chat list and contacts untouched. Packages `hive_ce`, `hive_ce_flutter`, `flutter_secure_storage`. New string `chat_refreshFailed` (20 locales). `[CHAT-PERF]` timings (debug only). Tests `test/chat_qa/chat_message_cache_test.dart` (19); old CACHE-01…07 moved there from `block_realtime_test.dart`. |
| F-1.2.3 | 2026-11-17 | **Archived group opens; Add Members keyboard smooth:** (1) tapping an archived group (row or quick-profile "Message") now opens the group chat, same arguments as the main list (§6.3); private rows unchanged. (2) Add Members search: no rebuild of the whole sheet on each keyboard frame (`MediaQuery.sizeOf` + `_KeyboardAwareSheet`), list stays above the keyboard, Group Info page no longer re-lays out behind it (§2.10). Logic unchanged. Files: `ArchivedChatsScreen.dart`, `ChatGroupProfile_Screen.dart`. No automated test (screens need live controllers): manual RS-13, RS-14. |
| F-1.2.2 | 2026-11-17 | **Crash fix: opening a group (often from a notification) showed the red "setState() or markNeedsBuild() called during build" screen (§2.1).** `GroupMessageController.onInit` now defers the steps that touch other screens' Rx values (translation reset, chat-list unread, `initializeGroupChat`) until after the current frame (`_runAfterBuild`). No other behaviour change. Regression test `test/chat_qa/group_open_during_build_test.dart` (fails with the old order). |
| F-1.2.1 | 2026-11-17 | **"X left" shows live in archived groups (§2.7, #27):** the open group chat fetches newer messages when `member_left` / `member_removed` / `group_left` / `user_removed_from_group` arrives for it (0.8 s and 3 s). New app-level `groupMemberChanges` stream on `/chat` via `onAny` (survives the existing `off(event)` calls). Additive only: no existing function changed. Same code on Android and iOS. Files: `Socket_Message_Services.dart` (`groupMemberChanges`, `_registerGroupMemberChanges`), `GroupChatController.dart` (`_listenMemberChangeMessages`, cancel in `onClose`). Tests `group_member_left_test.dart` (3 pass). Backend item #27. |
| F-1.2.0 | 2026-11-17 | **Message Info & seen / delivered (§11):** WhatsApp-style group Info (Read by / Delivered to with time, "N remaining", live); one app-level receipt listener (`groupReceipts`) and one aggregation for bubble + Info (`message_receipts.dart`); group `mark_seen` sends `messageIds` + `readAt`; new group `mark_delivered` (any screen, bulk after load); duplicate group messages / typing handled once (fixes the ×7 / ×20–30 handling); group `receiverId: null`. Backend contract in §11.6 (backend fixing). BUG-RT-03, BUG-CS-13, BUG-CS-16 fixed in code; BUG-05 open until MI-03 / MI-04 pass on phones. Temporary `[SEEN-DBG]` logs. |
| F-1.1.9 | 2026-11-17 | **Group chat messages no longer go blank (BUG-CS-18, §10):** `ChatScreenRules.merge` returned the caller's own list when a page held nothing new, and `_messages..clear()..addAll(...)` then emptied the chat. That happened after add / remove member, group rename / icon, app resume and socket reconnect. It now always returns a copy. Files: `chat_screen_logic.dart`, tests `group_chat_blank_messages_test.dart` (new), `chat_screen_logic_test.dart`. |
| F-1.1.8 | 2026-11-17 | **Real-time block (§1.6, #25):** a `BLOCKED` send ack now switches the open chat to the "blocked" banner at once (was: toast, then silent failures until the chat was reopened). Listens to `user_blocked` / `user_unblocked` (+ aliases) on all chat sockets; re-reads `blockStatus` on resume, reconnect, chat-list events for the open chat and every 4 s while it is open (so the blocked person sees it live). Old messages no longer vanish after a block: local copy of the last 50 messages per chat shown when the server returns an empty history for a blocked pair. Files: `Socket_Message_Services.dart` (`BlockStatusEvent`, `blockStatusEvents`, `_registerBlockStatus`, `_onSendAck`), `MessageController.dart` (`_onBlockStatusEvent`, `_refreshBlockStatus`, `_startBlockPolling`, `_historyOrCache`), new `private_chat_cache.dart` (last 50 messages, 20 most recent chats), `GetMessage.dart` (`toJson` keeps `audioUrl`, `clientMessageId`). Same Dart code on Android and iOS; tests `test/chat_qa/block_realtime_test.dart` (14 pass). Back / exit path (`onRoutePopped`) unchanged. Backend items #25, #26 opened. |
| F-1.1.7 | 2026-11-16 | **UI polish (no API or socket change):** whole app bar area opens the profile in private and group chat (§1.7); Group info Back / Edit buttons are the same 44×44 white squares (§2.10); Add Members sheet gets a skeleton while loading, two-line rows with the "Saved contact" label next to a filled **Add** button, and a friendly error with Retry (§2.10); the "left" sheet after exit / removal shows only **Done** (no Open Group / Go to Groups, §2.11). Files: `Chat_Screen.dart`, `GroupChatScreen.dart`, `ChatGroupProfile_Screen.dart`, `group_membership_sheet.dart`. |
| F-1.1.6 | 2026-11-13 | **Group Admin Promotion/Demotion, Real-Time Logs, Call Log Unread Permanence & Divider Fixes:**<br>1. **Group Admin Management:** Added `promoteAdmin` (`POST /promoteAdmin`) and `demoteAdmin` (`POST /demoteAdmin`) in `GroupRepo.dart` & `Group_Controller.dart`. In `ChatGroupProfile_Screen.dart`, integrated context-aware popup menu options ("Make group admin" for admins/creator, "Dismiss as admin" for creator, and "Remove from group") complete with native confirmation dialogs and reactive member refreshes.<br>2. **Real-Time Group Activity Logs:** Backend `updateGroups` captures pre-update state (`oldName`, `oldProfile`, `oldDesc`) so system messages fire reliably for name, icon, and description edits; socket broadcasts deliver to all members in real-time, rendered as centered gray pills (`_buildSystemMessageTile`).<br>3. **Call Log Unread Badge on Restart:** Backend seeds `private_message_status` on call log creation (caller = 'seen', receiver = 'delivered') and `markSeen` self-heals by upserting missing records as 'seen', preventing unread badge from reappearing after app restart.<br>4. **Unread Section Divider Guard:** In `ChatList.dart` (private and group chat), added strict `(controller.unreadCount.value > 0)` check to guarantee unread dividers never display when all messages are read. |
| F-1.1.5 | 2026-11-10 | **Anti-Shuffling & Status Popup UX Stability Fixes:**<br>1. **Chat List Stability:** Fixed bug where opening a chat and tapping back caused the chat list to reorder/shuffle. Updated `ChatListRules.isNewMessage` to reject identical message updates caused by read receipts (`mark-read`, `mark_seen`) or backend `updatedAt` touches; updated `syncLastMessageFromChat` to retain `lastMessageData` and true message `createdAt`; updated `ChatListRules.compare` with deterministic tie-breakers (`chatKey(a).compareTo(chatKey(b))`) and prioritized message creation timestamps over conversation `updatedAt`.<br>2. **Status Section Popup:** Replaced non-modal `OverlayEntry` in `StatusSection._showMyStatusPopup` with a modal `showGeneralDialog` (`barrierDismissible: true`). Tapping anywhere outside or pressing system back immediately dismisses the popup and restores full touch responsiveness without gesture arena conflicts. |
| F-1.1.4 | 2026-11-08 | Added v2.5.0 Frontend Guide parity: UI Flow & Architecture diagrams, WhatsApp-Style Management Operations reference matrix, screen lifecycle controller pattern with critical exit/leave guidelines (no accidental clear_chat on back), and verified REST history endpoints with multi-param alias support. |
| F-1.1.3 | 2026-11-08 | Fixed Group Activation/Deactivation: resolved "type 'String' is not a subtype of type 'bool'" dialog error by adding robust boolean/string/int parsing in `CommonResponse` and `GroupRes`/`GroupsResData`; updated `GroupRepo.updateGroupStatus` to use `Authpost` with JWT Bearer header; added optimistic switch toggle in `GroupController` with automatic rollback on error. |
| F-1.1.2 | 2026-11-07 | Delete group (admin, Member screen) follows the §2.11 rule: `navigateAfterLeave` instead of `Get.offAllNamed(Home)`. Home is no longer rebuilt after a delete, so Home's live-status group counts update on their next refresh. |
| F-1.1.1 | 2026-11-07 | Group navigation (§2.11) changed to "finish where you started" for the 4 start screens (Home, All Groups, Chatting, Walkie-Talkie): create no longer jumps to the All Group List (it used to pull the user out of Walkie); Open Group opens the chat on top of the current screen instead of rebuilding Home → All Group List → Chat; exit also stops at Walkie Group Select and Home and never opens the All Group List by itself; "Go to Groups" in the left sheet now opens the All Group List when not already on it. Navigation tests added. |
| F-1.1.0 | 2026-11-07 | Group navigation (§2.11): create → All Group List; exit → nearest Chat List or All Group List read from the route stack (`navigateAfterLeave`), group removed and list refreshed; Open Group (joined / created sheet) → Home → All Group List → Group Chat with the group list's own arguments; "left" sheet added to L4 / L5 and its button only closes it (#19, #20 done). New open items #23 (no exit in group chat) and #24 (chat list after exit). |
| F-1.0.9 | 2026-11-07 | New §2.11 group membership (create / join / add / remove / exit, rechecked against the code). Success bottom sheet `GroupMembershipSheet` (joined / left / created) replaces the join, create and exit toasts. Open items #19–#22. |
| F-1.0.8 | 2026-11-06 | Removed / left member: "You're no longer a member of this group" banner, sends blocked, history kept (#14). Listens to `user_removed_from_group` and `group_left`. |
| F-1.0.7 | 2026-11-06 | Socket `TOKEN_EXPIRED` twice within 60 s → existing force-logout to OTP login (#3). Protected login files not edited. |
| F-1.0.6 | 2026-11-06 | Mark as unread synced via `POST /mark-unread` and read from `isMarkedUnread` (#8). `POST /mark-viewed` on Chats screen open (#9). Local read guard 2 min → 15 s (#7). |
| F-1.0.5 | 2026-11-06 | Archive loads from `GET /archived` (#4). History uses cursor paging `before` / `after` for private + group, with automatic fallback to `page` (#6). |
| F-1.0.4 | 2026-11-06 | iOS: same foreground suppression via `fgtracker/active_chat` channel + `AppDelegate` `willPresent` (§3.1.1, #16). |
| F-1.0.3 | 2026-11-06 | Android: no foreground chat notification for the chat open on screen or for my own message (§3.1.1, #16). iOS unchanged. |
| F-1.0.2 | 2026-11-06 | Paired with backend v2.8.0. Answers to #1–#6, #8, #9, #13 recorded in §7.1; #5 and #13 closed. New items: #15 (private push payload has no `memberData`), #16 (foreground notification suppression, not built), #17 (forward target key). Token: no refresh endpoint (§0.1). §3.1.1 and §2.7 describe the current gaps. |
| F-1.0.1 | 2026-11-06 | Backend questions moved into §7.1; old chat working notes moved to `docs/archive/chat/` (§7.2). This guide is now the only maintained frontend chat doc. |
| F-1.0.0 | 2026-11-06 | First version: private chat, group chat, notifications, forwarding, long-press options, chat list. Includes reply previews, missing-media card, typing bubbles, history merge / paging / resync, safe parsing, attendance (no delete; per-poll fallback refresh), seen-by rules, keyboard / emoji / back rules, offline send guard, chat-to-chat navigation, notification routing fixes, socket listener scoping, token re-read on reconnect, send ack, delete-for-me isolation, chat-list archive / count / typing / delete fixes, deactivated groups, live member removal, forward recent-chats fix. |

---

## 10. Group chat: messages go blank (BUG-CS-18)

**Status:** root cause found, reproduced by a test and **fixed in F-1.1.9** (§10.4). Phone check still to do. Investigated 2026-11-17 on branch `46Solution`. Bug tracker: [testing/chatting/bug_tracker.md](testing/chatting/bug_tracker.md) → BUG-CS-18.

### 10.1 Symptom
In an open group chat the message list suddenly becomes empty. Going back and opening the group again shows every message, because nothing was deleted on the server: only the screen's list was wiped.

### 10.2 Root cause
1. `ChatScreenRules.merge(existing, incoming)` returns the **same list object** it was given when the incoming page adds nothing new (`chat_screen_logic.dart:110-111`: `return MergeResult(existing, 0, 0, …)`).
2. Three group paths then run `_messages..clear()..addAll(merged.messages)`. Here `merged.messages` **is** `_messages`, so `clear()` empties both and `addAll` adds nothing. The empty list is then pushed to the screen.
   - `GroupChatController.dart:1792-1795`, `getGroupMessages()`: **no guard**. Wipes every time page 1 holds nothing new.
   - `GroupChatController.dart:2752-2756`, `syncNewerMessages()` "Reconcile" block: guard `updated || added > 0`. Wipes when only ticks, seen counts, edits or deletes changed (`updated == true`, `added == 0`).
   - `GroupChatController.dart:2621` (`loadOlderGroupMessages`) and `2677` / `2714` (sync loops) are guarded by `added > 0`, so they are **safe**.
3. Once the list is empty it does not recover. `_onScrollForOlderMessages` returns when `_messages.isEmpty` (`GroupChatController.dart:2513`), and `loadOlderGroupMessages` also returns (`2567`). Only a new socket message adds rows back, and then only that one message shows.

**Proof:** `test/group_chat_blank_messages_test.dart` copies the exact controller statements and runs them with the real `ChatScreenRules.merge`:
```
case: getGroupMessages() again after add/remove member, rename, icon
  Expected: an object with length of <60>
    Actual: []
case: resume / reconnect reconcile … when only ticks changed
  Expected: an object with length of <30>
    Actual: []
```
The two failing cases are kept with `skip: 'BUG-CS-18 …'` until the fix. The guarded older-page path passes.

### 10.3 Every condition checked

| Condition | Can it blank the list? | Path (file:line) |
|---|---|---|
| Add member | **Yes**, when the "X added Y" message has already arrived by socket (or there is none), so page 1 holds nothing new | `ChatGroupProfile_Screen.dart:950` `onMemberAdded` → `getGroupMessages()` → `GroupChatController.dart:1792-1795` |
| Remove member | **Yes**, same way | `ChatGroupProfile_Screen.dart:1182` → `getGroupMessages()` |
| Group name / icon / description edit | **Yes**, same way | `Group_Controller.dart:162` → `getGroupMessages()` |
| Promote / demote admin | No. It only reloads members | `ChatGroupProfile_Screen.dart:1140`, `1160` (`getGroupMembers` only) |
| App background → resume | **Yes**, if any loaded message's ticks or seen count changed meanwhile (very common in groups) | `GroupChatController.dart:2462` → `syncNewerMessages()` → `2752-2756` |
| Socket reconnect / internet off → on | **Yes**, same way | attendance `onReconnect` `GroupChatController.dart:680` → `syncNewerMessages()` → `2752-2756` |
| "Randomly while open" | **Yes**: a reconnect after a short network drop runs the same reconcile with no visible sign | same as above |
| Scrolling up (older pages) | No, guarded by `added > 0` (`2621`). A blank seen while scrolling is the list wiped earlier by resume / reconnect; scrolling then cannot reload it (`2513`) | `GroupChatController.dart:2566-2634` |
| Fast scroll back down | No, nothing changes the list. Jump index is clamped by `scrollable_positioned_list` 0.3.8 | `GroupChatController.dart:1934-1970` |
| New socket message while scrolling | No, it is appended | `GroupChatController.dart:456` |
| Edited / deleted message | No, updated in place. But an edit or delete made while offline sets `updated` and triggers the reconcile wipe on reconnect | `chat_screen_logic.dart:95-104` |
| Media / poll / attendance cards | No parsing failure found. Bad rows become an "unsupported message" placeholder, not an empty list | `GetMessage.dart` (tolerant parsing, §0.3) |
| 1000+ messages | Not a separate cause. The wipe removes all of them the same way | — |
| Controller reset | No. The controller is not recreated. `handleBackPressed` (`GroupChatController.dart:2011-2015`, clears without updating the stream) is dead code for groups (no caller) | — |
| `group_chat_cleared` event without `userId` | Possible separate risk: it clears the list for everyone if the server ever omits `userId`. Not seen in the reported cases. **Ask backend** | `GroupChatController.dart:662-670` |
| Private chat (same pattern) | Latent: unguarded `clear()+addAll(merged)` when the history page holds nothing new compared to messages already on screen | `MessageController.dart:1928-1935` (by peer), `2040-2047` (by chatId) |
| Empty **bubbles** (rows shown but no text) | Not explained by this bug, which empties the whole list. No cause found yet. **Need a screenshot + `[RT]` log of one case** | — |

### 10.4 Fix (F-1.1.9, 2026-11-17)
- **Change:** `ChatScreenRules.merge` returns `List.of(existing)` when nothing is added, so the result is **never the caller's own list** (`chat_screen_logic.dart`, `merge`). Every caller that does `_messages..clear()..addAll(merged.messages)` is now safe, in group and private chat alike. No controller, socket or UI code changed.
- **Not done (not needed):** the extra `List.of(...)` at the 4 call sites (`GroupChatController.dart:1792-1795`, `2752-2756`; `MessageController.dart:1928-1935`, `2040-2047`). With the fix above they can no longer alias, and those two files are being edited by other sessions.
- **Tests:** `test/group_chat_blank_messages_test.dart`, 11 tests, all pass:
  - `merge()` never returns its input: nothing new, empty page, ticks only, new messages.
  - Group: page 1 again after add / remove member, rename or icon (60 stay 60); new "X added Y" message is added; resume / reconnect reconcile with ticks only (30 stay 30, ticks applied); reconnect after an offline edit or delete; older page of duplicates; 1200 messages.
  - Private: a history page that holds only messages already on screen.
  - `test/chat_screen_logic_test.dart`: the old assertion that `merge()` returns the same list (it encoded this bug) now checks for a copy.
- **Still to check on a phone:** add a member, rename the group, background 30 s and resume, internet off and on, scroll up 3 pages and then resume. The list must never go empty.
- **Still open:** empty **bubbles** (row shown, no text) and `group_chat_cleared` without `userId` (§10.3). Neither is fixed by this change.

### 10.5 Android and iOS
| Check | Android | iOS |
|---|---|---|
| Fix code | Same Dart code on both. `chat_screen_logic.dart` has no platform code (no `Platform`, `dart:io` or channels) | Same |
| Unit tests (11, `group_chat_blank_messages_test.dart`) | Pass (platform-independent) | Pass (platform-independent) |
| Build | `flutter build apk --debug` OK, 2026-11-17 | **Not built.** Needs a Mac with Xcode; this PC is Windows |
| Phone check | **Not run yet.** Use manual checklist `CS-11`…`CS-15` ([testing/chatting/manual_testing/manual_checklist.md](testing/chatting/manual_testing/manual_checklist.md)) | **Not run yet.** Same steps; also lock the screen for 1 min (CS-14) |

Nothing in the fix depends on the platform. The iOS-only paths are app resume and socket reconnect: iOS suspends sockets in the background, so CS-14 is the main iOS case. Both paths go through the same `merge()` that is now fixed.

---

## 11. Message Info & Seen / Delivered Status (Private + Group)

> Added F-1.2.0 (2026-11-17). The frontend part is built; the backend team is fixing the group part (§11.6). The results in §11.8 are **not run on phones yet**.

### 11.1 Expected behaviour (WhatsApp style)
- **Delivered** = the message reached that member's phone (socket on any screen, or fetched later). Opening the chat is not needed.
- **Read** = the member opened the group in the foreground and the message was loaded. Opening a chat marks all its unread messages read in one batch.
- Group messages store status **per member** (`readBy[{userId, readAt}]`, `deliveredTo[{userId, deliveredAt}]`), never one flag for the whole group.
- Status only moves forward (sent → delivered → read). A late "delivered" never overwrites "read".
- **Group Message Info** (my messages only):
  - **Read by:** photo, name and read time on the right, newest first. **"N remaining"** under it.
  - **Delivered to:** members who received it but have not read it, with the delivered time. **"N remaining"** under it (not received yet).
  - The sender is never listed. Members who left keep what they reached before leaving, but are not counted in "remaining".
- **Group bubble:**
  - one grey ✓ when sent;
  - grey ✓✓ when delivered to **all** current members;
  - blue ✓✓ when read by **all**.
- **Live:**
  - With Info open, B moves to "Read by" within about 1–2 s. The bubble updates too.
  - After background → resume, or after a reconnect, Info re-reads the API.
- **Time format:** "Today, 10:42 AM" / "Yesterday, …" / "17 Nov 2026, …" (same as Last seen). All labels come from l10n.

### 11.2 Private vs group flow

| Step | Private (worked before) | Group (now) |
|---|---|---|
| Read emit | `/privateChat` `mark_seen {chatId, userId, otherUserId}` + `mark_private_chat_read` | `/chat` `mark_seen {groupId, userId, group_id, user_id, messageIds[], readAt}`. Sent on open (no ids yet), after history loads (all loaded messages from others), for new messages while the group is open (400 ms debounce), on resume and on close |
| Delivered emit | `mark_delivered {messageIds, userId, otherUserId}` | `/chat` `mark_delivered {groupId, userId, messageIds[], deliveredAt}`. **App-level, on any screen.** Each id is sent once per session. Sent for: every group message from someone else reaching `/chat` (`receive_group_message` / `receive_message`); the group's last message in chat-list events; in bulk after the group history or resume sync loads |
| Backend save | per receiver | per member (`readBy`, `deliveredTo`). **Backend, §11.6** |
| Broadcast to sender | `messages_seen_update`, `messages_delivered` on `/privateChat` | `group_messages_seen` / `group_messages_delivered` `{groupId, userId, messageIds[], readAt / deliveredAt}`. The old `messages_seen_update`, `group_message_seen`, `messages_delivered` are still accepted |
| App listens | private chat screen | **One app-level listener** per socket (`SocketMessageService.groupReceipts` stream). The group screen and Message Info subscribe to it and cancel on close |
| Info API | `GET /messages/:id/info?chatType=private` | `GET /messages/:id/info?chatType=group` → `readBy[]`, `deliveredTo[]` with `userId`, `name`, `profileImage`, time |

Event names live in one place: `ReceiptEvents` in `lib/app/modules/Messages/Controller/message_receipts.dart`. If the backend uses other names, change only that class.

### 11.3 Root cause (device logs, 2026-11-17)
- **Backend:**
  - The sender never receives a seen event for group messages.
  - `seenBy` is always `[]`.
  - Delivery is one `isDelivered` flag; there is no per-member `deliveredTo`.
  - Result: the Info API had no readers, so Info showed "Not seen yet" even after reopening.
- **App:**
  1. **Duplicate handling:** one group message was handled about 7×, and `group_stop_typing` 20–30×. The server sends the same thing under several event names and to several rooms, and nothing deduped it.
  2. **Seen listeners:**
     - Two group "seen" listeners replaced each other with `off(event)` (BUG-RT-03).
     - My own `mark_seen` echo was counted.
     - Ids were a mix of int, string and map (BUG-CS-13), so the bubble never turned blue.
  3. **Emits:** group `mark_seen` had no `messageIds`, and the app never sent "delivered" for groups.
  4. **Message Info:**
     - It listened directly on the socket and needed ids that never came.
     - It filled "Delivered" with every member when the API had nothing (BUG-CS-16).
  5. **Group send:** `send_message` sent `receiverId` = the sender's own id.
- **Why private worked:** there is only one receiver. The chat id, the REST read and the private `messages_seen_update` with ids were enough.

### 11.4 What changed in the app (F-1.2.0)
| File | Change |
|---|---|
| `Controller/message_receipts.dart` (new) | **One aggregation shared by the bubble and Message Info.** Contains:<br>• `ReceiptEvents`: the event names.<br>• `normalizeReceiptId`: int / String / `{userId}` / `{_id}` / populated object → string.<br>• `ReceiptUpdate.parse`, with a dedupe key.<br>• `MessageReceipts`: `readMap`, `deliveredMap`, forward-only `applyRead` / `applyDelivered`, `summarize` / `summarizeMaps`, `groupTick`. |
| `Socket_Message_Services.dart` | • Receipt listeners registered once per `/chat` socket (by reference) → `groupReceipts` stream; new `chatConnected` stream.<br>• `markSeen(..., messageIds)` now also sends `readAt`; new `markGroupDelivered`.<br>• Group receive handler kept by reference and deduped by message id (30 s). Group typing deduped (600 ms) for both the screen and the list.<br>• `releaseGroupChatEvents` removes only the screen's handler.<br>• Removed the old `listenSeenUpdate`, `listenGroupMessageSeen`, `listenGroupMessagesDelivered`.<br>• Group sends now use `receiverId: null`.<br>• Temporary `[SEEN-DBG]` logs, debug builds only. |
| `Model/GetMessage.dart` | Parses `readBy` (`read_by`) and `deliveredTo` (`delivered_to`) |
| `GroupChatController.dart` | • Subscribes to `groupReceipts` and cancels on close.<br>• Ignores my own echo; updates per member, forward-only.<br>• Sends bulk delivered + read after history and sync.<br>• `mark_seen` carries the ids of messages from others not yet reported. |
| `widgets/ChatItem.dart` | Group tick = `MessageReceipts.groupTick`. The old `_areAllMembersSeen` is removed. |
| `widgets/MessageInfoSheet.dart` | Group only (**private unchanged**):<br>• WhatsApp layout: Read by / Delivered to cards, time on the right, "N remaining".<br>• State built from the local receipts + the Info API (forward-only merge).<br>• Live updates from `groupReceipts`. An event with no ids → re-read the API (500 ms debounce).<br>• Re-read on resume and reconnect. Subscriptions are cancelled on dispose. |
| l10n | `msgInfo_readBy`, `msgInfo_deliveredTo`, `msgInfo_remainingCount` × 20 languages (`tool/l10n/fragments/message_info.json`) |

### 11.5 Temporary diagnostics
`[SEEN-DBG]` lines, debug builds only. They log:
- every receipt emit payload;
- every seen / delivered event received;
- duplicates dropped;
- updates applied;
- the Info API request and response.

**Remove them before the final commit** (search for `SEEN-DBG` and `seenDbg(`).

### 11.6 Backend fix (to send to the backend team)
**Problem (from device logs):**
- For group messages the sender never gets a seen event.
- `seenBy` stays `[]`.
- Delivery is a single `isDelivered` flag.
- Result: Message Info shows "Not seen yet" for everyone, and the group bubble never turns blue.

**Contract the app now uses:**
1. **Client → server** on `/chat`:
   - `mark_seen {groupId, userId, messageIds[], readAt}`. The `group_id` / `user_id` copies are kept. `messageIds` may be missing on the very first emit when a group opens; treat that as "all messages in this group up to now".
   - `mark_delivered {groupId, userId, messageIds[], deliveredAt}`.
2. **Save per member** on each group message: `readBy[{userId, readAt}]`, `deliveredTo[{userId, deliveredAt}]`.
   - Forward-only.
   - Ignore the sender.
   - A read also counts as delivered.
3. **Broadcast** after saving, to the **sender's personal room and the group room**:
   - `group_messages_seen {groupId, userId, messageIds[], readAt}`
   - `group_messages_delivered {groupId, userId, messageIds[], deliveredAt}`
   - Send each one once, under one event name. Today the same thing arrives under several names and rooms.
4. **Info API** `GET /messages/:id/info?chatType=group` → `data.readBy[]` and `data.deliveredTo[]`, each `{userId, name, profileImage, readAt | deliveredAt}` (ISO UTC).
5. **History** `GET /getGroupMessageHistory` → include `readBy` / `deliveredTo` on my messages, so ticks are right after a restart.
6. **On connect:** mark that user's pending group messages as delivered and broadcast it. The app only knows the messages it loads.
7. **Send one copy of each group message** (one event name, one room). The app now dedupes, but every copy still costs work.

### 11.7 Automated tests
| File | What it checks | Result 2026-11-17 |
|---|---|---|
| `test/chat_qa/message_receipts_test.dart` (new) | • id normalisation<br>• forward-only status, duplicate readers<br>• aggregation: sender, late joiners, left members<br>• tick rule<br>• payload parsing and dedupe key | 19 pass |
| `test/chat_qa/realtime_socket_qa_test.dart` | • RT-09…RT-09f: receipts stream, dedupe across event names, `mark_seen` ids, delivered sent once and never for my own message<br>• RT-12: open / close the group 10× → 1 message handled once<br>• RT-13<br>• RT-14: typing handled once | Pass. RT-01b fails: it is a stale evidence test and fails on HEAD too |
| `test/chat_qa/chat_screen_widgets_qa_test.dart` | • Info: "N remaining"; no fake "Delivered" (BUG-CS-16 fixed)<br>• **Live Remaining → Delivered → Read**; duplicate / other message / own echo ignored<br>• Bubble: blue with `{userId}` maps (BUG-CS-13 fixed); ✓ until delivered to all | 12 pass |

### 11.8 Manual results MI-01 … MI-13
Real-device results only. **Not run yet**: the backend contract is not deployed.

| ID | Case | Android | iOS | Delay | Notes |
|---|---|---|---|---|---|
| MI-01 | Private regression: A sends, B reads → Info shows the read time, blue ticks | Not run | Not run | | |
| MI-02 | Group: A sends; B and C are not in the group → Delivered to B, C; Read by 0 | Not run | Not run | | needs backend |
| MI-03 | B opens the group → B moves to "Read by" live on A's open Info; bubble grey | Not run | Not run | | needs backend |
| MI-04 | C opens the group → C moves to "Read by"; bubble blue | Not run | Not run | | needs backend |
| MI-05 | C offline → "2 remaining"; C comes online → "Delivered to" live | Not run | Not run | | needs backend §11.6-6 |
| MI-06 | Close / reopen Info → B still in "Read by" | Not run | Not run | | needs backend |
| MI-07 | Kill / restart A → Info still right | Not run | Not run | | needs backend §11.6-5 |
| MI-08 | Late joiner D → not listed | Not run | Not run | | the member list has no join time; relies on the API |
| MI-09 | Resume after 1 min / 10+ min | Not run | Not run | | |
| MI-10 | Open / close Info 10×, then B reads → applied once | Not run | Not run | | automated: RT-12 + live widget test |
| MI-11 | Common chat: MI-02 … MI-04 | Not run | Not run | | |
| MI-12 | Types: photo, voice, document, poll, attendance | Not run | Not run | | |
| MI-13 | Hindi / Marathi: labels, time format, no overflow | Not run | Not run | | |

**BUG-05 (group seen)** stays open until MI-03 and MI-04 pass on real phones.

**Known limits:**
- The app has no join time per member, so filtering out late joiners relies on the Info API.
- Until the backend fix, "remaining" counts every current member.

---

## 12. Chat Screen Hive Cache (F-1.2.4)

Private and group chat screens open at once with the messages shown last time, then refresh from the API. **Only the chat screens use it.** The chat list and contacts are not cached and were not changed.

### 12.1 Storage
| Item | Value |
|---|---|
| Packages | `hive_ce`, `hive_ce_flutter`, `flutter_secure_storage` |
| Box | `chat_cache_<myUserId>`, `Box<String>`, **AES-256** (`HiveAesCipher`). One box per account, so a second account on the phone never sees the first one's chats. |
| Key | 32 random bytes, `flutter_secure_storage` key `fg_chat_cache_aes_key`. Android Keystore; iOS Keychain `first_unlock_this_device`. If the key is lost, the box is deleted and started again. |
| Entry key | `private_<peerId>` / `group_<groupId>` |
| Entry value | `{"v": cacheVersion, "chatId"?: "…", "m": [MessageData.toJson …]}`. The newest **50** messages that have a server id, oldest first. |
| LRU | `__lru` index; the **30** most recently saved chats are kept and the oldest beyond 30 are deleted. |
| Version | `ChatMessageCache.cacheVersion` (now 1) is in the box (`__version`) and in every entry. If either doesn't match, the data is cleared instead of being parsed. **Bump it whenever `MessageData.toJson` changes shape.** |
| Registry | Plain box `chat_cache_registry` lists the user box names, so logout can delete every box. It holds no message content. |
| Old cache | Once per box: the user's `private_chat_cache_<me>_<peer>` SharedPreferences copies are imported, then **all** `private_chat_cache_*` keys are deleted. |

### 12.2 Flow
1. **Open.** `MessageController._initializeChat` (private) / `GroupMessageController.onInit` (group) call `_showCachedMessages()`. It is an async read and never blocks the UI.
2. **Cache shown.** The cached messages are merged into `_messages` (`ChatScreenRules.merge`), then the stream updates and the list scrolls to the bottom. The skeleton only shows while the list is empty, so a chat with a cache never shows a spinner.
3. **API.** It runs in parallel and doesn't wait for the cache or the socket. 10 s timeout. The result is merged by id, in whichever order the two arrive.
4. **Save.** Every `updateMessageStream()` schedules a save 1 s later from a snapshot. That covers history, receive, sent, edited, deleted, delivered / seen, reactions and pin / unpin.
5. **Failure.** Empty list → "Couldn't load messages" + Retry. Cached messages on screen → `ChatRefreshFailedBar` ("Couldn't refresh · Retry"), which calls `retryLoadHistory`.

### 12.2.1 When the "Couldn't refresh · Retry" bar shows (F-1.2.9, replaces F-1.2.8)
Same rules on the chat list, the private chat and the group chat:

- **Shows only when** data is on screen, the latest **foreground** load (open, pull, Retry) failed **twice** (the first failure is retried quietly after 2 s) and no sync has succeeded since. A user Retry / pull that fails shows it at once.
- **Only "server not reached" counts:** timeout, connection error, 5xx, `status:false`. A 4xx (incl. 401 → existing force logout) or a parse / processing exception is never "Couldn't refresh" (logged with its stack; an empty screen still gets the full error view).
- **Background loads never raise it** (socket reconnect, resume, socket refetch, `/chat` connect): they can only clear it.
- **Any success clears it:** full load, incremental `/chat/sync`, `syncNewerMessages` (re-join / reconnect gap fill), the socket full list `private_chats`.
- **Soft timeout (10 s, `ChatScreenRules.historyTimeout`):** the load counts as failed and the loader stops, but the request is kept; a late answer is applied (merge by id) and clears the bar.
- **One first-page load at a time** (in-flight guard everywhere, incl. group `/chat` connect, which fires on the FIRST connect too).
- **Each attempt counts once** (socket "joined" without chatId / the join timer and the API failure of the same attempt).
- **A failure before the cache read finished** waits for the read (no instant error over messages that are about to show).
- **New chat:** a by-peer answer without `chatId`, or a 404, is an empty chat ("No messages here yet"), never an error; the join timer does nothing once history answered.
- **Search** has its own error state and always asks for page 1; a failed `nextPage()` rolls `currentPage` back.
- **Back:** a late answer after Back changes nothing and never overwrites the cache.
- One shared helper, `RefreshBarState` (`chat_screen_logic.dart`), used by the chat list, private chat and group chat. Debug log: `[REFRESH-BAR] … FLAG … -> true/false (reason)` and `[HTTP-GET] <path> failed after <ms>: dio=<type> status=<code>`.

<details><summary>Old F-1.2.8 text (superseded)</summary>

- Never once a history load (or the first page after a reconnect) has succeeded: a later or late failure is silent (log only).
- With messages on screen, the first failure is retried quietly after 2 s. The bar shows only if that retry fails too.
- An empty chat gets the full "Couldn't load messages" view at once, as before.
- Tapping **Retry**: a failure shows the bar again at once (no extra quiet retry).
- The bar hides when a later load succeeds. Private chat: the quiet retry or the socket re-join. Group chat: the quiet retry or the `/chat` reconnect, which now loads the history if it never loaded.

</details>

### 12.3 Rules
- Merge by message id only. An empty or partial response never replaces the list, and an empty list is never saved over an existing copy.
- Paging (`before=`) adds older messages and never resets the list. Only the newest 50 are saved, so older pages are not kept.
- Pending messages (no id) are not saved. They stay on screen and are replaced by the server copy (`clientMessageId`) without duplicates.
- After Back (`onRoutePopped` / group `handleBackPressed`) saving stops. A late API response can't overwrite the 50 saved messages with a part of them. The save already scheduled keeps its snapshot.
- `group_updated` and member added / removed never touch the message list or the cache.
- Clear: private `private_chat_cleared` (open chat, or the chat-list socket by `chatId`), group `clearGroupChat` / `group_chat_cleared`.
- Logout: `ChatMessageCache.clearAll()` deletes every box, the registry and the key. It has a 3 s cap and never throws.
- Every cache call has its own try/catch. If the cache fails, the chat works as before: it waits for the API.

### 12.4 Known limits
- A chat cleared **from the chat list on another device while the app was closed**, or a conversation deleted from the list, may show its cached messages until the next `private_chat_cleared` / clear event. Server-side clear state is not in the history response yet.
- Group clear from the chat list (not from the open group) does not drop the group copy, because the chat list was out of scope.

### 12.4.1 Warm-up and debug logs
- `main()` calls `unawaited(ChatMessageCache.warmUp())` after `Global.init()`. When someone is logged in, the box opens in the background, so the first chat after a cold start doesn't wait for Hive / the Keystore.
- Debug builds print `[CHAT-CACHE] ready (N entries)`, `load group_252: 50 msgs` or `no copy (first open)`, `saved group_252: 50 msgs`, and any `… failed: <error>`. These go through `debugPrint`, so they show in `flutter run` / logcat.
- **After adding the packages, use a full rebuild (stop + `flutter run`), not hot restart.** Hot restart doesn't register the new native plugin (`flutter_secure_storage`), so the cache fails (`MissingPluginException` in `[CHAT-CACHE] … failed`) and the chat works as before, without the cache.

### 12.5 Measuring open time (`[CHAT-PERF]`, debug builds only)
`ChatOpenPerf` logs each step once, measured from controller `onInit` (Android Studio / `flutter logs`, filter `CHAT-PERF`):

```
[CHAT-PERF] group_77 open: 0 ms
[CHAT-PERF] group_77 cache shown: 18 ms (50 msgs)
[CHAT-PERF] group_77 API done: 640 ms
[CHAT-PERF] group_77 list rendered: 660 ms (60 msgs)
```

**Checklist (do it on Android and on iOS):**
1. Use a debug or profile build with logs on. The test group needs **1000+ messages**, plus one private chat.
2. **Before** (build from the commit before F-1.2.4, or after logout, which empties the cache): kill the app, start it cold, open the group. Note the time until messages are visible. The old build has the existing `[CHAT-PERF]` / `HISTORY DEBUG` elapsed logs; otherwise use a screen recording at 60 fps.
3. **After:** open the group once (it fills the cache), kill the app, start it cold, open the group. Note `cache shown`, `API done` and `list rendered`.
4. Repeat steps 2–3 five times and record the median, for the group and for the private chat.
5. Airplane mode: open a cached chat. The messages show, then after ≤ 10 s the "Couldn't refresh · Retry" bar appears and never spins. Turn the network back on and tap Retry: the bar goes away.
6. Send, edit, delete, react and pin, then kill the app and reopen: everything shows from the cache before the API returns.
7. Clear chat, then reopen: empty. Log out and in as another account: none of the first account's chats show.

| Device | Chat | Before: messages visible (ms) | After: cache shown (ms) | After: API done (ms) | After: list rendered (ms) |
|---|---|---|---|---|---|
| Android … | group 1000+ | | | | |
| Android … | private | | | | |
| iOS … | group 1000+ | | | | |
| iOS … | private | | | | |

---

## 13. App cache: chat list, Archived, New chat, Status (F-1.2.7)

These screens use the shared app cache, **not** the chat screen cache of §12. Full rules: [07_APP_CACHE_FRONTEND.md](07_APP_CACHE_FRONTEND.md).

| Screen | Area | Notes |
|---|---|---|
| Chat list | `chat_list` (50 rows) | Lossless codec (`chat_list_cache_codec.dart`); merge keeps live rows (R3); saving starts after the cache read |
| Archived | `chat_archived` (100) | Unarchiving the last chat saves the empty list |
| New chat | `fg_contacts` (1000) | Only FG users of the phonebook; phonebook-only entries are never stored |
| Status strip | `status_mine` / `status_feed` | No viewer lists; expired items dropped on read and on resume |

Socket behaviour of the chat list is unchanged, except for the four fixes in the change log (F-1.2.7).


---

## 14. Chat List Unread Sync, Marker Guards & Status Events (F-1.3.2)

- **Shared List & Lifecycle Listeners (`Socket_Message_Services.dart`):**
  - `_registerListRemovalListeners` and `_registerListGroupLifecycleListeners` are registered on both `/chat` and `/privateChat` sockets.
  - Listens to `status:new` and `status_new` cross-namespace events to update `StatusSocketService.onNewStatusEvent` and refresh `StatusFeedController`.
- **Chat List Unread Preservation & Marker Sync (`chat_list_controller.dart`, `chat_list_logic.dart`, `chatlist_screen.dart`):**
  - `ChatListController` registers `hasLocalPrivateUnreadCheck` and `hasLocalGroupUnreadCheck` on `NotificationMarkerService.instance` (cleared in `onClose`) so stale backend marker heartbeats cannot clear the Chatting red dot while verified local unreads or manually-unread rows remain.
  - `ChatListRules.mergeUnreadCount` preserves `local > 0` when the server returns `0` if `!readLocally && !isViewing`.
  - `matchesGroupRow` matches `c.groupId == gid || c.id == gid || c.chatId == gid`, and `chatlist_screen.dart` uses `ChatListRules.isGroup(chat)` consistently.
