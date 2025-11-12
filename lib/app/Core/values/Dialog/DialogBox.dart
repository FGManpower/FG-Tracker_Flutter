import 'dart:developer';
import 'dart:io';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/util/validator.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/bottomSheet.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/input_widget.dart';
import 'package:fgtracker/app/modules/Group/Controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/Controller/JoinGroup_Controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../global_widget/common_widget.dart';
import '../../../modules/auth/Auth_Widget/Auth_widget.dart';
import '../../theme/AppText.dart';
import 'Common_dialog.dart';

class DialogBox {
  void showCreateGroupBottomSheet({
    required BuildContext context,
    required GroupController controller,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20.h,
            left: 20.w,
            right: 20.w,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: controller.createGroupKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  reausabletext(
                    AppText.createNewGroup,
                    fontsize: 18.sp,
                   fontfamily: FontFamily.interSemiBold
                  ),
                  SizedBox(height: 20.h),

                  inputField(
                    context,
                    title: AppText.groupName,
                    maxLength: 50,
                    maxLines: 1,
                    hintname: AppText.enterGroupName,
                    textctr: controller.groupName,
                    validators: (value) => Validator.validate(
                        value: value, title: "Group Name"),
                  ),
                  // InputField(
                  //   title: AppText.groupName,
                  //   maxLength: 50,
                  //   hintText: AppText.enterGroupName,
                  //   controller: controller.groupName,
                  //   validator: (value) => value == null || value.isEmpty
                  //       ? AppText.groupNameCnntEmpty
                  //       : null,
                  // ),
                  SizedBox(height: 12.h),
                  InputField(
                    title: AppText.groupDescription,
                    maxLength: 60,
                    hintText: AppText.entGroupDescription,
                    controller: controller.groupDesc,
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? AppText.entGroupDescriptionCnntBeEmpty
                        : null,
                  ),
                  SizedBox(height: 25.h),
                  reausablebutton(
                    title: "Done",
                    ontap: () async {
                      if (controller.createGroupKey.currentState!.validate()) {
                        bool isCreated = await controller.createGroup(
                          context,
                          controller: controller,
                        );

                        if (isCreated) {
                          Navigator.pop(context);
                          controller.groupName.clear();
                          controller.groupDesc.clear();
                        }
                      }
                    },
                    borderradiues: 50.r,
                  ),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showGroupCodeBottomSheet(
      {required BuildContext context,
      required JoinGroupController controller,
      required GroupController groupController}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20.h,
            left: 20.w,
            right: 20.w,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: controller.joinGroupKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  reausabletext(
                    AppText.enterGroupCode,
                    fontsize: 20.sp,
                    fontweight: FontWeight.bold,
                  ),
                  SizedBox(height: 20.h),
                  InputField(
                    title: AppText.groupCode,
                    hintText: AppText.enterGroupCode,

                    controller: controller.groupCodeController,
                    maxLength: 6,
                    textCapitalization: TextCapitalization
                        .characters,
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                    ],
                    validator: (value) => value == null || value.isEmpty
                        ? AppText.groupCodeCannotBeEmpty
                        : null,
                  ),
                  SizedBox(height: 25.h),
                  reausablebutton(
                    title: AppText.joinGroup,
                    ontap: () async {
                      if (controller.joinGroupKey.currentState!.validate()) {
                        bool isJoined = await controller.joinGroup(context,
                            groupController: groupController,
                            groupCode: controller.groupCodeController.text);
                        if (isJoined) {
                          controller.groupCodeController.clear();
                        }
                      }
                    },
                    borderradiues: 50.r,
                  ),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  showQRScanOptions(BuildContext context,
      {required JoinGroupController controller,
      required GroupController groupController}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 25),
                    _buildOptionTile(
                      title: AppText.scanFromCamera,
                      icon: Icons.qr_code_scanner,
                      onTap: () {
                        Navigator.pop(context);
                        controller.scanQRCodeFromCamera();
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildOptionTile(
                      title: AppText.uploadFromGallery,
                      icon: Icons.photo_library,
                      onTap: () {
                        Navigator.pop(context);

                        ModalImage bottomNavbar = ModalImage(
                          isImageCroppable: false,
                          onImageSelect: (path) async {
                            if (Utility.isNotNullEmptyOrFalse(path)) {
                              File imageFile = File(path);
                              log("${AppText.imagePicked}${imageFile.path}");

                              try {
                                final inputImage =
                                    InputImage.fromFilePath(imageFile.path);
                                final barcodeScanner = BarcodeScanner();
                                final barcodes = await barcodeScanner
                                    .processImage(inputImage);

                                if (barcodes.isNotEmpty) {
                                  final groupCode = barcodes.first.rawValue;
                                  if (groupCode != null &&
                                      groupCode.isNotEmpty) {
                                    await controller.joinGroup(
                                      context,
                                      groupController: groupController,
                                      groupCode: groupCode,
                                      type: "Qr",
                                    );
                                  } else {
                                    CommonDialog.errorMessage(
                                        AppText.noValidQrCodeFound);
                                  }
                                } else {
                                  CommonDialog.errorMessage(
                                      AppText.noQrFoundCodeFound);
                                }

                                await barcodeScanner.close();
                              } catch (e) {
                                CommonDialog.errorMessage(
                                    "${AppText.errorDecodingQrFromGallery}$e");
                              }
                            }
                          },
                        );

                        bottomNavbar.mainBottomSheet(context,
                            groupType: "joinGroup");
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildOptionTile(
                      title: AppText.enterGroupCodeManually,
                      icon: Icons.keyboard,
                      onTap: () {
                        Navigator.pop(context);
                        DialogBox().showGroupCodeBottomSheet(
                            context: context,
                            controller: controller,
                            groupController: groupController);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      splashColor: ToggleThemeData.Appcolor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.r),
      ),
      tileColor: ToggleThemeData.darkPurple,
      selectedTileColor: const Color(0xff5045B9).withOpacity(0.15),
      hoverColor: const Color(0xff5045B9).withOpacity(0.1),
      leading: Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: Icon(icon, color: Colors.white, size: 26.sp),
      ),
      title: Padding(
        padding: EdgeInsets.only(right: 30.w),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            color: ToggleThemeData.white,
            fontFamily: FontFamily.interSemiBold,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  void showRouteDetailsBottomSheet({
    required LatLng destination,
    required double distance,
    String? name,
    String? imageUrl,
    bool? status,
    String? lastSeen,
  }) {
    bool isOnline = lastSeen == "Just now";
    showModalBottomSheet(
      context: ContextUtility.context!,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 24.h,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                reausabletext(AppText.memberInfo,
                    fontsize: 18.sp, fontweight: FontWeight.bold),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, size: 28.sp),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                CircleAvatar(
                    radius: 30.r,
                    backgroundImage: NetworkImage(
                      Utility.isNotNullEmptyOrFalse(imageUrl)
                          ? ConstRes.aImageBaseUrl + imageUrl!
                          : MyAppTheme.notFoundImg,
                    )),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reausabletext(name ?? AppText.member,
                          fontsize: 18.sp, fontweight: FontWeight.bold),
                      SizedBox(height: 4.h),
                      Text(
                        isOnline ? "Online" : "Offline",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      if (!isOnline)
                        reausabletext(
                          "${AppText.lastSeen}$lastSeen",
                          fontsize: 12.sp,
                          color: Colors.grey,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: Colors.blue, size: 20.sp),
                      SizedBox(width: 8.w),
                      reausabletext(
                          "${AppText.distance}${distance.toStringAsFixed(1)} km",
                          fontsize: 15.sp),
                    ],
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ToggleThemeData.Appcolor, // Deep Blue
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  final Uri mapsUri = Uri.parse(
                      "https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}&travelmode=walking");
                  launchUrl(mapsUri);
                },
                icon: Icon(Icons.directions, size: 22.sp, color: Colors.white),
                label: reausabletext(AppText.getDirections,
                    fontsize: 16.sp,
                    color: Colors.white,
                    fontweight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }
}
