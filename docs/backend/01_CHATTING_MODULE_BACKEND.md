# WhatsApp-Style Chatting Module: Complete Flutter Integration Guide & Technical Specification

> **Document Version:** `v2.8.0` (Complete WhatsApp Parity: Real-Time Sockets, Anti-Self-Notification Architecture, Active Chat Suppression, Cursor Pagination, Attendance Polls & Group Status Integrity)  
> **Previous Versions:** `v2.7.0` (Technical Parity & Clarifications), `v2.6.0` (Archive State Integrity & Instant Unread Reset), `v2.5.0` (Inactive Group Support in Chat List & Sockets), `v2.3.0` (Advanced Delete Isolation, Edit Standardization & Clear Chat Media), `v2.1.0` (Unified Architecture & Aliases), `v1.0.0` (Legacy Dual-Tab System)  
> **Backend Environment:** Node.js, Express, Sequelize (MySQL/MariaDB), Socket.io  
> **Backend Compatibility:** 100% Backward Compatible (Zero breaking changes for existing Flutter builds)  
> **Verification Status:** 100% Tested & Verified in Production Backend

---

## Complete Version Changelog & Backward Compatibility Matrix

| Feature / Action | v1.0.0 (Legacy App) | v2.1.0 (Unified Standard) | v2.6.0 (Parity Release) | v2.8.0 (Current Release) | Compatibility Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Notification Delivery & Self-Notification** | Self-notifications occasionally received | Self-notifications on group messages | Partial checks | **WhatsApp Parity**: Sender NEVER receives self-notification (FCM or DB); muted groups skipped; active chat foreground suppression | **Active**: Server enforces 3-tier anti-self guard; client foreground suppression specified. |
| **Chat List Screen** | Separate screens: `GET /private-chat-list` & `GET /group-chat-list` | Single Unified Screen: `GET /chat-list` | Search filters by contact name, group name & content; excludes 0-message chats | Inactive groups fully visible with status; archived chats separated | **Active**: Legacy separate endpoints work; new unified screen aggregates both seamlessly. |
| **Real-time Chat List** | `private_chat_list_updated`, `group_chat_list_updated` | `chat_list_updated`, `common_chat_list_updated` | Auto-updates when group name/icon is edited by Admin | Recipient-isolated `isArchived` and real-time `unreadCount: 0` reset | **Active**: Server emits both legacy and unified events simultaneously. |
| **Group Message Reception** | `receive_group_message` | `receive_group_message` & `receive_message` | Emits both for backward compatibility | Emits both; mobile advised to listen to `receive_group_message` only | **Active**: Dual emission maintained; client deduplication advice clarified. |
| **Attendance Poll Counts** | Fallback 5s polling only | Not covered | Poll creation supported | Real-time `attendance:updated` socket broadcast (200ms debounce, versioned) | **Active**: Real-time vote counts and bar charts update instantly across all members. |
| **Member Removal / Leave** | Drop from list on reload | Socket `user_removed_from_group` | Documented in §1.4 | Fully restored & detailed: `member_removed`, `member_left`, and `user_removed_from_group` | **Active**: Real-time member list updates and input field disabling. |
| **Message History Pagination** | Page-based (`?page=&limit=`) | Page-based (`?page=&limit=`) | Page-based | Both Page-based AND Cursor-based (`?before=` & `?after=`) fully supported | **Active**: Older clients use `page`; new builds use `before` (scroll) and `after` (reconnect sync). |
| **Archived Chats Screen** | Separate private archive | REST: `GET /archived` | Private & Group combined | `GET /archived` returns combined list with full DTO parity, `limit: 100` max | **Active**: Unified archive feed with real `isArchived: true`. |
| **Mark as Read** | Socket `mark_seen` inside chat screen | REST: `POST /mark-read` or `POST /chat-list/mark-read` | Mark read directly from chat list swipe or screen entry | Server permanently records read and immediately broadcasts `unreadCount: 0` | **Active**: Flutter app can safely remove the temporary 2-minute timer hide workaround. |
| **Mark as Unread** | Not supported | Socket: `mark_chat_unread` | REST: `POST /mark-unread` | Multi-device DB persistence (`isMarkedUnread: true`); auto-cleared on read | **Active**: Multi-device green unread badge dot synchronized across all user devices. |
| **Mark Viewed** | Not supported | Not supported | `POST /mark-viewed` | Clears Home screen bottom-nav Chat red dot; does not reset conversation unread counters | **Active**: Extinguishes location/home notification badge across all devices. |
| **Auth & Token Lifecycle** | Custom auth | Bearer JWT | Single 90-day access token | Single 90-day JWT (`JWT_EXPIRES_IN=90d`); no refresh endpoint; OTP login on expiry | **Active**: 90-day validity; on `TOKEN_EXPIRED`, gracefully prompt user for mobile OTP login. |
| **Group Status Updates** | Group hidden on deactivate | Group hidden on deactivate | Inactive group displayed with deactivated status badge | `groupStatus` authority (`"active"` / `"deactivated"`); live broadcast to group and user rooms | **Active**: Inactive groups remain visible in all lists with deactivated status. |
| **Pin Conversation** | Socket: `pin_private_chat` (Private only) | REST: `POST /pin` or `POST /chat-list/pin` | Per-user group pinning: isolated to calling user only | Supports both REST and Socket events | **Active**: Sockets still supported; REST recommended for guaranteed HTTP status codes. |
| **Mute Conversation** | Socket: `mute_private_chat` | REST: `POST /mute` or `POST /chat-list/mute` | Supports duration via `mutedUntil` timestamp | Works on both Private and Group chats | **Active**: Sockets and REST supported. |
| **Clear / Delete Chat** | Socket `delete_private_chat` | REST: `POST /delete` or `POST /chat-list/delete` | WhatsApp-style "Clear Chat": clears history for caller only | Deleting group from chat list never removes user from group or channel | **Active**: REST provides isolated clear for both Private and Group. |
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
| **Media Uploads** | Single-file endpoints | Multi-file endpoints | Single-file & Multi-file endpoints both active | Up to 20 files per upload | **Active**: All upload endpoints fully maintained. |
| **Chat Profile Details** | Multiple separate endpoints | Multiple separate endpoints | Unified `GET /chat/profile-details` | Full Media, Links, Docs, Members & Clear Chat Media Isolation | **Active**: Dedicated screen for Contact Info & Group Info. |

---

## 0. Architectural Design, Root-Cause Forensics & Read-Only Query Protections (v2.5.0)

### 0.1 Architectural Design & Message Flow
```
                      ┌─────────────────────────────────────────┐
                      │              CLIENT APP                 │
                      └───────┬─────────────────────────┬───────┘
                              │ REST Requests           │ Socket.io
                              ▼                         ▼
             ┌─────────────────────────────┐   ┌─────────────────────────────┐
             │ Express API Routers         │   │ Socket Namespaces:          │
             │ - Group Messages:           │   │ - /privateChat (1-on-1)     │
             │   /api/getGroupMessageHistory   │   │ - /chat (Group Chat)        │
             │   /api/messages             │   └──────────────┬──────────────┘
             │ - Private Messages:         │                  │
             │   /api/private-chat-messages│                  │
             │   /api/private-chat/:id/msgs│                  │
             │ - /api/chat-list            │                  │
             └──────────────┬──────────────┘                  │
                            │                                 │
                            ▼                                 ▼
             ┌───────────────────────────────────────────────────────────────┐
             │                  SERVICE LAYER (Business Logic)               │
             │ - Multi-Param Resolver (groupId, chatId, conversationId)      │
             │ - Strict Read-Only Query Guard (No GET mutation of clearId)   │
             │ - Cursor Pagination (?before= & ?after=)                      │
             │ - WhatsApp Clear Chat Isolation (lastClearedMessageId)        │
             │ - Delete for Me vs Delete for Everyone                        │
             │ - 3-Tier Anti-Self Push Notification Filter                   │
             └──────────────────────────────┬────────────────────────────────┘
                                            │
                       ┌────────────────────┴────────────────────┐
                       ▼                                         ▼
         ┌───────────────────────────┐             ┌───────────────────────────┐
         │     SEQUELIZE / MYSQL     │             │     FIREBASE CLOUD MSG    │
         │ (Normalized Chat Tables)  │             │ (High-Priority Anti-Self) │
         └───────────────────────────┘             └───────────────────────────┘
```

### 0.2 REST API Endpoints for Message History

#### 1. Group Chat History
* **Primary Route:** `GET /api/getGroupMessageHistory`
* **Route Aliases:** `GET /api/messages`, `GET /api/group-messages`, `GET /api/group/:groupId/messages`, `GET /api/chats/:chatId/messages`
* **Authentication:** `Bearer <JWT>`
* **Parameters Accepted (Auto-Resolved):**
  - Group Identifier: `groupId`, `chatId`, `conversationId`, or `id` (via query string or route param).
  - Cursor Pagination: `before=<messageId>` (older messages) or `after=<messageId>` (newer messages).
  - Page Pagination: `page=1`, `limit=30` (max: 100).

#### 2. 1-on-1 Private Chat History
* **Primary Routes:** `GET /api/private-chat/:chatId/messages`, `GET /api/private-chat-messages`
* **Route Aliases:** `GET /api/private-chats/:chatId/messages`, `GET /api/private-messages`, `GET /api/private-chat/messages`
* **Authentication:** `Bearer <JWT>`
* **Parameters Accepted (Auto-Resolved):**
  - Chat Identifier: `chatId`, `conversationId`, `id` (via query or route param).
  - Direct Peer Fallback: `peerUserId`, `otherUserId`, `recipientId`, `userId`.
  - Cursor Pagination: `before=<messageId>`, `after=<messageId>`, `limit=30`.

### 0.3 The "Empty Messages on Re-open" Root Cause & Fix

#### 1. The Problem
Users experienced an issue where:
1. User B sends a message in Group A.
2. User A receives the notification and chats in real time (messages arrive via Socket.io `receive_group_message`).
3. User A exits the chat screen and re-opens it.
4. The chat screen suddenly appears **completely empty**, even though notifications arrived.

#### 2. Root Causes Identified
1. **Accidental Mutation during Read Query (`priorMsg` Clear Bug):**  
   In `repositories/messages.repository.js`, when a user fetched messages, if `lastClearedMessageId` was 0, it queried for `priorMsg` where `createdAt <= membership.joinedAt` and automatically executed `groupMember.update({ lastClearedMessageId: priorMsg.id })`. Due to clock-skew or timezone offsets (e.g. UTC vs IST +05:30), `priorMsg` matched the **newly created message**, writing its ID as the clear boundary and filtering out all current messages (`id > clearId`).
2. **`JoinMember` History Reset Bug:**  
   In `repositories/group.repository.js` (`JoinMember`), whenever an existing member was re-verified, it ran `existing.lastClearedMessageId = lastClearedMessageId`. This overwrote their clear pointer to the latest message, erasing history for active members upon screen re-entry.
3. **Parameter Mismatch:**  
   Frontend sent `?chatId=X` while backend controller was strictly checking `req.query.groupId`.

#### 3. The Resolution Implemented
* **Zero Mutation in Read Queries:** `messagesRepository.GetGroupMessages` NEVER mutates `lastClearedMessageId`. `lastClearedMessageId` is strictly and exclusively updated when a user deliberately taps **"Clear Chat"** (`clear_chat` / `POST /api/delete`).
* **Preserve Member State in `JoinMember`:** If a record exists in `groupMember`, its `lastClearedMessageId` and `joinedAt` are never overwritten.
* **Unified Parameter Normalizer:** Both `message.Controller.js` and `privateChat.controller.js` accept any naming variation (`groupId`, `chatId`, `conversationId`, `id`).
* **Route Aliasing:** `/api/messages`, `/api/group-messages`, and `/api/private-chat-messages` are mapped to ensure both older and newer client integrations resolve seamlessly.

### 0.4 WhatsApp-Style Isolated "Clear Chat" Architecture
When User A deletes or clears a conversation:
1. **Group Chat:** The server updates `groupmembers.lastClearedMessageId = latestMessageId` strictly for `userId = :callerId`.
   - The user is **never** removed from the group.
   - The group conversation disappears from `GET /api/chat-list` because 0 visible messages remain for this user.
   - If a new message arrives, the conversation reappears with unread count `1`, and history before `lastClearedMessageId` remains hidden.
2. **Private Chat:** The server updates `private_chat_user_settings.deletedBeforeMessageId = latestMessageId` for the caller only.

### 0.5 Cursor Pagination Implementation (`before` & `after`)
The backend implements cursor pagination in `repositories/messages.repository.js`:
```javascript
const messageWhere = {
  groupId,
  id: {
    ...(clearId > 0 ? { [Op.gt]: clearId } : {}),
    ...(deletedIds.length > 0 ? { [Op.notIn]: deletedIds } : {})
  }
};

if (isCursorBefore) {
  messageWhere.id = { ...messageWhere.id, [Op.lt]: Number(options.before) };
} else if (isCursorAfter) {
  const minAfter = Math.max(Number(options.after), clearId);
  messageWhere.id = { ...messageWhere.id, [Op.gt]: minAfter };
}
```

### 0.6 Socket.IO Namespaces & Room Management

#### 1. `/privateChat` Namespace
- **Rooms:** `chat_${chatId}` and `String(userId)`.
- **Events Handled:** `send_private_message`, `typing_private`, `mark_seen`, `delete_message`.
- **Broadcast Events:** `receive_private_message`, `user_typing_private`, `messages_seen_update`, `presence_update`.

#### 2. `/chat` Namespace
- **Rooms:** `group_${groupId}` and `${userId}_${groupId}`.
- **Events Handled:** `send_group_message`, `typing`, `mark_group_chat_read`, `edit_message`, `delete_message`.
- **Broadcast Events:** `receive_group_message`, `user_typing`, `group_info_updated`, `attendance:updated`.

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

### 1.2 Socket Event Names & Group Message Duplicate Prevention

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

> [!IMPORTANT]
> **Why Group Messages Arrive Under Two Events & How to Handle in Flutter:**  
> To maintain backward compatibility with legacy app versions that listened strictly to `receive_message`, the server emits new group messages as **both** `receive_group_message` and `receive_message` to room `group_{groupId}`.  
> **Client Best Practice:** In your Flutter group chat screen, register **ONLY ONE** listener:
> ```dart
> // Inside Group Chat Screen: Listen ONLY to receive_group_message
> socket.on('receive_group_message', (data) {
>   handleIncomingGroupMessage(data);
> });
> 
> // Do NOT also listen to 'receive_message' on the same group screen.
> // Alternatively, if your app uses a single global message bus, deduplicate by message 'id' or 'clientMessageId':
> void onMessageReceived(dynamic data) {
>   final String msgId = data['id']?.toString() ?? data['clientMessageId']?.toString() ?? '';
>   if (receivedMessageIds.contains(msgId)) return; // Discard duplicate
>   receivedMessageIds.add(msgId);
>   processMessage(data);
> }
> ```

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

### 1.5 Real-Time Group Membership Socket Events (`member_removed`, `member_left`, `member_added`)

When members are removed by an admin, voluntarily leave, or are added to a group, the backend emits real-time socket events across all relevant rooms:

#### 1. When an Admin Removes a Member (Kicked):
- **To the Removed User:** The server emits `user_removed_from_group` and `member_removed` directly to the user's socket rooms, sends an updated `chat_list_updated`, and forcibly removes all sockets belonging to that user from `group_{groupId}`:
  ```json
  // Event: "user_removed_from_group" AND "member_removed" (emitted to removed user)
  {
    "status": true,
    "groupId": 12,
    "chatId": 12,
    "chatType": "group",
    "userId": 45,
    "removedBy": 1,
    "isKicked": true,
    "message": "You have been removed from the group",
    "timestamp": "2026-11-06T15:30:00.000Z"
  }
  ```
- **To Remaining Group Members:** Emitted to `group_{groupId}` so member lists update live without refreshing:
  ```json
  // Event: "member_removed" (emitted to group_{groupId})
  {
    "status": true,
    "groupId": 12,
    "userId": 45,
    "removedBy": 1,
    "isKicked": true,
    "message": "A member was removed from the group",
    "timestamp": "2026-11-06T15:30:00.000Z"
  }
  ```

#### 2. When a Member Leaves Voluntarily:
- **To the Leaving User:** Emitted as `group_left` with `isKicked: false`.
- **To Remaining Members in `group_{groupId}`:**
  ```json
  // Event: "member_left" (emitted to group_{groupId})
  {
    "status": true,
    "groupId": 12,
    "userId": 45,
    "removedBy": null,
    "isKicked": false,
    "message": "A member left the group",
    "timestamp": "2026-11-06T15:32:00.000Z"
  }
  ```

#### 3. When a Member is Added:
- **To Group Members:** The server emits `group_updated` and `group_info_updated` to `group_{groupId}` with the updated member count and list.
- **To the Added Member:** Emits `chat_list_updated` directly to their personal user room so the new group appears at the top of their chat list immediately.

---

### 1.6 Location & Contact Message Schemas

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

### 1.7 Audio / Voice Note Duration

* **Recording & Duration:** Flutter records audio using native recorder and provides the duration in seconds.
* **Upload:** Upload to `POST /uploadAudio` or `POST /uploadMultipleAudio`. The server saves the file to `uploads/Messages/Audio/` and returns the file path.
* **Socket Send Payload:** Pass `"duration": 14` (integer seconds) or `"0:14"`:
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
* **What Backend Returns:** The server preserves and echoes `"duration": 14` directly in the message payload (`message.duration` and `message.audios[0].duration`). Flutter can directly display the audio player waveform slider and elapsed time (e.g. `0:14 / 0:35`).

---

### 1.8 Media Upload Endpoints (Single-File & Multi-File)

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

### 2.5 Message History Cursor Pagination (`before` & `after`)

Both Private and Group message history endpoints support **Cursor-Based Pagination** using message IDs, completely eliminating shifting-page duplicates and skipped messages:

#### 1. Endpoints & Query Parameters
* **Private Messages:** `GET /private-chat/:chatId/messages` (or `?otherUserId=3`)
* **Group Messages:** `GET /getGroupMessageHistory?groupId=12` (or `?id=12`)
* **Query Parameters:**
  - `limit`: Number of messages (default `20` or `50`, max `100`).
  - `before`: Integer message ID. Fetches messages strictly **older** than `before` (scrolling UP into history).
  - `after`: Integer message ID. Fetches messages strictly **newer** than `after` (downward sync upon reconnect / app resume).
  - `page`: Page number (kept 100% active for legacy builds).

#### 2. Scrolling Up: Fetching Older History (`before`)
```http
GET /getGroupMessageHistory?groupId=12&before=183180&limit=20
GET /private-chat/1/messages?before=183180&limit=20
```
- **Response Structure:**
  ```json
  {
    "status": true,
    "chatId": 12,
    "conversationId": 12,
    "groupId": 12,
    "messages": [
      { "id": 183179, "content": "Previous older message...", "timestamp": "..." },
      { "id": 183160, "content": "Oldest message in this batch...", "timestamp": "..." }
    ],
    "pagination": {
      "limit": 20,
      "hasMore": true,
      "oldestId": 183160,
      "currentPage": 1,
      "totalRecords": 85
    }
  }
  ```
  *When `hasMore` is `false`, the client has reached the top of the chat history.*

#### 3. Reconnect Downward Sync (`after`)
When the app reconnects to the network, fetch only missed messages without re-reading pages 1 to 5:
```http
GET /getGroupMessageHistory?groupId=12&after=183182&limit=50
GET /private-chat/1/messages?after=183182&limit=50
```
- **Response Structure:**
  ```json
  {
    "status": true,
    "chatId": 12,
    "messages": [
      { "id": 183183, "content": "Missed message 1", "timestamp": "..." },
      { "id": 183184, "content": "Missed message 2", "timestamp": "..." }
    ],
    "pagination": {
      "limit": 50,
      "hasMore": false
    }
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
* **Query Parameters:**
  - `page`: Page number (default `1`)
  - `limit`: Items per page (default `20`, maximum `100`)
  - `search`: Search filter (contact name, group name, content)
* **Confirmed Behavior:**
  - Returns **both** private and group archived conversations combined.
  - Every item is guaranteed to have `isArchived: true` and a valid `archivedAt` timestamp.
  - Returns identical DTO fields as `GET /chat-list` (including `groupStatus`, `lastMessage`, and `unreadCount`).
  - Standard pagination schema (`currentPage`, `perPage`, `totalRecords`, `totalPages`, `hasNextPage`).

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

### 4.5 Mark Chat as Unread (Multi-Device DB Synchronization)
WhatsApp allows users to mark a conversation as unread (showing a green unread badge dot):
* **REST Route:** `POST /mark-unread` (aliases: `/mark-as-unread`, `/chat-list/mark-unread`)
* **Request Body:**
  ```json
  {
    "chatId": 1,
    "chatType": "private"
  }
  ```
  *(For group chats: `{"groupId": 12, "chatType": "group"}`)*
* **Multi-Device Persistence Confirmation:**
  - Persisted in MySQL/MariaDB (`groupMember.isMarkedUnread = true` or `private_chat_user_settings.isMarkedUnread = true`).
  - Broadcasts `chat_list_updated` with `"isMarkedUnread": true` to **all active devices** of the user.
  - `GET /chat-list` returns `"isMarkedUnread": true` across all user logins until opened.
  - **Auto-Cleared:** As soon as the user opens the chat (`mark_seen` or `POST /mark-read`), the server automatically resets `isMarkedUnread: false`.

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

### 4.8 Mark Chat List as Viewed (`POST /mark-viewed`)
When the user opens the Chats tab/screen, call this endpoint to extinguish the unread red dot on the Home navigation bar:
* **REST Route:** `POST /mark-viewed` (aliases: `/chat-list/mark-viewed`, `/chats/mark-viewed`)
* **Behavior & Scope Clarification:**
  - Clears **strictly the Home screen bottom navigation Chats badge/dot** (`notificationViewStore`).
  - It does **NOT** alter conversation-level `unreadCount` or `unreadTotalCount` in `GET /chat-list`.
  - Notifies other devices of the same user via the `/location` namespace so their home screen badges clear simultaneously.

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

### 8.4 Authentication & Token Lifecycle Architecture (`TOKEN_EXPIRED`)

The backend implements a **single, long-lived JWT access token** architecture designed for mobile reliability:
- **Token Validity:** Access tokens are signed with a **90-day expiration** (`JWT_EXPIRES_IN=90d`).
- **No Refresh Token Endpoint:** The backend intentionally does not use short-lived access tokens with a separate refresh endpoint.
- **Handling `TOKEN_EXPIRED`:** When a token expires after 90 days, the user's session is terminated. The app should display a clean session expiry alert and redirect to the OTP / Phone login screen:

```dart
void setupSocketAuthHandler(IO.Socket socket, BuildContext context) {
  socket.onConnectError((err) {
    final errorStr = err.toString();
    if (errorStr.contains("TOKEN_EXPIRED") || errorStr.contains("jwt expired")) {
      // 90-day token has expired: route to mobile OTP login
      AuthService.clearSession();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

---

### 9.2 Real-Time Socket Event: `group_status_updated`
When an Admin calls `POST /deActivateGroup` or `POST /activateGroup`, the server immediately emits:
1. `group_status_updated` and `group_updated` to room `group_{groupId}`.
2. `chat_list_updated` directly to each group member's individual user room with `groupStatus: "deactivated"`.

```json
{
  "status": "deactivated",
  "groupStatus": "deactivated",
  "groupId": 12,
  "id": 12,
  "chatId": 12,
  "isActive": false,
  "isDeactivated": true,
  "updatedBy": 1,
  "updatedAt": "2026-11-06T19:00:00.000Z"
}
```

> [!NOTE]
> **Authoritative Status Field:**  
> `groupStatus` (`"active"` or `"deactivated"`) is the authoritative string field. `isActive` (boolean) and `isDeactivated` (boolean) are guaranteed to match `groupStatus` at all times.

---

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

### 9.4 Admin Activation & Deactivation REST API Specification
* **Endpoints:** `POST /deActivateGroup` (or alias `POST /activateGroup`)
* **Headers:**
  * `Authorization: Bearer <JWT_USER_TOKEN>` (Required — Admin permission verified)
  * `Content-Type: application/json`
* **Request Payload (Supported Keys):**
  ```json
  {
    "groupId": "12",
    "isActiveGroup": "false"
  }
  ```
  *(Note: Backend validator enforces `groupId` as String and `isActiveGroup` as String ("true" / "false")).*
* **Response Payload (Success):**
  ```json
  {
    "status": "deactivated",
    "message": "Group deactivated successfully",
    "groupId": 12,
    "isActive": false
  }
  ```
  *(Note: The Flutter client's `CommonResponse` and `GroupRes` parse both string statuses such as `"deactivated"` / `"active"` / `"success"` and boolean values safely without throwing type-cast exceptions).*

---

## 10. Advanced WhatsApp Parity Updates: Real `isArchived` State & Instant Unread Reset

### 10.1 Real-Time Archive State Integrity (`isArchived` Fix)
* **What Was Fixed:** In group message broadcasts, the server previously generated a base summary using the sender's user context, causing other members who had archived the group to receive `isArchived: false` and un-archive their chats.
* **Current Behavior:** The server resolves `groupMember.isArchived` specifically for each recipient user. When a user has archived a group, `chat_list_updated` always carries `isArchived: true` and `archivedAt: "..."`.
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

## 12. Real-Time Attendance Poll Sockets (`attendance:updated`)

Attendance polls in group chats update in **real time** whenever any member votes, changes their vote, or removes their vote.

### 12.1 Socket Event Specification
* **Namespace:** `/chat`
* **Event Name:** `attendance:updated`
* **Rooms Emitted To:**
  - `group_{groupId}` (All members currently inside the group screen)
  - `user_{userId}` (Direct personal room for each active group member)
* **Coalescing / Debounce:** 200 ms server-side debounce to prevent broadcast flooding during rapid voting.
* **Monotonic Versioning:** Every update increments the integer `version` property (`1, 2, 3...`) so the Flutter app can reject out-of-order stale packets.

### 12.2 Payload Schema (`attendance:updated`)
```json
{
  "groupId": 12,
  "pollId": 31,
  "messageId": 183250,
  "version": 7,
  "poll": {
    "id": 31,
    "title": "Site Inspection Attendance",
    "question": "Will you attend the 9 AM inspection at Site B?",
    "isActive": true,
    "options": [
      { "id": "opt_1", "text": "Present" },
      { "id": "opt_2", "text": "Absent" },
      { "id": "opt_3", "text": "On Leave" }
    ],
    "counts": {
      "total": 15,
      "byOption": {
        "opt_1": 10,
        "opt_2": 3,
        "opt_3": 2
      }
    }
  }
}
```

### 12.3 Admin Detail Subscription (`attendance:subscribe`)
When an Admin opens the dedicated "Attendance Detail" screen to see individual voter names:
* **Admin Emits:** `attendance:subscribe` with `{ "pollId": 31 }`. (Joins socket room `attendance_admin_31`).
* **Admin Receives:** `attendance:vote_changed` containing the voter's user details:
  ```json
  {
    "pollId": 31,
    "userId": 45,
    "userName": "Alice Smith",
    "optionId": "opt_1",
    "action": "voted",
    "timestamp": "2026-11-06T15:40:00.000Z"
  }
  ```
* **When Leaving Detail Screen:** Admin emits `attendance:unsubscribe` with `{ "pollId": 31 }`.

### 12.4 Flutter Poll Widget Implementation
```dart
int lastPollVersion = 0;

void listenToAttendanceUpdates(IO.Socket socket, int currentPollId) {
  socket.on('attendance:updated', (data) {
    final int pollId = data['pollId'] ?? data['poll']?['id'];
    final int version = data['version'] ?? 0;

    if (pollId == currentPollId && version > lastPollVersion) {
      lastPollVersion = version;
      final pollData = data['poll'];
      final Map<String, dynamic> counts = pollData['counts'];
      
      setState(() {
        currentPoll.updateCounts(
          total: counts['total'],
          byOption: Map<String, int>.from(counts['byOption']),
        );
      });
    }
  });
}
```

---

## 14. Push & In-App Notification Handling (WhatsApp Parity Specification)

WhatsApp-style notification behavior requires strict coordination between the backend push dispatch and the mobile app's foreground notification state.

### 14.1 Backend Anti-Self-Notification Architecture
The backend enforces a **3-tier anti-self guard** across all message dispatch pipelines:
1. **Sender ID Exclusion:**
   - In Group Messages: Group member recipients are filtered with `Number(member.userId) !== Number(senderId)`. The sender is strictly skipped from both FCM push notification and database notification creation.
   - In Private Messages: If `Number(senderId) === Number(receiverId)`, notification dispatch is aborted immediately.
2. **Device Token Verification:**
   - Even if user records differ, if `receiver.Device_Id === sender.Device_Id`, push notification is suppressed to prevent self-buzzing.
3. **Muted Group & Notification Preference Honor:**
   - If a member has muted the group (`notifications_enabled: false` or `isMuted: true`), push notifications are skipped for that user while message delivery on socket remains 100% active.

### 14.2 Flutter In-App Active Chat Suppression (WhatsApp Rule)
Just like WhatsApp, when a user is actively chatting inside a conversation:
- **Heads-Up Banner Suppression:** If a push notification arrives via FCM (`FirebaseMessaging.onMessage`) for the **currently opened chat screen**, Flutter must **suppress** the notification banner and alert sound. The message is already displayed live via the active Socket.io stream.
- **Outside Chat / In-App Notification:** If the user is on the Home screen, Chat List, or a different conversation, Flutter displays the heads-up notification banner with a tap action to open that chat.
- **Sender Check:** If `data['senderId'] == currentUserId`, unconditionally discard the notification.

### 14.3 FCM Notification Data Payloads

#### 1. Group Chat Notification Payload
```json
{
  "title": "Operations Team",
  "body": "User 50: Group announcement for testing!",
  "data": {
    "notificationId": "10425",
    "screen_name": "groupChatScreen",
    "groupId": "12",
    "groupName": "Operations Team",
    "senderId": "50",
    "messageType": "text"
  }
}
```

#### 2. Private Chat Notification Payload
```json
{
  "title": "Bob Builder",
  "body": "Hello Bob! Testing WhatsApp chat module",
  "data": {
    "notificationId": "10426",
    "screen_name": "chatScreen",
    "chatType": "private",
    "chatId": "1",
    "conversationId": "1",
    "senderId": "3",
    "receiverId": "2",
    "messageType": "text"
  }
}
```

### 14.4 Complete Flutter Notification Handler Implementation
```dart
class ChatNotificationService {
  static int? currentlyActiveGroupId;
  static int? currentlyActiveChatId;

  static void initialize() {
    // 1. Foreground Push Notification Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      final int myUserId = AuthService.currentUserId;
      final int senderId = int.tryParse(data['senderId']?.toString() ?? '') ?? 0;

      // Rule 1: Never notify for self-sent messages
      if (senderId == myUserId) {
        return;
      }

      // Rule 2: Active Chat Screen Suppression (WhatsApp behavior)
      final String screenName = data['screen_name'] ?? '';
      if (screenName == 'groupChatScreen') {
        final int groupId = int.tryParse(data['groupId']?.toString() ?? '') ?? 0;
        if (currentlyActiveGroupId == groupId) {
          // User is currently chatting in this group: SUPPRESS notification banner!
          return;
        }
      } else if (screenName == 'chatScreen') {
        final int chatId = int.tryParse(data['chatId']?.toString() ?? data['conversationId']?.toString() ?? '') ?? 0;
        if (currentlyActiveChatId == chatId) {
          // User is currently chatting in this private chat: SUPPRESS notification banner!
          return;
        }
      }

      // Rule 3: User is elsewhere in the app: Show in-app heads-up notification banner
      showLocalNotificationBanner(
        title: message.notification?.title ?? data['groupName'] ?? "New Message",
        body: message.notification?.body ?? data['body'] ?? "",
        payload: data,
      );
    });

    // 2. Notification Click Handling (Background & Terminated states)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigateToChatFromNotification(message.data);
    });
  }

  // Call on chat screen open
  static void setActiveChat({int? groupId, int? chatId}) {
    currentlyActiveGroupId = groupId;
    currentlyActiveChatId = chatId;
  }

  // Call on chat screen dispose / exit
  static void clearActiveChat() {
    currentlyActiveGroupId = null;
    currentlyActiveChatId = null;
  }
}
```

---

## 15. Flutter Developer Production Checklist

Before releasing the updated build to production or testing:

1. [x] **Unified Chat List:** Call `GET /chat-list` for recent chats feed. Verify 0-message chats are excluded and pinned items appear first.
2. [x] **Socket Handshake:** Pass JWT token in `auth: {'token': token}` and `query: {'token': token}`. Access token is valid for 90 days. On `TOKEN_EXPIRED`, route to OTP login screen.
3. [x] **Anti-Self Notification:** Server enforces sender exclusion. In Flutter `FirebaseMessaging.onMessage`, ignore any packet with `senderId == myUserId`.
4. [x] **Active Chat Notification Suppression:** Maintain `currentlyActiveGroupId` / `currentlyActiveChatId`. When active, suppress foreground notification banners.
5. [x] **Real-time Chat List Listener:** Register listener for `chat_list_updated`. Update local state in-place and re-order after pinned conversations.
6. [x] **Group Messages Listener:** In group chat screens, register *only* `receive_group_message` (or deduplicate by `id` / `clientMessageId`) to prevent duplicate bubbles.
7. [x] **Attendance Poll Real-Time Updates:** Register listener for `attendance:updated`. Update poll vote bars and counts in real time using the incrementing `version` check.
8. [x] **Group Member Removal & Leave:** Listen for `member_removed`, `user_removed_from_group`, and `member_left`. When current user is removed, disable input bar and prompt user.
9. [x] **Cursor History Pagination:** Use `?before=<oldestId>&limit=20` for upward scrolling and `?after=<newestId>&limit=50` for reconnect sync.
10. [x] **Read Receipts:** Emit `mark_seen` when entering chat screen. Listen for `messages_seen_update` to upgrade Double Grey Ticks ✓✓ to Double Blue Ticks ✓✓.
11. [x] **Unread Count Reset:** Remove 2-minute timer workaround; rely directly on server's `unreadCount: 0` broadcast.
12. [x] **Multi-Device Mark as Unread:** Call `POST /mark-unread` to show green badge across all user devices. Automatically cleared on `mark_seen`.
13. [x] **Home Screen Red Dot:** Call `POST /mark-viewed` when Chats tab is opened. Clears bottom nav red dot without affecting conversation counters.
14. [x] **Dedicated Archive Screen:** Query `GET /archived` (up to `limit: 100`) for combined private and group archived conversations.
15. [x] **Edit Message:** Listen to `message_edited` and `messageEdited`. Render standard italicized `(edited)` label.
16. [x] **Delete for Me:** When deleting "for me", only update local UI; listen for `message_deleted` to update `lastMessage` to previous visible message.
17. [x] **Inactive Groups:** Check `data['groupStatus'] == 'deactivated'` or `data['isDeactivated'] == true`. Render disabled bar `"This group has been deactivated by the Admin"`.
