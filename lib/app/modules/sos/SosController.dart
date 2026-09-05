import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/gen/assets.gen.dart';

import 'SosUserSheet.dart';

class SosReasonItem {
  final String key;
  final String label;
  final AssetGenImage asset;
  final Color activeColor;

  const SosReasonItem({
    required this.key,
    required this.label,
    required this.asset,
    required this.activeColor,
  });
}

class SosController extends GetxController {
  final ContactService _contactService = ContactService();
  final ImagePicker _picker = ImagePicker();

  late final List<SosReasonItem> reasonList = [
    SosReasonItem(
      key: 'Medical',
      label: 'Medical',
      asset: Assets.images.sosMedical,
      activeColor: const Color(0xFF5351DE),
    ),
    SosReasonItem(
      key: 'Accident',
      label: 'Accident',
      asset: Assets.images.sosAccident,
      activeColor: const Color(0xFFFF6D00),
    ),
    SosReasonItem(
      key: 'Safety',
      label: 'Safety',
      asset: Assets.images.sosSafety,
      activeColor: const Color(0xFFF12E43),
    ),
    SosReasonItem(
      key: 'Threat',
      label: 'Threat',
      asset: Assets.images.sosThreat,
      activeColor: const Color(0xFF5351DE),
    ),
    SosReasonItem(
      key: 'Other',
      label: 'Other',
      asset: Assets.images.sosOther,
      activeColor: const Color(0xFF676E95),
    ),
  ];

  var selectedReason = 'Medical'.obs;
  var imagePath = ''.obs;
  final detailsController = TextEditingController();

  var allUsers = <UserListData>[].obs;
  var selectedFamilyMembers = <UserListData>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    try {
      isLoading.value = true;
      final contactNumbers = await _contactService.getMobileNumbers();

      if (contactNumbers.isEmpty) {
        allUsers.clear();
        return;
      }

      UserProfileListRes result = await GroupRepo.getAllUserData();
      if (result.status == true && result.userData != null) {
        final users = result.userData!;
        final contactNumberSet = contactNumbers.toSet();

        final matchedUsers = users.where((user) {
          String mobileNo =
          (user.mobileNo ?? '').replaceAll(RegExp(r'[^0-9]'), '');

          if (mobileNo.startsWith('91') && mobileNo.length > 10) {
            mobileNo = mobileNo.substring(2);
          }

          if (mobileNo.length > 10) {
            mobileNo = mobileNo.substring(mobileNo.length - 10);
          }

          return contactNumberSet.contains(mobileNo);
        }).toList();

        allUsers.value = matchedUsers;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
    }
  }

  void selectReason(String reason) {
    selectedReason.value = reason;
  }

  void addFamilyMember(UserListData user) {
    if (selectedFamilyMembers.length < 5 &&
        !selectedFamilyMembers
            .any((element) => element.userId == user.userId)) {
      selectedFamilyMembers.add(user);
    }
  }

  void removeFamilyMember(int index) {
    selectedFamilyMembers.removeAt(index);
  }

  Future<void> openFamilyBottomSheet(BuildContext context) async {
    await fetchAllUsers();
    final UserListData? result = await SosUserSheet().showAllUserBottomSheet(
      context,
      allUsers,
    );
    if (result != null) {
      addFamilyMember(result);
    }
  }

  void sendSosAlert(BuildContext context) {
    if (selectedFamilyMembers.isEmpty) {
      Get.snackbar(
        "Required",
        "Add at least 1 family member to send SOS alert",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedReason.value == 'Other' &&
        detailsController.text.trim().isEmpty) {
      Get.snackbar(
        "Required",
        "Add Details is mandatory when 'Other' reason is selected",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child:
                    Icon(Icons.close, color: Colors.black54, size: 20.sp),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 32.sp, color: Colors.green),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "SOS Alert Sent!",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.h),
              Text(
                "Your alert has been sent to nearby people.",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              _buildPopupInfoRow(
                  Icons.group, "People within 2 km radius", "will be notified"),
              SizedBox(height: 12.h),
              _buildPopupInfoRow(
                  Icons.notifications_active_outlined,
                  "Stay calm, help is on the way",
                  "We will notify you of any updates"),
              SizedBox(height: 12.h),
              _buildPopupInfoRow(
                  Icons.location_on_outlined,
                  "Live tracking started",
                  "Your location is being shared with ${selectedFamilyMembers.length} family member(s)"),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Get.back();
                  },
                  child: Text(
                    "OK, Got It",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFF6B4DFF).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF6B4DFF)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void onClose() {
    detailsController.dispose();
    super.onClose();
  }
}