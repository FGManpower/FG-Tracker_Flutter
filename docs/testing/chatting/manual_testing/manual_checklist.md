# Chatting — Manual Test Checklist

| | |
|---|---|
| Module | Chatting: chat list, private / group / common chat, hold-press menu, forward, translate, status |
| Last updated | 2026-11-16 |
| Feature guide (reference) | [`docs/01_CHATTING_MODULE_FRONTEND.md`](../../../01_CHATTING_MODULE_FRONTEND.md) |
| Bugs | [../bug_tracker.md](../bug_tracker.md) |

## How to use this sheet

**Setup:** 3 accounts — **A** (tester), **B** and **C** — and a group "QA-Group" with all three. Devices: Android emulator, one real Android phone, and an iPhone or iOS Simulator.

**Column "Auto":** what the automated tests already checked.
- `✔ <test>` = the logic is checked by a unit test that passes. You still need to check it on a phone, because unit tests don't use the real server or screen.
- `✘ <bug>` = the automated test already shows this is broken. Expect it to fail until the bug is fixed.
- `—` = cannot be automated. **Only a manual check covers it.**

**Status values:** `Not run` · `Pass` (shows within 2 s) · `Slow` (2–10 s) · `Fail` (only after reopen / restart, or never) · `Blocked`.
Record a side-by-side video of every Fail. Write the device (Android / iOS) in Notes.

---

## 1. Chat list

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| CL-01 | B sends A one message while A is on the chat list | B's row jumps to the top; preview and time update | ✔ chat_list_controller_qa · ✘ BUG-RT-01, BUG-CL-01 | Not run | Not run | |
| CL-02 | B sends 5 messages quickly | Badge = 5, preview = last message | ✔ unread dedupe tests | Not run | Not run | |
| CL-03 | A opens B's chat and comes back | Badge gone | ✔ | Not run | Not run | |
| CL-04 | C writes in QA-Group | Group row on `top, "C: message", badge +1 | ✔ (logic) · server room to confirm | Not run | Not run | |
| CL-05 | New user D, who never chatted with A, sends a message | New row appears on top | ✔ | Not run | Not run | |
| CL-06 | B sends a photo, video, voice note, document, location, contact, poll / attendance | The right preview label each time | ✔ message_preview tests | Not run | Not run | |
| CL-07 | B types | "typing…" on B's row, clears when B stops | ✔ logic · ✘ BUG-RT-05 (row does not redraw) | Not run | Not run | |
| CL-08 | C types in QA-Group | "C is typing…" on the group row | ✔ RT-07 | Not run | Not run | |
| CL-09 | B opens / closes the app | Online dot turns on / off | ✘ BUG-RT-06 (no live listener) | Not run | Not run | |
| CL-10 | B deletes the last message for everyone | Preview "This message was deleted" | ✔ · ✘ BUG-CL-07 | Not run | Not run | |
| CL-11 | B edits the last message | Preview shows new text | — | Not run | Not run | |
| CL-12 | Admin renames QA-Group and changes the icon | Name and icon change in the list | ✘ BUG-RT-02 | Not run | Not run | |
| CL-13 | Same as CL-12, but first open and close QA-Group once | Still updates | ✘ BUG-RT-02 | Not run | Not run | |
| CL-14 | Admin adds or removes a member / A is removed | Row updates live | — | Not run | Not run | |
| CL-15 | Admin deactivates the group | "Deactivated" badge appears | ✔ group_activation tests · ✘ BUG-RT-05 | Not run | Not run | |
| CL-16 | Chats receive messages in random order | Sorted newest first, pinned on top | ✔ sorting tests | Not run | Not run | |
| CL-17 | Search by name, phone and message text | Right rows. Archived chats not shown. | ✔ search tests | Not run | Not run | |
| CL-18 | Scroll until page 2–3 loads, then B sends | Loaded rows stay | — | Not run | Not run | |
| CL-19 | New account with no chats | Empty state | — | Not run | Not run | |
| CL-20 | Internet off | Cached list or offline message, no crash | — | Not run | Not run | |
| CL-21 | Unread total in the list vs the home red dot | Same number | ✔ notification_marker tests | Not run | Not run | |

### 1a. Chat list hold-press (long-press) menu

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| CLH-01 | Long-press a row → **Pin** | Row goes to top at once and stays after reopen | ✔ pin tests | Not run | Not run | |
| CLH-02 | Pin while offline | Pin is undone with a "couldn't update" message | ✔ (async rollback) | Not run | Not run | |
| CLH-03 | **Unpin** | Row returns to time order | ✔ | Not run | Not run | |
| CLH-04 | **Mute** for 8 h / 1 week / always, then **Unmute** | Mute icon, no notification sound | ✔ · ✘ BUG-CL-04 (no rollback on error) | Not run | Not run | |
| CLH-05 | **Archive** | Row moves to Archived at once; archive count updates | ✔ archive tests | Not run | Not run | |
| CLH-06 | Open Archived → **Unarchive** | Row back in the main list | ✔ | Not run | Not run | |
| CLH-07 | A new message arrives in an archived chat | Stays in Archive; archived badge updates | ✔ | Not run | Not run | |
| CLH-08 | **Mark as unread** | Dot shows; survives app restart | ✔ · ✘ BUG-CL-05 | Not run | Not run | |
| CLH-09 | **Mark as read** | Badge and dot cleared | ✔ | Not run | Not run | |
| CLH-10 | Mark unread on phone 1, open the app on phone 2 (same account) | Dot shows on phone 2 | ✔ (parsing) | Not run | Not run | |
| CLH-11 | **Delete chat** | Row gone at once; comes back if the server call fails | ✔ delete tests | Not run | Not run | |
| CLH-12 | Same actions on a group row | Same behaviour | ✔ | Not run | Not run | |

### 1b. Status (Updates) section

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| ST-01 | Tap "My Status" with no status | Popup offers only "Add to My Status" | ✔ status_section_widget (passes alone; flaky in full run) | Not run | Not run | |
| ST-02 | Add a text / photo / video status | It shows under My Status | ✔ model tests | Not run | Not run | |
| ST-03 | B views A's status | A sees the view count go up | ✔ status:viewed test | Not run | Not run | |
| ST-04 | B posts a status | Green ring on B appears live in A's list | ✔ status:new test | Not run | Not run | |
| ST-05 | B deletes a status A is watching | Viewer skips it / ring disappears | ✔ delete tests | Not run | Not run | |
| ST-06 | Privacy "Only share with C" | B never sees it | — server (pentest S17) | Not run | Not run | |
| ST-07 | Status older than 24 h | Not shown | ✔ expiry tests (server decides) | Not run | Not run | |
| ST-08 | Tap outside or press back on the popup | Popup closes, screen still works | ✔ | Not run | Not run | |

---

## 2. Chat screen — messages

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| CS-01 | A sends a text to B | Shows on B once, within 2 s | ✔ RT-10 (once) | Not run | Not run | |
| CS-02 | A sends 10 messages quickly | Same order on both phones, no duplicates or gaps | ✔ merge / dedupe tests | Not run | Not run | |
| CS-03 | A and B send in the same second | Both see both, same order | ✔ ordering tests | Not run | Not run | |
| CS-04 | Photo, multiple photos, video, voice note, document, location, contact | Each sends, previews and opens | ✔ parsing tests | Not run | Not run | |
| CS-05 | Chat with 500+ messages, scroll up | Smooth paging, no repeats | ✔ HistoryPager tests | Not run | Not run | |
| CS-06 | Messages across midnight | "Today" / "Yesterday" / dates right in local time | ✔ last-seen / date tests | Not run | Not run | |
| CS-07 | Long text, emoji, links | Wraps, emoji show, link opens in browser | — | Not run | Not run | |
| CS-08 | Group: B and C write | Sender name on each bubble | — | Not run | Not run | |
| CS-09 | Attendance / poll card: B and C vote | Votes update live; admin can close it | ✔ attendance parsing | Not run | Not run | |
| CS-10 | Open the same chat 10 times, then B sends 1 message | Shows once | ✔ RT-10 | Not run | Not run | |
| CS-11 | **BUG-CS-18.** Group with 60+ messages, scroll up 2 pages. Open Group info → add a member → back | All messages still shown; the "X added Y" line appears once | ✔ group_chat_blank_messages | Not run | Not run | Was: list went empty until reopen |
| CS-12 | **BUG-CS-18.** Same group: remove a member, then back | All messages still shown | ✔ group_chat_blank_messages | Not run | Not run | |
| CS-13 | **BUG-CS-18.** Edit group name, then icon, then description | List never goes empty; new name / icon show | ✔ group_chat_blank_messages | Not run | Not run | |
| CS-14 | **BUG-CS-18.** Group open: background 30 s while B and C read and send, then resume. Repeat with Wi-Fi off 30 s → on | List stays full; ticks and new messages update | ✔ group_chat_blank_messages | Not run | Not run | iOS: also lock the screen 1 min |
| CS-15 | **BUG-CS-18.** Private chat: open, background 30 s, resume; Wi-Fi off → on | List stays full | ✔ group_chat_blank_messages (private case) | Not run | Not run | Same fix covers private |

### 2a. Hold-press (long-press) menu on a message

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| MH-01 | Long-press **my** text | Reply, Copy, Forward, Edit, Pin, Info, Delete for me, Delete for everyone | ✔ menu tests | Not run | Not run | |
| MH-02 | Long-press a **received** text | No Edit, no Info, no Delete for everyone | ✔ | Not run | Not run | |
| MH-03 | Long-press my photo / voice / document | No Copy, no Edit; Info + deletes shown | ✔ | Not run | Not run | |
| MH-04 | Long-press an attendance card | No delete option at all | ✔ | Not run | Not run | |
| MH-05 | Long-press a deleted message | No menu | ✔ | Not run | Not run | |
| MH-06 | **Reply** (menu and swipe right) | Reply bar shows the right preview; quoted bubble after send | ✔ reply preview tests | Not run | Not run | |
| MH-07 | Reply to a photo / voice / location / contact | Quote shows "Photo" / mic / pin / name, never a URL or JSON | ✔ | Not run | Not run | |
| MH-08 | **Copy** | Text on the clipboard | — | Not run | Not run | |
| MH-09 | **Forward** to 1 private chat + 1 group | Arrives once in each, with the "Forwarded" label | ✔ forward tests · ✘ BUG-CS-06 | Not run | Not run | |
| MH-10 | Forward screen: search by name and number | Right results; a user and a group with the same id are separate | ✔ | Not run | Not run | |
| MH-11 | **Edit** my message | Both phones show new text + "Edited" | ✔ · ✘ BUG-CS-07, BUG-CS-03 | Not run | Not run | |
| MH-12 | **Pin / Unpin** message | Pinned banner updates on both phones | ✔ | Not run | Not run | |
| MH-13 | **Info** on my private message | Sent / Delivered / Seen with correct times | ✔ · ✘ BUG-CS-15, BUG-CS-17 | Not run | Not run | |
| MH-14 | **Info** on my group message | "Seen (X of Y)" with the right members | ✔ · ✘ BUG-CS-16 | Not run | Not run | |
| MH-15 | **Delete for me** | Gone only on my phone | ✔ | Not run | Not run | |
| MH-16 | **Delete for everyone** | "This message was deleted" on both within 2 s | ✔ | Not run | Not run | |

### 2b. Translate and Listen

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| TR-01 | Swipe left on a received English text | Hindi translation card | ✔ translation tests | Not run | Not run | |
| TR-02 | Swipe left on a received Hindi text | English translation card | ✔ | Not run | Not run | |
| TR-03 | Swipe again | Card hides / shows, no new network call | ✔ | Not run | Not run | |
| TR-04 | Tap "Listen" on the original and the translation | Audio plays; button shows Stop while playing | ✔ widget tests | Not run | Not run | |
| TR-05 | Edit a message that was translated | New translation, not the old one | ✘ BUG-TS-01 | Not run | Not run | |
| TR-06 | Translate with internet off | Clear error, no endless spinner | ✔ (all endpoints fail) | Not run | Not run | |
| TR-07 | "नमस्ते, दोस्त" greeting | No double space in the result | ✘ BUG-TS-02 | Not run | Not run | |

---

## 3. Real-time status

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| RS-01 | A has B's chat open; B opens the app | "Online" within 2 s | ✘ BUG-RT-06 | Not run | Not run | |
| RS-02 | B closes the app / puts it in the background / kills it / turns on airplane mode (test each) | "Last seen …" | ✘ BUG-RT-06 | Not run | Not run | |issue
| RS-03 | A opens B's chat from B's profile (not from the list) while B is offline | "Last seen …", not blank | ✘ BUG-RT-07 | Not run | Not run | |
| RS-04 | B types (private) | "typing…" in the top bar, clears ≤ 4 s after B stops | ✔ RT-06, typing tests | Not run | Not run | |
| RS-05 | B and C type in the group | "B, C are typing…" | ✔ | Not run | Not run | |
| RS-06 | A sends; B online, chat closed | ✓ → ✓✓ grey | ✔ | Not run | Not run | |
| RS-07 | B opens the chat | ✓✓ turns blue on A live | ✔ · ✘ BUG-CS-04 (if the server sends no ids) | Not run | Not run | |
| RS-08 | Watch ✓✓ for 10 s after sending | Never drops back to ✓ | ✘ BUG-RT-08 | Not run | Not run | |
| RS-09 | B offline, A sends, B comes online | ✓ → ✓✓ when B connects | — server | Not run | Not run | |
| RS-10 | Group: B reads, then C reads | Blue only when everyone has read | ✘ BUG-RT-03, BUG-CS-05, BUG-CS-13 | Not run | Not run | |
| RS-11 | B blocks A / A leaves or is removed from the group | Input disabled, notice shown live | ✔ BLK-01…07 (block) | Not run | Not run | |
| RS-11a | A has B's chat open (foreground); B blocks A from B's chat | A sees "contact blocked you" within ~4 s without sending (instant once backend #25 ships). Then B unblocks → A's banner goes within ~4 s | ✔ BLK-01…05 | Not run | Not run | Run on Android **and** iOS; full app restart first (no hot reload) |
| RS-11b | Blocked A sends one message | Banner replaces the input bar on the first rejected send; draft not resent | ✔ BLK-06, BLK-07 | Not run | Not run | |
| RS-11c | A blocked, app to background ≥ 30 s, back to foreground | Banner correct right after resume (no 4 s wait); no checks run while in background | — | Not run | Not run | iOS: also pull Control Centre down (app `inactive`): checks pause, resume after |
| RS-11d | After the block, A and B both reopen the chat | Old messages still shown on both phones (last 50; server copy once #26 ships) | ✔ CACHE-01…07 | Not run | Not run | Reinstall / logout → copy is gone (expected) |
| RS-12 | A **archived** group G and has G's chat open; member C leaves G | "C left" grey system message appears within ~3 s, without reopening | ✔ GML-01…03 | Not run | Not run | Repeat with C **removed** by admin, and with G not archived (must still show once, no duplicate) |
| RS-13 | Chats ▸ Archive ▸ tap an archived **group** (row, and photo ▸ "Message") | Group chat opens with all messages; can read and send; back returns to Archive; group still archived | — | Not run | Not run | Also a deactivated archived group (banner shown), and an archived **private** chat (still opens as before) |
| RS-14 | Group Info ▸ Add Members ▸ tap search, type fast, delete, open / close keyboard several times | Keyboard opens / closes smoothly, no lag while typing; list stays above the keyboard and scrolls to the last contact | — | Not run | Not run | Test on a low-end Android phone too; landscape: sheet shrinks, no overflow stripes |

---

## 4. Connection

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| CN-01 | A in background 30 s; B sends, reads and edits; A comes back | Everything up to date | ✔ RT-16/17/18 (rejoin) · ✘ BUG-CS-01 | Not run | Not run | |
| CN-02 | Same after 10+ minutes in background | Same | ✘ BUG-RT-04 | Not run | Not run | |
| CN-03 | Internet off 30 s → on; B sent 3 messages | All 3 appear | ✔ RT-17 | Not run | Not run | |
| CN-04 | Internet off 5+ minutes → on | Live updates resume | ✘ BUG-RT-09 (to confirm on device) | Not run | Not run | |
| CN-05 | Switch Wi-Fi ↔ mobile data | Live within 10 s | — | Not run | Not run | |
| CN-06 | Send while offline (private and group) | Clear "not sent" / failed state, nothing lost, no duplicate | ✘ BUG-RT-10 (group) | Not run | Not run | |
| CN-07 | Kill the app, open it from a chat notification | Right chat opens with full history | ✔ notification_routing tests | Not run | Not run | |
| CN-08 | Lock the screen 2 min | Live updates resume | — | Not run | Not run | |
| CN-09 | Go Home through a call or walkie-talkie screen, open the list, B sends | List still live | — (suspected BUG-RT-11) | Not run | Not run | |
| CN-10 | Log out A, log in C on the same phone | Only C's data; live works | ✔ SEC-RT-03 | Not run | Not run | |
| CN-11 | iPhone: repeat CN-01, CN-02, CN-03 | Same as Android | — | Not run | Not run | |
| CN-12 | Push notifications + app icon badge | Arrive, right count, tap opens chat | — | Not run | Not run | |

---

## 5. Look and feel

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| UI-01 | Hindi and Marathi | All labels translated, nothing cut off | ✔ l10n_completeness · ✘ BUG-CS-17 | Not run | Not run | |
| UI-02 | Largest system font | No overflow | ✔ widget tests | Not run | Not run | |
| UI-03 | Small phone with the keyboard open | Input above the keyboard; last message visible | ✔ | Not run | Not run | |
| UI-04 | Dark mode | Bubbles, ticks and typing text readable | — | Not run | Not run | |
| UI-05 | Tap a member in Message Info | Ripple is visible | ✘ BUG-CS-14 | Not run | Not run | |

---

## 6. Security checks you can do on a phone

Full list: [../pentesting/pentest_report.md](../pentesting/pentest_report.md)

| ID | Steps | Expected | Android | iOS | Notes |
|---|---|---|---|---|---|
| SM-01 | Put the phone behind mitmproxy / Charles and send a message | Today you **will** see the token and the message in plain text (SEC-01). After the fix: only TLS traffic | Not run | Not run | |
| SM-02 | Send `javascript:alert(1)` and `intent://x#Intent;end` as text | Not clickable | Not run | Not run | |
| SM-03 | Log out, then look at the app cache on a rooted emulator | No chat files left (today they stay — SEC-12) | Not run | Not run | |
| SM-04 | Take a screenshot inside a chat | Decide whether it should be blocked (SEC-12) | Not run | Not run | |

---

## Result summary (fill in after the run)

| Area | Total | Pass | Slow | Fail | Blocked | Not run |
|---|---:|---:|---:|---:|---:|---:|
| Chat list + hold-press + status | 41 | | | | | 41 |
| Chat screen + hold-press + translate | 38 | | | | | 38 |
| Real-time status | 11 | | | | | 11 |
| Connection | 12 | | | | | 12 |
| Look and feel | 5 | | | | | 5 |
| Security on phone | 4 | | | | | 4 |
