import 'dart:ui';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Group/Controller/QrController.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';

import '../../../../gen/assets.gen.dart';

class QrCodeScreen extends StatefulWidget {


  const QrCodeScreen({super.key, });

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(Assets.images.qrCodeBg.path),
              fit: BoxFit.cover,
              opacity: 0.15),
          color: ToggleThemeData.darkPurple,
        ),
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: BackpressIcon(context, color: ToggleThemeData.white),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Center(
                    child: controller.groupCode.isNotEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Screenshot(
                                  controller: controller.screenshotController,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 5.h,
                                        bottom: 15.h,
                                        right: 5.w,
                                        left: 5.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(20.r),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          reausabletext(
                                            'Scan This QR Code',
                                            fontsize: 21,
                                            fontfamily:
                                                FontFamily.interSemiBold,
                                            color: Colors.black,
                                          ),
                                          SizedBox(height: 20.h),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(33.r),
                                              child: Container(
                                                padding: EdgeInsets.all(25.r),
                                                decoration: BoxDecoration(
                                                  color:
                                                      ToggleThemeData.Appcolor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          33.r),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 10,
                                                      offset: Offset(0, 5),
                                                    ),
                                                  ],
                                                ),
                                                child: PrettyQrView.data(
                                                  data:  controller.groupCode.toString(),
                                                  errorCorrectLevel:
                                                      QrErrorCorrectLevel.M,
                                                  decoration:
                                                      PrettyQrDecoration(
                                                    shape:
                                                        PrettyQrRoundedSymbol(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.r),
                                                    ),
                                                    image:
                                                        PrettyQrDecorationImage(
                                                      image: AssetImage(
                                                         Assets.icons.appIcon.path),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10.h),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              reausabletext("Team Code ",color: Colors.black,fontsize: 14,fontfamily: FontFamily.interRegular),
                                              Text(
                                                controller.groupCode.toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: ToggleThemeData.darkPurple,
                                                 fontFamily: FontFamily.interSemiBold
                                                ),
                                              ),
                                              TextButton.icon(
                                                onPressed: () {
                                                  Clipboard.setData(
                                                      ClipboardData(text: controller.groupCode.toString()));

                                                  Utils().fluttertoast("Group code copied!");
                                                },
                                                icon: Icon(Icons.copy,
                                                    size: 18.sp, color: Colors.black54),
                                                label: reausabletext("",
                                                    color: Colors.black54, fontsize: 14),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 15.h),
                                          reausabletext(
                                            "Share this code to let other’s join your group",
                                            align: TextAlign.center,
                                            fontsize: 14,
                                            color: Colors.black54,
                                            fontweight: FontWeight.w400,
                                            fontfamily: FontFamily.interMedium
                                          ),
                                          SizedBox(height: 10.h),

                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 32.h),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),child:   Row(
                              children: [
                                Expanded(child:   reausablebutton(icon: Icons.share,title: "Share",iconColor: Color(0xffFFE400),borderradiues: 25,fontSize:14,backgroundColor: ToggleThemeData.Appcolor,iconSize:20,ontap: () => controller
                                    .shareQrCode(controller.groupCode.toString()),),),

                                SizedBox(width: 20.w,),
                                Expanded(child:   reausablebutton(icon: Icons.download_rounded,title: "Download",iconColor: Color(0xffFFE400),borderradiues: 25,fontSize:14,backgroundColor: ToggleThemeData.Appcolor,iconSize:20,ontap: () => controller.downloadQrCode(context),),),

                              ],
                            ),)

                            ],
                          )
                        : reausabletext(
                            "No Group Code Available",
                            fontsize: 16,
                            fontweight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                  ),
                ],
              )),
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
