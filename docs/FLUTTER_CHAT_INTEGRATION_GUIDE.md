# WhatsApp-Style Chatting Module: Complete Flutter Integration Guide & Technical Specification

> **Document Version:** `v2.6.0` (Complete Architecture: Real-Time Sockets, Archive State Integrity, Instant Unread Reset, Inactive Group Handling & Full Production Parity)  
> **Previous Versions:** `v2.5.0` (Inactive Group Support in Chat List & Sockets), `v2.3.0` (Advanced Delete Isolation, Edit Standardization & Clear Chat Media), `v2.1.0` (Unified Architecture & Aliases), `v1.0.0` (Legacy Dual-Tab System)  
> **Backend Environment:** Node.js, Express, Sequelize (MySQL/MariaDB), Socket.io  
> **Backend Compatibility:** 100% Backward Compatible (Zero breaking changes for existing Flutter builds)  
> **Verification Status:** 100% Tested & Verified (All unit tests and integration routes validated)

---

## Complete Version Changelog & Backward Compatibility Matrix

| Feature / Action | v1.0.0 (Legacy App) | v2.1.0 (Unified Standard) | v2.3.0 (Parity & Addendum #3) | v2.6.0 (Current Release) | Compatibility Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Chat List Screen** | Separate screens: `GET /private-chat-list` & `GET /group-chat-list` | Single Unified Screen: `GET /chat-list` | Search filters by contact name, group name & content; excludes 0-message chats | Inactive groups fully visible with status; archived chats separated | **Active**: Legacy separate endpoints work; new unified screen aggregates both seamlessly. |
| **Real-time Chat List** | `private_chat_list_updated`, `group_chat_list_updated` | `chat_list_updated`, `common_chat_list_updated` | Auto-updates when group name/icon is edited by Admin | Recipient-isolated `isArchived` and real-time `unreadCount: 0` reset | **Active**: Server emits both legacy and unified events simultaneously. |
| **Pin Conversation** | Socket: `pin_private_chat` (Private only) | REST: `POST /pin` or `POST /chat-list/pin` | Per-user group pinning: isolated to calling user only | Supports both REST and Socket events | **Active**: Sockets still supported; REST recommended for guaranteed HTTP status codes. |
| **Archive Conversation**| Socket: `archive_private_chat` | REST: `POST /archive` or `POST /chat-list/archive` | Supports both Private & Group chats | Dedicated `GET /archived` screen; real `isArchived` preserved on all broadcasts | **Active**: Sockets and REST both active; archived state never leaks to false. |
| **Mark as Read** | Socket `mark_seen` inside chat screen | REST: `POST /mark-read` or `POST /chat-list/mark-read` | Mark read directly from chat list swipe or screen entry | Server permanently records read and immediately broadcasts `unreadCount: 0` | **Active**: Flutter app can remove the 2-minute timer hide workaround. |
| **Mark as Unread** | Not supported | Socket: `mark_chat_unread` | REST: `POST /mark-unread` or `POST /chat-list/mark-unread` | Adds visual green unread badge dot | **Active**: Available via both REST and Socket. |
| **Mute Conversation** | Socket: `mute_private_chat` | REST: `POST /mute` or `POST /chat-list/mute` | Supports duration via `mutedUntil` timestamp | Works on both Private and Group chats | **Active**: Sockets and REST supported. |
| **Clear / Delete Chat** | Socket `delete_private_chat` | REST: `POST /delete` or `POST /chat-list/delete` | WhatsApp-style "Clear Chat": clears history for caller only | Deleting group from chat list never removes user from group or channel | **Active**: REST provides isolated clear for both Private and Group. |
| **Mark Viewed** | Not supported | Not supported | `POST /mark-viewed` | Clears Home screen Chat red dot badge | **Active**: Clears unread notification markers for location/home screen. |
| **Incremental Sync** | Full list re-fetch only | Not supported | Not supported | `GET /chat/sync?since=ISO_TIMESTAMP` | **Active**: High-speed incremental offline-to-online reconciliation. |
| **Edit Message** | Emit: `editMessage` \| Listen: `messageEdited` | Emit: `edit_message` \| Listen: `message_edited` | Standardized payload across Private & Group | Both snake_case and camelCase supported | **Active**: Server accepts and emits both snake_case and camelCase. |
| **Join Private Room** | Emit: `join` (`{userId, receiverId}`) | Emit: `join_room` or `join` (`{chatId}`) | Accepts both `{chatId}` and `{userId, peerUserId}` | Handshake joins all required user rooms | **Active**: Aliased seamlessly on server. |
| **Join Group Room** | Emit: `join` (`{userId, groupId}`) | Emit: `join_group` or `join` (`{groupId, userId}`) | Joins `group_{groupId}` and `{userId}_{groupId}` | Broadcasts join confirmation | **Active**: Aliased seamlessly on server. |
| **Send Group Message** | Emit: `send_message` (on `/chat`) | Emit: `send_group_message` or `send_message` | Supports Socket.io Ack callbacks (`emitWithAck`) | Accepts both event names on `/chat` and root namespace | **Active**: Full Socket Ack support. |
| **Group Read Receipts** | Unread counter increment only | `messages_seen_update` emitted to member rooms | Emits `messages_seen_update` & `group_message_seen` | Full 3-tick WhatsApp flow with read counts & timestamps | **Active**: Full read receipt synchronization. |
| **Location Message** | Raw string or JSON string | Pre-parsed `locationMeta` | Returns both JSON string in `content` and parsed `locationMeta` object | Flutter doesn't need manual `jsonDecode` | **Active**: Transparent backward compatibility. |
| **Contact Message** | Raw string or JSON string | Pre-parsed `contactMeta` | Returns both JSON string in `content` and parsed `contactMeta` object | Flutter doesn't need manual `jsonDecode` | **Active**: Transparent backward compatibility. |
| **Audio Voice Note** | File upload without duration | Multi-audio upload | Supports `duration: 14` in send payload & message DTO | Direct slider & waveform elapsed time support | **Active**: Audio waveform/slider supported directly. |
| **Group Info Updates** | Polling `GET /getMembers` | Polling `GET /getMembers` | Emits `group_updated` & `group_info_updated` to `group_{groupId}` | Real-time AppBar title & avatar updates without re-entry | **Active**: Sockets notify all connected group members live. |
| **Group Status Updates** | Group hidden on deactivate | Group hidden on deactivate | Inactive group displayed with deactivated status badge | Emits `group_status_updated` live to all rooms | **Active**: Inactive groups remain visible in all lists with status. |
| **Media Uploads** | Single-file endpoints | Multi-file endpoints | Single-file & Multi-file endpoints both active | Up to 20 files per upload | **Active**: All upload endpoints fully maintained. |
| **Chat Profile Details** | Multiple separate endpoints | Multiple separate endpoints | Unified `GET /chat/profile-details` | Full Media, Links, Docs, Members & Clear Chat Media Isolation | **Active**: Dedicated screen for Contact Info & Group Info. |

---

## 1. Technical Clarifications & Confirmations

### 1.1 Common Chat Actions: REST API vs. Socket Confirmation
1. **Group Support on Actions:**
   - **`POST /pin` with `{"groupId": 2, "chatType": "group", "isPinned": true}`:**
     **CONFIRMED.** Group pinning is stored strictly in the requesting user's `groupMember` record (`userId`, `groupId`). Pinning or unpinning a group chat affects **only the calling user**. It does **not** pin the group for any other members.
   - **`POST /delete` with `{"groupId": 2, "chatType": "group"}`:**
     **CONFIRMED.** This performs a WhatsApp-style **"Clear Chat"** strictly for the requesting user. It sets `lastClearedMessageId` to the latest message ID for the caller only. In `GET /chat-list`, the conversation disappears because there are 0 visible messages left. **Crucially, the user is NOT removed from the group**, and the group remains visible in `GET /get-all-group`, `GET /all-group-members`, and `GET /api/walkie/channels`.
2. **Dual-Support (REST vs. Socket):**
   - **CONFIRMED.** The backend maintains **100% dual support**:
     - Mobile can continue emitting socket events: `pin_private_chat`, `unpin_private_chat`, `archive_private_chat`, `mute_private_chat`, `delete_private_chat` (and their group equivalents `pin_chat`, `archive_chat`, `mute_chat`, `delete_chat`).
     - **Recommendation:** Mobile should migrate to the unified REST endpoints (`POST /pin`, `POST /archive`, `POST /mark-read`, `POST /mark-unread`, `POST /mute`, `POST /delete`). REST provides standard HTTP status codes (`200 OK`, `400 Bad Request`, `401 Unauthorized`), automatic network retry handling, and offline-friendly error handling.

---

### 1.2 Socket Event Names: Aliases & Casing Alignment

The backend eliminates silent event drops by accepting and emitting both naming conventions:

| Action | Mobile Emits (Current) | Recommended Standard | Server Listens To | Server Emits on Completion |
| :--- | :--- | :--- | :--- | :--- |
| **Edit Message** | `editMessage` | `edit_message` | `edit_message` AND `editMessage` | Both `message_edited` AND `messageEdited` |
| **Join Private Room** | `join` (`{userId, receiverId}`) | `join_room` (`{chatId}`) | `join_room` AND `join` | `joined` / `private_chat_joined` |
| **Join Group Room** | `join` (`{userId, groupId}`) | `join_group` (`{groupId, userId}`) | `join_group` AND `join` | Room membership confirmation |
| **Send Group Message** | `send_message` (on `/chat`) | `send_group_message` | `send_group_message` AND `send_message` | `receive_group_message`, `receive_message`, `message_sent` |
| **Delete Message (for_me)** | `delete_message` | `delete_message` | Emits ONLY to requester socket with `{userId, messageId, chatId, deleteType: "for_me"}`; updates requester's `lastMessage` to previous message | **Active**: Other participants/rooms never receive `for_me` events. |
| **Delete Message (for_everyone)** | `delete_message` | `delete_message` | Broadcasts to room with `{messageId, deleteType: "for_everyone", deletedBy}`; replaces content with "This message was deleted" | **Active**: Broadcast to all participants. |
| **Pin / Unpin Chat** | `pin_private_chat` / `pin_chat` | `pin_chat` | `pin_chat`, `pin_private_chat`, `unpin_chat`, `unpin_private_chat` | Emits `chat_list_updated`, `private_chat_pinned` / `group_chat_pinned` |
| **Archive Chat** | `archive_private_chat` / `archive_chat` | `archive_chat` | `archive_chat`, `archive_private_chat`, `unarchive_chat`, `unarchive_private_chat` | Emits `chat_list_updated`, `chat_archived` / `chat_unarchived` |
| **Mark Chat Read** | `mark_seen` | `mark_chat_read` | `mark_seen`, `mark_private_chat_read`, `mark_group_chat_read` | Emits `chat_list_updated` with `unreadCount: 0` and `messages_seen_update` |
| **Mark Chat Unread**| `mark_chat_unread` | `mark_chat_unread` | `mark_chat_unread`, `mark_chat_as_unread`, `markAsUnread` | Emits `chat_list_updated` with `isMarkedUnread: true` |
| **Mute / Unmute** | `mute_private_chat` / `mute_chat` | `mute_chat` | `mute_chat`, `mute_private_chat`, `unmute_chat`, `unmute_private_chat` | Emits `chat_list_updated`, `chat_muted` / `chat_unmuted` |
| **Delete / Clear** | `delete_private_chat` / `delete_chat` | `delete_chat` | `delete_chat`, `delete_private_chat` | Emits `chat_list_updated` and `chat_deleted` |

---

### 1.3 Full WhatsApp Message State Flow (The 3-Tick Model)

```
[Mobile Sender]               [Backend Server]              [Recipient Client]
       |                              |                              |
       |-- send_message ------------->| (Saves to DB)                |
       |   (clientMessageId)          |                              |
       |<-- message_sent -------------|                              |  => (Single Grey Tick ✓)
       |    (id, clientMessageId)     |                              |
       |                              |-- receive_message ---------->|
       |                              |<-- mark_delivered -----------|  => (Recipient socket received)
       |<-- messages_delivered -------|                              |  => (Double Grey Tick ✓✓)
       |                              |                              |
       |                              |<-- mark_seen ----------------|  => (Recipient opened chat)
       |<-- messages_seen_update -----|                              |  => (Double Blue Tick ✓✓)
```

#### `message_sent` Event (Single Grey Tick ✓ Confirmation)
When a message is successfully stored in MySQL/MariaDB, the backend emits `message_sent` to the sender's socket:
```json
{
  "clientMessageId": "uuid-v4-or-client-id",
  "id": 183185,
  "chatId": 1,
  "timestamp": "2026-11-04T10:45:00.000Z",
  "status": "sent"
}
```
This allows Flutter to immediately map temporary local messages to permanent server IDs and upgrade the message icon from a Clock 🕒 to a Single Grey Tick ✓.

---

### 1.4 Group Chat Read Receipt Ticks (Double Blue Ticks in Groups)

* **Single Grey Tick (✓):**
  When User A sends a message in a group, User A immediately receives `message_sent` (or Socket Ack callback). The message bubble displays a **Single Grey Tick (✓)**.
* **Double Grey Tick (✓✓):**
  When at least one other active member receives the message on their socket (`mark_delivered`), the message status transitions to **Double Grey Tick (✓✓)**.
* **Double Blue Tick (✓✓):**
  - In WhatsApp, a group message displays **Double Blue Ticks only after ALL other members of the group have read the message**.
  - While partially read, the ticks remain Double Grey. In the message details screen ("Info"), the list of members who have read it is displayed along with their read timestamps.
* **Socket Event on Read (`mark_seen` in Groups):**
  When another member opens the group chat and emits `mark_seen` (`{ groupId: 2 }`), the server:
  1. Emits `messages_seen_update` and `group_message_seen` to the group room `group_{groupId}` with:
     ```json
     {
       "groupId": 2,
       "userId": 5,
       "seenBy": 5,
       "messageIds": [183185, 183186],
       "seenAt": "2026-11-04T10:50:00.000Z"
     }
     ```
  2. Emits `chat_list_updated` to the reader with `unreadCount: 0`.

---

### 1.5 Location & Contact Message Schemas

The backend supports **both** incoming payload styles transparently:

* **Location Message:**
  - **Option A (JSON in `content`):**
    ```json
    {
      "messageType": "location",
      "content": "{\"latitude\":23.0225,\"longitude\":72.5714,\"locationName\":\"Office Landmark\",\"address\":\"SG Highway, Ahmedabad, Gujarat\"}"
    }
    ```
  - **Option B (Separate `locationMeta`):**
    ```json
    {
      "messageType": "location",
      "content": "Shared Location",
      "locationMeta": {
        "latitude": 23.0225,
        "longitude": 72.5714,
        "address": "SG Highway, Ahmedabad, Gujarat",
        "name": "Office Landmark",
        "locationName": "Office Landmark"
      }
    }
    ```
* **Contact Message:**
  - **Option A (JSON in `content`):**
    ```json
    {
      "messageType": "contact",
      "content": "{\"name\":\"John Doe\",\"phone\":\"+919876543210\",\"avatar\":\"uploads/Auth/contact.png\"}"
    }
    ```
  - **Option B (Separate `contactMeta`):**
    ```json
    {
      "messageType": "contact",
      "content": "John Doe",
      "contactMeta": {
        "name": "John Doe",
        "phone": "+919876543210",
        "avatar": "uploads/Auth/contact.png"
      }
    }
    ```
* **What Backend Returns:**
  The server attaches **BOTH** fields so Flutter does **not** have to manually call `jsonDecode()`:
  ```json
  {
    "id": 183187,
    "messageType": "location",
    "content": "{\"latitude\":23.0225,\"longitude\":72.5714,\"locationName\":\"Office Landmark\",\"address\":\"SG Highway\"}",
    "locationMeta": {
      "latitude": 23.0225,
      "longitude": 72.5714,
      "locationName": "Office Landmark",
      "address": "SG Highway"
    },
    "contactMeta": null
  }
  ```

---

### 1.6 Audio / Voice Note Duration

* **Recording & Duration:**
  Flutter records audio using native recorder and provides the duration in seconds.
* **Upload:**
  Upload to `POST /uploadAudio` or `POST /uploadMultipleAudio`. The server saves the file to `uploads/Messages/Audio/` and returns the file path.
* **Socket Send Payload:**
  Pass `"duration": 14` (integer seconds) or `"0:14"`:
  ```json
  {
    "senderId": 101,
    "receiverId": 102,
    "messageType": "audio",
    "content": "uploads/Messages/Audio/audio-1730718000.m4a",
    "duration": 14,
    "clientMessageId": "voice-msg-uuid-1234"
  }
  ```
* **What Backend Returns:**
  The server preserves and echoes `"duration": 14` directly in the message payload (`message.duration` and `message.audios[0].duration`). Flutter can directly display the audio player waveform slider and elapsed time (e.g. `0:14 / 0:35`).

---

### 1.7 Media Upload Endpoints (Single-File & Multi-File)

All legacy single-file endpoints remain 100% active and supported in production alongside the multi-file endpoints:

| Media Type | Single-File Endpoint (Active) | Multi-File Endpoint (Active, Recommended) | Multipart Field Name |
| :--- | :--- | :--- | :--- |
| **Image** | `POST /uploadChatImage` | `POST /uploadMultipleChatImages` | `chatImage` or `chatImages` (up to 20) |
| **Audio** | `POST /uploadAudio` | `POST /uploadMultipleAudio` | `chatAudio` or `chatAudios` |
| **Video** | `POST /uploadVideo` | `POST /uploadMultipleVideos` | `chatVideo` (video), `thumbnail` (image) |
| **Document** | `POST /uploadDocument` | `POST /uploadMultipleDocuments` | `chatDocument` or `chatDocuments` |

---

## 2. Unified Chat List Screen (`GET /chat-list`)

Replaces separate tabs with a single WhatsApp recent chats feed combining direct private chats and group chats, sorted by latest activity.

### 2.1 Endpoint Specification
* **Method:** `GET`
* **Primary Route:** `/chat-list`
* **Route Aliases:** `/chats`, `/unified-chat-list`, `/common-chat-list`
* **Headers:** `Authorization: Bearer <JWT_USER_TOKEN>`

### 2.2 Query Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `page` | `int` | `1` | Pagination page number |
| `limit` | `int` | `20` | Items per page (max 100) |
| `search` | `string` | `""` | Filters against: <br>1. **Contact Name / Mobile** (`user.name`, `user.fullName`, `user.mobileNo`)<br>2. **Group Name** (`group.name`, `group.groupName`)<br>3. **Message Content** (`lastMessage.content`, `lastMessage.preview`, `caption`) |
| `type` | `string` | `"all"` | Filter: `"all"`, `"private"`, or `"group"` |
| `includeArchived`| `bool` | `false` | When `false`, archived chats are excluded from the main list (WhatsApp standard) |

### 2.3 WhatsApp Business Rules Enforced by Backend
1. **0-Message Chats Excluded:** Conversations without any visible messages (`lastMessage IS NOT NULL`) are excluded from the recent chat list.
2. **Sort Order:**
   - **1st:** Pinned conversations (`isPinned: true`, sorted by `pinnedAt DESC`).
   - **2nd:** Latest activity timestamp (`timestamp DESC` / `lastMessageAt DESC`).
3. **Contact Name Search:** Searching for user name (`user.name` / `user.fullName`), mobile number, group name (`group.name`), or text snippet inside `lastMessage.content` immediately filters the list.
4. **Group Active Status:** Group chats include `isActive`, `isDeactivated`, `status`, and `groupStatus` at both root level and inside the `group` object.

### 2.4 Complete JSON Response DTO
```json
{
  "status": true,
  "message": "Chat list fetched successfully",
  "unreadTotalCount": 4,
  "pagination": {
    "currentPage": 1,
    "perPage": 20,
    "totalRecords": 7,
    "totalPages": 1,
    "hasNextPage": false,
    "hasPreviousPage": false
  },
  "data": [
    {
      "id": 1,
      "chatId": 1,
      "conversationId": 1,
      "groupId": null,
      "chatType": "private",
      "isGroup": false,
      "name": "Bob Builder",
      "fullName": "Bob Builder",
      "groupName": null,
      "profileImage": "uploads/Auth/avatar.png",
      "avatar": "uploads/Auth/avatar.png",
      "groupProfile": null,
      "user": {
        "id": 3,
        "userId": 3,
        "name": "Bob Builder",
        "fullName": "Bob Builder",
        "Name": "Bob Builder",
        "mobileNo": "9900000002",
        "avatar": "uploads/Auth/avatar.png",
        "profileImage": "uploads/Auth/avatar.png",
        "isOnline": true,
        "lastSeen": "04-11-2026 03:45 PM"
      },
      "group": null,
      "lastMessage": {
        "id": 183180,
        "senderId": 2,
        "senderName": "You",
        "senderImage": null,
        "receiverId": 3,
        "groupId": null,
        "messageType": "text",
        "message": "Hello Bob! Testing WhatsApp chat module",
        "preview": "Hello Bob! Testing WhatsApp chat module",
        "content": "Hello Bob! Testing WhatsApp chat module",
        "caption": null,
        "isForwarded": false,
        "forwardedLabel": null,
        "isDeletedForEveryone": false,
        "isEdited": false,
        "timestamp": "2026-11-04T10:40:00.000Z",
        "createdAt": "2026-11-04T10:40:00.000Z"
      },
      "isForwarded": false,
      "forwardedLabel": null,
      "timestamp": "2026-11-04T10:40:00.000Z",
      "lastMessageAt": "2026-11-04T10:40:00.000Z",
      "updatedAt": "2026-11-04T10:40:00.000Z",
      "isOnline": true,
      "lastSeen": "04-11-2026 03:45 PM",
      "unreadCount": 0,
      "isBlocked": false,
      "blockedBy": null,
      "blockedByMe": false,
      "isMarkedUnread": false,
      "isPinned": false,
      "pinnedAt": null,
      "isMuted": false,
      "mutedUntil": null,
      "isArchived": false,
      "archivedAt": null
    },
    {
      "id": 12,
      "chatId": 12,
      "conversationId": 12,
      "groupId": 12,
      "chatType": "group",
      "isGroup": true,
      "name": "Operations Team",
      "groupName": "Operations Team",
      "profileImage": "uploads/Category/team.png",
      "avatar": "uploads/Category/team.png",
      "groupProfile": "uploads/Category/team.png",
      "isActive": true,
      "isDeactivated": false,
      "status": "active",
      "groupStatus": "active",
      "user": null,
      "group": {
        "id": 12,
        "groupId": 12,
        "name": "Operations Team",
        "groupName": "Operations Team",
        "groupProfile": "uploads/Category/team.png",
        "memberCount": 8,
        "createdAt": "2026-10-20T10:00:00.000Z",
        "isActive": true,
        "isDeactivated": false,
        "status": "active",
        "groupStatus": "active"
      },
      "lastMessage": {
        "id": 183182,
        "senderId": 50,
        "senderName": "User 50",
        "senderImage": "uploads/Auth/user50.png",
        "receiverId": null,
        "groupId": 12,
        "messageType": "text",
        "message": "Group announcement for testing!",
        "preview": "User 50: Group announcement for testing!",
        "content": "Group announcement for testing!",
        "caption": null,
        "isForwarded": true,
        "forwardedLabel": "Forwarded",
        "isDeletedForEveryone": false,
        "isEdited": false,
        "timestamp": "2026-11-04T10:41:00.000Z",
        "createdAt": "2026-11-04T10:41:00.000Z",
        "isGroupActive": true,
        "groupStatus": "active"
      },
      "isForwarded": true,
      "forwardedLabel": "Forwarded",
      "timestamp": "2026-11-04T10:41:00.000Z",
      "unreadCount": 3,
      "isMarkedUnread": false,
      "isPinned": true,
      "pinnedAt": "2026-11-04T10:00:00.000Z",
      "isMuted": false,
      "mutedUntil": null,
      "isArchived": false,
      "archivedAt": null
    }
  ]
}
```

---

## 3. Real-Time Chat List Stream (`chat_list_updated`)

Whenever **any** message is sent, received, forwarded, edited, deleted, or group info/status is updated (Private or Group), the backend emits real-time events to the user's socket rooms.

### 3.1 Event Names Emitted to User Rooms
* `chat_list_updated` (Primary Standard)
* `common_chat_list_updated`
* `unified_chat_list_updated`

### 3.2 Payload Schema
```json
{
  "chatId": 12,
  "conversationId": 12,
  "groupId": 12,
  "chatType": "group",
  "isGroup": true,
  "name": "Operations Team",
  "profileImage": "uploads/Category/team.png",
  "avatar": "uploads/Category/team.png",
  "message": "User 50: Group announcement for testing!",
  "unreadCount": 1,
  "timestamp": "2026-11-06T19:30:00.000Z",
  "moveToTop": true,
  "isPinned": false,
  "pinnedAt": null,
  "isArchived": false,
  "archivedAt": null,
  "isActive": true,
  "isDeactivated": false,
  "status": "active",
  "groupStatus": "active",
  "data": {
    "chatId": 12,
    "conversationId": 12,
    "groupId": 12,
    "chatType": "group",
    "unreadCount": 1,
    "isArchived": false,
    "archivedAt": null,
    "moveToTop": true
  }
}
```

### 3.3 Flutter Chat List State Handling Algorithm
```dart
void handleChatListUpdate(Map<String, dynamic> data) {
  final chatId = data['chatId'];
  final chatType = data['chatType'];
  final bool moveToTop = data['moveToTop'] ?? true;

  final int index = chatList.indexWhere(
    (c) => c.chatId == chatId && c.chatType == chatType,
  );

  if (index != -1) {
    // 1. Update conversation summary in-place
    chatList[index].updateFromSummary(data);

    // 2. Re-order if message moved chat to top and item is not pinned
    if (moveToTop && !chatList[index].isPinned) {
      final item = chatList.removeAt(index);
      // Place right after all pinned chats (or index 0 if no pins)
      final int firstUnpinnedIndex = chatList.indexWhere((c) => !c.isPinned);
      chatList.insert(firstUnpinnedIndex == -1 ? 0 : firstUnpinnedIndex, item);
    }
  } else {
    // 3. New conversation initiated: insert at index 0 (or after pinned items)
    final newItem = ChatItem.fromJson(data);
    final int insertPos = newItem.isPinned ? 0 : chatList.indexWhere((c) => !c.isPinned);
    chatList.insert(insertPos == -1 ? 0 : insertPos, newItem);
  }

  notifyListeners();
}
```

---

## 4. Common Conversation Actions API (REST & Socket)

All common actions support both Private Chats and Group Chats through unified REST endpoints (and backward-compatible Socket events).

### 4.1 Pin / Unpin Conversation
* **REST Route:** `POST /pin` (aliases: `/chat-list/pin`, `/chats/pin`)
* **Request Body:**
  ```json
  {
    "chatId": 1,
    "chatType": "private",
    "isPinned": true
  }
  ```
  *(For group chats: pass `"groupId": 12, "chatType": "group", "isPinned": true`)*
* **Response:** `200 OK` with updated conversation summary.
* **Socket Equivalents:** Emits `pin_chat`, `pin_private_chat`, `unpin_chat`, `unpin_private_chat`.

---

### 4.2 Archive / Unarchive Conversation
* **REST Route:** `POST /archive` (aliases: `/chat-list/archive`, `/chats/archive`)
* **Request Body:**
  ```json
  {
    "chatId": 1,
    "chatType": "private",
    "isArchived": true
  }
  ```
  *(For group chats: pass `"groupId": 12, "chatType": "group", "isArchived": true`)*
* **Response:** `200 OK` with updated summary.
* **Socket Equivalents:** Emits `archive_chat`, `archive_private_chat`, `unarchive_chat`.

---

### 4.3 Archived Chats Screen (`GET /archived`)
WhatsApp maintains a dedicated "Archived Chats" screen displaying only archived conversations:
* **REST Route:** `GET /archived` (aliases: `/chat-list/archived`, `/archived-chats`, `/chats/archived`)
* **Query Parameters:** `page`, `limit`, `search`
* **Response:** Same DTO structure as `GET /chat-list`, containing only conversations where `isArchived == true`.

---

### 4.4 Mark Chat as Read
* **REST Route:** `POST /mark-read` (aliases: `/mark-as-read`, `/chat-list/mark-read`)
* **Request Body:**
  ```json
  {
    "chatId": 1,
    "chatType": "private"
  }
  ```
* **Response:**
  ```json
  {
    "status": true,
    "chatType": "private",
    "chatId": 1,
    "unreadCount": 0,
    "summary": {
      "chatId": 1,
      "unreadCount": 0
    }
  }
  ```
* **Socket Equivalents:** Emits `mark_seen` with `{ chatId: 1 }` or `{ groupId: 12 }`. Server resets unread count to `0` in DB and immediately emits `chat_list_updated` with `unreadCount: 0`.

---

### 4.5 Mark Chat as Unread
WhatsApp allows users to mark a conversation as unread (showing a green dot):
* **REST Route:** `POST /mark-unread` (aliases: `/mark-as-unread`, `/chat-list/mark-unread`)
* **Request Body:**
  ```json
  {
    "chatId": 1,
    "chatType": "private"
  }
  ```
* **Response:** `200 OK` with `isMarkedUnread: true`.
* **Socket Equivalents:** Emits `mark_chat_unread` with `{ chatId, chatType }`.

---

### 4.6 Mute / Unmute Conversation
* **REST Route:** `POST /mute` (aliases: `/chat-list/mute`, `/chats/mute`)
* **Request Body:**
  ```json
  {
    "chatId": 1,
    "chatType": "private",
    "isMuted": true,
    "mutedUntil": "2026-11-07T12:00:00.000Z"
  }
  ```
* **Response:** `200 OK` with `isMuted: true` and `mutedUntil`.

---

### 4.7 Delete / Clear Chat (WhatsApp Isolated Clear)
* **REST Route:** `POST /delete` (aliases: `/clear`, `/chat-list/delete`, `/chats/delete`)
* **Request Body:**
  ```json
  {
    "chatId": 1,
    "chatType": "private"
  }
  ```
  *(For group chats: `{"groupId": 12, "chatType": "group"}`)*
* **Behavior:**
  - Clears message history strictly for the calling user.
  - The conversation is removed from the caller's `GET /chat-list` because 0 visible messages remain.
  - For groups, the user **remains a member** of the group and channel across `GET /get-all-group` and `GET /api/walkie/channels`.
* **Socket Equivalents:** Emits `delete_chat` or `delete_private_chat`.

---

### 4.8 Mark Chat List as Viewed (Home Screen Badge Clear)
When the user opens the Chats tab/screen, call this endpoint to extinguish the unread red dot on the Home navigation bar:
* **REST Route:** `POST /mark-viewed` (aliases: `/chat-list/mark-viewed`, `/chats/mark-viewed`)
* **Response:** `200 OK` with `{"status": true, "message": "Chat list marked as viewed successfully"}`.

---

## 5. Chat Profile Details & Media Gallery (`GET /chat/profile-details`)

Unified endpoint for Contact Info (Private) and Group Info screens, with categorized media tabs, members, and settings.

### 5.1 Endpoint Specification
* **Method:** `GET` (and `POST`)
* **Primary Route:** `/chat/profile-details`
* **Route Aliases:** `/chat/profile`, `/chat-profile-details`, `/profile-details`
* **Headers:** `Authorization: Bearer <JWT_USER_TOKEN>`

### 5.2 Query Parameters
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `chatId` | `int` | Required if private chat | Private conversation ID |
| `userId` | `int` | Optional alternative | Peer user ID |
| `groupId` | `int` | Required if group chat | Group ID |
| `mediaLimit` | `int` | Optional (default: 100) | Maximum media items to return (max 500) |
| `mediaCategory`| `string`| Optional | Filter media: `"photos"`, `"videos"`, `"audio"`, `"documents"`, `"links"` |

### 5.3 Complete Response DTO (Private Chat Profile)
```json
{
  "status": true,
  "chatType": "private",
  "chatId": 1,
  "user": {
    "id": 3,
    "name": "Bob Builder",
    "mobileNo": "9900000002",
    "avatar": "uploads/Auth/avatar.png",
    "isOnline": true,
    "lastSeen": "04-11-2026 03:45 PM",
    "isBlocked": false,
    "blockedByMe": false
  },
  "chatSettings": {
    "isPinned": false,
    "pinnedAt": null,
    "isArchived": false,
    "archivedAt": null,
    "isMuted": false,
    "mutedUntil": null
  },
  "commonGroups": {
    "count": 2,
    "groups": [
      { "id": 12, "groupName": "Operations Team", "groupProfile": "uploads/Category/team.png" }
    ]
  },
  "pinnedMessage": null,
  "mediaSummary": {
    "totalMediaCount": 15,
    "photosCount": 10,
    "videosCount": 2,
    "audiosCount": 1,
    "documentsCount": 1,
    "linksCount": 1
  },
  "media": {
    "photos": [
      { "messageId": 183170, "url": "uploads/Messages/Image/img1.jpg", "createdAt": "2026-11-04T09:00:00.000Z" }
    ],
    "videos": [
      { "messageId": 183175, "url": "uploads/Messages/Video/vid1.mp4", "thumbnail": "uploads/Messages/Video/thumb1.jpg", "duration": "01:20" }
    ],
    "audios": [],
    "documents": [],
    "links": []
  }
}
```

### 5.4 WhatsApp Clear Chat Media Isolation
When a user clicks "Clear chat", the shared media tab for that user is emptied of cleared messages (`id > lastClearedMessageId`), while remaining intact for all other participants.

---

## 6. Message Forwarding (WhatsApp Multi-Select Forward)

### 6.1 Target Picker Endpoint
* **Method:** `GET`
* **Routes:** `/api/forward/list` or `/forward/list` (aliases: `/api/forward/forward-list`, `/forward/forward-list`)
* **Headers:** `Authorization: Bearer <JWT_USER_TOKEN>`
* **Response:**
```json
{
  "status": true,
  "message": "Forward list fetched successfully",
  "data": {
    "recentChats": [ ... ],
    "groups": [ ... ],
    "users": [ ... ]
  }
}
```

### 6.2 Forward Action
* **Method:** `POST`
* **Routes:** `/api/forward/message` or `/forward/message`
* **Request Body:**
```json
{
  "messageId": 183180,
  "sourceType": "private",
  "targets": [
    { "type": "private", "receiverId": 3 },
    { "type": "group", "groupId": 12 }
  ]
}
```
* **Response:**
```json
{
  "status": true,
  "message": "Message forwarded successfully",
  "data": {
    "successCount": 2,
    "failedCount": 0,
    "forwardedMessages": [ ... ]
  }
}
```

### 6.3 Visual Forwarded Badge
Every forwarded message delivered through socket or history contains:
* `isForwarded: true`
* `forwardedLabel: "Forwarded"`

The Flutter UI must render the standard WhatsApp italicized forward arrow with the **"Forwarded"** label above the message bubble.

---

## 7. Status / Stories Reply Integration

When a user replies to a Status / Story:
* **Method:** `POST`
* **Route:** `/api/status/:id/reply` (e.g. `POST /api/status/15/reply`)
* **Headers:** `Authorization: Bearer <JWT_USER_TOKEN>`
* **Request Body:**
```json
{
  "comment": "Nice photo!",
  "reactionEmoji": "🔥"
}
```
* **Private Chat Representation:**
  - `messageType`: `"status_reply"`
  - `statusMeta`: `{ "statusId": 15, "type": "image", "thumbnail": "...", "ownerName": "..." }`
  - Flutter renders the reply with a thumbnail preview snippet of the status story above the user's text comment.

---

## 8. Advanced Message Lifecycle: Delete, Edit & Socket Acknowledgment

### 8.1 "Delete for me" vs "Delete for everyone"

#### 1. "Delete for me" (`deleteType: "for_me"`)
When User A deletes a message "for me":
* **Backend Storage:** Recorded in `message_deleted_for_me` for that user.
* **Socket Delivery Rule (STRICT ISOLATION):**
  - Emitted **ONLY to the calling user's active sockets**.
  - **NEVER** broadcast to the chat room or other members.
* **Socket Event:** `message_deleted`
* **Payload Schema:**
  ```json
  {
    "messageId": 183200,
    "id": 183200,
    "deleteType": "for_me",
    "userId": 2,
    "deletedBy": 2,
    "chatId": 1,
    "groupId": null,
    "chatType": "private"
  }
  ```
* **Chat List Reaction:**
  - Only User A receives `chat_list_updated`.
  - The chat's `lastMessage` automatically falls back to the **previous visible message**.
  - `moveToTop: false` prevents jumping to the top.

#### 2. "Delete for everyone" (`deleteType: "for_everyone"`)
When User A deletes a message "for everyone":
* **Backend Storage:** Marks `isDeletedForEveryone: true` and replaces content with `"This message was deleted"`.
* **Socket Delivery Rule:** Broadcast to all conversation participants.
* **Socket Event:** `message_deleted`
* **Payload Schema:**
  ```json
  {
    "messageId": 183200,
    "id": 183200,
    "deleteType": "for_everyone",
    "deletedBy": 2,
    "userId": 2,
    "chatId": 1,
    "groupId": null,
    "chatType": "private"
  }
  ```
* **Chat List Reaction:** All members receive `chat_list_updated` with `lastMessage.content = "This message was deleted"`.

---

### 8.2 Standardized Edit Message Across Private & Group Chats

#### 1. Listening to Edit Events
Flutter clients should register listeners for both `message_edited` and `messageEdited`:
```dart
socket.on('message_edited', (data) => handleMessageEdited(data));
socket.on('messageEdited', (data) => handleMessageEdited(data));
```

#### 2. Guaranteed Payload Schema
```json
{
  "messageId": 1530,
  "id": 1530,
  "chatId": 12,
  "groupId": 12,
  "content": "Hello, this is the updated text!",
  "isEdited": true,
  "editedAt": "2026-11-06T10:15:30.000Z"
}
```

#### 3. Client UI Reaction:
* Find message in state by `message.id == data['id']` or `data['messageId']`.
* Update message text: `message.content = data['content']`.
* Update flags: `message.isEdited = true` and `message.editedAt = data['editedAt']`.
* Render the standard WhatsApp italicized `(edited)` tag next to the message timestamp.

---

### 8.3 Socket Acknowledgment Callbacks (`emitWithAck`)

`send_message` and `send_group_message` support standard Socket.io acknowledgment callbacks:
```dart
socket.emitWithAck('send_message', {
  'senderId': myUserId,
  'receiverId': peerUserId,
  'content': 'Hello from Flutter!',
  'clientMessageId': 'uuid-v4-abc-123',
  'messageType': 'text',
}, ack: (response) {
  if (response != null && response['status'] == true) {
    final savedMessage = response['message'] ?? response['data'];
    updateLocalMessageStatus(
      clientMessageId: 'uuid-v4-abc-123',
      serverId: savedMessage['id'],
      status: MessageStatus.sentOnServer, // Single Grey Tick ✓
    );
  } else {
    final String errorMsg = response?['message'] ?? 'Message delivery failed';
    markLocalMessageFailed('uuid-v4-abc-123', errorMsg);
  }
});
```

---

### 8.4 Socket Authentication & Token Expiry Reconnection Architecture

The mobile app must listen to `connect_error` on the socket instance to handle expired tokens gracefully without logging the user out:
```dart
void setupSocketAuthHandler(IO.Socket socket) {
  socket.onConnectError((err) async {
    final errorStr = err.toString();
    if (errorStr.contains("TOKEN_EXPIRED") || errorStr.contains("jwt expired")) {
      final String? newAccessToken = await AuthService.refreshAccessToken();
      if (newAccessToken != null) {
        socket.io.options?['auth'] = {'token': newAccessToken};
        socket.io.options?['query'] = {'token': newAccessToken};
        socket.connect();
      } else {
        AuthService.forceLogout();
      }
    }
  });
}
```

---

## 9. Group Lifecycle & Deactivated Group Status Handling

### 9.1 Deactivated Groups Remain Fully Visible Across All APIs
When an admin deactivates a group (`isActive: false`):
1. **Chat List (`GET /chat-list`):** Group remains visible in the chat list with its message preview and unread count, carrying `isDeactivated: true` and `groupStatus: "deactivated"`.
2. **All Groups (`GET /get-all-group`):** All groups are returned with `isActive: false`, `isDeactivated: true`, `status: "deactivated"`.
3. **Group Members (`GET /all-group-members`):** Members of deactivated groups remain fully listed.
4. **Walkie-Talkie Channels (`GET /api/walkie/channels`):** Deactivated channels are returned with `status: "deactivated"` so UI shows disabled/deactivated badge.

### 9.2 Real-Time Socket Event: `group_status_updated`
When an Admin calls `POST /deActivateGroup`, the server immediately emits `group_status_updated` and `group_updated` to room `group_{groupId}`:
```json
{
  "status": true,
  "groupId": 12,
  "id": 12,
  "chatId": 12,
  "isActive": false,
  "isDeactivated": true,
  "status": "deactivated",
  "groupStatus": "deactivated",
  "updatedBy": 1,
  "updatedAt": "2026-11-06T19:00:00.000Z"
}
```

### 9.3 Flutter Chat Screen Disabled Bar Implementation
```dart
socket.on('group_status_updated', (data) {
  final int groupId = data['groupId'] ?? data['id'];
  final bool isDeactivated = data['isDeactivated'] ?? (data['isActive'] == false);
  if (currentChatScreenGroupId == groupId) {
    setState(() {
      isCurrentGroupDeactivated = isDeactivated;
    });
  }
});

Widget buildChatInputBar() {
  if (isCurrentGroupDeactivated) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade200,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.grey, size: 18),
          SizedBox(width: 8),
          Text(
            "This group has been deactivated by the Admin",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
  return NormalMessageInputField();
}
```

---

## 10. Advanced WhatsApp Parity Updates: Real `isArchived` State & Instant Unread Reset (v2.6.0)

### 10.1 Real-Time Archive State Integrity (`isArchived` Fix)
* **What Was Fixed:** In group message broadcasts, the server previously generated a base summary using the sender's user context, causing other members who had archived the group to receive `isArchived: false` and un-archive their chats.
* **Current Behavior:** In v2.6.0, the server resolves `groupMember.isArchived` specifically for each recipient user. When a user has archived a group, `chat_list_updated` always carries `isArchived: true` and `archivedAt: "..."`.
* **Private Chat:** In private chats, `private_chat_user_settings.isArchived` is guaranteed for the target user.

### 10.2 Instant Server-Side Unread Count Reset
* **What Was Fixed:** The Flutter app previously had to hide an outdated unread counter locally for 2 minutes because server-side read updates were delayed.
* **Current Behavior:**
  1. The backend implements `messagesRepository.getUnreadCount(groupId, userId)` which filters out already-read messages and clear boundaries, returning the true unread count (`0` immediately after reading).
  2. In `MarkMessagesAsSeen` and private `markSeen`, reads are safely recorded in DB and `isMarkedUnread: false` is cleared.
  3. The server immediately emits `chat_list_updated` to the reader with `unreadCount: 0`.
* **Frontend Action Item:** Flutter mobile app can safely **remove the temporary 2-minute local hide workaround**. The server now permanently persists reads and broadcasts `unreadCount: 0` in real time.

---

## 11. Incremental Offline Synchronization (`GET /chat/sync`)

When the mobile app reconnects after being offline, instead of re-fetching the entire chat list, use the incremental sync endpoint:
* **Method:** `GET`
* **Routes:** `/chat/sync` (aliases: `/chats/sync`, `/chat-list/sync`, `/sync`)
* **Headers:** `Authorization: Bearer <JWT_USER_TOKEN>`
* **Query Parameter:** `since=2026-11-06T10:00:00.000Z` (ISO 8601 timestamp of last sync)
* **Response:**
```json
{
  "status": true,
  "message": "Chats synced successfully",
  "since": "2026-11-06T10:00:00.000Z",
  "count": 3,
  "data": [ ... updated conversation summaries ... ]
}
```
Flutter app merges the returned conversations into the local store in-place.

---

## 12. Flutter Developer Production Checklist

Before releasing the updated build to production or testing:

1. [x] **Unified Chat List:** Call `GET /chat-list` for recent chats feed. Verify 0-message chats are excluded and pinned items appear first.
2. [x] **Socket Handshake:** Pass JWT token in `auth: {'token': token}` and `query: {'token': token}`. Handle `connect_error` with automatic refresh.
3. [x] **Real-time Listener:** Register listener for `chat_list_updated`. Update local state in-place and re-order after pinned conversations.
4. [x] **Message Send & Ack:** Emit `send_message` (private) or `send_group_message` (group) using `emitWithAck`. Transition clock 🕒 to Single Grey Tick ✓ immediately upon response.
5. [x] **Read Receipts:** Emit `mark_seen` when entering chat screen. Listen for `messages_seen_update` to upgrade Double Grey Ticks ✓✓ to Double Blue Ticks ✓✓.
6. [x] **Unread Count Reset:** Remove 2-minute timer workaround; rely directly on server's `unreadCount: 0` broadcast.
7. [x] **Archive Screen:** Query `GET /archived` for archived chats list. Verify archived chats do not appear on main chat list unless `includeArchived=true`.
8. [x] **Edit Message:** Listen to `message_edited` and `messageEdited`. Render standard italicized `(edited)` label.
9. [x] **Delete for Me:** When deleting "for me", only update local UI; listen for `message_deleted` to update `lastMessage` to previous visible message.
10. [x] **Inactive Groups:** Check `data['isActive'] == false` or `data['groupStatus'] == 'deactivated'`. Render disabled bar `"This group has been deactivated by the Admin"`.
11. [x] **Forwarding:** Multi-select targets from `GET /api/forward/list`. Post to `POST /api/forward/message`. Render "Forwarded" badge.
12. [x] **Profile Details:** Query `GET /chat/profile-details?chatId=1` or `?groupId=12` for media gallery, links, documents, and members.
