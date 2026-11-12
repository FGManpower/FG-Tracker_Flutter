import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';

class IntroController extends GetxController {
  var index = 0.obs;

  List<Map<String, dynamic>> get introData => [
    {
      'image': Assets.images.introductionn1.path,
      'icon': Assets.icons.realtimetrack,
      'title': appL10n.intro_realTimeTrackingTitle,
      'subtitle': appL10n.intro_realTimeTrackingSubtitle,
    },
    {
      'image': Assets.images.introductionn2.path,
      'icon': FontAwesomeIcons.walkieTalkie,
      'title': appL10n.intro_walkieTitle,
      'subtitle': appL10n.intro_walkieSubtitle,
    },
    {
      'image': Assets.images.introductionn3.path,
      'icon': Icons.verified_user_outlined,
      'title': appL10n.intro_secureTitle,
      'subtitle': appL10n.intro_secureSubtitle,
    },
  ];

  void next() {
    if (index.value < introData.length - 1) {
      index.value++;
    } else {
      Global.storageServices.setBool(PrefConst.introStatus, true);
      Get.offAllNamed(Routes.Login);
    }
  }

  void previous() {
    if (index.value > 0) {
      index.value--;
    }
  }
}
