# Chatting — Manual Test Checklist

| | |
|---|---|
| Module | Chatting: chat list, private / group / common chat, hold-press menu, forward, translate, status, Message Info, chat cache |
| Last updated | 2026-11-17 (Run 2, code F-1.2.5, branch `46Solution`) |
| Feature guide (reference) | [`docs/01_CHATTING_MODULE_FRONTEND.md`](../../../01_CHATTING_MODULE_FRONTEND.md) |
| Bugs | [../bug_tracker.md](../bug_tracker.md) |

## Run 2 status (2026-11-17)

**No phone case was run in Run 2.** The session had no human tester, no test accounts B / C, no OTP access (login files are frozen, `AGENTS.md`), no iPhone and no Mac. The app only talks to the **production** server, and test traffic to production needs written OK. So every Android / iOS cell below says **Not run** with the reason. Nothing in a result column is a prediction.

What was done instead, and is recorded in the rows:
- The **Auto** column was updated to today's automated result (Run 2).
- One read-only check on a real Android phone (model CPH2381, Android 14, debug build 2.0.4 / 322 already installed): the chat cache file is encrypted (SM-05). See [../pentesting/pentest_report.md](../pentesting/pentest_report.md) §E.

Reason codes used in the result columns:
- **NT** = Not run — no tester / accounts in this session.
- **NI** = Not run — no iPhone (and no Mac for the Simulator) available.
- **B-11.6** = Blocked — backend §11.6 (group receipts) not confirmed deployed on 2026-11-17.

## How to use this sheet

**Setup:** Phone 1 = real Android (account A). Phone 2 = iPhone (account B); without one, a second Android, and iOS = "Not run — no device". Phone 3 = any (account C). Groups: "QA-Group" (A, B, C) and one group with **1000+ messages**; a private chat A↔B; the common chat.

**For every case write in Notes:** build number, phone model, OS version, network (Wi-Fi / 4G / 3G throttled).

**Real-time cases:** screen-record BOTH phones and use a stopwatch. **≤ 2 s = Pass**, 2–10 s = **Slow**, only after reopen / refresh = **Fail**. Always write the delay. Ask the backend for the socket log (with timestamps) of the session if possible.

**Builds for device tests:** a FULL rebuild (stop + `flutter run`), never a hot restart: a hot restart does not register `flutter_secure_storage`, and the cache then fails silently (guide §12.4.1).

**Column "Auto":** what the automated tests checked (Run 2).
- `✔ <test>` = checked by a passing test. Still check it on a phone (no real server / screen).
- `✘ <bug>` = a test shows it is broken. Expect a fail until the bug is fixed.
- `—` = cannot be automated today. **Only a manual check covers it.**

**Status values:** `Not run` · `Pass` (≤ 2 s) · `Slow` (2–10 s) · `Fail` · `Blocked`.

---

## 1. Chat list

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| CL-01 | B sends A one message while A is on the chat list | B's row jumps to the top; preview and time update | ✔ chat_list_controller_qa · ✘ BUG-RT-01 (6 of 9 list events heard; Run 1: 2), BUG-CL-01 | NT | NI | |
| CL-02 | B sends 5 messages quickly | Badge = 5, preview = last message | ✔ unread dedupe tests | NT | NI | |
| CL-03 | A opens B's chat and comes back | Badge gone | ✔ | NT | NI | |
| CL-04 | C writes in QA-Group | Group row on top, "C: message", badge +1 | ✔ (logic) · server room to confirm | NT | NI | |
| CL-05 | New user D, who never chatted with A, sends a message | New row appears on top | ✔ | NT | NI | |
| CL-06 | B sends a photo, video, voice note, document, location, contact, poll / attendance | The right preview label each time | ✔ message_preview tests | NT | NI | |
| CL-07 | B types | "typing…" on B's row, clears when B stops | ✔ ChatTypingTracker (typing_indicator_test, rewritten T-05) · ✘ BUG-RT-05 (row does not redraw) | NT | NI | |
| CL-08 | C types in QA-Group | "C is typing…" on the group row | ✔ RT-07, typing_indicator_test | NT | NI | |
| CL-09 | B opens / closes the app | Online dot turns on / off | ✘ BUG-RT-06 (no live listener) | NT | NI | |
| CL-10 | B deletes the last message for everyone | Preview "This message was deleted" | ✔ · ✘ BUG-CL-07 | NT | NI | |
| CL-11 | B edits the last message | Preview shows new text | — | NT | NI | |
| CL-12 | Admin renames QA-Group and changes the icon | Name and icon change in the list | ✘ BUG-RT-02 | NT | NI | |
| CL-13 | Same as CL-12, but first open and close QA-Group once | Still updates | ✘ BUG-RT-02 | NT | NI | |
| CL-14 | Admin adds or removes a member / A is removed | Row updates live | — | NT | NI | |
| CL-15 | Admin deactivates the group | "Deactivated" badge appears | ✔ group_activation tests · ✘ BUG-RT-05 | NT | NI | |
| CL-16 | Chats receive messages in random order | Sorted newest first, pinned on top | ✔ sorting tests (T-02 updated) | NT | NI | |
| CL-17 | Search by name, phone and message text | Right rows. Archived chats not shown. | ✔ search tests | NT | NI | |
| CL-18 | Scroll until page 2–3 loads, then B sends | Loaded rows stay | — | NT | NI | |
| CL-19 | New account with no chats | Empty state | — | NT | NI | |
| CL-20 | Internet off | Cached list or offline message, no crash | — | NT | NI | |
| CL-21 | Unread total in the list vs the home red dot | Same number | ✔ notification_marker tests | NT | NI | |

### 1a. Chat list hold-press (long-press) menu

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| CLH-01 | Long-press a row → **Pin** | Row goes to top at once and stays after reopen | ✔ pin tests | NT | NI | |
| CLH-02 | Pin while offline | Pin is undone with a "couldn't update" message | ✔ async rollback (T-01 fixed) | NT | NI | |
| CLH-03 | **Unpin** | Row returns to time order | ✔ | NT | NI | |
| CLH-04 | **Mute** for 8 h / 1 week / always, then **Unmute** | Mute icon, no notification sound | ✔ · ✘ BUG-CL-04 (no rollback on error) | NT | NI | |
| CLH-05 | **Archive** | Row moves to Archived at once; archive count updates | ✔ archive tests (T-01 fixed) | NT | NI | |
| CLH-06 | Open Archived → **Unarchive** | Row back in the main list | ✔ | NT | NI | |
| CLH-07 | A new message arrives in an archived chat; also the peer of an archived chat **reads** it | Stays in Archive; archived badge updates; a read never reorders Archive | ✔ · ✘ BUG-CL-09 (a read re-sorts Archive) | NT | NI | |
| CLH-08 | **Mark as unread** | Dot shows; survives app restart | ✔ · ✘ BUG-CL-05 | NT | NI | |
| CLH-09 | **Mark as read** | Badge and dot cleared | ✔ | NT | NI | |
| CLH-10 | Mark unread on phone 1, open the app on phone 2 (same account) | Dot shows on phone 2 | ✔ (parsing) | NT | NI | |
| CLH-11 | **Delete chat** | Row gone at once; comes back if the server call fails | ✔ delete tests | NT | NI | |
| CLH-12 | Same actions on a group row | Same behaviour | ✔ | NT | NI | |

### 1b. Status (Updates) section

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| ST-01 | Tap "My Status" with no status | Popup offers only "Add to My Status" | ✔ status_section_widget (state isolated, T-04) | NT | NI | |
| ST-02 | Add a text / photo / video status | It shows under My Status | ✔ model tests | NT | NI | |
| ST-03 | B views A's status | A sees the view count go up | ✔ status:viewed test | NT | NI | |
| ST-04 | B posts a status | Green ring on B appears live in A's list | ✔ status:new test | NT | NI | |
| ST-05 | B deletes a status A is watching | Viewer skips it / ring disappears | ✔ delete tests | NT | NI | |
| ST-06 | Privacy "Only share with C" | B never sees it | — server (pentest S17) | NT | NI | |
| ST-07 | Status older than 24 h | Not shown | ✔ expiry tests (server decides) | NT | NI | |
| ST-08 | Tap outside or press back on the popup | Popup closes, screen still works | ✔ | NT | NI | |

---

## 2. Chat screen — messages

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| CS-01 | A sends a text to B | Shows on B once, within 2 s | ✔ RT-10 (once) | NT | NI | |
| CS-02 | A sends 10 messages quickly | Same order on both phones, no duplicates or gaps | ✔ merge / order tests · ✘ **BUG-CS-19** (a message repeated inside one page shows twice — regression) | NT | NI | |
| CS-03 | A and B send in the same second | Both see both, same order | ✔ ordering tests | NT | NI | |
| CS-04 | Photo, multiple photos, video, voice note, document, location, contact | Each sends, previews and opens | ✔ parsing tests | NT | NI | |
| CS-05 | Chat with 500+ messages, scroll up | Smooth paging, no repeats | ✔ HistoryPager tests | NT | NI | |
| CS-06 | Messages across midnight | "Today" / "Yesterday" / dates right in local time | ✔ last-seen / date tests (T-06: any time zone) | NT | NI | |
| CS-07 | Long text, emoji, links | Wraps, emoji show, link opens in browser | — | NT | NI | |
| CS-08 | Group: B and C write | Sender name on each bubble | — | NT | NI | |
| CS-09 | Attendance / poll card: B and C vote | Votes update live; admin can close it | ✔ attendance parsing | NT | NI | |
| CS-10 | Open the same chat 10 times, then B sends 1 message | Shows once | ✔ RT-10 (private), RT-12 (group) | NT | NI | |
| CS-11 | **BUG-CS-18.** Group with 60+ messages, scroll up 2 pages. Open Group info → add a member → back | All messages still shown; the "X added Y" line appears once | ✔ group_chat_blank_messages (11 / 11) | NT | NI | Was: list went empty until reopen |
| CS-12 | **BUG-CS-18.** Same group: remove a member, then back | All messages still shown | ✔ group_chat_blank_messages | NT | NI | |
| CS-13 | **BUG-CS-18.** Edit group name, then icon, then description | List never goes empty; new name / icon show | ✔ group_chat_blank_messages | NT | NI | |
| CS-14 | **BUG-CS-18.** Group open: background 30 s while B and C read and send, then resume. Repeat with Wi-Fi off 30 s → on | List stays full; ticks and new messages update | ✔ group_chat_blank_messages · ✔ merge upgrades ticks (BUG-CS-01 fixed in code) | NT | NI | iOS: also lock the screen 1 min |
| CS-15 | **BUG-CS-18.** Private chat: open, background 30 s, resume; Wi-Fi off → on | List stays full | ✔ group_chat_blank_messages (private case) | NT | NI | |
| CS-16 | **NEW (F-1.2.2) crash fix.** Open a group from a push notification **10×**: 5× with the app killed, 5× with the app in the background | Never the red "setState() or markNeedsBuild() called during build" screen; the right group opens with its messages | ✔ group_open_during_build_test (fails with the old order) | NT | NI | Count each of the 10 opens; record the build and the notification type (private / group / common) |

### 2a. Hold-press (long-press) menu on a message

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| MH-01 | Long-press **my** text | Reply, Copy, Forward, Edit, Pin, Info, Delete for me, Delete for everyone | ✔ menu tests | NT | NI | |
| MH-02 | Long-press a **received** text | No Edit, no Info, no Delete for everyone | ✔ | NT | NI | |
| MH-03 | Long-press my photo / voice / document | No Copy, no Edit; Info + deletes shown | ✔ | NT | NI | |
| MH-04 | Long-press an attendance card | No delete option at all (guide §5.1) | ✘ **BUG-CS-20** (delete is back since commit e761f45a — needs decision) | NT | NI | |
| MH-05 | Long-press a deleted message | No menu | ✔ | NT | NI | |
| MH-06 | **Reply** (menu and swipe right) | Reply bar shows the right preview; quoted bubble after send | ✔ reply preview tests | NT | NI | |
| MH-07 | Reply to a photo / voice / location / contact | Quote shows "Photo" / mic / pin / name, never a URL or JSON | ✔ | NT | NI | |
| MH-08 | **Copy** | Text on the clipboard | — | NT | NI | |
| MH-09 | **Forward** to 1 private chat + 1 group | Arrives once in each, with the "Forwarded" label | ✔ forward tests · ✘ BUG-CS-06 | NT | NI | |
| MH-10 | Forward screen: search by name and number | Right results; a user and a group with the same id are separate | ✔ | NT | NI | |
| MH-11 | **Edit** my message (twice; the second time with B offline) | Both phones show the newest text + "Edited" | ✔ · ✘ BUG-CS-07, BUG-CS-03, **BUG-CS-22** (2nd edit while offline) | NT | NI | |
| MH-12 | **Pin / Unpin** message | Pinned banner updates on both phones | ✔ | NT | NI | |
| MH-13 | **Info** on my private message | Sent / Delivered / Seen with correct times | ✔ (BUG-CS-15 fixed in code) · ✘ BUG-CS-17 | NT | NI | |
| MH-14 | **Info** on my group message | Read by / Delivered to with the right members (see MI-xx) | ✔ (BUG-CS-16 fixed in code), tick ↔ Info agreement tests | B-11.6 | NI | |
| MH-15 | **Delete for me** | Gone only on my phone | ✔ | NT | NI | |
| MH-16 | **Delete for everyone** | "This message was deleted" on both within 2 s | ✔ | NT | NI | |

### 2b. Translate and Listen

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| TR-01 | Swipe left on a received English text | Hindi translation card | ✔ translation tests | NT | NI | |
| TR-02 | Swipe left on a received Hindi text | English translation card | ✔ | NT | NI | |
| TR-03 | Swipe again | Card hides / shows, no new network call | ✔ | NT | NI | |
| TR-04 | Tap "Listen" on the original and the translation | Audio plays; button shows Stop while playing | ✔ widget tests | NT | NI | |
| TR-05 | Edit a message that was translated | New translation, not the old one | ✘ BUG-TS-01 | NT | NI | |
| TR-06 | Translate with internet off | Clear error, no endless spinner | ✔ (all endpoints fail) | NT | NI | |
| TR-07 | "नमस्ते, दोस्त" greeting | No double space in the result | ✘ BUG-TS-02 | NT | NI | |

### 2c. Message Info (F-1.2.0, guide §11) — NEW

Cases copied from guide §11.8. MI-02 … MI-07 need the backend fix in guide §11.6.

| ID | Steps | Expected | Auto | Android | iOS | Delay | Notes |
|---|---|---|---|---|---|---|---|
| MI-01 | Private regression: A sends, B reads | Info shows the read time; blue ticks | ✔ private Info widget tests | NT | NI | | |
| MI-02 | Group: A sends; B and C are online but not in the group screen | Delivered to B, C; Read by 0 | ✔ receipts aggregation · ✔ BUG-CS-16 fixed | B-11.6 | NI | | |
| MI-03 | B opens the group with A's Info open | B moves to "Read by" live; bubble stays grey | ✔ live widget test (Remaining → Delivered → Read) | B-11.6 | NI | | BUG-05 closes only when MI-03 + MI-04 pass |
| MI-04 | C opens the group | C moves to "Read by"; bubble turns blue | ✔ tick ↔ Info agreement (6 cases) | B-11.6 | NI | | |
| MI-05 | C offline → "2 remaining"; C comes online | C moves to "Delivered to" live | ✔ RT-09c, RT-09e | B-11.6 | NI | | needs §11.6-6 |
| MI-06 | Close / reopen Info | B still in "Read by" | — | B-11.6 | NI | | |
| MI-07 | Kill / restart A, open Info | Still right | ✔ HC-20 (readBy / deliveredTo survive the cache) | B-11.6 | NI | | needs §11.6-5 |
| MI-08 | Late joiner D | Not listed | ✔ late-joiner tests (with / without a receipt) | NT | NI | | the app has no join time; relies on the API |
| MI-09 | Resume after 1 min / 10+ min | Info re-reads, correct | — | NT | NI | | |
| MI-10 | Open / close Info 10×, then B reads | Applied once | ✔ RT-12 + live widget test (duplicate ignored) | NT | NI | | |
| MI-11 | Common chat: MI-02 … MI-04 | Same as group | — | B-11.6 | NI | | |
| MI-12 | Types: photo, voice, document, poll, attendance | Right preview, no path / JSON | ✘ BUG-CS-11, BUG-CS-12 (private Info) | NT | NI | | |
| MI-13 | Hindi / Marathi: labels, time format, no overflow | All translated | ✔ group labels from l10n · ✘ BUG-CS-17 (private Info) | NT | NI | | |

---

## 3. Real-time status

| ID | Steps | Expected | Auto | Android | iOS | Delay | Notes |
|---|---|---|---|---|---|---|---|
| RS-01 | A has B's chat open; B opens the app | "Online" within 2 s | ✘ BUG-RT-06 | NT | NI | | |
| RS-02 | B closes the app / background / kill / airplane (each) | "Last seen …" | ✘ BUG-RT-06 | NT | NI | | |
| RS-03 | A opens B's chat from B's profile (not from the list) while B is offline | "Last seen …", not blank | ✘ BUG-RT-07 | NT | NI | | |
| RS-04 | B types (private) | "typing…" in the top bar, clears ≤ 4 s after B stops | ✔ RT-06, typing tests | NT | NI | | |
| RS-05 | B and C type in the group | "B, C are typing…" | ✔ RT-14 (handled once), ChatTypingTracker | NT | NI | | |
| RS-06 | A sends; B online, chat closed | ✓ → ✓✓ grey | ✔ | NT | NI | | |
| RS-07 | B opens the chat | ✓✓ turns blue on A live | ✔ · ✘ BUG-CS-04 (if the server sends no ids) | NT | NI | | |
| RS-08 | Watch ✓✓ for 10 s after sending | Never drops back to ✓ | ✘ BUG-RT-08 | NT | NI | | |
| RS-09 | B offline, A sends, B comes online | ✓ → ✓✓ when B connects | — server | NT | NI | | |
| RS-10 | Group: B reads, then C reads | Blue only when everyone has read | ✔ RT-09 … RT-09f, receipts tests (BUG-RT-03, BUG-CS-13 fixed in code) | B-11.6 | NI | | |
| RS-11 | B blocks A / A leaves or is removed from the group | Input disabled, notice shown live | ✔ BLK-01 … 07 | NT | NI | | Backend #25 / #26 still open: note which behaviour comes from the 4 s check and which from a server event |
| RS-11a | A has B's chat open; B blocks A | A sees "contact blocked you" within ~4 s without sending (4 s check; instant once #25 ships). B unblocks → banner goes within ~4 s | ✔ BLK-01 … 05 | NT | NI | | Full rebuild first |
| RS-11b | Blocked A sends one message | Banner replaces the input on the first rejected send; draft not resent | ✔ BLK-06, BLK-07 | NT | NI | | |
| RS-11c | A blocked, background ≥ 30 s, foreground | Banner right after resume; no checks in background | — | NT | NI | | iOS: also Control Centre (inactive) |
| RS-11d | After the block, A and B reopen the chat | Old messages still shown (last 50 from the cache; server copy once #26 ships) | ✔ chat_message_cache_test HC-01 … HC-25 (old CACHE-01…07 moved there) | NT | NI | | |
| RS-12 | A **archived** group G with G open; C leaves G | "C left" appears within ~3 s without reopening | ✔ GML-01 … 03 | NT | NI | | Also C removed by admin; also G not archived (once, no duplicate). Backend #27 |
| RS-13 | Chats ▸ Archive ▸ tap an archived **group** (row, and photo ▸ "Message") | Group chat opens with all messages; can read and send; back returns to Archive; group still archived | — manual only (screen needs live controllers; no test without an app change) | NT | NI | | Also a deactivated archived group, and an archived private chat |
| RS-14 | Group Info ▸ Add Members ▸ type fast, delete, open / close the keyboard several times | Smooth; list stays above the keyboard | — | NT | NI | | Also a low-end Android; landscape |

---

## 4. Chat cache (Hive, F-1.2.4) — NEW

Use a debug or profile build (logs `[CHAT-CACHE]`, `[CHAT-PERF]`). Full rebuild before the run.

| ID | Steps | Expected | Auto | Android | iOS | Delay | Notes |
|---|---|---|---|---|---|---|---|
| HC-01 | Open a chat for the first time | Loader once, then messages | ✔ HC-17 (no copy → empty) | NT | NI | | |
| HC-02 | Kill the app, open the same chat | Messages instantly, no loader | ✔ HC-02, HC-20 (round trip) | NT | NI | | |
| HC-03 | Group with 1000+ messages, cold start | Instant from cache; new messages added after refresh | ✔ HC-03 (merge by id), HC-04 (newest 50) | NT | NI | | |
| HC-04 | B sends 3 messages while A's app is closed; A opens the chat | Cached messages first, then the 3 new ones, no duplicates | ✔ HC-03 · ✘ BUG-CS-19 (duplicates inside one page) | NT | NI | | |
| HC-05 | Airplane mode, open a cached chat | Cached messages + "Couldn't refresh · Retry" within ≤ 10 s, never an endless loader; network on + Retry → bar goes | ✔ HC-08 (failed API never wipes the copy) · — bar timing manual | NT | NI | | |
| HC-06 | Scroll up fast / down fast | No blank bubbles, no duplicates | — | NT | NI | | |
| HC-07 | Add a member while the group is open | Messages stay visible | ✔ group_chat_blank_messages | NT | NI | | |
| HC-08 | Edit / delete for everyone while the other phone is offline, then open | Correct after refresh | ✔ HC-09, merge upgrade (BUG-CS-01 fixed) · ✘ BUG-CS-22 (2nd edit) | NT | NI | | |
| HC-09 | Logout, log in with another account | No old messages visible | ✔ HC-12, HC-14, HC-22 … HC-24 · ✘ BUG-CS-23 (only if the Keystore hangs) | NT | NI | | Check also SM-03 |
| HC-10 | Open 30+ different chats | Oldest chat's copy removed; app works | ✔ HC-06, HC-07 (LRU 30) | NT | NI | | |

### 4a. Open time (guide §12.5)

Median of 5 cold starts. "Before" = the commit before F-1.2.4, or right after logout (cache empty). Values come from the `[CHAT-PERF]` logs.

| Device | Chat | Before: messages visible (ms) | After: cache shown (ms) | After: API done (ms) | After: list rendered (ms) | Notes |
|---|---|---|---|---|---|---|
| Android | group 1000+ | Not run (NT) | Not run (NT) | Not run (NT) | Not run (NT) | The phone's logcat (read 2026-11-17 20:22) held no `[CHAT-PERF]` line: no chat was opened in that window |
| Android | private | Not run (NT) | Not run (NT) | Not run (NT) | Not run (NT) | |
| iOS | group 1000+ | Not run (NI) | Not run (NI) | Not run (NI) | Not run (NI) | |
| iOS | private | Not run (NI) | Not run (NI) | Not run (NI) | Not run (NI) | |

Reference only (not a Run 2 result): the guide's change log F-1.2.5 quotes one developer log from a CPH2381: group 252, cache shown at 124 ms, API ~2 s.

### 4b. Stuck loader (F-1.2.5)

| ID | Steps | Expected | Auto | Android | iOS | Delay | Notes |
|---|---|---|---|---|---|---|---|
| SL-01 | Kill the app, open it, go straight to the 1000+ group; 10× | With cache: messages at once. First-ever open: loader stops within 10 s (messages or Retry), never spins forever | ✔ 10 s history timeout constant (`ChatScreenRules.historyTimeout`) · — UI | NT | NI | | Count the 10 runs |
| SL-02 | Same on slow network (3G throttling) | Cached messages shown; refresh finishes or the Retry bar appears | — | NT | NI | | |
| SL-03 | Cold start by tapping a group notification | Same as SL-01 | ✔ group_open_during_build_test | NT | NI | | |
| SL-04 | Back, then reopen the same group | Instant | ✔ HC-26 (after Back the saved 50 stay) | NT | NI | | |
| SL-05 | Socket log during SL-01 … SL-04 (ask the backend, or `[SEEN-DBG] EMIT mark_seen (group)` in logcat) | Group `mark_seen`: **1 per open**, **0 on close** when nothing new was read | ✔ SL-MS-01 … 04 (real controller + fake server: 1 per open, 5 opens = 5, 0 on close, 1 with ids for a message read while open) | NT | NI | | |

---

## 5. Connection

| ID | Steps | Expected | Auto | Android | iOS | Delay | Notes |
|---|---|---|---|---|---|---|---|
| CN-01 | A in background 30 s; B sends, reads and edits; A comes back | Everything up to date | ✔ RT-16/17/18 (rejoin), merge upgrade (BUG-CS-01 fixed) · ✘ BUG-CS-22 | NT | NI | | |
| CN-02 | Same after 10+ minutes in background | Same | ✘ BUG-RT-04 | NT | NI | | |
| CN-03 | Internet off 30 s → on; B sent 3 messages | All 3 appear | ✔ RT-17 | NT | NI | | |
| CN-04 | Internet off 5+ minutes → on | Live updates resume | ✘ BUG-RT-09 (to confirm on device) | NT | NI | | |
| CN-05 | Switch Wi-Fi ↔ mobile data | Live within 10 s | — | NT | NI | | |
| CN-06 | Send while offline (private and group) | Clear failed state, nothing lost, no duplicate | ✘ BUG-RT-10 (group) | NT | NI | | |
| CN-07 | Kill the app, open it from a chat notification | Right chat opens with full history | ✔ notification_routing tests | NT | NI | | |
| CN-08 | Lock the screen 2 min | Live updates resume | — | NT | NI | | |
| CN-09 | Go Home through a call or walkie-talkie screen, open the list, B sends | List still live | — (suspected BUG-RT-11) | NT | NI | | |
| CN-10 | Log out A, log in C on the same phone | Only C's data; live works | ✔ SEC-RT-03, HC-14 | NT | NI | | |
| CN-11 | iPhone: repeat CN-01, CN-02, CN-03 | Same as Android | — | — | NI | | |
| CN-12 | Push notifications + app icon badge | Arrive, right count, tap opens chat | — | NT | NI | | |

---

## 6. Look and feel

| ID | Steps | Expected | Auto | Android | iOS | Notes |
|---|---|---|---|---|---|---|
| UI-01 | Hindi and Marathi | All labels translated, nothing cut off | ✔ l10n_completeness · ✘ BUG-CS-17 | NT | NI | |
| UI-02 | Largest system font | No overflow | ✔ widget tests | NT | NI | |
| UI-03 | Small phone with the keyboard open | Input above the keyboard; last message visible | ✔ | NT | NI | |
| UI-04 | Dark mode | Bubbles, ticks and typing text readable | — | NT | NI | |
| UI-05 | Tap a member in Message Info | Ripple is visible | ✘ BUG-CS-14 | NT | NI | |

---

## 7. Security checks you can do on a phone

Full list: [../pentesting/pentest_report.md](../pentesting/pentest_report.md)

| ID | Steps | Expected | Android | iOS | Notes |
|---|---|---|---|---|---|
| SM-01 | Put the phone behind mitmproxy / Charles and send a message | Today you **will** see the token and the message in plain text (SEC-01). After the fix: only TLS | NT | NI | Needs a proxy set up on the phone + a tester |
| SM-02 | Send `javascript:alert(1)` and `intent://x#Intent;end` as text | Not clickable | NT | NI | |
| SM-03 | **Changed (F-1.2.4):** log out, then look at the app files (rooted Android emulator, or `adb run-as` on a debug build; iOS Simulator app container) | No `chat_cache_*.hive`, no `chat_cache_registry.hive`, Keystore / Keychain entry `fg_chat_cache_aes_key` gone. Downloads / image cache still stay (SEC-12) | Not run — needs a logout on the phone (NT). Before-logout state checked: files present (§E) | NI (no Mac for the Simulator) | Unit: HC-12, HC-22 pass |
| SM-04 | Take a screenshot inside a chat | Decide whether it should be blocked (SEC-12) | NT | NI | |
| SM-05 | **NEW:** read the cache file from the app folder | No readable message text | **Pass** — 2026-11-17, CPH2381, Android 14, debug 2.0.4 / 322, read-only `adb run-as`: 0 hits for message keys / URLs in a 237 KB file. Entry keys (chat ids) are readable → SEC-18 | NI | Pentest §E |

---

## 8. End-to-end journeys on 3 real phones (Part D3) — NEW

Run after the E2E plan is approved. Screen-record all phones.

| ID | Journey | Expected | Android | iOS | Notes |
|---|---|---|---|---|---|
| J1 | First day: fresh install → language → login → first chat → text, photo, voice, document, location, contact → forward to a group | Every step works; previews right; forward arrives once with "Forwarded" | NT | NI | |
| J2 | Group day: create → add B, C → typing, replies, mentions, poll / attendance → rename + icon → B leaves → C removed → Message Info at each step | Live updates; "X left" / removed lines; Info right at each step; list never blank | NT · MI parts B-11.6 | NI | |
| J3 | Bad network: Wi-Fi → 4G → airplane 1 min → send offline → online → 10+ min background → resume | Nothing lost, no duplicates, live again (also iPhone) | NT | NI | |
| J4 | Notifications: killed / background / locked; private, group, common | Arrive; tap opens the right chat; badge counts right; none for the open chat or my own message | NT | NI | |
| J5 | Block + privacy: block / unblock both ways with both chats open; logout leaves no chat data; mitmproxy check (SEC-01) | Banner ≤ 4 s; history kept; no cache after logout | NT | NI | |
| J6 | Two accounts on one phone | Only the logged-in account's chats, cache and notifications | NT | NI | |
| J7 | Big group: 1000+ group, cold start 10×, fast scroll | No stuck loader, no blank list, no duplicates | NT | NI | |

---

## Result summary (Run 2, 2026-11-17)

Manual results only (the Auto column is not counted here).

| Area | Total | Pass | Slow | Fail | Blocked | Not run |
|---|---:|---:|---:|---:|---:|---:|
| Chat list + hold-press + status | 41 | 0 | 0 | 0 | 0 | 41 |
| Chat screen + hold-press + translate | 39 | 0 | 0 | 0 | 1 (MH-14 Android) | 38 |
| Message Info (MI) | 13 | 0 | 0 | 0 | 7 (MI-02 … MI-07, MI-11) | 6 |
| Real-time status | 18 | 0 | 0 | 0 | 1 (RS-10 Android) | 17 |
| Chat cache (HC) + open time + stuck loader (SL) | 10 + 4 + 5 = 19 | 0 | 0 | 0 | 0 | 19 |
| Connection | 12 | 0 | 0 | 0 | 0 | 12 |
| Look and feel | 5 | 0 | 0 | 0 | 0 | 5 |
| Security on phone | 5 | 1 (SM-05 Android) | 0 | 0 | 0 | 4 |
| End-to-end journeys | 7 | 0 | 0 | 0 | 0 | 7 |
| **Total** | **159** | **1** | **0** | **0** | **9** | **149** |

Counted per case on Android (iOS: every case Not run — no iPhone / Mac).
