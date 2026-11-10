# Frontend Guide: Common Module (App Load, Screen Priority, Auth & Core Systems)

> **Document Version:** `v2.2.0`  
> **Target Framework:** Flutter (Dart)  
> **Scope:** App Bootstrap & Screen Priority Hierarchy, Pre-Navigation Permission Evaluation, Home Socket, Red Dot Navigation Badges, 90-Day JWT & OTP Lifecycle, Side-Menu OTP Charges Rate, Notification Center, Banners, Screen Sharing

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
| v2.2.0 | 2026-11-10 | Documented App Launch & Screen Priority State Machine; added root cause analysis & architectural resolution for millisecond permission screen flicker; established 'Evaluate-Before-Navigate' rule across Auth and Splash workflows. |
| v2.1.0 | 2026-11-09 | Production International Payment Gateway verified across both Node.js backend and Flutter frontend; Flutter models updated for decimal plan pricing ($5.99 / $9.99 / $19.99); CurrencyFormat integrated across all payment views; 0% export GST & USD Razorpay orders documented. |
| v2.0.0 | 2026-11-08 | Added GET `v2/otp-charge/my-rate` endpoint for dynamic side-menu rate; updated OTP token lifetime to 30 mins with grace period; verified 4-digit OTP format. |
