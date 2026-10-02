import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/AddStatusController.dart';
import '../widget/add_status_widgets.dart';

class AddStatusScreen extends StatefulWidget {
  const AddStatusScreen({super.key});

  @override
  State<AddStatusScreen> createState() => _AddStatusScreenState();
}

class _AddStatusScreenState extends State<AddStatusScreen> {
  late final AddStatusController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<AddStatusController>()) {
      Get.delete<AddStatusController>(force: true);
    }
    controller = Get.put(AddStatusController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<AddStatusController>()) {
      Get.delete<AddStatusController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          StatusPreview(controller: controller),
          StatusTopBar(controller: controller),
          Obx(() {
            if (controller.isRecording.value) {
              return RecordingBadge(controller: controller);
            }
            return const SizedBox.shrink();
          }),
          StatusBottomControls(controller: controller),
        ],
      ),
    );
  }
}