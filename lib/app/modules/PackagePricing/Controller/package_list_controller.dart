import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Repositories/package_pricing_repo.dart';
import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Packages & Pricing hub: one card per module.
/// Walkie-Talkie opens its existing plan screen; every other module opens
/// the shared PackagePlanDetailsView.
class PackageListController extends GetxController {
  final RxList<PackageItem> packages = <PackageItem>[].obs;
  final RxBool isLoading = false.obs;
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
      final res = await PackagePricingRepo.getPackages();
      if (res.status) {
        final list = res.packages
            .where((p) => p.moduleKey.isNotEmpty)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        packages.assignAll(list);
      } else if (packages.isEmpty) {
        errorMessage.value =
            res.message ?? 'Unable to load packages. Please try again.';
      } else {
        Utils().fluttertoast(
            res.message ?? 'Unable to refresh packages. Please try again.');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[PackageList] fetch failed: $e');
      // HttpUtil throws a readable message string
      final msg = e.toString();
      if (packages.isEmpty) {
        errorMessage.value = msg;
      } else {
        Utils().fluttertoast(msg);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openPackage(PackageItem item) async {
    if (!item.isAvailable) {
      Utils().fluttertoast('${item.title} plans are coming soon');
      return;
    }

    // Walkie-Talkie already has its own plan → order summary → payment flow
    if (item.moduleKey == PackageModuleKey.walkieTalkie) {
      await Get.toNamed(Routes.walkieTalkiePlanScreen);
      fetchPackages(silent: true);
      return;
    }

    final purchased = await Get.toNamed(
      Routes.packagePlanDetails,
      arguments: {'moduleKey': item.moduleKey, 'package': item},
    );
    // Refresh so the card shows the new "Active" status
    if (purchased == true) fetchPackages(silent: true);
  }
}
