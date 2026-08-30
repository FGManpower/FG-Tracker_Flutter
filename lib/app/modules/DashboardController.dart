import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:get/get.dart';

import 'Messages/Controller/Socket_Message_Services.dart';
import '../Core/constant/pref_res.dart';

class DashboardCtr extends GetxController {
  RxBool DeeplinkWithStartJob = false.obs;

  RxInt totalGroups = 0.obs;
  RxInt totalMembers = 0.obs;
  RxInt activeMembers = 0.obs;
  RxInt locationDisabledMembers = 0.obs;

  final socketService = SocketMessageService.instance;

  @override
  void onInit() {
    super.onInit();

    final userId =
    Global.storageServices.get(PrefConst.userId).toString();

    socketService.listenGroupDashboardCounts(
      callback: (data) {
        print("========== DASHBOARD DATA ==========");
        print(data);

        final dashboardData = data["data"] ?? data;

        totalGroups.value =
            int.tryParse(
              dashboardData["totalGroups"].toString(),
            ) ??
                0;

        totalMembers.value =
            int.tryParse(
              dashboardData["totalMembers"].toString(),
            ) ??
                0;

        activeMembers.value =
            int.tryParse(
              dashboardData["activeMembers"].toString(),
            ) ??
                0;

        locationDisabledMembers.value =
            int.tryParse(
              dashboardData["locationDisabledMembers"].toString(),
            ) ??
                0;

        print("TOTAL GROUPS => ${totalGroups.value}");
        print("TOTAL MEMBERS => ${totalMembers.value}");
        print("ACTIVE MEMBERS => ${activeMembers.value}");
        print(
          "LOCATION DISABLED => ${locationDisabledMembers.value}",
        );
      },
    );

    socketService.init(
      ConstRes.socketUrl,
      userId: userId,
    );
  }
}