import 'dart:convert';

class NotificationModel {

  int? id;
  int? senderId;
  int? receiverId;

  String? title;
  String? body;
  String? type;
  String? createdAt;

  int? groupId;

  bool? isRead;

  Map<String, dynamic>? data;

  NotificationModel({
    this.id,
    this.senderId,
    this.receiverId,
    this.title,
    this.body,
    this.type,
    this.groupId,
    this.isRead,
    this.createdAt,
    this.data,
  });

  NotificationModel.fromJson(
      Map<String, dynamic> json,
      ) {

    try {

      id = json['id'];

      senderId = json['senderId'];

      receiverId = json['receiverId'];

      title =
          json['title']?.toString() ?? "";

      body =
          json['body']?.toString() ?? "";

      type =
          json['type']?.toString() ?? "";

      groupId = json['groupId'];

      isRead =
          json['isRead'] ?? false;

      createdAt =
          json['createdAt']?.toString() ?? "";

      if (json['data'] != null) {

        // STRING JSON
        if (json['data'] is String) {

          final decoded =
          jsonDecode(json['data']);

          if (decoded is Map) {

            data =
            Map<String, dynamic>.from(
              decoded,
            );
          }
        }

        // DIRECT MAP
        else if (
        json['data'] is Map
        ) {

          data =
          Map<String, dynamic>.from(
            json['data'],
          );
        }
      }

    } catch (e) {

      print(
        "NotificationModel Parse Error => $e",
      );

      data = null;
    }
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'title': title,
      'body': body,
      'type': type,
      'groupId': groupId,
      'isRead': isRead,
      'createdAt': createdAt,
      'data': data,
    };
  }
}