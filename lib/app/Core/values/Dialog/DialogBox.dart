import 'dart:developer';
import 'dart:io';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/util/validator.dart';
import 'package:fgtracker/app/Core/values/bottomSheet.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/input_widget.dart';
import 'package:fgtracker/app/modules/Group/controller/JoinGroup_Controller.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackingController.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/GroupTrackController.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/Model/UsersWithinRadiusRes.dart';
import 'package:fgtracker/app/modules/Messages/Views/UserProfileScreen.dart';
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

  static String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty ||
        trimmed.toLowerCase() == 'member' ||
        trimmed.toLowerCase() == 'null') {
      return '';
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '';
  }

  static Widget _buildProfileAvatar({
    required String? imageUrl,
    required String displayName,
    required double size,
  }) {
    final String initials = _getInitials(displayName);
    final fallbackWidget = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.36,
                  fontFamily: FontFamily.interBold,
                ),
              )
            : Icon(Icons.person, color: Colors.white, size: size * 0.5),
      ),
    );

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return fallbackWidget;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade100,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => fallbackWidget,
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
    String? phone,
    String? location,
    String? team,
    int? battery,
  }) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';
    final effectiveUserId = userId ?? id;
    final bool isMe = effectiveUserId != null &&
        effectiveUserId.toString().isNotEmpty &&
        effectiveUserId.toString() == currentUserId;

    String? resolvedName = (name != null &&
            name.trim().isNotEmpty &&
            name.trim().toLowerCase() != 'null' &&
            name.trim().toLowerCase() != 'member')
        ? name.trim()
        : null;

    String? resolvedImg = (imageUrl != null &&
            imageUrl.trim().isNotEmpty &&
            imageUrl.trim().toLowerCase() != 'null')
        ? imageUrl.trim()
        : null;

    String? resolvedPhone =
        (phone != null && phone.trim().isNotEmpty && phone.trim().toLowerCase() != 'null')
            ? phone.trim()
            : null;
    String? resolvedLocation =
        (location != null && location.trim().isNotEmpty && location.trim().toLowerCase() != 'null')
            ? location.trim()
            : null;
    String? resolvedTeam = (team != null && team.trim().isNotEmpty && team.trim().toLowerCase() != 'null')
        ? team.trim()
        : (groupName != null && groupName.trim().isNotEmpty && groupName.trim().toLowerCase() != 'null'
            ? groupName.trim()
            : null);
    int? resolvedBattery = battery;
    String? resolvedLastSeen = lastSeen;
    bool resolvedIsOnline = status == true;

    // 1. Current user resolution
    if (isMe) {
      final myName =
          Global.storageServices.get(PrefConst.userName)?.toString() ?? '';
      if (resolvedName == null && myName.trim().isNotEmpty) {
        resolvedName = myName.trim();
      }

      final myImg =
          Global.storageServices.get(PrefConst.profileImage)?.toString() ?? '';
      if (resolvedImg == null && myImg.trim().isNotEmpty && myImg.trim().toLowerCase() != 'null') {
        resolvedImg = myImg.trim();
      }

      final myPhone =
          Global.storageServices.get(PrefConst.userPhone)?.toString() ?? '';
      if (resolvedPhone == null && myPhone.trim().isNotEmpty) {
        resolvedPhone = myPhone.trim();
      }

      if (Get.isRegistered<TrackController>()) {
        final tc = Get.find<TrackController>();
        if (resolvedLocation == null &&
            tc.currentLocationName.value.isNotEmpty &&
            tc.currentLocationName.value != 'Locating...') {
          resolvedLocation = tc.currentLocationName.value;
        }
      }
      resolvedIsOnline = true;
    } else if (effectiveUserId != null) {
      // 2. Cross-reference other members across all registered controllers
      final uidStr = effectiveUserId.toString();

      // Check TrackController
      if (Get.isRegistered<TrackController>()) {
        final tc = Get.find<TrackController>();

        // Check radius users
        final rUser = tc.radiusUsers.firstWhereOrNull(
          (u) => u.userId?.toString() == uidStr,
        );
        if (rUser != null) {
          if (resolvedName == null &&
              rUser.name != null &&
              rUser.name!.trim().isNotEmpty &&
              rUser.name!.trim().toLowerCase() != 'member') {
            resolvedName = rUser.name!.trim();
          }
          if (resolvedImg == null &&
              rUser.profileImage != null &&
              rUser.profileImage!.trim().isNotEmpty &&
              rUser.profileImage!.trim().toLowerCase() != 'null') {
            resolvedImg = rUser.profileImage!.trim();
          }
          if (resolvedPhone == null &&
              rUser.mobileNo != null &&
              rUser.mobileNo!.trim().isNotEmpty) {
            resolvedPhone = rUser.mobileNo!.trim();
          }
          if (resolvedLocation == null &&
              rUser.location != null &&
              rUser.location!.trim().isNotEmpty) {
            resolvedLocation = rUser.location!.trim();
          }
          if (resolvedTeam == null &&
              rUser.team != null &&
              rUser.team!.trim().isNotEmpty) {
            resolvedTeam = rUser.team!.trim();
          }
          if (resolvedBattery == null || resolvedBattery == 0) {
            resolvedBattery = int.tryParse(rUser.battery?.toString() ?? '');
          }
          resolvedLastSeen ??= rUser.lastSeen;
          if (rUser.isOnline) resolvedIsOnline = true;
        }

        // Check onlineGroupMembers & allFetchedMembers
        final gMember = tc.onlineGroupMembers.firstWhereOrNull(
          (m) => m.userId?.toString() == uidStr,
        );
        if (gMember != null) {
          if (resolvedName == null &&
              gMember.name != null &&
              gMember.name!.trim().isNotEmpty &&
              gMember.name!.trim().toLowerCase() != 'member') {
            resolvedName = gMember.name!.trim();
          }
          if (resolvedImg == null &&
              gMember.profileImage != null &&
              gMember.profileImage!.trim().isNotEmpty &&
              gMember.profileImage!.trim().toLowerCase() != 'null') {
            resolvedImg = gMember.profileImage!.trim();
          }
          if (resolvedPhone == null &&
              gMember.mobileNo != null &&
              gMember.mobileNo!.trim().isNotEmpty) {
            resolvedPhone = gMember.mobileNo!.trim();
          }
          if (resolvedTeam == null &&
              gMember.department != null &&
              gMember.department!.trim().isNotEmpty) {
            resolvedTeam = gMember.department!.trim();
          }
          resolvedLastSeen ??= gMember.lastSeen;
          if (gMember.online) resolvedIsOnline = true;
        }

        final fMember = tc.allFetchedMembers.firstWhereOrNull(
          (m) => m.userId?.toString() == uidStr,
        );
        if (fMember != null) {
          if (resolvedName == null &&
              fMember.name.trim().isNotEmpty &&
              fMember.name.trim().toLowerCase() != 'member') {
            resolvedName = fMember.name.trim();
          }
          if (resolvedImg == null &&
              fMember.avatarUrl.trim().isNotEmpty &&
              fMember.avatarUrl.trim().toLowerCase() != 'null') {
            resolvedImg = fMember.avatarUrl.trim();
          }
          if (resolvedTeam == null && fMember.team.trim().isNotEmpty) {
            resolvedTeam = fMember.team.trim();
          }
        }

        // Check GroupTrackingController groupWiseUserData
        if (resolvedName == null || resolvedImg == null) {
          final trackingUserData = Get.isRegistered<GroupTrackingController>()
              ? Get.find<GroupTrackingController>().groupWiseUserData
              : GroupTrackingController.instance.groupWiseUserData;
          for (final list in trackingUserData.values) {
            final match = list.firstWhereOrNull(
              (l) => l.userId?.toString() == uidStr,
            );
            if (match != null) {
              if (resolvedName == null &&
                  match.name != null &&
                  match.name!.toString().trim().isNotEmpty &&
                  match.name!.toString().trim().toLowerCase() != 'member') {
                resolvedName = match.name!.toString().trim();
              }
              if (resolvedImg == null &&
                  match.profileImage != null &&
                  match.profileImage!.toString().trim().isNotEmpty &&
                  match.profileImage!.toString().trim().toLowerCase() != 'null') {
                resolvedImg = match.profileImage!.toString().trim();
              }
              if (resolvedPhone == null &&
                  match.mobileNo != null &&
                  match.mobileNo!.toString().trim().isNotEmpty) {
                resolvedPhone = match.mobileNo!.toString().trim();
              }
              resolvedLastSeen ??= match.lastSeen?.toString();
              break;
            }
          }
        }
      }

      // Check HomeController liveLocations
      if (Get.isRegistered<HomeController>()) {
        final hc = Get.find<HomeController>();
        final liveLoc = hc.liveLocations.firstWhereOrNull(
          (l) => l.userId.toString() == uidStr,
        );
        if (liveLoc != null) {
          if (resolvedName == null &&
              liveLoc.fullName.trim().isNotEmpty &&
              liveLoc.fullName.toLowerCase() != 'member') {
            resolvedName = liveLoc.fullName.trim();
          }
          if (resolvedImg == null &&
              liveLoc.profileImage.trim().isNotEmpty &&
              liveLoc.profileImage.toLowerCase() != 'null') {
            resolvedImg = liveLoc.profileImage.trim();
          }
          if (resolvedPhone == null &&
              liveLoc.phone != null &&
              liveLoc.phone!.trim().isNotEmpty) {
            resolvedPhone = liveLoc.phone!.trim();
          }
          if (resolvedLocation == null &&
              liveLoc.address != null &&
              liveLoc.address!.trim().isNotEmpty) {
            resolvedLocation = liveLoc.address!.trim();
          }
          if (resolvedTeam == null &&
              liveLoc.team != null &&
              liveLoc.team!.trim().isNotEmpty) {
            resolvedTeam = liveLoc.team!.trim();
          }
          if (resolvedBattery == null || resolvedBattery == 0) {
            resolvedBattery = int.tryParse(liveLoc.battery?.toString() ?? '');
          }
          if (liveLoc.isOnline) resolvedIsOnline = true;
        }
      }

      // Check GroupMessageController
      if (Get.isRegistered<GroupMessageController>()) {
        final gc = Get.find<GroupMessageController>();
        final gm = gc.groupMembers.firstWhereOrNull(
          (m) =>
              m.userId?.toString() == uidStr || m.id?.toString() == uidStr,
        );
        if (gm != null) {
          if (resolvedName == null &&
              gm.name != null &&
              gm.name!.trim().isNotEmpty &&
              gm.name!.trim().toLowerCase() != 'member') {
            resolvedName = gm.name!.trim();
          }
          if (resolvedImg == null &&
              gm.profileImage != null &&
              gm.profileImage!.trim().isNotEmpty &&
              gm.profileImage!.trim().toLowerCase() != 'null') {
            resolvedImg = gm.profileImage!.trim();
          }
          if (resolvedPhone == null &&
              gm.mobileNo != null &&
              gm.mobileNo!.trim().isNotEmpty) {
            resolvedPhone = gm.mobileNo!.trim();
          }
          if (resolvedLocation == null &&
              gm.location != null &&
              gm.location.toString().trim().isNotEmpty) {
            resolvedLocation = gm.location.toString().trim();
          }
          if (resolvedTeam == null &&
              gm.team != null &&
              gm.team.toString().trim().isNotEmpty) {
            resolvedTeam = gm.team.toString().trim();
          }
        }
      }
    }

    // Fallback address from cache if destination coordinates exist
    if ((resolvedLocation == null || resolvedLocation.isEmpty) &&
        destination.latitude != 0.0 &&
        destination.longitude != 0.0) {
      final cacheKey =
          '${destination.latitude.toStringAsFixed(4)},${destination.longitude.toStringAsFixed(4)}';
      if (UsersWithinRadiusData.addressCache.containsKey(cacheKey)) {
        resolvedLocation = UsersWithinRadiusData.addressCache[cacheKey];
      }
    }

    // Recalculate distance if 0
    double effectiveDistance = distance;
    if (effectiveDistance <= 0.0 &&
        destination.latitude != 0.0 &&
        destination.longitude != 0.0) {
      if (Get.isRegistered<TrackController>()) {
        final tc = Get.find<TrackController>();
        if (tc.currentLat.value != 0.0 && tc.currentLong.value != 0.0) {
          final meters = Geolocator.distanceBetween(
            tc.currentLat.value,
            tc.currentLong.value,
            destination.latitude,
            destination.longitude,
          );
          effectiveDistance = meters / 1000.0;
        }
      } else if (Get.isRegistered<HomeController>()) {
        final hc = Get.find<HomeController>();
        if (hc.currentLocation.value != null &&
            hc.currentLocation.value!.latitude != 0.0 &&
            hc.currentLocation.value!.longitude != 0.0) {
          final meters = Geolocator.distanceBetween(
            hc.currentLocation.value!.latitude,
            hc.currentLocation.value!.longitude,
            destination.latitude,
            destination.longitude,
          );
          effectiveDistance = meters / 1000.0;
        }
      }
    }

    final bool isOnline = resolvedIsOnline ||
        Tracking().isOnline(
          rawIsOnline: resolvedIsOnline,
          lastSeen: resolvedLastSeen,
          thresholdMinutes: 5,
        );

    // Clean and normalize image URL (avoid double slashes and Windows backslashes)
    String? fullImageUrl;
    if (resolvedImg != null &&
        resolvedImg.trim().isNotEmpty &&
        resolvedImg.trim().toLowerCase() != 'null') {
      final cleanPath = resolvedImg.trim().replaceAll(r'\', '/');
      if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
        fullImageUrl = cleanPath;
      } else {
        final base = ConstRes.aImageBaseUrl.endsWith('/')
            ? ConstRes.aImageBaseUrl
            : '${ConstRes.aImageBaseUrl}/';
        final path =
            cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath;
        fullImageUrl = '$base$path';
      }
    }

    final String displayName =
        resolvedName ?? (isMe ? 'You' : (name ?? AppText.member));

    final MemberData currentMemberData = MemberData(
      id: id ?? userId,
      userId: userId ?? id,
      groupId: groupId ?? 0,
      name: displayName,
      profileImage: fullImageUrl ?? resolvedImg ?? '',
      lastSeen: resolvedLastSeen,
      isOnline: isOnline,
      locationSharing: isLocationSharing,
      mobileNo: resolvedPhone,
      location: resolvedLocation,
      team: resolvedTeam,
    );

    final String effectiveTeam = (resolvedTeam != null && resolvedTeam.trim().isNotEmpty)
        ? resolvedTeam.trim()
        : '';

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
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  Get.to(() => UserProfileScreen(userData: currentMemberData));
                },
                borderRadius: BorderRadius.circular(50.r),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
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
                        child: _buildProfileAvatar(
                          imageUrl: fullImageUrl,
                          displayName: displayName,
                          size: 95.r,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5.r,
                      right: 5.r,
                      child: Container(
                        height: 18.r,
                        width: 18.r,
                        decoration: BoxDecoration(
                          color: isLocationSharing == false
                              ? Colors.grey
                              : (isOnline
                                  ? const Color(0xFF10B981)
                                  : const Color(0xffFF6B6B)),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  Get.to(() => UserProfileScreen(userData: currentMemberData));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: reausabletext(
                        displayName,
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
                  Utility.isNotNullEmptyOrFalse(resolvedLastSeen))
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: reausabletext(
                    "${AppText.lastSeen}${Tracking().getTimeAgo(Tracking.parseDateTime(resolvedLastSeen) ?? DateTime.now())}",
                    fontsize: 12.sp,
                    fontfamily: FontFamily.interRegular,
                    color: Colors.grey.shade600,
                  ),
                ),
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xffF8F7FD),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFEBE7F8)),
                ),
                child: Column(
                  children: [
                    if (resolvedLocation != null && resolvedLocation.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.place_outlined,
                              color: ToggleThemeData.darkPurple, size: 18.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              resolvedLocation,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                color: Colors.black87,
                                fontFamily: FontFamily.interRegular,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 16.h, color: Colors.grey.shade200),
                    ],
                    Row(
                      children: [
                        Icon(Icons.near_me_outlined,
                            color: ToggleThemeData.darkPurple, size: 18.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            "${AppText.distance}${effectiveDistance.toStringAsFixed(2)} Km",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontFamily: FontFamily.interSemiBold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (resolvedBattery != null && resolvedBattery > 0) ...[
                          Icon(
                            resolvedBattery > 20
                                ? Icons.battery_5_bar_rounded
                                : Icons.battery_alert_rounded,
                            size: 16.sp,
                            color: resolvedBattery > 20
                                ? const Color(0xFF10B981)
                                : Colors.orange,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "$resolvedBattery%",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade700,
                              fontFamily: FontFamily.interMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (!isMe) ...[
                SizedBox(height: 16.h),
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

                          Navigator.pop(ctx);

                          Get.toNamed(
                            Routes.chatScreen,
                            arguments: {
                              "userData": currentMemberData,
                              "groupName": displayName,
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
                                                (effectiveUserId ?? "").toString(),
                                            "callerName": displayName,
                                            "callerProfile": fullImageUrl ?? "",
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
                                                (effectiveUserId ?? "").toString(),
                                            "callerName": displayName,
                                            "callerProfile": fullImageUrl ?? "",
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
                          GroupTrackingController.instance.searchUserAndZoom(
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
