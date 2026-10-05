

import 'dart:developer';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/Curve/walkie_painter.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Widget buildMembersSkeleton({bool isWide = false}) {
  if (isWide) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => SizedBox(height: 6.h),
      itemBuilder: (_, __) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 45.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(
      children: List.generate(
        4,
            (index) => Padding(
          padding: EdgeInsets.only(right: index < 3 ? 12.w : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48.r.clamp(42.0, 52.0),
                height: 48.r.clamp(42.0, 52.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: 5.h),
              Container(
                width: 36.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
Widget buildEmptyMembersState() {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: softPurple,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.wifi_tethering_rounded,
              size: 15.sp, color: primaryPurple),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            "Connected to channel • Waiting for others to join",
            style: TextStyle(
              color: textSecondary,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildAudioRouteDivider() {
  return Divider(
    color: const Color(0xFFF1F5F9),
    height: 1,
    thickness: 1,
    indent: 52.w.clamp(44.0, 60.0),
    endIndent: 16.w,
  );
}

void showExitDialog({required void Function() onTap}) {
  log('Displaying exit dialog prompt...');
  Get.dialog(
    AlertDialog(
      backgroundColor: cardWhite,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        "Exit Walkie?",
        style: TextStyle(
          color: textDark,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        "You will disconnect from this walkie channel. You will still remain a member of the group.",
        style: TextStyle(color: textSecondary, fontSize: 14.sp),
      ),
      actions: [
        TextButton(
          onPressed: () {
            log('User cancelled exit prompt.');
            Get.back();
          },
          child: Text("Cancel", style: TextStyle(color: textSecondary)),
        ),
        ElevatedButton(
          onPressed: onTap,

          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          child: const Text("Exit Walkie",
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}


Widget buildAudioRouteItem({
  required String title,
  String? subtitle,
  required IconData trailingIcon,
  required bool isSelected,
  bool isEnabled = true,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? const Color(0xFFF6F3FF) : Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: 18.w.clamp(14.0, 22.0),
          vertical: 13.h.clamp(10.0, 16.0),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24.w.clamp(20.0, 28.0),
              child: isSelected
                  ? Icon(
                Icons.check_rounded,
                color: primaryPurple,
                size: 20.sp.clamp(18.0, 23.0),
              )
                  : const SizedBox.shrink(),
            ),
            SizedBox(width: 10.w.clamp(8.0, 14.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: !isEnabled
                          ? slateGray
                          : (isSelected ? primaryPurple : textDark),
                      fontSize: 15.sp.clamp(14.0, 16.5),
                      fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isSelected
                            ? primaryPurple.withOpacity(0.8)
                            : textSecondary,
                        fontSize: 11.5.sp.clamp(10.5, 12.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              trailingIcon,
              color: !isEnabled
                  ? slateGray.withOpacity(0.5)
                  : (isSelected ? primaryPurple : textSecondary),
              size: 22.sp.clamp(19.0, 25.0),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildMutedListeningView({required double size,}) {
  final double s = size * 0.92;
  return Container(
    width: s,
    height: s,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.grey.withOpacity(0.12),
    ),
    padding: EdgeInsets.all((s * 0.05).clamp(5.0, 8.0)),
    child: Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      padding: EdgeInsets.all((s * 0.035).clamp(3.0, 6.0)),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade300, Colors.grey.shade400],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.headphones_rounded,
                color: Colors.white, size: (s * 0.26).clamp(32.0, 44.0)),
            SizedBox(height: 3.h),
            Text(
              "Listening",
              style: TextStyle(
                color: Colors.white,
                fontSize: (s * 0.075).clamp(11.0, 13.0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildMemberAvatar(
    WalkieParticipant p, {
      required int index,
      Map<String, dynamic>? args
    }) {
  final isSpeaking = p.isSpeaking;
  final isMuted = p.isMuted;
  final isAdmin = args?['adminId'] == p.userId || index == 0;

  return SizedBox(
    width: 66.w.clamp(58.0, 74.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 48.r.clamp(42.0, 52.0),
          width: 48.r.clamp(42.0, 52.0),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (isSpeaking)
                Container(
                  width: 48.r.clamp(42.0, 52.0),
                  height: 48.r.clamp(42.0, 52.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryPurple,
                      width: 2,
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.all(isSpeaking ? 2.5 : 1.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSpeaking
                        ? primaryPurple.withOpacity(0.3)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: buildSafeAvatar(p, 19.r.clamp(16.0, 21.0)),
              ),
              if (isSpeaking)
                Positioned(
                  left: -2,
                  bottom: -2,
                  child: Container(
                    width: 16.r.clamp(14.0, 18.0),
                    height: 16.r.clamp(14.0, 18.0),
                    decoration: BoxDecoration(
                      color: primaryPurple,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(Icons.graphic_eq_rounded,
                        color: Colors.white, size: 9.sp.clamp(8.0, 11.0)),
                  ),
                ),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: isMuted
                      ? 14.r.clamp(12.0, 16.0)
                      : 10.r.clamp(8.0, 12.0),
                  height: isMuted
                      ? 14.r.clamp(12.0, 16.0)
                      : 10.r.clamp(8.0, 12.0),
                  decoration: BoxDecoration(
                    color: isMuted ? mutedRed : activeGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: isMuted
                      ? Center(
                    child: Icon(Icons.mic_off_rounded,
                        color: Colors.white,
                        size: 8.sp.clamp(7.0, 9.5)),
                  )
                      : null,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 3.h.clamp(2.0, 5.0)),
        Text(
          p.name.length > 8 ? "${p.name.substring(0, 7)}." : p.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textDark,
            fontSize: 11.sp.clamp(10.0, 12.5),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 1.h),
        if (isSpeaking)
          Text(
            "Speaking...",
            maxLines: 1,
            style: TextStyle(
              color: primaryPurple,
              fontSize: 9.5.sp.clamp(8.5, 11.0),
              fontWeight: FontWeight.w600,
            ),
          )
        else if (isMuted)
          Text(
            "Muted",
            maxLines: 1,
            style: TextStyle(
              color: mutedRed,
              fontSize: 9.5.sp.clamp(8.5, 11.0),
              fontWeight: FontWeight.w600,
            ),
          )
        else if (isAdmin)
            Text(
              "Admin",
              maxLines: 1,
              style: TextStyle(
                color: primaryPurple,
                fontSize: 9.5.sp.clamp(8.5, 11.0),
                fontWeight: FontWeight.w600,
              ),
            )
          else
            SizedBox(height: 12.h.clamp(10.0, 14.0)),
      ],
    ),
  );
}

Widget headerButton({
  required IconData icon,
  required VoidCallback onTap,
  Color? iconColor,
}) {
  return Container(
    width: 44.r,
    height: 44.r,
    decoration: BoxDecoration(
      color: cardWhite,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        )
      ],
    ),
    child: IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(icon, color: iconColor ?? textDark, size: 20.sp),
      onPressed: onTap,
    ),
  );
}

PopupMenuItem<String> menuItem(String value, IconData icon, String label,
    {Color? color}) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, color: color ?? textDark, size: 18.sp),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            color: color ?? textDark,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
bool isBadImageUrl(String url) {
  if (url.isEmpty) return true;
  if (url.contains('pngitem.com')) return true;
  if (url.contains('placeholder')) return true;
  if (url.contains('default-avatar')) return true;
  return false;
}

String _getInitials(String name) {
  if (name.trim().isEmpty) return "?";
  List<String> parts = name.trim().split(" ");
  if (parts.length > 1) return (parts[0][0] + parts[1][0]).toUpperCase();
  return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
}

Widget buildSafeAvatar(WalkieParticipant p, double radius) {
  final rawImage = p.image;
  if (isBadImageUrl(rawImage)) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: softPurple,
      child: Text(
        _getInitials(p.name),
        style: TextStyle(
          color: primaryPurple,
          fontWeight: FontWeight.w700,
          fontSize: 15.sp,
        ),
      ),
    );
  }
  final fullUrl = rawImage.startsWith('http')
      ? rawImage
      : ConstRes.aImageBaseUrl + rawImage;

  return CircleAvatar(
    radius: radius,
    backgroundColor: softPurple,
    backgroundImage: NetworkImage(fullUrl),
    onBackgroundImageError: (_, __) {
      log('Failed to load profile photo for: ${p.name}');
    },
    child: null,
  );
}



Widget buildCrownGraphic() {
  return SizedBox(
    width: 110.w,
    height: 72.h,
    child: CustomPaint(
      painter: PremiumCrownIllustrationPainter(),
    ),
  );
}