import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Services/MethodChannel.dart';
import 'package:fgtracker/app/Data/Services/app_version_service.dart';
import 'package:fgtracker/app/Model/initialize_model.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/l10n/l10n.dart';

enum UpdateType {
  forceUpdate,
  shorebird,
}

class ForceUpdateController extends GetxController {
  late AppVersionData versionData;
  late PlatformVersionData platformData;

  final Rx<UpdateType> updateType = UpdateType.forceUpdate.obs;
  bool get isShorebird => updateType.value == UpdateType.shorebird;

  // Force Update state
  final RxBool isLaunchingStore = false.obs;
  final RxString installedVersion = ConstRes.appVersion.obs;

  // Shorebird state
  final ShorebirdUpdater updater = ShorebirdUpdater();
  final RxBool isCheckingShorebird = false.obs;
  final RxBool isDownloadingShorebird = false.obs;
  final RxDouble shorebirdProgress = 0.0.obs;
  final RxBool isRestartRequired = false.obs;
  final RxBool isUpToDate = false.obs;
  final Rx<int?> currentPatch = Rx<int?>(null);
  final RxString shorebirdStatusMessage = ''.obs;
  Timer? _progressTimer;

  String get targetStoreVersion {
    final vLatest = platformData.latestVersion.trim();
    final vMin = platformData.minVersion.trim();
    if (vLatest.isNotEmpty) return vLatest;
    if (vMin.isNotEmpty) return vMin;
    return '2.0.5';
  }

  void setUpdateType(UpdateType type) {
    if (updateType.value != type) {
      updateType.value = type;
      if (type == UpdateType.shorebird) {
        initShorebird();
      }
    }
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

    // Check if opened via shorebird route or argument
    if (Get.currentRoute == Routes.shorebirdUpdate ||
        (args is Map && args['type'] == 'shorebird')) {
      updateType.value = UpdateType.shorebird;
      initShorebird();
    }
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    super.onClose();
  }

  Future<void> initShorebird() async {
    try {
      final patch = await updater.readCurrentPatch();
      currentPatch.value = patch?.number;
    } catch (_) {}
    await checkShorebirdUpdate(showToast: false);
  }

  Future<void> checkShorebirdUpdate({bool showToast = true}) async {
    if (isCheckingShorebird.value || isDownloadingShorebird.value) return;

    try {
      isCheckingShorebird.value = true;
      shorebirdStatusMessage.value = 'Checking for updates...';

      if (!updater.isAvailable) {
        shorebirdStatusMessage.value = 'Shorebird Code Push is unavailable';
        if (showToast) Utils().fluttertoast(appL10n.appUpdate_updateUnavailable);
        return;
      }

      final status = await updater.checkForUpdate(track: UpdateTrack.stable);

      switch (status) {
        case UpdateStatus.upToDate:
          isUpToDate.value = true;
          shorebirdStatusMessage.value = 'App is up to date';
          if (showToast) Utils().fluttertoast(appL10n.appUpdate_noUpdateAvailable);
          break;
        case UpdateStatus.outdated:
          isUpToDate.value = false;
          shorebirdStatusMessage.value = 'New update found! Downloading...';
          await downloadShorebirdUpdate();
          break;
        case UpdateStatus.restartRequired:
          isRestartRequired.value = true;
          shorebirdStatusMessage.value = 'Update installed. Restart required.';
          break;
        case UpdateStatus.unavailable:
          isUpToDate.value = true;
          shorebirdStatusMessage.value = 'No update available';
          if (showToast) Utils().fluttertoast(appL10n.appUpdate_updateUnavailable);
          break;
      }
    } catch (error) {
      debugPrint('[ForceUpdateController] Shorebird check error: $error');
      shorebirdStatusMessage.value = 'Error checking for updates';
      if (showToast) Utils().fluttertoast(appL10n.appUpdate_checkError(error.toString()));
    } finally {
      isCheckingShorebird.value = false;
    }
  }

  Future<void> downloadShorebirdUpdate() async {
    try {
      isDownloadingShorebird.value = true;
      shorebirdProgress.value = 0.0;

      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
        if (shorebirdProgress.value < 90) {
          shorebirdProgress.value += 5.0;
        }
      });

      await updater.update(track: UpdateTrack.stable);

      _progressTimer?.cancel();
      shorebirdProgress.value = 100.0;
      isDownloadingShorebird.value = false;
      isRestartRequired.value = true;
      shorebirdStatusMessage.value = 'Update downloaded! Restart to apply.';
      Utils().fluttertoast(appL10n.appUpdate_restartApp);
    } on UpdateException catch (error) {
      _progressTimer?.cancel();
      isDownloadingShorebird.value = false;
      shorebirdStatusMessage.value = error.message;
      Utils().fluttertoast(error.message);
    } catch (e) {
      _progressTimer?.cancel();
      isDownloadingShorebird.value = false;
      shorebirdStatusMessage.value = e.toString();
      Utils().fluttertoast(e.toString());
    }
  }

  void restartApp() {
    if (Platform.isAndroid) {
      RestartHelper().restartApplication();
    } else {
      exit(0);
    }
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
