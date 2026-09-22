import 'dart:async';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/live_location_model.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketDashboardService extends GetxService {
  static SocketDashboardService get instance =>
      Get.put(SocketDashboardService());

  Socket? _socket;
  Map<String, dynamic>? _lastLiveLocationParams;

  final StreamController<dynamic> _groupCountController =
      StreamController<dynamic>.broadcast();

  final StreamController<List<LiveLocationModel>>
  _liveLocationController =
  StreamController<List<LiveLocationModel>>.broadcast();

  Stream<List<LiveLocationModel>> get liveLocationStream =>
      _liveLocationController.stream;

  Stream<dynamic> get groupCountStream => _groupCountController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void init() {
    if (_socket != null) {
      if (isConnected) {
        requestGroupCount();
      }
      return;
    }

    _socket = io(
      '${ConstRes.socketUrl}/dashboard',
      {
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true,
      },
    );

    _socket!.onConnect((_) {
      log('Dashboard socket connected');
      requestGroupCount();
      if (_lastLiveLocationParams != null) {
        log('📡 [DashboardSocket] Re-emitting get-user-live-location on connect: $_lastLiveLocationParams');
        _socket?.emit('get-user-live-location', _lastLiveLocationParams);
      }
    });

    _socket!.onConnectError((error) {
      log('Dashboard socket error: $error');
    });

    _socket!.on('group_dashboard_counts', (data) {
      log('📡 [DashboardSocket] group_dashboard_counts received: $data');
      if (!_groupCountController.isClosed) {
        dynamic payload = data;
        if (data is Map && data.containsKey('data') && data['data'] != null) {
          payload = data['data'];
        }
        _groupCountController.add(payload);
      }
    });

    _socket!.on('user-live-location', (response) {
      try {
        log('📡 [DashboardSocket] user-live-location received: $response');
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
    _socket?.emit(
      'get_group_dashboard_counts',
      {
        'userId': Global.storageServices.get(PrefConst.userId),
      },
    );
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

    log('📡 [DashboardSocket] Emitting get-user-live-location: $param');
    _socket?.emit(
      'get-user-live-location',
      param,
    );
  }

  @override
  void onClose() {
    _socket?.dispose();
    _socket = null;

    _groupCountController.close();
    _liveLocationController.close();

    super.onClose();
  }
}
