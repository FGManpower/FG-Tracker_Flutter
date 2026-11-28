import 'dart:developer';

import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';


class InviteHelper {
  InviteHelper._();

  static final RegExp _nonDigit = RegExp(r'[^0-9]');

  static String _buildInviteMessage(UserListData user) {
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.fg.fgtracker&hl=en";
    const String appStoreLink = "https://apps.apple.com/app/id6470000000";

    return "Hey ${user.name ?? ''}! Join me on FG Tracker.\n\n"
        "Download for Android: $playStoreLink\n\n"
        "Download for iOS: $appStoreLink";
  }

  static String _normalizedNumber(String? raw) {
    final String digits = (raw ?? '').replaceAll(_nonDigit, '');
    if (digits.length == 10) return '91$digits';
    if (digits.length == 11 && digits.startsWith('0')) {
      return '91${digits.substring(1)}';
    }
    return digits;
  }

  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      log("INVITE launch failed: $uri => $e");
      return false;
    }
  }

  static Future<void> _inviteViaWhatsApp(UserListData user) async {
    final String number = _normalizedNumber(user.mobileNo);
    final String encoded = Uri.encodeComponent(_buildInviteMessage(user));
    log("INVITE WHATSAPP NUMBER => $number");

    if (number.isNotEmpty) {
      if (await _tryLaunch(
          Uri.parse('whatsapp://send?phone=$number&text=$encoded'))) {
        return;
      }
      if (await _tryLaunch(Uri.parse('https://wa.me/$number?text=$encoded'))) {
        return;
      }
    }
    Get.snackbar("Error", "WhatsApp could not be opened");
  }

  static Future<void> _inviteViaTelegram(UserListData user) async {
    final String number = _normalizedNumber(user.mobileNo);
    log("INVITE TELEGRAM NUMBER => $number");

    if (number.isNotEmpty) {
      if (await _tryLaunch(Uri.parse('tg://resolve?phone=$number'))) {
        return;
      }
      if (await _tryLaunch(Uri.parse('https://t.me/+$number'))) {
        return;
      }
    }
    Get.snackbar("Error", "Telegram could not be opened");
  }

  static Future<void> _inviteViaSms(UserListData user) async {
    final String number = _normalizedNumber(user.mobileNo);
    final String encoded = Uri.encodeComponent(_buildInviteMessage(user));
    log("INVITE SMS NUMBER => $number");

    if (number.isNotEmpty &&
        await _tryLaunch(Uri.parse('sms:+$number?body=$encoded'))) {
      return;
    }
    Get.snackbar("Error", "Messaging app could not be opened");
  }

  static Future<void> _inviteViaShareSheet(UserListData user) async {
    try {
      await Share.share(_buildInviteMessage(user));
    } catch (e) {
      Get.snackbar("Error", "Could not open share menu: $e");
    }
  }

  static void showInviteOptions(UserListData user) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              reausabletext(
                "Invite ${user.name ?? ''}",
                fontsize: 16.sp,
                fontfamily: FontFamily.interBold,
                color: Colors.black87,
              ),
              SizedBox(height: 4.h),
              reausabletext(
                "Choose how you want to send the invite",
                fontsize: 11.sp,
                color: Colors.grey.shade600,
              ),
              SizedBox(height: 10.h),
              _inviteOption(
                icon: Icons.chat_rounded,
                color: const Color(0xFF25D366),
                title: "WhatsApp",
                onTap: () {
                  Get.back();
                  _inviteViaWhatsApp(user);
                },
              ),
              _inviteOption(
                icon: Icons.send_rounded,
                color: const Color(0xFF229ED9),
                title: "Telegram",
                onTap: () {
                  Get.back();
                  _inviteViaTelegram(user);
                },
              ),
              _inviteOption(
                icon: Icons.sms_rounded,
                color: const Color(0xFF6C5DD3),
                title: "Message",
                onTap: () {
                  Get.back();
                  _inviteViaSms(user);
                },
              ),
              _inviteOption(
                icon: Icons.share_rounded,
                color: const Color(0xFF5A2BE0),
                title: "More apps",
                onTap: () {
                  Get.back();
                  _inviteViaShareSheet(user);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _inviteOption({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: reausabletext(
                title,
                fontsize: 14.sp,
                fontfamily: FontFamily.interSemiBold,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 22.sp, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}