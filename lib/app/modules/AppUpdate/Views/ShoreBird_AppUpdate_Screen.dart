import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ForceUpdate/Binding/force_update_binding.dart';
import '../../ForceUpdate/Controller/force_update_controller.dart';
import '../../ForceUpdate/Views/force_update_screen.dart';

class ShorebirdAppUpdateScreen extends StatelessWidget {
  const ShorebirdAppUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ForceUpdateController>()) {
      ForceUpdateBinding().dependencies();
    }
    return const ForceUpdateScreen(updateType: UpdateType.shorebird);
  }
}
