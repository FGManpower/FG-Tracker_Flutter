# Calling Module — Flutter Frontend Architecture & Implementation Guide

**Document Version:** `v1.3.0` · **Last updated:** 2026-11-18 · **Branch:** `46Solution`  
**Target Audience:** Flutter Frontend Developers & Backend Integrators  
**Covers:** 1-on-1 Audio/Video Calls, WebRTC PeerConnection, AWS SFU & Coturn STUN/TURN, Sockets & REST APIs, CallKit, Audio Routing, Proximity Sensor, In-App PIP Overlay, Screen Sharing, Recent Calls Cache & Multi-Delete  
**Status:** In Production / Stable  

---

## 0. AWS Infrastructure & Server Confirmation

### 0.1 AWS Deployment Status (Verified Live)
* **Server Host:** `sfu.fgtracker.fgmanpower.co.in` (Resolves to AWS EC2 Mumbai `ap-south-1` IP `35.154.126.x`).
* **Active Services on AWS:**
  1. **Socket.io Signaling Server:** Node.js application hosting `/callSignaling`, `/screen-share`, `/groupCall`.
  2. **Coturn STUN/TURN Server:** Port `3478` (UDP/TCP) and TLS port `443` for NAT traversal and relayed media fallback.
  3. **LiveKit SFU Gateway:** `wss://sfu.fgtracker.fgmanpower.co.in` for multi-party group calls.
* **Environment Selection (`lib/app/Core/constant/urls.dart`):**
  - Controlled by `ConstRes.isProduction`.
  - Production uses `API_fgtracker_sfu_2026` credentials pointing directly to `sfu.fgtracker.fgmanpower.co.in:3478`.

### 0.2 Understanding Data Processing Latency & Slowness
If video or calling appears sluggish or delayed during testing, the runtime logs reveal the exact technical causes:
1. **Network Bandwidth Estimation (BWE):** Mobile networks/emulators frequently drop into low BWE (e.g. `Current BWE 148000 ~ 190119 bps` ≈ 150-190 kbps). When BWE drops below video bitrate thresholds, Google WebRTC enters `bandwidth limited state` and stops active probing.
2. **Playout Delay Buffering:** When packet jitter occurs on bandwidth-limited connections, the WebRTC receive pipeline automatically adapts receiver playout delays (e.g. `Actual delay value set to 744 ms`), introducing ~0.75s of visible latency to prevent frame stuttering.
3. **High Resolution Target:** Default video stream requests `1280x720 @ 30fps` with `1.8 Mbps` target bitrate, and Screen Sharing requests `2.5 Mbps`. On constrained mobile connections, this forces WebRTC into aggressive downscaling and temporal frame drops.

---

## 1. Architecture & File Registry

| Layer | File Path | Core Responsibility |
|---|---|---|
| **Repositories** | `lib/app/Data/Repositories/call_repo.dart` | Communicates with `/api/history`, `/api/getCallDetail`, `/api/calling-status` |
| **Single Signaling** | `lib/app/Data/Services/Socket/Socket_SignallingService.dart` | Socket.io client for `/callSignaling` namespace |
| **Screen Share Signaling**| `lib/app/modules/mediaStream/Controller/calling_controller.dart` | Direct socket handlers for `/screen-share` namespace |
| **Group Signaling** | `lib/app/Data/Services/Socket/Socket_Group_Calling.dart` | Socket.io client for `/groupCall` namespace |
| **CallKit Service** | `lib/app/Data/Services/IncommingCallKit/callkit_service.dart`<br>`lib/app/Data/Services/IncommingCallKit/call_session.dart` | Integrates iOS CallKit & Android Telecom framework |
| **Audio Routing** | `lib/app/modules/mediaStream/Controller/call_audio_route_controller.dart` | Manages hardware output: Speaker, Earpiece, Bluetooth, Wired Headset |
| **Overlay Service** | `lib/app/modules/mediaStream/Services/in_app_call_overlay_service.dart` | Floating movable PiP bubble across the entire app |
| **1-on-1 Call Controller**| `lib/app/modules/mediaStream/Controller/calling_controller.dart` | WebRTC lifecycle, camera switch, proximity screen lock, timer |
| **Group Call Controller**| `lib/app/modules/mediaStream/Controller/group_calling_controller.dart` | Mesh / SFU peer connections, group video layout |
| **Screens & Views** | `lib/app/modules/call/Views/call_screen.dart`<br>`lib/app/modules/mediaStream/Views/calling_screen.dart`<br>`lib/app/modules/mediaStream/Views/AudioCall_screen.dart` | Visual UI presentation layers |

---

## 2. 1-on-1 Calling: Socket Events & REST APIs

### 2.1 Complete Socket Event Specification (`/callSignaling` & `/screen-share`)

#### Outgoing & Signaling Core
| Event Name | Direction | Payload Schema | Purpose & Flow |
|---|---|---|---|
| `makeCall` | Client ➔ Server | `{ remoteUserId, sdpOffer, is_video, callerId }` | Emitted by caller after creating SDP offer and local description. |
| `newCall` | Server ➔ Client | `{ callId, callerId, callerName, profileImage, is_video, sdpOffer }` | Pushed to receiver socket (or backed by VoIP/FCM push). |
| `CallingStatus` | Bidirectional | `{ callId, remoteUserId, callingStatus }` | Status synchronization: `"Ringing"`, `"Connected"`, `"busy"`. |
| `answerCall` | Client ➔ Server | `{ callId, callerId, sdpAnswer }` | Emitted by receiver after generating SDP answer. |
| `callAnswered` | Server ➔ Client | `{ callId, sdpAnswer }` | Caller receives answer and sets remote description. |
| `IceCandidate` | Bidirectional | `{ remoteUserId, iceCandidate: { id, label, candidate } }` | ICE trickling for NAT candidate exchange. |
| `rejectCall` / `callRejected` | Bidirectional | `{ callId, remoteUserId, reason }` | Call rejected or declined by recipient. |
| `endCall` / `callEnded` | Bidirectional | `{ callId, remoteUserId }` | User hangs up an active or connecting call. |
| `missCall` / `missedCall` | Client ➔ Server | `{ callId, remoteUserId }` | Fired when 45s ringing timeout expires without answer. |

#### Media State & Upgrades
| Event Name | Direction | Payload Schema | Purpose & Flow |
|---|---|---|---|
| `upgradeToVideo` | Client ➔ Server | `{ callId, remoteUserId, callerId, cameraState }` | Notifies remote peer to enable or disable remote camera view. |
| `upgradeToVideoAnswer` | Bidirectional | `{ callId, remoteUserId, accepted }` | Peer accepts or declines video upgrade in audio call. |
| `cameraState` | Server ➔ Client | `{ cameraState: bool, userId }` | Syncs remote peer's camera muted/unmuted state. |

#### 1-on-1 Screen Sharing (`/screen-share` Namespace)
| Event Name | Direction | Payload Schema | Purpose & Flow |
|---|---|---|---|
| `start_screen_share` | Client ➔ Server | `{ callId, targetUserId }` | Initiates secondary WebRTC peer connection for screen capture. |
| `screen_share_offer` | Client ➔ Server | `{ callId, targetUserId, sdpOffer }` | Sends screen stream SDP offer (2.5 Mbps, 15 fps screencast). |
| `screen_share_answer` | Client ➔ Server | `{ callId, targetUserId, sdpAnswer }` | Remote peer answers screen sharing offer. |
| `screen_share_ice` | Bidirectional | `{ callId, targetUserId, candidate }` | ICE candidate exchange for screen sharing stream. |
| `stop_screen_share` | Bidirectional | `{ callId, targetUserId }` | Terminates screen stream and restores standard camera PiP. |

---

### 2.2 REST APIs for 1-on-1 Calling

#### 1. Recent Call History
* **Endpoint:** `GET /api/history`
* **Headers:** `Authorization: Bearer <token>`
* **Query Parameters:** `page=1&limit=20&filter=all|missed|incoming|outgoing`
* **Response:**
  ```json
  {
    "status": true,
    "message": "Call history fetched successfully",
    "data": {
      "today": [{ "id": "call_2", "callType": "private", "type": "video", "direction": "outgoing", "status": "completed", "duration": 120 }],
      "yesterday": [],
      "older": []
    }
  }
  ```

#### 2. Call Session Audit Details
* **Endpoint:** `GET /api/getCallDetail?callId=<callId>`
* **Headers:** `Authorization: Bearer <token>`
* **Response:** Returns caller/receiver profile, call duration, start time, termination reason, and participant records.

#### 3. Update Calling Status
* **Endpoint:** `POST /api/calling-status`
* **Headers:** `Authorization: Bearer <token>`
* **Body:** `{ "callId": 2, "callingStatus": "missed" | "rejected" | "ended", "duration": 45 }`

#### 4. LiveKit SFU Token Generation (Group Calls)
* **Endpoint:** `POST /api/calls/livekit-token`
* **Headers:** `Authorization: Bearer <token>`
* **Body:** `{ "roomName": "call_room_2", "participantName": "Vikas" }`
* **Response:** `{ "status": true, "token": "jwt_livekit_token", "wsUrl": "wss://sfu.fgtracker.fgmanpower.co.in" }`

---

## 3. Hardware Controls & Feature Implementation

### 3.1 Mic On / Off (Mute Toggle)
* **Function:** `CallingController.toggleMic()`
* **Mechanism:**
  ```dart
  isAudioOn = !isAudioOn;
  localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn);
  update();
  ```
* **UI Rebuild:** Bound through `GetBuilder<CallingController>` in `CallingScreen` so the button icon instantly switches between `Icons.mic_rounded` and `Icons.mic_off_rounded`.

### 3.2 Speaker / Earpiece Audio Switching
* **Function:** `CallingController.toggleSpeaker(BuildContext context)`
* **Intelligent Fast Switching:**
  - **Single Tap Toggle:** When no external audio device (Bluetooth headset or wired headphones) is connected, tapping the audio button instantly toggles between **Speaker** (`CallAudioRoute.speaker`) and **Earpiece** (`CallAudioRoute.earpiece`) without opening any modal dialog.
  - **Device Picker Sheet:** If Bluetooth or a wired headset is plugged in, `showAudioRoutePicker(context)` opens the native route picker sheet.
  - **Video Call Parity:** `CallAudioRouteController.availableRoutes` allows `earpiece` in both audio and video calls, enabling private listening during video calls.

### 3.3 Camera Switch (Front / Back)
* **Dual Trigger Architecture:**
  1. **Top Bar Button:** Located on the top right of `CallingScreen._topBar` whenever video is active.
  2. **PiP Badge Button:** Located on the floating camera preview tile.
* **Mechanism:**
  ```dart
  final MediaStreamTrack track = tracks.first;
  await Helper.switchCamera(track);
  isFrontCamera = !isFrontCamera;
  update();
  ```
  Switching `tracks.first` guarantees that secondary screen sharing tracks are not mistakenly flipped.

### 3.4 In-App Floating Overlay (Minimize Call)
* **Service:** `InAppCallOverlayService`
* **Bug Resolved (`No Overlay widget found`):**
  - Previously, `Overlay.of(Get.overlayContext!)` threw when called on an unattached theater context.
  - Resolved using safe navigation key lookup:
    ```dart
    final OverlayState? overlayState = Get.key.currentState?.overlay ??
        (Get.overlayContext != null ? Overlay.maybeOf(Get.overlayContext!) : null);
    ```
  - When minimized, renders a draggable floating bubble showing caller video or avatar, call duration, mute status, and expand/end controls.

---

## 4. Change Log

| Version | Date | Change |
|---|---|---|
| v1.3.0 | 2026-11-18 | Added AWS Server Confirmation (`sfu.fgtracker.fgmanpower.co.in:3478`). Documented all 1-on-1 socket events & REST APIs in full detail. Fixed overlay crash via `Overlay.maybeOf`. Re-enabled direct speaker-to-earpiece toggle. Added top-bar camera switch trigger and wrapped `CallingScreen` in `GetBuilder` for instant reactive UI updates. |
| v1.2.0 | 2026-11-17 | Recent calls cache (guide 07): today's first page shown at once, replaced by the API, retry bar, resume refresh, deletes saved. |
| v1.1.0 | 2026-11-07 | Recent Calls multi-select delete: header 3-dot menu removed; long-press a row to select; optimistic bulk delete. |
| v1.0.0 | — | Initial release of calling architecture. |
