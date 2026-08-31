import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/modules/Group/Views/QrScreen.dart';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:location/location.dart';

import '../../../Data/Services/LocationPermission.dart';
import '../controller/Group_Controller.dart';

class JoinGroupController extends GetxController {
  GlobalKey<FormState> joinGroupKey = GlobalKey<FormState>();
  final groupCodeController = TextEditingController();
  var responseError = "".obs;

  Future<void> scanQRCodeFromCamera() async {
    QrCodeBottomSheet(groupName: '', groupCode: '',);  }

  Future<bool> joinGroup(
    BuildContext context, {
    required GroupController groupController,
    required String groupCode,
    bool validateForm = true,
    String? type,
  }) async {
    final hasPermission =
        await LocationPermissions().handleLocationPermission();
    if (!hasPermission) {
      CommonDialog.errorMessage(
          "Location permission is required to join a group.");
      return false;
    }

    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        CommonDialog.errorMessage(
            "Please enable location services to join a group.");
        return false;
      }
    }

    try {
      Loading().showloading();
      final param = {"groupCode": groupCode};
      final result = await GroupRepo.joinGroup(param);
      Loading().dismissloading();

      if (result.status == true) {
        Utils().fluttertoast(result.message.toString());
        if (type != "Qr") {
          Navigator.pop(context);
        }
        groupController.getGroupData();
        // final service = TrackingService.instance;
        // await service.init();
        return true;
      } else {
        CommonDialog.errorMessage(result.message);
        return false;
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
      return false;
    }
  }
}
