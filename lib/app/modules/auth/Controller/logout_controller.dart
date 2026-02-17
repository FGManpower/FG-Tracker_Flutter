import 'package:fgtracker/app/Core/values/Utils.dart';

import 'package:get/get.dart';

import '../../../Core/values/Dialog/Common_dialog.dart';
import '../../../Core/values/loading.dart';
import '../../../Core/values/logoutuser.dart';
import '../../../Data/Repositories/Auth_repo.dart';

class logOutController extends GetxController {
  Future<void> logOutUser() async {
    try {
      Loading().showloading();

      var result = await AuthRepo.logOutUser();
      if (result.status == true) {
        Loading().dismissloading();
        Utils().fluttertoast(result.message.toString());
        LogoutUser().logout();
      } else {
        Loading().dismissloading();
        Utils().fluttertoast(result.message.toString());
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }
}
