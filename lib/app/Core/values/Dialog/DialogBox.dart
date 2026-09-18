import 'dart:developer';
import 'dart:io';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/util/validator.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
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
        return SafeArea(
            child: Padding(
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

  void showUpdateGroupBottomSheet(
      {required BuildContext context,
      required GroupController controller,
      required String groupId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
            child: Padding(
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
                  reausabletext(AppText.updateGroup,
                      fontsize: 18.sp, fontfamily: FontFamily.interSemiBold),
                  SizedBox(height: 20.h),
                  inputField(
                    context,
                    title: AppText.groupName,
                    maxLength: 50,
                    maxLines: 1,
                    textctr: controller.groupName,
                    validators: (value) =>
                        Validator.validate(value: value, title: "Group Name"),
                  ),
                  SizedBox(height: 25.h),
                  reausablebutton(
                    title: "Update",
                    ontap: () async {
                      if (controller.createGroupKey.currentState!.validate()) {
                        controller.updateGroupDetail(groupId: groupId);
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
        return SafeArea(
            child: Padding(
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
                    SizedBox(height: 10.h),
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
                    SizedBox(height: 20.h),
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
      selectedTileColor: const Color(0xff5045B9).withValues(alpha: 0.15),
      hoverColor: const Color(0xff5045B9).withValues(alpha: 0.1),
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
    String? lastSeen,
    String? groupName,
    required bool isGroupChat,
    required bool isLocationSharing,
  }) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';
    final bool isMe = userId != null && userId.toString() == currentUserId;

    final bool isOnline = status == true ||
        Tracking().isOnline(
          rawIsOnline: status,
          lastSeen: lastSeen,
          thresholdMinutes: 5,
        );

    final String resolvedImageUrl = (imageUrl != null &&
            imageUrl.trim().isNotEmpty &&
            imageUrl.trim().toLowerCase() != 'null')
        ? (imageUrl.trim().startsWith('http://') ||
                imageUrl.trim().startsWith('https://')
            ? imageUrl.trim()
            : ConstRes.aImageBaseUrl + imageUrl.trim())
        : MyAppTheme.ProfilenotFoundImg;

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
              Container(
                width: 95.r,
                height: 95.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ToggleThemeData.darkPurple.withValues(alpha: 0.15),
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: resolvedImageUrl,
                    width: 95.r,
                    height: 95.r,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: ToggleThemeData.darkPurple.withValues(alpha: 0.08),
                      child: Icon(
                        Icons.person,
                        size: 48.sp,
                        color: ToggleThemeData.darkPurple,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: reausabletext(
                      name ?? AppText.member,
                      fontsize: 18.sp,
                      fontfamily: FontFamily.interBold,
                      fontweight: FontWeight.w700,
                      color: Colors.black87,
                      align: TextAlign.center,
                    ),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: ToggleThemeData.Appcolor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "You",
                        style: TextStyle(
                          color: ToggleThemeData.Appcolor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 4.h),
              reausabletext(
                isLocationSharing == false
                    ? "Private"
                    : isOnline
                        ? "Online"
                        : "Offline",
                fontsize: 12.sp,
                fontfamily: FontFamily.interMedium,
                color: isLocationSharing == false
                    ? Colors.grey
                    : (isOnline ? Colors.green : const Color(0xffFF6B6B)),
              ),
              if (!isOnline &&
                  isLocationSharing &&
                  Utility.isNotNullEmptyOrFalse(lastSeen))
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: reausabletext(
                    "${AppText.lastSeen}${Tracking().getTimeAgo(Tracking.parseDateTime(lastSeen) ?? DateTime.now())}",
                    fontsize: 12.sp,
                    fontfamily: FontFamily.interRegular,
                    color: Colors.grey.shade600,
                  ),
                ),
              if (isLocationSharing) ...[
                SizedBox(height: 18.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: const Color(0xffF2F0FB),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: ToggleThemeData.darkPurple,
                        size: 22.sp,
                      ),
                      SizedBox(width: 8.w),
                      reausabletext(
                        "${AppText.distance}${distance.toStringAsFixed(2)} Km",
                        fontsize: 16.sp,
                        fontfamily: FontFamily.interSemiBold,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
              if (!isMe) ...[
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
                          if (Get.isRegistered<MessageController>()) {
                            Get.delete<MessageController>(force: true);
                          }
                          final MemberData memberData = MemberData(
                            id: id ?? userId,
                            userId: userId ?? id,
                            groupId: groupId ?? 0,
                            name: name ?? "Member",
                            profileImage: imageUrl ?? resolvedImageUrl,
                            lastSeen: lastSeen,
                            isOnline: isOnline,
                            locationSharing: isLocationSharing,
                          );

                          Navigator.pop(ctx);

                          Get.toNamed(
                            Routes.chatScreen,
                            arguments: {
                              "userData": memberData,
                              "groupName": name ?? "Chat",
                              "isCreator": false,
                              "type": "chatScreen",
                              "chatType": "private",
                              "groupId": groupId ?? 0,
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
                                padding: EdgeInsets.fromLTRB(
                                    20.w, 12.h, 20.w, 24.h),
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
                                        borderRadius:
                                            BorderRadius.circular(20.r),
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

                                        if (Get.isRegistered<
                                            CallingController>()) {
                                          Get.delete<CallingController>(
                                              force: true);
                                        }

                                        Get.toNamed(
                                          Routes.callScreen,
                                          arguments: {
                                            "callerId": currentUserId,
                                            "remoteUserId":
                                                (userId ?? id ?? "").toString(),
                                            "callerName": name ?? "Member",
                                            "callerProfile": resolvedImageUrl,
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
                                        borderRadius:
                                            BorderRadius.circular(7.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(12.r),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: ToggleThemeData.darkPurple
                                                  .withValues(alpha: 0.12),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                reausabletext(
                                                  "Audio Call",
                                                  fontsize: 16,
                                                  fontfamily:
                                                      FontFamily.interSemiBold,
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

                                        if (Get.isRegistered<
                                            CallingController>()) {
                                          Get.delete<CallingController>(
                                              force: true);
                                        }

                                        Get.toNamed(
                                          Routes.callScreen,
                                          arguments: {
                                            "callerId": currentUserId,
                                            "remoteUserId":
                                                (userId ?? id ?? "").toString(),
                                            "callerName": name ?? "Member",
                                            "callerProfile": resolvedImageUrl,
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
                                          borderRadius:
                                              BorderRadius.circular(18.r),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(12.r),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: ToggleThemeData.darkPurple
                                                    .withValues(alpha: 0.12),
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  reausabletext(
                                                    "Video Call",
                                                    fontsize: 16,
                                                    fontfamily:
                                                        FontFamily.interSemiBold,
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
              ],
              SizedBox(height: 14.h),
              (isLocationSharing == false || isMe)
                  ? const SizedBox()
                  : reausablebutton(
                      title: AppText.getDirections,
                      icon: Icons.directions,
                      fontSize: 18,
                      borderradiues: 50.r,
                      iconSize: 22.sp,
                      iconColor: Colors.white,
                      textcolor: Colors.white,
                      height: 55,
                      ontap: () {
                        Navigator.pop(ctx);
                        if (destination.latitude != 0.0 &&
                            destination.longitude != 0.0) {
                          final Uri mapsUri = Uri.parse(
                            "https://www.google.com/maps/dir/?api=1"
                            "&destination=${destination.latitude},${destination.longitude}"
                            "&travelmode=walking",
                          );
                          launchUrl(
                            mapsUri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else if (Get.currentRoute == Routes.LocationTracking) {
                          TrackingController.instance.searchUserAndZoom(
                            (groupId ?? 0).toString(),
                            (userId ?? '').toString(),
                          );
                        } else if (isGroupChat) {
                          Get.toNamed(
                            Routes.LocationTracking,
                            arguments: {
                              "groupId": groupId,
                              "groupName": groupName,
                              "targetUserId": userId.toString(),
                            },
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
