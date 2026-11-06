# Chat List (/chat-list): Root Cause Analysis

Branch: `46Solution` · Date: 2026-11-03 · Scope: unified chat list (private + group), Archived list, home "Chatting" badge.

## How to read this report

- **Evidence: code** means the root cause is visible in the Flutter source at the cited line. It is certain on the Flutter side.
- **Evidence: needs live capture** means the code allows the bug, but confirming it needs a real socket/API payload from two logged-in users. I could not run two devices from the development machine, so no live traffic was captured for this report. Run the capture procedure at the end of this file and paste the payloads under the matching issue before closing it.
- Line numbers refer to the code **before** the Phase 2 fix.

## 1. Flow map (as found)

### Chat list API
| Item | Value |
|---|---|
| Endpoint | `GET /chat-list?page=&limit=20&type=all&includeArchived=false[&search=]` ([GetMessageRepo.dart:184](../../lib/app/Data/Repositories/GetMessageRepo.dart)) |
| Parser | `PrivateChatResponse.fromJson` → `PrivateChatModel.fromJson` ([PrivateChatModel.dart](../../lib/app/Model/PrivateChatModel.dart)) |
| Pagination | `pagination.{currentPage,totalPages,hasNextPage}`; the list loads page 1 only unless `nextPage()` is called |
| Unread | per-row `unreadCount`, response-level `unreadTotalCount` |
| Last message | `lastMessage` / `lastActivity` map; preview text is read from `preview` → `message` → `content` |
| Archived | no REST call; socket `get_archived_private_chats` → `archived_private_chats` |

### Sockets (library: `socket_io_client ^3.1.1`, Socket.IO)
Three separate connections are opened to two namespaces:

| Connection | Namespace | Created by | Lifetime |
|---|---|---|---|
| `_socket` | `/chat` | `GroupChatController.onInit` → `SocketMessageService.init` (GroupChatController.dart:196) | Only after the user opens a group chat |
| `_privateChatSocket` | `/privateChat` | `MessageController` → `initPrivateChat` | While a private chat screen is open |
| `_privateChatListSocket` | `/privateChat` | `ChatListController.onInit` → `initPrivateChatListSocket` | **Only while the /chat-list route is alive**; disposed in `ChatListController.onClose` (chat_list_controller.dart:1346) |

Auth: `auth: {userId, token}` on `/privateChat`, `auth: {token, attendanceSupported}` on `/chat`. The token is read once at socket creation. There is no refresh on token expiry.

### Events used by the list
| Event | Dir | Socket | Registered / removed |
|---|---|---|---|
| `chat_list_updated`, `conversation_updated` | in | list socket + `/chat` | `_registerChatListListeners` / `disconnectPrivateChatListSocket` |
| `chat_list`, `common_chat_list`, `unified_chat_list` | in | list socket + `/chat` | `_registerFullChatListListeners` |
| `private_chat_removed`, `private_chat_cleared`, `private_chat_action_error`, `archived_private_chats` | in | list socket | in `initPrivateChatListSocket.onConnect` |
| `pin_private_chat`, `unpin_private_chat`, `archive_private_chat`, `unarchive_private_chat`, `mark_private_chat_read`, `delete_private_chat`, `mute_private_chat`, `get_archived_private_chats` | out | list socket | silently dropped if the list socket is not connected |
| `mark_seen {userId, groupId}` | out | `/chat` | group "mark as read" |
| `typing`, `stop_typing` | out/in | **chat screen** socket only | `listenPrivateTyping` (chat screen) |
| `group_typing`, `group_stop_typing` | out/in | `/chat` (group room) | `listenGroupTyping` (group screen); it calls `off(event)` with no handler, which removes **every** listener for that event |

---

## 2. Issues

### Issue 1: Typing indicator is never shown in the list
| | |
|---|---|
| Symptom | Nothing in the list changes while the other person types. |
| Root cause | (a) The list registers no `typing`, `stop_typing`, `group_typing` or `group_stop_typing` listener at all. (b) Typing is emitted on the chat-screen socket into the chat/group room (`Socket_Message_Services.dart:971`, `:432`). The list socket never joins those rooms. (c) `listenGroupTyping` calls `s.off("group_typing")` (`:469`), which would wipe any other listener on the shared `/chat` socket. (d) The `/chat` socket doesn't exist until a group chat is opened. |
| Evidence | code (a, c, d); **needs live capture** for (b): whether the server also emits typing to the receiver's personal room. |
| Side | **Both.** Flutter must listen. The backend must deliver typing to members who are not in the chat room (backend item #1). |
| Fix done | Flutter: list-level typing listeners on the list socket and the `/chat` socket, using handler-specific `off`. A `ChatTypingTracker` adds a 5 s auto-expiry, clears on a new message, ignores my own typing and never reorders. Rows in the main list and the Archived list show "typing…", "Name is typing…" or "A, B are typing…". `listenGroupTyping` now removes only its own handlers. Works end to end once backend #1 ships. |

### Issue 2: Chat actions are unreliable
| | |
|---|---|
| Symptom | Pin/archive/read/delete sometimes don't stick, revert after refresh, or do nothing for groups. Mark-as-unread is lost on another device or after reinstall. |
| Root cause | (a) Every action is a fire-and-forget emit that returns silently when the list socket is disconnected (`:1570`–`:1691`). The UI still changes, so the change is lost on the next fetch. (b) The `private_chat_action_error` handler is empty (`chat_list_controller.dart:1214`), so failures are never rolled back or shown. (c) Mark-as-unread is stored only in SharedPreferences (`:160`), so it is per device and lost on reinstall. (d) Delete for groups only removes the row locally (`:1203`), so it comes back on the next refresh. (e) Archiving a pinned chat unpins it locally but never tells the server. (f) All actions use `*_private_chat` events even for group rows. Whether the server accepts a group id there is unknown. |
| Evidence | code (a–e); **needs live capture** for (f). |
| Side | **Both** |
| Fix done | Flutter: optimistic update with a snapshot. It rolls back and shows a snackbar when the socket is offline or when `private_chat_action_error` arrives for that chat. Archiving a pinned chat also emits unpin. Delete keeps the existing confirmation dialog. Backend items #2 (persisted per-user flags and group support), #3 (multi-device `chat_updated`) and #6 (mark-unread API) are required. Group delete and server-side mark-unread are **blocked until backend**. |

### Issue 3: Socket only listens while the list screen is open
| | |
|---|---|
| Symptom | Badges and the list are stale after returning from other modules. Updates made while on the home screen are missed. |
| Root cause | `ChatListController` is created by `Get.put` in the `ChatListScreen` widget (`chatlist_screen.dart:35`). GetX links it to that route, so popping the route runs `onClose` → `disconnectPrivateChatListSocket()` (`:1346`), which disposes the socket and clears every callback. The `/chat` socket that carries group list events only exists after a group chat is opened. There is no reconnect or app-resume refetch. |
| Evidence | code |
| Side | Flutter |
| Fix done | The controller is now created by `HomeController.init`, so it lives for the whole logged-in session on the home route. GetX keeps the existing instance when the list screen calls `Get.put` again. It still disposes on logout (`Get.deleteAll`, non-permanent), so no data leaks between accounts. `ensureChatSocket` opens `/chat` up front. The list refetches on list-socket reconnect and on app resume, throttled. The protected `logoutuser.dart` was **not** touched. |

### Issue 4: Archived list reorders when the remote user opens the chat
| | |
|---|---|
| Symptom | Archived rows jump around. A chat sometimes pops into the main list and back. |
| Root cause | (a) `_handleArchivedPrivateChats` assigns the server array as-is (`:1310`) with no client sort. It runs on every list-socket (re)connect and on every server push. (b) In `_handlePrivateChatUpdated`, any update for an archived chat without `isArchived:true` takes the else branch and **removes it from Archived** (`:835`), then inserts it into the main list. A seen/read update triggered by the remote user opening the chat is exactly such a partial payload. (c) The main-list sort tie-break used the current order. Pinned rows sorted by `pinnedAt`. Time came from fields that can include `updatedAt`, which read/seen changes. (d) No `ValueKey` on rows. |
| Evidence | code (a, b, d); **needs live capture**: the payload the server sends to user A when user B opens the chat. |
| Side | Flutter (backend item #5 recommended) |
| Fix done | One sorter (`ChatListSorter`): pinned first, then last-message time, then a stable chat key. It is applied to both lists. A chat already in Archived stays archived unless the payload says `isArchived:false`. Order changes only for a new message (detected by message id or newer time) or pin/unpin. Read/seen/online updates merge in place and keep their time. `ValueKey(chatKey)` on every row. |

### Issue 5: Sender name appears twice in the preview
| | |
|---|---|
| Symptom | e.g. `Rahul: Rahul: hi` or `You: Prashant: hi` in group rows. |
| Root cause | The model reads the **display** string `preview` first (`PrivateChatModel.dart:329`). If the backend pre-formats it as `"Name: text"`, Flutter adds its own prefix in `MessagePreviewBuilder` (`message_preview_builder.dart:374`). The de-dupe guard (`:547`) only matches the exact same label, so it fails when the sender is me (backend sends my name, Flutter adds `You:`) or when the name differs (full name vs short name, extra spaces). |
| Evidence | code; **needs live capture** of `lastMessage` in `/chat-list` and in `chat_list_updated` to confirm the backend's exact format. |
| Side | Both. The real fix is to format from raw fields, not to strip strings. |
| Fix done | `MessagePreviewBuilder.forChat` now builds from the **raw** `lastMessage.content` plus structured `senderId`/`senderName` whenever the payload has them. The backend `preview` string is only a fallback for payloads without raw content. Private chats show `You: text` for my messages, group chats show `You:` or `Name:`, each exactly once. No string replacement. Backend item #4 asks for raw `content`, `senderId` and `senderName` in every payload. |

### Issue 6: New messages don't appear in the list
| | |
|---|---|
| Symptom | A new message (especially a group message, or a first message from a new contact) doesn't update or insert the row until pull-to-refresh. |
| Root cause | (a) Group list events arrive on `/chat`, which doesn't exist until a group chat is opened (see Issue 3). (b) For a chat not in the loaded page, `_handlePrivateChatUpdated` drops the update when the payload lacks a name (`:849`: name falls back to `"Unknown User"`). (c) For an existing chat, a partial payload without a name or message **removes the row** (`:878`–`:879`). (d) Updates are lost while the list route is closed (Issue 3). (e) Pagination was never wired in the UI. `nextPage()` existed but nothing called it, so only the first 20 chats could ever appear. |
| Evidence | code; **needs live capture**: which namespace and room the server emits `chat_list_updated` to for group messages. |
| Side | Flutter (backend item #1 also applies) |
| Fix done | `/chat` is opened up front. An unknown chat with an incomplete payload triggers a throttled page-1 refetch and is never silently dropped. A partial payload never deletes a row; it merges. Removal happens only through the explicit `private_chat_removed` or `private_chat_cleared` events. Load-more on scroll now calls `nextPage()` within 300 px of the bottom. |

### Issue 7: Unread counts and totals are wrong
| | |
|---|---|
| Symptom | Badges show counts for my own messages, stale counts, or a section total that doesn't match. The home "Chatting" dot sticks. |
| Root cause | (a) The "All Chats" badge shows `displayedChats.length` (`chatlist_screen.dart:513`), the number of **loaded rows** (max 20 per page), not unread. (b) The socket merge copies the server's `unreadCount` as-is (`:1022`). If the server sends the same row payload to the sender, my own message raises my badge. (c) The group "Chatting" marker is only ever set to true (`:205`), never cleared. (d) An API response that started before a socket update overwrote the newer socket state, because the server merge always wins (`:940`). (e) Archived unread counts aren't shown anywhere. (f) `unreadTotalCount` / `totalUnreadCount` are computed but not shown in any widget. (g) `PrivateChatModel.fromJson` defaults a **missing** `unreadCount` to `0` and a missing `isPinned` to `false` (`PrivateChatModel.dart`, `unreadCount: … ?? 0`, `isPinned: … ?? false`). Any partial socket update therefore wiped the badge and unpinned the chat, which also reordered the list. (h) The `/chat` socket remembers the last opened group and, on every reconnect, re-joins it and emits `mark_seen` (`Socket_Message_Services.dart` `onConnect`), even after that group chat was closed. That silently zeroed the group's unread count. **Checked and not a cause:** the duplicate listeners on `/chat` and the list socket. Both deliver absolute counts, so a duplicate delivery doesn't double them. |
| Evidence | code (a, c, d, e, f); **needs live capture** for (b). |
| Side | Both |
| Fix done | One store, one set of getters: `mainUnreadChatCount`, `totalUnreadCount` (main list only) and `archivedUnreadCount`. The "All Chats" badge shows unread chats. The Archived entry shows `Archived (n)` plus unread. For a new message I sent, my count never increases (temporary guard, `TODO(backend #7)`). The open chat stays at 0 (the existing `ActiveChatTracker`). A stale API response can't overwrite a newer socket message. The group marker is cleared correctly. Server values are accepted on load and reconnect. Fields missing from a realtime payload are treated as "unchanged", not 0/false. `GroupChatController.onClose` calls `clearActiveGroup`, so a closed group is no longer re-joined and marked seen on reconnect. |

---

## 3. Verification and known gaps

**Automated (all run on 2026-11-03):**
- `flutter test`: **141 passed, 0 failed** (46 new: `chat_list_logic_test`, `chat_list_controller_realtime_test`, `chat_list_widgets_test`, plus the new cases in `message_preview_builder_test`).
- `flutter analyze lib` compared against the committed baseline: **0 new issues**, 3 fewer than before.

**Not done, or done differently from the brief (deliberately):**
- **Socket layer:** the existing `SocketMessageService` singleton and its three connections were kept, not merged into one new service. List listeners are registered once by reference, and chat screens can no longer remove them. A rewrite would touch every chat screen and conflicts with "minimal, isolated changes".
- **Token expiry:** token expiry at socket auth isn't handled in Flutter. It needs a server error code first (backend #9).
- **Mark as unread** is still stored on the device (backend #6). **Group delete** is still local only (backend #2).
- **Widget tests** cover the new row widgets (typing text, Archived entry, large font). Full `ChatListScreen` tests for pinned order and the actions menu weren't feasible without a test harness for its sockets, storage and status section. Ordering, actions and rollback are covered by controller tests instead.
- **Stress tests and two-device tests** are manual. They're in `03_manual_test_cases_android_ios.md` (TC-46 to TC-52).
- **Protected modules** (login, location sharing / private mode) were not touched. `logoutuser.dart` already disposes the list store through `Get.deleteAll`.

## 4. Live-capture procedure (debug builds only)

Do this with User A on device 1 and User B on device 2. **Never log tokens.** The snippet only prints event names and payloads, and the auth map is never passed to it.

1. Temporarily add this to `initPrivateChatListSocket` and `init` in `Socket_Message_Services.dart`, right after the socket is created:
   ```dart
   socket.onAny((event, data) => debugPrint('[CAPTURE] $event => ${jsonEncode(data)}'));
   ```
2. Run `flutter run -d <id>` on both devices, then on each run: `flutter logs | findstr CAPTURE` (Windows) or `| grep CAPTURE`.
3. Perform: a private message B→A, a group message B→group, B typing then stopping, A opening the chat (read), and B opening the chat while A watches the Archived list.
4. Also record the `/chat-list` response once (Dio log or a breakpoint in `MessageRepo.getChatList`).
5. Paste each payload under the matching issue above, then **remove the snippet** before committing.
