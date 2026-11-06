# Packages & Pricing — Manual Test Cases (Android + iOS)

**For:** QA · **Build:** branch `46Solution` · **Devices:** one Android emulator (API 34) **and** one iOS Simulator (iOS 17+), plus one small screen (e.g. iPhone SE / 360 px Android)
**Scope:** one dynamic screen with 4 module cards. Walkie-Talkie opens its existing plan flow; Attendance, Safe Zone + Safe Route and Live Tracking show "Coming soon". The per-module pricing screen has been removed.
**Backend item #1** = `GET /api/packages` in [02_backend_requirements.md](02_backend_requirements.md). Cases that need it are **"Blocked until backend item #1"**.
**Automated coverage:** `flutter test test/package_pricing_model_test.dart test/package_api_error_test.dart test/package_pricing_widgets_test.dart` (37 tests) covers parsing, error mapping, every screen state, the 4-module rule and overflow.

How to simulate network errors: use a proxy (Charles / Proxyman / mitmproxy) to return 401 / 404 / 500 or delay the response 25 s; airplane mode for offline. Watch the debug console for `📦 [PackageAPI]` lines.

| TC ID | Screen | Precondition | Steps | Expected result | Android Pass/Fail | iOS Pass/Fail | Notes |
|---|---|---|---|---|---|---|---|
| PK-01 | Home | Logged in | Tap **View Plans** on "Upgrade to Premium" | Packages & Pricing opens | | | Works today |
| PK-02 | Packages | **Current server (no API)** | Open Packages | Loader, then "Plans are not available right now. Please try again later." + **Try again**. No `/api/` or "Can't find" text. | | | Expected today |
| PK-03 | Packages | Current server | Check the debug console | `📦 [PackageAPI] GET http://fgtracker.in:3000/api/packages` then `❌ … HTTP 404`. **No `Bearer` / token anywhere in the log.** | | | |
| PK-04 | Packages | Current server | Tap **Try again** | Loader again, same error state, no crash | | | |
| PK-05 | Packages | API live, 4 modules | Open Packages | 4 cards in `sortOrder`: Attendance, Walkie-Talkie, Safe Zone + Safe Route, Live Tracking. No prices on the cards. | | | Blocked until backend item #1 |
| PK-06 | Packages | As PK-05 | Look at the footers | Walkie-Talkie: "View plans" (normal opacity). The other 3: faded with "Coming soon". | | | Blocked until backend item #1 |
| PK-07 | Packages | As PK-05 | Tap Walkie-Talkie | The existing Walkie-Talkie plan screen opens; Back returns to Packages | | | Blocked until backend item #1 |
| PK-08 | Packages | As PK-05 | Tap Attendance / Safe Zone / Live Tracking | Toast "… plans are coming soon"; no navigation | | | Blocked until backend item #1 |
| PK-09 | Packages | API sends `isAvailable:true` for Attendance | Open Packages | Attendance still shows "Coming soon" (app rule) | | | Blocked until backend item #1 (or proxy) |
| PK-10 | Packages | API sends `isAvailable:false` for Walkie-Talkie | Open Packages | Walkie-Talkie shows "Coming soon" too | | | Blocked until backend item #1 (or proxy) |
| PK-11 | Packages | API returns `"packages": []` | Open Packages | Box icon + "No packages are available right now." + Try again | | | Blocked until backend item #1 (or proxy) |
| PK-12 | Packages | Proxy: 401 | Open Packages | User logged out to Login ("Session expired"), same as other screens | | | Proxy |
| PK-13 | Packages | Proxy: 500 | Open Packages | "Something went wrong. Please try again." + Try again | | | Proxy |
| PK-14 | Packages | Proxy: delay 25 s | Open Packages | After about 20 s: "The server is taking too long to respond…" + Try again | | | Proxy |
| PK-15 | Packages | Airplane mode on | Open Packages | Wi-Fi-off icon + "No internet connection…" | | | |
| PK-16 | Packages | PK-15 state | Airplane mode off → Try again | Loads (or shows the PK-02 state today) | | | |
| PK-17 | Packages | Proxy: 200 with `<html>` or `[1,2]` | Open Packages | "Something went wrong…" + Try again; no crash | | | Proxy |
| PK-18 | Packages | Proxy: values as strings (`"sortOrder":"2"`, `"isAvailable":"true"`) | Open Packages | Same as with real JSON types | | | Proxy |
| PK-19 | Packages | Proxy: a row with `moduleKey: ""`, missing title | Open Packages | Empty-key row hidden; missing title shows "Package" | | | Proxy |
| PK-20 | Packages | List loaded | Pull down to refresh | Spinner; list stays; on failure a toast, list kept | | | Blocked until backend item #1 |
| PK-21 | Packages | Long title / tagline / badge / chips | Open Packages | Title 1 line "…", tagline 2 lines "…", badge and chips truncate; no overflow stripes | | | Blocked until backend item #1 (or proxy) |
| PK-22 | Packages | `iconUrl` set / broken URL | Open Packages | Image shows; broken URL falls back to the built-in icon | | | Blocked until backend item #1 |
| PK-23 | Packages | Small screen (SE / 360 px) | Open Packages | Everything fits; no horizontal scroll | | | |
| PK-24 | Packages | Device font size at maximum | Open Packages | Layout unchanged (the app fixes text scale at 1.0 in `main.dart`); no overflow | | | |
| PK-25 | Packages | Device dark mode | Open Packages | Same light design as the rest of the app; text readable | | | |
| PK-26 | Packages | Walkie plan bought in the Walkie flow | Back to Packages | List refreshes silently (no skeleton) | | | Blocked until backend item #1 |
| R-01 | Regression: Walkie-Talkie | — | Home quick action → trial / channel list; plan → order → Razorpay | Unchanged (uses `/api/walkie/*`) | | | |
| R-02 | Regression: Chat list + chat screen | — | Send/receive, typing, archive, reply, forward | Unchanged | | | |
| R-03 | Regression: Attendance + Poll | — | Create a poll, mark attendance | Unchanged | | | |
| R-04 | Regression: Safe Zone / Route, Live Tracking | — | Open both from Home | Unchanged | | | |
| R-05 | Regression: Permission gate | Fresh install | Location + Notification required | Unchanged | | | |
| R-06 | Regression: Login / re-login | — | Log out, log in with OTP | Unchanged (frozen module not touched) | | | Full `flutter test`: 272 pass |
