import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:fgtracker/app/modules/PackagePricing/Controller/package_list_controller.dart';
import 'package:fgtracker/app/modules/PackagePricing/widgets/package_card.dart';
import 'package:fgtracker/app/modules/PackagePricing/widgets/package_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:fgtracker/l10n/l10n.dart';

/// Packages & Pricing — pick a module to open its plans.
class PackageListView extends GetView<PackageListController> {
  const PackageListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PackageUi.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: PackageUi.maxContentWidth),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                  child: PackageHeader(
                    title: context.l10n.package_title,
                    subtitle: context.l10n.package_subtitle,
                    onBack: () => Get.back(),
                  ),
                ),
                Expanded(child: Obx(_body)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    final items = controller.packages;
    final error = controller.errorMessage.value;

    if (controller.isLoading.value && items.isEmpty) return _skeleton();

    if (items.isEmpty) {
      return PackageStatusView(
        message: error.isNotEmpty
            ? error
            : appL10n.package_noPackages,
        isEmpty: error.isEmpty,
        onRetry: () => controller.fetchPackages(),
      );
    }

    return RefreshIndicator(
      color: PackageUi.accent,
      onRefresh: () => controller.fetchPackages(silent: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, i) {
          final item = items[i];
          return PackageCard(
            item: item,
            onTap: () => controller.openPackage(item),
          );
        },
      ),
    );
  }

  Widget _skeleton() {
    final placeholder = PackageItem.placeholder();
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, __) => PackageCard(item: placeholder),
      ),
    );
  }
}
