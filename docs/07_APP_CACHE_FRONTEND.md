# FG Tracker App Cache (Hive): Flutter (Frontend) Guide

> **Document version:** `C-1.0.0` · **Date:** 2026-11-17 · **Branch:** `46Solution`
> **Scope:** the on-device cache behind the app's list screens, outside the chat screen. The chat screen keeps its own cache; see guide 01 §12.
> **Readers:** Flutter developers and QA.
> **Testing:** [docs/testing/app_cache/](testing/app_cache/README.md)

The rule: **open a screen, show the last known data at once, then refresh from the server.** The server is always the source of truth. The cache is only used for the first paint, and nothing else in the app is decided by it.

---

## 1. What is cached

| Area (`AppCache.*`) | Screen | Saved fields | Cap | Version | Valid for |
|---|---|---|---|---|---|
| `chatList` (`chat_list`) | Chat list | Every row field, lossless (`ChatListCacheCodec`) | 50 rows | 1 | Until refresh |
| `chatArchived` | Archived chats | Same | 100 | 1 | Until refresh |
| `fgContacts` | New chat | FG users that match the phonebook: id, name, number, photo, chatId (`UserListData.toJson`) | 1000 | 1 | Until refresh |
| `groups` | All Groups (also used by walkie, calls and the chat list through `GroupController.groupData`) | `GroupsResData.toJson` (8 fields) | 200 | 1 | Until refresh |
| `banners` | Home banners | `BannerData.toJson` | 7 | 1 | Until refresh |
| `callHistory` | Calls → Recent | Raw first page (`CallingDetail.toJson`) + section + **local day** | 50 | 1 | **Same local day only** (server "Today / Yesterday" labels) |
| `statusMine` / `statusFeed` | Status strip (chat list) | `StatusItemModel.toJson` / `ContactStatusGroupModel.toJson`, **no viewer lists** | 30 / 50 | 1 | Until `expiresAt` (or 24 h when the server sent none) |
| `walkieChannels` | Walkie channel list | `WalkieChannelItem.toJson` **without live state** (speaking, speaker, online) | 200 | 1 | Until refresh |
| `notifications` | Notifications | `NotificationModel.toJson` | 100 | 1 | Until refresh |

## 2. What is never cached, and why

| Not cached | Why |
|---|---|
| OTP, login, tokens | Kept where they are today; a cache is not a secret store |
| Payments, prices, plans, subscription / trial status, OTP charges, `/initialize` (it holds a Razorpay `keyId`) | Must always be live. **Fix in this release:** the walkie card used a cached `cached_walkie_can_use` as its access decision. Access now comes from the live `/initialize` answer only (§7) |
| Live location, tracking, Ghost / Private mode, own profile (`ProfileRepo.getProfileData`) | Protected modules (AGENTS.md); you chose to skip the profile |
| Call state, walkie audio / floor control, SOS, permission gate | Live state |
| Group info, member list, forward targets, contact picker | No `toJson` / permission-heavy / rarely used / device-only (see the Part 0 audit) |
| Home counts | Already cached in prefs (`GroupCountService`), unchanged |
| Home red dots | A stale dot would mislead |
| Attendance polls | Already inside the encrypted chat cache (group messages) |
| Safe Zone | Mock data, not reachable |

**Display vs action:** flags such as `isCreator`, `isActive`, `isMember` and `isAdmin` may be *shown* from the cache. Every action is still checked by the server, and the cache never unlocks one.

## 3. Storage

- **Service:** `lib/app/Data/Services/app_cache.dart` (`AppCache`, `AppCacheArea`, `AppCachePerf`).
- **Box:** one AES-encrypted Hive box per user, `app_cache_<userId>` (`Box<String>`).
- **Key and registry shared with the chat cache:**
  - the same AES key `fg_chat_cache_aes_key` in flutter_secure_storage (Keystore / Keychain `first_unlock_this_device`);
  - the same Hive init and the same registry `chat_cache_registry`.
- **The chat cache is unchanged:** same boxes, key and data, so no migration. Test AC-09 proves its data survives.
- **Entry key = area name; value:** `{"v": version, "uid": userId, "savedAt": ms, "items": [ ... ]}`.
- **Plain JSON maps** (`toJson`); no Hive adapters.
- **Large lists:** above 64 KB of JSON they are decoded with `Isolate.run`, off the UI thread.
- **Shared key creation:** both caches create the key through one shared future, so they can never end up with two different keys (test AC-10).

## 4. The flow (every cached screen)

1. **Open:** read the area (async, never blocks the UI). If there is data, show it; the skeleton only shows when there is nothing.
2. **API in parallel:** the call is exactly as before, plus a **10 s timeout**. It does not wait for the cache or the socket.
3. **Merge:** by id, newer wins (`AppCache.mergeCachedIntoLive`, `ChatListRules.isNewMessage` for the chat list). Then update the UI and save.
4. **Failure / timeout:** the cached rows stay and **"Couldn't refresh · Retry"** (`ChatRefreshFailedBar`) appears; never an endless loader. With nothing on screen, the old full error view shows as before.
5. **Save:** `AppCache.scheduleWrite` 1 s after a change, from a snapshot taken at the time of the change.

`[APP-CACHE]` debug logs (silent in release) show the timings: `<screen> open / cache shown / API done / rendered`. Today's time to first content equals **API done / rendered**; with the cache it is **cache shown**.

### 4.1 Per screen

| Screen | Read | Save (write-through) | Retry bar |
|---|---|---|---|
| Chat list | `ChatListController.onInit` → `_showCachedChatList` | `ever(privateChats / archivedChats)` | `chatlist_screen.dart` |
| New chat | `getRegisteredContacts` (after the session cache) | after matching, after chatId patch | `new_chat_screen.dart` |
| Groups | `GroupController.onInit` → `_showCachedGroups` | `ever(groupData)` | `groups_list_screen.dart` |
| Banners | `HomeController.fetchBanners` | after a successful fetch | none (home strip; pull to refresh) |
| Call history | `getRecentCall` (page 1, first time) | `_rebuildRecentDisplay`, delete, clear all | `call_recent_calls_tab.dart` |
| Status | `StatusFeedController.onInit` → `_showCachedStatuses` | `ever(myStatuses / contactGroups)` | none (no loader in the strip) |
| Walkie | `WalkieChannelController.onInit` → `_showCachedChannels` | `ever(channels)` | `walkie_group_select_screen.dart` |
| Notifications | `NotificationController.onInit` → `_showCachedNotifications` | `ever(notifications)` | `Notification.dart` |

## 5. Real-time socket rules (R1–R8)

| Rule | How it is met |
|---|---|
| **R1** Listeners never wait for the cache | Sockets are set up exactly where they were. The cache read runs next to them, never before them |
| **R2** One list in memory, write-through | Socket handlers update the same Rx list; `ever(...)` saves it (debounced 1 s, snapshot) |
| **R3** Newer wins | The cache only *adds* rows that are missing; a row the API or a socket put on screen first is kept (chat list: unless the cached last message is newer). Saving starts only after the cache read, so an early 1-row change never overwrites 50 saved rows (CL-05) |
| **R4** Gap fill | Existing refresh on open / reconnect / resume. New resume refresh for call history, notifications and status (status also drops expired items) |
| **R5** Deletes reach the cache | Delete / clear / leave / expire update the list, and the next save writes it. `private_chat_removed` / `_cleared` now also remove Archived rows. Call-history delete / clear-all and notification clear-all save the empty list. A server "0 groups / 0 banners" clears that area |
| **R6** Unread: server wins | The cached count is only used for the first paint (SC-08) |
| **R7** Logout / account switch | The existing logout call `ChatMessageCache.clearAll()` (unchanged in `logoutuser.dart`) runs the `AppCache` hook: logout listeners, generation++, pending writes dropped, box closed, then every registered box and the key are deleted. Every write checks userId + generation (SC-06) |
| **R8** Never wipe | A merge returns a new list; an empty list never replaces a saved copy unless the server confirmed it. Chat-list fixes: `archived_private_chats` with a bad payload no longer clears Archive; the full-list event keeps rows with a pending optimistic action and never re-adds a chat whose delete is pending |

## 6. Logout and account switch

- **Logout:** nothing new in `logoutuser.dart`. Its `ChatMessageCache.clearAll()` now also:
  - closes and deletes `app_cache_<uid>` for every user on the phone;
  - runs `AppCache` logout listeners.
- **Logout listeners:** the **permanent** controllers (they survive `Get.deleteAll`) empty their memory:
  - `StatusFeedController`: lists, highlights, owner;
  - `AttendanceController`: polls, votes, timers.
- **Account switch without logout:**
  - `StatusSection` calls `ensureLoadedForCurrentUser()`;
  - `NewChatController` drops its static session cache when the userId changes (`_cachedFor`).

## 7. Fixes made during this work

| # | Problem (Part 0 audit) | Fix |
|---|---|---|
| 1 | `_canAccessWalkie()` returned **true** on any error (fail-open on a paid feature) | Returns `null` on error. The tap is blocked with "Check your connection and try again."; no upgrade prompt, never opens |
| 2a | `NewChatController` static contact cache survived logout | Tied to the userId |
| 2b | `StatusFeedController` / `AttendanceController` (permanent) kept the previous user's data | Logout listeners empty them; status reloads for the new user |
| 3 | Walkie access read the cached `cached_walkie_can_use` when `/initialize` had not answered | Access only from the live answer. The card tap waits for `/initialize` (≤ 10 s), otherwise opens the trial / plans screen (which checks with the server). The old key is removed. The subtitle / colour still use the last value (display only) |
| — | `walkie/channels` fallback returned "success, 0 channels" when its fallback call failed (wiped the list) | Throws instead |
| — | Notifications: the list was cleared before every refresh, and a failed answer looked like "no notifications" | Not cleared; new `NotificationRepo.getNotificationsOrNull` (`null` = failed) |
| — | Chat list: a failed load was swallowed and looked like "no chats" | Retry bar |
| — | All Groups: an error replaced the list; the skeleton showed over data | Retry bar; skeleton only when empty |

## 8. How to add a cached screen

1. Is it on the never list (§2)? Then stop.
2. Add an `AppCacheArea` in `AppCache` (name, `version: 1`, `maxItems`) and to `allAreas`.
3. In the controller's `onInit`:
   - `_perf = AppCachePerf('<screen>')..mark('open');`
   - read with `AppCache.readAs(area, Model.fromJson)` and assign **only if the live list is still empty** (or merge with `mergeCachedIntoLive`);
   - set `_cacheReadDone = true` in `finally`.
4. Write-through: `ever(list, (_) => AppCache.scheduleWrite(area, () => [...toJson()]))`, only after `_cacheReadDone`.
5. API: add `.timeout(const Duration(seconds: 10))`.
   - On failure with data shown, set `refreshFailed = true` and show `ChatRefreshFailedBar`.
   - With nothing shown, show the old error view.
6. A server-confirmed empty list → `AppCache.clearArea(area)`, or save with `allowEmpty: true`.
7. Live / permission fields: strip them before saving (see walkie `_cacheJson`).
8. Tests in `test/app_cache/` using `AppCacheTestEnv`: cache first, offline + retry, write-through, delete, version bump.

## 9. Version-bump rule

**Change the shape of a saved map** (a `toJson` field added, renamed or re-typed, or the codec changed) → **bump that area's `version`.** Old entries are then dropped (never parsed), only for that area (CL-06). The chat cache has its own `ChatMessageCache.cacheVersion` (guide 01 §12).

## 10. Change log

| Version | Date | Change |
|---|---|---|
| C-1.0.0 | 2026-11-17 | First version: `AppCache` with 10 areas, socket rules R1–R8, logout via the existing call, fixes 1 / 2a / 2b / 3 and the four list-wipe fixes (§7). Tests: `test/app_cache/` (59, all pass). |
