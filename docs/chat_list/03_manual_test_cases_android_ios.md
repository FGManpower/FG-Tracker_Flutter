# Chat List: Manual Test Cases (Android + iOS)

For: QA running the app on emulators/simulators · Build: branch `46Solution` · Backend items: [02_backend_requirements.md](02_backend_requirements.md)

## Setup

### Accounts and data
| User | Device | Purpose |
|---|---|---|
| **A** | Android emulator (e.g. Pixel 7, API 34) | Main tester: watches the chat list |
| **B** | iOS Simulator (iPhone 15) | Sends messages, types, opens chats |
| **C** | Second Android emulator or a real phone | Third group member (two people typing) |

- Group **"QA Group"** with A, B and C. Private chat **A ↔ B**. At least one message in each so both rows exist.
- For pagination (TC-40): A needs **25+ chats** (send one message from 25 different accounts, or ask the backend to seed them).
- iOS Simulator needs a Mac with Xcode. Without a Mac, run User B on a second Android emulator and mark the iOS column "N/A".

### Run commands
```bash
flutter devices                         # list device ids
# Android emulator(s)
flutter emulators                       # list AVDs
flutter emulators --launch <avd_id>
flutter run -d emulator-5554            # User A
flutter run -d emulator-5556            # User C (second AVD)
# iOS Simulator (macOS)
open -a Simulator
flutter run -d <iPhone-simulator-UDID>  # User B
# Real phone (USB debugging on)
flutter run -d <device-serial>
```
- Hot restart: `R`. Full restart: stop and run again. Logs: `flutter logs -d <id>`.
- **Airplane mode:** Android emulator, Extended controls → Cellular → Data status *Denied* (or swipe down → Airplane). iOS Simulator has no airplane mode: turn the Mac's Wi-Fi off, or use Network Link Conditioner → *100% Loss*.
- **Dark mode:** Android Settings → Display → Dark theme. iOS Settings → Developer → Dark Appearance.
- **Large font:** Android Settings → Display → Font size → Largest. iOS Settings → Accessibility → Display & Text Size → Larger Text.
- **Small screen:** Android AVD "Small Phone" (4", 720×1280). iOS iPhone SE (3rd gen).

### Status legend
Write **P** (pass), **F** (fail + note), **N/A**, or **B** for blocked. "Blocked until backend #X" means: run it, but a failure isn't a Flutter bug until that backend item ships.

---

## Test cases

| TC ID | Feature | Precondition | Steps | Expected result | Android P/F | iOS P/F | Notes |
|---|---|---|---|---|---|---|---|
| TC-01 | New private message (live) | A on chat list | B sends "hello" to A | A's row shows "hello", time updates, badge 1, row moves to top (below pinned) within ~1 s, no refresh needed | | | |
| TC-02 | New group message (live) | A on chat list, A has **not** opened any group this session | B sends "hi team" in QA Group | Group row shows "B-name: hi team", badge +1, moves to top | | | Before the fix this needed a group to be opened first |
| TC-03 | New chat inserted | A on chat list; D (new contact, no chat with A) | D sends first message to A | New row appears at top within ~1 s | | | Uses a page-1 refetch if the event lacks row details |
| TC-04 | Message while on another module | A on Home or Live Tracking | B sends 2 messages; A opens chat list | Row already shows the latest message and badge 2; the home "Chatting" dot was on | | | Socket now lives app-wide |
| TC-05 | Own message from this device | A in chat with B | A sends "yo", goes back | Row shows "You: yo", A's badge stays 0 | | | |
| TC-06 | Own message from another device | A logged in on 2 devices | Send from device 2 | Device 1 row shows "You: …", badge not increased | | | **Blocked until backend #1, #7** |
| TC-07 | Name shown once (group) | QA Group | B sends "check" | A sees "B-name: check" (one name). A sends → A sees "You: check" | | | Issue 5 |
| TC-08 | Name shown once (private) | A ↔ B | B sends; A sends | A sees "text" for B's message, "You: text" for A's | | | |
| TC-09 | Preview labels | Any chat | B sends image, 3 images, video, voice, document, poll/attendance, then deletes one | 📷 Photo / 📷 3 Photos / 🎥 Video / 🎤 Voice message / 📄 file name / 📊 poll title / "This message was deleted" (grey italic); group rows prefixed once | | | |
| TC-10 | Typing: private | A on list; B in chat with A | B types without sending | A's row shows green "typing..." instead of the preview; order unchanged | | | **Blocked until backend #1** |
| TC-11 | Typing stops | as TC-10 | B stops typing | Indicator clears within ~3 s (B's stop event) or ≤5 s (auto-expiry) | | | **Blocked until backend #1** |
| TC-12 | Typing cleared by message | as TC-10 | B sends while A sees "typing..." | Indicator replaced by the message immediately | | | **Blocked until backend #1** |
| TC-13 | Typing: group, one person | A on list | B types in QA Group | "B-name is typing..." | | | **Blocked until backend #1** |
| TC-14 | Typing: group, two people | A on list | B and C type at the same time | "B-name, C-name are typing..." | | | **Blocked until backend #1** |
| TC-15 | Own typing hidden | A on 2 devices | A types on device 2 | Device 1 shows no typing for A's own typing | | | |
| TC-16 | Typing in Archived | A ↔ B archived; A on Archived screen | B types | Archived row shows "typing..." | | | **Blocked until backend #1** |
| TC-17 | Typing never reorders | Several chats; B's chat is 3rd | B types | Rows don't move | | | |
| TC-18 | Mark as Unread | Chat with 0 unread | Long-press → Mark as Unread | Dot shows, time turns purple, "All Chats" badge counts it | | | Device-local until backend #6 |
| TC-19 | Mark as Unread survives restart | after TC-18 | Kill and relaunch app | Dot still shown | | | |
| TC-20 | Mark as Unread on other device / reinstall | after TC-18 | Check device 2, or reinstall | Dot shown there too | | | **Blocked until backend #6** |
| TC-21 | Mark as Read | Chat with badge 3 | Long-press → Mark as Read | Badge disappears; B sees blue ticks (private) | | | |
| TC-22 | Mark as Read offline | Internet off | Long-press → Mark as Read on a chat with badge | Snackbar "You're offline…", badge stays | | | |
| TC-23 | Pin | 3+ chats | Pin the bottom chat | Moves to top with pin icon | | | |
| TC-24 | Pinned order | 2 pinned chats | B messages the lower pinned chat | It becomes first among pinned; unpinned chats stay below all pinned | | | |
| TC-25 | Unpin | Pinned chat | Unpin | Returns to its time-based position | | | |
| TC-26 | Pin offline (rollback) | Internet off | Pin a chat | Snackbar "You're offline…", pin undone | | | |
| TC-27 | Pin survives restart | Pinned chat | Kill and relaunch | Still pinned | | | |
| TC-28 | Archive | Chat in main list | Long-press → Archive | Row leaves main list; "Archived (n)" entry appears/increments | | | |
| TC-29 | Archive a pinned chat | Pinned chat | Archive | Archived and unpinned; after unarchive it isn't pinned | | | |
| TC-30 | New message in archived chat | A ↔ B archived | B sends | Stays in Archived; Archived entry shows "1 unread message" + badge; main "All Chats" badge excludes it | | | |
| TC-31 | **Archived doesn't shuffle** | 3+ archived chats; A on Archived screen | B opens/reads the archived chat, goes online/offline | Archived rows keep their order | | | Issue 4 |
| TC-32 | Unarchive | Archived chat | Long-press → Unarchive (Archived screen) | Back in main list at its time position | | | |
| TC-33 | Archive offline (rollback) | Internet off | Archive a chat | Snackbar, chat returns to main list | | | |
| TC-34 | Archive on other device | A on 2 devices | Archive on device 2 | Device 1 updates without refresh | | | **Blocked until backend #3** |
| TC-35 | Delete private chat | A ↔ B | Long-press → Delete → confirm | Confirmation shown; row removed immediately; still gone after refresh | | | |
| TC-36 | Delete cancel | — | Long-press → Delete → No | Nothing changes | | | |
| TC-37 | Delete group chat | QA Group | Delete → confirm | Row removed; **stays removed after refresh** | | | **Blocked until backend #2** (returns on refresh today) |
| TC-38 | Delete offline | Internet off | Delete private chat | Snackbar, row restored | | | |
| TC-39 | Action error from server | Backend returns `private_chat_action_error` | Trigger a failing action (e.g. archive a chat deleted on server) | Change rolled back, server message shown | | | **Blocked until backend #8** for exact chat matching |
| TC-40 | Pagination | 25+ chats | Scroll to bottom / load next page; B messages a chat from page 2 | Page 2 loads; that chat jumps to top without duplicates | | | |
| TC-41 | Unread per chat | B sends 3 messages | Check A's row | Badge 3 (not 6, not 1) | | | |
| TC-42 | Open chat resets badge | after TC-41 | A opens the chat, goes back | Badge 0 | | | |
| TC-43 | Open chat doesn't count | A inside chat with B | B sends 2 messages; A goes back | Badge 0 | | | |
| TC-44 | "All Chats" badge | 2 unread chats + 1 archived unread | Look at "All Chats" header | Shows 2 (unread chats, archived excluded) | | | Was the number of loaded rows before |
| TC-45 | Home "Chatting" dot | A has unread group chat | Read it, go home | Dot clears (was stuck before for groups) | | | |
| TC-46 | 50 quick messages | A on list | B sends 50 messages fast (script or paste spam) | No freeze; final badge 50; row on top; no duplicate rows | | | |
| TC-47 | 300+ chats | Seeded account | Scroll the list | Smooth scrolling; rows stable | | | Needs backend seed |
| TC-48 | Reconnect (airplane) | A on list | Airplane ON 30 s; B sends 2 messages; airplane OFF | Within a few seconds the row shows both messages and badge 2 | | | Refetch on reconnect |
| TC-49 | Background → resume | A on list | Home button 1 min; B sends; reopen app | List is up to date on resume | | | |
| TC-50 | Kill → relaunch | — | Kill app; B sends; relaunch | Correct preview, badge and order from API | | | |
| TC-51 | Logout → login other user | A logged in | Logout; log in as C | C sees only C's chats (no A data), sockets work | | | |
| TC-52 | Same account, 2 devices | A on 2 devices | Read a chat on device 2 | Device 1 badge clears | | | **Blocked until backend #3, #7** |
| TC-53 | Dark mode | Dark mode on | Open list, Archived, typing | All text readable; typing green visible | | | |
| TC-54 | Large font | Largest font | Open list with long names/messages | One-line ellipsis, no overflow (no yellow/black stripes) | | | |
| TC-55 | Small screen | Small Phone / iPhone SE | Open list, Archived, long-press menu | Everything fits, menu fully visible | | | |
| TC-56 | Search | 10+ chats | Search a name, then a message word | Correct results; clear search restores the list in the same order | | | |
| **Regression** | | | | | | | |
| TC-60 | Private chat screen | — | Send/receive text, emoji, image, video, voice, document; reply; forward | All work as before, ticks progress | | | |
| TC-61 | Group chat screen | — | Same as TC-60 in QA Group; typing indicator **inside** the chat | All work; in-chat typing still shows | | | Group typing listener changed to handler-specific |
| TC-62 | Poll / Attendance in chat | QA Group | Create attendance poll, vote, view results | Card renders, votes update live | | | |
| TC-63 | Notification tap | App in background | B sends; tap the notification | Opens the correct chat; badge clears after reading | | | |
| TC-64 | Walkie-Talkie | — | Start a walkie session | Works as before | | | |
| TC-65 | Safe Zone / Route | — | Open Safe Zone, create/view | Works as before | | | |
| TC-66 | Live Tracking | — | Open tracking, toggle location sharing / private mode | Works as before | | | Protected module, untouched |
| TC-67 | Packages / payments | — | Open packages, start a payment (test mode) | Works as before | | | |
| TC-68 | Login / re-login | — | Logout → login with OTP | Works as before | | | Protected module, untouched |
