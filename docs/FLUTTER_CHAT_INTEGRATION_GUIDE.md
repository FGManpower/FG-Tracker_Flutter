# WhatsApp-Style Chatting Module: Flutter Integration Guide & Technical Specification

> **Document Version:** `v2.2.0` (Advanced WhatsApp Parity & Technical Addendum Release)  
> **Previous Versions:** `v2.1.0` (Unified Standard & Bidirectional Aliases), `v1.0.0` (Legacy Dual-Tab Architecture)  
> **Backend Environment:** Node.js, Express, Sequelize (MySQL/MariaDB), Socket.io  
> **Test Status:** 100% Verified (23/23 Automated End-to-End Tests Passed)

---

## Complete Version Changelog & Backward Compatibility Matrix

| Feature / Action | v1.0.0 (Legacy App Implementation) | v2.1.0 (Unified Architecture) | v2.2.0 (Advanced WhatsApp Parity Addendum) | Compatibility Status |
| :--- | :--- | :--- | :--- | :--- |
| **Chat List Screen** | Separate screens: `GET /private-chat-list` & `GET /getGroupChatList` | Single Unified Screen: `GET /chat-list` | Search filters by user name, group name & content; excludes 0-message chats | **Active**: Legacy screens work; new unified screen aggregates both. |
| **Real-time Chat List** | `private_chat_list_updated`, `group_chat_list_updated` | `chat_list_updated`, `common_chat_list_updated` | Auto-updates when group name/icon is edited by Admin | **Active**: Server emits both legacy and unified events simultaneously. |
| **Pin Conversation** | Socket: `pin_private_chat` (Private only) | REST: `POST /pin` or `/chat-list/pin` | Per-user group pinning: isolated to calling user only | **Active**: Sockets still supported; REST recommended for guaranteed HTTP status codes. |
| **Archive Conversation**| Socket: `archive_private_chat` | REST: `POST /archive` or `/chat-list/archive` | Supports both Private & Group chats | **Active**: Sockets still supported; REST supports both Private & Group. |
| **Mark as Read** | Socket `mark_seen` inside chat screen | REST: `POST /mark-read` or `/chat-list/mark-read` | Mark read directly from chat list swipe or screen entry | **Active**: REST allows marking read directly from chat list swipe/action. |
| **Clear / Delete Chat** | Socket `delete_private_chat` | REST: `POST /delete` or `/chat-list/delete` | WhatsApp-style "Clear Chat": clears history for caller only | **Active**: REST provides isolated clear for both Private and Group. |
| **Edit Message** | Emit: `editMessage` \| Listen: `messageEdited` | Emit: `edit_message` \| Listen: `message_edited` | Bidirectional aliases: both snake_case and camelCase emitted | **Active**: Server accepts and emits both snake_case and camelCase. |
| **Join Private Chat** | Emit: `join` with `{userId, receiverId}` | Emit: `join_room` or `join` with `{chatId}` | Accepts both `{chatId}` and `{userId, peerUserId}` | **Active**: Aliased seamlessly on server. |
| **Join Group Chat** | Emit: `join` with `{userId, groupId}` | Emit: `join_group` or `join` with `{groupId, userId}` | Joins `group_{groupId}` and `${userId}_{groupId}` | **Active**: Aliased seamlessly on server. |
| **Send Group Message** | Emit: `send_message` (on `/chat`) | Emit: `send_group_message` or `send_message` | Accepts `send_group_message` and `send_message` on `/chat` | **Active**: Both event names accepted on `/chat`. |
| **Group Read Receipts** | Unread counter increment only | `messages_seen_update` emitted to member rooms | Emits `messages_seen_update` & `group_message_seen` to group rooms | **Active**: Full 3-tick WhatsApp flow with read counts & timestamps. |
| **Location Message** | Raw string or JSON string | Pre-parsed `locationMeta` | Supports both `locationMeta` object & JSON string in `content` | **Active**: Returns both `content` JSON string and parsed `locationMeta`. |
| **Contact Message** | Raw string or JSON string | Pre-parsed `contactMeta` | Supports both `contactMeta` object & JSON string in `content` | **Active**: Returns both `content` JSON string and parsed `contactMeta`. |
| **Audio Voice Note** | File upload without duration | Multi-audio upload | Supports `duration: 14` (seconds) in send payload & message DTO | **Active**: Audio waveform/slider elapsed time supported directly. |
| **Group Info Updates** | Polling `GET /getMembers` | Polling `GET /getMembers` | Emits `group_updated` & `group_info_updated` to `group_{groupId}` | **Active**: Real-time AppBar title & avatar updates without screen re-entry. |
| **Media Uploads** | Single-file endpoints | Multi-file endpoints | Single-file & Multi-file endpoints both active | **Active**: Single-file and multi-file endpoints are fully maintained in production. |

---

## 1. Technical Clarifications & Confirmations (v2.1.0 & v2.2.0)

### 1.1 Common Chat Actions: REST API vs. Socket Confirmation
1. **Group Support on Actions:**
   - **`POST /pin` with `{"groupId": 2, "chatType": "group", "isPinned": true}`:**
     **CONFIRMED.** Group pinning is stored strictly in the requesting user's `groupMember` record (`userId`, `groupId`). Pinning or unpinning a group chat affects **only the calling user**. It does **not** pin the group for any other members.
   - **`POST /delete` with `{"groupId": 2, "chatType": "group"}`:**
     **CONFIRMED.** This performs a WhatsApp-style **"Clear Chat"** strictly for the requesting user. It records `lastClearedMessageId` and marks `isDeleted: true` on the caller's membership row. **No messages in the database are destroyed**, and other members of the group can still see their messages normally.
2. **Dual-Support (REST vs. Socket):**
   - **CONFIRMED.** The backend maintains **100% dual support**:
     - Mobile can continue emitting socket events: `pin_private_chat`, `unpin_private_chat`, `archive_private_chat`, `mute_private_chat`, `delete_private_chat` (and their group equivalents `pin_chat`, `archive_chat`, `mute_chat`, `delete_chat`).
     - **Recommendation:** Mobile should migrate to the unified REST endpoints (`POST /pin`, `POST /archive`, `POST /mark-read`, `POST /mute`, `POST /delete`). REST provides standard HTTP status codes (`200 OK`, `400 Bad Request`, `401 Unauthorized`), automatic network retry handling, and offline-friendly error handling.

---

### 1.2 Socket Event Names: Aliases & Casing Alignment

The backend has been configured to eliminate silent event drops by accepting and emitting both naming conventions:

| Action | Mobile Emits (Current) | Recommended Standard | Server Listens To | Server Emits on Completion |
| :--- | :--- | :--- | :--- | :--- |
| **Edit Message** | `editMessage` | `edit_message` | `edit_message` AND `editMessage` | Both `message_edited` AND `messageEdited` |
| **Join Private Room** | `join` (`{userId, receiverId}`) | `join_room` (`{chatId}`) | `join_room` AND `join` | `joined` / `private_chat_joined` |
| **Join Group Room** | `join` (`{userId, groupId}`) | `join_group` (`{groupId, userId}`) | `join_group` AND `join` | Room membership confirmation |
| **Send Group Message** | `send_message` (on `/chat`) | `send_group_message` | `send_group_message` AND `send_message` | `receive_group_message`, `receive_message`, `message_sent` |
| **Delete Message** | `delete_message` | `delete_message` | `delete_message` | `message_deleted` |
| **Pin Message** | `pinMessage` | `pin_message` | `pin_message` AND `pinMessage` | Both `message_pinned` AND `messagePinned` |
| **Unpin Message** | `unpinMessage` | `unpin_message` | `unpin_message` AND `unpinMessage` | Both `message_unpinned` AND `messageUnpinned` |

---

### 1.3 Full WhatsApp Message State Flow (The 3-Tick Model)

```
[Mobile Client (Sender)]        [Backend Server]         [Mobile Client (Recipient)]
           |                           |                           |
           |---- send_message -------->| (Persisted to DB)         |
           |     (clientMessageId)     |                           |
           |<--- message_sent ---------|                           |  ==> [Single Grey Tick ✓]
           |     (id, clientMessageId) |                           |      Saved on Server
           |                           |---- receive_message ----->|
           |                           |<--- mark_delivered -------|  ==> [Double Grey Tick ✓✓]
           |<--- messages_delivered ---|                           |      Delivered to Recipient Device
           |                           |                           |
           |                           |<--- mark_seen ------------|  ==> [Double Blue Tick ✓✓]
           |<--- messages_seen_update -|                           |      Opened / Read by Recipient
```

#### What Backend Returns on `message_sent`:
When a message is successfully stored in MySQL/MariaDB, the server immediately emits `message_sent` back to the sender's socket with the following payload structure:
```json
{
  "status": true,
  "id": 183185,
  "messageId": 183185,
  "clientMessageId": "d3b07384-d113-494b-9c8e-8a2bf83f60f2",
  "chatId": 1,
  "conversationId": 1,
  "senderId": 2,
  "receiverId": 3,
  "messageType": "text",
  "content": "Hello Bob!",
  "timestamp": "2026-11-04T10:45:00.000Z",
  "createdAt": "2026-11-04T10:45:00.000Z"
}
```
> **Client Implementation:** The Flutter client should display an initial local pending state, then immediately update the local message ID and change the state to **Single Grey Tick (`✓`)** upon receiving `message_sent` matched by `clientMessageId`.

---

### 1.4 Group Real-Time Lifecycle Events

#### Event 1: `group_chat_cleared`
Emitted to all active devices of the user who cleared the group chat history:
```json
{
  "status": true,
  "message": "Group chat cleared successfully",
  "groupId": 2,
  "group_id": 2,
  "userId": 2,
  "chatType": "group",
  "lastClearedMessageId": 183170,
  "deletedBeforeMessageId": 183170,
  "clearType": "for_me",
  "clearedAt": "2026-11-04T10:45:00.000Z"
}
```

#### Event 2: `member_removed` / `member_left`
Emitted to the group room `group_{groupId}` and to the affected user:
```json
{
  "status": true,
  "groupId": 2,
  "group_id": 2,
  "userId": 5,
  "removedBy": 2,
  "isKicked": true,
  "message": "User 5 was removed from the group",
  "timestamp": "2026-11-04T10:45:00.000Z"
}
```

---

### 1.5 Advanced WhatsApp Parity: The 4 Technical Addenda (v2.2.0)

#### 1. Group Chat Read Receipt Ticks (Double Blue Ticks in Groups)
* **Single Grey Tick (`✓`):**
  When User A sends a group message (`send_group_message` or `send_message`), the backend saves it to MySQL and immediately emits `message_sent` (and `group_message_sent`) back to User A's socket with `{ id, clientMessageId, groupId, timestamp }`. Flutter sets the message tick state to **Single Grey Tick (`✓`)**.
* **Double Grey Tick (`✓✓`):**
  Dispatched when the message is delivered to active group members' sockets via `receive_group_message` / `receive_message`.
* **Double Blue Tick (`✓✓`):**
  In WhatsApp groups, a message receives a **Double Blue Tick (`✓✓`) only when ALL members of the group have read the message**.
  When any member opens the group and reads messages, the member client emits:
  ```json
  socket.emit("mark_seen", { "userId": 102, "groupId": 2 });
  ```
  The backend records the read state in `message_reads` and immediately emits **`messages_seen_update`** and **`group_message_seen`** to:
  1. Room `${member.userId}_${groupId}`
  2. Room `group_${groupId}`
  3. Across the `/chat` namespace.

  **Socket Event Payload (`messages_seen_update` & `group_message_seen`):**
  ```json
  {
    "userId": 102,
    "seenBy": 102,
    "groupId": 2,
    "messageIds": [183185, 183186],
    "seenAt": "2026-11-04T12:00:00.000Z"
  }
  ```
  **Flutter Group Tick Algorithm:**
  ```dart
  void onGroupMessageSeenUpdate(Map<String, dynamic> data) {
    final int groupId = data['groupId'];
    final int seenBy = data['seenBy'];
    final List<int> messageIds = List<int>.from(data['messageIds'] ?? []);
    final int totalGroupMembers = currentGroup.memberCount; // e.g. 5 members

    for (final messageId in messageIds) {
      final message = findMessageById(messageId);
      if (message != null && message.senderId == myUserId) {
        message.seenByUserIds.add(seenBy);
        // If all other group members have read: total members minus sender (1)
        if (message.seenByUserIds.length >= (totalGroupMembers - 1)) {
          message.tickStatus = TickStatus.doubleBlue; // ✓✓ Blue
        } else {
          message.tickStatus = TickStatus.doubleGrey; // ✓✓ Grey
        }
      }
    }
    notifyListeners();
  }
  ```

---

#### 2. Location & Contact Message Schemas
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
* **What the Backend Returns (Both REST & Sockets):**
  The backend serializes and attaches **BOTH** fields so Flutter does **not** have to manually call `jsonDecode()`:
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
  *(Same applies for contact messages, returning parsed `contactMeta: { name, phone, avatar }`).*

---

#### 3. Audio / Voice Note Duration
* **Recording & Duration Calculation:**
  In WhatsApp, Flutter records audio using the device's native recorder. The mobile client already knows the exact duration in milliseconds/seconds upon recording completion.
* **Upload Flow:**
  Mobile uploads the file to `POST /uploadAudio` or `POST /uploadMultipleAudio`. The server saves the file to `uploads/Messages/Audio/` and returns the file path.
* **Socket Send Payload:**
  When sending via socket (`send_message` or `send_group_message`), mobile should pass `"duration": 14` (integer seconds) or `"0:14"`:
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

#### 4. Group Metadata Updates (`group_updated` & `group_info_updated`)
When a group Admin edits the group name, group icon, or group description via REST `POST /updateGroup`:

* **Socket Broadcast:**
  The backend immediately emits **`group_updated`** and **`group_info_updated`** to:
  - Room `group_{groupId}`
  - Room `{groupId}`
  - Across the `/chat` and `/privateChat` namespaces.
* **Socket Event Payload:**
  ```json
  {
    "status": true,
    "groupId": 2,
    "id": 2,
    "chatId": 2,
    "groupName": "Product Engineering Team",
    "groupDesc": "Official discussion and release announcements",
    "description": "Official discussion and release announcements",
    "groupProfile": "uploads/Category/group-profile-123.jpg",
    "rawGroupProfile": "group-profile-123.jpg",
    "groupProfileUrl": "uploads/Category/group-profile-123.jpg",
    "groupCode": "GRP-88129",
    "updatedBy": 101,
    "updatedAt": "2026-11-04T12:00:00.000Z",
    "timestamp": "2026-11-04T12:00:00.000Z"
  }
  ```
* **Flutter In-Chat Screen Handler:**
  ```dart
  socket.on('group_updated', (data) {
    if (data['groupId'] == currentGroupId) {
      setState(() {
        currentGroupName = data['groupName'];
        currentGroupAvatar = data['groupProfile'];
        currentGroupDesc = data['groupDesc'];
      });
    }
  });
  ```
* **Real-time Chat List Synchronization:**
  In addition to the in-chat event, the backend automatically triggers `chat_list_updated` for all active group members, so the main WhatsApp recent chats screen immediately reflects the new group name and avatar without requiring a pull-to-refresh!

---

### 1.6 Media Upload Endpoints (Single-File & Multi-File)

**CONFIRMED.** All legacy single-file endpoints remain 100% active and supported in production alongside the multi-file endpoints:

| Media Type | Single-File Endpoint (Active) | Multi-File Endpoint (Active, Recommended) | Multipart Field Name |
| :--- | :--- | :--- | :--- |
| **Image** | `POST /uploadChatImage` | `POST /uploadMultipleChatImages` | `chatImage` or `chatImages` (up to 20) |
| **Audio** | `POST /uploadAudio` | `POST /uploadMultipleAudio` | `chatAudio` or `chatAudios` |
| **Video** | `POST /uploadVideo` | `POST /uploadMultipleVideos` | `chatVideo` (video), `thumbnail` (image) |
| **Document** | `POST /uploadDocument` | `POST /uploadMultipleDocuments` | `chatDocument` or `chatDocuments` |

---

## 2. Unified Chat List Screen (`GET /chat-list`)

Replaces separate tabs with a single WhatsApp recent chats feed.

### 2.1 Endpoint Specification
* **Method:** `GET`
* **Route Aliases:** `/chat-list`, `/chats`, `/unified-chat-list`, `/common-chat-list`
* **Headers:** `Authorization: Bearer <JWT_USER_TOKEN>`

### 2.2 Query Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `page` | `int` | `1` | Pagination page number |
| `limit` | `int` | `20` | Items per page (max 100) |
| `search` | `string` | `""` | Filters against: <br>1. **Contact Name / Mobile** (`user.name`, `user.fullName`, `user.mobileNo`)<br>2. **Group Name** (`group.name`, `group.groupName`)<br>3. **Message Content** (`lastMessage.content`, `lastMessage.preview`, `caption`) |
| `type` | `string` | `"all"` | Filter: `"all"`, `"private"`, or `"group"` |
| `includeArchived`| `bool` | `false` | When `false`, archived chats are excluded from the main list |

### 2.3 WhatsApp Business Rules Enforced by Backend
1. **0-Message Chats Excluded:** Conversations without any visible messages (`lastMessageId IS NOT NULL AND lastMessageId > 0`) are excluded.
2. **Sort Order:**
   - **1st:** Pinned conversations (`isPinned: true`, sorted by `pinnedAt DESC`).
   - **2nd:** Latest activity timestamp (`timestamp DESC` / `lastMessageAt DESC`).
3. **Contact Name Search:** Searching for user name (`user.name` / `user.fullName`), mobile number, group name (`group.name`), or text snippet inside `lastMessage.content` immediately filters the list.

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
      "name": "Bob Builder (User 2)",
      "fullName": "Bob Builder (User 2)",
      "groupName": null,
      "profileImage": "uploads/Auth/avatar.png",
      "avatar": "uploads/Auth/avatar.png",
      "groupProfile": null,
      "user": {
        "id": 3,
        "userId": 3,
        "name": "Bob Builder (User 2)",
        "fullName": "Bob Builder (User 2)",
        "Name": "Bob Builder (User 2)",
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
      "isPinned": false,
      "pinnedAt": null,
      "isMuted": false,
      "mutedUntil": null,
      "isArchived": false,
      "archivedAt": null
    },
    {
      "id": 2,
      "chatId": 2,
      "conversationId": 2,
      "groupId": 2,
      "chatType": "group",
      "isGroup": true,
      "name": "Global Engineering Team (50+ Users)",
      "groupName": "Global Engineering Team (50+ Users)",
      "profileImage": "uploads/Category/group.png",
      "avatar": "uploads/Category/group.png",
      "groupProfile": "uploads/Category/group.png",
      "user": null,
      "group": {
        "id": 2,
        "groupId": 2,
        "name": "Global Engineering Team (50+ Users)",
        "groupName": "Global Engineering Team (50+ Users)",
        "groupProfile": "uploads/Category/group.png",
        "memberCount": 52,
        "createdAt": "2026-10-20T10:00:00.000Z"
      },
      "lastMessage": {
        "id": 183182,
        "senderId": 50,
        "senderName": "WhatsApp User 50",
        "senderImage": "uploads/Auth/user50.png",
        "receiverId": null,
        "groupId": 2,
        "messageType": "text",
        "message": "Group announcement for testing!",
        "preview": "WhatsApp User 50: Group announcement for testing!",
        "content": "Group announcement for testing!",
        "caption": null,
        "isForwarded": true,
        "forwardedLabel": "Forwarded",
        "isDeletedForEveryone": false,
        "isEdited": false,
        "timestamp": "2026-11-04T10:41:00.000Z",
        "createdAt": "2026-11-04T10:41:00.000Z"
      },
      "isForwarded": true,
      "forwardedLabel": "Forwarded",
      "timestamp": "2026-11-04T10:41:00.000Z",
      "unreadCount": 3,
      "isPinned": true,
      "pinnedAt": "2026-11-04T10:00:00.000Z",
      "isMuted": false,
      "isArchived": false
    }
  ]
}
```

---

## 3. Real-Time Chat List Stream (`chat_list_updated`)

Whenever **any** message is sent, received, forwarded, edited, deleted, or group info is updated (Private or Group), the backend emits a real-time event to the user's socket.

### 3.1 Event Names Emitted to User Rooms
* `chat_list_updated`
* `common_chat_list_updated`
* `unified_chat_list_updated`

### 3.2 Payload Schema
```json
{
  "chatId": 1,
  "conversationId": 1,
  "chatType": "private",
  "isGroup": false,
  "name": "Bob Builder (User 2)",
  "profileImage": "uploads/Auth/avatar.png",
  "message": "Hello Bob!",
  "unreadCount": 1,
  "timestamp": "2026-11-04T10:40:00.000Z",
  "moveToTop": true,
  "isPinned": false
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

## 4. Message Forwarding (WhatsApp Multi-Select Forward)

### 4.1 Target Picker Endpoint
* **Method:** `GET`
* **Path:** `/list` or `/forward-list`
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

### 4.2 Forward Action
* **Method:** `POST`
* **Path:** `/message` (or socket event `forward_message`)
* **Body:**
```json
{
  "messageId": 183180,
  "sourceType": "private", // "private" or "group"
  "targets": [
    { "type": "private", "receiverId": 3 },
    { "type": "group", "groupId": 2 }
  ]
}
```

### 4.3 Visual Forwarded Badge
Every forwarded message delivered through socket or history contains:
* `isForwarded: true`
* `forwardedLabel: "Forwarded"`

The Flutter UI must render the standard WhatsApp italicized forward arrow with the **"Forwarded"** label above the message bubble.

---

## 5. Status / Stories Reply Integration

When a user replies to a Status / Story:
* **Method:** `POST`
* **Path:** `/:id/reply` (e.g. `POST /api/status/15/reply`)
* **Body:**
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
