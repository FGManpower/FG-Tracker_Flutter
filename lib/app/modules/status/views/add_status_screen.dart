import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/AddStatusController.dart';
import '../widget/add_status_widgets.dart';

class AddStatusScreen extends StatelessWidget {
  const AddStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddStatusController());

    return Scaffold(
      backgroundColor: Colors.black,
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