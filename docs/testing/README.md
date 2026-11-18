# Testing — Index

QA, unit, manual and penetration testing for FG Tracker, one folder per module. The feature guides stay in `docs/` and are only referenced from here.

| Module | Folder | Unit / widget | Pentest | Manual | Last updated |
|---|---|---|---|---|---|
| Chatting | [chatting/](chatting/README.md) | Done (800 pass project-wide; chat: 5 fail, all logged) | Client review done; server cases to run | Checklist ready, not run | 2026-11-16 |
| Calling (1:1) | [calling/](calling/README.md) | Done: 69 pass (Phases 1–3), 34 mutation checks | Client review done; server cases not run (no staging) | Checklist ready, not run | 2026-11-18 |
| App cache | [app_cache/](app_cache/README.md) | Done (59 new pass; 0 new failures project-wide) | Code review + automated done; device steps not run | Checklist ready, not run | 2026-11-17 |

## Folder layout per module

```
docs/testing/<module>/
  README.md            status tracker for the module
  bug_tracker.md       every bug, root cause, fix idea, status
  unit_testing/        automated test report + coverage
  pentesting/          security findings + server pentest cases
  manual_testing/      phone checklist with Android / iOS result columns
```
