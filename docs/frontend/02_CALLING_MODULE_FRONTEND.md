# Calling Module — Flutter Frontend Architecture & Implementation Guide

**Document Version:** `v1.1.0`  
**Target Audience:** Flutter Frontend Developers  
**Covers:** Single & Group Audio/Video Calls, WebRTC PeerConnection, CallKit/CallKeep, Audio Routing, Proximity Sensor, PIP Floating Bubble, Call History & Call History Details Screen  
**Status:** In Production / Stable  

---

## 0. Architecture & File Registry

| Layer | File Path | Core Responsibility |
|---|---|---|
| **Repositories** | `lib/app/Data/Repositories/call_repo.dart` | Communicates with `/recentCallHistory`, `/getCallDetail`, `/updateCallingStatus` |
| **Single Signaling** | `lib/app/Data/Services/Socket/Socket_SignallingService.dart` | Connects to `/callSignaling` namespace; handles `makeCall`, `answerCall`, ICE exchange |
| **Group Signaling** | `lib/app/Data/Services/Socket/Socket_Group_Calling.dart` | Connects to `/groupCall` namespace; coordinates multi-peer mesh WebRTC |
| **CallKit Service** | `lib/app/Data/Services/IncommingCallKit/callkit_service.dart`<br>`lib/app/Data/Services/IncommingCallKit/call_session.dart` | Integrates iOS CallKit & Android Telecom framework; lock screen ring UI |
| **Audio Routing** | `lib/app/modules/mediaStream/Controller/call_audio_route_controller.dart` | Controls hardware output: Speaker, Earpiece, Bluetooth SCO |
| **Single Call State** | `lib/app/modules/mediaStream/Controller/calling_controller.dart` | WebRTC lifecycle, camera flip, proximity screen lock, timer |
| **Group Call State** | `lib/app/modules/mediaStream/Controller/group_calling_controller.dart` | Mesh peer connections, screen sharing track swap, roster state |
| **Call History State**| `lib/app/modules/call/Controller/call_controller.dart` | Pagination, filter chips (All/Missed/Incoming/Outgoing), dial pad, multi-delete |
| **Call Details State**| `lib/app/modules/mediaStream/Controller/contact_profile_controller.dart` | Fetches session audit via `CallRepo.getCallHistoryDetail(callId)` |
| **Screens & Views** | `lib/app/modules/call/Views/call_screen.dart`<br>`lib/app/modules/mediaStream/Views/calling_screen.dart`<br>`lib/app/modules/mediaStream/Views/AudioCall_screen.dart`<br>`lib/app/modules/mediaStream/Views/Group/group_calling_screen.dart`<br>`lib/app/modules/mediaStream/Views/contact_profile_screen.dart` | Visual presentation layers |

---

## 1. Single 1-on-1 Call Flow (`CallingController`)

### 1.1 Outgoing Call Setup
1. Launch `Routes.callScreen` with arguments:
   ```dart
   Get.toNamed(Routes.callScreen, arguments: {
     'callerId': selfUserId,
     'remoteUserId': targetUserId,
     'callId': generatedCallId,
     'is_video': isVideo,
     'callType': 'Outgoing',
     'callerName': targetUserName,
     'profileImage': targetUserProfile,
   });
   ```
2. Initialize WebRTC:
   - Request audio & video tracks via `navigator.mediaDevices.getUserMedia()`.
   - Create `RTCPeerConnection` with STUN/TURN servers.
   - Attach tracks: `localStream!.getTracks().forEach((t) => peer!.addTrack(t, localStream!))`.
   - Create SDP offer and set local description.
   - Emit `makeCall` on `/callSignaling` socket.
3. Start ringtone: `FlutterRingtonePlayer.play(fromAsset: "assets/ringtone/outgoing.mp3", looping: true)`.
4. Start 45s missed call timeout: If unanswered, trigger `updateCallingStatus(callingStatus: 'missed')`.

### 1.2 Incoming Call Setup & CallKit
1. Incoming call captured in background via FCM or in foreground via `newCall` socket event.
2. `CallKitService.showCallkit()` displays system ring UI.
3. User Taps **Accept**:
   - `CallKitService.onAcceptCall` executes.
   - Navigates to `Routes.callScreen` with compressed offer from extra data.
   - `CallingController` sets remote description `peer.setRemoteDescription(offer)`.
   - Generates SDP answer and emits `answerCall`.
   - Renders remote media in `remoteRenderer`.
4. User Taps **Decline**:
   - `CallKitService.onDeclineCall` emits `callRejected` and invokes `updateCallingStatus(callingStatus: 'rejected')`.

---

## 2. Group Calling Architecture (`GroupCallingController`)

### 2.1 Multi-Peer Mesh Rendering
- Maintains independent `RTCPeerConnection` for each peer in `_peers` map.
- Up to 4 active video streams are rendered in a responsive grid layout. If participant count exceeds 4, remaining members are displayed in an audio-only speaking pill at the top of the screen.
- Dynamic roster updates are processed via `group_call_participants_update`.

### 2.2 Picture-in-Picture (PIP) Floating Bubble
- Allows users to minimize active group calls and continue using the app.
- Managed by `group_call_pip_bubble.dart`.
- Uses draggable overlay widget containing remote video stream or active speaker avatar, mute toggle, and hangup button.

---

## 3. Screen Sharing Subsystem

1. Triggered via screen sharing icon in bottom controls.
2. Captures screen via `navigator.mediaDevices.getDisplayMedia({'video': true, 'audio': false})`.
3. In 1-on-1: Negotiates secondary high-bitrate peer connection `_screenPc` or replaces camera video track.
4. In Group Call: Emits `group_call_screen_share_started` socket event. Peers attach stream to dedicated full-screen renderer (`fullScreenShareUserId.value = sharingUserId`).
5. Termination: Emits `group_call_screen_share_stopped` and restores camera track.

---

## 4. Hardware Management (Audio Routing & Proximity Lock)

### 4.1 Audio Routing (`CallAudioRouteController`)
- Supports dynamic switching between `Speaker`, `Earpiece`, and `Bluetooth`.
- Defaults:
  - Audio call defaults to `Earpiece` (or connected Bluetooth headset).
  - Video call and Group call default to `Speaker`.
- Bottom sheet `audio_route_sheet.dart` displays selectable routes.

### 4.2 Proximity Screen Lock
- For 1-on-1 and Group audio calls, `ProximityScreenLock.setActive(true)` activates proximity sensor.
- When the phone is held against the ear, screen automatically blanks and touch is disabled to prevent accidental button presses.
- Auto-restores screen when phone is pulled away.

---

## 5. Call History & Call History Details Screen

### 5.1 Call History Screen (`call_screen.dart`)
- **Tabs:**
  - `Recent Calls`: Paginated list via `CallRepo.getRecentCall()`. Filter chips: `All`, `Missed`, `Incoming`, `Outgoing`.
  - `Contacts`: Organization contacts with one-tap dial buttons.
  - `Groups`: Team circles with instant group call initiation.
- **Dial Pad Modal (`call_dial_pad.dart`):** Numeric keypad with instant T9 live contact search.
- **Multi-Selection Deletion:** Long-press a row to select calls, then delete them together. See [5.3](#53-recent-calls--multi-select-delete).

### 5.2 Call History Details Screen (`contact_profile_screen.dart`)
- Triggered by tapping the Info icon `(i)` on any recent call tile.
- Loads audit metrics via `CallRepo.getCallHistoryDetail(callId)`.
- **Displays:**
  - Full contact avatar, name, phone, and online badge.
  - Session metadata: Call Type (Audio/Video), Direction, Status (`ended`, `missed`, `rejected`).
  - Formatted duration (`Xm Ys` or `0s`).
  - Exact start and end timestamps.
  - Group Call Breakdown: Shows list of all invited group members, who joined, join/leave timestamps.
  - Quick action buttons: Return Call, Video Call, Open Chat, Delete Record.

### 5.3 Recent Calls — Multi-select Delete
The 3-dot menu in the Call screen header (Recent tab) is removed. Its only option was "Delete Call". Selection now starts with a long-press on a row.

**Flow**
1. **Normal mode (unchanged):**
   - Tap a row → call history details.
   - Tap the avatar → quick profile.
   - Tap the call icon → call back.
   - Swipe left → delete one call.
2. **Long-press a row** → selection mode starts with that row selected (light haptic).
3. **In selection mode:**
   - Tap a row or its avatar → select / unselect it.
   - Selected rows get a `#EEEDFD` background and a filled `#704AFA` check circle on the avatar. Unselected rows show an empty circle.
   - The call icon is hidden; its space is kept so the layout doesn't move.
   - Swipe is off.
4. **Top bar** replaces the header: `✕` · `<n> selected` · `Select all` / `Unselect all`.
   - Select all picks only the rows visible under the current search / filter.
5. **Bottom button:** a red **Delete (n)** button, shown when at least 1 call is selected.
6. **Exit selection mode** with `✕`, Android back, Unselect all, unselecting the last row, switching tab, or opening the Call screen again.

**Delete**
- **Confirm dialog:** "Delete n call(s)?" / "These calls will be removed from your call history." / Cancel · Delete (red).
- **API:** `CallRepo.deleteMultipleCallHistory(callIds)` (bulk; see backend doc §3.4).
- **Optimistic:** rows disappear at once.
  - **Success:** snackbar "n call(s) deleted", and selection mode ends.
  - **Failure** (for example, no internet): the bulk call is all-or-nothing, so every row comes back in its old place, still selected. Snackbar: "Couldn't delete n call(s). Try again."
- **While deleting:**
  - The Delete button shows a loader and can't be pressed again.
  - ✕ and Select all are disabled.
  - Pull-to-refresh is ignored.

**Code**

| File | What |
|---|---|
| `call_controller.dart` | `isSelecting` / `selectedIds` (same objects as `isSelectionMode` / `selectedCallIds`), `startSelection(id)`, `toggle(id)`, `selectAll()`, `clearSelection()`, `areAllVisibleSelected`, `deleteSelected()`. `_rebuildRecentDisplay()` drops selected ids that are no longer in the list, and new rows arrive unselected. `refreshRecentCalls()` is skipped during a delete. |
| `call_recent_calls_tab.dart` | Long-press → `startSelection`, check circle on the avatar, hidden call icon, `RecentCallsSelectionBar` + confirm dialog, bottom Delete button. The old long-press sheet and old dialog are kept but unused (`// moved to selection bar`). |
| `call_screen.dart` | Header 3-dot removed; the selection bar replaces the header while selecting; selection cleared on screen open. |

**Test cases (Android + iPhone)**
1. No 3-dot in the header; row layout unchanged.
2. Tap a row in normal mode → same as before.
3. Long-press → selection mode, row selected, haptic.
4. Tap other rows → toggle; counter correct; Select all / Unselect all work.
5. Delete 3 → confirm → rows removed, snackbar; still gone after refresh.
6. Delete with no internet → rows restored + error snackbar.
7. ✕ / Android back / n = 0 → exits selection.
8. Pull-to-refresh / pagination while selecting → new rows unselected, selection kept.
9. Calling, call details, Contacts / Groups tabs unchanged.

**Known limitations**
- There is no recent-calls count on screen, so only the list updates.
- New calls don't arrive live; the list updates on refresh or pagination.
- Bulk delete is all-or-nothing, so a failure restores every selected row.
- Moving to another screen and coming back without closing the Call screen keeps the selection.

