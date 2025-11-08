import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';


class GroupController extends GetxController {
  GlobalKey<FormState> createGroupKey = GlobalKey<FormState>();
  final groupName = TextEditingController();
  final groupDesc = TextEditingController();
  RxBool groupDataLoading = false.obs;
  var groupData = <GroupData>[].obs;
  var responseError = "".obs;

  Future<void> decodeQRCodeFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final barcodeScanner = BarcodeScanner();

      final barcodes = await barcodeScanner.processImage(inputImage);
      for (final barcode in barcodes) {
        final groupCode = barcode.rawValue;
        if (groupCode != null) {
          handleJoinGroup(groupCode);
        }
      }
      await barcodeScanner.close();
    }
  }

  void handleJoinGroup(String groupCode) {}

  Future<bool> createGroup(BuildContext context,
      {required GroupController controller}) async {
    if (!createGroupKey.currentState!.validate()) return false;

    // TrackingController.instance.locationService.initLocationTracking();
    try {
      Loading().showloading();
      dynamic param = {
        "groupName": groupName.text,
        "groupDesc": groupDesc.text,
      };
      var result = await GroupRepo.createGroup(param);
      if (result.status == true) {

        Loading().dismissloading();
        Utils().fluttertoast(result.message.toString());

        controller.getGroupData();

        return true;
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
        return false;
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
      return false;
    }
  }

  Future<void> getGroupData({String? type}) async {
    try {
      groupDataLoading.value = true;
      var result = await GroupRepo.getGroupData();
      if (result.status == true) {
        groupData.value = result.groupData!;
        responseError.value = "";
        groupDataLoading.value = false;
        try{
          TrackingController.instance.inItAllGroups(groups: result.groupData ?? []);

        }catch(e){
          print("error in inItAllGroups:${e}");
        }

      } else {
        groupDataLoading.value = false;
        responseError.value = result.message.toString();
      }
    } catch (e) {
      responseError.value = e.toString();
      groupDataLoading.value = false;
    }
  }

  // Future<void> inItSocket({int? groupId}) async {
  //   try {
  //     var result = await GroupRepo.getGroupData();
  //     if (result.status == true) {
  //       TrackingController.instance.inItAllGroups(groups: result.groupData);
  //       // if (result.groupData!.isNotEmpty &&
  //       //     result.groupData![0].isActive == true) {
  //       //   TrackingController.instance.setActiveGroup(
  //       //     result.groupData![0].id.toString(),
  //       //     Global.storageServices.get(PrefConst.userId).toString(),
  //       //   );
  //       // }
  //     } else {
  //       Utils().fluttertoast(result.message.toString());
  //     }
  //   } catch (e) {
  //     Utils().fluttertoast(e.toString());
  //   }
  // }

  Future<void> updateGroup(GroupController controller,
      {required String groupId, required String groupStatus}) async {
    try {
      Loading().showloading();
      dynamic param = {
        "groupId": groupId,
        "isActiveGroup": groupStatus,
      };
      var result = await GroupRepo.updateGroupStatus(param);
      if (result.status == true) {
        Loading().dismissloading();
        Utils().fluttertoast(result.message.toString());
        controller.getGroupData();
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }
}
