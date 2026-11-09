# Backend Specification: Common Module (Bootstrap, Home Socket, Auth & Core Infrastructure)

> **Document Version:** `v2.0.0`  
> **Backend Architecture:** Node.js, Express, Sequelize ORM (MySQL), Socket.io, Firebase Cloud Messaging, Razorpay  
> **Source Files Covered:**  
> - App Root: `app.js`  
> - Initialization: `controllers/initialize.controller.js`, `services/initialize.service.js`, `repositories/initialize.repository.js`  
> - Home Socket: `sockets/location.socket.js`, `utils/NotificationViewStore.js`, `utils/sessionManager.js`  
> - Auth: `routes/user.router.js`, `controllers/UserController.js`, `models/users.js`  
> - Notification Center: `routes/notification.router.js`, `controllers/notification.controller.js`, `services/push-notification.js`  
> - Banners: `routes/banner.routes.js`, `controllers/banner.controller.js`, `models/banner.js`  
> - Screen Sharing: `routes/screenShare.routes.js`, `sockets/stream_one_to_one_screen_share.socket.js`  
> - Attendance: `routes/attendance.route.js`, `routes/attendancePoll.route.js`, `services/attendanceScheduler.service.js`  
> - Packages: `routes/package.route.js`, `controllers/package.controller.js`

---

## 1. Application Initialization Engine (`GET /api/initialize`)

When a client launches, `initializeService.initialize(userId)` resolves core system state concurrently via `Promise.all`:
1. **Walkie State (`initializeWalkie`):** Evaluates trial expiration, active subscription, days remaining, and active channel preference.
2. **Notification Markers (`repo.getNotificationMarkers`):**
   - `calling`: Checks `hasMissedCalls(userId)` across private and group calls.
   - `chat` / `chatting`: Checks `hasUnreadPrivateMessages(userId)` and `hasUnreadGroupMessages(userId)`.
   - `walkie`: Checks if active channel has ongoing transmission.
3. **Payment Config (`getPublicConfig`):** Returns Razorpay `keyId`, `currency`, and `enabled` flag.

---

## 2. Notification View Store & Invalidation Engine

In `utils/NotificationViewStore.js`:
- In-memory store keeping track of when each user last opened their Call History or Chat List:
  - `callHistoryViewed[userId] = timestamp`
  - `chatListViewed[userId] = timestamp`
- **Instant Invalidation Callback:** When `markCallHistoryViewed` or `markChatListViewed` is triggered, the store automatically invalidates `markerCache` and pushes fresh `notification_markers` over the `/location` socket to all devices logged in under that user.

---

## 3. Session Invalidation & Multi-Device Grace Window

In `utils/sessionManager.js` & `models/users.js`:
- Users possess a `token_version` integer in MySQL.
- Upon new login on Device B:
  - `user.token_version` is incremented.
  - JWT tokens from Device A carry the older `token_version`.
- **Grace Window:** A 15-second grace window allows in-flight background requests to finish without abruptly corrupting writes before forcing disconnection.
- Older sockets connected on `/location` or `/chat` are cleanly disconnected.

---

## 4. Auth & Single 90-Day JWT Architecture

In `controllers/otpChargeAuth.controller.js`, `controllers/UserController.js`, & `services/user.service.js`:
1. **Send OTP (`POST /v2/send-otp`):** 
   - Accepts `{ countryCode, MobileNo, Device_Id, Platform }`.
   - Checks resend limits (3 attempts, 6h block).
   - Domestic Indian numbers (`+91`): Dispatches SMS immediately via MSG91, returns `nextStep: "VERIFY_OTP"`.
   - International numbers (`prefix !== 91`): If `loginCount >= 1`, returns `nextStep: "SHOW_OTP_CHARGE_SCREEN"` with `otpCharge` payment details.
2. **Verify OTP (`POST /v2/verify-otp`):** 
   - Accepts `{ countryCode, MobileNo, otp, Device_Id, Platform, Voip_Device }`.
   - Validates 4-digit OTP.
   - Automatically saves/normalizes `countryCode` (e.g. `+1`, `+91`) and `Voip_Device` (for iOS CallKit ringing) on the `users` record.
   - Disconnects previous sessions on other devices and signs a single 90-day JWT:
     ```javascript
     jwt.sign({ id: user.UserId, tokenVersion: user.token_version }, process.env.JWT_SECRET_KEY, {
       expiresIn: "90d",
     });
     ```
   - Returns `data.token`, `data.userId`, `data.isNewUser`, `data.userName`, `data.profileImage`.
3. **No Refresh Token Endpoint:** Eliminates refresh token race conditions. When the token expires after 90 days or `token_version` mismatches, the server returns standard `401 Unauthorized`.

---

## 5. Unified Push Notification Architecture

In `services/push-notification.js`:
- Unified interface for all modules:
  - `sendCallNotification`: High-priority VoIP data payload (`TTL: 0`).
  - `sendMessageNotification`: Anti-self, foreground-suppressed message payload.
  - `sendWalkieAlertNotification`: High-priority channel alert.
  - `sendAttendancePollNotification`: Voting reminder payload.
- Automatically handles token cleanup for invalid or uninstalled device tokens (`messaging/registration-token-not-registered`).

---

## 6. Zero 404 Image Fallback Interceptor

In `app.js`:
```javascript
app.use(["/uploads", "/public/uploads"], (req, res, next) => {
  const isImageRequest = /\.(jpg|jpeg|png|gif|webp|bmp|svg|ico)$/i.test(req.path);
  if (isImageRequest) {
    const defaultImagePath = path.join(__dirname, "views/assets/img/default-profile.png");
    if (fs.existsSync(defaultImagePath)) {
      res.setHeader("Content-Type", "image/png");
      return res.sendFile(defaultImagePath);
    }
  }
  next();
});
```
This guarantees mobile clients never receive `404 Not Found` for missing user avatars, group icons, or banners.

---

## 7. Attendance Poll Deadline Scheduler

In `services/attendanceScheduler.service.js`:
- Runs an automated background scheduler (`setInterval` every 60 seconds).
- Identifies expired polls, closes voting, tallies final results, and emits `attendance:poll_closed` over the `/attendancePoll` socket.

---

## 8. International & Domestic OTP Charge Payment Gateway (v2 Engine)

> **Source Files Covered:**  
> - Routes: `routes/otpChargeAuth.routes.js`, `routes/otpChargeWebhook.routes.js`, `views/routes/otpChargeAdmin.routes.js`  
> - Controllers: `controllers/otpChargeAuth.controller.js`, `controllers/otpChargeWebhook.controller.js`, `controllers/otpCharge.controller.js`  
> - Services: `services/otpCharge.service.js`, `services/otpResend.service.js`  
> - Models: `models/otpCharge.model.js`, `models/otpChargeLog.model.js`, `models/otpChargePayment.model.js`  
> - Config & Security: `config/razorpay.config.js`, `utils/otpChargeToken.js`, `utils/currencies.js`

### 8.1 Longest-Prefix Country Resolution & Pricing Engine
When any mobile user initiates login via `POST /v2/send-otp` or `POST /v2/resend-otp`:
1. **Normalization:** Mobile number is stripped of non-digit characters (`normalizedMobile`).
2. **Longest-Prefix Match (1–8 digits):** The engine searches the `otp_charges` table for matching prefixes (e.g. `91`, `1`, `44`, `971`, `357`, etc.) ordered by `LENGTH(prefix) DESC`.
3. **Chargeability Decision:**
   - **India (`prefix: 91` & sub-ranges `9160`–`9199`):** Configured as `isChargeable = false` (Free domestic login). Server sends OTP immediately and returns `nextStep: "VERIFY_OTP"`.
   - **International Countries:** Evaluated against `isChargeable = true`. If chargeable and price > 0, the server **does NOT send SMS yet**. Instead, it generates a cryptographically signed HMAC token (`otpChargeToken`) with a **30-minute TTL (1800s)** and returns:
     ```json
     {
       "status": true,
       "message": "OTP charge required",
       "nextStep": "SHOW_OTP_CHARGE_SCREEN",
       "otpCharge": {
         "required": true,
         "amount": 0.50,
         "amountMinor": 50,
         "currency": "USD",
         "country": "United States",
         "prefix": "1",
         "otpChargeToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
         "requestId": "req_173105...",
         "baseAmount": 0.50,
         "gstPercent": 0,
         "gstAmount": 0.00
       },
       "otpResend": { "attemptsRemaining": 3, "maxAttempts": 3 },
       "loginInfo": { "isExistingUser": true, "maskedEmail": "a***@x.com" }
     }
     ```
   - **Token Expiry & Payment Capture Safety:**
     - The `otpChargeToken` has a **30-minute validity** (1800s).
     - **Grace Window:** `verifyOtpChargeToken` provides a 10-minute grace window for slow 3DS2 bank redirects / PayPal captures, so late verifications still succeed.
     - **Asynchronous Webhook Safety:** Even if the client callback times out or the app is closed, Razorpay's asynchronous webhook (`payment.captured` / `order.paid`) does not depend on the token; it matches the order by `razorpayOrderId` and dispatches the OTP automatically.
4. **Audit Ledger Logging:** Every evaluation writes an immutable record to `otp_charge_logs` tracking `hashedMobile`, `prefixMatched`, `countryName`, `price`, `currency`, `loginNumber`, and `paymentStatus`.

### 8.2 Endpoints & Verification Lifecycle
- **Logged-in User Dynamic OTP Rate (`GET /v2/otp-charge/my-rate`):**
  - Requires `Authorization: Bearer <JWT>`.
  - Resolves the OTP charge for the user's registered phone number using `users.countryCode` (same calculation as `/v2/send-otp`).
  - Returns `required: true` with amount, minor units, and 0% GST for international users (e.g. `$0.50` USD), `required: false` with amount `0` for free domestic numbers, or `required: null` if country code is unknown.
- **Gateway Config (`GET /v2/otp-charge/config`):** Returns public gateway configuration specific to the OTP Charge module (mode, live flag, Razorpay keyId, and supported currencies).
- **Create Payment Order (`POST /v2/otp-charge/create-order`):**
  - Requires: `{ "otpChargeToken": "<token>" }`.
  - Verifies token signature and checks 30-minute expiry (1800s).
  - Creates a Razorpay order with `amount` (converted to subunits) and `currency`. When `currency` is set to `USD`, Razorpay automatically enables **PayPal** in addition to international credit/debit cards.
  - Stores a pending payment row in `otp_charge_payments` with `status: "created"`.
  - Returns `orderId`, `amount`, `currency`, `keyId`, and `requestId`.
- **Verify Payment & Dispatch SMS (`POST /v2/otp-charge/payment-success`):**
  - Requires: `{ "razorpayOrderId", "razorpayPaymentId", "razorpaySignature", "otpChargeToken" }`.
  - Verifies Razorpay HMAC signature (`sha256(orderId + "|" + paymentId, secret)`).
  - Updates payment status to `paid` and links `razorpayPaymentId`.
  - **Dispatches International SMS:** Calls SMS provider (MSG91) via `UserService.SendOtp` to deliver the 4-digit OTP.
  - Returns `{ "status": true, "message": "Payment verified and OTP sent", "nextStep": "VERIFY_OTP" }`.
- **Payment Failure Reporting (`POST /v2/otp-charge/payment-failed`):**
  - Records user cancellation or bank decline in `otp_charge_payments` with `failureReason`.
- **Raw Webhook Engine (`POST /api/v2/otp-charge/webhook`):**
  - Receives asynchronous webhook events (`payment.captured`, `order.paid`).
  - Verifies signature using `RAZORPAY_OTP_WEBHOOK_SECRET` (or `RAZORPAY_WEBHOOK_SECRET`).
  - Ensures payments are marked paid even if the user closes their mobile browser during bank redirect.

### 8.3 Legal & Compliance for International OTP Charges
1. **RBI Cross-Border Compliance:** All card transactions via Razorpay comply with RBI PA-CB guidelines. International credit/debit cards are automatically routed through 3DS2 authentication.
2. **GST Invoice Compliance:** For Indian numbers (if charged), 18% GST applies. For international numbers where supply is outside India, standard export exemptions/LUT zero-rating applies.
3. **Fraud & Abuse Protection:** Daily rate-limiting enforced via `models/mobileLoginCounter.model.js` prevents SMS flooding attacks.
