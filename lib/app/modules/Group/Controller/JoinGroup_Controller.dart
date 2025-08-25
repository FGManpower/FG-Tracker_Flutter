import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';

import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Group/Controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/Views/QRScanScreen.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../Data/Services/LocationPermission.dart';

class JoinGroupController extends GetxController {
  GlobalKey<FormState> joinGroupKey = GlobalKey<FormState>();
  final groupCodeController = TextEditingController();

  RxBool memberDataLoading = false.obs;
  var memberData = <MemberData>[].obs;
  var responseError = "".obs;
  // Map<String, dynamic>? arguments = Get.arguments;

  Future<void> decodeQRCodeFromGallery(
    BuildContext context, {
    required GroupController groupController,
    String? type,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final barcodeScanner = BarcodeScanner();

      try {
        final barcodes = await barcodeScanner.processImage(inputImage);
        for (final barcode in barcodes) {
          final groupCode = barcode.rawValue;
          if (groupCode != null && groupCode.isNotEmpty) {
            // Use the same joinGroup logic
            await joinGroup(
              context,
              groupController: groupController,
              groupCode: groupCode,
              type: type ?? "Qr",
            );
            break; // Stop after the first valid QR code
          }
        }
      } catch (e) {
        CommonDialog.errorMessage("Failed to process image: $e");
      } finally {
        await barcodeScanner.close();
      }
    }
  }


  Future<void> scanQRCodeFromCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final scannedResult = await Get.to(() => QRScanScreen());
      if (scannedResult != null) {
        print("QR Code: $scannedResult");
      }
    } else {
      Get.snackbar(
          "Permission Denied", "Camera access is needed to scan QR codes");
    }
  }

  Future<bool> joinGroup(
    BuildContext context, {
    required GroupController groupController,
    required String groupCode,
    bool validateForm = true,
    String? type,
  }) async {
    final hasPermission =
        await  LocationPermissions().handleLocationPermission();
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

  Future<void> getMembersData(String groupId) async {
    try {
      memberDataLoading.value = true;
      var result = await GroupRepo.getMemberData(groupId);
      if (result.status == true) {
        memberData.value = result.memberData!;
        responseError.value = "";
        memberDataLoading.value = false;
      } else {
        memberDataLoading.value = false;
        responseError.value = result.message.toString();
      }
    } catch (e) {
      responseError.value = e.toString();
      memberDataLoading.value = false;
    }
  }

  Future<void> exitGroup(
    BuildContext context, {
    required String groupId,
  }) async {
    try {
      Loading().showloading();
      dynamic param = {
        "groupId": groupId,
      };
      var result = await GroupRepo.exitGroups(param);
      if (result.status == true) {
        Loading().dismissloading();
        leaveGroup(context, groupId: groupId);
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }

  Future<void> deleteGroup(
    BuildContext context, {
    required String groupId,
  }) async {
    try {
      Loading().showloading();
      dynamic param = {
        "groupId": groupId,
      };
      var result = await GroupRepo.deleteGroups(param);
      if (result.status == true) {
        Loading().dismissloading();
        deleteGroupSocket(context, groupId: groupId);
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }

  void leaveGroup(
    BuildContext context, {
    required String groupId,
  }) async {

    TrackingController.instance.exitGroup(
      groupId: groupId,
      onCompletion: (success) {
        if (success) {
          Utils().fluttertoast("Group Exit successfully");
          Get.offAllNamed(Routes.Home_Screen);
        }
      },
    );
  }

  void deleteGroupSocket(
    BuildContext context, {
    required String groupId,
  }) async {

    TrackingController.instance.deleteGroup(
      groupId: groupId,
      onCompletion: (success) {
        if (success) {
          Utils().fluttertoast("Group deleted successfully");
          Get.offAllNamed(Routes.Home_Screen);
        }
      },
    );
  }
}
