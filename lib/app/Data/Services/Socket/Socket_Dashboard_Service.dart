import 'dart:async';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketDashboardService extends GetxService {
  static SocketDashboardService get instance =>
      Get.put(SocketDashboardService());

  Socket? _socket;

  final StreamController<dynamic> _groupCountController =
  StreamController<dynamic>.broadcast();

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

    _socket!.onConnect((_) => requestGroupCount());
    _socket!.on('group_dashboard_counts', (data) {
      log("getGroupDashcount:${data['data']}");
      if (!_groupCountController.isClosed) {
        _groupCountController.add(data['data']);
      }
    });
  }

  void requestGroupCount() {
    _socket?.emit('get_group_dashboard_counts', {
      'userId': Global.storageServices.get(PrefConst.userId),
    },);
  }

  @override
  void onClose() {
    _socket?.dispose();
    _socket = null;
    _groupCountController.close();
  }
}
