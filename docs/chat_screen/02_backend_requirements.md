# Chat Screen: Backend Requirements (Node.js)

For: the Node.js developer · From: Flutter audit of the private and group chat screens, 2026-11-03.

The Flutter app already has guards for every item below, so nothing is broken while you work on them. The guards are listed so you know what to remove later; they are marked `TODO(backend #N)` in the code. Items are confirmed from the Flutter code. Where a detail still needs a live payload to verify, the entry says so.

| # | Item | Priority |
|---|---|---|
| 1 | Cursor-based history for private and group chats | High |
| 2 | Find an existing private chat by participant over REST | Medium |
| 3 | Seen updates: say who read, and never include the sender | Medium |
| 4 | Server must reject deleting attendance messages | **High** |
| 5 | One message payload shape for API and socket, private and group | Medium |
| 6 | "Messages after id" for catching up after reconnect or resume | Medium |

---

## 1. Cursor-based history for private and group chats

**Problem.** History is paged by page number. While a chat is open, new messages push old ones onto later pages. Flutter then gets the same messages twice (it now drops duplicates by id). Deleted messages pull rows onto earlier pages, so one message can be **skipped** at a page boundary. Flutter cannot detect or fix that skip.

**Current:**
- `GET /private-chat/:chatId/messages?page=2&limit=20`
- `GET /getGroupMessageHistory?groupId=7&page=2&limit=20`

Response:
```json
{ "status": true, "messages": [ ... ], "pagination": { "currentPage": 2, "hasNextPage": true } }
```
The private endpoint returns messages newest-first. The group endpoint's order is not fixed; Flutter sorts it.

**Required.** Add a `before` cursor to both endpoints, keeping `page` for old app versions:
```
GET /private-chat/:chatId/messages?before=1532&limit=20
GET /getGroupMessageHistory?groupId=7&before=1532&limit=20
```
Expected response:
```json
{
  "status": true,
  "messages": [ { "id": 1531, "...": "..." }, { "id": 1512 } ],
  "pagination": { "limit": 20, "hasMore": true, "oldestId": 1512 }
}
```
Rules:
- Return messages with `id < before` (or `createdAt` < the cursor message), newest first, at most `limit`.
- `hasMore` must be accurate.
- Private and group responses must have the same shape.

**Flutter dependency:** Issue 3 (pagination). Guard: `HistoryPager` in `chat_screen_logic.dart`.

---

## 2. Find an existing private chat by participant over REST

**Problem.** Several entry points open a private chat without a `chatId`: user profile, push-notification tap, bottom sheet, forward, Group → Members and Search Members. Today the only way to get the id is the socket: `emit join {userId, receiverId}` → `joined {chatId}`. If the socket can't connect, the chat can't load its history at all. Flutter now shows "Couldn't load messages · Retry" after 10 s instead of a false "No messages".

**Verify with a live capture:** that `join` always returns the **existing** chat for the pair and never creates a second one.

**Required:**
```
GET /private-chat/with/:otherUserId
→ { "status": true, "chatId": 88 }      // existing chat
→ { "status": true, "chatId": null }    // never chatted; nothing is created
```
The lookup must be idempotent and must never create a chat. Chat creation stays on the first `send_message`.

**Flutter dependency:** Issue 1 (old chat not showing).

---

## 3. Seen updates: say who read, and never include the sender

**Problem.**

Private `messages_seen_update`:
- The payload Flutter reads is `{ chatId, messageIds }`, with no reader id.
- Flutter cannot tell "B read my messages" from the echo of its own `mark_seen`.
- It used to add +1 to the seen count on every event.
- It now only marks *my* messages and caps the count at 1.

Group:
- Flutter emits `mark_seen {userId, groupId}` when a chat opens.
- The server replies with `messages_seen_update {userId}`.
- That reply reached the reader too, and Flutter added the reader to `seenBy` on **all** messages. This is why "Seen by" listed the logged-in user. It is fixed in Flutter.
- Whether the history API's `seenBy` array also includes the sender **needs a live capture**.

**Required.**
- Private:
  ```json
  { "chatId": 88, "messageIds": [1530, 1531], "seenBy": 42, "seenAt": "2026-11-03T09:12:00Z" }
  ```
- Group:
  ```json
  { "groupId": 7, "userId": 42, "messageIds": [1530, 1531], "seenAt": "2026-11-03T09:12:00Z" }
  ```
- History rows:
  ```json
  { "seenBy": [ { "userId": 42, "seenAt": "..." } ] }
  ```
  `seenBy` must never contain the message's sender.
- Optional: do not echo a reader's own `mark_seen` back to that reader.
- `seenAt` lets Message Info show the other user's seen time. The current payload has no time, so the sheet shows only "Seen".

**Flutter dependency:** Issue 5. Guard: `ChatScreenRules.seenByOthers`, `applyGroupSeen` and `applyPrivateSeen`.

---

## 4. Server must reject deleting attendance messages

**Problem.** The app no longer offers Delete on attendance messages: there is no "Delete for me / everyone" in the long-press menu, and no "Delete attendance" on the card. An old app version, or a direct call, can still delete them.

**Current:**
- Socket: `delete_message { messageId, userId, deleteType: "for_me" | "for_everyone", otherUserId? }` on `/privateChat` and `/chat`.
- REST: `DELETE /attendance/:pollId`.

**Required:**
- If the message's `messageType` is `attendance` (or it carries an `attendancePollId`), do not delete it. Reply to the sender only:
  ```json
  // socket event "delete_message_error"
  { "messageId": 1530, "code": "ATTENDANCE_NOT_DELETABLE", "message": "Attendance messages can't be deleted" }
  ```
- `DELETE /attendance/:pollId` → `403`:
  ```json
  { "status": false, "code": "ATTENDANCE_NOT_DELETABLE" }
  ```
  If admins must still delete from an admin panel, gate it by role there, not from chat.

**Flutter dependency:** Issue 2.

---

## 5. One message payload shape for API and socket, private and group

**Problem.** The Flutter parser has to accept more than 20 aliases for the same field:
- `content` / `message` / `text` / `msg` / `body`
- `senderId` / `sender_id` / `userId`
- nested `message`, `data`, `forwardedMessage` and `originalMessage` wrappers

Types also vary. If `id` arrives as a string (`"123"`) or a boolean as `0/1` / `"1"` (`isCreator`, `hasNextPage`), the old parser threw and the **whole history disappeared**. Flutter now tolerates this, but the API should not depend on that.

**Required.** One message object everywhere (history API, `receive_message`, `receive_group_message`, forward events):
```json
{
  "id": 1531, "chatId": 88, "groupId": null,
  "senderId": 42, "senderName": "Asha", "senderImage": "uploads/u/42.jpg",
  "messageType": "text", "content": "Hi", "caption": null,
  "images": [], "videos": [],
  "replyId": null, "replyType": null, "replyMessage": null, "replySenderName": null,
  "isForwarded": false, "isEdited": false, "isDeleted": false,
  "isDelivered": true, "seenBy": [],
  "createdAt": "2026-11-03T09:12:00Z"
}
```
- Ids are numbers.
- Flags are JSON booleans.
- `createdAt` is UTC ISO-8601 with a `Z`.
- Unknown future types are fine: Flutter shows an "unsupported message" placeholder.

**Flutter dependency:** Issue 1 (parsing). Guard: `GetMessage.fromJson` / `MessageData.parseIntOrNull` plus a per-row try/catch.

---

## 6. "Messages after id" for catching up after reconnect or resume

**Problem.** Messages sent while the socket was down, or while the app was in the background, were never fetched. They only appeared after reopening the chat. Flutter now refetches pages 1 to 5 until they overlap what is loaded. This costs up to 5 calls and still misses messages if more than 100 arrived.

**Required:**
```
GET /private-chat/:chatId/messages?after=1531&limit=50
GET /getGroupMessageHistory?groupId=7&after=1531&limit=50
→ { "status": true, "messages": [ ...oldest first... ], "pagination": { "hasMore": false } }
```

**Flutter dependency:** Issue 3 (reconnect and resume). Guard: `syncNewerMessages()` in both controllers, marked `TODO(backend #6)`.

---

## Checked, not included (not confirmed from code)

These need a live capture before they can be raised.

- **UTC timestamps.** Flutter parses with `DateTime.tryParse`. If `createdAt` lacks a `Z`, it is read as local time and date separators can shift around midnight. Item 5 already asks for UTC ISO.
- **From the wider audit, for your judgement:**
  1. `message_deleted` with `deleteType: "for_me"` should go only to the requester. If it is broadcast, the other user's copy disappears.
  2. Forward fires both `POST /forward/message` and a socket `forward_message` per target. Check that the server doesn't store it twice.
  3. No ack or error for `send_message`. A blocked user or a failed insert is silent.
  4. Peer presence and block changes have no live event while a chat is open.
