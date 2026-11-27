# Tracking Module — Flutter Frontend Architecture & Implementation Guide

**Document Version:** `v1.1.0`  
**Target Audience:** Flutter Frontend Developers  
**Covers:** Google Maps Integration, Custom Bitmap Markers, Radius Radar Overlay, Group Tracking, Background Geolocation Service, Battery Monitoring, Ghost Mode Privacy Sync, Tracker Share  
**Status:** In Production / Stable  

---

## 0. Architecture & File Registry

| Layer | File Path | Core Responsibility |
|---|---|---|
| **Repositories** | `lib/app/Data/Repositories/TrackRepo.dart` | REST API layer: `/users-within-radius`, `/getGrouplocationsData`, `/location-sharing/update` |
| **Location Service** | `lib/app/modules/Track/Controller/LocationService.dart`<br>`lib/app/Data/Services/Tracking.dart`<br>`lib/app/Data/Services/LocationPermission.dart` | Device GPS polling (`LocationAccuracy.high`), background streams, time normalization |
| **Location Sockets** | `lib/app/modules/Track/Controller/TrackLiveLocationSocketService.dart`<br>`lib/app/modules/Track/Controller/SocketServices.dart` | Manages `/location` socket: `send-location`, `join-group`, `leave-group` |
| **Radius State** | `lib/app/modules/Track/Controller/TrackingController.dart` | Radius slider (500m–50km), Google Maps radar circle, markers, member list |
| **Group Track State**| `lib/app/modules/Track/Controller/GroupTrackController.dart` | Group tracking screen state, room socket events, ghost mode sync, polyline routes |
| **Screens & Views** | `lib/app/modules/Track/Views/Tracking_screen.dart`<br>`lib/app/modules/Track/Views/GroupTrackLocationScreen.dart`<br>`lib/app/modules/Track/Views/Search_Members.dart` | Presentation layers |

---

## 1. Live Tracking by Nearby Radius (`TrackingController`)

### 1.1 Radar Circle & Radius Slider
Located in `Tracking_screen.dart`:
- **Radius Slider:** Dynamically updates `radius.value` from `500m`, `1km`, `2km`, `5km`, `10km`, `25km`, up to `50km`.
- **Strict Mutual Group Privacy Guard:**
  - In `TrackingController.dart`, members in `radiusUsers` are strictly restricted to users who share a common enterprise group with the logged-in user.
  - Sockets (`_applyLiveSocketLocationUpdate` and `group-location-update`) enforce `isCommonMember`: an incoming location packet is never added to `radiusUsers` unless the user exists in `onlineGroupMembers`, `allFetchedMembers`, `groupWiseUserData`, or `groupMembersMap`. Users not in any mutual group are ignored.
- **Google Maps Circle Overlay:**
  ```dart
  Circle(
    circleId: CircleId("nearby_radius_circle"),
    center: LatLng(currentLat, currentLng),
    radius: currentRadiusInMeters,
    fillColor: AppColors.primaryColor.withOpacity(0.12),
    strokeColor: AppColors.primaryColor.withOpacity(0.6),
    strokeWidth: 2,
  )
  ```
- **Custom Bitmap Markers:** Renders custom avatar pins with user profile photos, online green status badges, and battery percentage pills.
- **Proximity Clustering & Anti-Jitter Spider Offset (Capped at 4m):**
  - When multiple members occupy the exact same physical coordinates (e.g. User A, B, C within $\le 6$ meters of each other), markers are grouped into a proximity cluster.
  - To prevent overlapping pins while avoiding geographic jumping (which previously jumped to 64 meters with 35m spider radius), markers are given a subtle radial offset capped at **4 meters**.
  - **Distance Display Guarantee:** Distance calculations on cards and marker tooltips (`Geolocator.distanceBetween`) always compute against the user's **real physical coordinates** (`u.latitude, u.longitude`), never against the visual offset coordinates (`markerLat, markerLng`), preventing 3m $\leftrightarrow$ 64m jumping.
  - **Anti-Jitter Socket Guard:** Discards incoming live location packets where `userId == myUserId` across both `_applyLiveSocketLocationUpdate` and `group-location-update` to prevent device self-echo jitter.
  - **Stationary GPS Distance Filter:** `LocationService._listenToLocationUpdates` enforces `distanceFilter: 3.0` meters to eliminate stationary GPS multi-path jitter.
- **Marker Tap & Focus:** Tapping a member card in the bottom horizontal carousel smoothly pans the camera:
  ```dart
  mapController?.animateCamera(
    CameraUpdate.newLatLngZoom(LatLng(member.lat, member.lng), 16.0),
  );
  ```

---

## 2. Group-Wise Live Tracking (`GroupTrackController`)

### 2.1 Room Coordination & Stream Ingestion
Located in `GroupTrackLocationScreen.dart`:
1. On screen initialization, emits `join-group` (`{groupId, userId}`) on the `/location` socket.
2. Initial REST load: Calls `TrackRepo.getUserLocationData(groupId)`. If empty, safely falls back to `GroupRepo.getMemberData(groupId)`.
3. Listens to incoming `send-location` and `group-location-update` events via `TrackLiveLocationSocketService.instance.locationStream`.
4. **Anti-Jitter Guard:** Discards any socket updates where `model.userId == currentUserId` to prevent map jitter and allow smooth local GPS rendering.
5. **Auto-Fit Camera Bounds:** Calculates `LatLngBounds` enclosing all group members and animates the map to fit every member in view.
6. On screen close, emits `leave-group` (`{groupId, userId}`).

---

## 3. Location Sharing & Ghost Mode Synchronization

> **PROTECTED FLOW COMPLIANCE:**  
> The location sharing and ghost mode module is frozen and verified across production devices.

### 3.1 Ghost Mode State Flow
1. User toggles Private Mode in `LiveStatus_controller.dart` or Group Track screen.
2. Dispatches `POST /location-sharing/update` via `TrackRepo.updateLocationSharing(false)`.
3. Local storage updates: `Global.storageServices.set(PrefConst.locationSharing, false)`.
4. `GroupTrackController.syncLocationSharingFromBackend()` verifies consistency.
5. In Ghost Mode:
   - Client ceases emitting GPS coordinates over `/location` socket.
   - Sockets emit `user-left` to active rooms, extinguishing the user's marker from peers' screens.
   - The user retains the ability to see authorized circle members who have location sharing enabled.

---

## 4. Background Geolocation & Foreground Task

1. **Android Foreground Service (`flutter_foreground_task`):**
   - Runs with a persistent notification ("FG Tracker is actively updating your safety location").
   - Maintains continuous location updates when the app is in the background or device is locked.
2. **Adaptive Battery Throttling:**
   - **Stationary (< 3 min motion):** Samples GPS every 60 seconds (distance filter: 50m).
   - **Active Moving:** Samples GPS every 10–15 seconds (distance filter: 10m).
3. **Battery Reporting:** Device battery percentage is read via `battery_plus` and included in every socket emission (`"battery": batteryLevel`).



---

## 5. Recent Code Updates (Tracking Sync, Fallback & Ghost Mode UX)

- **Radius Fallback Guard (`TrackRepo.dart`):** `Urls.userWithinRadiusFallback` is now invoked only when the primary `/users-within-radius` request returns `null` (network/transport failure), not when the primary query succeeds with an empty list.
- **Location Socket Events (`SocketServices.dart`, `TrackLiveLocationSocketService.dart`):**
  - `SocketServices.dart` listens to `group-dashboard-counts`, `user-offline` (triggers `requestGroupCount()`), and both `notification_markers` / `notification-markers`.
  - `LiveLocationSocketModel` parses `locationSharing` from `locationSharing`, `location_sharing`, or `isLocationSharing`.
- **Ghost Mode & Invalid Coordinate Handling (`TrackingController.dart`):**
  - `zoomToMember` checks `locationSharing == false` (and `0` / `'0'`), `null`, or `(0.0, 0.0)` coordinates across `MemberModel`, `LocationData`, and `UsersWithinRadiusData`, showing a top snackbar (`track_memberPausedSharing`) instead of zooming to a fallback center coordinate.

---

## 6. Tracker Share Action (`Tracking_screen.dart`, `TrackLAppBar.dart`, `GroupTrackLocationScreen.dart`, 2026-11-27)

- **Nearby / Live Tracking (`Tracking_screen.dart`):**
  - Added an icon button (`Icons.share_rounded`) matching `_iconButton` in `_buildTopAppBar`.
  - Tapping Share builds a `SharePayloadKind.location` (`ShareLocationData` with current lat/lng, address, and active group info) and opens `Routes.forwardMessageScreen` in share mode (supporting multi-select FG Tracker chats/groups plus an OS Share Sheet button in the AppBar).
- **Group Tracking (`TrackLAppBar.dart`, `GroupTrackLocationScreen.dart`):**
  - Added `Share` item to the `more_vert` popup menu (`onShare`), opening the same Forward Screen flow with current location & group metadata.
