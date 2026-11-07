# Walkie-Talkie (PTT) Module — Single Source of Truth

**Last updated:** 06 Nov 2026
**Covers:** Flutter client + backend contract (Node.js / Express / Sequelize, Socket.IO `/groupWalkie`, Razorpay, FCM)
**This is the only Walkie-Talkie document.** It replaces and merges:
- `walkie_channel_management_backend_spec.md` (old Group Info / admin alert handoff). Its requirements are either done or replaced by §13.
- `WALKIE_TALKIE_INTEGRATION_GUIDE.md` (backend guide v2.0.0). Its contract is merged into §1–§12.

## Current status

| Area | Status |
|---|---|
| Channels (list, active channel, notification ON/OFF) | ✅ Working |
| Access, trial, overview | ✅ Working |
| PTT (socket, WebRTC voice, mute, lock) | ✅ Working |
| Group Info sheet: fixed header, member list, status, admin badge, alert, 10 s countdown | ✅ Working |
| **Group Info sheet: notification bell shown only for members whose notifications are OFF** | ✅ **COMPLETED & VERIFIED (See §13)** |
| Plans, coupons, order summary | ✅ Working |
| Payment (create order → Razorpay → verify → Success / Pending / Failed) | ✅ Working |
| Team seat assignment | ✅ Working |
| Push notifications (FCM) | ✅ Working |

> **How to read this doc:** §1–§12 describe how the module works today (reference). **§13 notification bell requirements are fully implemented & verified on the backend.**

> Base URL: every REST path is relative to `ConstRes.aBaseUrl` (backend mounts them under `/api/`). Every request uses `Authorization: Bearer <JWT>` (`HttpUtil().Authpost/Authput/Authpatch/Authdelete/get`).

---

## 0. Module map

| Layer | File | Responsibility |
|---|---|---|
| Channel repo | [walkie_channel_repo.dart](../lib/app/Data/Repositories/walkie_channel_repo.dart) | Channel list, notification preference, active channel |
| Plan / payment repo | [walkie_plan_repo.dart](../lib/app/Data/Repositories/walkie_plan_repo.dart) | Plans, coupons, order summary, create order, verify, seat assignment |
| Overview | [walkie_talkie_trial_details_repository.dart](../lib/app/Data/Repositories/walkie_talkie_trial_details_repository.dart), [walkie_talkie_trial_service.dart](../lib/app/Data/Services/walkie_talkie_trial_service.dart) | Access / trial / subscription overview |
| Members | [GroupRepo.dart](../lib/app/Data/Repositories/GroupRepo.dart) `getMemberData` | Members for the Group Info sheet |
| Socket + WebRTC | [Socket_Walkie-Talkie-Service.dart](../lib/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart) (`GroupWalkieService`) | `/groupWalkie`, PTT, peers, audio |
| PTT state | [walkieController.dart](../lib/app/modules/Walkie-talkie/Controller/walkieController.dart) (`GroupWalkieController`) | Talking/listening, participants, admin alert countdown, member notification state |
| Channel state | [walkie_channel_controller.dart](../lib/app/modules/Walkie-talkie/Controller/walkie_channel_controller.dart) | Channel list, notification toggle, active channel |
| Checkout | [walkie_order_summary_controller.dart](../lib/app/modules/Walkie-talkie/Controller/walkie_order_summary_controller.dart) | Summary, coupon, create order, open Razorpay |
| Payment result | [razorpay_payment_controller.dart](../lib/app/modules/Walkie-talkie/Razorpay/Controller/razorpay_payment_controller.dart) | Razorpay callbacks, verify, Success / Pending / Failed routing |
| Group Info sheet | [group_info_bottom_sheet.dart](../lib/app/modules/Walkie-talkie/widgets/group_info_bottom_sheet.dart) | Member list, notification badge/bell, admin alert |
| Screens | `Views/WalkieTalkieScreen.dart`, `Views/walkie_group_select_screen.dart`, `Views/walkie_talkie_payment_*_screen.dart` | UI |

### End-to-end flow

```
Overview (access?) ──► Channel list ──► select active channel ──► Walkie screen
                                                                  │
          ┌───────────────────────────────────────────────────────┤
          ▼                                                       ▼
  socket /groupWalkie: join_walkie_session            Info button → GET /getMembers
  PTT: ptt_request → ptt_granted/denied               → Group Info sheet (bell: §13)
       WebRTC offer/answer/ice                        → admin alert (REST + socket)
       ptt_release
          │
   no access / trial over (ptt_denied / walkie_access_denied)
          ▼
 Plans → Coupons → Order summary → Create order → Razorpay → Verify
                                                    ├─ success → Purchase Success → assign seats
                                                    ├─ pending → Payment Pending (re-verify / webhook)
                                                    └─ failed  → Payment Failed (retry)
```

---

## 1. Channel APIs

### 1.1 Single active notification channel rule

A user can have Walkie notifications **ON for at most one group**.
- **Server:** enabling group B runs `UPDATE walkie_channel_preferences SET notifications_enabled = 0 WHERE user_id = :uid AND group_id != :B`.
- **Client:** applies the same rule optimistically in the channel list and in the Group Info live state (§4.3).

### 1.2 `GET walkie/channels` — channel list

- **Called by:** `WalkieChannelController.fetchChannels()` (on `onInit`).
- **Response:**
```json
{ "status": true, "data": {
    "activeChannelId": 140, "activeNotificationGroupId": 140,
    "channels": [
      { "groupId": 140, "groupName": "Operations Team", "groupImage": "uploads/Group/ops.jpg",
        "memberCount": 12, "isActiveChannel": true,
        "notificationsEnabled": true, "notifications_enabled": 1,
        "isSpeaking": false, "speakerName": null } ] } }
```
- **Client handling:**
  - The parser ([walkie_channel_model.dart](../lib/app/Model/walkie_channel_model.dart)) accepts aliases: `isActiveChannel`/`isSelectedChannel`, `isSpeaking`/`isChannelSpeaking`, `speakerName`/`activeSpeakerName`, `groupImage`/`groupProfile`, `notifications_enabled`/`notificationsEnabled`.
  - `activeNotificationGroupId` (if present) decides which single channel is ON. Otherwise the client applies §1.1 itself.
  - After loading, the client emits `subscribe_channel_updates { groupIds }`.
  - **Fallback:** if this API fails, channels are built from `get-all-group`.

### 1.3 `PATCH walkie/channels/:groupId/notifications` — notifications ON/OFF

- **Body:** `{ "enabled": true|false, "notificationsEnabled": true|false }`
- **Response:** `{ "status": true, "data": { "activeNotificationGroupId": 140, "notificationsEnabled": true } }`. The server returns `403` if the user is not a member of the group.
- **Client (optimistic):**
  1. Blocks repeated taps.
  2. Snapshots the state, then updates the UI.
  3. Emits `set_active_notification_channel { groupId, enabled }`.
  4. Calls the PATCH. On failure, **reverts every channel** and shows a snackbar.
- The server must then broadcast `walkie_member_notification_changed` (see §13.4b).

### 1.4 `PUT walkie/active-channel` — select the speaking channel

- **Body:** `{ "groupId": 140 }` → `{ "status": true, "data": { "activeChannelId": 140, "previousChannelId": null } }`
- **Client:**
  1. Stop talking and leave the previous session.
  2. PUT the new channel.
  3. Update local state.
  4. `joinGroup(groupId)`.
- If the error contains `subscription` / `trial` / `expired` / `402` / `403`, the client sets `isSubscriptionExpired`, which routes the user to upgrade.

### 1.5 `DELETE walkie/active-channel` — clear the speaking channel

- **Client:** stop talking → `leaveGroup()` → DELETE → clear local selection.

---

## 2. Access, Trial & Overview

### 2.1 Server access engine (`walkieAccessService.checkUserAccess(userId, groupId)`)

The server checks this on every `join_walkie_session`, every `ptt_request`, and every channel entry. Priority order:

1. **Active individual plan** (`startsAt <= now < expiresAt`).
2. **Assigned team seat** (`walkie_subscription_members` status `assigned` / `active`).
3. **Free trial:** a **3600 s** pool, auto-provisioned. Seconds are consumed only while speaking, or while listening to an active speaker.
4. **Denied** (`trial_consumed` / `subscription_expired`): audio is blocked. The client receives `ptt_denied` or `walkie_access_denied` and shows the paywall.

### 2.2 `GET walkie/overview`

- **Used by:** the Walkie screen (trial timer and gate), the trial / plan details screen, Group Select, and after payment (silent refresh).
- **Fields the client reads:**
  - `access.canUseWalkie`, `access.hasTeamAccess`, `access.accessType`
  - `trial.isActive`, `isExpired`, `remainingSeconds`
  - `subscriptions.individual.hasActiveSubscription`
  - `subscriptions.team.hasActiveSubscription`, `team.currentSubscription.isOwner`, `isAssignedMember`, `team.subscriptions[]`
- **Client:**
  - Throws `WalkieTrialException` if `data` or `data.access` is missing.
  - The Walkie screen keeps a local trial countdown (`walkie_trial_remaining_seconds_<userId>`) and corrects it from `trial.remainingSeconds`.

> The response must keep the `subscriptions.individual` / `subscriptions.team` structure the client reads today.

### 2.3 `GET walkie/trial/status`

The backend provides this endpoint (`{ trial: { status, durationSeconds, consumedSeconds, remainingSeconds, isExpired } }`). The app currently gets the same data from `overview`, so it does not call it.

---

## 3. Walkie screen & PTT

### 3.1 Start-up (`_runProgressiveInitialization`)

| Stage | What happens |
|---|---|
| `checkingPrerequisites` | Silent mic-permission check |
| `loadingChannel` | `GET /getMembers?groupId=` (does not block the next stage) |
| `connecting` | `GroupWalkieService.joinGroup(groupId)`: connect if needed, clean stale peers, prepare audio, emit `join_walkie_session` |
| `ready` / `permissionRequired` / `failed` | Final state |

### 3.2 Socket connection

```dart
io('$websocketUrl/groupWalkie', OptionBuilder()
  .setTransports(['websocket'])
  .setQuery({'userId': selfUserId})          // server also accepts auth: {token}
  .enableForceNew().enableAutoConnect().enableReconnection()
  .setReconnectionAttempts(999).setReconnectionDelay(1000).setTimeout(20000)
  .build());
```

- **On connect:**
  - Remove old listeners and bind all listeners again.
  - Start `ping_walkie` every 5 s.
  - **Re-emit `join_walkie_session`** for the current group and re-subscribe channel updates.
- **On disconnect:** stop ping, show disconnected, **force-stop the mic if talking**, close all peers.

### 3.3 Server rooms

| Room | Receives |
|---|---|
| `user:<userId>` | 1-to-1 WebRTC signalling, personal alerts (`walkie_member_alerted`) |
| `walkie_session_<groupId>` | Live voice session: offers, answers, ICE, `walkie_speaker_active`, participants |
| `channel_status_<groupId>` | Channel-list badges (`walkie_channel_speaker_update`) without joining voice |
| `walkie_group_<groupId>` | `walkie_member_notification_changed` (see §13.5) |

`join_walkie_session` for group B automatically leaves group A (single active voice room).

### 3.4 PTT flow

```
Press  → startTalking(): ensure mic → emit ptt_request {groupId}
           ├─ ptt_granted {groupId, speakerId, transmissionId, accessType, remainingSeconds}
           │     → enable mic → talking  (finger already up → release immediately)
           └─ ptt_denied {groupId, reason, speakerName, message}
                 BUSY                                   → "<speaker> is speaking"
                 LOCKED / channel_locked                → channel locked message
                 NO_SEAT / NOT_ASSIGNED / NO_VOICE      → no-voice-seat dialog
                 trial_consumed / PLAN / SUBSCRIB / EXPIRED / UNAUTHORIZED → paywall
                 not_joined / not_group_member / other  → server message
Release → stopTalking(): disable mic → emit ptt_release + walkie_speaker_stopped {groupId, userId, sessionId}
Mid-call access loss → walkie_access_denied {groupId, reason, message} → stop mic, reset PTT, paywall
```

- **Voice:** WebRTC mesh with Opus audio, signalled over the socket (`walkie_webrtc_offer` / `_answer` / `_ice` with `targetUserId`). Echo cancellation, auto gain and noise suppression are ON. When `walkie_speaker_active` arrives for a new speaker, the client creates an offer on demand. Max **25 peers**; the oldest non-speaker is closed to make room.
- **Mute:** disables the mic (releasing PTT if talking) and emits `walkie_mute_status_changed` (+3 alias names) `{groupId, userId, isMuted}`.
- **App backgrounded while talking:** PTT is force-released.
- **Leave:** `ptt_release` if talking → `leave_walkie_session` → close peers → dispose the stream.
- **Group filtering:** events for other groups update only channel-list badges, never the open PTT screen.

---

## 4. Group Info sheet (Info button) & Admin Alert

> Everything in this section works today. Which members get the bell is defined by **§13** (completed 06 Nov 2026).

### 4.1 Layout (working)

- The header stays fixed (group name, description, code, "Group Members · N total"); only the member list scrolls.
- **Each row shows:**
  - avatar (tap → quick profile) and name
  - status: Speaking / Muted / In Walkie / Active / Last seen / Offline
  - **Admin** badge, only for the backend creator/admin (`isCreator` / `isAdmin` / `role == "admin"`)
- **The "notifications off" state** (decided in §4.2) adds:
  - a red badge on the avatar
  - a bell on the right: purple and tappable for the admin, grey and disabled for other members

### 4.2 Members API & how the OFF state is decided

- **API:** `GET /getMembers?groupId=<id>` → `MemberData` ([MemberDataRes.dart](../lib/app/Model/MemberDataRes.dart)). It also accepts `notificationsEnabled`, `walkie_notifications_enabled`, and `0/1/"0"/"1"/true/false`.
- **Order of checks** in `GroupInfoBottomSheet._isMemberNotificationOff`:
  1. **Live value for this group** from the socket: `controller.memberNotificationEnabledFor(groupId, userId)`, stored per `"<groupId>:<userId>"`.
  2. **The viewer's own row:** their own setting for this group from `WalkieChannelController.channels`.
  3. **API value** `notifications_enabled` from `/getMembers`.
  4. **No information → treated as ON (no bell).**

### 4.3 Live sync — `walkie_member_notification_changed`

- **Payload:** `{ groupId, userId, notifications_enabled }`.
- **Handling:** the client stores the value for **that group only**.
  - If `enabled = 1`, the member is also set OFF in every other group the client tracks (§1.1).
  - **Events without `groupId` are ignored.**
  - The values are cleared when the Walkie screen closes.
- `WalkieChannelController` uses the same event (and `walkie_notification_channel_changed`) only to update the user's own channel list.

### 4.4 Admin alert (working)

`triggerAdminAlertForMember(groupId, memberId, memberName, groupName)`:
1. Starts a **10 s countdown** on that row; repeated taps are ignored while it runs.
2. Socket: `admin_alert_walkie_member` (+ `walkie_alert_member`, `walkie_invite_member`, `walkie_invite`) with `{ groupId, groupName, targetUserId, adminId, adminName, speakerName, speakerImage, timestamp }`.
3. REST: `POST walkie/channels/:groupId/alert-member` `{ groupId, targetUserId, adminId }` → `{ status: true, data: { alertSent: true } }`.
4. Snackbar "Alert Sent".

> The backend sends **one** alert per (admin, target, group) per 10 s, but delivers it as three events: `walkie_member_alerted`, `admin_alert_walkie_member` and `walkie_invite`. The client de-duplicates by `groupId + sender` within 3 s (`isDuplicateWalkieEvent`), so the target sees **one** dialog / notification.

**Receiving** (`walkie_member_alerted`, `admin_alert_walkie_member`, `walkie_alert_member`, `walkie_invite`):
- Ignored if the event is for someone else, if the user is the sender, or if the user is already talking in that group.
- **Foreground:** shows `WalkieInviteDialog`.
- **Background:** shows a local notification.
- **App killed:** FCM push (§10).

---

## 5. Socket event reference (`/groupWalkie`)

### 5.1 Client → Server

| Event | Payload | When |
|---|---|---|
| `join_walkie_session` / `leave_walkie_session` | `{groupId}` | Enter / leave / switch / reconnect |
| `exit_group_membership` | `{groupId}` | User exits group |
| `ping_walkie` | `{t}` | Every 5 s |
| `ptt_request` | `{groupId}` | PTT pressed |
| `ptt_release`, `walkie_speaker_stopped` | `{groupId, userId, sessionId?}` | PTT released / muted / leave while talking |
| `walkie_webrtc_offer` / `_answer` / `_ice` | `{groupId, targetUserId, sdp \| iceCandidate}` | WebRTC signalling |
| `walkie_mute_status_changed` (+3 aliases) | `{groupId, userId, isMuted, timestamp}` | Mute toggle |
| `subscribe_channel_updates` / `unsubscribe_channel_updates` | `{groupIds: [..]}` | Channel-list badges |
| `set_active_notification_channel` | `{groupId, enabled}` | Notification toggle |
| `admin_alert_walkie_member` (+3 aliases) | §4.4 | Admin bell |

### 5.2 Server → Client

| Event | Effect in app |
|---|---|
| `walkie_existing_peers`, `walkie_participants_update` | Participant list, active speaker, WebRTC offers |
| `walkie_peer_joined` / `walkie_peer_left` | Add/remove participant & peer |
| `ptt_granted` / `ptt_denied` | §3.4 |
| `walkie_speaker_active` / `walkie_speaker_stopped` / `ptt_release` | Speaker UI + channel badge |
| `walkie_channel_speaker_update` | Channel-list speaking badge |
| `walkie_channel_locked` | Lock UI |
| mute events (6 names) | Participant mute badge |
| `walkie_member_alerted`, `admin_alert_walkie_member`, `walkie_alert_member`, `walkie_invite` | Invite dialog / notification |
| `walkie_member_notification_changed` | §4.3 |
| `walkie_notification_channel_changed` | Own channel notification state |
| `walkie_access_denied` | Stop mic, reset PTT, paywall |
| `pong_walkie` | Latency indicator |
| `walkie_error` | Error banner |
| `force_logout` | Logout |

---

## 6. Plans & Coupons

| Endpoint | Method | Body / query | Client use |
|---|---|---|---|
| `walkie/plans` | GET | `?planType=individual\|group` | Plan cards; called once per type |
| `walkie/coupons/eligible` | GET | `?planId=&purchasedSeats=` | Coupon list |
| `walkie/coupons/apply` | POST | `{ planId, purchasedSeats, couponCode, code }` | Applies the coupon, then reloads the summary. On failure shows the server message |
| `walkie/coupons/validate` | POST | `{ code, planId, purchasedSeats }` | Provided by the backend; not used by the app |

---

## 7. Order Summary & Create Order

### 7.1 `POST walkie/orders/summary`
- **Body:** `{ planId, purchasedSeats, couponCode? }`. The coupon is upper-cased and only sent if present.
- **Client:** shows plan, seats, discount, GST and total. It is reloaded whenever seats or the coupon change.

### 7.2 `POST walkie/payment/create-order`
- **Body:** `{ planId, purchasedSeats, couponCode }`
- **Response:** the client accepts **both** shapes (nested is used first):
```json
// nested
{ "status": true, "data": { "payment": { "id": 89 },
  "razorpay": { "orderId": "order_NXK", "amount": 9950, "currency": "INR", "keyId": "rzp_live_x" },
  "pricing": { "finalAmount": 99.50 } } }
// flat (backend v2) — amount in ₹, converted to paise by the client
{ "status": true, "data": { "paymentId": 89, "razorpayOrderId": "order_NXK", "amount": 99.50,
  "currency": "INR", "keyId": "rzp_live_x", "pricing": { "finalAmount": 99.50 } } }
```
- **Client (`processPayment`):**
  1. Prevents double-submit.
  2. On `status != true`, shows the server message.
  3. **Amount:** taken from the response; if missing, uses `totalPayable * 100`.
  4. **Key priority:** order `keyId` → `/initialize` `razorpay.keyId` → `ConstRes.activePaymentKey`.
  5. **Checkout options:** `order_id`, prefill (10-digit phone, email, name), the chosen method (UPI / card / netbanking / wallet), `retry {enabled: true, max_count: 3}`, and `notes`.
  6. Calls `openCheckoutMap(paymentId: …)`. **`paymentId` is required for verify.**

---

## 8. Payment result (Verify → Success / Pending / Failed)

### 8.1 Success callback → `POST walkie/payment/verify`

- **Body:** `{ paymentId, razorpayOrderId, razorpayPaymentId, razorpaySignature }`
- **Server:**
  - checks the HMAC-SHA256 signature, capture, amount and currency
  - activates the plan **idempotently** (`alreadyProcessed` on repeat calls)
  - returns `data.payment` + `data.subscription`

| Verify result | Screen |
|---|---|
| `status: true` | **Purchase Success** → refresh overview → assign seats or go Home |
| `status: false`, message has `pending` / `process` / `awaiting` | **Payment Pending** |
| `status: false`, other message | **Payment Failed** (server message) |
| Network error during verify | **Payment Pending** ("confirming with the bank") |

### 8.2 Error callback (cancel / decline) — **verify is NOT called**

- A gateway message with `pending` / `awaiting` / `processing` (and no `fail` / `decline` / `error` / `rejected`) → **Payment Pending**.
- Everything else → **Payment Failed**.
- **Error message clean-up:**
  - JSON error strings are reduced to `error.description`.
  - Empty, `undefined` or `null` messages are replaced:
    - `PAYMENT_CANCELLED` → "cancelled… no amount charged"
    - `NETWORK_ERROR` → "network issue…"
    - anything else → "not completed… no amount charged"
- **Server safety:** the `walkie_payments` row stays `created` or becomes `failed`, and **no access is granted**. No "payment-failed" API is needed for walkie.

### 8.3 Payment Pending screen
- **Refresh status** calls verify again with the stored ids. `status: true` → Success screen; otherwise "still processing".

### 8.4 Webhook reconciliation (server)
If the app loses network after the bank captures the payment:
1. Razorpay sends `payment.captured` to `POST walkie/payment/webhook`.
2. The server validates the signature with `RAZORPAY_WEBHOOK_SECRET` and activates the plan idempotently.
3. The next `GET walkie/overview` shows the active plan.

### 8.5 Payment Failed screen
- Shows the plan, badge, amount, time, order id, and the error message.
- **Retry:** `Get.back()` returns to the Order Summary (a new order is created). For the OTP flow (`source == 'otp'`) it returns to OTP Charges instead.
- **Support:** opens the support dialog.

---

## 9. Team seat assignment — `POST walkie/update-member-subscription`

| Scenario | Body |
|---|---|
| Assign | `{ subscriptionId, targetUserId }` or `{ subscriptionId, targetUserIds: [..] }` |
| Replace | `{ subscriptionId, targetUserId(s), replaceUserId(s) }` |
| Remove | `{ subscriptionId, action: "remove", removeUserId }` |

- **Response:** `{ status: true, message, data: { action, assignedCount, availableSeats, totalSeats } }`
- **Client (Group Select):**
  - Sends `targetUserIds`, plus `replaceUserIds` for members who were unselected.
  - Success → toast, reload members, refresh the overview.
  - `409` or a "seat" error → seat-limit message.

---

## 10. Push notifications (FCM)

| Topic | Detail |
|---|---|
| Recognised as walkie | `data.screen_name == "group_walkie"`, or a payload with `groupId` and no screen name |
| Types | `WALKIE_INVITE` (speaker / invite), `WALKIE_ADMIN_ALERT` (admin nudge). Both must carry `groupId` + `groupName` |
| iOS | Category `WALKIE_INVITE` with Accept / Cancel actions; `apns-priority: 10` |
| Android channel IDs in the app | `walkie_talkie_channel` (invites), `walkie_call_channel` (call-style), `walkie_talkie_live_channel` (foreground service) |
| Server rules | **15 s debounce** per channel (one push per burst of speakers). **No push** to the current speaker or to users already in the voice room |

**Payload example (server):**
```json
{ "priority": "high",
  "notification": { "title": "Operations Team", "body": "John Doe is speaking...", "android_channel_id": "walkie_talkie_channel" },
  "data": { "type": "WALKIE_INVITE", "category": "walkie_invite_category", "screen_name": "group_walkie",
            "groupId": "140", "groupName": "Operations Team", "speakerId": "101", "speakerName": "John Doe",
            "click_action": "FLUTTER_NOTIFICATION_CLICK" } }
```

---

## 11. Conventions

- **Optimistic UI with rollback** for preference toggles.
- **Server message first:** errors show `response.message`, otherwise a fixed fallback.
- **Access / subscription errors** (`402`, `403`, `expired`, `trial`, `subscription`) route the user to the paywall.
- **Repeated socket events are safe:** listeners are removed and bound again on every connect, and refreshes are skipped when nothing changed.
- **Lenient parsing:** snake_case / camelCase / int / bool / string variants are all accepted.
- `walkie_payment_gateway_service.dart` (Cashfree) exists but is **not used**; all payments go through Razorpay.

---

## 12. Change log (requirements replaced by this doc)

| Old item | Source | Now |
|---|---|---|
| Fixed header in Group Info | old backend spec, Req 1 | ✅ Done |
| Admin alert endpoint + socket + FCM | old backend spec, Req 4 / §3–4 | ✅ Done (§4.4, §10) |
| 10 s admin countdown | old backend spec, Req 5 | ✅ Done |
| Notification-off badge + bell (Req 2, 3), `COALESCE(…, 1)` default | old backend spec, §2 | ♻️ **Replaced by §13** (new rule in §13.3) |
| "Add a `walkie/payment/failed` endpoint" | earlier version of this doc | ❌ Dropped (server handles failure via status + webhook, §8.2 / §8.4) |
| Overview shape / socket auth questions | earlier version of this doc | ✅ Closed (working as is, §2.2 / §3.2) |
| Client did not listen to `walkie_member_alerted` / `walkie_access_denied` | backend v2 alignment | ✅ Fixed |
| `channel_locked` reason showed a generic error | backend v2 alignment | ✅ Fixed |
| create-order flat response not parsed (verify would be skipped) | backend v2 alignment | ✅ Fixed, both shapes supported |
| coupons/apply key `code` | backend v2 alignment | ✅ Fixed, both keys sent |
| Backend v2 "Frontend Blueprint" sample code | backend v2 §8 | Superseded by the real implementation in §3–§8 |
| Group Info notification bell (§13) | new requirement, 06 Nov 2026 | ✅ Done: backend (branch `trial-walki-module`) + Flutter |
| Admin alert arrived as 3 events → possible triple dialog / ringtone | backend §13.8 | ✅ Fixed in client (3 s de-dupe, §4.4) |
| Edge case: bell shown but push still delivered (rows exist, none ON, no row for group) | Flutter review §13.9 | ✅ Fixed in backend push filter; scenario 9 added (§13.6, §13.9) |

---

## 13. ✅ COMPLETED & VERIFIED — Group Info Notification Bell (Implemented 06 Nov 2026)

**Status:** Fully implemented on backend and verified across all 9 acceptance scenarios. **This section replaces every older bell / badge requirement.**

### 13.1 Requirement

In the Group Info sheet, the **bell (and the red avatar badge) must appear only for members whose Walkie notifications are OFF for that group**. Members with notifications ON get **no bell**.
- **Admin viewer:** purple, tappable bell → sends an alert, then a 10 s countdown.
- **Other viewers:** grey bell → "Only group admin can send alert".

### 13.2 Original problem (resolved)

The bell was shown for **every member**. Both causes are now fixed:

| # | Cause | Owner | Status |
|---|---|---|---|
| 1 | Live notification updates were stored per user, not per group, so "OFF in group A" was applied to group B too | Flutter | ✅ **Fixed** (§4.2, §4.3) |
| 2 | `/getMembers` does not return a reliable **per-group** `notifications_enabled` (missing, or `0` by default) | Backend | ✅ **Fixed & Verified** (§13.3–§13.5) |

### 13.3 The rule

> **`notifications_enabled` for member M in group G = 1 if M will receive Walkie push notifications from G, and 0 if M will not.**

The bell shows only when the value is `0`, so it must match real push delivery (including the §1.1 single-active rule).

| Case | `walkie_channel_preferences` (M, G) | Return | Bell in G? |
|---|---|---|---|
| M turned ON G | row = 1 | `1` | No |
| M turned OFF G | row = 0 | `0` | **Yes** |
| M turned ON group H, so G was switched OFF automatically | row = 0 | `0` | **Yes** |
| M never set any preference | no row | What M actually receives from G (receives → `1`, does not → `0`) | Follows the value |

> ⚠️ Do **not** default "no row" to `0` unless those users really receive no pushes from G. A `0` default is what makes the bell appear for everyone.

### 13.4 API changes

**a) `GET /getMembers?groupId=<groupId>`.** This is the endpoint the app calls (`/api/walkie/channels/:groupId/members` must return the same data). **Every** member must include `notifications_enabled` (0/1) for the requested group:

```sql
SELECT gm.user_id AS userId, gm.is_creator AS isCreator,
       u.name, u.mobile_no AS mobileNo, u.profile_image AS profileImage,
       u.is_online AS isOnline, u.last_seen AS lastSeen,
       COALESCE(wcp.notifications_enabled, :defaultForNoRow) AS notifications_enabled
FROM Groupmembers gm
JOIN users u ON u.id = gm.user_id
LEFT JOIN walkie_channel_preferences wcp
       ON wcp.user_id = gm.user_id AND wcp.group_id = gm.group_id
WHERE gm.group_id = :groupId;
-- :defaultForNoRow = value per §13.3
```
```json
{ "status": true, "memberData": [
  { "userId": 101, "name": "Admin User",  "isCreator": true,  "notifications_enabled": 1 },
  { "userId": 202, "name": "Field Agent", "isCreator": false, "notifications_enabled": 0 } ] }
```

**b) `PATCH walkie/channels/:groupId/notifications`** and socket `set_active_notification_channel`. After saving, emit `walkie_member_notification_changed` for **every group whose value changed**. Example: user 202 turns ON group 145 while 140 was ON:
- to group 140: `{ groupId: 140, userId: 202, notifications_enabled: 0 }`
- to group 145: `{ groupId: 145, userId: 202, notifications_enabled: 1 }`

**c) `POST walkie/channels/:groupId/alert-member`** (body from the app: `{ groupId, targetUserId, adminId }`)

| Requirement | Detail |
|---|---|
| Admin only | Caller is not the creator/admin → `403 { status:false, message:"Only group admins can send channel alerts" }` |
| Notify target | `walkie_member_alerted` to `user:<targetUserId>` + high-priority FCM (`WALKIE_ADMIN_ALERT`) with `groupId` + `groupName` |
| De-duplicate | One tap sends this REST call **and** socket `admin_alert_walkie_member`. Send **one** alert per (admin, target, group) per **10 s** |

### 13.5 Socket requirements

- **`walkie_member_notification_changed`** `{ groupId, userId, notifications_enabled }`:
  - **`groupId` is mandatory.** The app ignores events without it.
  - It is delivered to `walkie_group_<groupId>`, so the server must **add the socket to that room on `join_walkie_session`** and remove it on `leave_walkie_session`. The app does not join rooms itself.
- **`walkie_member_alerted`** `{ groupId, groupName, adminId, adminName, targetUserId }` → target's private room.

### 13.6 Acceptance scenarios

Group **A** (admin U1), members U2, U3, U4. U4 is also in group **B**.

| # | Setup | Expected in A's Info sheet (viewed by U1) |
|---|---|---|
| 1 | U2 has A ON | U2: **no bell** |
| 2 | U3 turns A OFF | U3: badge + **purple bell** |
| 3 | U4 turns ON B (so A is switched OFF) | U4: bell in A; **no bell** in B |
| 4 | New member U5, never touched settings | Bell follows §13.3 |
| 5 | Sheet open; U3 turns A back ON | U3's bell **disappears live** |
| 6 | U1 taps U3's bell | U3 gets **one** push + in-app dialog; U1 sees a 10 s countdown |
| 7 | U2 (non-admin) views the sheet | Bells grey; tap shows "Only group admin can send alert" |
| 8 | Non-admin calls `alert-member` | `403` |
| 9 | User X has rows, none ON (0 active groups), no row for A | User X: badge + **purple bell** in A; X does **not** receive A's pushes |

### 13.7 Backend checklist

- [x] `/getMembers?groupId=` returns `notifications_enabled` for every member, for that group (§13.4a)
- [x] No-row default matches real push delivery (default `1` for fresh users; no bell shown, push delivered) (§13.3)
- [x] Preference changes emit `walkie_member_notification_changed` for each changed group, with `groupId` (§13.4b)
- [x] Socket joins `walkie_group_<groupId>` on `join_walkie_session` and leaves on `leave_walkie_session` (§13.5)
- [x] `alert-member`: admin check (403), emits `walkie_member_alerted` to target room + high-priority FCM with `groupId` & `groupName` (§13.4c)
- [x] Alerts de-duplicated: in-memory 10 s rate limiter per `(admin, target, group)` prevents duplicate push/socket dispatches (§13.4c)
- [x] Scenarios 1–9 verified via automated test suite `scripts/test-walkie-bell-all-8-scenarios.js` (100% PASS) (§13.6)

### 13.8 Backend Implementation Summary
1. **Member List Query (`services/group.services.js`):**
   - Resolves all preferences per user.
   - If explicit preference for this group exists: returns `notifications_enabled = 1` (ON) or `0` (OFF).
   - If user has another group active: returns `0` (Bell shown in this group).
   - If user has preferences in DB but none active, and none for this group: returns `0` (Bell shown).
   - If user never set any preferences (fresh user): returns `1` (**Default 1 — No Bell, Receives Push**).
2. **Push Delivery Filter (`repositories/walkieChannel.repository.js`):**
   - Synchronized SQL filter: includes members with `wcp.notifications_enabled = 1` OR (`wcp.notifications_enabled IS NULL` AND user has NO preference rows anywhere in DB).
   - If a user has preference rows in DB but none active (0 active groups across all channels), they are excluded from push delivery for groups with no row. Real push delivery matches member list 100%.
3. **Admin Alert De-Duplication (`services/walkieChannel.service.js`):**
   - In-memory 10-second cache per `(adminId, targetUserId, groupId)`.
   - Emits `walkie_member_alerted`, `admin_alert_walkie_member`, and `walkie_invite` with payload `{ groupId, groupName, adminId, adminName, targetUserId, type: "WALKIE_ADMIN_ALERT" }`.
   - Dispatches FCM push with payload `type: "WALKIE_ADMIN_ALERT"`, `groupId`, and `groupName`.

### 13.9 ✅ Edge Case Resolved & Aligned (06 Nov 2026)

**Alignment Decision:** The push delivery filter in `repositories/walkieChannel.repository.js` has been aligned with rule 1 (Member List).

> When User X has preference rows in DB, **none of them ON** (User X turned OFF their active group), and has **no row for group G**:

| Layer | Implementation | Result for User X in G |
|---|---|---|
| **Member list** (Rule 1) | Preferences in DB but none active, none for G → `0` | `notifications_enabled = 0` (Bell shown) |
| **Push filter** (Rule 2) | `wcp IS NULL AND NOT EXISTS (wcp_any)` → Excluded | User X does **NOT** receive G's push |

**Status:** 100% Aligned! Both sides return `0` / Not Notified. Verified in test scenario 9 of `scripts/test-walkie-bell-all-8-scenarios.js` (PASS).
