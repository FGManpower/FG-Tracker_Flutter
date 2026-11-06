# Chat List: Backend Requirements (Node.js / Socket.IO)

For: the Node.js developer · From: the Flutter chat-list fix (branch `46Solution`) · Related: [01_RCA_report.md](01_RCA_report.md)

The Flutter side is done and works with today's payloads. The items below are what Flutter **cannot** fix correctly on its own. Each one names the Flutter issue that depends on it. Payload field names match what the app already parses. Everything is **additive and backward compatible** unless marked otherwise.

**Namespaces in use:** `/privateChat` (private chats and the chat-list socket, auth `{userId, token}`) and `/chat` (groups, auth `{token}`). The app now keeps both connected for the whole logged-in session.

| # | Item | Priority | Unblocks Flutter issue |
|---|---|---|---|
| 1 | Deliver typing and new-message list events to each member's **personal user room** | High | 1 Typing, 6 New message |
| 2 | Per-user pin/archive/delete flags stored in the DB, **for groups too** | High | 2 Actions |
| 3 | Multi-device sync event after every action | Medium | 2 Actions |
| 4 | `lastMessage` with raw fields: id, content, type, senderId, senderName | High | 5 Name twice, 4 Archive order |
| 5 | `lastMessageAt` for sorting; read/seen must not change it | Medium | 4 Archive order |
| 6 | Mark-as-unread API, persisted per user | Medium | 2 Actions |
| 7 | Correct per-recipient unread counts | High | 7 Counts |
| 8 | Actionable `private_chat_action_error` (or acks) | Medium | 2 Actions |
| 9 | Clear auth error on expired token at socket connect | Low | Global socket layer |
| 10 | Single-chat fetch endpoint | Low | 6 New message |

---

## 1. Typing and new-message events to personal rooms

- **Problem:** `typing` / `stop_typing` (private) and `group_typing` / `group_stop_typing` (group) are emitted only to the chat or group room. A user sitting on the chat list hasn't joined those rooms, so the list never sees typing. It's not confirmed whether `chat_list_updated` for a **group** message reaches members who never opened that group in the session.
- **Current:** Client emits `typing {chatId, userId, senderId, otherUserId, receiverId, userName, isTyping:true}` on `/privateChat`, and `group_typing {groupId, userId, senderId, userName, isTyping:true}` on `/chat`.
- **Required:** On connect, join every socket to `user:<userId>`. Re-emit typing and list updates to each recipient's personal room (never back to the typist):
  ```js
  // private
  io.of('/privateChat').to(`user:${receiverId}`).emit('typing', payload);
  // group: every member except the typist, on /chat
  members.filter(id => id !== userId)
         .forEach(id => io.of('/chat').to(`user:${id}`).emit('group_typing', payload));
  // after saving any message (private or group)
  recipients.forEach(id => nsp.to(`user:${id}`).emit('chat_list_updated', rowFor(id)));
  ```
  Keep the payloads exactly as above (the app reads `userId`/`senderId`, `userName`/`senderName`, `chatId` or `groupId`). The app expires a typing indicator by itself after 5 s.
- **Backward compatible:** yes.

## 2. Per-user flags in the DB, for private and group chats

- **Problem:** `pin_private_chat`, `unpin_private_chat`, `archive_private_chat`, `unarchive_private_chat` and `delete_private_chat` are named and probably implemented for private chats only. The app sends them for **group rows too**, using the group's `chatId`/`id`. There is no "delete for me" for groups at all (the app removes the row locally and it comes back on refresh).
- **Required:** Store a per-user row `chat_user_state(userId, chatType, chatId|groupId, isPinned, pinnedAt, isArchived, isDeleted, deletedAt, manualUnread)`. Accept these events for both types by adding `chatType`:
  ```json
  { "userId": 1001, "chatId": 77, "chatType": "group" }
  ```
  `delete_*` = hide for me until a newer message arrives (WhatsApp "delete chat"). `archive` keeps the chat archived when new messages arrive. Return all flags on every row of `/chat-list` and the archived list.
- **Backward compatible:** yes. If `chatType` is missing, treat it as `private`.

## 3. Multi-device sync after every action

- **Problem:** Pin/archive/read/delete made on one device doesn't update my other devices.
- **Required:** After applying an action, emit the updated row to **all of the actor's own sockets** (`user:<userId>`), using the existing event so no client change is needed:
  ```json
  // event: chat_list_updated  (to user:1001)
  { "chatId": 2001, "userId": 505, "chatType": "private",
    "isPinned": true, "pinnedAt": "2026-11-03T09:00:00Z",
    "isArchived": false, "unreadCount": 0 }
  ```
  For delete, emit the existing `private_chat_removed {chatId, chatType}`.
- **Backward compatible:** yes.

## 4. `lastMessage` with raw fields

- **Problem:** The sender name shows twice when `preview` is pre-formatted (`"Rahul: hi"`) and the app adds its own label. The app now formats from raw fields when they're present, but needs them in **every** payload (API and socket) in the same shape.
- **Required:** In `/chat-list` rows, `archived_private_chats` rows and `chat_list_updated`:
  ```json
  "lastMessage": {
    "id": 98765,
    "content": "hi",
    "messageType": "text",
    "caption": null,
    "senderId": 600,
    "senderName": "Rahul",
    "isDeletedForEveryone": false,
    "timestamp": "2026-11-03T09:00:00Z",
    "preview": "Rahul: hi"
  }
  ```
  Media/poll: put type-specific fields alongside (`images:[…]`, `fileName`, `duration`, `attendance:{title}`/`poll:{question}`). `preview` may stay for older app versions. New apps ignore it when `content` is present.
- **Backward compatible:** yes.

## 5. `lastMessageAt` for sorting

- **Problem:** The Archived list reordered when the other user opened the chat. The server array order (and possibly the row time) changes on read/seen.
- **Required:** Add `lastMessageAt` (time of the last *message*, never `updatedAt`) to every row. Sort `/chat-list` and `archived_private_chats` by `isPinned DESC, lastMessageAt DESC, chatId ASC`. Don't push `archived_private_chats` because of a read/seen. Push a single-row `chat_list_updated` instead.
  ```json
  { "chatId": 2001, "lastMessageAt": "2026-11-03T09:00:00Z", "lastMessage": { "id": 98765 } }
  ```
- **Backward compatible:** yes.

## 6. Mark-as-unread API

- **Problem:** "Mark as unread" is saved only in the phone's local storage. It's lost on reinstall and invisible on other devices.
- **Required:** Socket events (same style as the others) persisted in `chat_user_state.manualUnread`, cleared automatically when the chat is read:
  ```json
  // emit: mark_chat_unread   { "userId": 1001, "chatId": 2001, "chatType": "private" }
  // row field everywhere:    "isMarkedUnread": true
  ```
  Then sync to my other devices as in #3. The Flutter change after this ships: send the event and read `isMarkedUnread` (about 15 lines in `ChatListController.markChatAsUnread`).
- **Backward compatible:** yes.

## 7. Correct per-recipient unread counts

- **Problem:** If the same row payload is broadcast to the sender and the receiver, the sender's own message raises the sender's badge. The app currently guards against this (`TODO(backend #7)` in `chat_list_logic.dart` and `chat_list_controller.dart`); remove the guard once this ships.
- **Required:** `unreadCount` is computed **per recipient**: messages from others, after my last read, excluding deleted. Never count the sender's own message. Reset on `mark_private_chat_read` / group `mark_seen` and push the zero to my devices (#3). In `/chat-list`:
  ```json
  { "unreadTotalCount": 7, "archivedUnreadCount": 2, "data": [ { "chatId": 2001, "unreadCount": 3 } ] }
  ```
  `unreadTotalCount` must **exclude** archived chats. Partial socket updates should **omit** `unreadCount` rather than send `0`, unless the count really is 0. The app now treats a missing field as "unchanged".
- **Backward compatible:** yes.

## 8. Actionable action errors (or acks)

- **Problem:** The app rolls an optimistic action back on `private_chat_action_error`, but it can only match the right chat when the payload says which one it was.
- **Required:**
  ```json
  // event: private_chat_action_error
  { "action": "archive", "chatId": 2001, "chatType": "private", "message": "Chat not found" }
  ```
  Optional, better: support Socket.IO acks on all action events (`callback({ok:true})` / `callback({ok:false, message})`).
- **Backward compatible:** yes.

## 9. Auth error on an expired token

- **Problem:** Sockets read the token once at creation. If it expires, the server may silently refuse events.
- **Required:** In the namespace auth middleware, reject with `next(new Error('unauthorized'))` (code `401` in `err.data`) so the client gets `connect_error` and can refresh the token and reconnect.
- **Backward compatible:** yes.

## 10. Single-chat fetch

- **Problem:** When a message arrives for a chat that isn't in the loaded page and the event lacks row details, the app refetches page 1 (throttled). A single-row endpoint is cheaper.
- **Required:** `GET /chat-list/:chatType/:id`, which returns one row in the same shape as `/chat-list` data items.
- **Backward compatible:** yes.
