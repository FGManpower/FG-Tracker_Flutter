// Custom banner camera permission (doc 05 §5.1.1). The permission plugin's
// method channel is mocked; statuses use permission_handler's codes:
// denied 0, granted 1, restricted 2, limited 3, permanentlyDenied 4.
import 'package:fgtracker/app/Data/Services/local_banner_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel('flutter.baseflow.com/permissions/methods');
const _camera = 1; // Permission.camera.value

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late int status;
  late List<int> requestReplies;
  late int requests;
  late bool throwOnRequest;

  setUp(() {
    status = 0;
    requestReplies = [];
    requests = 0;
    throwOnRequest = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      switch (call.method) {
        case 'checkPermissionStatus':
          return status;
        case 'requestPermissions':
          requests++;
          if (throwOnRequest) {
            throw PlatformException(
                code: 'PermissionHandler.PermissionManager',
                message: 'A request for permissions is already running');
          }
          final reply = requestReplies.isEmpty ? 0 : requestReplies.removeAt(0);
          status = reply;
          return {_camera: reply};
      }
      return null;
    });
  });

  test('BCP-01 already granted → granted, no popup', () async {
    status = 1;
    expect(await LocalBannerService.ensureCameraPermission(),
        BannerCameraAccess.granted);
    expect(requests, 0);
  });

  test('BCP-02 first "Don\'t allow" (Android) → denied → ask-again dialog',
      () async {
    requestReplies = [0];
    expect(await LocalBannerService.ensureCameraPermission(),
        BannerCameraAccess.denied);
    expect(requests, 1);
  });

  test('BCP-03 "Allow" in our dialog → popup again → granted', () async {
    requestReplies = [1];
    expect(await LocalBannerService.ensureCameraPermission(retry: true),
        BannerCameraAccess.granted);
    expect(requests, 1);
  });

  test('BCP-04 "Allow" but refused / no popup shown (MIUI) → Settings, '
      'never the same dialog again', () async {
    requestReplies = [0];
    expect(await LocalBannerService.ensureCameraPermission(retry: true),
        BannerCameraAccess.blocked);
  });

  test('BCP-05 "Don\'t ask again" / iOS refusal → blocked → Settings',
      () async {
    requestReplies = [4];
    expect(await LocalBannerService.ensureCameraPermission(),
        BannerCameraAccess.blocked);
    status = 4;
    expect(await LocalBannerService.ensureCameraPermission(),
        BannerCameraAccess.blocked);
  });

  test('BCP-06 parental controls (restricted) → blocked', () async {
    status = 2;
    expect(await LocalBannerService.ensureCameraPermission(),
        BannerCameraAccess.blocked);
  });

  test('BCP-07 another request running → retried once, then Settings, '
      'never a silent "granted"', () async {
    throwOnRequest = true;
    expect(await LocalBannerService.ensureCameraPermission(),
        BannerCameraAccess.blocked);
    expect(requests, 2);
  });
}
