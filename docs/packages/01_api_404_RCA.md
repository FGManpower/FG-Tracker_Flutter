# Packages API 404 — Root Cause Analysis

**Reported:** opening Packages returns `Can't find /api/package on this server`
**Checked on:** 3 Nov 2026, 11:08 UTC · branch `46Solution` · server `http://fgtracker.in:3000`
**Verdict:** **Backend — the Packages API was never built or never deployed.** No package route exists on the production server under any name or method. The Flutter side calls the documented path correctly. No Flutter path change can fix this; the backend needs to build the routes in [02_backend_requirements.md](02_backend_requirements.md).

---

## 1. What the app calls

The package URL lives in one place, [`lib/app/Core/constant/urls.dart:58`](../../lib/app/Core/constant/urls.dart#L58), built from `ConstRes.aBaseUrl` ([`const_res.dart:8-9`](../../lib/app/Core/constant/const_res.dart#L8-L9)).

| # | Purpose | Method | Final URL | Auth | Body / query |
|---|---|---|---|---|---|
| 1 | Package list | GET | `http://fgtracker.in:3000/api/packages` | `Authorization: Bearer <token>` | none |

Headers on every call: `accept: application/json`, `content-type: application/json`, `authorization: Bearer …` (only when logged in). Debug builds now log `📦 [PackageAPI] <METHOD> <URL> body=…` — never the token.

**The app never calls `/api/package` (singular).** A search of `lib/` for `aBaseUrl}package`, `api/package` (singular), `'package'` and `"package"` as a path finds no match. The singular path in the report must come from a manual test (Postman / browser), or be a paraphrase of the plural error. Both answer the same 404 (see §3).

**Until this fix, debug builds made no request at all.** `PackagePricingRepo.useMock` (`kDebugMode && true`) served hard-coded sample data, so the 404 could only appear in a release build or in a manual test. Release builds then showed the raw server text to the user; that's fixed now (see §6).

## 2. Environment / base URL

| Item | Value | Evidence |
|---|---|---|
| Base URL | `http://fgtracker.in:3000/api/` (production) | `const_res.dart:8-9` |
| Dev URL | `http://10.57.204.163:4000/` — **commented out** | `const_res.dart:7`; that host is not reachable from outside the office LAN (curl: no response) |
| Flavors / `.env` / `--dart-define` | None. One hard-coded environment. | no `.env*` files, no flavor code in `main.dart` |
| Last change to base URL | `64b9098` · 2025-11-08 · fgmanpower · "New Ui changes" | `git log -S"fgtracker.in:3000" -- const_res.dart` |
| Last commit to `const_res.dart` | `14e2336` · 2026-11-01 · saritadalai (unrelated to base URL) | `git log -1` |

The base URL is the same one every working API uses (`/api/initialize`, `/api/walkie/*`), so a **wrong environment is ruled out**.

## 3. Reproduced outside the app (curl, no token)

How to read the results: on this server, a **registered route answers 401 `Please provide a token`** when called without a token, because auth middleware sits on each route. A path + method with **no route falls through to the Express catch-all 404** (`Can't find <path> on the server!`). So a no-token request is enough to tell "route exists" apart from "route missing".

Control group: routes that exist.

```
GET  /api/initialize                  -> 401 {"status":false,"message":"Please provide a token"}
GET  /api/walkie/plans                -> 401 {"status":false,"message":"Please provide a token"}
POST /api/walkie/payment/create-order -> 401 {"status":false,"message":"Please provide a token"}
POST /api/walkie/payment/verify       -> 401 {"status":false,"message":"Please provide a token"}
POST /api/walkie/plans                -> 404 {"status":false,"message":"Can't find /api/walkie/plans on the server!"}   <- right path, wrong method = 404
```

Package paths: every variant tried.

```
GET  /api/package                      -> 404 {"status":false,"message":"Can't find /api/package on the server!"}
POST /api/package                      -> 404 {"status":false,"message":"Can't find /api/package on the server!"}
GET  /api/package/                     -> 404 {"status":false,"message":"Can't find /api/package/ on the server!"}
POST /api/package/                     -> 404
GET  /api/packages                     -> 404 {"status":false,"message":"Can't find /api/packages on the server!"}
POST /api/packages                     -> 404
GET  /api/packages/                    -> 404
POST /api/packages/                    -> 404
GET  /api/v1/package                   -> 404
POST /api/v1/package                   -> 404
GET  /api/v1/packages                  -> 404
POST /api/v1/packages                  -> 404
GET  /api/packages/walkie_talkie/plans -> 404
POST /api/packages/walkie_talkie/plans -> 404
GET  /api/plans                        -> 404
POST /api/plans                        -> 404
GET  /api/subscription                 -> 404
POST /api/subscription                 -> 404
GET  /api/subscriptions                -> 404
GET  /api/my-subscriptions             -> 404
GET  /api/payment/history              -> 404
GET  /api/payments                     -> 404
POST /api/walkie/payment/failed        -> 404   <- the Walkie flow has no "failed" endpoint either
```

Response headers for `GET /api/packages`: `HTTP/1.1 404 Not Found`, `X-Powered-By: Express`, `Content-Type: application/json`. The request reached the Node/Express app; there's no proxy or CDN error.

*Not done:* a run with a real user token. No test credentials were available in this session. Because auth runs per route, a token can't turn a missing route into a found one. Backend question Q1 asks for this to be confirmed anyway.

## 4. Backend side

There is no backend repo on this machine (only Flutter projects are under `C:\`), and no Postman collection or API docs in the Flutter repo. Questions for the backend developer:

| # | Question | Why |
|---|---|---|
| Q1 | With a valid token, what does `GET /api/packages` return? (Expected: still 404.) | Confirms §3 with auth. |
| Q2 | Does any route file contain `package` / `packages` / `plans` outside `walkie`? | "Never built" vs "built under another name". |
| Q3 | If it exists in the repo: is its router registered in `app.js` / `server.js` **before** the catch-all 404 handler? | "Router not registered". |
| Q4 | Is the deployed commit the same as `main` / the release branch? When was the server last restarted (pm2 / systemd)? | "Built but not deployed". |
| Q5 | Has any route under `/api/package*` been renamed or deleted (git log on routes)? | "Renamed / moved". |
| Q6 | Please include the HTTP method in the 404 handler message (`Can't find GET /api/packages`). | §3 shows the same path answering 401 on GET and 404 on POST; the method in the message speeds up debugging. |

## 5. Conclusion

| Possible cause | Result | Evidence |
|---|---|---|
| Renamed / moved | **No** | No variant (`package`, `packages`, `v1`, `plans`, `subscription(s)`) exists — §3. |
| Wrong HTTP method | **No** | Both GET and POST return 404 for every package path — §3. |
| Wrong base URL / environment | **No** | Same host/port/prefix as working `/api/initialize` and `/api/walkie/*` — §2. |
| Router not registered | Possible, can't be told apart from outside | Q3. |
| Built but not deployed | Possible, can't be told apart from outside | Q4. |
| **Never built** | **Most likely** | The Packages contract was written by the Flutter side on 2026-11-02 (commit `6f2d1df`, saritadalai, together with the screens and URLs). No package route exists on the server in any form. |

**Root cause:** the server has no Packages routes. The Flutter app calls the documented paths with the correct method, base URL and auth.
**Action:** backend builds and deploys `GET /api/packages` as described in [02_backend_requirements.md](02_backend_requirements.md). That single API unblocks the screen.

## 6. What was fixed on the Flutter side

These don't fix the 404 (that's the backend's job); they bring the app in line with the golden rules.

| Problem found | Fix |
|---|---|
| Debug builds showed **hard-coded sample packages and prices** (`package_pricing_mock.dart`, `useMock`) | Sample data deleted. All package data comes from the API; debug builds now call the real API. |
| On error the screen showed the **raw server text** (`Can't find /api/packages on the server!`). `ApiErrorHandler` passes `data['message']` through. | New `PackageApiException` with a friendly message per kind (offline, timeout, 401, 404, 409, 5xx, bad data). The raw text goes to the debug log only. |
| Shared `HttpUtil` debug logger prints **request headers, including the Bearer token** | The package API uses its own Dio, with no header logging. The shared logger now has `requestHeader: false` too, so no module logs the token (`http_util.dart`). |
| `dio` was used by 18 files but not declared (it only came in via `pretty_dio_logger`) | Declared in `pubspec.yaml`, pinned to the installed `5.11.1`; `pubspec.lock` version unchanged. |
| No request timeout on package calls | 15 s connect, 20 s send/receive → "taking too long" state with Retry. |
| A 200 response with `status:false`, or a body that isn't a JSON object, was treated as data | Both now raise an error state with Retry. |
| Long badge / highlight text **overflowed** the card (found by the new widget test) | Pill text truncates with "…"; the badge is flexible next to the title. |

No card layout or design was changed.

**Scope update (3 Nov 2026):** the per-module plan-details screen and its plan / order / payment API calls were removed from the app. Packages & Pricing is now a single dynamic list of 4 modules: Walkie-Talkie opens its existing plan flow, and the other three show "Coming soon". Only `GET /api/packages` is needed from the backend.
