import 'dart:developer';

import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';

import '../../../Core/values/global.dart';
import '../../../Data/Services/app_cache.dart';
import '../../../Data/Repositories/Notification_Repo.dart';
import '../../../Model/notification_model.dart';

class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications =
      <NotificationModel>[].obs;

  final RxList<NotificationModel> filteredNotifications =
      <NotificationModel>[].obs;

  final RxInt unreadCount = 0.obs;

  final RxBool isLoading = false.obs;

  final RxString responseError = "".obs;

  final RxString selectedFilter = "all".obs;

  // ---- App cache (doc 07): the list shown at once ----

  /// "Couldn't refresh · Retry" over the notifications already shown.
  final RxBool refreshFailed = false.obs;
  bool _cacheReadDone = false;
  AppCachePerf? _perf;
  AppLifecycleListener? _lifecycle;

  @override
  void onInit() {
    super.onInit();
    _perf = AppCachePerf('notifications')..mark('open');
    ever<List<NotificationModel>>(
        notifications, (_) => _scheduleNotificationsSave());
    // Gap fill (R4): there is no notification socket; refresh on resume.
    _lifecycle = AppLifecycleListener(onResume: refreshNotifications);
    _showCachedNotifications().then((_) => refreshNotifications());
  }

  @override
  void onClose() {
    _lifecycle?.dispose();
    super.onClose();
  }

  Future<void> _showCachedNotifications() async {
    try {
      final cached = await AppCache.readAs(
          AppCache.notifications, (m) => NotificationModel.fromJson(m));
      // An API answer that is already here wins (R3).
      if (!isClosed && cached.isNotEmpty && notifications.isEmpty) {
        notifications.assignAll(cached);
        applyFilter();
        _perf?.mark('cache shown', extra: '${cached.length} items');
      }
    } catch (_) {
    } finally {
      _cacheReadDone = true;
    }
  }

  /// Write-through: new list, read flags, "clear all" (saved empty).
  void _scheduleNotificationsSave() {
    if (!_cacheReadDone || isClosed) return;
    AppCache.scheduleWrite(
      AppCache.notifications,
      () => [
        for (final n in notifications.take(AppCache.notifications.maxItems))
          n.toJson()
      ],
      allowEmpty: true,
    );
  }

  Future<void> refreshNotifications() async {
    final token = Global.storageServices.getaccesstoken();
    if (token == null || token.isEmpty) return;

    responseError.value = "";

    // The list is no longer cleared first: what is shown (cached or
    // earlier) stays until the server answers (doc 07).

    selectedFilter.value = "all";

    await Future.wait([
      getNotifications(),
      getUnreadCount(),
    ]);
  }

  Future<void> getNotifications() async {
    try {
      isLoading.value = true;
      responseError.value = "";

      final result = await NotificationRepo.getNotificationsOrNull()
          .timeout(const Duration(seconds: 10)); // never an endless loader

      if (result == null) {
        // Failed answer: keep what is shown; never "no notifications".
        if (notifications.isNotEmpty) refreshFailed.value = true;
        return;
      }

      notifications.value = result;
      refreshFailed.value = false;
      _perf?.mark('API done', extra: '${result.length} items');
      _perf?.markAfterFrame('rendered');

      applyFilter();
    } catch (e, stackTrace) {
      log(
        "Notification Error: $e",
        stackTrace: stackTrace,
      );

      if (notifications.isNotEmpty) {
        refreshFailed.value = true; // cached list stays (offline / timeout)
      } else {
        filteredNotifications.clear();
        responseError.value = _getErrorMessage(e);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter() {
    if (selectedFilter.value == "all") {
      filteredNotifications.value = notifications;
    } else if (selectedFilter.value == "unread") {
      filteredNotifications.value = notifications
          .where(
            (e) => e.isRead == false,
      )
          .toList();

      log(
        "Unread Notifications : ${filteredNotifications.length}",
      );
    } else if (selectedFilter.value == "chat") {
      log("=========== FILTER : CHAT ============");

      filteredNotifications.value = notifications
          .where(
            (e) => e.type == "chat",
      )
          .toList();

      log(
        "Chat Notifications : ${filteredNotifications.length}",
      );
    } else if (selectedFilter.value == "call") {
      log("=========== FILTER : CALL ============");

      filteredNotifications.value = notifications
          .where(
            (e) =>
        e.type == "voice_call" ||
            e.type == "video_call" ||
            e.type == "missed_call",
      )
          .toList();
    }
  }

  Future<void> getUnreadCount() async {
    try {
      unreadCount.value =
      await NotificationRepo.getUnreadCount();
    } catch (e, stackTrace) {
      log(
        "Unread Count Error: $e",
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final bool success =
      await NotificationRepo.markAsRead(id);

      if (success) {
        final int index = notifications.indexWhere(
              (e) => e.id == id,
        );

        if (index != -1) {
          notifications[index].isRead = true;

          notifications.refresh();

          applyFilter();
        }

        await getUnreadCount();
      }
    } catch (e, stackTrace) {
      log(
        "Mark Read Error: $e",
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final bool success =
      await NotificationRepo.markAllAsRead();

      if (success) {
        for (final item in notifications) {
          item.isRead = true;
        }

        notifications.refresh();

        applyFilter();

        unreadCount.value = 0;
      }
    } catch (e, stackTrace) {
      log(
        "Mark All Error: $e",
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final response =
      await NotificationRepo.clearAllNotifications();

      if (response) {
        notifications.clear();
        filteredNotifications.clear();

        unreadCount.value = 0;

        Get.snackbar(
          appL10n.common_success,
          appL10n.notifications_clearedSuccess,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      log(
        "Clear Notification Error: $e",
        stackTrace: stackTrace,
      );
    }
  }

  String formatTime(String? date) {
    if (date == null || date.isEmpty) {
      return "";
    }

    try {
      final notificationTime =
      DateTime.parse(date).toLocal();

      final now = DateTime.now();

      final difference =
      now.difference(notificationTime);

      if (difference.inSeconds < 60) {
        return appL10n.common_justNow;
      }

      if (difference.inMinutes < 60) {
        return appL10n.common_minutesAgo(difference.inMinutes);
      }

      if (difference.inHours < 24) {
        return appL10n.common_hoursAgo(difference.inHours);
      }

      if (difference.inDays == 1) {
        return appL10n.common_yesterday;
      }

      if (difference.inDays < 7) {
        return appL10n.common_daysAgo(difference.inDays);
      }

      return "${notificationTime.day}/"
          "${notificationTime.month}/"
          "${notificationTime.year}";
    } catch (e) {
      return "";
    }
  }

  String _getErrorMessage(dynamic error) {
    final String message = error.toString().trim();

    if (message.isEmpty) {
      return appL10n.common_somethingWentWrong;
    }

    return message;
  }
}