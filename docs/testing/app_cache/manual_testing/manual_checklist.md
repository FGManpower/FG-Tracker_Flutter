# App Cache — Manual Checklist (Android + iOS)

| | |
|---|---|
| Last updated | 2026-11-17 |
| Build | Debug or profile build of branch `46Solution` (logs: filter `APP-CACHE`). **Use a full `flutter run`, not hot restart.** |
| Status | **Not run** (needs your phones / test accounts) |

Fill in **Pass / Fail + note** per platform.

## Per screen (repeat MC-01 … MC-07 for each)

Screens: **S1** Chat list · **S2** Archived · **S3** New chat · **S4** All Groups · **S5** Home banners · **S6** Recent calls · **S7** Status strip · **S8** Walkie channel list · **S9** Notifications

| ID | Steps | Expected | Android | iOS |
|---|---|---|---|---|
| MC-01 | Fresh login, open the screen | Skeleton once, then data | | |
| MC-02 | Kill the app, open it again, open the screen | Data at once (`[APP-CACHE] <screen> cache shown`), no skeleton | | |
| MC-03 | Airplane mode, open the screen | Cached data + "Couldn't refresh · Retry" (not S5 / S7); no endless loader; Retry works when back online | | |
| MC-04 | Stay on the screen; another phone sends a message / renames a group / adds or removes a member / calls / posts a status / sends a notification | Shows within 2 s | | |
| MC-05 | Background 10+ min (changes on the other phone meanwhile), resume | Catches up; nothing stale stays | | |
| MC-06 | Log out, log in with another account | Nothing from the first account on any screen | | |
| MC-07 | Big data: 100+ chats, 250 contacts, a 1000+ member / message group | Smooth scrolling, no jank, no freeze | | |

## Specific cases

| ID | Steps | Expected | Android | iOS |
|---|---|---|---|---|
| MC-10 | Delete a chat / clear a chat, kill + reopen | It does not come back (S1, S2) | | |
| MC-11 | Archive / unarchive the last chat, kill + reopen | Archived row correct | | |
| MC-12 | Delete a call / "clear all", kill + reopen | No ghost calls (S6) | | |
| MC-13 | Open Recent calls just after midnight (cache from yesterday) | Skeleton, then server list (cache dropped) | | |
| MC-14 | A status expires while the app is closed; reopen | Never shown from the cache | | |
| MC-15 | Walkie: a channel is "speaking" on another phone; kill + reopen | No stale "speaking" from the cache; live state from the socket | | |
| MC-16 | Walkie card, airplane mode, cold start, tap the card | Never opens the channel list without a live check; trial / plans screen or toast | | |
| MC-17 | Walkie channel list, airplane mode, tap a channel (no plan) | Toast "Check your connection…", channel does not open, no upgrade prompt | | |
| MC-18 | Notifications: mark all read, kill + reopen | Read state kept; unread count from the server | | |
| MC-19 | Leave your last group, kill + reopen All Groups | No ghost group after the refresh | | |

## Time to first content (median of 5 cold starts)

"Before" = `API done` / `rendered`; "After" = `cache shown` (same build, see guide 07 §4).

| Screen | Android before (ms) | Android after (ms) | iOS before (ms) | iOS after (ms) |
|---|---|---|---|---|
| Chat list | | | | |
| New chat | | | | |
| All Groups | | | | |
| Recent calls | | | | |
| Status strip | | | | |
| Walkie channels | | | | |
| Notifications | | | | |
| Banners | | | | |

## Run 2 (C-1.0.1)

MC-03 ("Couldn't refresh · Retry" on cached screens) for the chat list now follows MB-05 / MB-10 / MB-11 in `docs/testing/chatting/manual_testing/manual_checklist.md` §9 (bar only after the quiet retry, never on background loads, search has its own state). Not run yet.
