# Project Guidelines & Critical Frozen Modules

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
