# Calling Module — Backend Technical Specification & Contract

**Document Version:** `v1.1.0` · **Last updated:** 2026-11-07  
**Target Audience:** Backend Developers (Node.js / Express / Sequelize / Socket.IO)  
**Covers:** Single & Group Audio/Video Calling, WebRTC Signaling Sockets, CallKit/VoIP FCM Payloads, Call History APIs, Duration & Status Persistence  
**Status:** In Production / Stable  

---

## 0. Architecture & Namespace Map

The backend calling infrastructure powers two core communication channels:
1. **1-on-1 Signaling Socket (`/callSignaling`):** Handles bidirectional SDP offer/answer relay, ICE candidate exchange, mute/camera state sync, screen share signaling, and call termination.
2. **Group Calling Socket (`/groupCall`):** Multi-peer mesh WebRTC coordinator maintaining room rosters, join/leave events, mute/camera states, screen share broadcasts, and admin termination.
3. **REST APIs:** Call state persistence (`/updateCallingStatus`), paginated recent call history (`/recentCallHistory`), detailed session audit (`/getCallDetail`), and single/bulk deletion.
4. **VoIP / FCM Push Notification Pipeline:** High-priority VoIP/FCM push for wake-on-call when the recipient application is in background or terminated.

---

## 1. WebSocket Signaling Protocols

### 1.1 Single Call Signaling Namespace (`/callSignaling`)

**Connection URL:** `ws://<HOST>:<PORT>/callSignaling?callerId=<USER_ID>`  
**Auth / Query:** `callerId` (User ID string). The server must map the socket to this `userId` room.

#### Event Matrix

| Event Name | Direction | Payload Schema | Server Responsibility |
|---|---|---|---|
| `makeCall` | Client ➔ Server | `{"callerId": "12", "calleeId": "34", "sdpOffer": {...}, "isVideo": true, "callId": "CALL_101", "callerName": "Alex", "profileImage": "..."}` | 1. Create DB call record in `ringing` state.<br>2. Route to `calleeId` socket via `newCall`.<br>3. If callee socket disconnected, dispatch high-priority VoIP/FCM push. |
| `newCall` | Server ➔ Client | Same as `makeCall` with session metadata | Dispatched to target callee socket. |
| `answerCall` | Client ➔ Server | `{"callerId": "12", "calleeId": "34", "sdpAnswer": {...}, "callId": "CALL_101"}` | Relay `callAnswered` to caller socket. Update DB call status to `accepted` / `in-progress` with `startedAt = NOW()`. |
| `callAnswered` | Server ➔ Client | Same as `answerCall` payload | Dispatched to caller socket. |
| `IceCandidate` | Client ➔ Server | `{"callerId": "12", "calleeId": "34", "candidate": {...}}` | Relay to remote peer as `iceCandidate`. |
| `iceCandidate` | Server ➔ Client | `{"candidate": {...}}` | Relayed candidate delivered to peer. |
| `callRejected` | Client ⇄ Server | `{"callerId": "12", "calleeId": "34", "callId": "CALL_101", "sessionId": "..."}` | Update DB call status to `rejected`. Forward to caller socket and dismiss CallKit notification. |
| `endCall` | Client ➔ Server | `{"callerId": "12", "calleeId": "34", "callId": "CALL_101"}` | Update DB call status to `ended`, compute duration (`endedAt - startedAt`). Broadcast `callEnded` to peer. |
| `callEnded` | Server ➔ Client | `{"callId": "CALL_101", "sessionId": "..."}` | Informs peer the session was terminated. |
| `toggle-camera` | Client ⇄ Server | `{"callerId": "12", "calleeId": "34", "isVideoOn": false}` | Relay camera toggle state to peer. |
| `toggle-mute` | Client ⇄ Server | `{"callerId": "12", "calleeId": "34", "isMuted": true}` | Relay microphone mute state to peer. |
| `screen-share-offer` | Client ➔ Server | `{"callerId": "12", "calleeId": "34", "sdpOffer": {...}}` | Relay screen share WebRTC offer to peer. |
| `screen-share-answer`| Client ➔ Server | `{"callerId": "12", "calleeId": "34", "sdpAnswer": {...}}` | Relay screen share WebRTC answer to peer. |
| `cancelMissedCallTimer`| Server ➔ Client | `{"callId": "CALL_101"}` | Signals client that call was picked up or cancelled. |

---

### 1.2 Group Call Signaling Namespace (`/groupCall`)

**Connection URL:** `ws://<HOST>:<PORT>/groupCall?userId=<USER_ID>`  
**Auth / Query:** `userId` (User ID string).

#### Event Matrix

| Event Name | Direction | Payload Schema | Server Responsibility |
|---|---|---|---|
| `group_call_started` | Client ➔ Server | `{"groupId": "5", "callerId": "12", "isVideo": true, "callId": "GC_501"}` | 1. Initialize room `group_call_5`.<br>2. Broadcast invite to all circle members (Sockets + FCM). |
| `group_call_participant_joined` | Broadcast | `{"groupId": "5", "userId": "34", "name": "Jane", "profileImage": "...", "isMuted": false}` | Add participant to active room roster; broadcast to all room sockets. |
| `group_call_participant_left` | Broadcast | `{"groupId": "5", "userId": "34"}` | Remove from active room; broadcast departure. If zero members remain, close session and record duration. |
| `group_call_participant_rejected`| Broadcast | `{"groupId": "5", "userId": "34", "userName": "Jane"}` | Mark participant as rejected; notify host. |
| `group_call_participant_mute` | Broadcast | `{"groupId": "5", "userId": "34", "isMuted": true}` | Broadcast updated mic mute state. |
| `group_call_camera_changed` | Broadcast | `{"groupId": "5", "userId": "34", "isVideoOn": false}` | Broadcast updated video state. |
| `group_call_offer` | Peer ➔ Peer | `{"senderId": "12", "receiverId": "34", "sdp": {...}}` | Mesh WebRTC SDP offer routed directly to `receiverId`. |
| `group_call_answer` | Peer ➔ Peer | `{"senderId": "34", "receiverId": "12", "sdp": {...}}` | Mesh WebRTC SDP answer routed directly to `receiverId`. |
| `group_call_ice` | Peer ➔ Peer | `{"senderId": "12", "receiverId": "34", "candidate": {...}}` | Route ICE candidate between peers. |
| `group_call_screen_share_started` | Broadcast | `{"groupId": "5", "userId": "12"}` | Notify room of active screen broadcast track. |
| `group_call_screen_share_stopped` | Broadcast | `{"groupId": "5", "userId": "12"}` | Notify room screen broadcast has terminated. |
| `group_call_participants_update` | Server ➔ Client | `{"participants": [{"userId": "12", "name": "Alex", "status": "in_call", "isMuted": false}], "total": 4}` | Comprehensive room snapshot sent upon member changes. |
| `group_call_ended` | Broadcast | `{"groupId": "5", "callId": "GC_501"}` | Host terminated call for all members. |

---

## 2. VoIP & Background Push Notification Specification

When the callee is not connected to `/callSignaling` or `/groupCall`, backend must dispatch high-priority FCM notifications.

### 2.1 FCM High-Priority VoIP Payload
```json
{
  "to": "<RECIPIENT_FCM_TOKEN>",
  "priority": "high",
  "content_available": true,
  "data": {
    "type": "CALL",
    "callType": "single",
    "callId": "CALL_101",
    "callerId": "12",
    "callerName": "Alex Morgan",
    "callerProfile": "https://cdn.example.com/profiles/alex.jpg",
    "isVideo": "true",
    "sdpOfferCompressed": "eJztV...<compressed_string>...",
    "timestamp": 1730900000000
  }
}
```
*Backend Requirement:* Compress large SDP offer strings using Deflate/GZip if payload size exceeds 3.5 KB.

---

## 3. REST API Specifications

Base URL: `/api` | Header: `Authorization: Bearer <JWT>`

### 3.1 Get Recent Call History
- **Endpoint:** `GET /recentCallHistory`
- **Query Parameters:**
  - `page`: Page index (Integer, default `0`)
  - `type`: Filter type (`all`, `missed`, `incoming`, `outgoing`)
- **Response Format:**
```json
{
  "status": true,
  "message": "Call history retrieved successfully",
  "pagination": {
    "currentPage": 0,
    "totalPages": 3,
    "totalRecords": 25,
    "hasMore": true
  },
  "data": {
    "calls": [
      {
        "id": "CALL_101",
        "callId": "CALL_101",
        "callerId": "12",
        "calleeId": "34",
        "callerName": "Alex Morgan",
        "callerProfile": "https://cdn.example.com/profiles/alex.jpg",
        "calleeName": "John Doe",
        "calleeProfile": "https://cdn.example.com/profiles/john.jpg",
        "callType": "video",
        "direction": "incoming",
        "status": "ended",
        "duration": 184,
        "createdAt": "2026-11-06T14:32:00.000Z"
      }
    ]
  }
}
```

---

### 3.2 Get Call History Detail
- **Endpoint:** `GET /getCallDetail?callId=CALL_101`
- **Response Format:**
```json
{
  "status": true,
  "message": "Call detail retrieved",
  "data": {
    "callId": "CALL_101",
    "isGroup": false,
    "groupId": null,
    "groupName": null,
    "groupProfile": null,
    "callType": "video",
    "status": "ended",
    "duration": 184,
    "startTime": "2026-11-06T14:32:00.000Z",
    "endTime": "2026-11-06T14:35:04.000Z",
    "caller": {
      "userId": "12",
      "name": "Alex Morgan",
      "phone": "+919876543210",
      "profileImage": "https://cdn.example.com/profiles/alex.jpg"
    },
    "participants": [
      {
        "userId": "34",
        "name": "John Doe",
        "profileImage": "https://cdn.example.com/profiles/john.jpg",
        "status": "accepted",
        "joinedAt": "2026-11-06T14:32:05.000Z",
        "leftAt": "2026-11-06T14:35:04.000Z"
      }
    ]
  }
}
```

---

### 3.3 Update Calling Status
- **Endpoint:** `POST /updateCallingStatus`
- **Request Body:**
```json
{
  "callId": "CALL_101",
  "remoteUserId": "34",
  "callingStatus": "rejected" // "accepted" | "rejected" | "missed" | "ended"
}
```
- **Response:**
```json
{
  "status": true,
  "message": "Calling status updated successfully"
}
```

---

### 3.4 Delete Call History
- **Delete Single Call:** `DELETE /recentCallHistory` with query `?callId=CALL_101` and body `{"callId": "CALL_101"}`
- **Delete Multiple Calls:** `DELETE /recentCallHistory` with body `{"callIds": ["CALL_101", "CALL_102"]}`
- **Clear All:** `DELETE /recentCallHistory` with body `{"clearAll": true}`
- **Response:**
```json
{
  "status": true,
  "message": "Call history deleted successfully"
}
```
- **Used by the app's Recent Calls multi-select** (long-press → select → Delete): the app sends **Delete Multiple Calls** once for all selected ids.
- **Backend request:**
  1. Confirm that `callIds` is supported and deletes only the caller's own history rows.
  2. If some ids fail, return them (for example `"failedIds": [...]`) so the app can restore only those rows. Today the app treats the call as all-or-nothing.

---

## 4. Database Schema Guidelines (Sequelize / SQL)

### Calls Table (`calls`)
- `id` (VARCHAR/UUID, Primary Key)
- `call_id` (VARCHAR, Unique Index)
- `caller_id` (BIGINT, Foreign Key -> users.id)
- `callee_id` (BIGINT, Nullable for group calls)
- `group_id` (BIGINT, Nullable for 1-on-1 calls)
- `call_type` (ENUM: `'audio'`, `'video'`)
- `status` (ENUM: `'ringing'`, `'accepted'`, `'rejected'`, `'missed'`, `'ended'`)
- `duration` (INT, seconds elapsed)
- `started_at` (DATETIME, Nullable)
- `ended_at` (DATETIME, Nullable)
- `created_at` (DATETIME)
- `updated_at` (DATETIME)

### Group Call Participants Table (`group_call_participants`)
- `id` (BIGINT, Auto-increment, Primary Key)
- `call_id` (VARCHAR, Index)
- `user_id` (BIGINT, Index)
- `status` (ENUM: `'ringing'`, `'accepted'`, `'rejected'`, `'left'`)
- `joined_at` (DATETIME, Nullable)
- `left_at` (DATETIME, Nullable)

---

## 5. Change log
| Version | Date | Change |
|---|---|---|
| v1.1.0 | 2026-11-07 | §3.4: the app's Recent Calls multi-select now uses Delete Multiple Calls (`callIds`). Backend request: confirm `callIds` support and return `failedIds` for partial failures. |
| v1.0.0 | — | First version. |
