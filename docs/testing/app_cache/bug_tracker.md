# App Cache — Bug Tracker

| | |
|---|---|
| Last updated | 2026-11-17 (Run 1) |
| Branch | `46Solution`, uncommitted |
| Security findings | [pentesting/pentest_report.md](pentesting/pentest_report.md) (PT-Fx) |

**Status:**
- `Fixed (test)`: fixed in code; an automated test proves it; phone check pending.
- `Fixed (code)`: fixed in code; no automated test can reach it.
- `Open`: not fixed.
- `Needs decision`: you must decide.

| ID | Area | Bug | Root cause | Status | Proof |
|---|---|---|---|---|---|
| AC-B01 | Walkie | A network error opened the paid channel list | `_canAccessWalkie()` `catch → true` | Fixed (code) | PT-F1 |
| AC-B02 | Walkie / Home | Access read from a cached prefs flag | `canUseWalkie` fallback to `cached_walkie_can_use` | Fixed (code) | PT-F2 |
| AC-B03 | New chat | Another account saw the previous user's contacts | Static session cache survives logout | Fixed (test) | CT-03 |
| AC-B04 | Status / Attendance | Previous user's statuses / polls stayed in memory | Permanent controllers survive `Get.deleteAll` | Fixed (test) | ST-04, ST-05 |
| AC-B05 | Walkie | Offline: the channel list emptied | Fallback returned "success, 0 channels" when it failed | Fixed (test) | WK-01 |
| AC-B06 | Notifications | List cleared on every refresh; a failed answer looked like "no notifications" | `refreshNotifications` cleared first; repo returned `[]` on `status:false` | Fixed (test) | NT-03 |
| AC-B07 | Chat list | A failed load looked like "no chats" | `catch` swallowed the error | Fixed (test) | CL-03 |
| AC-B08 | Chat list | Removed / cleared chats stayed in Archived | Handlers touched the main list only | Fixed (test) | SC-05 |
| AC-B09 | Chat list | A bad `archived_private_chats` payload cleared Archive | `archivedChats.clear()` on parse errors | Fixed (test) | CL-04 |
| AC-B10 | Chat list | Full-list event undid pending pin / mute and re-added a chat being deleted | `assignAll` ignored `_pendingActions` | Fixed (code) | — (needs the action path; phone MC-10) |
| AC-B11 | All Groups | An error replaced the list; skeleton over data | Error checked first; loader shown whenever loading | Fixed (test) | GR-03 |
| AC-B12 | Groups / Walkie | API failing before the cache read left a full-screen error over cached data | Race between the cache read and a fast failure | Fixed (test) | WK-01 (found while testing) |
| AC-B13 | Chat cache | Two caches creating the AES key at once could leave one box with a lost key | No shared key creation | Fixed (test) | AC-10 |
| AC-B14 | Notifications | If the server uses `status:false` for "no notifications", the old list stays with a retry bar | API contract unknown | Needs decision (backend) | — |
| AC-B15 | Walkie | Channels fetched twice on open | Controller `onInit` + screen `initState` | Open (low, not in scope) | Part 0 audit |
| AC-B16 | Members | Member search crashes on a null name / number | `m.name!` / `m.mobileNo!` | Open (low, not in scope) | Part 0 audit |
| AC-B17 | Groups | `listenGroupUpdated` removes the other screen's handler | `off(event)` without a handler | Open (low, not in scope) | Part 0 audit |
| AC-B19 | Chat screen | "Couldn't refresh · Retry" appeared inside an open chat ~10 s after opening, while the chat worked | 10 s history timeout / one failed request showed the bar; a late failure could show it after a success; a group reconnect never reloaded a failed history | **Reopened → fixed in F-1.2.9**, see BUG-CS-24…31 (the F-1.2.8 fix missed S1/S3/S4 and added the parallel group load) | `test/chat_qa/chat_refresh_bar_test.dart` RB-01 … RB-03 (RB-01 fails with the old behaviour); guide 01 §12.2.1 |
| AC-B20 | Chat list | "Couldn't refresh · Retry" on a live chat list | No foreground / "loaded once" rules, one catch for API + processing, only page-1 cleared it | Fixed (test) in F-1.2.9 | BUG-CL-10…16 (chatting tracker), RB-L01…L18 |
| AC-B18 | Status socket | After logout + login the status socket service stays registered but disconnected | `StatusBinding` only connects when not registered | Open (pre-existing; not in scope) | Code review |
