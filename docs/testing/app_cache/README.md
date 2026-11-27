# App Cache — Testing Tracker

Testing folder for the on-device cache. The feature guide is [`docs/07_APP_CACHE_FRONTEND.md`](../../07_APP_CACHE_FRONTEND.md); the chat screen cache is in guide 01 §12.

| | |
|---|---|
| Last updated | 2026-11-17 (Run 1) |
| Branch | `46Solution`, uncommitted |

## Documents

| File | What it holds | Status |
|---|---|---|
| [unit_testing/unit_test_report.md](unit_testing/unit_test_report.md) | 59 new unit / widget tests incl. SC-01 … SC-08, coverage | Done: all pass; coverage 87–95 % |
| [pentesting/pentest_report.md](pentesting/pentest_report.md) | PT-01 … PT-11 and findings PT-F1 … PT-F7 | Code review + automated checks done; **device steps not run** |
| [manual_testing/manual_checklist.md](manual_testing/manual_checklist.md) | MC-01 … MC-19 per screen, time to first content table | Ready, **not run** (needs phones) |
| [bug_tracker.md](bug_tracker.md) | AC-B01 … AC-B18 | 13 fixed, 1 needs a decision, 4 open (low, out of scope) |

## Status at a glance

| Screen | Automated | Manual | Main open items |
|---|---|---|---|
| Chat list + Archived | Pass (11) | Not run | AC-B10 phone check |
| New chat | Pass (4) | Not run | — |
| All Groups | Pass (6) | Not run | — |
| Home banners | Code only | Not run | — |
| Recent calls | Pass (5) | Not run | — |
| Status strip | Pass (5) | Not run | AC-B18 (status socket after re-login, pre-existing) |
| Walkie channels | Pass (2) | Not run | PT-F1 / F2 fixed, phone MC-16 / MC-17 |
| Notifications | Pass (5) | Not run | AC-B14 (backend contract) |
| Security | PT-01 … PT-11 automated / review | Device steps not run | PT-F3 backups, PT-F4 location in chat cache, PT-F5 notification `data` — need decisions |
