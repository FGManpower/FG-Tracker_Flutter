# FG Tracker — Backend (Node.js / Express / Socket.io) Documentation Index

This directory contains the technical specifications and database schemas for the backend engineering team.

---

## Master Architecture & Integration Guides

- **[International Multi-Currency Payments & Production Setup Guide](../INTERNATIONAL_PAYMENT_SETUP_GUIDE.md)**  
  Comprehensive reference covering multi-currency handling (`INR` / `USD`), zero-rated 0% export GST under LUT RFD-11, E.164 phone formatting, Razorpay PayPal & International Cards integration, and production checklist.

---

## Module Specifications

| Module | Specification File | Version | Core Responsibilities |
|---|---|:---:|---|
| **Master Payment Guide** | [INTERNATIONAL_PAYMENT_SETUP_GUIDE.md](../INTERNATIONAL_PAYMENT_SETUP_GUIDE.md) | `v1.0.0` | Enterprise Cross-Border Gateway Integration, Currency Detection, 0% Export GST under LUT RFD-11, RBI Purpose Codes |
| **01. Chatting** | [01_CHATTING_MODULE_BACKEND.md](./01_CHATTING_MODULE_BACKEND.md) | `v1.0.0` | `/chat` Socket Architecture, Cursor Pagination, Media Uploads, Anti-Self FCM Notifications |
| **02. Calling** | [02_CALLING_MODULE_BACKEND.md](./02_CALLING_MODULE_BACKEND.md) | `v1.0.0` | WebRTC Mesh Signaling (`/callSignaling`, `/groupCall`), CallKit/VoIP FCM Pushes |
| **03. Walkie-Talkie** | [03_WALKIE_TALKIE_MODULE_BACKEND.md](./03_WALKIE_TALKIE_MODULE_BACKEND.md) | `v2.2.0` | PTT Floor Control Arbiter, Multi-Currency Plans (`INR`/`USD`), Export GST LUT, Razorpay HMAC-SHA256 Webhooks |
| **04. Tracking** | [04_TRACKING_MODULE_BACKEND.md](./04_TRACKING_MODULE_BACKEND.md) | `v1.0.0` | `/location` Socket, Radar Radius Clustering, Geolocation Ingestion, Ghost Mode Privacy Sync |
| **05. Common Module** | [05_COMMON_MODULE_BACKEND.md](./05_COMMON_MODULE_BACKEND.md) | `v2.0.0` | `/initialize` Bootstrap, Session Invalidation, Phone OTP Login & International OTP Charges Gateway (v2 Engine) |

