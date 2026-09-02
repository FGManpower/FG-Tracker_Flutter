import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

class SosController extends GetxController {
  var selectedReason = 'Medical'.obs;
  var imagePath = ''.obs;
  final detailsController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  void selectReason(String reason) {
    selectedReason.value = reason;
  }

  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
    }
  }

  void sendSosAlert(BuildContext context) {
    if (selectedReason.value == 'Other' && detailsController.text.trim().isEmpty) {
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
                    child: const Icon(Icons.close, color: Colors.black54),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 40.sp,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16.h),
              reausabletext(
                "SOS Alert Sent!",
                fontsize: 18.sp,
                fontfamily: FontFamily.interBold,
                color: Colors.black87,
                align: TextAlign.center,
              ),
              SizedBox(height: 6.h),
              reausabletext(
                "Your alert has been sent to nearby people.",
                fontsize: 12.sp,
                color: Colors.black54,
                align: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              _buildPopupInfoRow(Icons.group, "People within 2 km radius", "will be notified"),
              SizedBox(height: 10.h),
              _buildPopupInfoRow(Icons.notifications_active, "Stay calm, help is on the way", "We will notify you of any updates"),
              SizedBox(height: 10.h),
              _buildPopupInfoRow(Icons.location_on, "Live tracking started", "Your location is being shared"),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Get.back();
                  },
                  child: reausabletext(
                    "OK, Got It",
                    fontsize: 15.sp,
                    fontfamily: FontFamily.interBold,
                    color: Colors.white,
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
            color: const Color(0xFF6B4DFF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.sp, color: const Color(0xFF6B4DFF)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              reausabletext(title, fontsize: 12.sp, fontfamily: FontFamily.interSemiBold, color: Colors.black87),
              reausabletext(subtitle, fontsize: 10.sp, color: Colors.black54),
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