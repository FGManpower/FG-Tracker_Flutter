# FG Tracker — Frontend (Flutter) Documentation Index

This directory contains the implementation guides and architecture specifications for the Flutter mobile engineering team.

---

## Master Architecture & Integration Guides

- **[International Multi-Currency Payments & Production Setup Guide](../INTERNATIONAL_PAYMENT_SETUP_GUIDE.md)**  
  Comprehensive reference covering multi-currency handling (`INR` / `USD`), zero-rated 0% export GST under LUT RFD-11, E.164 phone formatting, Razorpay PayPal & International Cards integration, and production checklist.

---

## Module Specifications

| Module | Specification File | Version | Core Responsibilities |
|---|---|:---:|---|
| **Master Payment Guide** | [INTERNATIONAL_PAYMENT_SETUP_GUIDE.md](../INTERNATIONAL_PAYMENT_SETUP_GUIDE.md) | `v1.0.0` | Enterprise Cross-Border Gateway Integration, Currency Formatting, Razorpay Options, Production Checklist |
| **01. Chatting** | [01_CHATTING_MODULE_FRONTEND.md](./01_CHATTING_MODULE_FRONTEND.md) | `v1.2.0` | 1-on-1 & Group Chat, `/chat` Sockets, Cursor Pagination, Media Sharing, Polls, Voice Notes |
| **02. Calling** | [02_CALLING_MODULE_FRONTEND.md](./02_CALLING_MODULE_FRONTEND.md) | `v1.1.0` | WebRTC Audio/Video Calls, Screen Sharing, Floating PIP Bubble, CallKit / Call History |
| **03. Walkie-Talkie** | [03_WALKIE_TALKIE_MODULE_FRONTEND.md](./03_WALKIE_TALKIE_MODULE_FRONTEND.md) | `v1.6.0` | PTT over `/groupWalkie`, Audio Floor Control, Razorpay Plan Purchase & Multi-Currency Checkout |
| **04. Tracking** | [04_TRACKING_MODULE_FRONTEND.md](./04_TRACKING_MODULE_FRONTEND.md) | `v1.0.0` | Live Tracking by Radius, `/location` Sockets, Custom Google Maps Pins, Ghost Mode Privacy Sync |
| **05. Common Module** | [05_COMMON_MODULE_FRONTEND.md](./05_COMMON_MODULE_FRONTEND.md) | `v2.1.0` | Bootstrap Sequence, Home Socket (`/location`), Red Dot Badges, Phone OTP Login & International OTP Charges |

