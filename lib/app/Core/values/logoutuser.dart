import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Data/Services/GroupCountService.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/Data/Services/Socket/status_socket_service.dart';
import 'package:fgtracker/app/Data/Services/notification_marker_service.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:fgtracker/app/modules/Track/Controller/SocketServices.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global.dart';

class LogoutUser {
  static bool _isLoggingOut = false;
  static DateTime? _lastLoginTime;

  /// Call this immediately after a successful login/OTP verification
  static void recordLoginSuccess() {
    _lastLoginTime = DateTime.now();
    log('[LogoutUser] Login recorded at: $_lastLoginTime');
  }

  Future<void> logout() async {
    await clearSessionAndSockets();
    Get.offAllNamed(Routes.Login);
  }

  Future<void> handleForceLogout({String? message}) async {
    if (_isLoggingOut) return;

    // 1. Guard: Check if the user is currently logged in
    final token = Global.storageServices.getaccesstoken();
    if (token == null || token.trim().isEmpty) {
      log('[LogoutUser] Ignored handleForceLogout: No active session/token.');
      return;
    }

    // 2. Guard: Never force logout if the app is currently in the auth/login flow
    final currentRoute = Get.currentRoute;
    final authRoutes = [
      Routes.Login,
      Routes.OTPScreen,
      Routes.Register,
      Routes.Splash,
      Routes.Intro,
    ];
    if (authRoutes.contains(currentRoute)) {
      log('[LogoutUser] Ignored handleForceLogout: User is in auth flow ($currentRoute).');
      return;
    }

    // 3. Guard: Grace period for a newly logged-in device (15 seconds)
    if (_lastLoginTime != null) {
      final elapsed = DateTime.now().difference(_lastLoginTime!);
      if (elapsed < const Duration(seconds: 15)) {
        log('[LogoutUser] Ignored handleForceLogout: New device login grace period active (${elapsed.inSeconds}s ago).');
        return;
      }
    }

    _isLoggingOut = true;

    try {
      log('[LogoutUser] Performing force logout...');
      await clearSessionAndSockets();

      final routeAfter = Get.currentRoute;
      if (!authRoutes.contains(routeAfter)) {
        Get.offAllNamed(Routes.Login);
      }

      final alertText = (message != null && message.trim().isNotEmpty)
          ? message.trim()
          : "Session expired. You logged in on another device.";

      Future.delayed(const Duration(milliseconds: 350), () {
        CommonDialog.sessionExpiredDialog(alertText);
      });
    } catch (e) {
      log('[LogoutUser] Error during force logout: $e');
    } finally {
      _isLoggingOut = false;
    }
  }

  Future<void> clearSessionAndSockets() async {
    // 1. Destroy all SharedPreferences & local storage data
    try {
      log('[LogoutUser] Destroying all stored user preferences and local data...');
      await Global.storageServices.clearAllUserData();
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final introDone = prefs.getBool(PrefConst.introStatus) ?? true;
      final isDark = prefs.getBool(PrefConst.isDarkMode);
      await prefs.clear();
      await prefs.setBool(PrefConst.introStatus, introDone);
      if (isDark != null) {
        await prefs.setBool(PrefConst.isDarkMode, isDark);
      }
      await prefs.reload();
      await Global.storageServices.reload();
    } catch (e) {
      log('[LogoutUser] Error clearing storage: $e');
    }

    // 2. Reset Http authorization headers
    try {
      HttpUtil().api.sendRequest.options.headers.remove("authorization");
    } catch (_) {}

    // 3. Stop running foreground services
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (_) {}

    // 4. Disconnect and dispose all sockets
    try {
      await GroupWalkieService.instance.dispose();
    } catch (_) {}

    try {
      SignallingService.instance.disconnect();
    } catch (_) {}

    try {
      if (Get.isRegistered<SocketDashboardService>()) {
        SocketDashboardService.instance.disconnect();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<SocketService>()) {
        SocketService.instance.disconnect();
      }
    } catch (_) {}

    try {
      await Socket_GroupCallService.instance.dispose();
    } catch (_) {}

    try {
      if (Get.isRegistered<SocketMessageService>()) {
        SocketMessageService.instance.disconnectAll();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<StatusSocketService>()) {
        Get.find<StatusSocketService>().disconnect();
      }
    } catch (_) {}

    // 5. Dismiss all calls & reset call session
    try {
      await CallKitService.dismissAll();
      CallSessionState.reset();
    } catch (_) {}

    // 6. Cancel all notifications (local & awesome)
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.cancelAll();
    } catch (_) {}

    try {
      await AwesomeNotifications().cancelAll();
    } catch (_) {}

    // 7. Reset in-memory services to clean slate
    try {
      if (Get.isRegistered<GroupCountService>()) {
        GroupCountService.instance.groupCount.value = const GroupCountDetail();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<NotificationMarkerService>()) {
        NotificationMarkerService.instance.clearAll();
      }
    } catch (_) {}

    // 8. Delete user-specific GetX controllers to prevent stale data leaking
    try {
      Get.deleteAll(force: false);
    } catch (e) {
      log('[LogoutUser] Error in Get.deleteAll: $e');
    }
  }
}
