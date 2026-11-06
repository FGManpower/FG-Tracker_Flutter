# Backend: make the Attendance module production-ready

**Context:** FG Tracker backend (Node.js, Express, Sequelize/MySQL, Socket.IO), currently at `http://fgtracker.in:3000`, branch `trial-walki-module` (latest `df7ec57a`). The Flutter app is already updated and depends on the contract below. **Do not rename events, routes, or response fields.** You may add new fields. Everything must keep working for **old app versions already on users' phones**.

Work through each section, then reply with: ✅ / ❌ per item, the commit hash, test output, and the server log lines requested in section 9.

---

## 1. Contract the app depends on (keep exactly)

### REST (prefix `/api`, `Authorization: Bearer <jwt>`, the app sends `x-attendance-supported: 1` on every request)

| Method | Path | Who | Notes |
|---|---|---|---|
| POST | `/groups/:groupId/attendance` | group admin | Body: `title`, `description?`, `eventDate`, `eventTime?`, `location?`, `options[]`, `photoRequiredOptionLabel?`, `allowVoteChange`, `voterVisibility` (`admin`/`all`), `deadlineAt?` (**optional**, ISO UTC) |
| GET | `/groups/:groupId/attendance?page&limit&status` | member | Paginated list |
| GET | `/attendance/:pollId` | member | `{ poll, myVote }`; deleted poll returns **404** `{status:false, message:"Poll not found", code:"POLL_NOT_FOUND"}` |
| POST | `/attendance/:pollId/vote` | member | multipart: `optionId`, `clientRequestId`, `latitude?`, `longitude?`, `locationName?`, `locationAccuracy?`, `attendancePhoto?` (JPEG) |
| DELETE | `/attendance/:pollId/vote` | member | Remove own vote |
| GET | `/attendance/:pollId/voters?status=voted\|notVoted&page&limit` | admin (or member when `voterVisibility=all`) | Each row: `userId`, `name`, `profileImage` (same raw format as `sender.ProfileImage`), `optionId`, `optionLabel`, `votedAt`, `capturedAt`, `photoUrl`, `livenessVerified`, `location{lat,lng,name,accuracy}`; plus `counts{total,byOption,eligible,notVoted}` and `pagination` |
| PUT | `/attendance/:pollId` | admin | Edit |
| POST | `/attendance/:pollId/close` | admin | |
| DELETE | `/attendance/:pollId` | admin | A second delete returns **404 JSON**, never an SQL error |
| GET | `/attendance/:pollId/export` | admin | `200 text/csv`; columns: `Name, Phone, Response, Voted At (Asia/Kolkata), Location, Latitude, Longitude, Photo URL`; members who didn't respond are listed as "Not responded" |

Every error response: `{ status:false, message, code }` with the correct HTTP status code. No SQL text and no stack traces.

### Socket.IO

**`/chat` namespace.** Handshake `auth: { token, attendanceSupported:"1" }`, `query: { attendanceSupported:"1" }`.

| Direction | Event | Payload |
|---|---|---|
| client→server | `join`, `join_group_chat` | `{ userId, groupId }`: join `group_<groupId>` |
| client→server | `mark_seen` | `{ userId, groupId }` |
| client→server | `attendance:subscribe` (ack) | `{ pollId }` → ack `{ ok, room }` or `{ ok:false, code:"FORBIDDEN" }`; joins `attendance_admin_<pollId>` |
| client→server | `attendance:unsubscribe` | `{ pollId }` |
| client→server | `attendance:sync` (ack) | `{ pollIds:[...] }` → ack `{ polls:[ <full poll> ] }` |
| server→group room | `attendance:created` | `{ poll, message, groupId, pollId, version }` |
| server→group room | `attendance:updated` | `{ poll, version, groupId, pollId }`, where `poll` includes `id`, `status`, `totalVotes`, `countsByOption`, `version`, `createdBy{id,name,profileImage}` |
| server→group room | `attendance:edited`, `attendance:closed` | `{ poll, version, groupId, pollId }` |
| server→group room and user rooms | `attendance:deleted` | `{ pollId, groupId, messageId }`, plus `message_deleted { messageId, groupId, isDeletedForEveryone:true }` |
| server→voter's user rooms | `attendance:my_vote` | `{ pollId, groupId, version, myVote }` |
| server→`attendance_admin_<pollId>` | `attendance:vote_changed` | `{ poll, version, groupId, pollId, action, voter{userId,name,profileImage,optionId,optionLabel,votedAt,capturedAt,photoUrl,livenessVerified,location} }` |
| server→group room | `receive_group_message` | Normal chat messages. Attendance messages: `messageType:"attendance"`, `attendance`, `attendancePollId` |

**`/privateChat` namespace.** Handshake `auth: { userId, token }`. Events: `mark_seen {chatId,userId,otherUserId}`, `mark_private_chat_read {chatId,userId}` → emit `chat_list_updated` / `private_chat_updated` with `unreadCount: 0` for that user.

**`/location` namespace.** Sends **no token**, in any app version. Must keep working unchanged.

---

## 2. Blockers (must fix before production)

### 2.1 Connections without a token must keep working
- If a handshake has a valid token, take the user ID from the token and ignore the payload `userId`.
- If a handshake has **no token** (old app versions on `/chat` and `/privateChat`, and every version on `/location`), fall back to the payload or handshake `userId` exactly as before. Never disconnect or silently ignore those sockets.
- If a token is present but **invalid or expired**, log it and fall back to the same legacy behaviour for now. Don't disconnect, or users get logged out of chat mid-session.
- `attendance:subscribe` may require a valid token (new apps send one). When it fails, return the `FORBIDDEN` ack; don't throw.

### 2.2 Atomic version increment
`version: Number(poll.version) + 1` reads the number and writes it back, so two simultaneous votes get the same version, and the app drops one of the updates. Replace it with:
```js
await sequelize.transaction(async (t) => {
  const poll = await AttendancePoll.findByPk(pollId, { transaction: t, lock: t.LOCK.UPDATE });
  // ... validate + upsert vote ...
  await poll.increment('version', { by: 1, transaction: t });
  await poll.reload({ transaction: t });
});
// emit AFTER commit, using the reloaded poll.version
```
Apply this to vote, change vote, remove vote, edit, close and delete. Emit only after the transaction commits, never before.

### 2.3 Correct legacy-client detection
How does the server decide that a client is "legacy" and gets the text fallback `📋 Attendance: <title> - please update the app to vote`? The new app sends `x-attendance-supported: 1` on REST and `attendanceSupported:"1"` on `/chat`, but **not** on `/privateChat`. The new app must never see the fallback text in the chat list or in the chat. If detection is per user rather than per socket, describe how.

---

## 3. Vote rules (enforce on the server)
- Voters must be active members of the poll's group. Admins can vote too, unless the product says otherwise.
- One vote per user per poll: a unique index on `(pollId, userId)`. Changing a vote is allowed only when `allowVoteChange` is true.
- Votes are rejected when the poll is closed, deleted, or past its `deadlineAt` (when it has one): `409 {code:"POLL_CLOSED"}`.
- Idempotency: if the same `clientRequestId` arrives again, return the first result and don't create a second vote or bump the version.
- Photo-required option: reject a missing photo with `400 {code:"PHOTO_REQUIRED"}`.
- Validate latitude in −90..90 and longitude in −180..180. Location fields are optional.

## 4. Uploads and privacy
- Accept only JPEG and PNG, check the file's actual content type and not just its extension, and limit size to 5 MB. Store under random names.
- Don't allow directory listing under `/uploads/Attendance/Photos`. Preferably serve photos only to group admins (or members when `voterVisibility=all`) through an authorized route. If they stay as public static files, confirm the names are random and can't be guessed.
- Never put phone numbers, tokens or photo bytes in socket logs.
- When a poll is deleted, keep the photos for the retention period the product owner sets, then remove them with a cleanup job.

## 5. Reliability
- Wrap every socket handler in try/catch. A bad payload must never crash the process.
- Socket emits: keep `JSON.parse(JSON.stringify(payload))`.
- PM2 currently runs one process. If cluster mode or more servers are ever turned on, add `@socket.io/redis-adapter` and sticky sessions in the same release. Without them, live updates reach only part of the users.
- Scheduler: auto-close runs only on `NODE_APP_INSTANCE === '0'` (or when that variable is unset in fork mode). Check that it isn't skipped entirely in fork mode.
- Rate limits (current: 10 creates/min, 30 votes/min, 10 exports/min): return `429 {code:"RATE_LIMITED"}`. Key them by user ID, not IP, since many users share mobile IPs.
- Database indexes: `attendance_votes(pollId, userId)` unique, `attendance_votes(pollId, optionId)`, `attendance_polls(groupId, status, createdAt)`.

## 6. Dates
- Store everything in UTC. Calculate "today" for `eventDate` checks, the CSV "Voted At" column, and any future end-of-day auto-close in **Asia/Kolkata**.
- `deadlineAt` is optional; missing or null means the poll stays open until the admin closes it.

## 7. Notifications and chat list
- Poll created: FCM push to group members who are offline or in the background (`FG Tracker: <Sender>: 📋 <Title>`), unread count +1, chat list preview `📋 <Title>`.
- No push and no unread +1 for the creator.
- `mark_seen` / `mark_private_chat_read` reset that user's `unreadCount` to 0 and emit `chat_list_updated`.
- Deleted poll: the chat list preview updates to "This message was deleted" if it was the last message.

## 8. Cleanup before release
- Keep the `receive_group_message` / `messageType:"attendance_test"` emit until the mobile team confirms the 2-phone test, then **remove it** in the same release that goes to production.
- Detailed socket logs only when `LOG_LEVEL=debug`; production runs at `info`.
- `/api/version` reads the commit from git (or a build environment variable) at startup, not a hard-coded string.

## 9. Testing

**Automated tests (add to `tests/api/attendancePoll.test.js`):**
1. Two votes at the same moment on one poll produce distinct versions N+1 and N+2.
2. The same `clientRequestId` sent twice creates one vote and one version bump.
3. Voting on a closed or deleted poll → 409 / 404.
4. A non-member vote → 403; a non-admin export, delete or close → 403.
5. A second delete → 404 JSON.
6. A socket with no token still joins `group_<id>` and receives `receive_group_message`.
7. A socket with a token receives `attendance:updated` after an HTTP vote.
8. Export with members who didn't respond → "Not responded" rows; times in IST.
9. Create without `deadlineAt` → the poll stays open after the scheduler runs.

**Manual 2-phone check on staging** (admin phone A, member phone B, same group chat open). Send us the server log lines for each step:
1. A creates a poll: B sees it instantly and gets a push notification when the app is closed.
2. B votes with a selfie: A's card count and View Attendance list (photo, location, profile picture) update within about 1 s. Log: `[ChatMessage][join] socket.id=… rooms=[…]` for both phones, plus `[Attendance] emit attendance:updated -> group_<id> (N sockets), version=…`.
3. B changes the vote, then removes it: both phones update.
4. A closes the poll: B can't vote.
5. A exports the CSV; it opens on Android and iOS.
6. A deletes the poll: it disappears on both phones; deleting again returns 404.
7. B turns the phone's internet off and on: it reconnects and catches up through `attendance:sync`.
8. Both users have the chat open and send messages: unread counts stay at 0.
9. An **old app build** (previous store version) can still chat, see location, and sees the fallback text for the poll.

## 10. Deployment
1. Open a PR from `trial-walki-module` into the production branch; review and merge it. **Deploy the production branch, not the trial branch.**
2. On the server, run `mysqldump` of the database and copy `/uploads` before migrating.
3. `git pull` the production branch, then `npx sequelize-cli db:migrate`, then `pm2 restart FG_Tracker`.
4. `curl http://fgtracker.in:3000/api/version`: send us the commit hash.
5. Set up a **daily** MySQL dump and a daily copy of `/uploads/Attendance/Photos` stored off the server; name the person who checks them.
6. Rollback plan: the previous commit hash plus the dump. Write down the steps to run the migration's `down`.
7. HTTPS (later release): put Nginx or Caddy with Let's Encrypt in front of the app, and support `wss://` with the `Upgrade` headers. Send us the new URL **before** switching; keep `:3000` running in parallel until the new app version is adopted.

**Reply format:** a table of item numbers 2.1–10 with ✅/❌ and notes, the commit hash, test output (passing counts), and the log lines from step 9.
