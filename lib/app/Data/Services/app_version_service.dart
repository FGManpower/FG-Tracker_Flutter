import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/initialize_model.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

class AppVersionService extends GetxService {
  static AppVersionService get instance {
    if (!Get.isRegistered<AppVersionService>()) {
      return Get.put(AppVersionService(), permanent: true);
    }
    return Get.find<AppVersionService>();
  }

  final Rx<AppVersionData?> versionConfig = Rx<AppVersionData?>(null);
  final RxBool isUpdateRequired = false.obs;

  /// Compares two semver strings (e.g. "2.0.1" vs "2.0.3").
  /// Returns:
  ///  -1 if v1 < v2
  ///   0 if v1 == v2
  ///   1 if v1 > v2
  static int compareVersions(String v1, String v2) {
    List<int> parse(String v) => v
        .split(RegExp(r'[^\d]+'))
        .where((s) => s.isNotEmpty)
        .map((s) => int.tryParse(s) ?? 0)
        .toList();

    final p1 = parse(v1);
    final p2 = parse(v2);
    final len = p1.length > p2.length ? p1.length : p2.length;

    for (int i = 0; i < len; i++) {
      final num1 = i < p1.length ? p1[i] : 0;
      final num2 = i < p2.length ? p2[i] : 0;
      if (num1 < num2) return -1;
      if (num1 > num2) return 1;
    }
    return 0;
  }

  /// Checks if installed version is strictly below required minimum version
  bool isBelowMinVersion({
    required String installedVersion,
    required String minVersion,
  }) {
    return compareVersions(installedVersion, minVersion) < 0;
  }

  /// Evaluates if force update is needed based on AppVersionData and current OS platform
  bool checkNeedsForceUpdate(AppVersionData config) {
    versionConfig.value = config;
    final platformData = config.currentPlatformData;

    if (!platformData.forceUpdate) {
      isUpdateRequired.value = false;
      return false;
    }

    final installed = ConstRes.appVersion;

    // The required cutoff: minVersion if provided, otherwise latestVersion
    final targetCutoff = platformData.minVersion.trim().isNotEmpty && platformData.minVersion.trim() != '0.0.0'
        ? platformData.minVersion.trim()
        : platformData.latestVersion.trim();

    // If installed version is strictly less than target cutoff, force update
    final needsUpdate = compareVersions(installed, targetCutoff) < 0;

    debugPrint(
      '[AppVersionService] Platform: ${Platform.isIOS ? "iOS" : "Android"} | '
      'Installed: $installed | Cutoff: $targetCutoff | '
      'Min: ${platformData.minVersion} | Latest: ${platformData.latestVersion} | '
      'ForceUpdate: ${platformData.forceUpdate} | NeedsUpdate: $needsUpdate',
    );

    isUpdateRequired.value = needsUpdate;
    return needsUpdate;
  }

  /// Fetch version config from server (via /api/initialize or fallback /api/app-version)
  Future<AppVersionData?> fetchVersionConfig() async {
    final dio = ConstRes().sendRequest;
    final token = Global.storageServices.getaccesstoken();

    try {
      // 1. If logged in, call /initialize (returns appVersion, payment, walkie, notifications)
      if (token != null && token.isNotEmpty) {
        final res = await dio.get(
          Urls.initialize,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        if (res.statusCode == 200 && res.data != null && res.data['status'] == true) {
          final data = res.data['data'];
          if (data != null && data['appVersion'] != null) {
            return AppVersionData.fromJson(Map<String, dynamic>.from(data['appVersion']));
          }
        }
      }

      // 2. Fallback public version endpoint: /api/app-version
      final res = await dio.get('${ConstRes.aBaseUrl}app-version');
      if (res.statusCode == 200 && res.data != null && res.data['status'] == true) {
        final data = res.data['data'];
        if (data != null) {
          return AppVersionData.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      debugPrint('[AppVersionService] fetchVersionConfig error: $e');
    }
    return null;
  }

  /// Check on app launch and navigate to ForceUpdateScreen if update is required
  Future<bool> checkAndPromptUpdate() async {
    try {
      final config = await fetchVersionConfig();
      if (config != null) {
        final needsUpdate = checkNeedsForceUpdate(config);
        if (needsUpdate) {
          Get.offAllNamed(Routes.forceUpdate, arguments: config);
          return true;
        }
      }
    } catch (e) {
      debugPrint('[AppVersionService] checkAndPromptUpdate error: $e');
    }
    return false;
  }
}
