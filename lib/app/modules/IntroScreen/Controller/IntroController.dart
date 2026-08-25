import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class IntroController extends GetxController {
  var index = 0.obs;

  final List<Map<String, dynamic>> introData = [
    {
      'image': Assets.images.introductionn1.path,
      'icon': Assets.icons.realtimetrack,
      'title': 'Real-Time Tracking',
      'subtitle':
          'View live locations of friends, \n family, or team members on \n the map instantly.',
    },
    {
      'image': Assets.images.introductionn2.path,
      'icon': FontAwesomeIcons.walkieTalkie,
      'title': 'Walkie-Talkie \n feature',
      'subtitle': 'No signal. No problem. Stay \n connected anywhere.',
    },
    {
      'image': Assets.images.introductionn3.path,
      'icon': Icons.verified_user_outlined,
      'title': 'Secure & Easy',
      'subtitle':
          'Share your live location with \n selected contacts safely and \n privately.',
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
