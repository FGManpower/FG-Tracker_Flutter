# Frontend Guide: Common Module (App Load, Screen Priority, Auth & Core Systems)

> **Document Version:** `v2.3.1`  
> **Target Framework:** Flutter (Dart)  
> **Scope:** App Bootstrap & Screen Priority Hierarchy, Pre-Navigation Permission Evaluation, Home Socket, Red Dot Navigation Badges, 90-Day JWT & OTP Lifecycle, Side-Menu OTP Charges Rate, Notification Center, Banners, Screen Sharing, "Last seen" format across all modules (§7)

---

## 1. App Launch, Screen Priority & State Machine Hierarchy

The application follows a strict **Screen Priority Hierarchy** on startup and during authentication transitions. No screen is allowed to flash, mount, or transition if its entry conditions are not met.

```
                           [ APP LAUNCH / COLD START ]
                                        │
                                        ▼
                  ┌───────────────────────────────────────────┐
                  │ Priority 0: Native / VoIP / Push Actions  │
                  │ (CallKit, Incoming Call, Walkie-Talkie)   │
                  └─────────────────────┬─────────────────────┘
                                        │ (If no pending VoIP action)
                                        ▼
                  ┌───────────────────────────────────────────┐
                  │ Priority 1: Splash Screen (Routes.Splash) │
                  │  Plays branding animation (InitiateCtrl)  │
                  └─────────────────────┬─────────────────────┘
                                        │
                                        ▼
                  ┌───────────────────────────────────────────┐
                  │ Priority 2: Force Version Update Check    │
                  │   (GET /initialize or /api/app-version)   │
                  └─────────────────────┬─────────────────────┘
                                        ├──► [Blocked: v_app < min_version & force=true]
                                        │       └──► Routes.forceUpdate (Hard Block)
                                        │
                                        ▼ [Version OK]
                  ┌───────────────────────────────────────────┐
                  │ Priority 3: Authentication Gate (JWT/Reg) │
                  │   Checks saved JWT token & isRegistered   │
                  └─────────────────────┬─────────────────────┘
                                        ├──► [Unauthenticated / Logged Out]
                                        │       ├── If intro done  ──► Routes.Login
                                        │       └── If first time  ──► Routes.Intro
                                        │
                                        ▼ [Authenticated & Registered]
                  ┌───────────────────────────────────────────┐
                  │ Priority 4: Compulsory Permission Gate    │
                  │ Location (Always+GPS) & Push Notification │
                  └─────────────────────┬─────────────────────┘
                                        ├──► [Missing Compulsory Permissions]
                                        │       ├── App launch ────► Routes.permissionGate
                                        │       └── New login  ────► Routes.permissionSetup
                                        │
                                        ▼ [All Compulsory Permissions Granted]
                  ┌───────────────────────────────────────────┐
                  │ Priority 5: Home Dashboard Screen         │
                  │   (Routes.Home_Screen / Dashboard)        │
                  │ Connects Socket, LiveStatus, Red-Dot Sync │
                  └───────────────────────────────────────────┘
```

### 1.1 Screen Priority Decision Matrix

| Priority | Screen Name | Route Path | Trigger Condition | Exit / Bypass Rule | When It Must NEVER Open |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | **VoIP / Push Intercept** | `Routes.callScreen`<br>`Routes.groupWalkieScreen` | Incoming VoIP call via CallKit, or Walkie PTT push tap. | User ends call or dismisses walkie transmission. | During normal user-initiated app launch without active VoIP/PTT events. |
| **1** | **Splash Screen** | `Routes.Splash` | Initial route of `GetMaterialApp` on app cold launch. | 4-second animation ends and all lower priority checks complete. | Never opens again after cold launch (cleared with `Get.offAllNamed`). |
| **2** | **Force Update Screen** | `Routes.forceUpdate` | Remote Config / API returns `forceUpdate == true` AND `installedVersion < minVersion`. | User updates app via Play Store / App Store link. | When app version is up-to-date or `forceUpdate == false`. |
| **3** | **Intro Walkthrough** | `Routes.Intro` | Fresh install / `introStatus != true` AND user not logged in. | User swipes through slides and taps "Get Started". | When `introStatus == true` or user is already authenticated. |
| **4** | **Login / OTP Screen** | `Routes.Login`<br>`Routes.OTPScreen` | User is not logged in (`token == null` or `isRegistered != true`). | User enters phone, pays OTP charge (if intl), verifies OTP. | When user is already authenticated with a valid JWT token. |
| **5A**| **Permission Setup (New Login)** | `Routes.permissionSetup` | Brand new user / fresh login AFTER OTP verification **ONLY IF** compulsory permissions are pending. | Once compulsory permissions (Location Always + Notification) are satisfied. | **MUST NEVER OPEN** if compulsory permissions are already granted on the device. |
| **5B**| **Permission Gate (Existing User)** | `Routes.permissionGate` | Existing logged-in user on cold-start or app-resume **ONLY IF** compulsory permissions are revoked. | Auto-unlocks to Home as soon as permission is granted. | **MUST NEVER OPEN** when all compulsory permissions are already satisfied. |
| **6** | **Home Dashboard** | `Routes.Home_Screen` | Version is valid, user is authenticated, and all compulsory permissions are active. | User logs out or permissions are revoked from OS Settings. | When unauthenticated, outdated, or lacking compulsory permissions. |

---

### 1.2 Root Cause Analysis: The Millisecond Screen Flicker Bug

#### The Issue
When opening the app or logging in with all required permissions already granted on the phone, users experienced the Permission Screen (`PermissionSetupScreen` or `PermissionGateScreen`) flashing on the display for 100ms–300ms before suddenly being redirected to `Home_Screen`.

#### Why Was It Happening? (Antipattern: "Navigate First, Evaluate Later")
1. **Unconditional Navigation in Auth Controller**:
   After OTP verification, the code immediately executed:
   ```dart
   Get.offAllNamed(Routes.permissionSetup);
   ```
   without checking whether permissions were already granted on the device.
2. **Asynchronous Evaluation on Screen Mount**:
   The `PermissionSetupScreen` mounted immediately. Because its reactive loading state `checking.value` was initialized to `true`, the widget tree instantly painted the skeleton shimmer UI or cards.
3. **Delayed Redirection**:
   In `PermissionSetupController.onReady()`, `checkAllPermissionStatus()` queried native OS platform channels. Once it confirmed `canContinue == true`, it executed `_goHome()` (`Get.offAllNamed(Routes.Home_Screen)`).
4. **User Perception**:
   The screen was pushed, rendered, and destroyed within ~200ms. This produced an unpolished, unprofessional screen flicker / ghost screen transition.

#### Architectural Fix: The "Evaluate Before Navigate" Rule
To ensure screens that are not part of the active flow never open:
1. **Never mount a route whose exit condition is already met.**
2. **Pre-flight Permission Check**: Evaluate `PermissionGateService.to.check()` **before** initiating navigation.
3. **Direct Routing**:
   - If `permissions.allowsAccess == true` ➔ Navigate directly to `Routes.Home_Screen`.
   - If `permissions.allowsAccess == false` ➔ Navigate to `Routes.permissionSetup` (or `Routes.permissionGate`).

---

## 2. Home Socket & Bottom-Nav Red Dot Markers

### 2.1 Connecting to Home Socket (`/location`)
```dart
void connectHomeSocket(String jwtToken, int userId) {
  homeSocket = IO.io('https://api.fgtracker.com/location', {
    'transports': ['websocket'],
    'auth': { 'token': jwtToken, 'userId': userId },
    'autoConnect': true,
  });

  homeSocket.on('notification_markers', (data) {
    final markers = data['data'];
    // Update reactive navigation badge state:
    badgeController.hasCallingNotification.value = markers['calling'] ?? false;
    badgeController.hasChatNotification.value = markers['chat'] ?? false;
    badgeController.hasWalkieNotification.value = markers['walkie'] ?? false;
  });

  homeSocket.on('group_dashboard_counts', (data) {
    dashboardController.updateCounts(data['data']);
  });
}
```

### 2.2 Clearing Badges Across Devices (`mark-viewed`)
When the user switches to the Calling or Chatting tab, notify the backend to turn off the red dot:
```dart
// Calling Tab selected:
void onCallingTabOpened() {
  homeSocket.emit('call_history_viewed');
  // Or REST fallback: http.post('$baseUrl/api/history/mark-viewed');
}

// Chatting Tab selected:
void onChattingTabOpened() {
  homeSocket.emit('chat_list_viewed');
  // Or REST fallback: http.post('$baseUrl/api/mark-viewed');
}
```

---

## 3. Phone OTP Login & International OTP Charge (v2 Architecture)

### 3.1 Production Endpoints & Routing Contract

Relative to `ConstRes.aBaseUrl` (`.../api/` or root `/`):
- `POST v2/send-otp` (Request OTP)
- `POST v2/resend-otp` (Resend OTP)
- `POST v2/verify-otp` (Verify OTP and receive 90-day JWT token)
- `GET  v2/otp-charge/config` (Module-specific Razorpay configuration)
- `POST v2/otp-charge/create-order` (Initiate Razorpay order)
- `POST v2/otp-charge/payment-success` (Verify payment and dispatch international SMS)
- `POST v2/otp-charge/payment-failed` (Report failure/cancellation)
- `GET  v2/otp-charge/my-rate` (Logged-in user's dynamic OTP charge rate for Side-Menu)

### 3.2 Send OTP Response & State Machine

When a user submits their phone number on the login screen:
```dart
POST v2/send-otp
{
  "MobileNo": "4155552671",
  "countryCode": "+1", // or "+91"
  "Platform": "android"
}
```

The backend evaluates country prefix chargeability and returns one of two flows:

#### Flow A: Domestic / Free (`nextStep: "VERIFY_OTP"`)
SMS is sent immediately. Navigate directly to the OTP verification screen.
```json
{
  "status": true,
  "message": "OTP sent successfully",
  "otpCharge": {
    "required": false,
    "amount": 0,
    "amountMinor": 0,
    "currency": "INR",
    "country": "India",
    "prefix": "91"
  },
  "nextStep": "VERIFY_OTP"
}
```

#### Flow B: International / Chargeable (`nextStep: "SHOW_OTP_CHARGE_SCREEN"`)
SMS is held until payment is completed. Navigate to the OTP Charges Screen. The backend returns dynamic `currency` (e.g. `USD` for international users, which enables PayPal inside Razorpay Checkout) and zero-rated 0% export GST:
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

> [!IMPORTANT]
> **International Tax Labeling on OTP Charge Screen:**
> - For domestic Indian numbers (+91 / INR), the tax breakdown renders `GST (18%)`.
> - For international foreign numbers (e.g. Argentina +54, USA +1 / USD), the breakdown renders `Tax (0% Export)` or `VAT / Tax (X%)`. It **never displays "GST"** to foreign customers.

> **Currency Display on the OTP Charge Screen:**
> The OTP Charge Screen in the Flutter app must display the currency symbol dynamically based on `otpCharge.currency` (e.g. `$` for USD, `€` for EUR, `£` for GBP, `₹` for INR) instead of hardcoding `₹`.
> When initiating Razorpay Checkout, passing `currency: 'USD'` will natively render **PayPal** and international card checkout.

### 3.3 Flutter International OTP Charge Controller Implementation

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class OtpChargesController {
  late Razorpay _razorpay;
  String? _savedOtpChargeToken;
  String? _savedOrderId;
  String? _pendingMobile;

  void init() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleOtpPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleOtpPaymentError);
  }

  void dispose() {
    _razorpay.clear();
  }

  /// 1. Create Gateway Order and Open Razorpay Checkout
  Future<void> proceedWithOtpPayment({
    required String otpChargeToken,
    required String dialCode,
    required String mobileNumber,
    String? unmaskedEmail,
  }) async {
    _savedOtpChargeToken = otpChargeToken;
    _pendingMobile = '$dialCode$mobileNumber';

    // Step A: Create Gateway Order
    final orderRes = await http.post(
      Uri.parse('$baseUrl/v2/otp-charge/create-order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'otpChargeToken': _savedOtpChargeToken}),
    );

    final orderBody = jsonDecode(orderRes.body);
    final orderData = orderBody['data'];
    _savedOrderId = orderData['orderId'];

    // Step B: Launch Razorpay SDK (Supports International Cards & PayPal when currency is USD)
    var options = {
      'key': orderData['keyId'],
      'amount': orderData['amount'], // Minor units (e.g. 50 cents) - NEVER multiply by 100
      'name': 'FG-Tracker Login',
      'description': 'International SMS Verification Fee',
      'order_id': orderData['orderId'],
      'currency': orderData['currency'] ?? 'USD', // USD automatically enables PayPal
      'prefill': {
        'contact': _pendingMobile, // E.164 phone format
        if (unmaskedEmail != null && unmaskedEmail.isNotEmpty) 'email': unmaskedEmail,
      },
      'notes': {
        'purpose': 'otp_charge',
        'requestId': orderData['requestId'],
      }
    };

    _razorpay.open(options);
  }

  /// 2. Payment Success: Verify with backend & trigger SMS dispatch
  Future<void> _handleOtpPaymentSuccess(PaymentSuccessResponse response) async {
    final verifyRes = await http.post(
      Uri.parse('$baseUrl/v2/otp-charge/payment-success'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'razorpayOrderId': response.orderId,
        'razorpayPaymentId': response.paymentId,
        'razorpaySignature': response.signature,
        'otpChargeToken': _savedOtpChargeToken,
      }),
    );

    final verifyData = jsonDecode(verifyRes.body);
    if (verifyData['status'] == true && verifyData['nextStep'] == 'VERIFY_OTP') {
      // Payment verified & SMS sent! Navigate to OTP verify screen
      navigateToOtpVerifyScreen();
    }
  }

  /// 3. Payment Failed / Cancelled: Send the SAVED order ID
  void _handleOtpPaymentError(PaymentFailureResponse response) {
    if (_savedOrderId != null) {
      http.post(
        Uri.parse('$baseUrl/v2/otp-charge/payment-failed'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'razorpayOrderId': _savedOrderId, // Saved order ID, NOT response.message
          'failureReason': response.message ?? 'Payment cancelled by user',
        }),
      );
    }
  }

  /// 4. Final OTP Verification (Receives JWT in data.token, persists Voip_Device for iOS CallKit)
  Future<void> verifyOtp({
    required String countryCode,
    required String mobileNo,
    required String otp,
    required String deviceId,
    required String platform,
    String? voipDevice, // Saved in DB for iOS CallKit APNs ringing
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/v2/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'countryCode': countryCode,
        'MobileNo': mobileNo,
        'otp': otp,
        'Device_Id': deviceId,
        'Platform': platform,
        if (voipDevice != null && voipDevice.isNotEmpty) 'Voip_Device': voipDevice,
      }),
    );

    final response = jsonDecode(res.body);
    if (response['status'] == true && response['data']?['token'] != null) {
      final String jwtToken = response['data']['token']; // Token is in data.token
      await StorageServices().setString(PrefConst.STORAGE_USER_TOKEN_KEY, jwtToken);
      navigateToHomeScreen();
    }
  }
}
```

### 3.4 Pay Button State Machine & Enablement Conditions (OTP Charges Screen)

The **Pay** button on `Routes.OTP_CHARGES` is governed by a strict client-server condition chain to guarantee that only valid, enabled payment sessions can initiate checkout:

| Condition Parameter | Source | Description / Rule | If Condition Fails |
|---|---|---|---|
| **`canPay`** | Navigation Arguments (`otpChargeToken`) | `true` if `otpChargeToken != null && otpChargeToken.isNotEmpty`. Issued when entering from Login flow. | Button is completely hidden (`SizedBox.shrink()`). Used when screen is opened from Side-Menu info rate. |
| **`isLoading`** | Local Controller State (`RxBool`) | `true` during active REST API order creation or verification attempts. | Button shows centered CircularProgressIndicator; duplicate taps blocked. |
| **`isPaymentEnabled`** | `GET /v2/otp-charge/config` -> `data.isPaymentEnabled` | Evaluates backend master payment switches: `process.env.PAYMENT_ENABLED` and `system_settings` table in MySQL (`PAYMENT_ENABLED`). | Displays prominent red alert banner: *"OTP payments are temporarily paused by administrator"*. Button shows *"Payment Paused"* and clicking pops up explanatory alert dialog. |
| **`_tokenExpired`** | 25-minute client timer (`_tokenLifetime`) | Backend JWT token has 30-min validity. Controller times it out locally after 25 mins. | Shows session expired dialog and redirects user back to login screen. |

#### Backend Master Switches (Troubleshooting Disabled Pay Button):
1. **Server `.env`**: Ensure `PAYMENT_ENABLED=true` is present in the backend `.env`.
2. **Database Table `system_settings`**: Ensure the row where `key = 'PAYMENT_ENABLED'` has `status = true` (or `1`) and `value = 'true'`.
3. **Gateway Output**: Check `GET /api/v2/otp-charge/config` — the payload `data.isPaymentEnabled` must be `true` for checkout to be activated.

---

### 3.5 Handling Session Expiry & Force Logout
The backend uses a single 90-day JWT signed with a `token_version`. If a `401 Unauthorized` response or `force_logout` socket event is encountered:
- Execute `LogoutUser().handleForceLogout()`
- Clears session state from `StorageServices` while preserving `PrefConst.introStatus`
- Disconnects all active sockets (`/dashboard`, `/location`, `/chat`, `/groupWalkie`)
- Redirects user to `Routes.loginScreen`

---

### 3.6 Logged-in User OTP Rate (Side-Menu "OTP Charges" Screen)

Endpoint: `GET v2/otp-charge/my-rate`  
Headers: `Authorization: Bearer <JWT>`  
Request Body: None

This endpoint resolves the OTP rate for the authenticated user's own phone number based on `users.countryCode` (using the exact same calculation as `/v2/send-otp`).

#### Response Scenarios:

1. **International User (e.g. US user, $0.50, 0% export GST):**
   ```json
   {
     "status": true,
     "data": {
       "required": true,
       "country": "United States",
       "prefix": "1",
       "currency": "USD",
       "amount": 0.50,
       "amountMinor": 50,
       "baseAmount": 0.50,
       "gstPercent": 0,
       "gstAmount": 0.00
     }
   }
   ```
   *Action in App:* Displays the exact dynamic price and currency (`$0.50`, 0% GST).

2. **Domestic Indian User (Free SMS):**
   ```json
   {
     "status": true,
     "data": {
       "required": false,
       "country": "India",
       "prefix": "91",
       "currency": "INR",
       "amount": 0,
       "amountMinor": 0,
       "baseAmount": 0,
       "gstPercent": 0,
       "gstAmount": 0
     }
   }
   ```
   *Action in App:* Displays "OTP is free for your number".

3. **Older User Without Stored Country Code:**
   ```json
   {
     "status": true,
     "data": {
       "required": null,
       "country": null,
       "prefix": null,
       "currency": null,
       "amount": null,
       "amountMinor": null,
       "baseAmount": null,
       "gstPercent": null,
       "gstAmount": null
     }
   }
   ```
   *Action in App:* Displays general informational message instead of a price.

---

## 4. Notification Center Screen

Displays in-app alert notifications with read/unread statuses:
- **Fetch List:** `GET /api/getNotifications?page=1&limit=20`
- **Unread Count:** `GET /api/getUnreadCount` (displays on notification bell icon).
- **Mark Single Read:** `PUT /api/markAsRead/:id`
- **Mark All Read:** `PUT /api/markAllAsRead`
- **Clear All:** `DELETE /api/clear-all-notifications`

---

## 5. Dynamic App Banners & Screen Sharing

### 5.1 Banner Carousel
- Fetch active banners: `GET /api/banners`.
- Render using `carousel_slider`.
- When tapping banner with `action_type: "deep_link"`, parse `action_url` (e.g. `fgtracker://walkie/channels`) to navigate to the target screen.

### 5.2 One-to-One Screen Sharing (Calling Socket Signaling)

Screen sharing is initiated and controlled over the calling socket connection:

- **Start Screen Sharing:**
  - Client emits `start_screen_share` (or `start_one_to_one_screen_share`) with `{ callId, remoteUserId }`.
  - Server confirms with `screen_share_started` acknowledgment to sharer and notifies peer.
  - WebRTC screen track is captured via `flutter_webrtc`'s `navigator.mediaDevices.getDisplayMedia()`.
- **Signaling Renegotiation Events:**
  - Client emits `screen_share_offer` `{ callId, targetUserId, sdp }` ──► Peer receives `screen_share_offer`.
  - Peer emits `screen_share_answer` `{ callId, targetUserId, sdp }` ──► Sharer receives `screen_share_answer`.
  - Both peers exchange ICE candidates: `screen_share_ice` `{ callId, targetUserId, candidate }`.
- **Stop Screen Sharing:**
  - Client emits `stop_screen_share` `{ callId, remoteUserId }`.
  - Server broadcasts `screen_share_stopped` to both participants.


---

## 6. International Payment Architecture & Changelog

### 6.1 Architecture Summary
- **Login OTP Charges & Walkie Plans**: Both modules fully support dynamic currency (India = INR ₹, International = USD $).
- **Payment Gateway**: Razorpay receives native currency and minor units (cents / paise). For USD, PayPal and international cards are automatically enabled.
- **Taxation (GST)**: International transactions are zero-rated (0% GST) under Section 16 of the IGST Act with Letter of Undertaking (LUT Form GST RFD-11). Domestic Indian transactions are charged 18% GST.
- **Razorpay Sandbox Simulator Note**: In Razorpay Test Mode, the mock card simulator uses a default pre-auth authorization hold of USD 1.00 for card testing; production live mode charges the exact order amount ($0.50 USD).

### 6.2 Change Log
| Version | Date | Description |
|---|---|---|
| v2.3.1 | 2026-11-12 | §7.7 Private Mode add-on: audit P1–P5, what the string API does to every last-seen place (crash risk in Group Members, false "Offline" / "Just now"), backend request for ISO `lastSeenAt` / `privateModeStartedAt`, interim rule. D2 answered (strings, not ISO). Test cases LS-17–LS-25. **Audit only — no code changed yet.** |
| v2.3.0 | 2026-11-12 | §7 "Last seen" in one format across the app: target format, audit of all 13 places (branch `multi-language`), findings, open decisions, build plan and manual test cases. **Audit only — no code changed yet.** |
| v2.2.0 | 2026-11-10 | Documented App Launch & Screen Priority State Machine; added root cause analysis & architectural resolution for millisecond permission screen flicker; established 'Evaluate-Before-Navigate' rule across Auth and Splash workflows. |
| v2.1.0 | 2026-11-09 | Production International Payment Gateway verified across both Node.js backend and Flutter frontend; Flutter models updated for decimal plan pricing ($5.99 / $9.99 / $19.99); CurrencyFormat integrated across all payment views; 0% export GST & USD Razorpay orders documented. |
| v2.0.0 | 2026-11-08 | Added GET `v2/otp-charge/my-rate` endpoint for dynamic side-menu rate; updated OTP token lifetime to 30 mins with grace period; verified 4-digit OTP format. |

---

## 7. "Last seen": one format across the app

> **Status (2026-11-12):** audit done on branch `multi-language`. **No code changed yet** — waiting for the decisions in §7.4. Frontend only; no backend change.

### 7.1 Target format
Reference: Walkie-Talkie → Group Info → Group Members.

| When (phone's local day) | Text (English) | Pattern |
|---|---|---|
| Today | `Last seen: Today, 12:40 AM` | `Today, ` + `hh:mm a` |
| Earlier this year (yesterday too) | `Last seen: 09 Nov, 11:15 PM` | `dd MMM, hh:mm a` |
| Earlier year | `Last seen: 09 Nov 2025, 11:15 PM` | `dd MMM yyyy, hh:mm a` |

Rules:
- 12-hour clock, 2-digit hour and day, AM / PM in capitals.
- Server UTC is converted to the phone's local time; "Today" is the phone's calendar day.
- A time slightly in the future counts as now.
- "Online", "In Walkie Channel", "typing…" stay as they are. No value → the screen keeps what it shows today.
- **Languages:** "Last seen:" and "Today" come from the ARB files (all 10 languages); month names and AM / PM follow the app language via `appDateFormat` (digits stay 0–9).

### 7.2 Where "last seen" is shown today (audit)

| # | Screen | File : line | Today (English) |
|---|---|---|---|
| 1 | Private chat app bar | `Messages/Controller/MessageController.dart:1851` → `Views/Chat_Screen.dart:567` | `5 min ago` / `Yesterday` / `12 Nov 2026` (`appRelativeTime`), **no prefix**; raw text if not parseable |
| 2 | User profile (from chat) | `Messages/Views/UserProfileScreen.dart:130` | `5 min ago` / `3 days ago` (`getTimeAgo`), **no prefix** |
| 3 | Quick-profile popup (avatar tap, any screen) | `Core/values/Dialog/DialogBox.dart:1158` | `Last seen: 5 min ago` |
| 4 | Chat Group Info — members | `Messages/Views/Group/ChatGroupProfile_Screen.dart:140` | `5 min ago`, **no prefix**; text → "Offline" |
| 5 | Group Members screen (both lists) | `Group/Views/MemberScreen.dart:549`, `:821` → `Core/util/DateTime_Format.dart` `formatTime` | `hh:mm a` only — **no date, no prefix**; `DateTime.parse` throws on non-ISO text |
| 6 | Walkie-Talkie Group Info (reference) | `Walkie-talkie/widgets/group_info_bottom_sheet.dart:399` | timestamp → `Last seen 5 min ago` (no colon on this branch); text → `Last seen <raw backend text>` |
| 7 | Home › Online members | `home/Views/LiveStatus/components/online_member.dart:714` | `Last seen 5 min ago` |
| 8 | Home › Total members | `home/Views/LiveStatus/components/total_member.dart:558` | `5 min ago`, **no prefix** |
| 9 | (shared by 7 and 8) | `Model/group_member_model.dart:1699` `formattedLastSeen` | builds the "x ago" text |
| 10 | Tracking › member card | `Track/Views/Tracking_screen.dart:3090` | `Last seen: 5 min ago` |
| 11 | Group members bottom sheet | `Core/values/BottomSheets/BottomSheetUi.dart:392` | `Last seen: 5 min ago` |
| 12 | Tracking › Search members | `Track/Views/Search_Members.dart:103` | `5 min ago`, **no prefix** |
| 13 | Tracking › map cluster sheet | `Track/Controller/GroupTrackController.dart:1133` (`_showClusterMembersSheet`) | `5 min ago`; "Online" / "Offline" hard-coded English — ⚠️ **protected file (AGENTS.md)** |

Checked, **not** a real last-seen value: Safe Zone / Route (hard-coded sample rows "2 min ago"), side menu (online dot only), Attendance, Calling, Profile (none), `logoutuser.dart` (protected; sets the value, never shows it).

ARB today: four different keys — `groupDialog_lastSeen` / `track_lastSeen` ("Last seen: {time}") and `home_lastSeen` / `walkie_lastSeen` ("Last seen {time}", no colon).

### 7.3 Findings
1. **The reference format comes from the backend, not the app.** The colon in the reference screenshot is printed only by Walkie's fallback when `lastSeen` is **not** a date — so `/getMembers` sent ready-made English text ("Today, 12:40 AM"). Such text cannot be converted from UTC or translated. But #5 runs `DateTime.parse` on the same field and would throw on it → the payload may differ per API or changed recently. **Needs a sample `/getMembers` response.**
2. Today nothing refreshes the private chat header's last seen from the socket (only online / offline); it is set when history loads. "Refresh as today" = same behaviour.
3. #5 shows only a time with no date — a member last seen days ago looks like today.

### 7.4 Open decisions (owner: product / Flutter lead)
| # | Decision | Recommendation |
|---|---|---|
| D1 | Change #13 inside the protected `GroupTrackController.dart` (one text expression in `_showClusterMembersSheet`, not a listed protected function)? | Only with explicit OK; otherwise left out |
| D2 | What does each API send in `lastSeen` (ISO / epoch / ready text)? | **Answered 2026-11-12:** confirmed in logs — `lastSeen` and `privateModeStartedAt` arrive as **ready-made strings** ("Today, 12:49 AM", "28 Oct, 02:01 PM"), not ISO. See §7.7 for the backend request and the interim rule |
| D3 | Add the "Last seen: " prefix to #1, #2, #4, #5, #8, #12 (they have none today) | Yes — one format everywhere |
| D4 | Helper path (`lib/core/utils/` does not exist) | `lib/app/Core/util/last_seen_formatter.dart` |
| D5 | Docs | This section (one guide per module); screenshots under `build/`, not `docs/` |
| D6 | Branch | `multi-language` (has large uncommitted l10n work) — confirm |

### 7.5 Build plan (after the decisions)
- **One helper:** `String? formatLastSeen(BuildContext context, DateTime? serverTime, {DateTime? now})` → `"Last seen: Today, 12:40 AM"` etc.; `null` when there is no time, so each screen keeps its current fallback.
- **ARB (all 10 languages):** `common_lastSeenAt` = "Last seen: {time}", `common_todayAt` = "Today, {time}". Month / AM-PM via `appDateFormat('dd MMM, hh:mm a')` / `('dd MMM yyyy, hh:mm a')`.
- **Each place:** replace only the expression that builds the last-seen text — same widget, style and position. Parsing stays `Tracking.parseDateTime` (ISO + epoch, UTC → local).
- **Unit tests (fixed "now"):** today, yesterday (shows the date), older date, last year, UTC → IST, null, future time, Hindi locale.
- `flutter analyze`: no new issues; existing tests pass.

### 7.6 Manual test cases (Android + iOS)
Set the phone to IST, app language English unless stated.

| TC | Where | Steps | Expected | Android | iOS |
|---|---|---|---|---|---|
| LS-01 | Walkie › Group Info | Member last seen earlier today | `Last seen: Today, 12:40 AM` | | |
| LS-02 | Walkie › Group Info | Member last seen yesterday | `Last seen: 11 Nov, 11:15 PM` (date, not "Yesterday") | | |
| LS-03 | Walkie › Group Info | Member last seen in 2025 | `Last seen: 09 Nov 2025, 11:15 PM` | | |
| LS-04 | Walkie › Group Info | Member in the channel / online | `In Walkie Channel` / `Active` unchanged | | |
| LS-05 | Private chat app bar | Open a chat with an offline user | `Last seen: …` in the new format; typing / Online unchanged | | |
| LS-06 | User profile (from chat) | Open an offline user's profile | New format | | |
| LS-07 | Quick-profile popup | Tap an offline member's avatar | New format | | |
| LS-08 | Chat Group Info › members | Open group info | Offline members in the new format | | |
| LS-09 | Group Members screen | Open a group from Home | Both lists show date + time in the new format | | |
| LS-10 | Home › Online / Total members | Open both lists | New format; online members unchanged | | |
| LS-11 | Tracking › member card / Search / cluster sheet | Open each | New format (cluster sheet only if D1 = yes) | | |
| LS-12 | Group members bottom sheet | Open it | New format | | |
| LS-13 | Any | Member with no last-seen value | Same text as before (Offline / blank) | | |
| LS-14 | Any | Change app language to हिन्दी | Translated "Last seen" / "Today", Hindi month, digits 0–9 | | |
| LS-15 | Any | Phone clock a few minutes behind the server | Shows today's time, no negative / odd value | | |
| LS-16 | Regression | Chat, Walkie PTT, Tracking map, Home | Unchanged apart from the text | | |
| LS-17 | Home › Private Mode › Active sessions | Member private since today | `Private since: Today, 12:49 AM` | | |
| LS-18 | Home › Private Mode › Active sessions | Member private since an older date / last year | `Private since: 28 Oct, 02:01 PM` / `… 28 Oct 2025, 02:01 PM` | | |
| LS-19 | Private member → quick-profile popup | Tap a private member | Last seen in the new format | | |
| LS-20 | Tracking › member card / members sheet | Private member (badge "Private") | Badge unchanged; last seen in the new format | | |
| LS-21 | Any | Online member | Online / Active unchanged | | |
| LS-22 | Any | No last seen / no private-since value | Same as before (Offline / Just now) | | |
| LS-23 | Any | App in हिन्दी | Translated labels, Hindi month, digits 0–9 (only once the backend sends ISO) | | |
| LS-24 | Any | Phone in a non-IST time zone (e.g. Dubai) | Local time of the phone (only once the backend sends ISO; until then the server string is shown as is) | | |
| LS-25 | Group Members screen, Search members, Chat Group Info | **Old API (string only)** | **No crash, no "Invalid date", no wrong "Offline"** — server string shown as is | | |

### 7.7 Private Mode add-on (audit 2026-11-12)

**Where Private Mode shows a time**

| # | Screen | File : line | Shows today (string API) |
|---|---|---|---|
| P1 | Home › Private Mode › Active sessions (`/all-group-members?filter=private`) | `home/Views/LiveStatus/components/ghost_member.dart:536` → `Model/group_member_model.dart:1679` `formattedStartedAt` | `Started at Today, 12:49 AM` (the string can't be parsed → shown raw inside `home_startedAt`) |
| P2 | Private member → quick-profile popup | `ghost_member.dart:404` → `Core/values/Dialog/DialogBox.dart:1158` (§7.2 #3) | `Last seen: Today, 12:49 AM` (raw string) |
| P3 | Tracking › member card / members sheet (private member, "Private" badge) | §7.2 #10 / #11 | `Last seen: Today, 12:49 AM` (raw string) |
| P4 | Tracking › map cluster sheet ("Private" badge) | §7.2 #13 — ⚠️ protected file | `getTimeAgo(now)` → **"Just now"** for every string value (wrong) |
| P5 | Home › Private count tile | `home/Views/LiveStatus/StatsGrid.dart` | count only — no time |

The data comes from `LiveStatus_controller.getPrivateMembers` (**protected**, not changed); only the model getter and the view text are in scope.

**What the string API does to each place today**

| Place | Result with "Today, 12:49 AM" |
|---|---|
| Walkie Group Info (#6) | `Last seen Today, 12:49 AM` (no colon) |
| Tracking card / members sheet / popup (#3, #10, #11) | `Last seen: Today, 12:49 AM` ✅ |
| Private chat app bar (#1) | `Today, 12:49 AM` (no prefix). `DateTime.parse` throws a **FormatException** — it is already caught and falls back to the raw string; only a log line, no crash |
| User profile (#2), Home lists (#7, #8) | raw string (with / without prefix) |
| Chat Group Info (#4), Search members (#12) | ❌ **"Offline"** — the parse fails and the real value is hidden |
| Group Members screen (#5, `MemberScreen.dart:549` and `:830`) | ❌ **`formatTime` → `DateTime.parse` throws with no catch → the row fails to build (red/grey error box)** |
| Map cluster sheet (#13) | ❌ "Just now" |
| Private since (P1) | `Started at Today, 12:49 AM` |

**Backend request (needed before the §7.1 format, time-zone and language rules can work)**
> Add ISO 8601 **UTC** fields next to the existing strings (keep the old string fields for older app versions):
> - `lastSeenAt` and `privateModeStartedAt` (ISO, e.g. `"2026-11-11T19:19:00Z"`) — or, if `privateModeStartedAt` must stay the string, `privateModeStartedAtUtc`.
> - In: `/all-group-members` (all filters), `/getMembers`, `/chat-list`, `/private-chat/:id/messages` (peer), `/chat/profile-details` members, and the socket `userStatus` / joined events.

**Interim rule until the backend adds them (Step 2.2)**
- Show the server string as it is, with **no parsing that can fail** (no crash, no "Invalid date", no false "Offline" / "Just now").
- Labels from ARB (all 10 languages): `Last seen: {time}`, `Private since: {time}`.
- When an ISO field is present → `formatLastSeen` (§7.5) for both.
- Online / live states unchanged.
