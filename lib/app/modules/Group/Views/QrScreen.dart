import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/modules/Group/controller/QrController.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../gen/assets.gen.dart';

class QrCodeBottomSheet extends StatefulWidget {
  final String groupName;
  final String groupCode;

  const QrCodeBottomSheet({
    super.key,
    required this.groupName,
    required this.groupCode,
  });

  static void show(
    BuildContext context, {
    required String groupName,
    required String groupCode,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QrCodeBottomSheet(
        groupName: groupName,
        groupCode: groupCode,
      ),
    );
  }

  @override
  State<QrCodeBottomSheet> createState() => _QrCodeBottomSheetState();
}

class _QrCodeBottomSheetState extends State<QrCodeBottomSheet>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(QrController());
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final Color primaryPurple = const Color(0xFF4A3BD1);
  final Color bgColor = const Color(0xFFF7F7FA);

  @override
  void initState() {
    super.initState();
    controller.initializeNotifications();
    controller.groupCode.value = widget.groupCode;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutBack);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 15.h),
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.groupName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: FontFamily.interSemiBold,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.2), width: 1),
                        ),
                        child: Icon(Icons.close,
                            size: 18.sp, color: primaryPurple),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Team Code: ",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                      fontFamily: FontFamily.interRegular,
                    ),
                  ),
                  Text(
                    controller.groupCode.toString(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: primaryPurple,
                      fontFamily: FontFamily.interSemiBold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: controller.groupCode.toString()));
                      Utils().fluttertoast("Group code copied!");
                    },
                    child: Icon(Icons.copy, size: 16.sp, color: primaryPurple),
                  ),
                ],
              ),
              SizedBox(height: 25.h),
              controller.groupCode.isNotEmpty
                  ? ScaleTransition(
                      scale: _scaleAnimation,
                      child: Screenshot(
                        controller: controller.screenshotController,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: 30.h, horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: primaryPurple.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 200.w,
                                height: 200.w,
                                child: PrettyQrView.data(
                                  data: controller.groupCode.toString(),
                                  errorCorrectLevel: QrErrorCorrectLevel.H,
                                  decoration: PrettyQrDecoration(
                                    shape: PrettyQrRoundedSymbol(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                    image: PrettyQrDecorationImage(
                                      image:
                                          AssetImage(Assets.icons.appIcon.path),
                                      padding: const EdgeInsets.all(5),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 25.h),
                              Text(
                                "Scan this QR code to join the group",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                  fontFamily: FontFamily.interMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(vertical: 50.h),
                      child: Text(
                        "No Group Code Available",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
              SizedBox(height: 30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    title: "Share QR",
                    onTap: () => controller.shareQrCode(
                        context, controller.groupCode.toString()),
                  ),
                  SizedBox(width: 10.w),
                  _buildActionButton(
                    icon: Icons.download_outlined,
                    title: "Download",
                    onTap: () => controller.downloadQrCode(context),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: primaryPurple),
              SizedBox(width: 5.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: primaryPurple,
                  fontFamily: FontFamily.interSemiBold,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
