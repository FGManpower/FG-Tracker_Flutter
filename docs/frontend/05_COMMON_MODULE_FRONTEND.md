# Common Application Architecture — Flutter Frontend Guide

**Document Version:** `v1.10.0` · **Last updated:** 2026-11-07 · **Branch:** `46Solution`  
**Target Audience:** Flutter Frontend Developers  
**Covers:** App Cold Start in `main.dart`, Initial Route Resolution, Permission Gate System, Home Dashboard Sockets, WhatsApp-Style Stories UI, SharedPreferences Storage, HttpUtil, Global Audio Priority, Phone OTP Login & International OTP Charge  
**Status:** In Production / Stable  

---

## 0. Architecture & File Registry

| Layer | File Path | Core Responsibility |
|---|---|---|
| **Entry Point** | `lib/main.dart` | OS bootstrap, Firebase init, background FCM handler, route determination |
| **Dashboard Socket** | `lib/app/Data/Services/Socket/Socket_Dashboard_Service.dart` | `/dashboard` socket: live group counts, live member location queries |
| **Home Socket** | `lib/app/modules/Track/Controller/SocketServices.dart` | `/location` socket: `notification_markers` (bottom-nav red dots via `NotificationMarkerService`), `group_dashboard_counts`; emits `call_history_viewed` / `chat_list_viewed` |
| **Status Socket** | `lib/app/Data/Services/Socket/status_socket_service.dart` | `/status` socket: 24-hr status stories (`status:new`, `status:viewed`, `status:deleted`) |
| **Permission Gate** | `lib/app/Data/Services/PermissionGate/permission_gate_service.dart`<br>`lib/app/Data/Services/PermissionGate/permission_gate_middleware.dart` | Enforces permissions (Location Always, Camera, Mic, Battery, Overlay) |
| **Notification Engine** | `lib/app/Data/Services/NotificationServices.dart`<br>`lib/app/Data/Services/notification_marker_service.dart`<br>`lib/app/Data/Services/active_chat_tracker.dart` | FCM push handling, notification badges, active screen suppression |
| **Security & Session** | `lib/app/Core/values/logoutuser.dart`<br>`lib/app/Core/values/storage_services.dart` | Token clearance, socket teardown, multi-channel force logout handler |
| **HTTP Networking** | `lib/app/Core/util/http/http_util.dart`<br>`lib/app/Core/util/http/ApiErrorHandler.dart` | Centralized REST client, Bearer JWT header injection, multipart file upload engine |
| **Audio Arbiter** | `lib/app/Core/util/global_audio_manager.dart`<br>`lib/app/Core/util/configureAudioSession.dart` | Global audio session arbiter (Call vs. Walkie vs. Voice Notes) |
| **Currency Format** | `lib/app/Core/util/currency_format.dart` (`CurrencyFormat`) | Symbol, grouping (lakh for INR) and screen-reader text for any backend currency; used by OTP charges and Walkie payments |
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

---

## 6. Phone OTP Login & International OTP Charge

> 🔒 `OtpController.dart` is part of the frozen Login flow (see `AGENTS.md`). This section documents it; any code change there needs the user's confirmation first.

### 6.1 Flow
```
Login Screen ──► POST v2/send-otp { MobileNo, countryCode, Platform }
                        │
        ┌───────────────┴──────────────────────┐
nextStep == VERIFY_OTP                 nextStep == SHOW_OTP_CHARGE_SCREEN
(India / free: SMS already sent)       (non-India, 2nd login onwards: no SMS yet)
        │                                      │
        │                              OTP Charges Screen
        │                              ├─ GET  v2/otp-charge/config   (own test/live key, enabled flag)
        │                              ├─ POST v2/otp-charge/create-order { otpChargeToken }
        │                              ├─ Razorpay checkout
        │                              ├─ success → POST v2/otp-charge/payment-success (backend sends the SMS)
        │                              └─ error   → POST v2/otp-charge/payment-failed
        ▼                                      ▼
                 OTP Screen ──► POST v2/verify-otp ──► token in data.token

Side menu (logged in) ──► OTP Charges Screen (info only)
                          └─ GET v2/otp-charge/my-rate (Bearer JWT) → price / free / unknown
```
All paths are relative to `ConstRes.aBaseUrl` (`.../api/`). The login calls happen before login, so they carry no auth header. `my-rate` is the only one that needs the JWT.

### 6.2 File registry

| Layer | File Path | Core Responsibility |
|---|---|---|
| **Repo** | `lib/app/Data/Repositories/otp_charge_repo.dart` | `v2/send-otp`, `v2/resend-otp`, `v2/verify-otp`, `v2/otp-charge/*`, `getMyRate()` |
| **Models** | `lib/app/Model/otp_charge_model.dart` | `SendOtpResponse`, `OtpChargeInfo`, `OtpChargeConfig`, `OtpChargeOrderResponse`, `OtpMyRateResponse`, `OtpNextStep` |
| **Login** | `lib/app/modules/auth/Controller/login_controller.dart` | Calls send-otp and routes on `nextStep` |
| **OTP Charges** | `lib/app/modules/OtpCharges/Controller/otp_charges_controller.dart`<br>`lib/app/modules/OtpCharges/Views/otp_charges_view.dart` | Fee breakup in the charge currency, Razorpay, payment-success / payment-failed |
| **OTP verify** 🔒 | `lib/app/modules/auth/Controller/OtpController.dart` | Resend and verify, saves the token |

### 6.3 send-otp response (charge case), as parsed by the app
Backend revision 5 example: international charges come in `USD` with 0% GST (export of services).
```json
{
  "status": true,
  "nextStep": "SHOW_OTP_CHARGE_SCREEN",
  "otpCharge": {
    "required": true, "amount": 0.50, "amountMinor": 50, "currency": "USD",
    "country": "United States", "prefix": "1",
    "otpChargeToken": "eyJ...", "requestId": "...",
    "baseAmount": 0.50, "gstPercent": 0, "gstAmount": 0.00
  },
  "otpResend": { "attemptsRemaining": 3, "maxAttempts": 3 },
  "loginInfo": { "isExistingUser": true, "maskedEmail": "a***@x.com" }
}
```
How the app reads it (`OtpChargesController._loadFromLogin`):
- **Total** = `amountMinor / 100` (falls back to `amount`) → `$0.50`.
- **Currency** = `otpCharge.currency` → symbol `$`.
- **GST** = `gstPercent` when sent (here `0`, so the GST row is hidden). If it is missing: 0 for non-INR, 18% for INR.
- **Base** = `baseAmount` when sent, else worked out from the total and GST.

The free / domestic case returns `nextStep: "VERIFY_OTP"` with `otpCharge.required: false` and no token; the login screen goes straight to the OTP screen.

### 6.4 OTP Charges controller rules
- **Token lifetime:** the backend `otpChargeToken` lives **30 min** (confirmed, backend spec §8.1). The client expires it after **25 min** and sends the user back to login for a fresh send-otp. The 5-min margin leaves room to finish checkout.
  - **Grace window:** `payment-success` accepts the token for 10 more minutes (slow 3DS2 / PayPal).
  - **Webhook:** `payment.captured` / `order.paid` match the order by `razorpayOrderId` and send the OTP even if the app never calls `payment-success`. A paid user always gets the OTP.
  - **create-order** checks the same 30 min. **OTPs are always 4 digits**, domestic and international.
- **Gateway key:** create-order `keyId` first, then `v2/otp-charge/config` `keyId`. Never the Walkie key.
- **Checkout options:** `amount` (minor units) and `currency` from create-order, `notes.purpose = 'otp_charge'`, prefill `contact = dialCode + number` (E.164), and `email` only when it is not masked.
- **payment-success** is retried up to 3 times. If it never gets through, the Razorpay webhook still sends the OTP, so the app moves on to the OTP screen.
- **payment-failed** is sent with the **saved order id**. The user stays on the screen; tapping Pay creates a new order.
- Razorpay error codes map to plain messages (cancelled, network, update the app, generic refund note).

### 6.5 International cards & PayPal
- When create-order returns `currency: "USD"`, Razorpay Checkout shows PayPal. No PayPal SDK is needed. The app passes the order currency through and sends no `method` prefill or custom blocks, so PayPal is not hidden.
- **Which OTP charges are USD:** the backend looks up the `otp_charges` table by country prefix. Foreign destinations stored with `currency: "USD"` (or the international default) return `USD`, so PayPal appears. Backend confirmed PayPal is supported on the live account.
- **Currency on screen (fixed v1.4.0):** `OtpChargesController.money()` uses `otpCharge.currency` (`₹`, `$`, `€`, `£`, else the code). For a non-INR charge with no `gstPercent`, GST is 0 and the GST row and "Including GST" line are hidden. Screen-reader text reads the right currency ("10.50 US dollars").
- 3D Secure 2.0 needs `name`, `email` and `contact` (E.164) prefilled. Before login the app only has the phone number (and sometimes an unmasked email), so `name` cannot be prefilled here; Razorpay asks for it in checkout.

#### Side-menu info mode: `GET v2/otp-charge/my-rate` (v1.8.0)
Opened from the side menu (no charge token), the screen is info-only. It no longer shows fixed `₹2.36` defaults. It calls `my-rate` (Bearer JWT, no body), which the backend works out from `users.countryCode` exactly like send-otp.

| `data.required` | Screen (`OtpRateState`) | Shown |
|---|---|---|
| `true` + amount | `charged` | Price in `data.currency` (e.g. `$0.50`), GST row only if `gstPercent > 0`, same rules as §6.3 |
| `false` | `free` | "OTP is free for your number" |
| `null`, `status: false`, or network error | `unknown` | "OTP charges depend on your country" + general note |
| (while loading) | `loading` | Spinner |

- The number card uses `data.prefix` for the dial code and badge (e.g. `+1`) and `data.country` for the country line. Before the reply it shows a phone icon, not the old `IN` / `+91` defaults.
- There is no Pay button in this mode (it needs a charge token from login).
- Example (US user): `{ "status": true, "data": { "required": true, "country": "United States", "prefix": "1", "currency": "USD", "amount": 0.50, "amountMinor": 50, "baseAmount": 0.50, "gstPercent": 0, "gstAmount": 0.00 } }`.

#### Release test checklist (OTP charge)

| # | Scenario | Expected |
|---|---|---|
| 1 | Indian number | `nextStep: VERIFY_OTP`; OTP screen directly, no charge screen |
| 2 | Foreign number, INR charge with GST split | Charge screen in `₹` with the GST row; Pay → Razorpay → OTP SMS arrives |
| 3 | Foreign number (e.g. `+1`), USD charge, `gstPercent: 0` | Charge screen shows `$0.50`, no GST row or "Including GST" line; create-order succeeds for the small amount; PayPal visible in checkout; Pay → OTP SMS arrives |
| 4 | Cancel checkout | `payment-failed` sent with the saved order id; stays on the screen; Pay again creates a new order |
| 5 | Wait 25+ minutes on the charge screen | "Session expired" dialog → back to login |
| 6 | Screen reader on the charge screen | Reads the amount in the charge currency ("0.50 US dollars") |
| 7 | Side menu → OTP Charges, US user | `$0.50`, no GST row, `+1` badge, "United States (+1)", no Pay button |
| 8 | Side menu → OTP Charges, Indian user | "OTP is free for your number", `+91` badge |
| 9 | Side menu → OTP Charges, older user with no stored country code, or offline | "OTP charges depend on your country" |

### 6.6 Review of the backend guide
Source: the backend team's `05_COMMON_MODULE_FRONTEND.md`. **Revision 2 (07 Nov 2026)** matches the app's OTP contract. **Revision 3** confirms `Voip_Device` and USD OTP charges. **Revision 5** adds a USD / 0% GST charge example and the currency-display rule.

**Revision 6 (frontend guide v2.1.0) + backend spec `05_COMMON_MODULE_BACKEND.md` v2.0.0**

| Item | Status |
|---|---|
| §3.5 `GET v2/otp-charge/my-rate` (three response cases) | ✅ Shipped by the backend; the app uses it (§6.5) |
| §1 launch sequence: `StorageServices`, no `/api/version`, no `update-device-token`, FCM token as `Device_Id` | ✅ Fixed, matches the app |
| §5.2 screen share over the call socket (`start_screen_share`, `screen_share_offer` / `_answer` / `_ice`, `stop_screen_share`, `screen_share_started` / `_stopped`) | ✅ Fixed, matches `calling_controller.dart` |
| **`otpChargeToken` lifetime** | ✅ Revision 7: **30 min**, plus a 10-min grace on `payment-success` and a token-independent webhook. App keeps its 25-min timer (§6.4). |
| Backend spec §4 / §8.1: old send-otp reply and legacy endpoints | ✅ Revision 7: now `v2/send-otp`, `v2/verify-otp`, `v2/resend-otp` and the `otpCharge` / `SHOW_OTP_CHARGE_SCREEN` reply |
| Backend spec §8.2 create-order expiry | ✅ Revision 8: **30 min** (1800 s), same as send-otp. The app's 25-min timer leaves a 5-min buffer. |
| Backend spec §8.2 OTP length | ✅ Revision 8: **all OTPs are 4 digits** (domestic and international, sent via MSG91; validator `/^[0-9]{4}$/`), matching the app's OTP screen (`Otp_Screen.dart`, `OtpController`). |

Nothing is open on the OTP / OTP-charge contract after revision 8.

**Revision 5: §3.2 and §3.3 checked against the app**

| Their section | App | Status |
|---|---|---|
| §3.2 Flow A (`VERIFY_OTP`, `required: false`) | Login routes on `nextStep` only | ✅ Matches |
| §3.2 Flow B: `USD`, `amount: 0.50`, `amountMinor: 50`, `gstPercent: 0` | Shows `$0.50`, GST row hidden (§6.3) | ✅ Matches |
| §3.2 note: show the symbol from `otpCharge.currency` | Done in v1.4.0 (`OtpChargesController.money()`) | ✅ Matches |
| §3.3 create-order → Razorpay (`amount` minor units, order `currency`, `contact = dialCode + number`, unmasked email) | Same (§6.4) | ✅ Matches |
| §3.3 payment-success / payment-failed / verify-otp (`Voip_Device`, `data.token`) | Same | ✅ Matches |
| §3.3 `notes.requestId` | App sends only `notes.purpose` | Optional; not needed by the flow |
| §3.3 `'name': 'FG-Tracker Login'` | App: `'FG MANPOWER LLP'` (the merchant's legal name, as for Walkie) | Keep the app's version |

**Revision 5: other sections checked against the app**

| Their section | App | Status |
|---|---|---|
| §1 step 1: JWT in `flutter_secure_storage` | `StorageServices` (`SharedPreferences`) | Doc fix on their side |
| §1 step 2: `GET /api/version` update check | Not called anywhere in the app | Doc fix (or a new feature) |
| §1 step 5: `POST /api/update-device-token` | Not called; the FCM token goes as `Device_Id` on `v2/verify-otp` | Doc fix on their side |
| §2 home socket `/location`: `notification_markers`, `group_dashboard_counts`, emits `call_history_viewed` / `chat_list_viewed` | ✅ `Track/Controller/SocketServices.dart` (`/location`). Chat list also calls REST `POST /mark-viewed`. | ✅ Matches |
| §3.4 force logout | `LogoutUser().handleForceLogout()` (§3) | ✅ Matches |
| §4 Notification Center (`getNotifications`, `getUnreadCount`, `markAsRead/:id`, `markAllAsRead`, `clear-all-notifications`) | `Notification_Repo.dart` | ✅ Matches (app does not send `page` / `limit`) |
| §5.1 `GET /api/banners` | `Urls.banner` | ✅ Matches |
| §5.2 1:1 screen share via REST `POST /api/screen-share/start` / `stop` | Socket events on the call socket: `screen_share_started`, `screen_share_stopped`, `screen_share_offer` / `_answer` / `_ice` (`calling_controller.dart`); group calls emit `start_group_screen_share` | Doc fix on their side: no REST calls in the app |

**Resolved in revision 3**

| Item | Outcome |
|---|---|
| `Voip_Device` on verify-otp | ✅ Saved to `users.Voip_Device` (also accepts `voip_device` / `voip_token`); used for iOS CallKit VoIP pushes |
| Which OTP charges are USD | ✅ Per country prefix in `otp_charges` (see §6.5) |

**Resolved in revision 2**

| Item | Outcome |
|---|---|
| Endpoints | ✅ `v2/send-otp`, `v2/resend-otp`, `v2/verify-otp`, `v2/otp-charge/*` |
| `nextStep` value | ✅ `SHOW_OTP_CHARGE_SCREEN` (was `PAY_CHARGE`) |
| Charge info shape | ✅ `otpCharge` with `required`, `country`, numeric `amount`, `amountMinor`, GST split |
| verify-otp | ✅ `{ countryCode, MobileNo, otp, Device_Id, Platform }`, token at `data.token` |
| payment-failed | ✅ Sends the saved order id |
| 401 / force logout | ✅ `LogoutUser().handleForceLogout()` + `StorageServices` |

**Still open / sample-only differences**

| Backend guide (rev 3) | App | Status |
|---|---|---|
| §3.3 `verifyOtp` sample had duplicated lines | — | ✅ Fixed in revision 4 (now also sends `Voip_Device`) |
| PayPal on the live Razorpay account | — | ✅ Confirmed supported (USD) |
| Sample `currency` fallback `'USD'` | Fallback `INR` | Keep the app's version; do not guess a currency |
| Sample navigates only when payment-success returns `nextStep: VERIFY_OTP`; no token-expiry timer, no retry | App navigates on `status: true`, retries 3×, expires the token at 25 min (§6.4) | Keep the app's version |
| §1 / §2 (outside OTP) | — | Superseded by the revision 5 table above. Correction: the `/location` home socket in their §2 **is** correct; an earlier version of this row wrongly said `/dashboard` only. |

---

## 7. Change log
| Version | Date | Change |
|---|---|---|
| v1.10.0 | 2026-11-07 | Backend revision 8: create-order expiry is 30 min and all OTPs are 4 digits; both backend spec §8.2 lines fixed. Nothing open on the OTP / OTP-charge contract. |
| v1.9.0 | 2026-11-07 | Backend revision 7: token lifetime confirmed 30 min (+10-min grace, webhook sends the OTP regardless); backend spec §4 / §8.1 now v2. App timer stays 25 min. New open items in backend spec §8.2: create-order "15-minute expiry" and "6-digit OTP" (app uses 4). |
| v1.8.0 | 2026-11-07 | Side-menu OTP Charges screen uses the new `GET v2/otp-charge/my-rate`: price in the user's currency, "free" for Indian numbers, general note when unknown; number card no longer assumes India / +91 (§6.5). Backend revision 6 reviewed (§6.6): §1, §3.5 and §5.2 match. Open: `otpChargeToken` lifetime (15 vs 30 min); backend spec §8.1 still shows the old send-otp reply. |
| v1.7.0 | 2026-11-07 | Backend guide revision 5 reviewed in full (§6.6): §3.2 / §3.3 match the app; doc fixes needed on their side for §1 (`flutter_secure_storage`, `/api/version`, `update-device-token`) and §5.2 (screen share is socket-based). Corrected an earlier wrong row: the `/location` home socket exists (added to §0). §6.3 example now USD / 0% GST with parsing rules. New known gap: side-menu info mode shows fixed `₹` prices (§6.5). |
| v1.6.0 | 2026-11-07 | Doc completeness pass: `CurrencyFormat` and the OTP charges view added to the file registries; §6.5 updated (PayPal confirmed) with an OTP charge release test checklist. |
| v1.5.0 | 2026-11-07 | Backend guide revision 4: `verifyOtp` sample fixed, PayPal on the live account confirmed. Users' `countryCode` is now stored by `v2/send-otp` / `v2/verify-otp` (see Walkie guide §5.5). |
| v1.4.0 | 2026-11-07 | OTP Charges screen shows the charge currency and hides GST for non-INR charges without a GST split (§6.5). |
| v1.3.0 | 2026-11-07 | Backend guide revision 3: `Voip_Device` and USD OTP charges confirmed. New app gap in §6.5: the OTP Charges screen hard-codes `₹` and assumes 18% GST. Open: PayPal toggle, broken `verifyOtp` sample. |
| v1.2.0 | 2026-11-07 | §6.6 updated for backend guide revision 2: OTP contract confirmed (`SHOW_OTP_CHARGE_SCREEN`, `otpCharge` shape, v2 endpoints, `data.token`). Remaining questions: `USD` OTP charges for PayPal, `Voip_Device`. |
| v1.1.0 | 2026-11-07 | New §6: phone OTP login and international OTP charge flow as implemented, international cards & PayPal notes from backend guide v2.0.0, and open items for the backend team. |
| v1.0.0 | — | First version: cold start, permission gate, force logout, storage, audio arbiter. |
