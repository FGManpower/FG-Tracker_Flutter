# Calling (1:1) — Testing Tracker

Testing-only folder. The feature guide is [`docs/02_CALLING_MODULE_FRONTEND.md`](../../02_CALLING_MODULE_FRONTEND.md) (reference only; the Part 0 flows, gap table and plan are in its §5).

| | |
|---|---|
| Last updated | 2026-11-18 — Phase 3 (parity) + E2E tooling + manual + pentest docs |
| Branch | `46Solution` @ `3e16f524` |
| App code changed | Phases 1–3 (approved), uncommitted. Tests: `test/call_qa/`, `integration_test/call_signaling_e2e_test.dart`, `scripts/call_qa/` |

## Documents

| File | What it holds | Status |
|---|---|---|
| [bug_tracker.md](bug_tracker.md) | BUG-CALL-01 … 38: root cause, file:line, status, proof | Phases 1–3: 32 fixed or fixed client-side (phone check pending); open items need the backend (guide §8) or a decision |
| [unit_testing/unit_test_report.md](unit_testing/unit_test_report.md) | CT-xx / PM-xx results + mutation proof | 69/69 pass (19 + 23 + 27); 34 mutation checks |
| [manual_testing/manual_checklist.md](manual_testing/manual_checklist.md) | M-01 … M-14, P-01 … P-12, Phase 1 checks, per device pair | Ready · **not run** (no phones in this session) |
| [pentesting/pentest_report.md](pentesting/pentest_report.md) | SEC-CALL-01 … 13, server cases S-CALL-01 … 16 | Client review done · server cases **not run** (no staging) |
