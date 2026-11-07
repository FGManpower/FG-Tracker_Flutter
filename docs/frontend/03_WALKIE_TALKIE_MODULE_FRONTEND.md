# Walkie-Talkie (PTT) Module — Flutter Frontend Architecture & Implementation Guide

**Document Version:** `v1.0.0`  
**Target Audience:** Flutter Frontend Developers  
**Covers:** Push-to-Talk (PTT) UI, Audio Stream & WebRTC, Active Channel Switcher, Notification Toggles, Group Info Sheet with Bell Indicators, Razorpay Plan Purchase & Seat Assignment  
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
  - Tapping the bell triggers `POST walkie/channels/:groupId/alert-member`.
  - The UI button immediately transforms into a 10-second circular countdown timer to prevent repeated spamming.

---

## 4. Plans, Checkout & Razorpay Payment Integration

```
User Trial Expired / ptt_denied ──► Plans Screen (Weekly/Monthly/Yearly)
                                            │
                                            ▼
                                  Order Summary Screen
                                  (Apply Promo Coupon)
                                            │
                                            ▼
                                   Create Razorpay Order
                               (POST walkie/payments/order)
                                            │
                                            ▼
                                 Open Native Razorpay SDK
                                            │
                 ┌──────────────────────────┼──────────────────────────┐
                 ▼                          ▼                          ▼
          [ SUCCESS ]                  [ PENDING ]                 [ FAILED ]
                 │                          │                          │
        Verify Payment               Poll / Webhook              Retry Payment
     (POST walkie/payments/verify)          │                          │
                 │                          ▼                          ▼
                 ▼                 Payment Pending Screen      Payment Failed Screen
      Payment Success Screen
                 │
                 ▼
        Assign Team Seats
```

1. **Order Summary Controller:** Calculates GST, applies coupon codes via `WalkiePlanRepo.applyCoupon()`, and requests Razorpay Order ID.
2. **Razorpay SDK Event Handlers:**
   - `handlePaymentSuccess`: Extracts `razorpay_payment_id`, `razorpay_order_id`, `razorpay_signature` and sends to `/walkie/payments/verify`.
   - `handlePaymentError`: Routes user to `walkie_talkie_payment_failed_screen.dart`.
3. **Seat Allocation:** After successful verification, admin can distribute purchased seats among circle members using `WalkiePlanRepo.assignSeats()`.

