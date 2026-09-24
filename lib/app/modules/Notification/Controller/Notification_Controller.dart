import 'dart:developer';

import 'package:get/get.dart';

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

  @override
  void onInit() {
    super.onInit();
    refreshNotifications();
  }

  Future<void> refreshNotifications() async {
    responseError.value = "";

    notifications.clear();
    filteredNotifications.clear();

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

      final result = await NotificationRepo.getNotifications();

      notifications.value = result;

      applyFilter();
    } catch (e, stackTrace) {
      log(
        "Notification Error: $e",
        stackTrace: stackTrace,
      );

      notifications.clear();
      filteredNotifications.clear();

      responseError.value = _getErrorMessage(e);
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
          "Success",
          "All notifications cleared successfully",
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
        return "Just now";
      }

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} min ago";
      }

      if (difference.inHours < 24) {
        return "${difference.inHours} hr ago";
      }

      if (difference.inDays == 1) {
        return "Yesterday";
      }

      if (difference.inDays < 7) {
        return "${difference.inDays} days ago";
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
      return "Something went wrong. Please try again.";
    }

    return message;
  }
}