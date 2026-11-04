import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Repositories/package_api_error.dart';
import 'package:fgtracker/app/Data/Repositories/package_pricing_repo.dart';
import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';
/// Packages & Pricing: one card per module, all from GET /api/packages.
/// Walkie-Talkie opens its existing plan screen; the rest are "Coming soon".
class PackageListController extends GetxController {
  /// Injected in tests; defaults to the real API
  final Future<PackageListResponse> Function() _load;

  PackageListController({Future<PackageListResponse> Function()? loader})
      : _load = loader ?? PackagePricingRepo.getPackages;

  final RxList<PackageItem> packages = <PackageItem>[].obs;
  final RxBool isLoading = false.obs;

  /// Friendly text for the error state ('' = no error)
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPackages();
  }

  /// [silent] keeps the current list on screen (pull-to-refresh, return
  /// from a purchase) instead of showing the skeleton.
  Future<void> fetchPackages({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _load();
      final list = res.packages
          .where((p) => p.moduleKey.isNotEmpty)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      packages.assignAll(list);
    } catch (e) {
      final message = _friendly(e);
      if (kDebugMode) AppLog.d('[PackageList] fetch failed: $e');
      if (packages.isEmpty) {
        errorMessage.value = message;
      } else {
        Utils().fluttertoast(message);
      }
    } finally {
      isLoading.value = false;
    }
  }

  static String _friendly(Object e) => e is PackageApiException
      ? e.userMessage
      : 'Something went wrong. Please try again.';

  /// Only Walkie-Talkie has an inner screen (its existing plan → order
  /// summary → payment flow). Every other module is "Coming soon".
  Future<void> openPackage(PackageItem item) async {
    if (!item.isAvailable || item.moduleKey != PackageModuleKey.walkieTalkie) {
      Utils().fluttertoast('${item.title} plans are coming soon');
      return;
    }
    await Get.toNamed(Routes.walkieTalkiePlanScreen);
    // Refresh so the card reflects a purchase made in the Walkie flow
    fetchPackages(silent: true);
  }
}
