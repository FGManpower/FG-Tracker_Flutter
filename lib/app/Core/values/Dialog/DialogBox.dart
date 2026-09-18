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
import '../../../Model/MemberDataRes.dart';
import '../../../global_widget/common_widget.dart';
import '../../../modules/auth/Auth_Widget/Auth_widget.dart';
import '../../../routes/app_pages.dart';
import '../../constant/pref_res.dart';
import '../../theme/AppText.dart';
import '../global.dart';
import 'Common_dialog.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';

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
    String? mobileNo,
    bool? isCreator,
    dynamic battery,
    required bool isGroupChat,
    required bool isLocationSharing,
  }) {
    final String memberName = (name != null &&
            name.trim().isNotEmpty &&
            name.toLowerCase() != 'null')
        ? name.trim()
        : 'Member';

    final String? rawImg = imageUrl?.toString();
    final String? profileUrl = (rawImg != null &&
            rawImg.trim().isNotEmpty &&
            rawImg.trim().toLowerCase() != 'null')
        ? (rawImg.trim().startsWith('http://') ||
                rawImg.trim().startsWith('https://')
            ? rawImg.trim()
            : (ConstRes.aImageBaseUrl.endsWith('/') &&
                    rawImg.trim().startsWith('/')
                ? "${ConstRes.aImageBaseUrl}${rawImg.trim().substring(1)}"
                : (!ConstRes.aImageBaseUrl.endsWith('/') &&
                        !rawImg.trim().startsWith('/')
                    ? "${ConstRes.aImageBaseUrl}/${rawImg.trim()}"
                    : "${ConstRes.aImageBaseUrl}${rawImg.trim()}")))
        : null;

    final bool isOnline = status == true ||
        (lastSeen != null &&
            (lastSeen.toLowerCase() == "just now" ||
                lastSeen.toLowerCase() == "online" ||
                lastSeen.toLowerCase() == "true"));

    String lastSeenText = "Offline";
    if (isLocationSharing == false) {
      lastSeenText = "Ghost Mode Enabled";
    } else if (isOnline) {
      lastSeenText = "Online";
    } else if (lastSeen != null &&
        lastSeen.trim().isNotEmpty &&
        lastSeen.toLowerCase() != 'null') {
      final parsed = Tracking.parseDateTime(lastSeen);
      if (parsed != null) {
        try {
          lastSeenText = "Last seen: ${Tracking().getTimeAgo(parsed)}";
        } catch (_) {
          lastSeenText = "Last seen: $lastSeen";
        }
      } else {
        lastSeenText = lastSeen.toLowerCase() == 'offline'
            ? "Offline"
            : "Last seen: $lastSeen";
      }
    }

    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';
    final String memberUserId = (userId ?? id ?? '').toString();
    final bool isMe = memberUserId == currentUserId;

    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppText.memberInfo,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96.w,
                      height: 96.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8E4FF),
                        border: Border.all(
                          color: isLocationSharing == false
                              ? const Color(0xFF7E57C2)
                              : (isOnline
                                  ? const Color(0xFF2BB673)
                                  : Colors.grey.shade300),
                          width: 3.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: profileUrl != null
                            ? Image.network(
                                profileUrl,
                                width: 96.w,
                                height: 96.w,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarFallback(memberName),
                              )
                            : _buildAvatarFallback(memberName),
                      ),
                    ),
                    Positioned(
                      bottom: 4.h,
                      right: 4.w,
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLocationSharing == false
                              ? const Color(0xFF7E57C2)
                              : (isOnline
                                  ? const Color(0xFF2BB673)
                                  : Colors.grey.shade400),
                          border: Border.all(color: Colors.white, width: 2.5.w),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      memberName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (isCreator == true) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F8EC),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "Admin",
                        style: TextStyle(
                          color: const Color(0xFF2BB673),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                  if (isMe) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: ToggleThemeData.Appcolor.withOpacity(0.12),
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
              Text(
                lastSeenText,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isOnline ? FontWeight.w600 : FontWeight.w400,
                  color: isLocationSharing == false
                      ? const Color(0xFF7E57C2)
                      : (isOnline
                          ? const Color(0xFF2BB673)
                          : Colors.grey.shade600),
                ),
              ),
              if ((mobileNo != null &&
                      mobileNo.trim().isNotEmpty &&
                      mobileNo.trim().toLowerCase() != 'null') ||
                  (battery != null &&
                      battery.toString().trim().isNotEmpty &&
                      battery.toString().toLowerCase() != 'null')) ...[
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (mobileNo != null &&
                        mobileNo.trim().isNotEmpty &&
                        mobileNo.trim().toLowerCase() != 'null') ...[
                      Icon(
                        Icons.phone_iphone_rounded,
                        size: 15.sp,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        mobileNo.trim(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (mobileNo != null &&
                        mobileNo.trim().isNotEmpty &&
                        mobileNo.trim().toLowerCase() != 'null' &&
                        battery != null &&
                        battery.toString().trim().isNotEmpty &&
                        battery.toString().toLowerCase() != 'null') ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text("•",
                            style: TextStyle(color: Colors.grey.shade400)),
                      ),
                    ],
                    if (battery != null &&
                        battery.toString().trim().isNotEmpty &&
                        battery.toString().toLowerCase() != 'null') ...[
                      Icon(
                        Icons.battery_charging_full_rounded,
                        size: 15.sp,
                        color: const Color(0xFF10B981),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "${battery.toString().replaceAll('%', '')}%",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (isLocationSharing != false && distance > 0) ...[
                SizedBox(height: 14.h),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xffA8A3DC).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: ToggleThemeData.darkPurple,
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "${AppText.distance}${distance.toStringAsFixed(2)} Km away",
                        style: TextStyle(
                          color: ToggleThemeData.darkPurple,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              if (!isMe) ...[
                Row(
                  children: [
                    Expanded(
                      child: _dialogActionButton(
                        title: "Chat",
                        icon: Icons.chat_bubble_outline_rounded,
                        color: ToggleThemeData.Appcolor,
                        onTap: () {
                          Navigator.pop(ctx);
                          if (Get.isRegistered<MessageController>()) {
                            Get.delete<MessageController>(force: true);
                          }
                          final MemberData memberData = MemberData(
                            id: id,
                            userId: userId,
                            groupId: 0,
                            name: memberName,
                            profileImage: rawImg,
                            mobileNo: mobileNo,
                            lastSeen: lastSeen,
                            isOnline: isOnline,
                          );

                          Get.toNamed(
                            Routes.chatScreen,
                            arguments: {
                              "userData": memberData,
                              "groupName": memberName,
                              "isCreator": false,
                              "type": "chatScreen",
                              "chatType": "private",
                              "groupId": 0,
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _dialogActionButton(
                        title: "Audio",
                        icon: Icons.call_outlined,
                        color: const Color(0xFF2BB673),
                        onTap: () {
                          Navigator.pop(ctx);
                          if (Get.isRegistered<CallingController>()) {
                            Get.delete<CallingController>(force: true);
                          }
                          Get.toNamed(
                            Routes.callScreen,
                            arguments: {
                              "callerId": currentUserId,
                              "remoteUserId": memberUserId,
                              "callerName": memberName,
                              "callerProfile": profileUrl ?? rawImg ?? "",
                              "offer": null,
                              "is_video": false,
                              "callType": "outGoing",
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _dialogActionButton(
                        title: "Video",
                        icon: Icons.videocam_outlined,
                        color: Colors.redAccent,
                        onTap: () {
                          Navigator.pop(ctx);
                          if (Get.isRegistered<CallingController>()) {
                            Get.delete<CallingController>(force: true);
                          }
                          Get.toNamed(
                            Routes.callScreen,
                            arguments: {
                              "callerId": currentUserId,
                              "remoteUserId": memberUserId,
                              "callerName": memberName,
                              "callerProfile": profileUrl ?? rawImg ?? "",
                              "offer": null,
                              "is_video": true,
                              "callType": "outGoing",
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],
              if (isLocationSharing != false) ...[
                SizedBox(
                  width: double.infinity,
                  child: reausablebutton(
                    title: "Focus on Map",
                    icon: Icons.my_location_rounded,
                    fontSize: 16,
                    borderradiues: 50.r,
                    iconSize: 20.sp,
                    iconColor: Colors.white,
                    textcolor: Colors.white,
                    height: 52,
                    ontap: () {
                      Navigator.pop(ctx);
                      if (Get.currentRoute == Routes.LocationTracking) {
                        TrackingController.instance.searchUserAndZoom(
                          groupId?.toString() ?? "0",
                          memberUserId,
                        );
                      } else {
                        Get.toNamed(
                          Routes.LocationTracking,
                          arguments: {
                            "groupId": groupId,
                            "groupName": groupName,
                            "targetUserId": memberUserId,
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildAvatarFallback(String name) {
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : "?";
    return Container(
      color: const Color(0xFFE8E4FF),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: ToggleThemeData.Appcolor,
          fontWeight: FontWeight.w800,
          fontSize: 34.sp,
        ),
      ),
    );
  }

  static Widget _dialogActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
