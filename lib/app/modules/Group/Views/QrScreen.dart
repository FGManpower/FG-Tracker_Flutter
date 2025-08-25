import 'dart:ui';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Group/Controller/QrController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';

class QrCodeScreen extends StatefulWidget {
  final String groupCode;

  const QrCodeScreen({super.key, required this.groupCode});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(QrController());
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller.initializeNotifications();

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
    return Scaffold(
      appBar: reusableAppbar("Group QR Code", ontap: Get.back),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F8FD), Color(0xFFE0E7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Center(
              child: widget.groupCode.isNotEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Screenshot(
                      controller: controller.screenshotController,
                      child: Card(
                        margin: EdgeInsets.only(top: 5.h,bottom: 15.h,right: 5.w,left: 5.w),
                        elevation: 8,shadowColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.r),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              reausabletext(
                                'Scan this QR Code',
          
                                  fontsize: 22,
                                  fontweight: FontWeight.bold,
                                  color: Colors.black87,
          
                              ),
                              SizedBox(height: 20.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Container(
                                  padding: EdgeInsets.all(20.r),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: PrettyQrView.data(
          
                                    data: widget.groupCode,
                                    errorCorrectLevel: QrErrorCorrectLevel.M,
                                    decoration: PrettyQrDecoration(
                                      shape: PrettyQrRoundedSymbol(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      image: PrettyQrDecorationImage(
                                        image: AssetImage('assets/icons/app_icon.png'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
          
                            ],
                          ),
                        ),
                      ),
                    ),
          
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    widget.groupCode,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.groupCode));
          
                      Utils().fluttertoast("Group code copied!");
                    },
                    icon: Icon(Icons.copy,
                        size: 18.sp, color: Colors.black54),
                    label: reausabletext(
                      "Copy Code",
                      color: Colors.black54, fontsize: 14),
          
                  ),
                  SizedBox(height: 8.h),
          
                  reausabletext(
                    "Share this code to let others join your group",
                    align: TextAlign.center,
                      fontsize: 14,
                      color: Colors.black54,
                      fontweight: FontWeight.w400,
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _qrActionButton(
                        icon: Icons.share,
                        label: "Share",
                        onPressed: () => controller.shareQrCode(widget.groupCode),
          
                        color: Colors.indigo,
                      ),
                      SizedBox(width: 20.w),
                      _qrActionButton(
                        icon: Icons.download_rounded,
                        label: "Download",
                        onPressed: () => controller.downloadQrCode(context),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              )
                  : reausabletext(
                "No Group Code Available",
                  fontsize: 16,
                  fontweight: FontWeight.w500,
                  color: Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _qrActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 0,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(fontSize: 15.sp)),
        ],
      ),
    );
  }
}
