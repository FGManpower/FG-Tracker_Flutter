# FG Tracker — Complete Application Documentation

This directory contains the organized, module-wise documentation of the entire FG Tracker application, separated cleanly into **Backend** and **Frontend** specifications.

---

## Directory Structure

```
docs/
├── backend/                  # Complete specifications for the Backend Team
│   ├── 01_CHATTING_MODULE_BACKEND.md
│   ├── 02_CALLING_MODULE_BACKEND.md
│   ├── 03_WALKIE_TALKIE_MODULE_BACKEND.md
│   ├── 04_TRACKING_MODULE_BACKEND.md
│   └── 05_COMMON_MODULE_BACKEND.md
│
└── frontend/                 # Complete implementation guides for the Flutter Team
    ├── 01_CHATTING_MODULE_FRONTEND.md
    ├── 02_CALLING_MODULE_FRONTEND.md
    ├── 03_WALKIE_TALKIE_MODULE_FRONTEND.md
    ├── 04_TRACKING_MODULE_FRONTEND.md
    └── 05_COMMON_MODULE_FRONTEND.md
```

---

## Module Overview & Quick Links

| Module | Backend Specification | Frontend Guide | Core Capabilities |
|---|---|---|---|
| **1. Chatting** | [01_CHATTING_MODULE_BACKEND.md](./backend/01_CHATTING_MODULE_BACKEND.md) | [01_CHATTING_MODULE_FRONTEND.md](./frontend/01_CHATTING_MODULE_FRONTEND.md) | 1-on-1 & Group Chat, `/chat` Sockets, Cursor Pagination, Anti-Self FCM Notifications, Active Chat Suppression, Polls, Voice Notes, Multi-File Media (up to 20 files). |
| **2. Calling** | [02_CALLING_MODULE_BACKEND.md](./backend/02_CALLING_MODULE_BACKEND.md) | [02_CALLING_MODULE_FRONTEND.md](./frontend/02_CALLING_MODULE_FRONTEND.md) | 1-on-1 & Group Audio/Video Calls, WebRTC Signaling (`/callSignaling`, `/groupCall`), CallKit/VoIP FCM Pushes, Screen Sharing, Floating PIP Bubble, Call History & History Details Screen (`contact_profile_screen.dart`), Audio Routing & Proximity Lock. |
| **3. Walkie-Talkie** | [03_WALKIE_TALKIE_MODULE_BACKEND.md](./backend/03_WALKIE_TALKIE_MODULE_BACKEND.md) | [03_WALKIE_TALKIE_MODULE_FRONTEND.md](./frontend/03_WALKIE_TALKIE_MODULE_FRONTEND.md) | Push-to-Talk (PTT) over `/groupWalkie`, Channel Management, Active Notification Group toggle, Group Info sheet with member notification bell sync, Razorpay Plans & Seat Distribution, International Payments & PayPal (backend currency on every payment screen, E.164 customer prefill, release test checklist). |
| **4. Tracking** | [04_TRACKING_MODULE_BACKEND.md](./backend/04_TRACKING_MODULE_BACKEND.md) | [04_TRACKING_MODULE_FRONTEND.md](./frontend/04_TRACKING_MODULE_FRONTEND.md) | Live Tracking by Nearby Radius (500m to 50km radar), Group-Wise Tracking, `/location` Sockets, Google Maps with custom avatar pins, Ghost Mode Privacy Sync (`/location-sharing/update`), Battery Percentage Monitoring, Background Geolocation Task. |
| **5. Common Module**| [05_COMMON_MODULE_BACKEND.md](./backend/05_COMMON_MODULE_BACKEND.md) | [05_COMMON_MODULE_FRONTEND.md](./frontend/05_COMMON_MODULE_FRONTEND.md) | App Cold Start & Bootstrap (`main.dart`), Permission Gate Framework, Home Dashboard Sockets (`/dashboard`), WhatsApp-Style Stories/Status (`/status`), 3-Tier Force Logout Engine, 90-Day JWT Token Lifecycle, Local Storage (`PrefConst`), Global Audio Priority, Phone OTP Login & International OTP Charge (Razorpay, PayPal). |

