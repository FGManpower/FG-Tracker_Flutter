# Frontend Guide: Common Module (App Load, Screen Priority, Auth & Core Systems)

> **Document Version:** `v2.5.8`  
> **Target Framework:** Flutter (Dart)  
> **Scope:** App Bootstrap & Screen Priority Hierarchy, Pre-Navigation Permission Evaluation, Home Socket, Red Dot Navigation Badges, 90-Day JWT & OTP Lifecycle, Side-Menu OTP Charges Rate, Notification Center, Banners, Screen Sharing, "Last seen" format across all modules (§7), Real-time Location Tracking & Socket Synchronization Architecture (§8), Side Menu: Legal / Language / Share App / Social Links (§9), Custom Banner + Crop + permissions (§5.1.1), One back button & app bar style (§10), Company contact details (§11), Side Menu Refactor & Contact Us Bottom Sheet (§12), Build & Assets Cleanup (§14), System Share Sheet, Native Share Intake & Share App (§16)

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

### 1.3 "Home opens twice" after login (v2.5.5, 2026-11-18)

#### The Issue
After logging in with Location + Notification already granted, Home opened, then briefly the Permission Gate, then Home again.

#### Root Cause (code path; not yet reproduced with a log)
1. `PermissionGateService._doCheck()` gives up after 3 s and returns `PermissionGateResult.error(...)`. An error result has `allowsAccess == false`.
2. Right after login the phone is busy (sockets start, the OTP keyboard closes, a system dialog ends) and an app-resume event fires. The resume check could time out (seen in a device log: `[PermissionGate] snapshot failed: TimeoutException after 0:00:03`).
3. The resume handler treated that error like a **revoked** permission: `Get.offAllNamed(Routes.permissionGate)`.
4. The gate checked again, found everything granted and called `Get.offAllNamed(Routes.Home_Screen)` → **Home a second time**. The route middleware (`shouldBlockRoute`) had the same problem with a cached error.

#### Fix (`permission_gate_service.dart`)
- An error is "unknown", not "revoked". On resume a failed check is retried once (after 1.5 s); if it fails again the user stays where they are. Only a real result (e.g. location set to "Never" in Settings) blocks.
- `shouldBlockRoute` never redirects on a cached error result.
- Unchanged: the gate still opens at once when a permission is really missing; the login pre-flight (`OtpController`, protected) is untouched.

Tests: `test/permission_gate_service_test.dart` PG-R1 … PG-R4.

**If it still happens:** send a log from the login. A second possible path is a second OTP verify (button tap after auto-submit), which would need a change in the protected `OtpController`; it was not changed.

---

## 2. Home Sockets, Dashboard Counts & Bottom-Nav Red Dot Markers

### 2.1 Home Dashboard Socket (`/dashboard`) & Cache Synchronization
The Home Screen initializes `SocketDashboardService.instance.init()` connecting to the `/dashboard` namespace on app cold start and resume:
1. **Emit Event:** `get_group_dashboard_counts` (`{ userId }`)
2. **Listen Event:** `group_dashboard_counts`
3. **Local Cache (`GroupCountService`):**
   - Counts (`totalGroups`, `totalMembers`, `activeMembers`, `locationDisabledMembers`) are cached locally in `SharedPreferences` under key `cached_group_dashboard_counts`.
   - On app launch, `GroupCountService.instance.loadFromCache()` renders immediate numbers to prevent UI delay/skeletons.
   - When the live socket update arrives, `updateFromSocket(payload)` overwrites the cache with fresh values.
4. **Active Members Freshness Rule:**
   - Active members are computed by the backend based on live in-memory presence (`OnlineUserStore.isOnline`) OR a database fallback requiring `lastSeen >= (now - 2 minutes)`.
   - Inactive background devices no longer inflate the active members count.

### 2.2 Connecting to Notification Markers Socket (`/location`)
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
    GroupCountService.instance.updateFromSocket(data['data']);
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

### 5.1 Banner Carousel & Slider Animation Engine (v2.5.7)
- **API Fetch & Cache Hydration:**
  - Active promotional banners: `GET /api/banners`.
  - App Cache: Hydrated from `AppCache.banners` immediately on cold start while API request completes in the background (`10s` timeout).
  - Shimmer Skeleton: `HomeController.isLoadingBanners` is initialized to `true.obs`, rendering a shimmer skeleton when `bannerList.isEmpty`, preventing blank screen flashes.
- **Infinite Bi-Directional Carousel Architecture:**
  - Implemented using Flutter's native `PageView.builder` with `itemCount: count > 1 ? null : count`.
  - **Left-Slide / Backward Scroll Fix on First Load:**
    - Flutter's `PageView` strictly clamps at page index `0` and cannot scroll into negative indices.
    - If initialized with `initialPage: 0` (e.g. before banners load from cache/API), swiping left (backward) is completely blocked.
    - Fixed by assigning a dynamic widget key: `key: ValueKey('banner_slider_${controller.bannerList.length}')`.
    - `_initialPageFactor = 1000`: When banners load, `initialPage` is initialized at `count * _initialPageFactor` (e.g. `6 * 1000 = 6000`), allowing thousands of seamless swipes in both left and right directions immediately on first load.
    - `didUpdateWidget` re-centers `_pageController` to `(_totalSlides * _initialPageFactor) + (_currentIndex % _totalSlides)` whenever the banner count changes.
- **User Gesture & Touch-Aware Autoplay Engine:**
  - Autoplay runs on a periodic timer (`3800ms` interval, `700ms` `Curves.easeInOut` transition).
  - Wrapped inside `Listener` (`onPointerDown`, `onPointerUp`, `onPointerCancel`) and `NotificationListener<ScrollNotification>` (`ScrollStartNotification`, `ScrollEndNotification`).
  - As soon as the user touches or drags a banner, autoplay is instantly paused (`_isUserInteracting = true; _stopAutoPlay();`).
  - When the user releases the banner, autoplay resumes smoothly after the timer interval. This prevents automated page flips from fighting with user swipes.
- **Deep Linking:** When tapping an API banner with `action_type: "deep_link"`, parses `action_url` (e.g. `fgtracker://walkie/channels`) to navigate to the target screen.

### 5.1.1 Custom (local) banner — v2.5.0
The last slide of the Home carousel is the user's own banner. It is stored **only on the phone** (`LocalBannerService`, pref `local_custom_banner_path`, file in app documents); nothing is uploaded. Files: `lib/app/modules/home/Home_Widget/bannerUi.dart`, `lib/app/Data/Services/local_banner_service.dart`.

| State | What the user sees | Tap |
|---|---|---|
| No banner yet | "Custom Banner · NEW" upload card | Opens **Select Banner Photo** |
| Banner set | The photo, "My Banner" badge, ✏ button | Opens **Manage Custom Banner** |

- **Select Banner Photo sheet:** white, top radius 24, handle; header (icon, title, "Shown only on your phone"); **only when a banner is already set** (Replace), the current banner in the banner shape (key `banner_current_preview`) — with no banner there is no preview box; two cards side by side: **Gallery** and **Camera**. Keys `banner_pick_gallery`, `banner_pick_camera`.
- **Crop:** after a photo is picked (gallery **or** camera), `image_cropper` opens **locked to the banner's aspect ratio** (`LocalBannerService.cropToBanner`). Android: dark-blue toolbar, title "Crop Image" (`imagePicker_cropTitle`), ratio locked. iOS: ratio lock on, ratio picker hidden. Cancelling the crop keeps the current banner.
- **Camera → crop without Home in between (v2.5.1):** camera / gallery and the cropper are separate native screens (Android: camera app + `UCropActivity`; iOS: picker + TOCropViewController). Between them the app resumes on Home while the photo is resized. Before, Home's resume handler also ran `PermissionGuard.checkAndRequestAllPermissions(autoFetchLocation: true)` at that moment, so Home showed for a while before the crop screen. Now:
  - `LocalBannerService.pickInProgress` (`ValueNotifier<bool>`) is true from opening the camera / gallery until the cropped photo is saved or cancelled.
  - `HomeScreen.didChangeAppLifecycleState` skips the permission / location check while it is true and runs it **once** when it turns false (`_onBannerPickChanged`), so the check still happens.
  - `_pickBanner` shows a dim full-screen spinner (`DialogRoute`, not dismissible, back blocked) for the whole flow and removes exactly that route at the end (`removeRoute`), so the gap shows a loader, not Home.
  - Same Dart code on Android and iOS. Not unit-testable (native camera / cropper screens): check on both phones: Home ▸ banner ▸ Camera ▸ take photo ▸ ✓ → crop screen opens next (only the spinner in between) ▸ crop ✓ → banner updated. Also: cancel in the camera, cancel in the cropper (spinner goes, old banner kept), and the Gallery path.
- **Camera / photo permission (v2.5.2, updated v2.5.6):** before, a missing camera permission made the Camera card do nothing (Android declares `CAMERA`, so the camera intent fails with `camera_access_denied`, and the error was swallowed). Now `_pickBanner` asks first (`_sourceAllowed`):

  | Source | Android | iOS |
  |---|---|---|
  | Camera | `Permission.camera` (runtime popup) | `Permission.camera` (`NSCameraUsageDescription`, Podfile `PERMISSION_CAMERA=1`) |
  | Gallery | **Android 13+ (SDK ≥ 33)**: `Permission.photos` (`READ_MEDIA_IMAGES`, `READ_MEDIA_VISUAL_USER_SELECTED`).<br>**Android ≤ 12**: `Permission.storage` (`READ_EXTERNAL_STORAGE` `maxSdkVersion="32"`).<br>Proper WhatsApp-like explanation dialog on Deny ("Not now" / "Allow") and direct Settings dialog on permanent refusal. | `Permission.photos` (`NSPhotoLibraryUsageDescription`, `PERMISSION_PHOTOS=1`); "Limited" and "Granted" both count as allowed. |

  - **Android & iOS Gallery Freeze Fix (v2.5.6):** Removed the blocking modal `_showPhotoLoader()` overlay before `pickImage` that caused the screen to freeze or go blank during native gallery transitions on Android.
  - **Banner Persistence Fix across Updates & Reboots (v2.5.6):** Stored using a fixed relative filename `local_custom_banner.jpg` dynamically resolved via `getApplicationDocumentsDirectory()`, ensuring the banner never disappears across app updates, device reboots, or iOS container sandbox `<UUID>` changes, with backward-compatible migration for existing installations.
  - **API Banners Resolution & Non-Blocking Carousel (v2.5.6):** `BannerData.fromJson` now supports multiple backend keys (`imageUrl`, `image`, `image_url`, `banner_image`) with automatic prefixing of `ConstRes.aImageBaseUrl` for relative paths. The local banner I/O check (`_isLoadingLocal`) is isolated to the 8th custom slide, ensuring promotional API banners and dots render immediately without waiting.
  - Granted → spinner, picker / camera, crop (as above).
  - Refused, system can ask again (Android first refusal) → dialog "Camera" / "Gallery" with `permission_cameraWhy` / `permission_genericSettingsMessage`, **Not now** / **Allow** (keys `banner_camera_ask_again_dialog`, `banner_gallery_ask_again_dialog`, `banner_permission_allow`); Allow shows the system popup again (after 350 ms, so the dialog is fully closed). If that is refused again, or the phone shows no popup at all (some Android skins such as MIUI block repeat requests and return "denied" at once), the Settings dialog follows; the same Allow dialog is never shown twice in a row. A "request already running" error (another screen asking at the same time) is retried once, then Settings; it is never treated as granted. Never silent. Tests: `test/banner_camera_permission_test.dart` (BCP-01…07).
  - Access refused inside the picker after our check (`camera_access_denied` / `photo_access_denied`, kept in `LocalBannerService.lastAccessDenied`) → the Settings dialog below.
  - Blocked (Android "Don't allow" twice / "Don't ask again", iOS after the first refusal, parental controls) → dialog: title "Camera" / "Gallery", the same message, **Cancel** / **Open Settings** (keys `banner_camera_permission_dialog`, `banner_gallery_permission_dialog`, `banner_open_settings`). Back from Settings with access allowed → the camera / gallery opens by itself (one-shot `AppLifecycleListener`).
  - `pickInProgress` stays true during the system popup, **our dialogs, and the trip to Settings** (cleared when the dialog closes, or on return from Settings). Before, it was cleared right after "Don't allow", Home's resume permission / location check started at once and covered or replaced our message, so nothing seemed to happen after "Don't allow". Flag kept on while in Settings (`_inSettings`), so on return only one thing runs: the camera / gallery if now allowed, else Home's check.
  - **Dialog look** (both dialogs, `_showPermissionDialog` in `bannerUi.dart`), same style as the app's confirmation dialog (`CommonDialog.ConfirmationDialog`): white card (radius 20, no M3 tint), round light-purple circle with the icon on top (camera / gallery for "ask again", settings gear for "Open Settings"), centred bold title, centred grey message, two pills side by side: grey outlined **cancel** and filled purple `#6B4DFF` **confirm** (same purple as the banner sheets). Back or tap outside = cancel.
  - Existing strings only (all languages): `permission_camera`, `imagePicker_gallery`, `permission_cameraWhy`, `permission_cameraSettingsMessage`, `permission_genericSettingsMessage`, `permission_openSettings`, `common_cancel`, `common_notNow`, `common_allow`.
  - Code: `LocalBannerService.ensureCameraPermission` / `ensureGalleryPermission` / `isCameraGranted` / `isGalleryGranted` / `openSettings`, enum `BannerCameraAccess`.
  - Manual check on both phones (full restart, no hot reload): first tap (popup) → **Don't allow** → a dialog must appear (Android: Not now / Allow; iOS: Cancel / Open Settings), nothing else on top; Android: Allow → popup again → Don't allow → Settings dialog; Settings → enable → back → camera / gallery opens; Settings → leave off → back → nothing opens, Home normal; iOS Photos "Limited" → gallery works; turn Camera off in Settings while the app is open → tap Camera → Settings dialog.
- **Banner shape:** `_bannerAspect` = card width (page width − 2 × 4.w margin) ÷ card height (160.h), measured with a `LayoutBuilder` on the real slide; default 2.0.
- **Manage Custom Banner sheet:** white, current banner preview, **Replace Banner** (opens Select Banner Photo) and **Remove Banner** (deletes the file and the pref, shows the upload card again). Keys `banner_replace`, `banner_remove`.
- Sheet texts are English only (not in the ARB files yet).

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

### 5.9 Cache: Home banners, Notification Center, All Groups (v2.5.3)
- The encrypted app cache (guide [07](07_APP_CACHE_FRONTEND.md)) shows the last banners (`banners`, 7), notifications (`notifications`, 100) and groups (`groups`, 200) at once, then refreshes from the server (10 s timeout).
- **Notifications:**
  - the list is no longer cleared before each refresh;
  - a failed answer keeps the list with "Couldn't refresh · Retry";
  - the list refreshes on app resume;
  - unread count: the server value wins.
- **All Groups:** an error no longer replaces the list (retry bar); the skeleton shows only when the list is empty. The cached `isCreator` / `isActive` flags are display only; every action is checked by the server.
- **Not cached:** `/initialize` (payment / walkie access, Razorpay key), red dots, home counts (these already use their own prefs cache, unchanged).
- **Logout:** unchanged. The existing `ChatMessageCache.clearAll()` call deletes the app cache too.

## 6. International Payment Architecture & Changelog

### 6.1 Architecture Summary
- **Login OTP Charges & Walkie Plans**: Both modules fully support dynamic currency (India = INR ₹, International = USD $).
- **Payment Gateway**: Razorpay receives native currency and minor units (cents / paise). For USD, PayPal and international cards are automatically enabled.
- **Taxation (GST)**: International transactions are zero-rated (0% GST) under Section 16 of the IGST Act with Letter of Undertaking (LUT Form GST RFD-11). Domestic Indian transactions are charged 18% GST.
- **Razorpay Sandbox Simulator Note**: In Razorpay Test Mode, the mock card simulator uses a default pre-auth authorization hold of USD 1.00 for card testing; production live mode charges the exact order amount ($0.50 USD).

### 6.2 Change Log
| Version | Date | Description |
|---|---|---|
| v2.5.8 | 2026-11-27 | §16 System Share Sheet, Native Share Intake & Share FG Tracker: Added `SharePayload`, `ShareValidationService` (10 MB limit, offline check, auth guard, missing/permission-denied file handling), and `AppShareService` (`share_plus` with clamped non-empty `sharePositionOrigin`, socket auto-init before dispatch, and `PendingShareService` auth-resume queue). Added Android `ACTION_SEND` / `ACTION_SEND_MULTIPLE` filters + `MainActivity.java` channel, iOS `ShareExtension` (`group.com.fg.fgtracker`) + `AppDelegate.swift` intake, and **Share FG Tracker** in Side Menu & Settings (`https://play.google.com/store/apps/details?id=com.fg.fgtracker` & `https://apps.apple.com/app/fg-tracker/id6738914614`). |
| v2.5.6 | 2026-11-21 | §5.1.1 Custom Banner Gallery Fix & Permission Architecture: Proper Android 13+ (`READ_MEDIA_IMAGES` / `READ_MEDIA_VISUAL_USER_SELECTED` via `Permission.photos`) and Android ≤ 12 (`READ_EXTERNAL_STORAGE` via `Permission.storage`) permission handling with WhatsApp-like explanation and Settings dialogs. iOS full & limited photo access preserved. Removed blocking pre-picker modal loader (`_showPhotoLoader`) causing Android blank/white screen. Fixed banner persistence across app updates, reboots, and iOS dynamic sandbox `<UUID>` changes by saving to stable relative filename `local_custom_banner.jpg` in app documents with backward-compatible migration. Files: `android/app/src/main/AndroidManifest.xml`, `lib/app/Data/Services/local_banner_service.dart`, `lib/app/modules/home/Home_Widget/bannerUi.dart`. |
| v2.5.5 | 2026-11-18 | §1.3 "Home opens twice" after login: a failed / timed-out permission check on app resume is retried once and never treated as a revoked permission (no more Home → Permission Gate → Home); the route guard ignores a cached error. File: `permission_gate_service.dart`. Tests PG-R1 … PG-R4. Uncommitted. |
| v2.5.4 | 2026-11-18 | §11 Company contact details: phone **+91 93727 23727**, email **fgtracker@fgmanpower.com**, address **Ghatkopar West, Mumbai, Maharashtra 400086, India** (from the website footer) now used on Legal, About, Privacy / Terms text and the Walkie payment-failed screen. Home › Online members: bottom info card commented out. |
| v2.5.3 | 2026-11-17 | App cache (guide 07) for Home banners, the Notification Center and All Groups: shown at once, 10 s timeout, "Couldn't refresh · Retry" (not for banners), skeleton only when empty. Notifications are no longer cleared before each refresh; a failed answer (`getNotificationsOrNull` → `null`) never looks like "no notifications"; resume refresh added. All Groups: an error no longer replaces the list. `AppCache.warmUp()` in `main.dart`. Logout unchanged (the existing chat-cache `clearAll` deletes the app cache too). |
| v2.5.2 | 2026-11-17 | §5.1.1 Custom banner asks for camera (Android + iOS) and photos (iOS) before opening; blocked → Settings dialog, auto-continues after Settings. §9.3 "Follow us" uses real brand icons in brand colours. §9.3.1 side menu: divider + more space between Log out and Delete Account. §10 one back button app-wide: shared `AppBackButton` (white circle, purple `arrow_back_rounded`) and app bars that don't change on scroll (`AppBarStyle`); every back keeps its old action. |
| v2.5.1 | 2026-11-17 | §5.1.1 Custom banner: after taking a photo the crop screen opens next; Home no longer shows in between. Home's resume permission / location check waits until the photo flow ends (`LocalBannerService.pickInProgress`), and a spinner covers the native camera → cropper gap. Files: `local_banner_service.dart`, `bannerUi.dart`, `home_screen.dart`. |
| v2.5.0 | 2026-11-16 | §9 Side menu: **Legal** replaces Contact Us (6 documents open the fgtracker.fgmanpower.com pages, Contact Us card with phone, email, address, website); Language row matches the menu; Twitter removed and Facebook / Instagram / YouTube links updated. §5.1.1 Custom banner: new Select Banner Photo and Manage sheets (white), crop locked to the banner shape after Gallery or Camera. |
| v2.4.0 | 2026-11-13 | §8 Tracking Screen & Socket Synchronization Architecture: Live Tracking (radius boundary filtering) & Group Tracking ("Location Hidden" ghost mode); fixed `join-group` on Node.js /location socket; single moving user packet extraction for `group-location-update`; 5-min inactivity threshold for Online vs Last-seen; unit tests added under `test/tracking_unit_test.dart`. |
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

---

## 8. Real-time Location Tracking & Socket Synchronization Architecture (Tab 1: Live Tracking & Tab 2: Group)

### 8.1 Functional Overview & Business Logic
The Location Tracking module under Quick Actions provides two primary view modes:

1. **Tab 1: Live Tracking (Radius-based Nearby Users in Common Groups)**
   - **Strict Privacy & Authorization Policy**: A user can only track or view locations of other users who share at least one common group with the logged-in user. If User A and User B are both registered in the system but share no common group, they are strictly invisible to each other.
   - **Dynamic Radius Filtering**: Users configure a radius slider/selector (e.g., 500m, 1km, 2km, 5km). Changing the radius dynamically triggers an API query (`/getUsersWithinRadius`) and redraws the Google Maps radius circle and user list.
   - **Geofence Enforcement**: `TrackingController` validates all incoming socket coordinates using `Geolocator.distanceBetween(myLat, myLng, targetLat, targetLng)`. If a user moves beyond the selected radius limit, they are immediately stripped from `radiusUsers` and their marker is removed from Google Maps. Only users strictly within the radius boundary appear inside the circle.

2. **Tab 2: Group (Group-Wise Live Member Tracking)**
   - **Group Selection**: Tapping any group lists all labour / members enrolled in that group.
   - **Ghost Mode / Location Hidden**: If a user has turned off Location Sharing (`locationSharing == false` / `0`), their card appears in the group member list displaying `"Location Hidden"`, their coordinates are suppressed, and no location marker is drawn on the map.
   - **Online / Inactivity / Last-Seen State**:
     - Status evaluation conforms to §7 of the Common Module specification.
     - `Tracking().isOnline(...)` inspects both the socket connection state and `lastSeen` timestamp.
     - If the member's `lastSeen` is older than 5 minutes (`thresholdMinutes: 5`), the member is evaluated as `Offline`, and their relative last-seen label is rendered (e.g., `"Last seen: Today, 12:49 AM"`).
     - Live socket packets update timestamps and status dynamically without marking the entire group active.

---

### 8.2 Real-time Socket Architecture (`/location` Namespace)

| Event Name | Direction | Payload Structure | Purpose |
|---|---|---|---|
| `join-group` / `join_group` | Client → Server | `{ "groupId": 12 }` | Joins the socket room for real-time group broadcasts. Note: the Node.js server also auto-joins all authenticated user groups upon socket connection. |
| `send-location` | Client → Server | `{ "groupId": 12, "lat": 19.0760, "lng": 72.8777, "battery": 85, "speed": 0 }` | Emits the user's latest GPS fix to the backend. |
| `group-location-update` | Server → Room | `{ "status": true, "groupId": 12, "updatedUserId": 101, "updatedUser": { ... }, "data": [ ... ] }` | Broadcasts location updates to all members of `group_<groupId>`. `TrackingController` specifically extracts `updatedUser` to update the active moving member and avoids bulk-mutating inactive members. |
| `user-offline` / `userStatus` | Server → Client | `{ "userId": 101, "isOnline": false, "lastSeen": "2026-11-13T10:00:00Z" }` | Updates the live online/offline indicator across group member lists and map markers. |

---

### 8.3 Unit Testing Suite (`test/tracking_unit_test.dart`)

The test suite validates tracking models, distance geofencing, and socket processing:

1. **`UsersWithinRadiusRes` & `LocationData` Model Unit Tests**:
   - Parses nearby users with latitude, longitude, and formatted distance strings.
   - Accurately parses `locationSharing` flag to support Ghost Mode / Private Mode.
2. **`LiveLocationSocketModel` Unit Tests**:
   - Parses incoming socket location dictionaries with address fallbacks (`area`, `city`).
   - Normalizes raw string coordinates (`"19.0123"`) and percentage strings (`"95%"`) into clean numeric values without runtime exceptions.
3. **Activity & Online / Last-Seen State Tests**:
   - Validates that users with `lastSeen` within 5 minutes evaluate to `Online`.
   - Validates that users with `lastSeen` older than 5 minutes evaluate to `Offline` (even if stale database flags indicate `1`).
4. **Radius Boundary & Distance Filtering Tests**:
   - Verifies `Geolocator.distanceBetween` boundary checks (accepts points within radius, excludes points outside).
   - Verifies radius unit parsing (`"0.5"`, `"1"`, `"2"`, `"5"`, `"500m"`, `"2km"`).
5. **Socket Event Packet Unwrapping Tests**:
   - Validates extraction of `updatedUser` from `group-location-update` events, ensuring static member arrays in `data` do not falsely mark everyone active.

---

### 8.4 Home Screen Sockets, Notification Markers & Quick Action Badges (Zero-Blink Engine)

#### 8.4.1 Quick Action Badges & Marker Types
Home screen Quick Action items display a persistent circular red dot badge (`Color(0xFFEF4444)`) indicating unread or pending events:
- **Audio/Video Calling (`hasCallingMarker`):** Missed incoming calls (Private or Group calls). Cleared when navigating to `CallScreen` via `SocketService.instance.markCallHistoryViewed()`.
- **Chatting (`hasChattingMarker`):** Unread messages across Private and Group chats. Cleared when navigating to `ChatListScreen` via `SocketService.instance.markChatListViewed()`.
- **Walkie-Talkie (`hasWalkieMarker`):** Active speaker on a Walkie channel or walkie-specific notification.

#### 8.4.2 Root Cause Analysis: The Red Dot Blinking / Flickering Bug
##### The Problem
On the Home screen, the red dot badge on the "Chatting" or "Call" quick action card would intermittently blink on and off every few seconds.

##### Why It Happened (Socket vs. Local Controller Race Condition)
1. **Heartbeat Socket Emission:** Every few seconds, the background location tracking socket emitted a location fix to the server, receiving `location-update-success` with a `notificationMarkers` dictionary (e.g. `{"calling": false, "chatting": false, "walkie": false}`).
2. **Blind Reset in NotificationMarkerService:** In `NotificationMarkerService.updateFromMap()`, if the incoming payload contained `chatting: false` without granular sub-keys (`privateChat` or `groupChat`), the service wiped:
   ```dart
   hasGroupChatUnread.value = false;
   hasPrivateChatUnread.value = false;
   hasChattingMarker.value = false;
   ```
3. **Local Chat Controller Contradiction:** Simultaneously, `ChatListController` maintains local unread counts from active SQLite / in-memory conversations. On the next stream or tick, it called `_syncChattingNotificationMarker()`, setting `hasChattingMarker.value = true` again.
4. **Result:** The reactive `Obx` on `_QuickActionCard` received alternating `true` and `false` values every few seconds, causing rapid visual blinking/flashing.

#### 8.4.3 Architectural Fix: Authoritative Local State Guard & Value Distinctness
1. **Sub-Source Protection:** If an incoming socket or API map sends `chatting: false` without granular private/group breakdown, it **must never clobber active local unread states**:
   ```dart
   if (!hasPrivateChatKey && !hasGroupChatKey) {
     if (!hasGroupChatUnread.value && !hasPrivateChatUnread.value) {
       if (hasChattingMarker.value) hasChattingMarker.value = false;
     } else {
       // Keep true: verified local unreads exist in ChatListController
       if (!hasChattingMarker.value) hasChattingMarker.value = true;
     }
   }
   ```
2. **Distinct Value Guard:** `hasCallingMarker`, `hasChattingMarker`, and `hasWalkieMarker` only re-assign `.value` when the incoming value differs from the current value (`if (x.value != parsed) x.value = parsed;`), avoiding redundant GetX reactive notifications and repaints.
3. **Explicit User Reset:** Unread markers are cleared only when the user deliberately opens the respective screen (`clearChattingMarker()`, `clearCallingMarker()`) or when `ChatListController` validates that all conversations are marked read.

#### 8.4.4 Parity & Premature-Reset Hardening (`v2.5.6`, 2026-11-26)
Following cross-module Home & Chat List updates, three additional causes of missing or blinking Chatting Red Dots (especially for Group chats) were resolved:
1. **No Implicit `setChatListViewed` on `GET /chat-list` (`controllers/chatList.controller.js`):**
   - `HomeController.init()` starts `ChatListController` on app launch, which fetches `GET /chat-list` in the background. Previously `getChatList` called `notificationViewStore.setChatListViewed(userId)`, immediately suppressing server `groupChat` red-dot markers before the user ever tapped Chatting. Only explicit `POST /mark-viewed` and socket `chat_list_viewed` now mark the list as viewed.
2. **Backend `seenAt IS NOT NULL` & Private/Group Marker Symmetry (`repositories/initialize.repository.js`):**
   - `hasUnreadGroupMessages` now checks `MessageReads` with `seenAt: { [Op.ne]: null }` (ignoring delivery-only rows where `seenAt: null`), excludes `messageType: "system"`, checks `Groupmembers.isMarkedUnread`, and matches `hasUnreadPrivateMessages` (which also checks `private_chat_user_settings.isMarkedUnread`) without the asymmetric `lastChatViewedAt` cutoff that caused `/location` heartbeats (`groupChat: false`) to disagree with `ChatListController`.
   - `markChatAsRead` / `markChatAsUnread` across REST (`chatList.controller.js`) and sockets (`ChatMessage.socket.js`, `privateChat.socket.js`) notify `/location` (`notifyUserMarkersUpdate`) immediately.
3. **Frontend Authoritative Local Guard & Socket Alias Parity (`notification_marker_service.dart`, `SocketServices.dart`, `chat_list_controller.dart`):**
   - `ChatListController` registers `hasLocalPrivateUnreadCheck` and `hasLocalGroupUnreadCheck` on `NotificationMarkerService` (cleared in `onClose`), preventing `updateFromMap` / `updateFromModel` from resetting `hasPrivateChatUnread` / `hasGroupChatUnread` to `false` when verified local unreads or manual-unread marks exist.
   - `clearManualUnreadForGroup`, `markChatAsUnread`, and chat removal/clear handlers now invoke `_syncChattingNotificationMarker()`.
   - `SocketService` listens to both `notification_markers` and `notification-markers` via a shared handler.

---

### 8.5 Home Screen 4 Stats Cards & Group Dashboard Counts Real-time Architecture

#### 8.5.1 The 4 Stat Cards
The Home Screen displays 4 summary cards (`StatsGrid.dart`) backed by `GroupCountService`:
1. **Total Groups (`totalGroups`):** Active groups joined or created by the user. Opens `Routes.GroupsList`.
2. **Current Online (`activeMembers`):** Real-time online members across the user's groups (`OnlineUserStore` memory presence or active ping within 2 minutes). Opens `OnlineMember()`.
3. **Total Members (`totalMembers`):** Total unique members across the user's groups (excluding the logged-in user). Opens `TotalMember()`.
4. **Total Private Mode Users (`locationDisabledMembers` / `privateMembers`):** Members who have toggled Location Sharing OFF. Opens `GhostMember()`.

#### 8.5.2 Root Cause Analysis: Total Member Count Mismatch (Card Showing 4 vs List Showing 3)
##### The Problem
The "Total Member" card on the Home Screen displayed `4`, but tapping the card opened `TotalMember` list displaying only `3` members.

##### Why It Happened
1. **Unverified Database Queries in `dashboard.services.js`:**
   `getGroupDashboardCounts()` previously queried raw rows from the `groupMember` table and directly computed `uniqueUserIds.length` without cross-referencing the `User` table:
   ```javascript
   // Flawed original logic:
   const groupMembers = await groupMember.findAll({ where: { groupId: { [Op.in]: groupIds } } });
   const uniqueUserIds = [...new Set(groupMembers.map(m => Number(m.userId)))].filter(id => id !== normalizedUserId);
   ```
   If a row in `groupMember` belonged to a user who was deleted from the `users` table or created during test fixtures, it was counted.
2. **Screen Member Validation in `getAllGroupMembers`:**
   When the user tapped the card, `TotalMember` called `GET /all-group-members`. In `group.repository.js`, it queried `User.findAll({ where: { UserId: { [Op.in]: uniqueUserIds } } })`. It then executed:
   ```javascript
   const allMembers = uniqueUserIds.map(id => {
     const user = userMap.get(id);
     if (!user) return null; // Excluded!
     ...
   }).filter(Boolean);
   ```
   The non-existent/deleted user was filtered out, returning only 3 valid members.
3. **The Solution:**
   Updated `DashboardService.getGroupDashboardCounts()` to validate all member IDs against `User.findAll` and check `GroupRepository.getUserGroupIds()` with `deletedAt: null`. `totalMembers` now matches the 3 valid members displayed in the list.

#### 8.5.3 Real-time Synchronization Architecture
##### Why Counts Were Not Updating in Real-Time
1. The backend previously only emitted `group_dashboard_counts` to the single socket that triggered a location fix or explicit query. Co-members in the group were never notified when another user went online, offline, or changed Private Mode.
2. Flutter's `home_controller.dart` attempted to request counts via `SocketDashboardService` on namespace `/dashboard`, while the main real-time connection ran on `/location` (`SocketService.instance`).

##### Architectural Fix
1. **Backend Real-Time Broadcast (`notifyGroupDashboardCountsUpdate`):**
   - Whenever any user connects (`socket.on("connection")`), disconnects (`socket.on("disconnect")`), or toggles Location Sharing (`broadcastLocationSharingUpdate`), the backend immediately resolves all affected co-members across their groups.
   - For every connected co-member in `OnlineUserStore`, the backend calculates their fresh counts and emits `group_dashboard_counts` directly to their socket room:
     ```javascript
     locationNamespaceInstance.to(String(targetUid)).emit("group_dashboard_counts", { status: true, data: counts });
     ```
2. **Multi-Channel Flutter Ingestion:**
   - In `home_controller.dart`, both `SocketService.instance.requestGroupCount()` and `SocketDashboardService.instance.requestGroupCount()` are triggered on boot and resume.
   - `SocketServices.dart` listens to `group_dashboard_counts` and `group-dashboard-counts`, as well as `user-offline` events to keep `GroupCountService` continuously synchronized without requiring a manual pull-to-refresh.
3. **Instant HTTP Hydration:**
   - The `/api/initialize` endpoint now packages `dashboardCounts` alongside `notificationMarkers`, ensuring the 4 cards paint with exact numbers immediately on cold start before platform sockets even connect.

---

## 9. Side menu: Legal, Language, social links (v2.5.0, 2026-11-16)

### 9.1 Legal (replaces "Contact Us")
- **Menu item:** "Legal" / "Policies and agreements", gavel icon, same position as the old "Contact Us" (`sidemenu.dart`). Opens `Routes.Legal` (`/legal`) → `LegalScreen`.
- **Config:** `lib/app/modules/Legal/legal_documents.dart`, one list (`legalDocuments`) with id, title, subtitle, bundled `.md` path and **`websiteUrl`**. Change a link here; no UI change needed.
- **Tap = website.** Every row opens its page on **https://fgtracker.fgmanpower.com** in the browser (`url_launcher`, external; only `https`, `tel`, `mailto` are allowed; a failed launch shows a snackbar).

| Row (en) | Opens |
|---|---|
| Privacy Policy | `/privacy-policy/` |
| Terms & Conditions (EULA) | `/terms/` |
| Enterprise Service Agreement | `/enterprise-service-agreement/` |
| Data Processing Agreement | `/data-processing-agreement/` |
| Data Retention & Deletion Policy | `/data-retention-policy/` |
| Data Protection & Information Security Policy | `/information-security-policy/` |

- **Contact Us card** (below the documents, values copied from the website footer, `legalContacts`):

| Row | Value | Tap |
|---|---|---|
| Phone | +91 93727 23727 | `tel:+919372723727` |
| Email | fgtracker@fgmanpower.com | `mailto:` |
| Address | Ghatkopar West, Mumbai, Maharashtra 400086, India | Google Maps search |
| Website | fgtracker.fgmanpower.com | website |

- **Draft notice:** `showLegalDraftNotice = false` (the website has the final v1.0 documents, effective 16 Nov 2026).
- **Strings:** `legal_*` keys in all 20 ARB files (titles, subtitles, menu label). Document text is English and lives on the website.
- **Tests:** `test/legal_screen_test.dart` (config order, website links, contacts, every tap opens the right link, failed launch message, large font / dark mode / hi-mr-ar, document screen).
- **Open items:**
  1. Row titles still use the old names; the website uses "Global Privacy Policy", "Terms and EULA", "… and …". Change `legal_*Title` in the 20 ARB files if wanted.
  2. Unused since taps go to the website: `LegalDocumentScreen` + route `/legal-document`, package `flutter_markdown_plus`, the 6 empty `assets/legal/*.md` files and keys `legal_draftNotice` / `legal_emptyDocument`. Remove after sign-off.
  3. The old `AboutUs.dart` (Contact Us screen) still links to `www.fgmanpower.co.in`; it is no longer reachable from the menu.

### 9.2 Language row
Same look and size as the other menu items: "Language" + "Change app language", one line each. Details in the Language guide (`06_LANGUAGE_MODULE_FRONTEND.md` §2).

### 9.3 Social links (menu footer)
- Facebook, Instagram, YouTube (`AppText.facebookUrl` / `instagramUrl` / `youtubeUrl`). **Twitter / X removed** (icon and `twitterUrl`).
- **Real brand icons (v2.5.2):** "Follow us on" shows the official logos (Font Awesome brands, `font_awesome_flutter` 11, type `FaIconData`) in white on 40×40 rounded tiles in the brand colours, instead of the old generic SVGs tinted purple: Facebook `facebookF` on `#1877F2`; Instagram `instagram` on the Instagram gradient (`#FEDA75` → `#FA7E1E` → `#D62976` → `#962FBF` → `#4F5BD5`); YouTube `youtube` on `#FF0000`. Keys `menu_social_facebook` / `_instagram` / `_youtube`; screen reader label = network name. Tap still opens the URL outside the app (unchanged). Helper `_buildSocialIcon` in `sidemenu.dart`.

| Network | URL |
|---|---|
| Facebook | https://www.facebook.com/people/FG-Tracker/61594760706918/ |
| Instagram | https://www.instagram.com/fgtracker/ |
| YouTube | https://www.youtube.com/channel/UC_nUpY0OdPbJjZRdzFiZGhQ |

### 9.3.1 Log out ↔ Delete Account spacing (v2.5.2)
- Delete Account (red card) is set apart from Log out to avoid a mis-tap on the destructive action: 14 h gap, a visible divider (`#E2DCF3`, 1 px, key `menu_delete_account_divider`), then 18 h gap. Before: the faint shared divider (`#F0ECFC`) directly above the card.
- Only spacing / divider changed in `sidemenu.dart`; Log out and Delete Account actions and dialogs are unchanged.

### 9.4 Changed files (v2.5.0)
| Area | Files |
|---|---|
| Legal | `lib/app/modules/Legal/*` (new), `lib/app/routes/app_routes.dart`, `app_pages.dart`, `sidemenu.dart`, `lib/l10n/*.arb` + generated, `pubspec.yaml` (assets, `flutter_markdown_plus`), `assets/legal/*` (new, unused), `test/legal_screen_test.dart` (new) |
| Social links | `lib/app/Core/theme/AppText.dart`, `sidemenu.dart` |
| Custom banner (§5.1.1) | `lib/app/modules/home/Home_Widget/bannerUi.dart`, `lib/app/Data/Services/local_banner_service.dart` |

## 10. One back button & app bar style (v2.5.2, 2026-11-17)

**Rule:** every screen's Back uses the shared `AppBackButton` (`lib/app/global_widget/app_back_button.dart`). Do not draw a new back icon.

- **Look:** white **circle** 40×40, light purple shadow, purple (`#5045B9`) `Icons.arrow_back_rounded` 20 sp; the whole circle is tappable; semantics label = the platform "Back" tooltip. Optional `color` changes only the arrow.
- **Action:** `onTap` is always the screen's **old** back action (e.g. `Get.back()`, `Navigator.pop`, close search, exit dialog in Walkie, `_backToOtpCharges` on payment failed). No back behaviour changed in this pass. Without `onTap` it calls `Navigator.maybePop` (same as Flutter's implicit back).
- **App bars:** `AppBarStyle.leading(onTap: …)` + `leadingWidth: AppBarStyle.leadingWidth` (16 px gap). Bars holding it use `scrolledUnderElevation: AppBarStyle.scrolledUnderElevation` (0) and `surfaceTintColor: AppBarStyle.surfaceTintColor` (transparent), so Material 3 no longer tints / lifts the bar while the page scrolls (that made the back button look broken on All Groups). Bars that had a deliberate shadow keep it with the same value while scrolling.
- **Exceptions:** QR scanner keeps its round "glass" button over the camera (same `arrow_back_rounded` glyph, matches the flash button). Other buttons next to Back (Edit, call, search, flash) keep their own style.
- **Shared helpers changed once** (callers untouched): `reusableAppbar` and `BackpressIcon` (`common_widget.dart`), `customAppBar` (`widgets/cutom_appbar.dart`), `PackageBackButton`, Safe Zone common widgets, `TrackLAppBar`, safety coming-soon `_buildBackButton`.
- **Screens:** Groups (All Groups, Group chat + search, Group Info, Members, Media/Links/Docs, QR scan), Chats (list + search, Archive, private chat + search, Forward, New chat, User profile, Document viewer, Video player, image viewer, Notifications), Status viewer, Home Live Status lists, Tracking, Attendance, Call, Contact profile, Intro, Legal, OTP charges, Package pricing, Safe Zone, SOS, Language settings, Registration, all Walkie-talkie screens incl. payment.
- **Check on Android + iOS:** each screen's Back looks the same and does what it did before; on long lists (All Groups, Members, Chats) scroll up and down: the bar and the Back circle don't change.

---

## 11. Company contact details: one set everywhere (v2.5.4, 2026-11-18)

**Source of truth:** the footer of https://fgtracker.fgmanpower.com/legal/. When the website changes, update every row below.

| Detail | Value |
|---|---|
| Phone | +91 93727 23727 (`tel:+919372723727`) |
| Email | fgtracker@fgmanpower.com |
| Address | Ghatkopar West, Mumbai, Maharashtra 400086, India (no company name in the address line) |

| Where | File |
|---|---|
| Legal › Contact Us card | `lib/app/modules/Legal/legal_documents.dart` (`legalContacts`, test `test/legal_screen_test.dart`) |
| About (support email, address) | `lib/app/modules/home/Views/About.dart` |
| Privacy Policy / Terms text (contact, office, grievance officer, notice) | `lib/app/modules/auth/Auth_Widget/policy_texts.dart` |
| Walkie payment-failed screen (support email + phone) | `lib/app/modules/Walkie-talkie/Views/walkie_talkie_payment_failed_screen.dart` |

**Not changed on purpose:** `walkie_payment_gateway_service.dart` keeps `support@fgtracker.in` as the payment-form fallback email for a customer without one (never shown as our contact). Website links (`fgmanpower.co.in`, `fgmanpower.in`) are unchanged.

### 11.1 Home › Online members: bottom info card hidden
`home/Views/LiveStatus/components/online_member.dart`: the call to `_buildBottomInfoCard()` is commented out (method kept, marked `// ignore: unused_element`). Remove the `//` to show it again.

---

## 12. Side Menu Refactor & Contact Us Bottom Sheet (v2.5.5, 2026-11-23)

### 12.1 Side Menu Hierarchy
The drawer navigation in `lib/app/modules/home/Views/sidemenu.dart` is refactored into a clean, modern layout:
1. **User Profile Header**: Wave gradient, avatar, online indicator, name, email/phone.
2. **Edit Profile**: Navigation to `Routes.Register` (update mode, standardized with Tracker's `reusableAppbar`).
3. **Contact Us**: Tapping opens the Contact Us bottom sheet.
4. **Settings**: Dedicated settings menu item navigating to `Routes.settings` (subtitle short and clean: `"Language, legal & updates"`).
5. **Log Out**: Positioned outside on the menu bar below Settings, set apart with a divider line and styled in an isolated red card (`#FEF2F2` background, `#FECACA` border, `#DC2626` red icon and bold title).
6. **Footer**: FG Manpower LLP branding card, official social links (Facebook, Instagram, YouTube), and dynamic app version tag (`"v ${ConstRes.appVersion}"` from `ConstRes.appVersion`).

### 12.2 Contact Us Bottom Sheet (`contact_us_bottom_sheet.dart`)
- **Clean Native Design**: Removed hero illustration/fallback icon; renders a clean top drag handle (`#E2DCF3`), centered bold title ("Contact Us"), and subtle helper subtitle ("We're here to help you").
- **Visuals & Theme Styling**: Full FG-Tracker signature palette:
  - Badges: `#EDE9FE` soft-purple rounded tiles (44×44, 14.r radius) with `#5D47F1` brand purple icons.
  - Typography: `#1E202B` bold headers with `#7A7F93` regular subtitles and `#7E69F7` chevrons.
  - Dividers: Subtle `#F0ECFC` lines.
- **Communication Channels (Full data from Legal §11):**
  - **Phone**: Calls `tel:+919372723727` to launch device dialer (`+91 93727 23727 (9:00 AM - 6:00 PM)`).
  - **Email**: Calls `mailto:fgtracker@fgmanpower.com` to launch mail client (`fgtracker@fgmanpower.com`).
  - **WhatsApp**: Calls `whatsapp://send?phone=919372723727` with automatic web fallback `https://wa.me/919372723727` (`+91 93727 23727`).
  - **Website**: Launches `https://fgtracker.fgmanpower.com/` in browser (`fgtracker.fgmanpower.com`).
  - **Office Address**: Launches Google Maps search for `Ghatkopar West, Mumbai, Maharashtra 400086, India`.
  - Safe error handling with localized toasts (`chat_unableToOpen`, `chatList_whatsappOpenFailed`).

### 12.3 Dedicated Settings Screen (`settings_screen.dart`)
- Route: `Routes.settings` (`/settings`).
- App bar: Standard `reusableAppbar` / `AppBarStyle.leading` with `AppBackButton`.
- Screen Content:
  1. **Language**: `LanguageSettingsRow` (opens instant language selection sheet).
  2. **Legal**: `Icons.gavel_rounded` -> `Routes.Legal` (Contact Us section removed from Legal screen to eliminate duplication).
  3. **Update App**: `Icons.system_update_rounded` -> `Routes.shorebirdUpdate`.
- **Bottom Destructive Action**:
  - `Delete Account`: Pinned in `bottomNavigationBar` inside `SafeArea` as a prominent red button (`#DC2626` background, white trash icon, bold white title) -> confirmation dialog with reason selector -> `AccountDeletionController().deleteUserAccount()`.

### 12.4 AppBar Standardization Across Menu Screens (Matching All Media)
All screens reachable from the side menu now share the exact AppBar pattern from **All Media** (`MediaLinksDocsScreen` in `lib/app/modules/Messages/Views/Group/media_links_docs_screen.dart`):
- **Visuals & Specifications**:
  - `backgroundColor: Colors.white` (pure clean white background; dark theme compatible).
  - `elevation: 1` and `scrolledUnderElevation: 1` (subtle persistent border shadow).
  - `shadowColor: const Color(0xFF5045B9).withValues(alpha: 0.1)` (soft purple-tinted shadow).
  - `surfaceTintColor: AppBarStyle.surfaceTintColor` (no Material 3 scroll tint).
  - `centerTitle: false` (left-aligned title).
  - `automaticallyImplyLeading: false`.
  - `leadingWidth: AppBarStyle.leadingWidth` with `AppBarStyle.leading(...)` (`AppBackButton` white circular badge with purple arrow).
  - `title`: `Text(title, style: TextStyle(color: Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w700))`.
- **Screens Standardized**:
  1. **Settings Screen** (`settings_screen.dart`)
  2. **Language Screen** (`language_settings.dart`)
  3. **Legal Screen & Legal Documents** (`legal_app_bar.dart` / `legal_screen.dart`)
  4. **Update App Screen** (`ShoreBird_AppUpdate_Screen.dart`)
  5. **Edit Profile Screen** (`registration_screen.dart`)

### 12.5 Home Screen 4 Stats Tab AppBars (Icons Removed)
The extra circular badge icons between `AppBackButton` and the title have been completely removed across the 4 Home stat tab screens for a clean, streamlined AppBar:
1. **Online Members** (`online_member.dart`): Removed `Icons.person_pin_circle_rounded` badge.
2. **Ghost / Private Mode** (`ghost_member.dart`): Removed `Icons.verified_user_rounded` badge.
3. **Total Members** (`total_member.dart`): Removed `Icons.group_rounded` badge.
4. **Groups** (`total_groups.dart` / `groups_list_screen.dart`): Clean back button + title + count subtitle.

### 12.5 Verification & Modules Integrity
- **Files Modified/Created**:
  - `lib/app/modules/home/Views/contact_us_bottom_sheet.dart` (Updated: clean header without hero icon)
  - `lib/app/modules/home/Views/settings_screen.dart` (Updated: red bottom delete account button)
  - `lib/app/modules/home/Views/sidemenu.dart` (Updated: version uses `ConstRes.appVersion`)
  - `lib/app/modules/Legal/Views/legal_app_bar.dart` (Updated: standardized to 50h, 20sp, AppColors.darkBlue)
  - `lib/app/modules/auth/Views/registration_screen.dart` (Updated: edit profile uses standard `reusableAppbar`)
- **Files Locked (Protected & Untouched)**:
  - Authentication / Login: `OtpController.dart`, `logoutuser.dart`.
  - Location Sharing & Ghost Mode: `GroupTrackController.dart`, `LiveStatus_controller.dart`, `Profile_Repo.dart`, `ProfileRes.dart`, `OtpVeriefy.dart`.
  - Core existing modules: Home Screen, Menu user header, Chatting, Call Swipe, Attendance, Safe Zone, Walkie-talkie, Block/Unblock.
- **Static Analysis**: `0 errors` verified with `analyze_files`.

---

## 13. Scan Text Module (Offline ML Kit Chat Attachment (+) Text OCR & Send)

### 13.1 Overview & Objective
An on-device, completely offline Text Recognition (OCR) feature integrated directly into the **Chat Attachment (+)** menu alongside Camera, Gallery, Document, Location, and Contact. It allows users to take a photo or select an existing image of any printed or handwritten text (paper, book, whiteboard, receipt, poster, visiting card), extracts the text automatically with offline Google ML Kit (Latin-first with Devanagari fallback for Hindi), presents an editable full-screen preview with word/character counts, Copy, and Rescan buttons, and upon pressing **Send**, sends the text directly into the chat as a standard text message.

### 13.2 Architecture & Flow
1. **Entry Point (Chat Attachment (+) Only - MenuBar Removed)**:
   - **MenuBar**: Scan Text has been completely removed from `sidemenu.dart`, restoring MenuBar 100% to its original state.
   - **Chatting Attachment Sheet (`ChatBottomSheet.showFileOptions`)**: Contains `Scan Text` item with `Icons.document_scanner_rounded` alongside Gallery, Camera, Document, Location, and Contact. Tapping it closes the sheet and triggers `ScanTextService.instance.startChatScanFlow(context)`.
2. **Live Camera Scanner (`LiveScanCameraScreen`)**:
   - Opens the in-app live camera screen directly (`LiveScanCameraScreen(isForChatSelection: true)`) with:
     - Real-time targeting reticle (`[ ]` yellow corner brackets).
     - Tap-to-focus and auto-exposure support on the preview.
     - Ultra-high resolution preset (`veryHigh` 1080p+) for crisp OCR capture.
     - Controls: Torch toggle, Gallery picker shortcut, and blue **Insert** capture button.
     - Top message draft bubble showing text in real-time with Copy, Share, and Send buttons.
   - Upon tapping **Insert** (or selecting photo from Gallery), executes offline ML Kit text extraction and opens full-screen `ScanTextResultScreen`.
3. **Editable Preview Screen (`ScanTextResultScreen(isForChat: true)`)**:
   - Displays the extracted text in a full-height editable `TextField` where the user can freely read, edit, or adjust the text before sending.
   - **Live Counters**: Displays live word and character counts in the AppBar.
   - **Copy Button**: Copies the text to clipboard and shows `"Copied"` toast.
   - **Rescan Button**: Pops back directly to `LiveScanCameraScreen` so the user can retake/re-point the camera at any text and tap "Insert" again, without sending incomplete text.
   - **Send Button**: Prominent purple action button (`Color(0xFF5D47F1)`). Tapping it returns the final edited text through `LiveScanCameraScreen` to `ChatInputArea`.
4. **Chat Send Integration (`ChatInputArea.dart`)**:
   - Upon receiving the edited text from the preview screen, `ChatInputArea` populates `widget.textController.text`, updates reactive observables (`messageText`, `onInputTextChanged`), and immediately invokes `widget.onSend()`, delivering the text into the active chat conversation as a standard message.
5. **High-Accuracy OCR Pipeline & Zero Noise**:
   - **Automatic Viewfinder Cropping (`cropImageToViewfinder`)**: Crops the photo directly to the central reticle area before running ML Kit. This eliminates peripheral monitor bezels, keyboard keys, desk clutter, and neighboring screen noise outside the target box.
   - **Latin-First Recognition**: Prioritizes `TextRecognitionScript.latin` as the primary engine for English, numbers, code, and punctuation. Eliminates random Devanagari hallucinations (like `है।`, `और`) caused by screen glare/moiré on English scans.
   - **Hindi Threshold Detection**: Runs Devanagari recognition and only uses it if significant Devanagari characters (`\u0900-\u097F`, >= 8 characters) are present, ensuring real Hindi documents are preserved while English documents remain pure.
   - **Noise & Artifact Cleanup (`_cleanOcrText`)**: Strips stray border artifacts (`|`, `•`, `~`, `¬`), discards symbol-only lines (`---`, `***`), and drops single-consonant glitch lines so the output is clean and directly sendable without junk.
   - **Zero Hindi / Hinglish UI**: All banners, error messages, dialogs, toasts, and buttons are 100% in clean English.
   - **Completely Offline**: Operates 100% locally on-device without cloud network requests.

### 13.3 Platform Configurations
- **Android**:
  - `AndroidManifest.xml`: `android.permission.CAMERA`, `android.permission.READ_MEDIA_IMAGES`, `android.permission.READ_EXTERNAL_STORAGE`.
  - `build.gradle`: `implementation 'com.google.mlkit:text-recognition-devanagari:16.0.1'`.
  - `proguard-rules.pro`: Keep rules for `com.google.mlkit.**`.
- **iOS**:
  - `Info.plist`: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`.
  - `Podfile`: `pod 'GoogleMLKit/TextRecognitionDevanagari', '~> 9.0.0'`.

### 13.4 Verification & Tests
- Automated test suites:
  - `test/scan_text_proof_test.dart`:
    - Proof A: MenuBar DOES NOT show Scan Text option (Clean MenuBar).
    - Proof B: Chat Attachment (+) shows Scan Text option.
    - Proof C: Scan Text Result Screen in Chat mode shows Send button, Edit capability, and Copy.
    - Proof D: Error toast handling when no text is found.
  - `test/scan_text_unit_test.dart`: Verifies `ScanTextService` exception safety and edge cases.

---

## 14. Build & Assets Cleanup (`v2.5.6`, 2026-11-26)

- **`pubspec.yaml`:** Removed the non-existent `- assets/legal/` directory entry (`assets/legal/` is not checked in because legal documents open directly on `https://fgtracker.fgmanpower.com`, per §9.1). This fixes Flutter asset-bundle build failures (`Error: unable to find directory entry in pubspec.yaml: .../assets/legal/`).
- **Android / macOS Plugin Build Cache Recovery:** If Android Studio / Gradle reports `cannot find symbol` for pub-cache plugins (for example `OTPPlugin` in `otp_autofill` or `VideoCompressPlugin` in `video_compress`) alongside Kotlin Gradle Plugin deprecation warnings, run `flutter clean`, refresh `.pub-cache` / `flutter pub get`, and rebuild before switching Kotlin plugin settings.




---

## 15. App Lifecycle Presence, Marker Guards & Version Bump (`v2.5.7`)

- **Version & Build (`pubspec.yaml`, `android/app/build.gradle`, `const_res.dart`):**
  - `pubspec.yaml`: `2.0.8+343`; `android/app/build.gradle`: `flutterVersionCode = '343'`, `flutterVersionName = '2.0.8'`; `ConstRes`: `appVersion = '2.0.8'`, `appBuildNumber = 3403`.
- **Background Chat Socket Disconnect (`lib/main.dart`):**
  - `_MyAppState.didChangeAppLifecycleState` disconnects `SocketMessageService.instance.disconnectPrivateChatSocket()` when `AppLifecycleState.paused` or `AppLifecycleState.detached` occurs so peers see offline / last-seen immediately.
- **Notification Marker Local Guard (`notification_marker_service.dart`):**
  - Adds `hasLocalPrivateUnreadCheck` and `hasLocalGroupUnreadCheck` callbacks so stale backend heartbeats cannot turn off the bottom-nav Chatting red dot while verified local unreads or manually-unread rows remain.
- **Force Update & Banner UI (`force_update_screen.dart`, `bannerUi.dart`):**
  - `ForceUpdateScreen` hides the lock-icon helper footer when `isShorebird` is `true` (shown only for Store Force Update).
  - `bannerUi.dart` wraps `PageView.builder` with scroll notification handling.

---

## 16. System Share Sheet, Native Share Intake & Share App (`v2.5.8`, 2026-11-27)

- **Share Services (`lib/app/Data/Services/Share/`):**
  - `share_payload.dart`: Unified `SharePayload` (`text`, `link`, `image`, `video`, `audio`, `file`, `location`) with JSON persistence.
  - `share_validation_service.dart`: Enforces 10 MB file size cap across images, videos, audio, and documents, verifies internet connectivity (`hasInternet`), auth state (`isUserAuthenticated`), and file readability/permissions.
  - `app_share_service.dart`: Outgoing OS Share Sheet (`share_plus` with `sharePositionOrigin`), `Share FG Tracker` link (`https://play.google.com/store/apps/details?id=com.fg.fgtracker` & `https://apps.apple.com/app/fg-tracker/id6738914614`), native intake (`com.fgtracker/share_intake` + `com.fgtracker/share_intake_events`), and `PendingShareService` auth-resume queue.
- **Native Intake (`AndroidManifest.xml`, `MainActivity.java`, `ios/ShareExtension/`, `AppDelegate.swift`, `Runner.xcodeproj`):**
  - Android: `ACTION_SEND` & `ACTION_SEND_MULTIPLE` intent filters + `ContentResolver` stream copy to `share_intake` cache.
  - iOS: `ShareExtension` target (`com.fg.fgtracker.ShareExtension`, App Group `group.com.fg.fgtracker`) writing payload + opening `fgtracker://share-intake`.
- **Auth-Guarded Resume (`main.dart`, `home_screen.dart`):**
  - Unauthenticated shares persist in `SharedPreferences` while normal Login/OTP/Register/PermissionSetup runs untouched; `HomeScreen._initializeHomeServices()` calls `AppShareService.instance.consumePendingOnHomeReady()` to open `ForwardMessageScreen` automatically after login.
- **Share FG Tracker Menu Entry (`sidemenu.dart`, `settings_screen.dart`):**
  - Added **Share FG Tracker** row in Side Menu and Settings screen.
