# Chat Screen: Backend Requirements, Addendum

For: the Node.js developer. Follow-up to `02_backend_requirements.md` (items #1–#6 there are unchanged). Date: 2026-11-03.

These came out of a second round of Flutter fixes. Items #7 and #8 matter most: the app now relies on them.

| # | Item | Priority |
|---|---|---|
| 7 | "Delete for me" event: send it only to the requester, and include `userId` | **High** |
| 8 | Same edit-event payload in private and group chats | Medium |
| 9 | Acknowledge `send_message` (success or error) | Medium |
| 10 | Socket auth token is read only once | Medium |
| 11 | Update the chat list after a delete, with the new last message | **High** |
| 12 | Profile media must respect "Clear chat" | Medium |

---

## 7. "Delete for me" event: send it only to the requester, and include `userId`

**Problem.**
- When user A deletes a message "for me", the other user's copy must stay.
- If the server broadcasts `message_deleted` with `deleteType: "for_me"` to both users, the other user's app removes the message too.
- The app now ignores a `for_me` event whose `userId` isn't the current user. Without a `userId` in the event, the app can't tell who deleted it and falls back to removing it.

**Current.**
- The app emits on `/privateChat` or `/chat`:
  ```json
  { "messageId": 1530, "userId": 42, "deleteType": "for_me", "otherUserId": 9 }
  ```
- The server answers with `message_deleted`.

**Required.**
- `for_me`: emit `message_deleted` **only to the requester's sockets** (all of their devices), with the deleter's id:
  ```json
  { "messageId": 1530, "deleteType": "for_me", "userId": 42, "chatId": 88 }
  ```
- `for_everyone`: emit to everyone in the chat, with the same shape, and `groupId` instead of `chatId` for groups.

## 8. Same edit-event payload in private and group chats

**Problem.** The private and group screens used to read `messageEdited` differently: one matched on `id`, the other on `messageId`. The app now accepts both, but the server should send one shape.

**Required** (`messageEdited`, both namespaces):
```json
{ "messageId": 1530, "chatId": 88, "groupId": null, "content": "updated text", "isEdited": true, "editedAt": "2026-11-03T09:12:00Z" }
```

## 9. Acknowledge `send_message` (success or error)

**Problem.** `send_message` and `send_group_message` get no reply. A blocked user, a failed save or a server error looks like a successful send. The app now blocks sending while it's offline, but it still can't detect a send the server rejected.

**Required.** Support a socket.io acknowledgement callback on `send_message` and `send_group_message`:
```js
socket.on("send_message", async (payload, ack) => {
  // ... save ...
  ack?.({ status: true, message: savedMessage });        // success: the full saved message
  // or
  ack?.({ status: false, code: "BLOCKED", message: "You can't message this user" });
});
```
This stays backward compatible: old app versions don't pass a callback.

## 10. Socket auth token is read only once

**Problem.** The app sends the login token in the socket `auth` when the connection is first created. When the token expires or refreshes, the app keeps reconnecting with the old token.

**Required.** Please confirm which of these applies:
- (a) The server checks the token only on the first connect, so reconnects work. Nothing to do.
- (b) Every reconnect is checked. Then send a clear `connect_error` with `{ "message": "TOKEN_EXPIRED" }` so the app can rebuild the socket with the new token.

---

## 11. Update the chat list after a delete, and send the new last message

**Problem.** When a message is deleted ("for me" or "for everyone") while the chat isn't open on the other user's phone, their chat list keeps showing the deleted text. The app now fixes the row itself when the chat is open, or when it closes. With the chat closed, only the server knows.

**Required.** After `delete_message`, emit `chat_list_updated` to the affected users, carrying the chat's new last message:
- for_everyone → everyone in the chat:
  ```json
  { "chatId": 88, "lastMessage": { "id": 1530, "content": "This message was deleted", "isDeletedForEveryone": true, "createdAt": "..." } }
  ```
- for_me → only the requester, with the previous message as `lastMessage` (or `null` if none is left).

Priority: **High**.

## 12. Profile media must respect "Clear chat"

**Problem.** After "Clear chat", the profile's Media / Links / Docs section still listed the cleared files. The app now empties it immediately and refetches `/chat/profile-details`. If that API still returns media from before the clear, the files come back.

**Required.** `profile-details` (private and group) returns `media` / `mediaSummary` only for messages after the requesting user's clear timestamp, the same rule the message history already uses.

Priority: Medium.
