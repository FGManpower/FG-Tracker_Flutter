
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/deep_Link/uniservices.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/walkie_native_service.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:get/get.dart';

class WalkieController extends GetxController{


  Future<void> startServices({required String callerName,profileImage,required String remoteUserId}) async {
    await WalkieNativeService.start(
      myUserId:
      Global.storageServices.get(PrefConst.userId).toString(),
      remoteUserId:remoteUserId.toString(),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    Get.toNamed(Routes.walkieTalkieScreen,arguments: {
      "callerName": callerName ?? "",
      "profileUrl": profileImage,
    });

  }
}