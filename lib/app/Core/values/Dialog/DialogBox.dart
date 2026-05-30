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
import 'package:fgtracker/app/modules/Group/controller/JoinGroup_Controller.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../Model/MemberDataRes.dart';
import '../../../global_widget/common_widget.dart';

import '../../../modules/auth/Auth_Widget/Auth_widget.dart';
import '../../../routes/app_pages.dart';
import '../../constant/pref_res.dart';
import '../../theme/AppText.dart';
import '../global.dart';
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
        return SafeArea(child: Padding(
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
                  reausabletext(AppText.createNewGroup,
                      fontsize: 18.sp, fontfamily: FontFamily.interSemiBold),
                  SizedBox(height: 20.h),

                  inputField(
                    context,
                    title: AppText.groupName,
                    maxLength: 50,
                    maxLines: 1,
                    hintname: AppText.enterGroupName,
                    textctr: controller.groupName,
                    validators: (value) =>
                        Validator.validate(value: value, title: "Group Name"),
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
                  // SizedBox(height: 12.h),
                  // InputField(
                  //   title: AppText.groupDescription,
                  //   maxLength: 60,
                  //   hintText: AppText.entGroupDescription,
                  //   controller: controller.groupDesc,
                  //   maxLines: 3,
                  //   validator: (value) => value == null || value.isEmpty
                  //       ? AppText.entGroupDescriptionCnntBeEmpty
                  //       : null,
                  // ),
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
        ));
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
        return SafeArea(child: Padding(
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
                    textCapitalization: TextCapitalization.characters,
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
        ));
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
        return SafeArea(child: LayoutBuilder(
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
        ));
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
    int? userId,
    int? groupId,
    int? id,
    String? name,
    String? imageUrl,
    bool? status,
    String? lastSeen, String? groupName, required bool isGroupChat,
  }) {
    bool isOnline = status == true || (lastSeen?.toLowerCase() == "just now");

    showModalBottomSheet(
      context: Get.context!,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        builder: (ctx) => SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 24.h,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    reausabletext(
                      AppText.memberInfo,
                      fontsize: 20,
                      fontweight: FontWeight.w700,
                      align: TextAlign.center,
                    ),
                    SizedBox(height: 15.h),
                    CircleAvatar(
                      radius: 55.r,
                      backgroundImage: NetworkImage(
                        Utility.isNotNullEmptyOrFalse(imageUrl)
                            ? ConstRes.aImageBaseUrl + imageUrl!
                            : MyAppTheme.notFoundImg,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    reausabletext(
                      name ?? AppText.member,
                      fontsize: 16.sp,
                      fontfamily: FontFamily.interMedium,
                      color: Colors.black87,
                      align: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    reausabletext(
                      isOnline ? "Online" : "Offline",
                      fontsize: 12.sp,
                      color: isOnline ? Colors.green : Colors.red,
                      fontfamily: FontFamily.interMedium,
                    ),
                    if (!isOnline && Utility.isNotNullEmptyOrFalse(lastSeen))
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: reausabletext(
                          "${AppText.lastSeen}$lastSeen",
                          fontsize: 10.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    SizedBox(height: 24.h),
                    if (!isGroupChat) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: const Color(0xffA8A3DC).withOpacity(0.16),
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            reausableIcon(
                              icon: Icons.location_on_outlined,
                              color: ToggleThemeData.darkPurple,
                              size: 22.sp,
                            ),
                            SizedBox(width: 8.w),
                            reausabletext(
                              "${AppText.distance}${distance.toStringAsFixed(2)} Km",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Expanded(
                          child: reausablebutton(
                            title: "Chat",
                            fontSize: 17,
                            borderradiues: 50.r,
                            icon: Icons.chat_bubble_outline,
                            iconSize: 20.sp,
                            iconColor: Colors.white,
                            textcolor: Colors.white,
                            height: 55,
                            ontap: () {

                              final MemberData memberData = MemberData(
                                id: id,
                                userId: userId,
                                groupId: groupId ?? 0,
                                name: name,
                                profileImage: imageUrl,
                                lastSeen: lastSeen,
                                isOnline: status,
                              );

                              Navigator.pop(ctx);

                              Get.toNamed(
                                Routes.chatScreen,
                                arguments: {
                                  "userData": memberData,
                                  "groupName": "Members Chat",
                                  "isCreator": false,
                                  "type": "",
                                },
                              );
                            },
                          ),
                        ),

                        SizedBox(width: 12.w),
                        Expanded(
                          child: reausablebutton(
                            title: "Call",
                            fontSize: 17,
                            borderradiues: 50.r,
                            icon: Icons.call,
                            iconSize: 20.sp,
                            iconColor: Colors.white,
                            textcolor: Colors.white,
                            height: 55,
                            ontap: () {
                              showModalBottomSheet(
                                context: ctx,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24.r),
                                  ),
                                ),
                                builder: (_) {
                                  return Container(
                                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(28.r),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 45.w,
                                          height: 5.h,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(20.r),
                                          ),
                                        ),

                                        SizedBox(height: 20.h),

                                        reausabletext(
                                          "Select Call Type",
                                          fontsize: 20,
                                          fontweight: FontWeight.w700,
                                          color: Colors.black,
                                        ),

                                        SizedBox(height: 22.h),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            Navigator.pop(ctx);

                                            Get.toNamed(
                                              Routes.callScreen,
                                              arguments: {
                                                "callerId": Global.storageServices
                                                    .get(PrefConst.userId)
                                                    .toString(),
                                                "remoteUserId": userId?.toString() ?? "",
                                                "callerName": name ?? "",
                                                "offer": null,
                                                "is_video": false,
                                                "callType": "outGoing",
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 14.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffF6F4FF),
                                              borderRadius: BorderRadius.circular(7.r),
                                            ),
                                            child: Row(
                                              children: [

                                                Container(
                                                  padding: EdgeInsets.all(12.r),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: ToggleThemeData.darkPurple.withOpacity(0.12),
                                                  ),
                                                  child: Icon(
                                                    Icons.call,
                                                    color: ToggleThemeData.darkPurple,
                                                    size: 22.sp,
                                                  ),
                                                ),

                                                SizedBox(width: 16.w),

                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      reausabletext(
                                                        "Audio Call",
                                                        fontsize: 16,
                                                        fontfamily: FontFamily.interSemiBold,
                                                      ),

                                                      SizedBox(height: 2.h),

                                                      reausabletext(
                                                        "Start voice conversation",
                                                        fontsize: 11,
                                                        color: Colors.black54,
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: 16.sp,
                                                  color: Colors.black45,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 14.h),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            Navigator.pop(ctx);

                                            Get.toNamed(
                                              Routes.callScreen,
                                              arguments: {
                                                "callerId": Global.storageServices
                                                    .get(PrefConst.userId)
                                                    .toString(),
                                                "remoteUserId": userId.toString(),
                                                "callerName": name ?? "",
                                                "offer": null,
                                                "is_video": true,
                                                "callType": "outGoing",
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 14.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffF6F4FF),
                                              borderRadius: BorderRadius.circular(18.r),
                                            ),
                                            child: Row(
                                              children: [

                                                Container(
                                                  padding: EdgeInsets.all(12.r),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: ToggleThemeData.darkPurple.withOpacity(0.12),
                                                  ),
                                                  child: Icon(
                                                    Icons.videocam_rounded,
                                                    color: ToggleThemeData.darkPurple,
                                                    size: 22.sp,
                                                  ),
                                                ),

                                                SizedBox(width: 16.w),

                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      reausabletext(
                                                        "Video Call",
                                                        fontsize: 16,
                                                        fontfamily: FontFamily.interSemiBold,
                                                      ),

                                                      SizedBox(height: 2.h),

                                                      reausabletext(
                                                        "Start video conversation",
                                                        fontsize: 11,
                                                        color: Colors.black54,
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: 16.sp,
                                                  color: Colors.black45,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15.h),
                    reausablebutton(
                      title: isGroupChat ? "Track" : AppText.getDirections,
                      icon: isGroupChat
                          ? Icons.track_changes
                          : Icons.directions,
                      fontSize: 19,
                      borderradiues: 50.r,
                      iconSize: 23.sp,
                      iconColor: Colors.white,
                      textcolor: Colors.white,
                      height: 58,
                      ontap: () {

                        if (isGroupChat) {

                          Navigator.pop(ctx);

                          Get.toNamed(
                            Routes.LocationTracking,
                            arguments: {
                              "groupId": groupId,
                              "groupName": groupName,
                              "targetUserId": userId.toString(),
                            },
                          );

                        } else {

                          final Uri mapsUri = Uri.parse(
                            "https://www.google.com/maps/dir/?api=1"
                                "&destination=${destination.latitude},${destination.longitude}"
                                "&travelmode=walking",
                          );

                          launchUrl(
                            mapsUri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
    ],

              ),
            ),
        ),
    );
  }
}
