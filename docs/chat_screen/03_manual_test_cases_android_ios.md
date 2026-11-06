# Chat Screen: Manual Test Cases (Android + iOS)

For: whoever runs the emulator and simulator tests. Fill in the Pass/Fail columns as you go.

## Setup

**Devices and users**
| Device | User | Used for |
|---|---|---|
| Android emulator: a Pixel with API 35, plus one small phone (360×640 dp, e.g. "Nexus S" profile) | **A** | Main tester |
| iOS Simulator: an iPhone 15/16 and an iPad (for the split-view and keyboard cases) | **B** | Main tester |
| Third device or emulator | **C** | Group seen and typing |

**Test data**
- One private chat A–B with **100+ messages** spread over at least 3 days. Include text, an image, bulk images, a video, a document (PDF), a voice note, a location and a contact.
- One group "QA Group" with A (admin), B and C, also 100+ messages, including at least 2 Attendance polls (one open, one closed).
- A message from B to A that replies to a message more than 60 messages back (for the reply-jump test).

**Run**
```
flutter devices
flutter run -d <android-emulator-id>
flutter run -d <ios-simulator-id>
```

**Reset permissions for retesting**
```
# Android (package com.fg.fgtracker)
adb shell pm revoke com.fg.fgtracker android.permission.CAMERA
adb shell pm revoke com.fg.fgtracker android.permission.RECORD_AUDIO
adb shell pm revoke com.fg.fgtracker android.permission.READ_CONTACTS
adb shell pm revoke com.fg.fgtracker android.permission.ACCESS_FINE_LOCATION
adb shell pm reset-permissions com.fg.fgtracker        # everything
# iOS Simulator (check the Runner bundle id in Xcode; expected com.fg.fgtracker)
xcrun simctl privacy booted reset all com.fg.fgtracker
```
Revoking a permission restarts the app on Android. That is expected.

**Tips**
- **iOS Simulator: Cmd+K** shows or hides the on-screen keyboard. It must be visible for every keyboard case. Cmd+Shift+K toggles the hardware keyboard.
- The iOS Simulator **has no camera**. Camera cases are marked "Real iPhone needed".
- Android airplane mode: drag down the quick settings, or run `adb shell cmd connectivity airplane-mode enable|disable`.
- Android gesture vs 3-button navigation: Settings → System → Navigation mode.
- Large font: Android Settings → Display → Font size (max). iOS Settings → Accessibility → Larger Text.

**Legend**: P = private, G = group. "Blocked until backend #N" means the case can only pass after that item in `02_backend_requirements.md` ships.

---

## 1. The five issues

| TC ID | Feature | P/G | Precondition | Steps | Expected result | Android | iOS | Notes |
|---|---|---|---|---|---|---|---|---|
| H-01 | History on open: chat list | P | Chat A–B has history | A opens B from the Chat list | Skeleton, then the latest messages at the bottom. No "No messages here yet" | | | |
| H-02 | History on open: Group → Members | P | A and B in QA Group | Group → Members → tap B | **Same** conversation and history as H-01 | | | Was empty before the fix |
| H-03 | History on open: Track → Search Members | P | | Search Members → chat icon on B | Same conversation and history | | | Was empty before the fix |
| H-04 | History on open: user profile, bottom sheet, forward | P | | Open B from each of these | Same conversation every time; history shows within ~2 s | | | Uses the socket `joined` |
| H-05 | History on open: notification tap | P | App in background | B sends a message; A taps the push | Opens chat B with full history | | | |
| H-06 | History on open: notification tap, killed app | P | App killed | B sends; A taps the push | App starts and opens chat B with history | | | |
| H-07 | History on open | G | | Open QA Group from the chat list, Groups list and Walkie | Latest messages show; Attendance cards render | | | |
| H-08 | Load failure | P/G | Airplane mode ON | Open a chat that is not already open | After at most 10 s: "Couldn't load messages" + Retry (**not** "No messages here yet") | | | |
| H-09 | Retry | P/G | H-08 state | Airplane mode OFF → Retry | History loads | | | |
| H-10 | Truly empty chat | P | A and D never chatted | Open D | "No messages here yet / Say hi" | | | |
| H-11 | Unknown message type | P/G | Backend inserts a row with `messageType:"xyz"` and JSON content | Open the chat | That row shows "This message isn't supported…"; every other message renders | | | Needs a test row in the DB |
| AT-01 | Attendance long-press, sender | G | A created the attendance | A long-presses the attendance card | Menu shows Reply / Forward / Pin / Message Info. **No** "Delete for Everyone" or "Delete for Me" | | | |
| AT-02 | Attendance long-press, member | G | | B long-presses the same card | **No** Delete options | | | |
| AT-03 | Attendance card ⋮ menu (open poll) | G | A is admin, poll open | Tap ⋮ on the card | Only "Close attendance". No "Delete attendance" | | | |
| AT-04 | Attendance card ⋮ menu (closed poll) | G | Poll closed | Look at the card header | No ⋮ menu | | | |
| AT-05 | Other types keep Delete | P/G | | Long-press my text, then B's image | Text (mine): Delete for Everyone + Delete for Me. B's image: Delete for Me | | | |
| AT-06 | Server rejects attendance delete | G | Old app build, or Postman | Send `delete_message` for an attendance message | Server refuses; the message stays for everyone | | | Blocked until backend #4 |
| PG-01 | Older page | P/G | 100+ messages | Scroll to the top | Small spinner at the top; ~20 older messages appear; the message you were looking at **doesn't move** | | | |
| PG-02 | Continue to the start | P/G | | Keep scrolling up | Pages keep loading until the first message. No more spinner after that. No duplicates | | | |
| PG-03 | Fast fling | P/G | 1000+ messages | Fling to the top repeatedly | Only one request at a time (check logs `OLDER MESSAGE API CALL` with sequential pages). No duplicates. No freeze | | | Stress |
| PG-04 | Offset shift | P/G | A scrolled to the middle | B sends 25 messages, then A scrolls further up | No duplicate bubbles; paging keeps working (it used to get stuck in group) | | | |
| PG-05 | Date separators | P/G | | Scroll across days while paging | One separator per day; none repeated at page joins | | | |
| PG-06 | New message while scrolled up | P/G | A scrolled up | B sends 3 messages | No auto-scroll; the "new messages" button shows a count; tapping it jumps to the bottom | | | |
| PG-07 | 50 quick messages | P/G | A scrolled up | B sends 50 quick messages | A doesn't jump; the counter grows; all 50 arrive once | | | Stress |
| PG-08 | Reply-jump to an old message | P/G | Reply to a message 60+ back | Tap the quoted part | Older pages load, then it scrolls to and highlights the original | | | |
| PG-09 | Reply-jump, original gone | P/G | Original deleted for me | Tap the quote | Toast "Message not available" | | | |
| PG-10 | Deleted message at a page boundary | P/G | | Delete messages while another device pages | No crash; a skipped message is possible | | | Fully fixed only after backend #1 |
| KB-01 | Input above keyboard | P/G | iOS: Cmd+K on | Tap the input | The bar sits right above the keyboard. No yellow/black stripes. The latest message stays visible | | | |
| KB-02 | Close keyboard by drag | P/G | Keyboard open | Drag the message list | Keyboard closes smoothly | | | |
| KB-03 | Close keyboard by tap | P/G | Keyboard open | Tap on the list | Keyboard closes | | | |
| KB-04 | Multi-line | P/G | | Type 8 lines (Shift/Enter) | Grows to ~5 lines, then scrolls inside | | | |
| KB-05 | Spaces only | P/G | | Type only spaces | Send is not shown (mic stays) | | | |
| KB-06 | Focus after send | P/G | | Type, then send | Keyboard stays open; cursor stays in the input | | | |
| KB-07 | Emoji ↔ keyboard | P/G | Keyboard open | Tap the emoji icon, then tap the input | Emoji panel is about the keyboard's height; no big jump either way | | | |
| KB-08 | Emoji panel on small phone | P/G | 360×640 emulator, large font | Open the emoji panel | No overflow; list and input still visible | | | |
| KB-09 | Attachment sheet | P/G | Keyboard open | Tap the attachment (+) icon | Sheet opens; screen doesn't jump; closing it returns to the chat | | | |
| KB-10 | iOS suggestion bar | P | iOS, Cmd+K | Type until the QuickType bar appears and disappears | Input follows the height change | | | |
| KB-11 | Home indicator / nav bar | P/G | Keyboard closed | Look at the input bottom | Clear of the iOS home indicator and Android gesture bar / 3-button bar (test both modes, Android 15) | | | |
| KB-12 | Large font | P/G | Max font scale | Open the chat and keyboard | No overflow | | | |
| KB-13 | iPad landscape and Split View | P/G | iPad simulator | Rotate; then Split View 1/3 | Input above keyboard; no overflow | | iOS only | Phones are portrait-locked |
| KB-14 | Landscape on phone | P/G | | Rotate the phone | Stays portrait (app is locked to portrait) | | | By design |
| SB-01 | Seen by excludes me | G | A sends; B and C read | A → Message Info | "Seen (2 of 2)" lists B and C. **Not A** | | | |
| SB-02 | Opening doesn't mark my own messages | G | A sends; nobody read | A leaves and reopens the group → Message Info | "Seen" is empty; A is not listed | | | Bug before the fix |
| SB-03 | Count excludes sender | G | 3 members, B read | A → Message Info | "(1 of 2)" | | | |
| SB-04 | Private seen | P | A sends, B reads | A → Message Info | Shows B as "Seen"; count is 1 even after several reads | | | Seen **time** blocked until backend #3 |
| SB-05 | Private not seen | P | B hasn't opened | A → Message Info | "Not seen yet"; ticks are grey | | | |
| SB-06 | Background doesn't send seen | P | A has chat B open, app in background | B sends | B sees **delivered** (grey) until A opens the app; then it turns seen (purple) | | | |

## 2. Feature regression (inventory)

| TC ID | Feature | P/G | Precondition | Steps | Expected result | Android | iOS | Notes |
|---|---|---|---|---|---|---|---|---|
| F-01 | Send/receive text | P/G | | A sends; B receives | Appears once on both sides; ticks progress | | | |
| F-02 | Image | P/G | | Send 1 image | Uploads, renders, opens in the gallery | | | |
| F-03 | Bulk images and mixed media | P/G | | Send 5 images + 1 video | Grid with "+N"; opens the gallery | | | |
| F-04 | Video | P/G | | Send a video | Thumbnail + duration; plays | | | |
| F-05 | Document | P/G | | Send a PDF | Card with name and size; tap opens it | | | |
| F-06 | Voice note | P/G | Mic allowed | Record and send | Plays; seek works | | | |
| F-07 | Camera photo | P/G | | Attachment → Camera → capture → send | Sent | | **Real iPhone needed** | |
| F-08 | Gallery | P/G | | Attachment → Gallery | Picker opens with no permission prompt (Photo Picker / PHPicker) | | | |
| F-09 | Location | P/G | | Share location | Bubble opens Google Maps | | | |
| F-10 | Contact | P/G | | Share a contact; tap Call | Bubble shows; Call opens the dialer with the number | | | Fixed (A14, Android) |
| F-11 | Reply | P/G | | Swipe right on a message → reply | Quote shows the right preview for text, image, document and attendance | | | |
| F-12 | Forward | P/G | | Long-press → Forward to another chat | Arrives once | | | Duplicate risk: backend audit B2 |
| F-13 | Copy | P/G | | Long-press text → Copy | Toast; clipboard has the text | | | |
| F-14 | Delete for me | P/G | | Long-press → Delete for Me | Gone for A only; B still sees it | | | Audit B1 |
| F-15 | Delete for everyone | P/G | Own message | Long-press → Delete for Everyone | "This message was deleted" on both sides | | | |
| F-16 | Edit | P/G | Own text | Edit → save | Updated on both sides, marked edited | | | |
| F-17 | Pin / unpin | P/G | | Pin, then unpin | Banner appears and disappears on both sides | | | |
| F-18 | Ticks | P | | A sends; B offline; B online; B opens | Single grey → double grey → double purple | | | |
| F-19 | Typing | P/G | | B types | A sees the typing bubble (group: with B's name) | | | |
| F-20 | Online / last seen | P | | Open chat B | Header shows Online or last seen | | | Not live (audit) |
| F-21 | Group info | G | | Tap the header | Group profile opens | | | |
| F-22 | Mentions | G | | Type "@" in the group | Member list; select inserts the name | | | |
| F-23 | Links | P/G | | Send "https://example.com" | Tappable; opens the browser | | | |
| F-24 | Search in chat | P/G | | Search a word | Results highlight; next/prev works | | | Loaded pages only |
| F-25 | Translation | P/G | | Translate a message | Translated text shows | | | |
| F-26 | Missing media | P/G | A file deleted on the server | Open the chat | "Media is missing" card | | | |
| F-27 | Attendance vote | G | B member, poll open | B responds | Card updates for A live | | | |
| F-28 | Block / unblock | P | | Block B; unblock | Input replaced by the blocked banner; restored | | | |
| F-29 | Clear chat | P/G | | Menu → Clear chat | Messages cleared | | | |
| F-30 | Chat list unaffected | – | | Open and close chats | List unread, typing and order still correct | | | Regression |
| F-31 | Other modules | – | | Smoke-test Walkie-Talkie, Safe Zone/Route, Live Tracking, Packages | Unchanged | | | Regression |
| F-32 | Permission gate | – | Fresh install | Launch | Compulsory Location + Notification gate still blocks until granted | | | Regression |

## 3. Permissions

| TC ID | Feature | P/G | Precondition | Steps | Expected result | Android | iOS | Notes |
|---|---|---|---|---|---|---|---|---|
| PM-01 | Mic: allow | P/G | Reset perms | Tap mic → Allow | Recording starts | | | |
| PM-02 | Mic: deny | P/G | Reset perms | Tap mic → Don't allow | Reason shown; can ask again | | | |
| PM-03 | Mic: permanently denied | P/G | Deny twice (Android) / deny once (iOS) | Tap mic | Dialog with **Open Settings**; enabling it in Settings works on return | | | |
| PM-04 | Camera: allow | P/G | | Open camera → Allow | Preview shows | | **Real iPhone needed** | |
| PM-05 | Camera: deny | P/G | | Deny camera | Reason shown with **Try again**; when permanently denied, **Open Settings** too. No endless spinner | | **Real iPhone needed** | Fixed (A12) |
| PM-06 | Camera with mic denied | P/G | Camera allowed, mic denied | Take a photo, then record a video | Photo works; video records without sound | | **Real iPhone needed** | Fixed (A12) |
| PM-07 | Gallery | P/G | Fresh install | Open gallery | No permission prompt; picker works | | | Android 14 "Select photos" not applicable |
| PM-08 | Location: allow | P/G | | Share location → Allow | Picker shows the map | | | |
| PM-09 | Location: deny / permanently deny / service off | P/G | | Deny; then permanently deny; then turn location off | Reason in the picker with **Try again**; **Open Settings** when denied. Never stuck on the loader | | | Fixed (A13) |
| PM-10 | Contacts: allow / deny / permanently deny | P/G | | Open the contact picker | Allow: list. Deny: "Contacts permission needed" + **Try again** + **Open Settings** | | | Fixed (A13) |
| PM-11 | Files | P/G | | Attach a document | System picker, no permission prompt | | | |
| PM-12 | Never crashes | P/G | Each permission denied | Use each feature | No crash in any case | | | |

## 4. Offline, lifecycle and accounts

| TC ID | Feature | P/G | Precondition | Steps | Expected result | Android | iOS | Notes |
|---|---|---|---|---|---|---|---|---|
| OF-01 | Reconnect catch-up | P/G | A has the chat open | A airplane ON; B sends 5; A airplane OFF | Within a few seconds the 5 messages appear in order, once each | | | Over 100 missed needs backend #6 |
| OF-02 | Resume catch-up | P/G | A has the chat open | A home button; B sends 3; A returns | The 3 messages appear; B sees them turn seen | | | |
| OF-03 | Kill and relaunch | P/G | | Kill the app; B sends; relaunch and open the chat | All messages present | | | |
| OF-04 | Offline send | P | Airplane ON | A sends text, a voice note, a location | Toast "You're offline. Message not sent."; typed text stays in the box | | | Fixed (A1) |
| OF-05 | Offline send | G | Airplane ON | A sends text | Delivered after reconnect | | | |
| OF-06 | Two devices, same account | P/G | A logged in on two devices | Send from one | The other shows it once; history the same on both | | | |
| OF-07 | Logout / login | P/G | | Log out, log in as another user, open chats | No messages from the previous user; history correct | | | |
| OF-08 | Pagination offline | P/G | Scrolled up, airplane ON | Scroll to the top | Spinner stops; no crash; resumes when back online | | | |

## 5. Second-pass fixes (frontend bugs from the audit)

| TC ID | Feature | P/G | Precondition | Steps | Expected result | Android | iOS | Notes |
|---|---|---|---|---|---|---|---|---|
| S2-01 | Forward into another chat | P/G | Inside chat with B | Long-press → Forward → pick C (single) | Chat B closes and chat **C** opens with its own history (not B's) | | | A2 |
| S2-02 | Forward into the same chat | P | Inside chat with B | Forward to B | Stays in chat B; message appears once | | | A2 |
| S2-03 | Push tap while another chat is open | P/G | Chat with B open, app in background | C sends; tap the push | Chat C opens (it used to be ignored) | | | A2 |
| S2-04 | Group-chat local notification | G | App in foreground on another screen | B sends in QA Group; tap the local notification | Opens the **group chat**, not Walkie | | | A3 |
| S2-05 | Walkie notification still works | G | | Walkie call notification → tap | Opens Walkie | | | A3 regression |
| S2-06 | One tap = one navigation | P/G | App in background | Tap a chat push | Screen opens once (back goes straight to the previous screen) | | | A3 duplicate listener |
| S2-07 | Private reconnect, different chat | P | Open chat B, back, open chat C | Toggle airplane mode while in C | C keeps its messages; B's never appear in C | | | A5 |
| S2-08 | Live edit (private) | P | | B edits a message | A sees the new text live; ticks unchanged | | | A7 |
| S2-09 | Unpin (private) | P | Pinned message | B unpins | Banner disappears for A | | | A8 |
| S2-10 | Delete for everyone with image (private) | P | Pinned image message | B deletes it for everyone | "This message was deleted"; image gone; pin banner gone | | | A9 |
| S2-11 | Delete for me isn't shared | P/G | | B deletes a message "for me" | Still visible to A | | | B1 Flutter half |
| S2-12 | Edit/delete after visiting a group | P | Private chat open | Open a group from the profile, go back; B edits/deletes | A still sees the edit/delete live | | | A17/A18 |
| S2-13 | iOS swipe back | P | iPhone | Swipe from the left edge | Returns to the previous screen; reopening the chat works normally | | iOS only | A15 |
| S2-14 | Document with query-string URL | P/G | | Open a shared document | Opens with the right app | | | A19 |
| S2-15 | Lost picker data (Android) | P | Developer options → "Don't keep activities" ON | Attach → Gallery → pick 2 photos | Back in chat, the 2 photos are in the tray as images (not videos) | | Android only | A22 |
| S2-16 | Background reconnect doesn't mark read | G | Group open, app in background | Toggle the network; C sends | C sees A's read state only after A reopens the app | | | SMS:150 |
