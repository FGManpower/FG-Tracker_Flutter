import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/features/voice_input/voice_input_controller.dart';
import 'package:fgtracker/features/voice_input/voice_languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LanguageList extends StatelessWidget {
  final VoiceInputController controller;

  const LanguageList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final appLocaleCode =
        Get.locale?.languageCode ?? Get.deviceLocale?.languageCode ?? 'en';
    final defaultLang =
        VoiceLanguages.defaultLanguage(appLanguageCode: appLocaleCode);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Choose Speech Language",
                style: TextStyle(
                  color: AppColors.darkText, // #0F0B4C
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.mode.value = VoiceInputMode.voiceToTextListening;
                },
                icon: const Icon(Icons.close_rounded),
                color: Colors.grey.shade700,
              ),
            ],
          ),
          const Divider(height: 1),
          SizedBox(height: 8.h),

          // Scrollable Languages
          SizedBox(
            height: 220.h,
            child: Obx(() {
              final langs = controller.availableLanguages;
              final currentSelected = controller.selectedLanguage.value;

              return ListView.builder(
                itemCount: langs.length,
                itemBuilder: (context, index) {
                  final lang = langs[index];
                  final isSelected = lang.code == currentSelected.code;
                  final isAppDefault = lang.code == defaultLang.code;

                  return InkWell(
                    onTap: () => controller.selectLanguage(lang),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      margin: EdgeInsets.only(bottom: 4.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.authIconBgCircle // #EEEDFD
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  lang.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primaryDarkblue
                                        : AppColors.darkText,
                                    fontSize: 15.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "(${lang.englishName})",
                                  style: TextStyle(
                                    color: AppColors
                                        .primarySecondaryElementText, // #666666
                                    fontSize: 12.sp,
                                  ),
                                ),
                                if (isAppDefault) ...[
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryDarkblue
                                          : AppColors.authIconBgCircle,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      "App language",
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.primaryDarkblue,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              color: AppColors.primaryDarkblue,
                              size: 20.sp,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
