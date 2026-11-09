# Backend Specification: Walkie-Talkie (PTT) Module (Node.js / Express / Socket.io / Razorpay)

> **Document Version:** `v2.2.0`  
> **Backend Architecture:** Node.js, Express, Sequelize ORM (MySQL), Socket.io (`/groupWalkie`), WebRTC Voice Engine, Razorpay Cryptographic Webhooks  
> **Source Files Covered:**  
> - Routes: `routes/walkie.routes.js`, `app.js` (Razorpay raw webhook mount)  
> - Controllers: `controllers/walkiePayment.controller.js`, `controllers/walkiePlanApi.controller.js`, `controllers/walkieSubscription.controller.js`, `controllers/walkieTrial.controller.js`, `controllers/webhookDispatcher.controller.js`, `controllers/walkiePaymentWebhook.controller.js`  
> - Services: `services/walkiePayment.service.js`, `services/walkiePlan.service.js`, `services/walkieOrderSummary.service.js`, `services/groupWalkieSessionManager.js`, `services/walkieSubscription.service.js`, `services/user.service.js`  
> - Sockets: `sockets/stream_group_walkie_socket.js` (`/groupWalkie`)  
> - Models: `models/users.js`, `models/walkieChannelPreference.js`, `models/walkieUserActiveChannel.js`, `models/walkiePlan.model.js`, `models/walkieSubscription.model.js`, `models/walkieSubscriptionMember.model.js`, `models/walkieSubscriptionPeriod.model.js`, `models/walkieTrial.model.js`, `models/walkiePayment.model.js`, `models/walkiePaymentEvent.model.js`

---

## 1. Architectural Architecture & PTT Floor Control

```
                 ┌─────────────────────────────────────────────────────────┐
                 │                   CLIENT PTT ACTIONS                    │
                 └──────────────┬───────────────────────────┬──────────────┘
                                │ REST Admin/Plans          │ Socket /groupWalkie
                                ▼                           ▼
             ┌─────────────────────────────┐     ┌─────────────────────────────┐
             │ Express Walkie Routes       │     │ Socket.io /groupWalkie      │
             │ - /api/walkie/channels      │     │ - join_walkie_session       │
             │ - /api/walkie/plans         │     │ - ptt_request               │
             │ - /api/walkie/payment       │     │ - ptt_granted / ptt_denied  │
             │ - /api/walkie/alert         │     │ - ptt_release               │
             └──────────────┬──────────────┘     └──────────────┬──────────────┘
                            │                                   │
                            ▼                                   ▼
             ┌─────────────────────────────────────────────────────────────────┐
             │               GROUP WALKIE SESSION MANAGER                      │
             │ - Single floor arbiter per channel (isFloorTaken)               │
             │ - Active speaker tracking & talking timeout (30s)               │
             │ - Single active notification channel constraint                 │
             │ - Section 13 Notification Bell member evaluation                │
             └──────────────────────────────┬──────────────────────────────────┘
                                            │
                       ┌────────────────────┴────────────────────┐
                       ▼                                         ▼
         ┌───────────────────────────┐             ┌───────────────────────────┐
         │     SEQUELIZE / MYSQL     │             │     RAZORPAY GATEWAY      │
         │ (Subscriptions, Channels, │             │ (HMAC-SHA256 Webhooks &   │
         │  Seat Licences, Payments) │             │  Signature Verification)  │
         └───────────────────────────┘             └───────────────────────────┘
```

---

## 2. Floor Control Algorithm & WebRTC Audio Mesh

In `services/groupWalkieSessionManager.js`:
1. **Floor Lock:** When `ptt_request` arrives for channel `groupId`:
   - Checks `session.activeSpeaker`. If non-null and not expired:
     - Returns `ptt_denied` with `{ reason: "channel_busy", activeSpeaker }`.
   - If free:
     - Assigns `session.activeSpeaker = userId`.
     - Starts 30-second speaking safety timer.
     - Emits `ptt_granted` to the speaker and broadcasts `walkie_speaker_active` to room `walkie_group_${groupId}`.
2. **Floor Release:** When `ptt_release` or socket disconnect fires:
   - Clears `session.activeSpeaker`.
   - Broadcasts `walkie_speaker_stopped` to the room.

---

## 3. Single Active Notification Channel Constraint

A user cannot receive audio simultaneously from multiple walkie groups. The database enforces:
```sql
UPDATE walkie_channel_preferences 
SET notifications_enabled = 0 
WHERE user_id = :userId AND group_id != :targetGroupId;

INSERT INTO walkie_channel_preferences (user_id, group_id, notifications_enabled)
VALUES (:userId, :targetGroupId, 1)
ON DUPLICATE KEY UPDATE notifications_enabled = 1;
```
Client route: `PATCH /api/walkie/channels/:groupId/notifications`.

---

## 4. Group Info Sheet Notification Bell (§13 Verification)

In the Group Info sheet:
- Members with `notifications_enabled = 1` are already receiving audio live.
- Members with `notifications_enabled = 0` are missing audio transmissions.
- **Backend Filter:** The member list cross-references `walkie_channel_preferences`. If `notifications_enabled == 0` or record is missing, the response outputs `showNotificationBell: true` for that member.

---

## 5. Admin Alert Broadcast System

- **Primary Socket Event:** Client emits `admin_alert_walkie_member` (or alias `walkie_alert_member`) with 10-second countdown to room `/groupWalkie`.
- **REST Fallback:** `POST /api/walkie/channels/:groupId/alert-member` `{ targetUserId }`.
- **FCM Override:** Dispatches high-priority push notification with loud siren channel ID to target group members regardless of their notification toggle.

---

## 6. Razorpay Webhook Engine & Raw Body Handling

In `app.js`:
- Razorpay webhook verification requires the byte-for-byte exact request payload.
- Mounted **BEFORE** `express.json()`:
  ```javascript
  app.post(
    "/api/walkie/payment/webhook",
    express.raw({ type: "application/json", limit: "2mb" }),
    webhookDispatcherController.handleWebhook
  );
  ```
- Signature verified with `crypto.createHmac("sha256", process.env.RAZORPAY_WEBHOOK_SECRET)`.
- Idempotency enforced via `walkiePaymentEvent.model.js`.

---

## 7. International Payment Gateway & Multi-Currency Architecture

### 7.1 Multi-Currency Plans API (`GET /api/walkie/plans`)
The plans endpoint serves domestic Indian users in **INR (₹)** and international users in **USD ($)**:
- **Currency Detection Logic:**
  1. **Explicit Query:** `GET /api/walkie/plans?currency=USD` or `?currency=INR`.
  2. **Automatic Detection:** If no query param is sent, the server inspects the authenticated user (`req.user.countryCode`):
     - `countryCode !== "+91"` (e.g. `+54` for Argentina, `+1` for USA, `+44` for UK) -> serves **`USD`** plans.
     - `countryCode === "+91"` (or 10-digit Indian number) -> serves **`INR`** plans.
- **Available Plan Tiers:**
  - **International (USD):**
    - Individual Monthly: `$5.99` (`durationMonths: 1`)
    - Individual Quarterly: `$9.99` (`durationMonths: 3`)
    - Individual Yearly: `$19.99` (`durationMonths: 12`)
    - Group Monthly: `$5.99` / seat (`minMembers: 2`, `maxMembers: 100`)
  - **Domestic (INR):**
    - Individual Monthly: `₹500.00`
    - Individual Quarterly: `₹750.00`
    - Individual Yearly: `₹1,500.00`
    - Group Monthly: `₹500.00` / seat

### 7.2 Legal & Tax Framework (Indian GST & Export of Services)
1. **Domestic Supplies (India / `+91` / `INR`):**
   - Place of Supply is India.
   - Standard 18% GST applies (`WALKIE_GST_PERCENT = 18`).
   - Calculation: `subtotal + (subtotal * 0.18) = finalAmount`.
2. **Export of Services (International / Outside India / `USD`):**
   - Governed by **Section 2(6)** and **Section 16 of the IGST Act, 2017**.
   - Classified as a **Zero-Rated Supply** (0% GST).
   - Executed under a **Letter of Undertaking (LUT)** filed with the GST department (Form GST RFD-11).
   - Server calculation: `gstPercent = 0`, `gstAmount = 0.00`, `finalAmount = subtotal`.
   - Invoices state: *"SUPPLY MEANT FOR EXPORT OF SERVICES UNDER LETTER OF UNDERTAKING WITHOUT PAYMENT OF INTEGRATED TAX"*.
3. **RBI Purpose Codes:**
   - For foreign inward remittances through Razorpay, export purpose code `P0802` (Software subscriptions / SaaS licenses) is registered in the Razorpay Dashboard (*Settings -> International Payments -> Export Purpose Code*). Razorpay generates monthly Foreign Inward Remittance Statements (FIRS).

### 7.3 Walkie Order Creation, Customer Details & Verification Flow
- **Order Creation (`POST /api/walkie/payment/create-order`):**
  - Accepts `{ planId, purchasedSeats, couponCode }`.
  - Calculates subtotal, discounts, and zero-rated export GST (0%) for foreign currencies.
  - Converts decimal amount to gateway subunits via `paymentMoney.toPaise(amount, "amount", currency)`.
  - Creates order on Razorpay with `amount`, `currency`, `receipt`, and `notes`.
  - Fetches user details and constructs E.164 compliant `customer` object (`name`, `email`, `contact`, `countryCode`).
  - Returns complete contract:
    ```json
    {
      "status": true,
      "message": "Payment order created successfully",
      "data": {
        "payment": { "id": 142, "orderId": "WALKIE_ORD_1731057891234", "status": "pending" },
        "razorpay": { "keyId": "rzp_live_xxxx", "orderId": "order_OG7289ABCxyz", "amount": 599, "currency": "USD" },
        "customer": {
          "name": "John Smith",
          "email": "john@example.com",
          "contact": "+5491112345678",
          "countryCode": "+54"
        },
        "plan": { "id": 5, "name": "Individual Monthly", "planType": "individual", "billingInterval": "monthly", "durationMonths": 1, "currency": "USD" },
        "subscription": { "purchasedSeats": 1 },
        "coupon": { "applied": false, "details": null },
        "pricing": { "subtotal": 5.99, "discountAmount": 0.00, "taxableAmount": 5.99, "gstPercent": 0, "gstAmount": 0.00, "finalAmount": 5.99 }
      }
    }
    ```
- **Payment Verification (`POST /api/walkie/payment/verify`):**
  - Requires `{ paymentId, razorpayOrderId, razorpayPaymentId, razorpaySignature }`.
  - Cryptographically verifies Razorpay HMAC-SHA256 signature against module secret.
  - Fetches payment from Razorpay API to verify currency match (`gatewayPayment.currency === payment.currency`) and exact amount match.
  - Activates subscription period, sets up seat entitlements, and broadcasts socket update over `/groupWalkie`.
- **Seat Assignment (`POST /api/walkie/update-member-subscription`):**
  - Accepts `targetUserIds`, `replaceUserIds`, or `{ action: "remove", removeUserId }`.
