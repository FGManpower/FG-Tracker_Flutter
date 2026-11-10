import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Data/Services/app_version_service.dart';
import 'package:fgtracker/app/Model/initialize_model.dart';

class ForceUpdateController extends GetxController {
  late AppVersionData versionData;
  late PlatformVersionData platformData;

  final RxBool isLaunchingStore = false.obs;
  final RxString installedVersion = ConstRes.appVersion.obs;

  String get targetStoreVersion {
    if (platformData.latestVersion.trim().isNotEmpty && platformData.latestVersion.trim() != '0.0.0') {
      return platformData.latestVersion.trim();
    }
    return platformData.minVersion.trim();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is AppVersionData) {
      versionData = args;
    } else if (AppVersionService.instance.versionConfig.value != null) {
      versionData = AppVersionService.instance.versionConfig.value!;
    } else {
      versionData = AppVersionData(
        android: PlatformVersionData(
          minVersion: '2.0.3',
          latestVersion: '2.0.3',
          forceUpdate: true,
          storeUrl: 'https://play.google.com/store/apps/details?id=com.fgtracker',
        ),
        ios: PlatformVersionData(
          minVersion: '2.0.3',
          latestVersion: '2.0.3',
          forceUpdate: true,
          storeUrl: 'https://apps.apple.com/app/fg-tracker/id6738914614',
        ),
      );
    }
    platformData = versionData.currentPlatformData;
  }

  Future<void> openStore() async {
    isLaunchingStore.value = true;
    try {
      String urlStr = platformData.storeUrl.trim();
      if (urlStr.isEmpty) {
        urlStr = Platform.isIOS
            ? 'https://apps.apple.com/app/fg-tracker/id6738914614'
            : 'https://play.google.com/store/apps/details?id=com.fgtracker';
      }

      final uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('[ForceUpdateController] Could not launch $urlStr');
      }
    } catch (e) {
      debugPrint('[ForceUpdateController] Error launching store: $e');
    } finally {
      isLaunchingStore.value = false;
    }
  }
}
