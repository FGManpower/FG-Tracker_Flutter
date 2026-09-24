import 'dart:async';
import 'dart:developer';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Model representing location data received via socket event 'send-location'
class LiveLocationSocketModel {
  final dynamic userId;
  final dynamic groupId;
  final double lat;
  final double lng;
  final String area;
  final String city;
  final String address;
  final String? name;
  final String? profileImage;
  final int? battery;
  final DateTime timestamp;

  LiveLocationSocketModel({
    required this.userId,
    this.groupId,
    required this.lat,
    required this.lng,
    this.area = '',
    this.city = '',
    this.address = '',
    this.name,
    this.profileImage,
    this.battery,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory LiveLocationSocketModel.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['userId'] ?? json['id'] ?? json['user_id'];
    final rawGroupId = json['groupId'] ?? json['group_id'];

    final double lat = double.tryParse(
          (json['lat'] ??
                  json['latitude'] ??
                  json['userLat'] ??
                  '')
              .toString(),
        ) ??
        0.0;

    final double lng = double.tryParse(
          (json['lng'] ??
                  json['lon'] ??
                  json['long'] ??
                  json['longitude'] ??
                  json['userLong'] ??
                  '')
              .toString(),
        ) ??
        0.0;

    final String area =
        (json['area'] ?? json['subLocality'] ?? '')?.toString().trim() ?? '';
    final String city =
        (json['city'] ?? json['locality'] ?? '')?.toString().trim() ?? '';

    String addr =
        (json['address'] ?? json['location'] ?? '')?.toString().trim() ?? '';
    if (addr.isEmpty) {
      if (area.isNotEmpty && city.isNotEmpty) {
        addr = area.toLowerCase() == city.toLowerCase()
            ? city
            : '$area, $city';
      } else if (area.isNotEmpty) {
        addr = area;
      } else if (city.isNotEmpty) {
        addr = city;
      }
    }

    final rawBattery = json['battery'] ??
        json['batteryLevel'] ??
        json['battery_level'] ??
        json['batteryPercentage'] ??
        json['percentage'];
    final int? battery = rawBattery != null
        ? int.tryParse(rawBattery.toString().replaceAll(RegExp(r'[^\d]'), ''))
        : null;

    return LiveLocationSocketModel(
      userId: rawUserId,
      groupId: rawGroupId,
      lat: lat,
      lng: lng,
      area: area,
      city: city,
      address: addr,
      name: (json['name'] ?? json['fullName'])?.toString(),
      profileImage:
          (json['profileImage'] ?? json['image'] ?? json['profile_image'])
              ?.toString(),
      battery: battery,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (groupId != null) 'groupId': groupId,
      'lat': lat,
      'lng': lng,
      'latitude': lat,
      'longitude': lng,
      'area': area,
      'city': city,
      'address': address,
      if (name != null) 'name': name,
      if (profileImage != null) 'profileImage': profileImage,
      if (battery != null) 'battery': battery,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'LiveLocationSocketModel(userId: $userId, groupId: $groupId, lat: $lat, lng: $lng, area: $area, city: $city, address: $address, battery: $battery)';
  }
}

class UserStatusSocketModel {
  final String userId;
  final bool isOnline;
  UserStatusSocketModel({required this.userId, required this.isOnline});
}

/// Service dedicated to handling live tracking real-time socket events:
/// socket.on("send-location", async (data) => {
///    const { userId, groupId, lat, lng, area, city } = data;
/// });
class TrackLiveLocationSocketService extends GetxService {
  static TrackLiveLocationSocketService get instance =>
      Get.isRegistered<TrackLiveLocationSocketService>()
          ? Get.find<TrackLiveLocationSocketService>()
          : Get.put(TrackLiveLocationSocketService());

  IO.Socket? _socket;
  bool _isExternalSocket = false;

  final StreamController<LiveLocationSocketModel> _locationStreamController =
      StreamController<LiveLocationSocketModel>.broadcast();

  final StreamController<UserStatusSocketModel> _userStatusStreamController =
      StreamController<UserStatusSocketModel>.broadcast();

  /// Stream of incoming live location updates from socket event 'send-location'
  Stream<LiveLocationSocketModel> get locationStream =>
      _locationStreamController.stream;

  /// Stream of user status updates (online / offline)
  Stream<UserStatusSocketModel> get userStatusStream =>
      _userStatusStreamController.stream;

  final List<void Function(LiveLocationSocketModel)> _listeners = [];

  bool get isConnected => _socket?.connected == true;

  /// Initialize standalone socket or attach to existing socket
  Future<void> init({String? socketUrl, IO.Socket? existingSocket}) async {
    if (existingSocket != null) {
      attachSocket(existingSocket);
      return;
    }

    if (_socket != null && _socket!.connected) return;

    final url = socketUrl ?? ConstRes.socketUrl;
    final locationNamespaceUrl = url.endsWith('/location') ? url : '$url/location';

    log('🔌 [TrackLiveSocket] Initializing socket connection: $locationNamespaceUrl');

    _isExternalSocket = false;
    _socket = IO.io(
      locationNamespaceUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableForceNew()
          .build(),
    );

    _registerSocketEvents();
  }

  /// Attach to an existing socket instance (e.g. from SocketService)
  void attachSocket(IO.Socket socket) {
    _socket = socket;
    _isExternalSocket = true;
    log('🔌 [TrackLiveSocket] Attached to existing socket instance');
    _registerSocketEvents();
  }

  void _registerSocketEvents() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      log('✅ [TrackLiveSocket] Connected to location socket');
    });

    _socket!.onDisconnect((_) {
      log('⚠️ [TrackLiveSocket] Disconnected from location socket');
    });

    _socket!.onError((err) {
      log('❌ [TrackLiveSocket] Socket error: $err');
    });

    // 1. Primary listener: 'send-location'
    // { userId, groupId, lat, lng, area, city }
    _socket!.off('send-location');
    _socket!.on('send-location', (data) async {
      log('📡 [TrackLiveSocket] Received event "send-location": $data');
      _processIncomingLocation(data);
    });

    // 2. Also listen for group-location-update or location-update as complementary events
    _socket!.off('group-location-update');
    _socket!.on('group-location-update', (data) {
      log('📡 [TrackLiveSocket] Received event "group-location-update": $data');
      _processIncomingLocation(data);
    });

    _socket!.off('location-update');
    _socket!.on('location-update', (data) {
      log('📡 [TrackLiveSocket] Received event "location-update": $data');
      _processIncomingLocation(data);
    });

    _socket!.off('user-offline');
    _socket!.on('user-offline', (data) {
      log('📡 [TrackLiveSocket] Received event "user-offline": $data');
      final uId = data is Map ? (data['userId'] ?? data['id']) : data;
      if (uId != null) {
        _userStatusStreamController.add(
          UserStatusSocketModel(userId: uId.toString(), isOnline: false),
        );
      }
    });

    _socket!.off('user-left');
    _socket!.on('user-left', (data) {
      log('📡 [TrackLiveSocket] Received event "user-left": $data');
      final uId = data is Map ? (data['userId'] ?? data['id']) : data;
      if (uId != null) {
        _userStatusStreamController.add(
          UserStatusSocketModel(userId: uId.toString(), isOnline: false),
        );
      }
    });
  }

  void _processIncomingLocation(dynamic data) {
    if (data == null) return;

    try {
      if (data is List) {
        for (var item in data) {
          _processSingleItem(item);
        }
      } else if (data is Map) {
        _processSingleItem(data);
      }
    } catch (e, stack) {
      debugPrint('❌ [TrackLiveSocket] Error processing location data: $e\n$stack');
    }
  }

  void _processSingleItem(dynamic rawItem) {
    if (rawItem is! Map) return;

    final map = Map<String, dynamic>.from(rawItem);
    final model = LiveLocationSocketModel.fromJson(map);

    // Ignore invalid coordinates
    if (model.lat == 0.0 || model.lng == 0.0) return;

    // Filter out self update to prevent jitter on current user's GPS marker
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString();
    if (currentUserId != null &&
        model.userId != null &&
        model.userId.toString() == currentUserId) {
      return;
    }

    log('🎯 [TrackLiveSocket] Parsed live member update: ${model.userId} @ (${model.lat}, ${model.lng}) - ${model.address}');

    // Dispatch to stream
    if (!_locationStreamController.isClosed) {
      _locationStreamController.add(model);
    }

    // Dispatch to registered callbacks
    for (final callback in List.from(_listeners)) {
      try {
        callback(model);
      } catch (e) {
        debugPrint('❌ [TrackLiveSocket] Listener callback error: $e');
      }
    }
  }

  /// Register a callback to be called whenever a 'send-location' event is received
  void onLocationReceived(void Function(LiveLocationSocketModel) callback) {
    if (!_listeners.contains(callback)) {
      _listeners.add(callback);
    }
  }

  /// Unregister callback
  void removeLocationListener(void Function(LiveLocationSocketModel) callback) {
    _listeners.remove(callback);
  }


  /// Join a group room on the location socket
  void joinGroup({required String groupId, required String userId}) {
    if (_socket?.connected == true) {
      _socket!.emit('join-group', {
        'groupId': groupId,
        'userId': userId,
      });
      log('👥 [TrackLiveSocket] Joined group: $groupId');
    }
  }

  /// Leave a group room on the location socket
  void leaveGroup({required String groupId, required String userId}) {
    if (_socket?.connected == true) {
      _socket!.emit('leave-group', {
        'groupId': groupId,
        'userId': userId,
      });
      log('🚪 [TrackLiveSocket] Left group: $groupId');
    }
  }

  @override
  void onClose() {
    _listeners.clear();
    _locationStreamController.close();
    _userStatusStreamController.close();

    if (!_isExternalSocket) {
      _socket?.disconnect();
      _socket?.dispose();
    }
    _socket = null;
    super.onClose();
  }
}
