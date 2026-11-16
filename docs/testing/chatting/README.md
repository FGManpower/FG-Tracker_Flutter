# Chatting — Testing Tracker

Testing-only folder. The feature guide is [`docs/01_CHATTING_MODULE_FRONTEND.md`](../../01_CHATTING_MODULE_FRONTEND.md) (reference only, not edited here).

| | |
|---|---|
| Last updated | 2026-11-16 |
| Branch | `multi-language` |
| App code changed by testing | **None** (tests and docs only) |

## Documents

| Folder / file | What it holds | Status |
|---|---|---|
| [unit_testing/unit_test_report.md](unit_testing/unit_test_report.md) | Automated unit, widget and real-time socket tests: results per feature, coverage, how to run | Done — last run 2026-11-16 |
| [pentesting/pentest_report.md](pentesting/pentest_report.md) | Security review (SEC-xx) + server-side pentest cases (S1–S21) | Client review done · server cases to run |
| [manual_testing/manual_checklist.md](manual_testing/manual_checklist.md) | Phone checklist: chat list, hold-press, status, chat screen, translate, real-time, connection, UI | Ready — not run yet |
| [bug_tracker.md](bug_tracker.md) | Every bug found, with root cause, fix idea and status | 38 app bugs (7 High, 25 Medium, 6 Low; none fixed yet) + 6 test-suite issues |

## Status at a glance

| Area | Automated | Manual | Main open problems |
|---|---|---|---|
| Chat list (new message, unread, sort, search) | Pass + known bugs | Not run | BUG-RT-01 list events lost; BUG-CL-01/02/06 |
| Chat list hold-press (pin, mute, archive, mark read/unread, delete) | Pass + known bugs | Not run | BUG-CL-03/04/05 |
| Status / Updates | Pass (widget tests flaky) | Not run | T-04 |
| Chat screen messages (send, history, paging, media parsing) | Pass + known bugs | Not run | BUG-CS-01/02/09 |
| Message hold-press (reply, copy, forward, edit, pin, info, delete) | Pass + known bugs | Not run | BUG-CS-03/06/07/08, Message Info BUG-CS-11…17 |
| Translate + Listen | Pass + known bugs | Not run | BUG-TS-01/02; privacy SEC-07 |
| Real-time: typing | Pass | Not run | List row redraw BUG-RT-05 |
| Real-time: ticks | Pass + known bugs | Not run | BUG-RT-03/08, BUG-CS-04/05/13 |
| Real-time: online / last seen | **No listener in app** | Not run | BUG-RT-06, BUG-RT-07 |
| Reconnect / background / offline send | Pass + known bugs | Not run | BUG-RT-04/09/10/11, BUG-CS-01 |
| Security | 3 socket checks pass | 4 phone checks | **SEC-01 plain HTTP/WS (Critical)**, SEC-02/03/04 |

## Coverage

18.3 % of chat module lines.

- **Well covered:** the logic files, 60–97 %.
- **Not covered:** the two chat screen controllers and the screens, 0 %. These are checked only by the manual checklist.

## Keeping this up to date

1. After each test run, update the result table in `unit_testing/unit_test_report.md` and the date above.
2. After a manual run, fill the Android / iOS columns in `manual_testing/manual_checklist.md`.
3. When a bug is fixed, turn its skipped test back on and set it to `Fixed` in `bug_tracker.md`.
4. New finding → add it to `bug_tracker.md` (app) or `pentesting/pentest_report.md` (security). Don't put testing notes into the module guide.
