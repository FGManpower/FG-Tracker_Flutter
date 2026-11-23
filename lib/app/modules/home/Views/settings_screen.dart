import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/auth/Controller/account_deletion_controller.dart';
import 'package:fgtracker/app/modules/auth/Controller/logout_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/features/language/language_settings.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: trackerAppBar(
        context,
        context.l10n.common_settings,
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language ("Language" + "Change app language"; opens language sheet)
            LanguageSettingsRow(
              sizes: LanguageRowSizes(
                tile: 44.w,
                tileRadius: 14.r,
                icon: 22.sp,
                gap: 14.w,
                title: 15.sp,
                subtitleGap: 3.h,
                subtitle: 12.sp,
                chevron: 24.sp,
                padV: 10.h,
                padH: 8.w,
                radius: 15.r,
                appBarHeight: 50.h,
                appBarTitle: 20.sp,
                appBarIcon: 20.sp,
              ),
            ),
            _buildDivider(),

            // Legal
            _buildSettingsItem(
              icon: Icons.gavel_rounded,
              title: context.l10n.legal_title,
              subtitle: context.l10n.legal_menuSubtitle,
              onTap: () => Get.toNamed(Routes.Legal),
            ),
            _buildDivider(),

            // Update App
            _buildSettingsItem(
              icon: Icons.system_update_rounded,
              title: context.l10n.appUpdate_updateApp,
              subtitle: context.l10n.appUpdate_updateAvailable,
              onTap: () => Get.toNamed(Routes.shorebirdUpdate),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: _buildDeleteAccountButton(context),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: const Divider(
        color: Color(0xFFF0ECFC),
        height: 1,
        thickness: 1,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: const Color(0xFF5D47F1), size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: FontFamily.interBold,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E202B),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: FontFamily.interRegular,
                      color: const Color(0xFF7A7F93),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF7E69F7),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('settings_delete_account_button'),
        onTap: () => _showDeleteAccountDialog(context),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 50.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_forever_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                context.l10n.account_deleteTitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: FontFamily.interBold,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        String selectedReason = "I no longer need this account";
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              contentPadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFDC2626),
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      context.l10n.account_deleteDialogTitle,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: FontFamily.interBold,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.account_deleteConfirm,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E202B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    context.l10n.account_deleteWarning,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    context.l10n.account_reasonLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedReason,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: const Color(0xFF1F2937),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: "I no longer need this account",
                            child:
                                Text(context.l10n.account_reasonNoLongerNeed),
                          ),
                          DropdownMenuItem(
                            value: "Privacy concerns",
                            child: Text(context.l10n.account_reasonPrivacy),
                          ),
                          DropdownMenuItem(
                            value: "Too many notifications / battery",
                            child:
                                Text(context.l10n.account_reasonNotifications),
                          ),
                          DropdownMenuItem(
                            value: "Switching to another app or device",
                            child: Text(context.l10n.account_reasonSwitching),
                          ),
                          DropdownMenuItem(
                            value: "Other reason",
                            child: Text(context.l10n.account_reasonOther),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedReason = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(
                    context.l10n.common_cancel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  ),
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    Navigator.pop(context);
                    await AccountDeletionController().deleteUserAccount(
                      reason: selectedReason,
                    );
                  },
                  child: Text(
                    context.l10n.account_deleteForever,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
