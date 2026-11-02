import 'package:fgtracker/app/modules/PackagePricing/Controller/package_list_controller.dart';
import 'package:fgtracker/app/modules/PackagePricing/Controller/package_plan_details_controller.dart';
import 'package:get/get.dart';

class PackageListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackageListController>(() => PackageListController());
  }
}

class PackagePlanDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackagePlanDetailsController>(
        () => PackagePlanDetailsController());
  }
}
