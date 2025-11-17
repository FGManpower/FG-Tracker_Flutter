
import 'package:fgtracker/app/modules/auth/Controller/OtpController.dart';
import 'package:fgtracker/app/modules/auth/Controller/RegisterController.dart';
import 'package:fgtracker/app/modules/auth/Controller/login_controller.dart';
import 'package:get/get.dart';

import '../Controller/SearchController.dart';



class SearchMember_Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchMemberController>(
          () => SearchMemberController(),
    );
  }
}

