

import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';

class GroupService {
  Future<List<String>> getGroupData({String? type}) async {
    try {
      var result = await GroupRepo.getGroupData();
      if (result.status == true && result.data != null) {
        final Set<String> groupIds = {}; // Use Set to avoid duplicate IDs

        // Safely extract and convert all IDs to String
        result.data?.createdGroups?.forEach((item) {
          if (item.id != null) {
            groupIds.add(item.id.toString());
          }
        });

        result.data?.newlyCreatedGroups?.forEach((item) {
          if (item.id != null) {
            groupIds.add(item.id.toString());
          }
        });

        return groupIds.toList();
      } else {
        return [];
      }
    } catch (e) {
      print("❌ Error fetching group data: $e");
      return [];
    }
  }
}
