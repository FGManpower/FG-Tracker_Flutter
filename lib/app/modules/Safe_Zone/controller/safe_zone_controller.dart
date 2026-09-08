import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SafeZoneController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final RxDouble individualRadius = 500.0.obs;
  final RxString selectedIndividualMember = "Vikram Singh".obs;

  final RxDouble groupRadius = 500.0.obs;
  final RxString selectedGroup = "FG Manpower Team".obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

// --- API & Socket Placeholders ---
// void initMapSocket() {
//   // connect to socket, listen to lat/lng updates
// }
// void saveSafeZone() {
//   // POST request with coordinates and radius
// }
}