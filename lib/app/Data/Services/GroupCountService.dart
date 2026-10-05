import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:get/get.dart';

class GroupCountService extends GetxService {
  static GroupCountService get instance => Get.find<GroupCountService>();

  final Rx<GroupCountDetail> groupCount = const GroupCountDetail().obs;

  int get totalGroups => groupCount.value.totalGroups;
  int get totalMembers => groupCount.value.totalMembers;
  int get activeMembers => groupCount.value.activeMembers;
  int get locationDisabledMembers => groupCount.value.locationDisabledMembers;

  void updateFromSocket(dynamic data) {
    if (data != null) {
      groupCount.value = GroupCountDetail.fromJson(data);
    }
  }
}