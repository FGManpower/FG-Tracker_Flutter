import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import '../../Core/util/app_log.dart';

class GroupService {
  Future<List<String>> getGroupData({String? type}) async {
    try {
      var result = await GroupRepo.getGroupData();
      if (result.status == true && result.data != null) {
        final Set<String> groupIds = {};

        result.data?.groupData?.forEach((item) {
          if (item.id != null) {
            groupIds.add(item.id.toString());
          }
        });

        return groupIds.toList();
      } else {
        return [];
      }
    } catch (e) {
      AppLog.e("Error fetching group data: $e");
      return [];
    }
  }
}
