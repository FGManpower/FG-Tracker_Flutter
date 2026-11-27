# Project Guidelines & Critical Frozen Modules

## 🔒 STRICT MODULE LOCK POLICY (ALL IMPLEMENTED MODULES)

> **MANDATORY RULE FOR ALL DEVELOPERS & AI AGENTS:**  
> Every module currently implemented and documented in `docs/` (up to `2026-11-27`) is **LOCKED / FROZEN** in production:
> - **01. Chatting** (`docs/01_CHATTING_MODULE_FRONTEND.md`)
> - **02. Calling** (`docs/02_CALLING_MODULE_FRONTEND.md`)
> - **03. Walkie-Talkie** (`docs/03_WALKIE_TALKIE_MODULE_FRONTEND.md`)
> - **04. Live Tracking** (`docs/04_TRACKING_MODULE_FRONTEND.md`)
> - **05. Common Module** (Bootstrap, Home Sockets, Auth, OTP Charges, Banners, Force Update, Side Menu, Scan Text — `docs/05_COMMON_MODULE_FRONTEND.md`)
> - **06. Language / Localization** (`docs/06_LANGUAGE_MODULE_FRONTEND.md`)
> - **07. App Cache** (`docs/07_APP_CACHE_FRONTEND.md`)
> - **International Multi-Currency Payments** (`docs/INTERNATIONAL_PAYMENT_SETUP_GUIDE.md`)
>
> **NO FURTHER CHANGES WITHOUT EXPLICIT PERMISSION:**  
> - **DO NOT** modify, refactor, or alter any existing locked module or its behavior without **explicit prior permission** from the project owner / lead.
> - Before making any change that touches an existing module, **STOP and ask for permission first**. Only proceed after explicit approval is granted, and update the corresponding document in `docs/` once approved changes are made.

---

## ⚠️ STRICT RULE: Protected / Completed Modules

The following flow has been completely tested, stabilized, and verified to be working perfectly across devices:
- **Authentication & Login / Re-login Flow**:
  - `lib/app/modules/auth/Controller/OtpController.dart`
  - `lib/app/Core/values/logoutuser.dart`
- **Location Sharing & Private / Ghost Mode Sync**:
  - `lib/app/modules/Track/Controller/GroupTrackController.dart` (specifically `loadLocationSharing`, `syncLocationSharingFromBackend`, `onInit`)
  - `lib/app/modules/home/Controller/LiveStatus_controller.dart` (specifically `_loadMyPrivateStatus`, `getAllMembers`, `getPrivateMembers`, `togglePrivateMode`)
  - `lib/app/Data/Repositories/Profile_Repo.dart` (`getProfileData`)
  - `lib/app/Model/ProfileRes.dart` & `lib/app/Model/OtpVeriefy.dart` (`locationSharing` parsing)

### 🚨 Mandatory Requirement Before Touching These Modules:
- **DO NOT** make any modifications, refactoring, or additions to any of the files or logic in these completed modules without **explicit confirmation from the user**.
- If any future task, feature, or bug fix appears to touch or impact these modules, **YOU MUST ASK THE USER FIRST**:
  > *"This change affects the completed and verified Login / Location Sharing & Private Mode synchronization module. Do you want to make changes to this completed module?"*
- Only proceed if the user explicitly confirms.

---

## 🛡️ Permission Setup & Gate Architecture (`Routes.permissionSetup`)

### Background & Issue Resolved:
After OTP verification, the app navigates to `Routes.permissionSetup` (`PermissionSetupScreen`). Previously, if hardware/system permissions or Remote Config flags took longer to evaluate, the screen rendered a blank screen with a raw `CircularProgressIndicator` and had no timeouts, leaving users stuck until they killed and restarted the app (which routed through splash directly to Home).

### Verified Architectural Implementation:
1. **Never Block indefinitely (Safety Watchdog & Timeouts)**:
   - `PermissionSetupController.onReady()` runs a 3-second hard safety watchdog (`_safetyTimer`). If any platform channel check hangs or takes longer than 3 seconds, `checking.value` is immediately set to `false`, restoring full UI control to the user.
   - Initial check `checkAllPermissionStatus()` has a strict 2.5-second timeout.
   - `PermissionGateService._doCheck()` has a 3-second timeout on `backend.snapshot()`.
   - Optional permissions (Camera, Microphone, Contacts) are queried concurrently via `Future.wait` with 800ms timeouts and never block navigation to Home if compulsory permissions (Location & Notifications) are already granted.
2. **Polished Shimmer Skeleton Loading Effect**:
   - Instead of a raw blank white screen or center spinner, `PermissionSetupScreen` renders the permanent app bar and a smooth shimmer skeleton list (`Skeletonizer`) matching the cards and action buttons.
3. **Instant Pass-Through**:
   - If compulsory permissions (`locationOk` and `notificationOk`) are already satisfied, `_goHome()` is called immediately to transition to `Routes.Home_Screen` without lingering.

