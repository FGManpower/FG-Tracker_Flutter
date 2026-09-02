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

  final StreamController<dynamic> _groupCountController =
      StreamController<dynamic>.broadcast();



  final StreamController<List<LiveLocationModel>>
  _liveLocationController =
  StreamController<List<LiveLocationModel>>.broadcast();

  Stream<List<LiveLocationModel>> get liveLocationStream =>
      _liveLocationController.stream;

  Stream<dynamic> get groupCountStream => _groupCountController.stream;


  void init() {
    if (_socket != null) return;

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
    });

    _socket!.onConnectError((error) {
      log('Dashboard socket error: $error');
    });

    _socket!.on('group_dashboard_counts', (data) {
      if (!_groupCountController.isClosed) {
        _groupCountController.add(data['data']);
      }
    });

    _socket!.on('user-live-location', (response) {
      try {
        final List<dynamic> data;

        if (response is Map && response['data'] is List) {
          data = response['data'];
        } else if (response is List) {
          data = response;
        } else {
          data = [];
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
          item.latitude != 0 &&
              item.longitude != 0,
        )
            .toList();

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
    double radius = 2,
  }) {
    var param = {
      'userId': Global.storageServices.get(PrefConst.userId),
      'userLat': userLat,
      'userLong': userLong,
      'radius': radius,
    };
    log("=====requestLiveParam:${param}");
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
