import 'dart:async';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/logoutuser.dart';
import 'package:fgtracker/app/Model/live_location_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../GroupCountService.dart';

class SocketDashboardService extends GetxService with WidgetsBindingObserver {
  static SocketDashboardService get instance {
    if (!Get.isRegistered<SocketDashboardService>()) {
      return Get.put<SocketDashboardService>(
        SocketDashboardService._internal(),
        permanent: true,
      );
    }
    return Get.find<SocketDashboardService>();
  }

  factory SocketDashboardService() => instance;
  SocketDashboardService._internal();

  Socket? _socket;
  Map<String, dynamic>? _lastLiveLocationParams;

  final StreamController<dynamic> _groupCountController =
      StreamController<dynamic>.broadcast();

  final StreamController<List<LiveLocationModel>> _liveLocationController =
      StreamController<List<LiveLocationModel>>.broadcast();

  Stream<List<LiveLocationModel>> get liveLocationStream =>
      _liveLocationController.stream;

  Stream<dynamic> get groupCountStream => _groupCountController.stream;

  bool get isConnected => _socket?.connected ?? false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log('[DashboardSocket] App resumed, syncing counts & socket connection');
      if (_socket == null || !isConnected) {
        init();
      } else {
        requestGroupCount();
      }
    }
  }

  void init() {
    if (_socket != null) {
      if (isConnected) {
        requestGroupCount();
      } else {
        _socket?.connect();
      }
      return;
    }

    _socket = io(
      '${ConstRes.socketUrl}/dashboard',
      {
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': false,
        'reconnection': true,
        'reconnectionAttempts': 10,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 10000,
        'randomizationFactor': 0.5,
      },
    );

    _socket!.onConnect((_) {
      log('Dashboard socket connected');
      requestGroupCount();
      if (_lastLiveLocationParams != null) {
        log('[DashboardSocket] Re-emitting get-user-live-location on connect: $_lastLiveLocationParams');
        _socket?.emit('get-user-live-location', _lastLiveLocationParams);
      }
    });

    _socket!.onReconnect((_) {
      log('Dashboard socket reconnected');
      requestGroupCount();
      if (_lastLiveLocationParams != null) {
        _socket?.emit('get-user-live-location', _lastLiveLocationParams);
      }
    });

    _socket!.on('force_logout', (data) {
      log('[DashboardSocket] force_logout received: $data');
      LogoutUser().handleForceLogout();
    });

    _socket!.onConnectError((error) {
      log('Dashboard socket error: $error');
    });

    _socket!.off('group_dashboard_counts');
    _socket!.on('group_dashboard_counts', (data) {
      try {
        log('[DashboardSocket] group_dashboard_counts received: $data');
        dynamic payload = data;
        if (data is Map && data.containsKey('data') && data['data'] != null) {
          payload = data['data'];
        }

        if (Get.isRegistered<GroupCountService>()) {
          GroupCountService.instance.updateFromSocket(payload);
        }

        if (!_groupCountController.isClosed) {
          _groupCountController.add(payload);
        }
      } catch (e) {
        log('Error parsing group_dashboard_counts: $e');
      }
    });

    _socket!.on('user-live-location', (response) {
      try {
        log('[DashboardSocket] user-live-location received: $response');
        List<dynamic> data = [];

        if (response is Map) {
          if (response['data'] is List) {
            data = response['data'];
          } else if (response['locations'] is List) {
            data = response['locations'];
          } else if (response['users'] is List) {
            data = response['users'];
          } else if (response['members'] is List) {
            data = response['members'];
          } else if (response['data'] is Map) {
            final inner = response['data'];
            if (inner['locations'] is List) {
              data = inner['locations'];
            } else if (inner['users'] is List) {
              data = inner['users'];
            } else if (inner['members'] is List) {
              data = inner['members'];
            }
          }
        } else if (response is List) {
          data = response;
        }

        final locations = data
            .whereType<Map>()
            .map(
              (item) => LiveLocationModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where(
              (item) =>
                  (item.latitude != 0 && item.longitude != 0) ||
                  (item.address != null && item.address!.trim().isNotEmpty),
            )
            .toList();

        log('📡 [DashboardSocket] Successfully parsed ${locations.length} live members');

        if (!_liveLocationController.isClosed) {
          _liveLocationController.add(locations);
        }
      } catch (e) {
        log('Live location parsing error: $e');
      }
    });
  }

  void requestGroupCount() {
    final userId = Global.storageServices.get(PrefConst.userId);
    if (userId == null || userId.toString().isEmpty) {
      log('[DashboardSocket] Skip requestGroupCount: userId is empty');
      return;
    }

    if (isConnected) {
      _socket?.emit(
        'get_group_dashboard_counts',
        {
          'userId': userId,
        },
      );
      log('[DashboardSocket] Emitted get_group_dashboard_counts for userId: $userId');
    }
  }

  void requestLiveLocation({
    required double userLat,
    required double userLong,
    dynamic radius = 2,
    String? address,
    String? area,
    String? city,
    int? battery,
  }) {
    var param = {
      'userId': Global.storageServices.get(PrefConst.userId),
      'userLat': userLat,
      'userLong': userLong,
      'radius': radius,
      'battery': battery ?? 85,
      if (address != null && address.isNotEmpty) 'address': address,
      if (area != null && area.isNotEmpty) 'area': area,
      if (city != null && city.isNotEmpty) 'city': city,
    };

    _lastLiveLocationParams = param;

    log('[DashboardSocket] Emitting get-user-live-location: $param');
    _socket?.emit(
      'get-user-live-location',
      param,
    );
  }

  void disconnect() {
    try {
      _socket?.clearListeners();
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
    } catch (_) {}
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();

    _groupCountController.close();
    _liveLocationController.close();

    super.onClose();
  }
}
