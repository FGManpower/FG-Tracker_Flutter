# Walkie-Talkie (PTT) Module — Flutter Frontend Architecture & Implementation Guide

**Document Version:** `v1.6.0` · **Last updated:** 2026-11-08 · **Branch:** `46Solution`  
**Target Audience:** Flutter Frontend Developers  
**Covers:** Push-to-Talk (PTT) UI, Audio Stream & WebRTC, Active Channel Switcher, Notification Toggles, Group Info Sheet with Bell Indicators, Razorpay Plan Purchase & Seat Assignment, International Payments & PayPal  
**Status:** In Production / Stable  

---

## 0. Architecture & File Registry

| Layer | File Path | Core Responsibility |
|---|---|---|
| **Channel Repo** | `lib/app/Data/Repositories/walkie_channel_repo.dart` | Communicates with `walkie/channels`, notification toggles, active channel |
| **Plan / Payment Repo**| `lib/app/Data/Repositories/walkie_plan_repo.dart` | Plans, coupons, order summary, create order, verify, seat assignment |
| **Trial Overview** | `lib/app/Data/Repositories/walkie_talkie_trial_details_repository.dart`<br>`lib/app/Data/Services/walkie_talkie_trial_service.dart` | Manages subscription status, trial banners, seat availability checks |
| **Members Repo** | `lib/app/Data/Repositories/GroupRepo.dart` | Fetches group member list for Group Info bottom sheet |
| **Socket & WebRTC** | `lib/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart` (`GroupWalkieService`) | Connects to `/groupWalkie` namespace, manages WebRTC voice tracks |
| **PTT State** | `lib/app/modules/Walkie-talkie/Controller/walkieController.dart` (`GroupWalkieController`) | Talking/listening states, floor control lock, 10s admin alert countdown |
| **Channel State** | `lib/app/modules/Walkie-talkie/Controller/walkie_channel_controller.dart` | Channel selection, notification toggle, optimistic updates |
| **Order Summary** | `lib/app/modules/Walkie-talkie/Controller/walkie_order_summary_controller.dart` | Discount coupon calculation, order creation, Razorpay initiation |
| **Razorpay Controller**| `lib/app/modules/Walkie-talkie/Razorpay/Controller/razorpay_payment_controller.dart` | Razorpay SDK callback routing: Success, Pending, or Failed screens |
| **Group Info Sheet** | `lib/app/modules/Walkie-talkie/widgets/group_info_bottom_sheet.dart` | Renders member roster, live notification bell (visible only if notifications OFF) |
| **Screens & Views** | `lib/app/modules/Walkie-talkie/Views/WalkieTalkieScreen.dart`<br>`lib/app/modules/Walkie-talkie/Views/walkie_group_select_screen.dart`<br>`lib/app/modules/Walkie-talkie/Views/walkie_order_summary_screen.dart` | Primary user interfaces |

---

## 1. PTT User Experience & State Machine

### 1.1 Press-to-Talk Interaction
Located in `WalkieTalkieScreen.dart`:
- **Idle State:** Microphone button is neutral blue/grey. User is listening to incoming floor transmissions.
- **Press & Hold (Floor Request):**
  - Triggers `onLongPressStart` / `onTapDown`.
  - Haptic feedback fires immediately.
  - Client emits `ptt_request` (`{groupId, userId}`).
  - State changes to `Requesting...`.
- **Floor Granted:**
  - Server confirms via `ptt_granted`.
  - PTT button pulses vivid green. Audio waveform animation activates.
  - Microphone unmutes; WebRTC audio track begins broadcasting.
- **Floor Denied (Busy Floor):**
  - Server responds with `ptt_denied` (`{reason: "Floor busy", currentSpeaker: "John"}`).
  - PTT button turns amber/red, triggers failure vibration, and displays "Channel Busy".
- **Release (Floor Release):**
  - Triggers `onLongPressEnd` / `onTapUp`.
  - Client emits `ptt_release`. Microphone mutes; button returns to idle state.
- **Hands-Free Lock Mode:**
  - Swiping the PTT button upward engages hands-free talk lock, allowing continuous transmission without holding the screen. Tap once to unlock.

---

## 2. Channel Selection & Single Notification Channel Rule

### 2.1 Single Active Notification Channel
A user can receive background Walkie-Talkie audio/alerts for **at most one active group** at a time:
- In `walkie_group_select_screen.dart`, each channel card has a notification bell toggle.
- When the user enables notifications for Group B:
  1. Optimistic Update: Group B bell turns ON; any previously enabled group immediately turns OFF in the local UI.
  2. Emits socket event `set_active_notification_channel` with `{groupId: B, enabled: true}`.
  3. Dispatches `PATCH walkie/channels/:groupId/notifications`.
  4. If request fails, state rolls back to snapshot and displays an error snackbar.

---

## 3. Group Info Sheet & Notification Bell (§13 Verification)

Managed by `group_info_bottom_sheet.dart`:
- **Bell Visibility Rule:** The notification bell icon is **only shown for members whose Walkie-Talkie notifications are currently turned OFF**.
  - If Member A has notifications OFF: Bell icon appears next to their name. Admins can tap the bell to trigger an alert pinging the member to enable notifications.
  - If Member A has notifications ON: No bell icon is shown (they are already receiving live audio).
- **Admin Alert & 10s Countdown:**
  - Tapping the bell emits socket events on `/groupWalkie` (`GroupWalkieController`): `admin_alert_walkie_member`, `walkie_alert_member`, `walkie_invite_member` and `walkie_invite`, with `{ groupId, groupName, targetUserId, adminId, adminName, speakerImage, timestamp }`. The socket is the primary channel (backend accepts `groupId` or `channelId`). The backend also has a REST fallback, `POST walkie/channels/:groupId/alert-member` `{ targetUserId }`, which the app does not call.
  - The UI button immediately transforms into a 10-second circular countdown timer to prevent repeated spamming.

---

## 4. Plans, Checkout & Razorpay Payment Integration

```
User Trial Expired / ptt_denied ──► Plans Screen (Weekly/Monthly/Yearly)
                                            │
                                            ▼
                                  Order Summary Screen
                       (POST walkie/orders/summary, apply coupon)
                                            │
                                            ▼
                                   Create Razorpay Order
                             (POST walkie/payment/create-order)
                                            │
                                            ▼
                                 Open Native Razorpay SDK
                                            │
                 ┌──────────────────────────┼──────────────────────────┐
                 ▼                          ▼                          ▼
          [ SUCCESS ]                  [ PENDING ]                 [ FAILED ]
                 │                          │                          │
        Verify Payment               Re-verify / Webhook          Retry Payment
      (POST walkie/payment/verify)          │                          │
                 │                          ▼                          ▼
                 ▼                 Payment Pending Screen      Payment Failed Screen
      Payment Success Screen
                 │
                 ▼
        Assign Team Seats
  (POST walkie/update-member-subscription)
```

All paths are relative to `ConstRes.aBaseUrl` (`.../api/`) and use `Authorization: Bearer <JWT>`.

| Step | Endpoint (as called by the app) | Repo method |
|---|---|---|
| Plans | `GET walkie/plans?planType=` | `WalkiePlanRepo.getPlans` |
| Coupons | `GET walkie/coupons/eligible`, `POST walkie/coupons/apply` | `getEligibleCoupons`, `applyCoupon` |
| Order summary | `POST walkie/orders/summary` | `getOrderSummary` |
| Create order | `POST walkie/payment/create-order` `{ planId, purchasedSeats, couponCode }` | `createOrder` |
| Verify | `POST walkie/payment/verify` `{ paymentId, razorpayOrderId, razorpayPaymentId, razorpaySignature }` | `verifyPayment` |
| Seats | `POST walkie/update-member-subscription` `{ subscriptionId, targetUserIds, replaceUserIds? }` or `{ subscriptionId, action: "remove", removeUserId }` | `updateMemberSubscription` |

1. **Order Summary Controller (`processPayment`):** Applies coupon codes via `WalkiePlanRepo.applyCoupon()`, calls create-order, then builds the checkout options:
   - **Amount:** `razorpay.amount` from create-order (minor units). Falls back to `totalPayable * 100`.
   - **Currency:** `razorpay.currency` from create-order. Falls back to `INR`.
   - **Key priority:** create-order `keyId` → `/initialize` `payment.razorpay.keyId` → `ConstRes.activePaymentKey`.
   - **Prefill:** `customer.contact` (E.164 e.g. `+14155552671`), `customer.email` and `customer.name` from the `customer` object returned by create-order, plus the method the user picked.
2. **Razorpay SDK Event Handlers (`RazorpayPaymentController`):**
   - `handlePaymentSuccess`: Sends `paymentId` (from create-order `data.payment.id`) plus `razorpay_order_id`, `razorpay_payment_id` and `razorpay_signature` to `walkie/payment/verify`. **`paymentId` is required.**
   - `handlePaymentError`: Routes to `walkie_talkie_payment_pending_screen.dart` (gateway says pending) or `walkie_talkie_payment_failed_screen.dart`. Verify is not called.
3. **Seat Allocation:** After successful verification, admin can distribute purchased seats among circle members using `WalkiePlanRepo.updateMemberSubscription()`.

---

## 5. International Payments & PayPal (Backend v2.0.0)

The backend has enabled international payments and PayPal through Razorpay. Source: the backend team's `03_WALKIE_TALKIE_MODULE_FRONTEND.md` v2.0.0, §5.

### 5.1 What the backend contract says
- **Currency comes from the backend.** Plans (`GET walkie/plans`) and create-order return `currency` (`INR`, `USD`, `EUR`, `AED` …). The client passes it straight into the Razorpay options.
- **PayPal needs no separate SDK.** When the order currency is `USD`, Razorpay Checkout shows PayPal inside the standard checkout sheet. PayPal is toggled in the live Razorpay Dashboard under **Settings > Payment Methods > International Payments > PayPal**.
- **Which orders are USD:** any Walkie plan stored with `currency: "USD"` returns `USD` from create-order. Domestic plans stay `INR`.
- **Prefill for international cards.** Visa / Mastercard / Amex require 3D Secure 2.0 and address checks. Always prefill `name`, `email` and `contact`. `contact` is provided by backend in `data.customer.contact` in E.164 format with the country code (`+14155552671`, `+919876543210`), preventing bank declines.
- **Amount is in minor units** (cents / paise), exactly as the backend created the order. `data.razorpay.amount` is **always** in minor units: never multiply it by 100. Only the fallback `pricing.finalAmount` is in major units.
- **create-order response (confirmed, revision 4):**
```json
{
  "status": true,
  "message": "Payment order created successfully",
  "data": {
    "payment":  { "id": 142, "orderId": "WALKIE_ORD_1731057891234", "status": "pending" },
    "razorpay": { "keyId": "rzp_live_xxxx", "orderId": "order_OG7289ABCxyz", "amount": 1050, "currency": "USD" },
    "customer": {
      "name": "John Smith",
      "email": "john@example.com",
      "contact": "+14155552671",
      "countryCode": "+1"
    },
    "plan":     { "id": 1, "name": "Walkie Individual Pro", "planType": "individual", "billingInterval": "monthly", "durationMonths": 1 },
    "subscription": { "purchasedSeats": 1 },
    "coupon":   { "applied": false, "details": null },
    "pricing":  { "subtotal": 10.50, "discountAmount": 0.00, "taxableAmount": 10.50, "gstPercent": 0, "gstAmount": 0.00, "finalAmount": 10.50 }
  }
}
```
  This matches the nested shape the app parses (`WalkieCreateOrderData`). `payment.id` is the `paymentId` sent to verify.

### 5.2 Client checklist

| # | Requirement | App today | Action |
|---|---|---|---|
| 1 | Pass backend `currency` into `_razorpay.open` | ✅ `'currency': rzp?.currency ?? 'INR'` | None |
| 2 | Use backend `amount` (minor units) | ✅ `razorpay.amount` used as is; fallback `pricing.finalAmount × 100`; stops with an error if the amount is 0 | None |
| 3 | `contact` prefill in E.164 | ✅ Use `data.customer.contact` (E.164, e.g. `+14155552671` or `+919876543210`) | App maps `data.customer.contact` to `prefill.contact` |
| 4 | `name` + `email` prefill | ✅ Sent from `data.customer.name` and `data.customer.email` | None |
| 5 | Show the order currency on screen | ✅ Order Summary and coupon toasts use `controller.money()` (`₹`, `$`, `€`, `£`, else the code); thousands grouping for non-INR | None |
| 6 | PayPal reachable in checkout | ✅ Non-INR orders send no `config` blocks and no `method` prefill, so Razorpay's default checkout (cards, PayPal) opens. INR orders are unchanged. | None |

Currency source (`WalkieOrderSummaryController.currencyCode`): create-order `razorpay.currency` → summary `plan.currency` → summary `currency` → chosen plan `currency` → `INR`. Shared helper: `lib/app/Core/util/currency_format.dart`.

### 5.3 Reference options for a non-INR order
```dart
final options = {
  'key': rzp.keyId,                 // key paired with the order
  'order_id': rzp.orderId,
  'amount': rzp.amount,             // minor units, from the backend
  'currency': rzp.currency,         // e.g. 'USD' → PayPal shown
  'name': 'FG MANPOWER LLP',
  'description': 'Walkie-Talkie Subscription',
  'prefill': {
    'name': customer.name,
    'email': customer.email,
    'contact': customer.contact,    // E.164 format: +14155552671 or +919876543210
  },
  'notes': {
    'purpose': 'walkie_subscription',
    'backendOrderId': payment.orderId,
  },
};
```

### 5.4 Review of the backend guide
**Revision 4 (07 Nov 2026):** All frontend requirements are implemented and verified in the backend.

| Item | Status | Backend Outcome |
|---|---|---|
| `customer` object (E.164 `contact`) in create-order | ✅ **Completed** | Returned in `data.customer` with `name`, `email`, `contact` (`+14155552671` / `+919876543210`), and `countryCode` (`+1` / `+91`). |
| User `countryCode` storage & backfill | ✅ **Completed** | `countryCode` column added to `users` table; Indian 10-digit users backfilled with `+91`; `v2/send-otp` and `v2/verify-otp` persist `countryCode` for every user. |
| PayPal toggle in live Razorpay Dashboard | ✅ **Confirmed** | Backend exports 0% GST and USD currency orders. Live Razorpay account toggle location: *Settings > Payment Methods > International Payments > PayPal*. |
| Seat assignment body | ✅ **Completed** | Backend accepts `targetUserIds` / `targetUserId`, `replaceUserIds`, and `action: "remove"` + `removeUserId` (or `targetUserIds`). |
| Notification toggle | ✅ **Completed** | `PATCH walkie/channels/:groupId/notifications`. |
| Admin alert | ✅ **Completed** | Socket `admin_alert_walkie_member` (alias `walkie_alert_member`) is primary; REST fallback is `alert-member`. |
| PTT events | ✅ **Completed** | `walkie_speaker_active` `{ userId, userName, groupId }`, `walkie_speaker_stopped` `{ userId, groupId }`. |
| Which orders are USD | ✅ **Completed** | Plans stored with `currency: "USD"`. |
| Payment endpoints & create-order shape | ✅ **Completed** | Matches app (`walkie/payment/create-order`, `walkie/payment/verify`). |
| Amount unit & paymentId | ✅ **Completed** | `razorpay.amount` is minor units. `paymentId` (`data.payment.id`) required on verify. |

### 5.5 Backend Request: Customer Details in Create-Order (Shipped)

**Status:** ✅ Implemented & Deployed (07 Nov 2026) · **Owner:** Backend · **Target:** Flutter App v1.5.0

#### 1. Added `customer` to create-order response
`POST walkie/payment/create-order` returns the `customer` object:
```json
{
  "status": true,
  "message": "Payment order created successfully",
  "data": {
    "payment":  { "id": 142, "orderId": "WALKIE_ORD_1731057891234", "status": "pending" },
    "razorpay": { "keyId": "rzp_live_xxxx", "orderId": "order_OG7289ABCxyz", "amount": 1050, "currency": "USD" },
    "customer": {
      "name": "John Smith",
      "email": "john@example.com",
      "contact": "+14155552671",
      "countryCode": "+1"
    },
    "plan":     { "...": "unchanged" },
    "pricing":  { "...": "unchanged" }
  }
}
```

| Field | Type | Behavior |
|---|---|---|
| `customer.name` | string \| null | The user's profile name. `null` if not set. |
| `customer.email` | string \| null | The user's email, unmasked. `null` if not set. |
| `customer.contact` | string \| null | **E.164:** `+`, dial code, then local number without spaces or leading zero (`+14155552671`, `+919876543210`). `null` if country code is unknown. |
| `customer.countryCode` | string \| null | Dial code with `+` (`+1`, `+91`). `null` if unknown. |

#### 2. User `countryCode` Storage & Migration
- Column `countryCode` added to the `users` table via migration `20261107200000-add-countrycode-to-users.js`.
- All existing Indian 10-digit mobile numbers are automatically backfilled with `+91`.
- `UserService.VeriefyOtp` stores `countryCode` upon login/registration for all new and returning users.

---

### 5.6 Country-to-Currency Resolution & Dynamic Plan Fallback
- GET /api/walkie/plans dynamically determines currency from the authenticated user's countryCode:
  * +966 -> SAR (Saudi Arabia)
  * +971 -> AED (United Arab Emirates)
  * +91 -> INR (India)
  * +44 -> GBP (UK), etc.
- **Resilient Fallback:** If a user logs in from a country with no custom local currency plans created in the database yet (e.g. +971 user when only SAR, INR, and USD plans exist), the backend automatically falls back to USD so plans are always available.
- **Frontend Display:** CurrencyFormat.symbol(plan.currency) formats the currency dynamically (SAR 20.99, AED 22.00, ₹500, $5.99). No client-side hardcoding needed.

---

## 6. Change log
| Version | Date | Change |
|---|---|---|
| v1.7.0 | 2026-11-09 | Production International Payment Gateway readiness verified: Flutter models (WalkiePlanItem, WalkiePaymentOrderModel, plan controller) updated to num for decimal pricing (.99 / .99 / .99); dynamic CurrencyFormat integrated across all screens; razorpay_payment_screen passes plan currency to Razorpay SDK. |
| v1.6.0 | 2026-11-08 | Multi-currency Walkie plans shipped: `GET walkie/plans` auto-detects international users by `countryCode` and serves USD plans ($5.99 / $9.99 / $19.99); zero-rated 0% export GST applied under LUT RFD-11; verified with Argentina (`+54`) & USA (`+1`). |
| v1.5.0 | 2026-11-07 | Backend shipped §5.5: added `customer` object (E.164 `contact`, `countryCode`, `name`, `email`) to create-order response, added `countryCode` column to `users`, and backfilled Indian 10-digit users. |
| v1.4.0 | 2026-11-07 | Client fixes (§5.2): Order Summary shows the order currency; non-INR orders open the default checkout (PayPal visible, no UPI forcing, no wrong phone); amount fallback uses `pricing.finalAmount` and never charges a placeholder. |
| v1.3.0 | 2026-11-07 | Backend guide revision 3: seat body, notification toggle, admin alert (socket primary, REST `alert-member` fallback), PTT events and USD plans all confirmed (§3, §5.1, §5.4). Only open item: PayPal toggle confirmation. |
| v1.2.0 | 2026-11-07 | Reviewed backend guide revision 2: payment endpoints, create-order shape, amount unit and `paymentId` confirmed (§5.1, §5.4). New open items: seat body key, alert endpoint, PTT event names. §3 corrected: the admin alert is sent over the socket, not REST. §4 seats body added. |
| v1.1.0 | 2026-11-07 | §4 endpoints corrected to match the app (`walkie/payment/create-order`, `walkie/payment/verify`, `walkie/update-member-subscription`). New §5: international payments & PayPal from backend guide v2.0.0, client checklist, reference options, and open items for the backend team. |
| v1.0.0 | — | First version: PTT, channels, Group Info sheet, plans and Razorpay checkout. |
