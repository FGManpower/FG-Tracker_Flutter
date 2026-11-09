# Frontend Guide: Common Module (App Load, Home Socket, Auth & Core Systems)

> **Document Version:** `v2.1.0`  
> **Target Framework:** Flutter (Dart)  
> **Scope:** App Bootstrap, Home Socket, Red Dot Navigation Badges, 90-Day JWT & OTP Lifecycle, Side-Menu OTP Charges Rate, Notification Center, Banners, Screen Sharing

---

## 1. App Launch & Initialization Sequence

The Flutter application executes a streamlined launch sequence to hydrate state before rendering the Home screen:

```
[ App Launch / Splash Screen ]
              │
              ├──► 1. Check SharedPreferences (StorageServices) for saved JWT token.
              │       └── If missing: Navigate to OTP Login Screen.
              │
              ├──► 2. Call GET /api/initialize -> Hydrate root application state:
              │       ├── Walkie access, trial days, active channel
              │       ├── Calling missed call flags
              │       ├── Chat unread flags
              │       └── Razorpay public API key
              │
              ├──► 3. Connect to Socket.io /location namespace (Home Socket).
              │       ├── Listen to 'notification_markers' -> Update bottom-nav red dots.
              │       └── Listen to 'group_dashboard_counts' -> Populate Home tiles.
              │
              └──► 4. Navigate to Home Dashboard Screen.
                      (FCM Token is sent as Device_Id on v2/verify-otp during login)
```

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

### 3.4 Handling Session Expiry & Force Logout
The backend uses a single 90-day JWT signed with a `token_version`. If a `401 Unauthorized` response or `force_logout` socket event is encountered:
- Execute `LogoutUser().handleForceLogout()`
- Clears session state from `StorageServices` while preserving `PrefConst.introStatus`
- Disconnects all active sockets (`/dashboard`, `/location`, `/chat`, `/groupWalkie`)
- Redirects user to `Routes.loginScreen`

---

### 3.5 Logged-in User OTP Rate (Side-Menu "OTP Charges" Screen)

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
| v2.1.0 | 2026-11-09 | Production International Payment Gateway verified across both Node.js backend and Flutter frontend; Flutter models updated for decimal plan pricing ($5.99 / $9.99 / $19.99); CurrencyFormat integrated across all payment views; 0% export GST & USD Razorpay orders documented. |
| v2.0.0 | 2026-11-08 | Added GET `v2/otp-charge/my-rate` endpoint for dynamic side-menu rate; updated OTP token lifetime to 30 mins with grace period; verified 4-digit OTP format. |
