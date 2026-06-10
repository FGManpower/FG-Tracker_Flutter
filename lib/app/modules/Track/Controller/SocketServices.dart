import 'dart:developer';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

class SocketService extends GetxService {
  static SocketService get instance => Get.put(SocketService());

  IO.Socket? _socket;
  bool get isSocketConnected => _socket?.connected == true;

  final Set<String> connectedGroupIds = {};

  IO.Socket get socket {
    if (_socket == null) {
      log("⚠️ Socket accessed before initialization");
      throw Exception("Socket not initialized");
    }
    return _socket!;
  }

  Future<void> init(String socketUrl) async {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io("$socketUrl/location", {
      "transports": ["websocket"],
      "autoConnect": true,
    });

    _socket?.onConnect((_) {
      log("✅Location Socket connected");
      for (String groupId in connectedGroupIds) {
        _rejoinGroup(groupId);
      }
    });

    _socket?.onDisconnect((_) => log("❌ Socket disconnected"));
    _socket?.onError((err) => log("❌ Socket error: $err"));
  }


  void joinGroup({required String groupId, required String userId}) {
    if (!connectedGroupIds.contains(groupId)) {
      _socket?.emit("join-group", {
        "groupId": groupId,
        "userId": userId,
      });
      connectedGroupIds.add(groupId);
      log("📤 Joined group $groupId");
    }
  }


  void leaveGroup({required String groupId, required String userId}) {
    _socket?.emit("leave-group", {
      "groupId": groupId,
      "userId": userId,
    });
    connectedGroupIds.remove(groupId);
  }

  void emitLocation(String userId, dynamic lat, dynamic lng) {
    if (!isSocketConnected) return;

    if (userId.isEmpty || lat == null || lng == null) {
      log("❌ Invalid data: userId=$userId, lat=$lat, lng=$lng");
      return;
    }

    for (String groupId in connectedGroupIds) {
      // log("📡 Emitting location to group: $groupId");
      _socket?.emit("send-location", {
        "userId": userId,
        "groupId": groupId,
        "lat": lat,
        "lng": lng,
      });
    }
  }

  void onGroupLocationUpdate( Function(dynamic) callback) {
    _socket?.on("group-location-update", (data) {
      if (data is List) {
        for (var item in data) {
          if (item["userId"].toString() != Global.storageServices.get(PrefConst.userId)
            ) {
            callback(item);
          }
        }
      } else if (data is Map) {
        if (data["userId"].toString() != Global.storageServices.get(PrefConst.userId)) {
          callback(data);
        }
      }
    });
  }

  void onGroupLocationUpdateOff() {
    _socket?.off("group-location-update");
  }



  void onUserLeft(Function(String userId) callback) {
    _socket?.on("user-left", (data) {
      callback(data["userId"]);
    });
  }

  void onUserOffline(Function(String userId) callback) {
    _socket?.on("user-offline", (data) {
      callback(data["userId"]);
    });
  }

  void onGroupDeleted(Function(String groupId) callback) {
    _socket?.on("group-deleted", (data) {
      final groupId = data["groupId"];
      if (groupId != null) {
        connectedGroupIds.remove(groupId);
        callback(groupId);
      }
    });
  }

  void allSocketEventLogger() {
    _socket?.onAny((event, data) {
      log("📦 Received event: $event => $data");
    });
  }

  void _rejoinGroup(String groupId) {
    final userId = Global.storageServices.get(PrefConst.userId).toString();
    _socket?.emit("join-group", {
      "groupId": groupId,
      "userId": userId,
    });
    log("🔁 Rejoined group after reconnect: $groupId");
  }

  void deleteGroup({required String groupId}) {
    if (isSocketConnected) {
      _socket?.emit("delete-group", {
        "groupId": groupId,
      });
      connectedGroupIds.remove(groupId);
      log("🗑️ Deleted group: $groupId");
    } else {
      log("⚠️ Cannot delete group. Socket not connected.");
    }
  }



  @override
  void onClose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.onClose();
  }
}
