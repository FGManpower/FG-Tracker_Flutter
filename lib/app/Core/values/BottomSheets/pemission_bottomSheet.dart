import 'dart:io';


import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/modules/home/Controller/permission_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PermissionBottomSheet extends StatelessWidget {
  const PermissionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.put(PermissionController());


    ever(controller.step, (value) {

      Navigator.pop(context);
       //=========== Get Current Location function call ==========>


    });

    return SafeArea(
      child: Obx(() {
        final step = controller.step.value;

        final icon = [
          Icons.location_on_rounded,
          Icons.gps_fixed_rounded,
        ][step.clamp(0, 1)];

        final title = [
          AppText.locationPermission.tr,
          AppText.EnableGPS.tr,
        ][step.clamp(0, 1)];

        return WillPopScope(
          onWillPop: () async {
            CommonDialog.ConfirmationDialog(
              title: AppText.areYouSure.tr,
              content: AppText.doYouWantToExit.tr,
              onConfirm: () => exit(0),
            );

            return true;
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 28.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48.sp,
                    color: Colors.blueAccent,
                  ),
                ),

                SizedBox(height: 20.h),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: FontFamily.interBold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 16.h),

                ..._buildDescription(step),

                SizedBox(height: 28.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                    controller.requestStepWisePermission,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 14.h),
                      backgroundColor:
                      Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      step < 2
                          ? AppText.next.tr
                          : AppText.continueBtn.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily:
                        FontFamily.interSemiBold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildDescription(int step) {
    TextStyle style = TextStyle(
      fontSize: 13.sp,
      fontFamily: FontFamily.interRegular,
      color: Colors.grey.shade600,
      height: 1.5,
    );

    if (step == 0) {
      return [
        Text(
          AppText.fgPartnerAppNeedYourPermission.tr,
          textAlign: TextAlign.center,
          style: style,
        ),
        SizedBox(height: 6.h),
        Text(
          AppText.plsChooseAllowAllTheTime.tr,
          textAlign: TextAlign.center,
          style: style,
        ),
        SizedBox(height: 6.h),
        Text(
          AppText.thisAppCollectsLocationData.tr,
          textAlign: TextAlign.center,
          style: style,
        ),
      ];
    } else {
      return [
        Text(
          AppText.gpsRequiredToTrackGroup.tr,
          textAlign: TextAlign.center,
          style: style,
        ),
        SizedBox(height: 6.h),
        Text(
          AppText.pleaseEnableYourDeviceGps.tr,
          textAlign: TextAlign.center,
          style: style,
        ),
      ];
    }
  }
}