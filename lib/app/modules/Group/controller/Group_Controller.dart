import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';


class GroupController extends GetxController {
  GlobalKey<FormState> createGroupKey = GlobalKey<FormState>();
  final groupName = TextEditingController();
  final groupDesc = TextEditingController();
  RxBool groupDataLoading = false.obs;
  var newlyCreatedGroups = <GroupsResData>[].obs;
  var createdGroups = <GroupsResData>[].obs;
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

  Future<void> updateGroupDetail({required String groupId}) async {

    try {
      Loading().showloading();
      dynamic param = {
        "groupName": groupName.text,
        "groupId": groupId,
      };
      var result = await GroupRepo.updateGroup(param);
      if (result.status == true) {

        Loading().dismissloading();
        Get.offAllNamed(Routes.Home_Screen);


      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }

  Future<void> getGroupData({String? type}) async {
    try {
      groupDataLoading.value = true;
      var result = await GroupRepo.getGroupData();
      if (result.status == true) {
        newlyCreatedGroups.value = result.data!.newlyCreatedGroups!;
        createdGroups.value = result.data!.createdGroups!;
        responseError.value = "";
        groupDataLoading.value = false;
        try{
          List<GroupsResData> groupData =[];
          groupData.addAll(newlyCreatedGroups);
          groupData.addAll(createdGroups);


          TrackingController.instance.inItAllGroups(groups: groupData);

        }catch(e){
          debugPrint("error in inItAllGroups:${e}");
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

  Future<void> deleteGroupMember(
      BuildContext context, {
        required String groupId,
        required String groupMemberId,
      }) async {
    try {
      Loading().showloading();
      dynamic param = {
        "groupId": groupId,
        "groupMemberId": groupMemberId,
      };
      var result = await GroupRepo.deleteGroupsMember(param);
      if (result.status == true) {
        Loading().dismissloading();
        MemberController().leaveGroup(context, groupId: groupId);
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
