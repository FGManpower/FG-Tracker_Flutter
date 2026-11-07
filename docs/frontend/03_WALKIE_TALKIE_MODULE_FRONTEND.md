# Walkie-Talkie (PTT) Module — Flutter Frontend Architecture & Implementation Guide

**Document Version:** `v1.8.0` · **Last updated:** 2026-11-07 · **Branch:** `46Solution`  
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
| **Plans** | `lib/app/modules/Walkie-talkie/Controller/walkie_talkie_plan_controller.dart`<br>`lib/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart` | Plan list, team seats, coupons; prices in each plan's currency (`money(amount, [currency])`) |
| **Order Summary** | `lib/app/modules/Walkie-talkie/Controller/walkie_order_summary_controller.dart` | Discount coupon calculation, order creation, Razorpay options (currency, prefill, INR-only method picker) |
| **Order Models** | `lib/app/Model/walkie_create_order_model.dart`<br>`lib/app/Model/walkie_order_summary_model.dart`<br>`lib/app/Model/walkie_plan_model.dart` | create-order (`payment`, `razorpay`, `customer`, `pricing`), summary and plan parsing, incl. `currency` |
| **Razorpay Controller**| `lib/app/modules/Walkie-talkie/Razorpay/Controller/razorpay_payment_controller.dart` | Razorpay SDK callback routing: Success, Pending, or Failed screens; keeps the checkout `currency` for those screens |
| **Payment Result Screens** | `lib/app/modules/Walkie-talkie/Views/walkie_talkie_purchase_success_screen.dart`<br>`lib/app/modules/Walkie-talkie/Views/walkie_talkie_payment_pending_screen.dart`<br>`lib/app/modules/Walkie-talkie/Views/walkie_talkie_payment_failed_screen.dart` | Receipt, re-verify, retry; amounts via `RazorpayPaymentController.money()` |
| **Currency Format** | `lib/app/Core/util/currency_format.dart` (`CurrencyFormat`) | Shared symbol / grouping / screen-reader text for any backend currency (also used by OTP charges) |
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
   - **Amount:** `razorpay.amount` from create-order (minor units). Falls back to `pricing.finalAmount × 100`; stops with an error if that is 0.
   - **Currency:** `razorpay.currency` from create-order. Falls back to the order's `currencyCode` (§5.2), then `INR`.
   - **Checkout type:** INR → custom blocks with the user's method first (UPI by default). Non-INR → Razorpay's default checkout (cards, PayPal); no method prefill.
   - **Key priority:** create-order `keyId` → `/initialize` `payment.razorpay.keyId` → `ConstRes.activePaymentKey`.
   - **Prefill:** `customer.contact` (E.164), `customer.name` and `customer.email` from create-order; storage fills a missing name / email (§5.2). INR orders also prefill the method the user picked (UPI / card / netbanking / wallet).
2. **Razorpay SDK Event Handlers (`RazorpayPaymentController`):**
   - `openCheckoutMap`: stores plan, seats, amount, method and the options' `currency` for the result screens, then opens the SDK.
   - `handlePaymentSuccess`: Sends `paymentId` (from create-order) plus `razorpay_order_id`, `razorpay_payment_id` and `razorpay_signature` to `walkie/payment/verify`. **`paymentId` is required.**
   - `handlePaymentError`: Routes to `walkie_talkie_payment_pending_screen.dart` (gateway says pending) or `walkie_talkie_payment_failed_screen.dart`. Verify is not called.
3. **Seat Allocation:** After successful verification, admin can distribute purchased seats among circle members using `WalkiePlanRepo.updateMemberSubscription()`.

---

## 5. International Payments & PayPal

The backend has enabled international payments and PayPal through Razorpay. Sources: the backend team's `03_WALKIE_TALKIE_MODULE_FRONTEND.md` (revisions 1–4, 07 Nov 2026) and `03_WALKIE_TALKIE_MODULE_BACKEND.md` v2.1.0 §7.

### 5.1 What the backend contract says
- **Currency comes from the backend.** Plans (`GET walkie/plans`) and create-order return `currency` (`INR`, `USD`, `EUR`, `AED` …). The client passes it straight into the Razorpay options.
- **PayPal needs no separate SDK.** When the order currency is `USD` (or another PayPal currency such as `EUR` / `GBP`), Razorpay Checkout shows PayPal inside the standard checkout sheet. PayPal is never shown for `INR` orders. Backend confirmed the live account supports USD and PayPal (Settings → Payment Methods → International Payments → PayPal).
- **GST:** non-INR plans are export of services, so the backend returns `gstPercent: 0`. Domestic INR orders keep 18%.
- **Which orders are USD:** any Walkie plan stored with `currency: "USD"` returns `USD` from create-order. Domestic plans stay `INR`.
- **Prefill for international cards.** Visa / Mastercard / Amex require 3D Secure 2.0 and address checks. Always prefill `name`, `email` and `contact`. `contact` must be in E.164 format with the country code (`+14155552671`, `+919876543210`), otherwise banks may decline.
- **Amount is in minor units** (cents / paise), exactly as the backend created the order. `data.razorpay.amount` is **always** in minor units: never multiply it by 100. Only the fallback `pricing.finalAmount` is in major units.
- **create-order response (confirmed, revision 4):**
```json
{ "status": true, "data": {
  "payment":  { "id": 142, "orderId": "WALKIE_ORD_1731057891234", "status": "pending" },
  "razorpay": { "keyId": "rzp_live_xxxx", "orderId": "order_OG7289ABCxyz", "amount": 1050, "currency": "USD" },
  "customer": { "name": "John Smith", "email": "john@example.com", "contact": "+14155552671", "countryCode": "+1" },
  "plan":     { "id": 1, "name": "Walkie Individual Pro", "planType": "individual", "billingInterval": "monthly", "durationMonths": 1 },
  "pricing":  { "subtotal": 10.50, "discountAmount": 0.00, "taxableAmount": 10.50, "gstPercent": 0, "gstAmount": 0.00, "finalAmount": 10.50 } } }
```
  This is the nested shape the app parses (`WalkieCreateOrderData`, `customer` → `WalkieOrderCustomerInfo`). `payment.id` is the `paymentId` sent to verify.

### 5.2 Client checklist

| # | Requirement | App today | Action |
|---|---|---|---|
| 1 | Pass backend `currency` into `_razorpay.open` | ✅ `'currency': CurrencyFormat.code(rzp?.currency ?? currencyCode)` | None |
| 2 | Use backend `amount` (minor units) | ✅ `razorpay.amount` used as is; fallback `pricing.finalAmount × 100`; stops with an error if the amount is 0 | None |
| 3 | `contact` prefill in E.164 | ✅ `customer.contact` from create-order, used only if it is valid E.164 (`+` and 8–15 digits). **Fallback** when it is `null` (e.g. an older international user with no stored country code): INR → stored 10-digit number; non-INR → no `contact`, so checkout asks for it with its country picker. | None |
| 4 | `name` + `email` prefill | ✅ `customer.name` / `customer.email`; storage fills a missing value | None |
| 5 | Show the order currency on screen | ✅ `₹`, `$`, `€`, `£`, else the code; lakh grouping for INR, thousands otherwise. **Plan details:** each plan in its own `currency`, totals in the selected plan's currency. **Order Summary** and coupon toasts: order currency. **Success / pending / failed** and the shared receipt: currency of the last checkout (`RazorpayPaymentController.currency`). | None (see §5.7 for the placeholder cards) |
| 6 | PayPal reachable in checkout | ✅ Non-INR orders send no `config` blocks and no `method` prefill, so Razorpay's default checkout (cards, PayPal) opens. INR orders are unchanged. | None |

Currency source (`WalkieOrderSummaryController.currencyCode`): create-order `razorpay.currency` → summary `plan.currency` → summary `currency` → chosen plan `currency` → `INR`. Shared helper: `lib/app/Core/util/currency_format.dart` (`CurrencyFormat.format(amount, currency)` → `₹1,25,000` / `$125,000.50`). Plan screens use `WalkieTalkiePlanController.money(amount, [currency])`; result screens use `RazorpayPaymentController.money(amount)`, whose currency is set from the checkout options in `openCheckoutMap`.

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
    'contact': customer.e164Contact,   // "+14155552671"
  },
  'notes': {'purpose': 'walkie_subscription', 'backendOrderId': payment.orderId},
};
```

### 5.4 Review of the backend guide
**Revision 4 (07 Nov 2026):** nothing is open. The backend shipped §5.5 and confirmed the live account supports USD and PayPal.

**Resolved in revision 4**

| Item | Outcome |
|---|---|
| `customer` object in create-order | ✅ Shipped; the app uses it (§5.2) |
| Users' `countryCode` stored | ✅ New `users.countryCode` column, saved on `v2/send-otp` / `v2/verify-otp`; existing Indian 10-digit numbers backfilled with `+91` |
| PayPal on the live account | ✅ Confirmed supported (USD) |

**Resolved in revision 3**

| Item | Outcome |
|---|---|
| Seat assignment body | ✅ Backend accepts `targetUserIds` / `targetUserId`, `replaceUserIds`, and `action: "remove"` + `removeUserId` (or `targetUserIds`) |
| Notification toggle | ✅ `PATCH walkie/channels/:groupId/notifications` |
| Admin alert | ✅ Socket `admin_alert_walkie_member` (alias `walkie_alert_member`) is primary; REST fallback is `alert-member` |
| PTT events | ✅ `walkie_speaker_active` `{ userId, userName, groupId }`, `walkie_speaker_stopped` `{ userId, groupId }` |
| Which orders are USD | ✅ Plans stored with `currency: "USD"` |

**Resolved in revision 2**

| Item | Outcome |
|---|---|
| Endpoints (create-order, verify, seats, channel notifications) | ✅ Match the app (§4 table) |
| create-order response shape | ✅ Nested `payment` / `razorpay` / `plan` / `pricing`, as the app parses |
| Amount unit | ✅ `razorpay.amount` is always minor units |
| `paymentId` in verify | ✅ Required (`data.payment.id`) |
| Sample `Razorpay()` never cleared; checks only HTTP 200 on verify | Sample only; the app keeps one instance per controller and checks `status` in the body |

### 5.5 ✅ Backend request: customer details in create-order

**Status:** Requested and shipped 07 Nov 2026 · **Owner:** Backend · **Client:** done (`WalkieOrderCustomerInfo`, `WalkieOrderSummaryController.processPayment`)

> **Backend notes on delivery:** migration `20261107200000-add-countrycode-to-users.js` adds `users.countryCode`. Existing Indian 10-digit numbers were backfilled with `+91`. Existing **international** users have no stored code until their next login, so their `contact` is `null` and the app uses the fallback in §5.2.

The original request is kept below for reference.

#### Why
Razorpay needs the customer's phone number **with country code** (E.164, e.g. `+14155552671`) for international cards (3D Secure 2.0). Without it, banks may decline the payment.

The app only stores the user's **local** number (`MobileNo`, e.g. `4155552671`). It does not keep the country code after login. So before this change:
- **INR orders** send the 10-digit number (Razorpay reads it as +91).
- **Non-INR orders** send no phone number, and Razorpay asks the user to type it.

The backend already knows each user's country code, because the app sends `countryCode` on `v2/send-otp` and `v2/verify-otp`.

#### Requirement 1: add `customer` to the create-order response
`POST walkie/payment/create-order`: add a `customer` object next to `payment` / `razorpay`:

```json
{
  "status": true,
  "message": "Payment order created successfully",
  "data": {
    "payment":  { "id": 142, "orderId": "WALKIE_ORD_1731057891234", "status": "pending" },
    "razorpay": { "keyId": "rzp_live_xxxx", "orderId": "order_OG7289ABCxyz", "amount": 1050, "currency": "USD" },
    "plan":     { "...": "unchanged" },
    "pricing":  { "...": "unchanged" },
    "customer": {
      "name": "John Smith",
      "email": "john@example.com",
      "contact": "+14155552671",
      "countryCode": "+1"
    }
  }
}
```

| Field | Type | Rule |
|---|---|---|
| `customer.name` | string \| null | The user's profile name. `null` if not set. |
| `customer.email` | string \| null | The user's email, **not masked**. `null` if not set. |
| `customer.contact` | string \| null | **E.164:** `+`, country code, then the local number, digits only, no spaces or leading `0` (`+14155552671`, `+919876543210`). `null` if the country code is unknown. |
| `customer.countryCode` | string \| null | Dial code with `+` (`+1`, `+91`). `null` if unknown. |

- All existing fields stay exactly as they are. This is an addition only.
- Return `customer` for **every** currency, INR included.

#### Requirement 2: store the country code for every user
- Please confirm that `users` stores the `countryCode` the app sends on `v2/send-otp` / `v2/verify-otp`.
- If it is not stored yet: save it on verify-otp, and decide how to fill it for existing users (e.g. `+91` for Indian numbers, otherwise `null` until their next login).

#### What the app does (implemented)
- Uses `customer.contact` for Razorpay `prefill.contact` (and `name` / `email` when sent), for all currencies.
- If `customer` or `contact` is missing, `null` or not valid E.164, it keeps the fallback (§5.2 item 3).
- Only the Walkie create-order model and `WalkieOrderSummaryController` changed. No login code changes.

#### Acceptance checks
1. Indian user, INR plan → `customer.contact` = `+91XXXXXXXXXX`.
2. US user (`+1`), USD plan → `customer.contact` = `+1XXXXXXXXXX`, `customer.countryCode` = `+1`.
3. User with no email or name → those fields are `null`, the order is still created.
4. Older user with no stored country code → `contact` and `countryCode` are `null`, the order is still created.
5. All other create-order fields are unchanged.

### 5.6 Release test checklist (real device, live or test key)

| # | Scenario | Expected |
|---|---|---|
| 1 | Indian user, INR plan, pay with UPI | UPI block first; phone prefilled; `₹` everywhere; GST 18% on the summary; Success screen and receipt in `₹` |
| 2 | US user (`+1`), USD plan | `$` on plan card, summary, success and receipt; no GST line; checkout opens the default layout with **PayPal** and cards; phone prefilled as `+1…` |
| 3 | USD plan, pay with PayPal | Verify succeeds → Success screen; subscription active in `walkie/overview` |
| 4 | USD plan, cancel checkout | Failed screen in `$`; "no amount charged" message; Retry returns to the Order Summary |
| 5 | Older international user (no stored country code) | Order is created; checkout asks for the phone with its country picker |
| 6 | Apply a coupon on a USD plan | Toast and discount line in `$` |
| 7 | Network drop right after paying | Pending screen in the order currency; Refresh status → Success once the webhook lands |
| 8 | Team plan (several seats), INR | Unchanged from before: member total, seats assignment after Success |

### 5.7 Known limitations
- **Placeholder plan cards:** when no plans load, `walkie_talkie_plan_details.dart` shows fixed sample cards (`₹500`, `₹399`, `FLAT ₹150 OFF`). They are not real prices and stay in `₹`.
- **Older international users:** until their next login the backend has no country code for them, so `customer.contact` is `null` and they type their phone in checkout (§5.5).
- **Unused code:** `RazorpayPaymentScreen` and `WalkieTalkiePurchaseSuccessController` are not referenced anywhere and still format amounts in `₹`. Remove them, or update them before reuse.
- **Amount fallback** (`pricing.finalAmount × 100`) assumes a 2-decimal currency. It is only used if create-order omits `razorpay.amount`; zero-decimal currencies such as `JPY` would need the backend amount.

---

## 6. Change log
| Version | Date | Change |
|---|---|---|
| v1.8.0 | 2026-11-07 | Doc completeness pass: §0 file registry adds plans, order models, result screens and `CurrencyFormat`; §4 documents the INR vs non-INR checkout and `openCheckoutMap` currency; §5 sources updated; new §5.6 release test checklist and §5.7 known limitations. |
| v1.7.0 | 2026-11-07 | Currency shown correctly on the plan details, purchase success, payment pending and payment failed screens, plus the plan coupon toast and the receipt share text (§5.2 item 5). |
| v1.6.0 | 2026-11-07 | Backend shipped §5.5. Client: `WalkieOrderCustomerInfo` parses `data.customer`; checkout prefills `customer.contact` (E.164) / name / email, falling back to the old behaviour when missing. §4 amount fallback text corrected. §5.4: nothing open. |
| v1.5.0 | 2026-11-07 | New §5.5: backend request to add a `customer` object (E.164 `contact`, `countryCode`, `name`, `email`) to the create-order response, and to store each user's country code. §5.2 item 3 and §5.4 open items point to it. |
| v1.4.0 | 2026-11-07 | Client fixes (§5.2): Order Summary shows the order currency; non-INR orders open the default checkout (PayPal visible, no UPI forcing, no wrong phone); amount fallback uses `pricing.finalAmount` and never charges a placeholder. |
| v1.3.0 | 2026-11-07 | Backend guide revision 3: seat body, notification toggle, admin alert (socket primary, REST `alert-member` fallback), PTT events and USD plans all confirmed (§3, §5.1, §5.4). Only open item: PayPal toggle confirmation. |
| v1.2.0 | 2026-11-07 | Reviewed backend guide revision 2: payment endpoints, create-order shape, amount unit and `paymentId` confirmed (§5.1, §5.4). New open items: seat body key, alert endpoint, PTT event names. §3 corrected: the admin alert is sent over the socket, not REST. §4 seats body added. |
| v1.1.0 | 2026-11-07 | §4 endpoints corrected to match the app (`walkie/payment/create-order`, `walkie/payment/verify`, `walkie/update-member-subscription`). New §5: international payments & PayPal from backend guide v2.0.0, client checklist, reference options, and open items for the backend team. |
| v1.0.0 | — | First version: PTT, channels, Group Info sheet, plans and Razorpay checkout. |
