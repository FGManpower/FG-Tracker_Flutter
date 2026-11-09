# FG Tracker — Complete Application Documentation

This directory contains the organized, module-wise documentation of the entire FG Tracker application, separated cleanly into **Backend** and **Frontend** specifications, alongside master cross-cutting guides.

---

## Directory Structure

```
docs/
├── INTERNATIONAL_PAYMENT_SETUP_GUIDE.md # Master Enterprise Guide: International Payments & Production Setup
│
├── backend/                             # Complete specifications for the Backend Team
│   ├── README.md                        # Backend Documentation Index
│   ├── 01_CHATTING_MODULE_BACKEND.md
│   ├── 02_CALLING_MODULE_BACKEND.md
│   ├── 03_WALKIE_TALKIE_MODULE_BACKEND.md (v2.2.0)
│   ├── 04_TRACKING_MODULE_BACKEND.md
│   └── 05_COMMON_MODULE_BACKEND.md (v2.0.0)
│
└── frontend/                            # Complete implementation guides for the Flutter Team
    ├── README.md                        # Frontend Documentation Index
    ├── 01_CHATTING_MODULE_FRONTEND.md
    ├── 02_CALLING_MODULE_FRONTEND.md
    ├── 03_WALKIE_TALKIE_MODULE_FRONTEND.md (v1.6.0)
    ├── 04_TRACKING_MODULE_FRONTEND.md
    └── 05_COMMON_MODULE_FRONTEND.md (v2.1.0)
```

---

## Master Architecture & Setup Guides

- **[International Multi-Currency Payments & Production Setup Guide](./INTERNATIONAL_PAYMENT_SETUP_GUIDE.md)**: Enterprise master reference covering multi-currency handling (`INR` / `USD`), zero-rated 0% export GST under LUT RFD-11, E.164 phone formatting, Razorpay PayPal & International Cards integration, and production checklist.

---

## Module Overview & Quick Links

| Module | Backend Specification | Frontend Guide | Core Capabilities |
|---|---|---|---|
| **Master Payment Guide** | [INTERNATIONAL_PAYMENT_SETUP_GUIDE.md](./INTERNATIONAL_PAYMENT_SETUP_GUIDE.md) | [INTERNATIONAL_PAYMENT_SETUP_GUIDE.md](./INTERNATIONAL_PAYMENT_SETUP_GUIDE.md) | Enterprise International Multi-Currency & Production Setup (Walkie-Talkie & Login OTP Charges, PayPal, 0% Export GST under LUT RFD-11). |
| **1. Chatting** | [01_CHATTING_MODULE_BACKEND.md](./backend/01_CHATTING_MODULE_BACKEND.md) | [01_CHATTING_MODULE_FRONTEND.md](./frontend/01_CHATTING_MODULE_FRONTEND.md) | 1-on-1 & Group Chat, `/chat` Sockets, Cursor Pagination, Anti-Self FCM Notifications, Active Chat Suppression, Polls, Voice Notes, Multi-File Media (up to 20 files). |
| **2. Calling** | [02_CALLING_MODULE_BACKEND.md](./backend/02_CALLING_MODULE_BACKEND.md) | [02_CALLING_MODULE_FRONTEND.md](./frontend/02_CALLING_MODULE_FRONTEND.md) | 1-on-1 & Group Audio/Video Calls, WebRTC Signaling (`/callSignaling`, `/groupCall`), CallKit/VoIP FCM Pushes, Screen Sharing, Floating PIP Bubble, Call History & History Details Screen (`contact_profile_screen.dart`), Audio Routing & Proximity Lock. |
| **3. Walkie-Talkie** | [03_WALKIE_TALKIE_MODULE_BACKEND.md](./backend/03_WALKIE_TALKIE_MODULE_BACKEND.md) | [03_WALKIE_TALKIE_MODULE_FRONTEND.md](./frontend/03_WALKIE_TALKIE_MODULE_FRONTEND.md) | Push-to-Talk (PTT) over `/groupWalkie`, Channel Management, Active Notification Group toggle, Group Info sheet with member notification bell sync, Razorpay Plans & Seat Distribution, International Payments & PayPal (backend currency on every payment screen, E.164 customer prefill, release test checklist). |
| **4. Tracking** | [04_TRACKING_MODULE_BACKEND.md](./backend/04_TRACKING_MODULE_BACKEND.md) | [04_TRACKING_MODULE_FRONTEND.md](./frontend/04_TRACKING_MODULE_FRONTEND.md) | Live Tracking by Nearby Radius (500m to 50km radar), Group-Wise Tracking, `/location` Sockets, Google Maps with custom avatar pins, Ghost Mode Privacy Sync (`/location-sharing/update`), Battery Percentage Monitoring, Background Geolocation Task. |
| **5. Common Module**| [05_COMMON_MODULE_BACKEND.md](./backend/05_COMMON_MODULE_BACKEND.md) | [05_COMMON_MODULE_FRONTEND.md](./frontend/05_COMMON_MODULE_FRONTEND.md) | App Cold Start & Bootstrap (`main.dart`), Permission Gate Framework, Home Dashboard Sockets (`/dashboard`), WhatsApp-Style Stories/Status (`/status`), 3-Tier Force Logout Engine, 90-Day JWT Token Lifecycle, Local Storage (`PrefConst`), Global Audio Priority, Phone OTP Login & International OTP Charge (Razorpay, PayPal). |
