import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  final RxString currentInstalledVersion = ConstRes.appVersion.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInstalledVersion();
  }

  /// Loads the real app version from native Android / iOS package info.
  /// Falls back to ConstRes.appVersion if not available.
  Future<String> _loadInstalledVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        currentInstalledVersion.value = info.version.trim();
      }
    } catch (e) {
      debugPrint('[AppVersionService] PackageInfo error (using fallback): $e');
    }
    return currentInstalledVersion.value;
  }

  /// Compares two semver strings (e.g. "2.0.1" vs "2.0.5").
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

    final installed = currentInstalledVersion.value.trim().isNotEmpty
        ? currentInstalledVersion.value.trim()
        : ConstRes.appVersion.trim();

    // Minimum required version: mandatory floor to run the app
    final vMin = platformData.minVersion.trim();
    final vLatest = platformData.latestVersion.trim();
    final targetCutoff = vMin.isNotEmpty ? vMin : (vLatest.isNotEmpty ? vLatest : '2.0.0');

    // If installed version is strictly less than minimum required version, force update
    final needsUpdate = compareVersions(installed, targetCutoff) < 0;

    debugPrint(
      '[AppVersionService] Platform: ${Platform.isIOS ? "iOS" : "Android"} | '
      'Installed: $installed | Min Required: $targetCutoff | '
      'Latest Store: $vLatest | ForceUpdate: ${platformData.forceUpdate} | '
      'NeedsUpdate: $needsUpdate',
    );

    isUpdateRequired.value = needsUpdate;
    return needsUpdate;
  }

  /// Fetch version config from server (via /api/initialize or fallback /api/app-version)
  Future<AppVersionData?> fetchVersionConfig() async {
    final dio = ConstRes().sendRequest;
    final token = Global.storageServices.getaccesstoken();

    // 1. If logged in, attempt /api/initialize (isolated try-catch so 401 falls back cleanly)
    if (token != null && token.isNotEmpty) {
      try {
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
      } catch (e) {
        debugPrint('[AppVersionService] Authenticated initialize error (falling back to public endpoint): $e');
      }
    }

    // 2. Fallback to public endpoint: /api/app-version
    try {
      final res = await dio.get('${ConstRes.aBaseUrl}app-version');
      if (res.statusCode == 200 && res.data != null && res.data['status'] == true) {
        final data = res.data['data'];
        if (data != null) {
          return AppVersionData.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      debugPrint('[AppVersionService] Fallback fetchVersionConfig error: $e');
    }
    return null;
  }

  /// Check on app launch and navigate to ForceUpdateScreen if update is required
  Future<bool> checkAndPromptUpdate() async {
    try {
      await _loadInstalledVersion();
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
