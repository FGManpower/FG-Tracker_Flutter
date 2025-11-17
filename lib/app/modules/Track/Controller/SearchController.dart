import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Model/LocationDataRes.dart';

class SearchMemberController extends GetxController {
  late List<LocationData> allMembers;
  RxList<LocationData> filteredMembers = <LocationData>[].obs;
  TextEditingController searchValues = TextEditingController();

  @override
  void onInit() {
    allMembers = Get.arguments["GroupMembers"] ?? [];
    filteredMembers.assignAll(allMembers);
    super.onInit();
  }

  void filterMembers(String query) {
    if (query.isEmpty) {
      filteredMembers.assignAll(allMembers);
    } else {
      filteredMembers.assignAll(
        allMembers
            .where((m) => (m.name ?? "").toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  void clearSearch() {
    searchValues.clear();
    filterMembers("");
    update();
  }
}
