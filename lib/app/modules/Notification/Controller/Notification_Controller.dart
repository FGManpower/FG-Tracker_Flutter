import 'dart:developer';

import 'package:get/get.dart';

import '../../../Data/Repositories/Notification_Repo.dart';
import '../../../Model/notification_model.dart';

class NotificationController extends GetxController {
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  RxList<NotificationModel> filteredNotifications = <NotificationModel>[].obs;

  RxInt unreadCount = 0.obs;

  RxBool isLoading = false.obs;

  RxString selectedFilter = "all".obs;

  @override
  void onInit() {
    super.onInit();

    getNotifications();
    getUnreadCount();
  }

  Future<void> getNotifications() async {
    try {
      isLoading.value = true;

      final result = await NotificationRepo.getNotifications();

      notifications.value = result;

      applyFilter();
    } catch (e) {
      log("Notification Error: $e");
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

      print("Unread Notifications : ${filteredNotifications.length}");
    } else if (selectedFilter.value == "chat") {
      print("===========FILTER : CHAT============");

      filteredNotifications.value = notifications
          .where(
            (e) => e.type == "chat",
          )
          .toList();

      print("Chat Notifications : ${filteredNotifications.length}");
    } else if (selectedFilter.value == "call") {
      print("===========FILTER : CALL============");

      filteredNotifications.value = notifications
          .where(
            (e) =>
                e.type == "voice_call" ||
                e.type == "video_call" ||
                e.type == "missed_call",
          )
          .toList();

    } else if (selectedFilter.value == "clear_history") {
      clearAllNotifications();

      filteredNotifications.clear();
    }

  }

  Future<void> getUnreadCount() async {
    try {
      unreadCount.value = await NotificationRepo.getUnreadCount();
    } catch (e) {
      log("Unread Count Error: $e");
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      bool success = await NotificationRepo.markAsRead(id);

      if (success) {
        int index = notifications.indexWhere(
          (e) => e.id == id,
        );

        if (index != -1) {
          notifications[index].isRead = true;

          notifications.refresh();

          applyFilter();
        }

        getUnreadCount();
      }
    } catch (e) {
      log("Mark Read Error: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      bool success = await NotificationRepo.markAllAsRead();

      if (success) {
        for (var item in notifications) {
          item.isRead = true;
        }

        notifications.refresh();

        applyFilter();

        unreadCount.value = 0;
      }
    } catch (e) {
      log("Mark All Error: $e");
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final response = await NotificationRepo.clearAllNotifications();

      if (response) {
        notifications.clear();

        unreadCount.value = 0;

        Get.snackbar(
          "Success",
          "All notifications cleared successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      log(e.toString());
    }
  }

  String formatTime(String? date) {
    if (date == null || date.isEmpty) {
      return "";
    }

    try {
      final notificationTime = DateTime.parse(date).toLocal();

      final now = DateTime.now();

      final difference = now.difference(notificationTime);

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

      return "${notificationTime.day}/${notificationTime.month}/${notificationTime.year}";
    } catch (e) {
      return "";
    }
  }
}
