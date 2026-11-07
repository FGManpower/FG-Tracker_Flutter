# Common Application Architecture — Flutter Frontend Guide

**Document Version:** `v1.0.0`  
**Target Audience:** Flutter Frontend Developers  
**Covers:** App Cold Start in `main.dart`, Initial Route Resolution, Permission Gate System, Home Dashboard Sockets, WhatsApp-Style Stories UI, SharedPreferences Storage, HttpUtil, Global Audio Priority  
**Status:** In Production / Stable  

---

## 0. Architecture & File Registry

| Layer | File Path | Core Responsibility |
|---|---|---|
| **Entry Point** | `lib/main.dart` | OS bootstrap, Firebase init, background FCM handler, route determination |
| **Dashboard Socket** | `lib/app/Data/Services/Socket/Socket_Dashboard_Service.dart` | `/dashboard` socket: live group counts, live member location queries |
| **Status Socket** | `lib/app/Data/Services/Socket/status_socket_service.dart` | `/status` socket: 24-hr status stories (`status:new`, `status:viewed`, `status:deleted`) |
| **Permission Gate** | `lib/app/Data/Services/PermissionGate/permission_gate_service.dart`<br>`lib/app/Data/Services/PermissionGate/permission_gate_middleware.dart` | Enforces permissions (Location Always, Camera, Mic, Battery, Overlay) |
| **Notification Engine** | `lib/app/Data/Services/NotificationServices.dart`<br>`lib/app/Data/Services/notification_marker_service.dart`<br>`lib/app/Data/Services/active_chat_tracker.dart` | FCM push handling, notification badges, active screen suppression |
| **Security & Session** | `lib/app/Core/values/logoutuser.dart`<br>`lib/app/Core/values/storage_services.dart` | Token clearance, socket teardown, multi-channel force logout handler |
| **HTTP Networking** | `lib/app/Core/util/http/http_util.dart`<br>`lib/app/Core/util/http/ApiErrorHandler.dart` | Centralized REST client, Bearer JWT header injection, multipart file upload engine |
| **Audio Arbiter** | `lib/app/Core/util/global_audio_manager.dart`<br>`lib/app/Core/util/configureAudioSession.dart` | Global audio session arbiter (Call vs. Walkie vs. Voice Notes) |
| **Deep Linking** | `lib/app/Core/deep_Link/uniservices.dart`<br>`lib/app/Core/deep_Link/Context_Utility.dart` | Universal Links & invite routing (`https://fgtracker.com/invite/...`) |

---

## 1. App Startup & Cold Bootstrap Pipeline (`main.dart`)

### 1.1 Startup Sequence
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Firebase.initializeApp()`
3. `@pragma('vm:entry-point') firebaseMessagingBackgroundHandler`: Listens for background pushes including `FORCE_LOGOUT`.
4. `Global.init()`: Initializes `StorageServices` wrapping `SharedPreferences`.
5. `AwesomeNotifications().initialize()`: Configures local notification channels.
6. `ScreenUtilInit(designSize: Size(375, 812))`: Adaptive UI scaling across device form factors.

### 1.2 Route Resolution Tree
```
Check CallKit Launch Intent? ────────► Routes.callScreen
              │ (No)
Check Intro Screen Status?  ─────────► Routes.introScreen (if false)
              │ (Done)
Check User JWT Token?       ─────────► Routes.loginScreen (if missing)
              │ (Exists)
Check Mandatory Permissions? ────────► Routes.permissionSetupScreen (if missing)
              │ (Granted)
        Routes.homeScreen
```

---

## 2. Permission Gate Architecture

Managed by `PermissionGateService` and `PermissionGateMiddleware`:
- Pre-flight verification blocks access to protected screens if required permissions are revoked.
- **Mandatory Permissions:**
  1. `Location (Foreground & Always)`: Needed for live tracking and geofence alerts.
  2. `Camera & Microphone`: Needed for WebRTC Calling and Walkie-Talkie PTT.
  3. `Notification`: Needed for incoming call alerts and chat push notifications.
  4. `Ignore Battery Optimization`: Prevents Android OEMs from killing background GPS tasks.
  5. `System Alert Window (Overlay)`: Enables floating Picture-in-Picture (PIP) bubble.

---

## 3. Session Security & Force Logout Engine

Managed by `LogoutUser().handleForceLogout()`:
- Triggered by 3 channels:
  1. FCM Push: `type == "FORCE_LOGOUT"` received in background handler.
  2. Sockets: `force_logout` event received on any active namespace.
  3. HTTP: 401 response returned from `HttpUtil`.
- **Cleanup Actions:**
  - Closes all WebSocket connections (`/dashboard`, `/location`, `/callSignaling`, `/groupCall`, `/chat`).
  - Dismisses any active CallKit sessions (`CallKitService.endAllCalls()`).
  - Clears `SharedPreferences` tokens while preserving onboarding status (`PrefConst.introStatus`).
  - Navigates to `Routes.loginScreen` and displays an explanation toast.

---

## 4. Local Storage & Cache Registry (`PrefConst`)

Access via `Global.storageServices`:
- `STORAGE_USER_TOKEN_KEY`: 90-day Bearer JWT token.
- `userId`: Current logged-in user identifier.
- `userRole`: User privilege role (`admin`, `member`, `owner`).
- `locationSharing`: Ghost mode preference boolean.
- `introStatus`: Onboarding completion boolean.
- `activeChannelId`: Last selected Walkie-Talkie group ID.

---

## 5. Global Audio Arbiter (`GlobalAudioManager`)

Enforces strict hardware audio priority across competing media:
1. **Priority 1 (Highest): Incoming & Active Phone/Video Calls** — Automatically pauses chat voice note playback and stops PTT audio.
2. **Priority 2: Walkie-Talkie PTT Audio** — Ducks/pauses chat voice note audio.
3. **Priority 3 (Lowest): In-Chat Voice Note Playback** — Yields immediately if a call or PTT talk arrives.

