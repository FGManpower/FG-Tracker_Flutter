# Chat Module: Questions for the Backend (after Guide v2.6.0)

For: the Node.js developer · From: the Flutter team · Date: 2026-11-06

Thanks for v2.6.0. The real `isArchived` per user and the instant `unreadCount: 0` reset are both live in the app. These questions are what is still open on our side. Each one says what we need and why.

| # | Topic | Type | Priority |
|---|---|---|---|
| 1 | Attendance vote counts in real time | Request | **High** |
| 2 | `member_removed` / `member_left` still emitted? | Confirm | **High** |
| 3 | Refresh token for `TOKEN_EXPIRED` | Question | **High** |
| 4 | `GET /archived` response details | Confirm | Medium |
| 5 | Group messages arrive twice | Question | Medium |
| 6 | Cursor-based message history | Request | Medium |
| 7 | "Messages after id" for reconnect | Request | Medium |
| 8 | Mark as unread across devices | Confirm | Low |
| 9 | `POST /mark-viewed` behaviour | Confirm | Low |
| 10 | Group status fields: which one wins | Confirm | Low |

---

## 1. Attendance vote counts in real time (Request, High)

The guide doesn't cover attendance. Vote counts in the group chat currently update only every 5 s, through a fallback refresh, not instantly.

**Questions**
- When a member votes or changes a vote, which event is sent, and to which room?
- Does every group member receive it, or only the admin who opened "View Attendance" (`attendance:subscribe`)?

**What we need:** on every vote, vote change and vote removal, send this to `group_{groupId}`:
```json
// event: "attendance:updated"
{
  "pollId": 31, "groupId": 12, "version": 7,
  "poll": {
    "id": 31,
    "counts": { "total": 5, "byOption": { "opt_1": 3, "opt_2": 2 } }
  }
}
```
`version` must go up on every change, so the app can ignore old events.

## 2. Is `member_removed` / `member_left` still emitted? (Confirm, High)

v2.3.0 documented it (§1.4, Event 2). It is **missing from v2.6.0**. The app now listens to it, so the other members' lists update live when someone is removed.

**Please confirm**
- Is it still sent to `group_{groupId}` on removal and when a member leaves?
- Is the payload still `{ groupId, userId, removedBy, isKicked, message, timestamp }`?
- Is it also sent to the removed user themselves?
- When a member is **added**, which event is sent (`member_added`? `group_updated`?), and with what payload?

## 3. Refresh token for `TOKEN_EXPIRED` (Question, High)

§8.4 says: on `connect_error` with `TOKEN_EXPIRED`, call refresh and reconnect. The app can't do that yet.

**Questions**
- Does the login / OTP-verify response return a **refresh token**? Under which field name?
- What is the exact refresh request and response (endpoint, method, body, the new access token field, expiry)?
- When the refresh token itself has expired, what does the endpoint return (status code + body)?

## 4. `GET /archived` response details (Confirm, Medium)

We want to switch the Archive screen to `GET /archived` (§4.3).

**Please confirm**
- It returns **both** private and group archived chats.
- Every row has `isArchived: true` and the same fields as `/chat-list` (including `groupStatus` and `unreadCount`).
- Pagination works the same way (`page`, `limit`, `pagination.hasNextPage`). What is the maximum `limit`?

## 5. Group messages arrive twice (Question, Medium)

Per §1.2, one group message is emitted as **both** `receive_group_message` and `receive_message` on `/chat`. The app receives the same message twice. We de-duplicate by id, so nothing breaks, but it costs extra work on every message.

**Question:** can a client opt in to receive only `receive_group_message`, for example with a handshake flag like `attendanceSupported`? Or will both always be sent?

## 6. Cursor-based message history (Request, Medium)

History is still paged by page number (`?page=&limit=`). New messages shift the pages, so the app can get duplicates (removed) or **skip a message** when one is deleted at a page boundary.

**What we need** (keep `page` for old builds):
```
GET /private-chat/:chatId/messages?before=<oldestMessageId>&limit=20
GET /getGroupMessageHistory?groupId=12&before=<oldestMessageId>&limit=20
→ { "status": true, "messages": [...newest first...],
    "pagination": { "limit": 20, "hasMore": true, "oldestId": 1512 } }
```

## 7. "Messages after id" for reconnect (Request, Medium)

`/chat/sync` updates the chat **list**. Inside an open chat, after a reconnect or app resume, the app still re-reads pages 1–5 to find messages it missed.

**What we need:**
```
GET /private-chat/:chatId/messages?after=<newestMessageId>&limit=50
GET /getGroupMessageHistory?groupId=12&after=<newestMessageId>&limit=50
→ { "status": true, "messages": [...oldest first...], "pagination": { "hasMore": false } }
```

## 8. Mark as unread across devices (Confirm, Low)

Today the app saves "mark as unread" only on the phone. We plan to call `POST /mark-unread` (§4.5).

**Please confirm**
- Does `/chat-list` then return `isMarkedUnread: true` for that chat on **all** the user's devices?
- Is it cleared automatically on `mark_seen` / `POST /mark-read`? (§10.2 suggests yes.)

## 9. `POST /mark-viewed` behaviour (Confirm, Low)

We plan to call it when the Chats screen opens (§4.8).

**Questions**
- What exactly does it clear: only the home "Chatting" dot, or anything else? Does it affect `unreadTotalCount` or per-chat `unreadCount`?
- Is there an event, or a field in another response, so a second device clears its dot too?

## 10. Group status fields: which one wins (Confirm, Low)

Chat-list rows carry `isActive`, `isDeactivated`, `status` and `groupStatus`. The `group_status_updated` example in §9.2 has the key `"status"` twice (`true` and `"deactivated"`).

**Please confirm**
- `groupStatus` (`"active"` / `"deactivated"`) is the field to trust, and the four can never disagree.
- In `group_status_updated`, is `status` a boolean or the string `"deactivated"`? Please fix the duplicate key in the example.
- Is `group_status_updated` also sent to members who **don't** have the group open (their personal user room)? Otherwise their chat list badge won't update live.
