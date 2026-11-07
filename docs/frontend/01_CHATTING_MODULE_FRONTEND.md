# FG Tracker Chat Module: Flutter (Frontend) Implementation Guide

> **Document version:** `F-1.1.2` · **Date:** 2026-11-07 · **Branch:** `46Solution`
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
- **`GET /private-chat/:chatId/messages?page=N&limit=20`**, newest first.
- First load **merges** with messages already received over the socket (dedupe by id, oldest-first order).
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
  - Emits `editMessage`.
  - Listens to **both** `messageEdited` and `message_edited`, keyed by `messageId` or `id`; text is updated in place (ticks kept).
- **Delete:**
  - Emits `delete_message {messageId, userId, deleteType: "for_me|for_everyone", otherUserId}`.
  - `message_deleted` with `for_me` removes the bubble **only if `userId` is me**.
  - `for_everyone` → "This message was deleted": text, media, caption and reply cleared, pin banner removed.
- **Pin:** emits `pin_message` / `unpin_message`; listens to `message_pinned` / `message_unpinned`.
- **Clear chat:**
  - Emits `clear_private_chat {chatId}`.
  - `private_chat_cleared` clears the open chat **only if the id matches** (or this screen asked for it).
- **Block:** `POST /blockUser`, `POST /unblockUser`. Block state comes from the history response (`blockStatus`).

### 1.7 Screen behaviour
- **Keyboard:** `adjustResize`, input above the keyboard. The emoji panel matches the last keyboard height (max 40% of the screen).
- **Back / swipe:** closes the emoji panel first; the iOS swipe-back works.
- **Swipes:** right = reply; **left on a received text or caption = translate** (Hindi ↔ English). **Listen** (text-to-speech) is under received messages.
- **Search** in chat searches loaded messages only.

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

### 2.2 History, paging, sync
- **`GET /getGroupMessageHistory?groupId=&page=N&limit=20`** (any order; the app sorts by time).
- Same merge / paging / resume rules as §1.2.
- **Reconnect** (`connect` on `/chat`) → re-sync attendance polls + fetch newer messages.

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

### 2.8 Deactivated groups (backend v2.5.0)
- **Read from** `/chat-list` rows (`groupStatus`, `isDeactivated`, also inside `group`) and the open arguments (`groupStatus`, `isDeactivated`, `isActive:"false"`).
- **Live:** `group_status_updated {groupId, isDeactivated, groupStatus, isActive}` on **all three sockets** (one shared map; the live value wins).
- **UI:**
  - The input bar becomes "ℹ️ This group has been deactivated by the Admin".
  - All sends (text, voice, file, video, location, contact) are blocked.
  - The chat list shows a grey **"Deactivated"** chip.

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
- **Left:** "You left the group", the member count without you. **Go to Groups →** on the All Group List only closes the sheet; anywhere else (Chat List, Home, Walkie Group Select) it opens the All Group List on top. **Done** only closes the sheet.
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
| Forward | All | Forward screen (§4) |
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
2. **New message** = a **newer** last-message id; equal or older = not new. A "delete for me" that sends the previous message never bumps the badge or moves the row.
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

### 6.3 Open chat ↔ list
- The open chat pushes its real last message to its list row after a **delete**, a **clear**, and on **close**.
- On close: unread for that chat → 0 locally; `mark_private_chat_read` / `mark_seen` are sent.

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
