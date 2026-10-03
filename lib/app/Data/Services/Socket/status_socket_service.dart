import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class StatusSocketService extends GetxService {
  io.Socket? _socket;
  final RxBool isConnected = false.obs;

  final Rxn<Map<String, dynamic>> onNewStatusEvent =
  Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> onStatusViewedEvent =
  Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> onStatusDeletedEvent =
  Rxn<Map<String, dynamic>>();

  void connect({String? baseUrl, String? token}) {
    final resolvedBaseUrl = (baseUrl ?? ConstRes.socketUrl)
        .replaceAll(RegExp(r'/$'), '');
    final resolvedToken =
        token ?? Global.storageServices.getaccesstoken() ?? '';
    final namespaceUrl = '$resolvedBaseUrl/status';

    _socket?.dispose();

    _socket = io.io(
      namespaceUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': resolvedToken})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      isConnected.value = true;
    });

    _socket!.onDisconnect((_) {
      isConnected.value = false;
    });

    _socket!.on('status:new', (data) {
      if (data is Map) {
        onNewStatusEvent.value = Map<String, dynamic>.from(data);
      }
    });

    _socket!.on('status:viewed', (data) {
      if (data is Map) {
        onStatusViewedEvent.value = Map<String, dynamic>.from(data);
      }
    });

    _socket!.on('status:deleted', (data) {
      if (data is Map) {
        onStatusDeletedEvent.value = Map<String, dynamic>.from(data);
      }
    });
  }

  void emitStatusView({
    required int statusId,
    String? reactionEmoji,
    void Function(bool success, Map<String, dynamic>? data)? onResult,
  }) {
    if (_socket == null || !isConnected.value) {
      onResult?.call(false, null);
      return;
    }

    final payload = <String, dynamic>{
      'statusId': statusId,
      if (reactionEmoji != null && reactionEmoji.isNotEmpty)
        'reactionEmoji': reactionEmoji,
    };

    _socket!.emitWithAck(
      'status:view',
      payload,
      ack: (response) {
        if (response is Map) {
          final map = Map<String, dynamic>.from(response);
          final success = map['success'] == true;
          final data = map['data'] is Map
              ? Map<String, dynamic>.from(map['data'])
              : null;
          onResult?.call(success, data);
        } else {
          onResult?.call(false, null);
        }
      },
    );
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}