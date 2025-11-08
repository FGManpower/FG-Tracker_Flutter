
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';


import '../../../Core/values/Dialog/Common_dialog.dart';
import '../../../Data/Repositories/Notification_Repo.dart';
import '../../../Model/NotificationData.dart';
import 'cubit/notification_count_cubit.dart';

class NotificationController extends GetxController {
  final notificationdata = Rxn<NotificationRes>();
  RxBool loading = false.obs;
  var Respone_Error = "".obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Global.storageServices.setBool(PrefConst.notificationBadge, false);
    BlocProvider.of<NotificationCountCubit>(ContextUtility.context!)
        .showBadge();
    getNotificationData();
  }

  Future<void> getNotificationData() async {
    try {
      loading.value = true;
      var result = await Notification_Repo.getNotificationData();
      if (result.status == true) {
        loading.value = false;
        notificationdata.value = result;

        Respone_Error.value = "";
      } else {
        loading.value = false;
        CommonDialog.errorMessage(result.message.toString());
      }
    } catch (e) {
      loading.value = false;
      Respone_Error.value = e.toString();
    }
  }
}
