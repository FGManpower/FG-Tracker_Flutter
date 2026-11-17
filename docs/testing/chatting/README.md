# Chatting — Testing Tracker

Testing-only folder. The feature guide is [`docs/01_CHATTING_MODULE_FRONTEND.md`](../../01_CHATTING_MODULE_FRONTEND.md) (reference only, not edited here).

| | |
|---|---|
| Last updated | 2026-11-17 (Run 2) |
| Branch | `46Solution` — HEAD `d892094c` (F-1.2.6) + uncommitted chat-list / app-cache work from a parallel session. Run 2 was planned on F-1.2.5; see the unit test report R2.1 |
| Previous run | Run 1, 2026-11-16, branch `multi-language` |
| App code changed by testing | **None** (tests and these 5 docs only) |

## Documents

| Folder / file | What it holds | Status |
|---|---|---|
| [unit_testing/unit_test_report.md](unit_testing/unit_test_report.md) | Automated unit, widget and real-time socket tests: results, per feature, failures, flaky table, coverage, testability list, how to run, **E2E plan (D0)** | Run 2 done 2026-11-17 · E2E: plan only, waiting for approval |
| [pentesting/pentest_report.md](pentesting/pentest_report.md) | Security review (SEC-xx), server pentest cases (S1–S21), Run 2 phone check of the cache file | Updated · server cases not run (no staging OK) |
| [manual_testing/manual_checklist.md](manual_testing/manual_checklist.md) | Phone checklist (159 cases incl. Message Info, Hive cache, stuck loader, open time, J1–J7) | Ready · **not run on phones in Run 2** (no tester / accounts / iPhone) |
| [bug_tracker.md](bug_tracker.md) | Every bug with root cause, fix idea, status and proof | 45 app bugs (39 old + 6 new) + 8 test-suite items |

## Status at a glance (Run 2)

| Area | Automated | Manual | E2E | Main open problems |
|---|---|---|---|---|
| Chat list (new message, unread, sort, search) | Pass + known bugs | Not run | Not built | BUG-RT-01 (6 of 9 events now), BUG-CL-01/02/06 |
| Chat list hold-press + Archive | Pass + known bugs | Not run | Not built | BUG-CL-04/05/09 (BUG-CL-03 fixed in uncommitted code) |
| Status / Updates | Pass (no longer flaky) | Not run | Not built | — |
| Chat screen messages + history merge | Pass + known bugs | Not run | Not built | **BUG-CS-19 duplicates (regression)**, BUG-CS-02, -21, -22 |
| Blank group list (F-1.1.9) | Pass (11) | Not run | Not built | Phone check CS-11 … CS-15 |
| Crash opening a group (F-1.2.2) | Pass | Not run (CS-16) | Not built | — |
| Message hold-press | Pass + known bugs | Not run | Not built | **BUG-CS-20 attendance delete (needs decision)**, BUG-CS-03/06/07 |
| Message Info + receipts (F-1.2.0) | Pass (+ tick ↔ Info agreement) | Blocked — backend §11.6 | Not built | Backend §11.6; BUG-CS-11/12/14/17 (private Info) |
| Hive cache (F-1.2.4 / 1.2.5) | Pass + 1 bug (HC-23 flaky under load) | Not run · SM-05 encryption **Pass** on a real phone | Not built | BUG-CS-23, SEC-18 (cache metadata readable) |
| Group `mark_seen` (F-1.2.5) | Pass (real controller + fake server) | Not run (SL-05) | Not built | — |
| Translate + Listen | Pass + known bugs | Not run | Not built | BUG-TS-01/02; SEC-07 |
| Real-time typing | Pass (typing test now uses app code) | Not run | Not built | BUG-RT-05 (row redraw) |
| Real-time ticks | Pass + known bugs | Not run / Blocked (group) | Not built | BUG-RT-08, BUG-CS-04 |
| Online / last seen | **No listener in app** | Not run | Not built | BUG-RT-06, BUG-RT-07 |
| Block (F-1.1.8) | Pass (7) | Not run | Not built | Backend #25 / #26 |
| "X left" (F-1.2.1) / archived group open (F-1.2.3) | Pass (3) / manual only | Not run | Not built | Backend #27 |
| Reconnect / background / offline send | Pass + known bugs | Not run | Not built | BUG-RT-04/09/10/11 |
| Security | Socket + cache tests pass | 1 of 5 phone checks (SM-05 Pass) | — | **SEC-01 plain HTTP / WS (Critical)**, SEC-02/03/04, SEC-12 partly, SEC-18 new |

## Numbers (Run 2)

| | |
|---|---|
| Final chat suite (35 files, 20:47) | 689 pass · 34 skipped (known bugs) · 3 fail → 1 app bug (BUG-CL-08), 1 compile error from the parallel session's half-edited file (re-run 7 / 7 pass), 1 timing flake (HC-23, passes alone) |
| Whole project, 3 runs | 926 / 947 / 947 pass; 31–32 fail (27 permission setup + 3 language selection, both outside chat; chat: BUG-CL-08 + the BUG-CS-20 regression) |
| Flaky | HC-23 only (under heavy load). T-04 and RT-18 passed in all 3 runs |
| Coverage | Overall 6.2 % → **7.2 %** · chat module 18.3 % → **22.2 %** · new `message_receipts.dart` 98.2 %, `chat_message_cache.dart` 81.4 %, `GroupChatController.dart` 0.1 % → 15.7 % |

## Open problems (top)

1. **SEC-01** — all traffic plain HTTP / WS to a raw IP (App + Backend).
2. **BUG-CS-19** — duplicate bubbles from a page that repeats a message; regression from commit `271d63a3` (App).
3. **Backend §11.6** — group read / delivered receipts; blocks Message Info MI-02 … MI-07 (Backend).
4. **BUG-RT-01 / BUG-RT-06** — chat list misses 3 list events; no live presence (App; presence also Backend).
5. **BUG-CS-20** — attendance cards can be deleted again; guide says no (needs decision).
6. **E2E blocked** — no way to point the app at staging without a `lib/` change (D0, unit test report R2.9).
7. **No phone run yet** — Run 2 manual / E2E columns are all Not run or Blocked.

## Keeping this up to date

1. After each test run, update the result table in `unit_testing/unit_test_report.md` and the date above.
2. After a manual run, fill the Android / iOS columns in `manual_testing/manual_checklist.md`.
3. When a bug is fixed, turn its skipped test back on and set it to `Fixed in code — phone check pending` (or `Fixed (test + phone)` after the phone case passes) in `bug_tracker.md`.
4. New finding → add it to `bug_tracker.md` (app) or `pentesting/pentest_report.md` (security). Don't put testing notes into the module guide.
5. `flutter test --coverage` rewrites the tracked `coverage/lcov.info`: restore it with `git checkout -- coverage/lcov.info`.

## Run 3 (2026-11-18): false "Couldn't refresh · Retry"

- Root causes and fixes: [bug_tracker.md](bug_tracker.md) BUG-CL-10…16, BUG-CS-24…31 (all fixed in F-1.2.9).
- Tests: [unit_testing/unit_test_report.md](unit_testing/unit_test_report.md) §R3 — 68 new tests, all pass; every rule proven by a mutation check; no new failure project-wide.
- Phone + E2E: [manual_testing/manual_checklist.md](manual_testing/manual_checklist.md) §9 — **not run yet** (needs devices / staging).
- Security: [pentesting/pentest_report.md](pentesting/pentest_report.md) §G — no new risk.
