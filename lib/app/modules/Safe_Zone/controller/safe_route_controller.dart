import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SafeRouteController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // State Management
  final RxString selectedRoute = "Route A".obs;
  final RxDouble deviationLimit = 500.0.obs;

  final RxInt selectedGroupMemberIndex = 0.obs; // For horizontal scrolling member selection

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
// void drawRouteOnMap() { }
// void listenToDeviationAlerts() { }
}