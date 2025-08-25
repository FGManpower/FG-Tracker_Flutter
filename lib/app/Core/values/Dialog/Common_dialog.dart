import 'dart:io';


import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';

import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CommonDialog {
  static errorMessage(
    String? title, {   String successBtnName="DISMISS",
    bool status = false,
    void Function()? onDismiss,
  }) {
    showCupertinoDialog(
      barrierDismissible: false,
      context: ContextUtility.context!,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              buttonPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.only(left: 0.w, right: 0.w),
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              content: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? ToggleThemeData.backgroundBlack
                      : Colors.white,
                  borderRadius: BorderRadius.circular(15.0.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: Container(
                        width: 70.h,
                        height: 70.h,
                        decoration: BoxDecoration(
                          color: status == true
                              ? Colors.green
                              : Colors.red.shade900,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              status == true ? Icons.verified : Icons.close,
                              size: 40,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    reausabletext(status == true ? AppText.success.tr : AppText.error.tr,
                        fontsize: 24,
                        fontfamily: FontFamily.interMedium,
                        align: TextAlign.center),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 240.w,
                      ),
                      child: reausabletext(
                        title ?? AppText.anErrorOccured.tr,
                        align: TextAlign.center,
                        fontfamily: FontFamily.interRegular,
                        fontsize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: onDismiss ?? () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.h),
                        child: Container(
                          width: 140.w,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 8.w),
                          margin: EdgeInsets.symmetric(horizontal: 30.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 3,
                                color: status == true
                                    ? Colors.blue
                                    : Colors.red.shade900),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          child: reausabletext( status == true ?successBtnName.tr: AppText.dismiss.tr,
                              color: status == true
                                  ? Colors.blue
                                  : Colors.red.shade900,
                              fontweight: FontWeight.bold,
                              fontsize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static ConfirmationDialog({
    String? title,
    content,
    void Function()? onConfirm,
    void Function()? onCancel,
    Color? titleColor,
    String cancel = "No",
    String confirm = "Yes",
    IconData icon = Icons.question_mark,
  }) {
    showCupertinoDialog(
      barrierDismissible: false,
      context: ContextUtility.context!,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              buttonPadding: EdgeInsets.zero,
              elevation: 10.h,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              content: Container(
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? ToggleThemeData.backgroundBlack
                      : Colors.white,
                  borderRadius: BorderRadius.circular(15.0.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: Container(
                          width: 70.w,
                          height: 70.h,
                          decoration: const BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: reausableIcon(
                            icon: icon,
                            size: 40.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      title == null
                          ? const SizedBox()
                          : reausabletext(
                              title,
                              color: context.isDarkMode
                                  ? ToggleThemeData.white
                                  : Colors.black,
                              align: TextAlign.center,
                              fontfamily: FontFamily.interSemiBold,
                              fontsize: 16,
                            ),
                      content == null
                          ? const SizedBox()
                          : SizedBox(
                              height: 20.h,
                            ),
                      content == null
                          ? const SizedBox()
                          : reausabletext(
                              content ?? AppText.doYouWantToLogout.tr,
                              color: context.isDarkMode
                                  ? ToggleThemeData.white
                                  : Colors.black,
                              align: TextAlign.center,
                              fontfamily: FontFamily.interRegular,
                              fontsize: 14,
                            ),
                      SizedBox(
                        height: 30.h,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 20.h,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: onCancel ?? () => Navigator.pop(context),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5.w, horizontal: 15.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 2.w,
                                        color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                  child: reausabletext(
                                    cancel.tr,
                                    fontfamily: FontFamily.interMedium,
                                    color: context.isDarkMode
                                        ? Colors.grey.shade700
                                        : Colors.grey,
                                    fontweight: FontWeight.bold,
                                    fontsize: 14,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: onConfirm,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5.w, horizontal: 15.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    border: Border.all(
                                        width: 2.w, color: AppColors.blue),
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                  child: reausabletext(
                                    confirm.tr,
                                    fontfamily: FontFamily.interMedium,
                                    color: Colors.white,
                                    fontweight: FontWeight.bold,
                                    fontsize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> PermissionDeny_dialog(
      BuildContext context, {
        void Function()? acceptontap,
        void Function()? CancelOnTap,
      }) async {
    return await showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Determine content based on the platform (Android or iOS)
        String titleText = Platform.isIOS
            ? AppText.allowLocationAccess.tr
            : AppText.locationPermissionReqrd.tr;
        String contentText = Platform.isIOS
            ? AppText.thisAppRequiresYourLocation.tr
            : AppText.wthtLocationAccessWeWont.tr;

        return WillPopScope(
          onWillPop: () async => false, // Disables back button and gesture
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: 250.h,
                width: 300.w,
                decoration: BoxDecoration(
                  color: context.isDarkMode ? ToggleThemeData.black : Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: reausabletext(
                        titleText.tr,
                        fontfamily: FontFamily.interRegular,
                        color: context.isDarkMode
                            ? ToggleThemeData.white
                            : Colors.black,
                        decorationcolor: Colors.transparent,
                        fontsize: 16,
                        decoration: TextDecoration.none,
                        align: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Content
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: reausabletext(
                        contentText.tr,
                        fontfamily: FontFamily.interRegular,
                        color: context.isDarkMode
                            ? ToggleThemeData.white
                            : Colors.black,
                        decorationcolor: Colors.transparent,
                        fontsize: 14,
                        decoration: TextDecoration.none,
                        align: TextAlign.center,
                      ),
                    ),
                    const Spacer(),
                    // Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: CancelOnTap,
                            child: Container(
                              width: 100.w,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: reausabletext(
                                AppText.cancelbtn.tr,
                                color: Colors.redAccent,
                                fontweight: FontWeight.bold,
                                fontsize: 14,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: acceptontap,
                            child: Container(
                              width: 100.w,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: AppColors.darkBlue,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: reausabletext(
                                AppText.settings.tr,
                                color: context.isDarkMode
                                    ? ToggleThemeData.white
                                    : Colors.white,
                                fontweight: FontWeight.bold,
                                fontsize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  //********** Location Permission ****************//
  LocationPermission_dialog(
      BuildContext context, {
        void Function()? acceptontap,
      }) async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                backgroundColor: context.isDarkMode
                    ? ToggleThemeData.backgroundBlack
                    : ToggleThemeData.backgroundWhite,
                surfaceTintColor: Colors.white,
                insetPadding: EdgeInsets.only(left: 30.w, right: 30.w),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0))),
                contentPadding: EdgeInsets.zero,
                content: Container(
                    padding:
                    EdgeInsets.only(left: 10.w, right: 10.w, top: 12.h),
                    width: MediaQuery.sizeOf(context).width,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          reausabletext(
                            AppText.important.tr,
                            fontsize: 20,
                            fontfamily: FontFamily.interSemiBold,
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          reausabletext(
                            AppText.toIimproveServiceEfficiency.tr,
                            fontsize: 15,
                            fontfamily: FontFamily.interSemiBold,
                            align: TextAlign.center,
                            height: 1.5,
                          ),
                          SizedBox(
                            height: 25.h,
                          ),
                          reausabletext(
                              AppText.inTheNextPopup.tr,
                              fontsize: 15,
                              fontfamily: FontFamily.interSemiBold,
                              height: 1.5,
                              align: TextAlign.center),
                          SizedBox(
                            height: 30.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 10.w, right: 10.w, bottom: 10.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // dashcontroller.isLoading.value = false;
                                    Navigator.pop(context);
                                  },style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                  child: reausabletext(AppText.no.tr,
                                      fontsize: 15,backcolor: Colors.grey.shade200,

                                      fontfamily: FontFamily.interRegular,
                                      color: context.isDarkMode
                                          ? ToggleThemeData.white
                                          : Colors.black,
                                      align: TextAlign.center),
                                ),
                                // Container(
                                //   height: 20.h,
                                //   width: 1.w,
                                //   color: const Color(0xff828282),
                                // ),
                                ElevatedButton(onPressed: acceptontap, style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),child: reausabletext(AppText.yes.tr,
                                    fontsize: 15,color: Colors.white, backcolor: Colors.blue,
                                    fontfamily: FontFamily.interRegular,
                                    align: TextAlign.center),)

                              ],
                            ),
                          )
                        ],
                      ),
                    )));
          });
        });
  }



}