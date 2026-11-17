import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/notification_model.dart';

class NotificationRepo {
  static Future<List<NotificationModel>> getNotifications() async {
    var response = await HttpUtil().get("/getNotifications");

    if (response["status"] == true) {
      return (response["notifications"] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    }

    return [];
  }

  /// Same request as [getNotifications], but a failed answer
  /// (`status` not true) is `null` instead of `[]`, so a failure never
  /// looks like "no notifications" and never wipes the cached list (doc 07).
  static Future<List<NotificationModel>?> getNotificationsOrNull() async {
    var response = await HttpUtil().get("/getNotifications");

    if (response is Map && response["status"] == true) {
      return (response["notifications"] as List? ?? const [])
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    }

    return null;
  }

  static Future<int> getUnreadCount() async {
    var response = await HttpUtil().get("/getUnreadCount");

    if (response["status"] == true) {
      return response["count"] ?? 0;
    }

    return 0;
  }

  static Future<bool> markAsRead(int id) async {
    var response = await HttpUtil().Authput("/markAsRead/$id",);

    return response["status"] == true;
  }

  static Future<bool> markAllAsRead() async {
    var response = await HttpUtil().Authput("/markAllAsRead");

    return response["status"] == true;
  }

  static Future<bool> clearAllNotifications() async {


    var response = await HttpUtil().Authdelete(
      "/clear-all-notifications",
    );

    return response["status"] == true;
  }
}
