# Recent Calls – Multi-select

## Purpose
- The 3-dot menu is removed. It was in the Call screen header (Recent tab only); the rows never had one. Its only option was "Delete Call", which opened selection mode.
- Multi-select now starts with a **long-press on a row**. Select many calls and delete them in one go.
- Swipe-left-to-delete on a single row still works in normal mode.

## User flow
1. **Normal mode** (same as before)
   - Tap a row → call info / history screen.
   - Tap the avatar → quick profile popup.
   - Tap the call icon → call back.
2. **Long-press a row** → selection mode starts with that row selected (light haptic).
3. **In selection mode**
   - Tap a row or its avatar → select / unselect it.
   - A selected row gets a `#EEEDFD` background and a filled `#704AFA` circle with a white check on the avatar. Unselected rows show an empty circle.
   - The call icon is hidden; its space is kept so the layout doesn't move.
   - Swipe-to-delete is off.
4. **Top bar** replaces the header: `✕` · `<n> selected` · `Select all` / `Unselect all` · Delete (trash).
5. **Exit selection mode** with `✕`, Android back, Unselect all, unselecting the last row (n = 0), switching tab, or opening the Call screen again.

## Actions
| Action | Single / multi | API | Notes |
|---|---|---|---|
| Delete | multi | `DELETE /history`, body `{"callIds": [...]}` (bulk) | Confirm dialog first. Rows are removed at once and come back if the call fails. |
| Select all / Unselect all | multi | – | Selects only the rows visible under the current search / filter. |

The old 3-dot menu had no single-item actions (Call info, Call back, Copy number), so the bar has none.

## Delete details
- **Dialog:** "Delete n call(s)?" / "These calls will be removed from your call history." / Cancel · Delete (red).
- **Success:** snackbar "n call(s) deleted", and selection mode ends.
- **Failure** (for example, no internet): the bulk call is all-or-nothing, so every row comes back in its old place, still selected. Snackbar: "Couldn't delete n call(s). Try again."
- **While deleting:**
  - The Delete icon shows a loader.
  - ✕, Select all and Delete are disabled.
  - Pull-to-refresh is ignored.
  - A second delete can't start.

## Files changed
- `lib/app/modules/call/Views/call_recent_calls_tab.dart`
  - Long-press starts selection.
  - Check circle on the avatar; call icon hidden while selecting; selected colour `#EEEDFD`.
  - New `RecentCallsSelectionBar` widget with its confirm dialog.
  - The old long-press sheet, bottom "Delete (n)" button and old dialog are kept but unused (`// moved to selection bar`).
- `lib/app/modules/call/Views/call_screen.dart`
  - Header 3-dot menu removed.
  - The selection bar replaces the header while selecting.
  - Selection is cleared when the screen opens.
- `lib/app/modules/call/Controller/call_controller.dart`
  - `isSelecting`, `selectedIds`: new names for the existing `isSelectionMode` / `selectedCallIds`.
  - New: `startSelection(id)`, `toggle(id)`, `selectAll()`, `areAllVisibleSelected`, `deleteSelected()`.
  - Changed: `clearSelection()` now also exits selection; `toggleCallSelection()` exits when n reaches 0.
  - `_rebuildRecentDisplay()` drops selected ids that are no longer in the list.
  - `refreshRecentCalls()` does nothing while a delete is running.

## API
- **Bulk delete (existing):** `CallRepo.deleteMultipleCallHistory`, which sends `DELETE {base}history` with body `{"callIds": ["id1", "id2"]}` and returns `{status, message}`.
- **Backend request:** please confirm the endpoint accepts `callIds`. It would also help if it returned which ids failed, so partial failures could restore only those rows.

## Test cases (Android + iPhone)
| # | Case | Result |
|---|---|---|
| 1 | No 3-dot; row layout unchanged | pending device test |
| 2 | Tap row in normal mode → call info, same as before | pending |
| 3 | Long-press → selection mode, row selected, haptic | pending |
| 4 | Tap others → toggle; counter correct; Select all / Unselect all | pending |
| 5 | n = 1 / n > 1 → bar shows the same actions (no single-only actions exist) | pending |
| 6 | Delete 3 → confirm → removed, snackbar; still gone after refresh | pending |
| 7 | Delete with no internet → rows restored + error snackbar | pending |
| 8 | ✕ / Android back / n = 0 → exits selection | pending |
| 9 | New call while selecting (after pull-to-refresh) → appears unselected, selection kept | pending |
| 10 | Scroll + pagination while selecting | pending |
| 11 | Calling, call info, Contacts / Groups tabs unchanged | pending |

## Known limitations
- There is no recent-calls count on screen (the tab just says "Recent"), so only the list updates.
- New calls don't arrive live; the list updates on pull-to-refresh or pagination.
- Bulk delete is all-or-nothing, so a failure restores every selected row.
- If you go to another screen and come back without closing the Call screen, the selection is kept. It's cleared when the Call screen is opened again.
