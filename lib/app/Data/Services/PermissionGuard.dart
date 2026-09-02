import 'package:fgtracker/app/Core/values/BottomSheets/pemission_bottomSheet.dart';
import 'package:fgtracker/app/modules/home/Controller/permission_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PermissionGuard {
  static Future<bool> checkAndRequestAllPermissions(
    BuildContext context, {
    bool autoFetchLocation = false,
  }) async {
    final controller = Get.put(PermissionController());

    int step = await controller.getStartingStep();

    if (step < 2 && context.mounted) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => const PermissionBottomSheet(),
      );

      return false;
    }

    if (autoFetchLocation && context.mounted) {}

    return true;
  }
}
