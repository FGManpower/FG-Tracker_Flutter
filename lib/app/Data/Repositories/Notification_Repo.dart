

import '../../Core/util/http/http_util.dart';
import '../../Model/NotificationData.dart';

class Notification_Repo {
  static Future<NotificationRes> getNotificationData() async {
    var response = await HttpUtil().get(
        "/seller/get-notifications?notify_id=${1}&role=seller");
    return NotificationRes.fromJson(response);
  }
}
