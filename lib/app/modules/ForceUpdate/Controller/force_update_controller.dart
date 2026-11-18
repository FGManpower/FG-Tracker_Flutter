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
    final vLatest = platformData.latestVersion.trim();
    final vMin = platformData.minVersion.trim();
    if (vLatest.isNotEmpty) return vLatest;
    if (vMin.isNotEmpty) return vMin;
    return '2.0.5';
  }

  @override
  void onInit() {
    super.onInit();
    final realInstalled = AppVersionService.instance.currentInstalledVersion.value;
    if (realInstalled.trim().isNotEmpty) {
      installedVersion.value = realInstalled.trim();
    }

    final args = Get.arguments;
    if (args is AppVersionData) {
      versionData = args;
    } else if (AppVersionService.instance.versionConfig.value != null) {
      versionData = AppVersionService.instance.versionConfig.value!;
    } else {
      versionData = AppVersionData(
        android: PlatformVersionData(
          minVersion: '2.0.0',
          latestVersion: '2.0.5',
          forceUpdate: true,
          storeUrl: 'https://play.google.com/store/apps/details?id=com.fgtracker',
        ),
        ios: PlatformVersionData(
          minVersion: '2.0.0',
          latestVersion: '2.0.5',
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
