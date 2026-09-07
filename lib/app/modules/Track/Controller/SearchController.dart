import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Model/LocationDataRes.dart';

class SearchMemberController extends GetxController {
  List<LocationData> allMembers = [];
  RxList<LocationData> filteredMembers = <LocationData>[].obs;
  TextEditingController searchValues = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    try {
      final args = Get.arguments;
      if (args is Map && args["GroupMembers"] != null) {
        if (args["GroupMembers"] is List<LocationData>) {
          allMembers = List<LocationData>.from(args["GroupMembers"]);
        } else if (args["GroupMembers"] is List) {
          allMembers = (args["GroupMembers"] as List)
              .map((e) => e is LocationData ? e : LocationData.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error loading arguments in SearchMemberController: $e");
    }
    filteredMembers.assignAll(allMembers);
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
