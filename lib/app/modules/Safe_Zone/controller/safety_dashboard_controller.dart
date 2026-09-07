import 'package:get/get.dart';

class SafetyAlert {
  final String type;
  final String desc;
  final String location;
  final String time;
  final bool isZone;

  SafetyAlert({
    required this.type,
    required this.desc,
    required this.location,
    required this.time,
    required this.isZone,
  });
}

class SafetyDashboardController extends GetxController {
  final RxInt safeNowCount = 24.obs;
  final RxInt alertsCount = 2.obs;

  final recentAlerts = <SafetyAlert>[
    SafetyAlert(
      type: "Safe Zone Alert",
      desc: "Rahul has left the Safe Zone",
      location: "Ghatkopar (Outside Chembur Zone)",
      time: "4:32 PM",
      isZone: true,
    ),
    SafetyAlert(
      type: "Safe Route Alert",
      desc: "Aamir has deviated from Safe Route",
      location: "Vikhroli (Deviation: 850 m)",
      time: "4:45 PM",
      isZone: false,
    ),
  ].obs;
}