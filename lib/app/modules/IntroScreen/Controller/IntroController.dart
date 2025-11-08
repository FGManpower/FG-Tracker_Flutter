import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:get/get.dart';

class IntroController extends GetxController {
  var index = 0.obs;

  final List<Map<String, dynamic>> introData = [
    {
      'image': Assets.images.introduction1.path,
      'title': 'Real-Time Tracking',
      'subtitle':
          'View live locations of friends, family, or team members on the map instantly.',
    },
    {
      'image': Assets.images.introduction2.path,
      'title': 'Walkie-Talkie Feature',
      'subtitle': 'No signal. No problem. Stay connected anywhere.',
    },
    {
      'image': Assets.images.introduction3.path,
      'title': 'Secure & Easy',
      'subtitle':
          'Share your live location with selected contacts safely and privately.',
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
