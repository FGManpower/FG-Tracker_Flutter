# Tracking Module — Backend Technical Specification & Contract

**Document Version:** `v1.0.0`  
**Target Audience:** Backend Developers (Node.js / Express / Sequelize / Socket.IO)  
**Covers:** Spatial Radius Queries, Group Location Tracking, `/location` WebSocket Namespace, Ghost Mode Sync, Background Coordinate Ingestion, Battery Level Storage  
**Status:** In Production / Stable  

---

## 0. Architecture & Namespace Map

The backend tracking infrastructure powers real-time spatial queries and live coordinate synchronization:
1. **Spatial Radius Radar (`/users-within-radius`):** High-speed geospatial query (PostGIS or Haversine SQL formula) returning members within a dynamic distance radius (`radius` in meters).
2. **Group Tracking API (`/getGrouplocationsData`):** Returns the latest known location, battery, and online status of all members in a specific group.
3. **Location Socket (`/location`):** WebSocket namespace for bidirectional live GPS coordinate streaming (`send-location`, `group-location-update`).
4. **Ghost Mode (Location Privacy):** Dedicated privacy endpoint (`POST /location-sharing/update`) enforcing location redaction across all socket broadcasts and spatial queries.

---

## 1. WebSocket Protocol Specification (`/location` Namespace)

**Connection URL:** `ws://<HOST>:<PORT>/location`  
**Transports:** `["websocket"]`

### 1.1 Socket Events & Payload Matrix

| Event Name | Direction | Payload Schema | Server Responsibility |
|---|---|---|---|
| `join-group` | Client ➔ Server | `{"groupId": "5", "userId": "12"}` | Add client socket to room `group_location_5`. |
| `leave-group` | Client ➔ Server | `{"groupId": "5", "userId": "12"}` | Remove client socket from room `group_location_5`. |
| `send-location` | Client ➔ Server | `{"userId": "12", "groupId": "5", "lat": 28.7041, "lng": 77.1025, "area": "Connaught Place", "city": "New Delhi", "address": "...", "battery": 85}` | 1. Check if user has `location_sharing = 1`. If `0` (Ghost Mode), do NOT broadcast coordinates.<br>2. Upsert user coordinates & battery in DB.<br>3. Broadcast `send-location` to all sockets in room `group_location_5`.<br>4. Respond with `location-update-success`. |
| `send-location` | Server ➔ Client | Same as incoming `send-location` | Delivers real-time position of circle members. |
| `group-location-update` | Server ➔ Client | `[{"userId": "12", "lat": 28.7041, "lng": 77.1025, ...}]` | Bulk snapshot sent to newly joined room members. |
| `location-update` | Server ➔ Client | `{"userId": "12", "lat": 28.7041, "lng": 77.1025}` | Lightweight single-member coordinate update. |
| `location-update-success`| Server ➔ Client | `{"status": true, "data": {"dashboardCounts": {...}, "notificationMarkers": {...}}}` | Confirms coordinate save and pushes updated dashboard counts. |
| `user-offline` / `user-left`| Server ➔ Client | `{"userId": "12"}` | Broadcast when member disconnects or disables sharing. |

---

## 2. Location Privacy (Ghost Mode) Enforcement

> **CRITICAL BACKEND SECURITY RULE:**  
> When a user has `location_sharing = 0` (Ghost Mode active):
> 1. The server must **NEVER** return their coordinates in `/users-within-radius`, `/getGrouplocationsData`, or WebSocket broadcasts.
> 2. The user's status must be flagged as `locationSharing: false`.
> 3. The user may still query locations of other circle members who have permitted sharing.

### 2.1 Update Location Sharing API
- **Endpoint:** `POST /location-sharing/update`
- **Request Body:**
```json
{
  "userId": 12,
  "locationSharing": false // false = Ghost Mode ON; true = Ghost Mode OFF
}
```
- **Response Format:**
```json
{
  "status": true,
  "message": "Location sharing updated successfully"
}
```
- **Side Effects:**
  - Updates column `users.location_sharing = 0`.
  - Emits `user-left` or `user-offline` to active group rooms on `/location` socket so their marker is immediately extinguished from peers' screens.

---

## 3. Spatial REST API Specifications

Base URL: `/api` | Header: `Authorization: Bearer <JWT>`

### 3.1 Get Users Within Radius
- **Endpoint:** `GET /users-within-radius` (Fallback: `GET /users-within-radius-fallback`)
- **Query Parameters:**
  - `userId`: Querying user ID
  - `lat` / `userLat`: Latitude float (e.g. `28.7041`)
  - `long` / `userLong`: Longitude float (e.g. `77.1025`)
  - `radius`: Distance radius in meters (Integer, e.g. `2000`)
- **Haversine Formula Implementation (SQL / Sequelize):**
```sql
SELECT id, name, profile_image, lat, lng, battery, last_seen,
  ( 6371000 * acos( cos( radians(:userLat) ) * cos( radians( lat ) )
  * cos( radians( lng ) - radians(:userLong) ) + sin( radians(:userLat) )
  * sin( radians( lat ) ) ) ) AS distance
FROM users
WHERE location_sharing = 1
  AND id != :userId
HAVING distance <= :radius
ORDER BY distance ASC;
```
- **Response Format (`UsersWithinRadiusRes`):**
```json
{
  "status": true,
  "message": "Nearby users retrieved",
  "data": [
    {
      "id": 45,
      "userId": 45,
      "name": "Sarah Connor",
      "profileImage": "https://cdn.example.com/profiles/sarah.jpg",
      "lat": 28.7095,
      "lng": 77.1080,
      "distance": 850.5,
      "distanceFormatted": "850 m",
      "isOnline": true,
      "battery": 92,
      "area": "Rohini",
      "city": "Delhi",
      "address": "Sector 9, Rohini, Delhi",
      "lastSeen": "2026-11-06T12:45:00.000Z"
    }
  ]
}
```

---

### 3.2 Get Group Locations Data
- **Endpoint:** `GET /getGrouplocationsData?groupId=5`
- **Response Format (`LocationDataRes`):**
```json
{
  "status": true,
  "message": "Group locations retrieved",
  "locations": [
    {
      "id": 101,
      "userId": 12,
      "groupId": 5,
      "name": "Alex Morgan",
      "profileImage": "https://cdn.example.com/profiles/alex.jpg",
      "isCreator": true,
      "isOnline": true,
      "locationSharing": true,
      "latitude": 28.7041,
      "longitude": 77.1025,
      "battery": 85,
      "area": "Connaught Place",
      "city": "New Delhi",
      "address": "Barakhamba Road, New Delhi",
      "lastSeen": "2026-11-06T12:50:00.000Z"
    }
  ]
}
```

---

### 3.3 Get Filtered Group Members
- **Endpoint:** `GET /allGroupMembers?groupId=5&filter=all&page=1&limit=20`
- **Filters:**
  - `filter=all`: Returns all group members.
  - `filter=active`: Returns members currently sharing location (`location_sharing = 1`).
  - `filter=private`: Returns members who have enabled Ghost Mode (`location_sharing = 0`).

