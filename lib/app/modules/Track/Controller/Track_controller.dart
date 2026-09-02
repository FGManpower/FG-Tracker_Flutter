import 'package:fgtracker/app/Model/MemberModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrackController extends GetxController {
  RxString selectedRadius = '2'.obs;
  TextEditingController customRadiusController = TextEditingController();

  RxInt selectedTabIndex = 0.obs;

  RxList<MemberModel> liveMembers = <MemberModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMockData();
  }

  void fetchMockData() {
    liveMembers.value = [
      MemberModel(
        name: "Samad",
        team: "FG Manpower Team",
        location: "Ghatkopar, Mumbai",
        distance: "0.3",
        battery: 80,
        avatarUrl: "https://i.pravatar.cc/150?img=11",
      ),
      MemberModel(
        name: "Riya Sharma",
        team: "Event Management Team",
        location: "Ghatkopar, Mumbai",
        distance: "0.8",
        battery: 70,
        avatarUrl: "https://i.pravatar.cc/150?img=5",
      ),
      MemberModel(
        name: "Neha Verma",
        team: "Construction Site Team",
        location: "Vikhroli, Mumbai",
        distance: "1.2",
        battery: 65,
        avatarUrl: "https://i.pravatar.cc/150?img=9",
      ),
      MemberModel(
        name: "Arjun Patel",
        team: "Logistics & Delivery Team",
        location: "Powai, Mumbai",
        distance: "1.9",
        battery: 55,
        avatarUrl: "https://i.pravatar.cc/150?img=12",
      ),
    ];
  }

  void updateRadius(String value) {
    selectedRadius.value = value;

  }

  @override
  void onClose() {
    customRadiusController.dispose();
    super.onClose();
  }
}

