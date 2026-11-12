import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';

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
      type: appL10n.safeZone_alertTitle,
      desc: appL10n.safeZone_memberLeft("Rahul"),
      location: appL10n.safeZone_outsideZone("Ghatkopar", "Chembur Zone"),
      time: appTime(DateTime(2000, 1, 1, 16, 32)),
      isZone: true,
    ),
    SafetyAlert(
      type: appL10n.safeRoute_alertTitle,
      desc: appL10n.safeRoute_memberDeviated("Aamir"),
      location: appL10n.safeRoute_deviationAt("Vikhroli", "850 m"),
      time: appTime(DateTime(2000, 1, 1, 16, 45)),
      isZone: false,
    ),
  ].obs;
}