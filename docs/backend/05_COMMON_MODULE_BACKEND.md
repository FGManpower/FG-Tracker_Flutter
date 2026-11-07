# Common Application Architecture — Backend Technical Specification & Contract

**Document Version:** `v1.0.0`  
**Target Audience:** Backend Developers (Node.js / Express / Sequelize / Socket.IO)  
**Covers:** 90-Day JWT Lifecycle, 3-Tier Force Logout Engine, Dashboard & Stories Sockets (`/dashboard`, `/status`), FCM Notification Dispatch Rules, Anti-Self Notification Enforcement  
**Status:** In Production / Stable  

---

## 0. Architecture & Namespace Map

The Common Backend infrastructure orchestrates system-wide services:
1. **Authentication & Token Lifecycle:** 90-day single JWT access token (`JWT_EXPIRES_IN=90d`). No refresh tokens.
2. **Three-Tier Force Logout System:** Synchronous account termination across FCM, WebSockets, and HTTP 401 interceptors.
3. **Dashboard WebSocket Namespace (`/dashboard`):** Pushes live group counts, active members, and dashboard widget stats.
4. **Stories & Status WebSocket Namespace (`/status`):** Real-time WhatsApp-style 24-hour status stories (`status:new`, `status:viewed`, `status:deleted`).
5. **Anti-Self Notification Engine:** Strict database & FCM rules guaranteeing senders never receive push or DB notifications for their own actions.

---

## 1. Authentication & Token Lifecycle

### 1.1 90-Day Single JWT Token Standard
- Upon successful OTP verification (`POST /verifyOtp`), the server issues a single JWT access token.
- Expiration: 90 days (`JWT_EXPIRES_IN=90d`).
- Payload contains: `{ id: user.id, phone: user.phone, role: user.role }`.
- When expired or revoked, the server responds with HTTP `401 Unauthorized` and payload `{"status": false, "message": "TOKEN_EXPIRED"}`. The client will gracefully prompt the user for an OTP re-login.

---

## 2. Three-Tier Force Logout Engine

When an account is logged in from a second device or terminated by an administrator, the backend MUST trigger an immediate force logout across three independent channels:

```
                          Force Logout Event
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        ▼                          ▼                          ▼
   [ Channel 1 ]              [ Channel 2 ]              [ Channel 3 ]
  FCM High-Priority          WebSocket Event            HTTP 401 Interceptor
  type: "FORCE_LOGOUT"       "force_logout"             on Next API Request
```

1. **Channel 1 — FCM High-Priority Push:**
   ```json
   {
     "to": "<DEVICE_FCM_TOKEN>",
     "priority": "high",
     "content_available": true,
     "data": {
       "type": "FORCE_LOGOUT",
       "screen_name": "force_logout",
       "message": "Your account has been logged in on another device."
     }
   }
   ```
2. **Channel 2 — WebSocket Broadcast (`force_logout`):**
   - Emitted to all connected namespaces for that `userId`: `/dashboard`, `/callSignaling`, `/groupCall`, `/location`, `/chat`.
   - Payload: `{"message": "Logged in from another device"}`.
3. **Channel 3 — HTTP 401:** Invalidates previous JWT token in database/Redis blacklist so any subsequent HTTP call triggers client-side logout.

---

## 3. Dashboard WebSocket Protocol (`/dashboard` Namespace)

**Connection URL:** `ws://<HOST>:<PORT>/dashboard`

### 3.1 Event Matrix

| Event Name | Direction | Payload Schema | Server Responsibility |
|---|---|---|---|
| `get-group-dashboard-counts` | Client ➔ Server | `{"userId": 12}` | Calculate total groups, active groups, member counts, online counts. |
| `group_dashboard_counts` | Server ➔ Client | `{"status": true, "data": {"totalGroups": 8, "activeGroups": 6, "totalMembers": 42, "onlineMembers": 29, "unreadNotifications": 3}}` | Broadcast updated statistics to user dashboard. |
| `get-user-live-location` | Client ➔ Server | `{"groupId": 5, "userId": 12}` | Query active locations of group members for dashboard widget. |
| `user-live-location` | Server ➔ Client | `{"status": true, "locations": [...]}` | Stream live coordinates for home mini-map. |
| `force_logout` | Server ➔ Client | `{"message": "Session invalidated"}` | Immediate termination trigger. |

---

## 4. Stories & Status WebSocket Protocol (`/status` Namespace)

**Connection URL:** `ws://<HOST>:<PORT>/status`  
**Auth:** Header or query containing Bearer JWT token.

### 4.1 Event Matrix

| Event Name | Direction | Payload Schema | Server Responsibility |
|---|---|---|---|
| `status:new` | Server ➔ Client | `{"statusId": 105, "userId": 34, "userName": "John", "mediaUrl": "...", "type": "image", "createdAt": "..."}` | Broadcast to mutual contacts when a new 24-hr status is posted. |
| `status:viewed` | Client ➔ Server | `{"statusId": 105, "viewerId": 12}` | Record view receipt in DB; relay to status author. |
| `status:deleted` | Server ➔ Client | `{"statusId": 105, "userId": 34}` | Broadcast to contacts to immediately remove the status tile. |

---

## 5. Anti-Self Notification & Delivery Rules

1. **Self-Notification Prohibition:** In every notification trigger (Chat message, Group invite, Call invitation, Poll vote), the backend query MUST exclude the sender:
   ```sql
   WHERE group_members.user_id != :senderId
   ```
2. **Muted Chat / Channel Rule:** If a user has muted a conversation or has disabled notifications for a Walkie channel, FCM push notifications must be suppressed for that user.
3. **Active Chat Suppression Coordination:** The backend includes `chatId` / `groupId` in FCM data payloads so the Flutter client can silence notifications if that conversation is currently open on screen.

