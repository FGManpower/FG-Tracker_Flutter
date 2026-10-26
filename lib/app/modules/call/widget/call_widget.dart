import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallActionChip extends StatelessWidget {
  const CallActionChip({
    super.key,
    required this.icon,
    this.onTap,
    this.size,
    this.iconSize,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double? size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final double buttonSize = size ?? 38.w;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F0FE),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: iconSize ?? 18.sp,
          color: const Color(0xFF4818F0),
        ),
      ),
    );
  }
}

class AudioBackground extends StatelessWidget {
  const AudioBackground();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE9E6FF),
            Color(0xFFF4F2FF),
            Color(0xFFEDE9FF),
          ],
        ),
      ),
    );
  }
}

Widget ctrl({
  required IconData icon,
  required String label,
  required bool isVideo,
  required VoidCallback onTap,
  bool active = false,
  bool videoInactive = false,
  Color? iconColor,
}) {
  final Color baseIcon =
      iconColor ?? (isVideo ? Colors.white : AppColors.primaryPurple);
  final Color bg = isVideo
      ? Colors.white.withOpacity(active ? 0.28 : 0.14)
      : Colors.white.withOpacity(active ? 0.95 : 0.85);

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46.r,
          height: 46.r,
          decoration: BoxDecoration(
            color: videoInactive?Colors.grey:bg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: baseIcon, size: 22.sp),
        ),
      ),
      SizedBox(height: 6.h),
      Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: isVideo ? Colors.white : AppColors.darkText,
          fontFamily: FontFamily.interMedium,
        ),
      ),
    ],
  );
}


Widget sheetDivider() {
  return Divider(
    height: 1,
    thickness: 1,
    color: const Color(0xFFF0EEF8),
    indent: 18.w,
    endIndent: 18.w,
  );
}

Widget sheetTile({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18.r),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryPurple, size: 24.sp),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 16.sp,
                fontFamily: FontFamily.interMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primaryPurple.withOpacity(0.7),
            size: 24.sp,
          ),
        ],
      ),
    ),
  );
}

String formatSectionTitle(String raw) {
  if (raw.isEmpty) return 'Recent';
  final lower = raw.toLowerCase().replaceAll(RegExp(r'[_-]'), ' ').trim();
  if (lower == 'today') return 'Today';
  if (lower == 'yesterday') return 'Yesterday';
  if (lower == 'this week' || lower == 'thisweek' || lower == 'week') {
    return 'This Week';
  }
  if (lower == 'last week' || lower == 'lastweek') return 'Last Week';
  if (lower == 'older') return 'Older';

  return lower.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}

String formatPhoneForDisplay(String raw) {
  if (raw.trim().isEmpty) return 'Unknown';
  final clean = raw.trim();
  final digits = clean.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 10) {
    return "+91 ${digits.substring(0, 5)} ${digits.substring(5)}";
  } else if (digits.length == 12 && digits.startsWith('91')) {
    final sub = digits.substring(2);
    return "+91 ${sub.substring(0, 5)} ${sub.substring(5)}";
  }
  if (!clean.startsWith('+') && digits.length >= 10) {
    return "+$clean";
  }
  return clean;
}

String normalizePhone(String phone) {
  String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('91') && digits.length > 10) {
    digits = digits.substring(2);
  }
  if (digits.length > 10) {
    digits = digits.substring(digits.length - 10);
  }
  return digits;
}

class CallValidation {
  /// Warning message displayed when calling own number
  static const String selfCallWarningMessage = "You cannot call your own number.";

  /// Returns the current logged-in user's phone number if available.
  static String? get currentUserPhone {
    try {
      final phone =
          Global.storageServices.get(PrefConst.userPhone)?.toString().trim();
      if (phone != null && phone.isNotEmpty) return phone;
    } catch (_) {}
    return null;
  }

  /// Returns current user's userId.
  static String? get currentUserId {
    try {
      final uid =
          Global.storageServices.get(PrefConst.userId)?.toString().trim();
      if (uid != null && uid.isNotEmpty) return uid;
    } catch (_) {}
    return null;
  }

  /// Compares two phone numbers accounting for formatting differences and country codes.
  static bool isSamePhoneNumber(String? phoneA, String? phoneB) {
    if (phoneA == null || phoneB == null) return false;
    final cleanA = phoneA.trim();
    final cleanB = phoneB.trim();
    if (cleanA.isEmpty || cleanB.isEmpty) return false;

    final digitsA = cleanA.replaceAll(RegExp(r'[^0-9]'), '');
    final digitsB = cleanB.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsA.isEmpty || digitsB.isEmpty) return false;

    // Exact raw digits match
    if (digitsA == digitsB) return true;

    // Normalized (national 10-digit) match
    final normA = normalizePhone(cleanA);
    final normB = normalizePhone(cleanB);
    if (normA.isNotEmpty && normB.isNotEmpty && normA == normB) {
      if (normA.length >= 7) {
        final bool aHasPlus = cleanA.startsWith('+');
        final bool bHasPlus = cleanB.startsWith('+');
        if (aHasPlus && bHasPlus && digitsA != digitsB) {
          return false;
        }
        if (aHasPlus && !cleanA.startsWith('+91') && !bHasPlus) {
          return false;
        }
        if (bHasPlus && !cleanB.startsWith('+91') && !aHasPlus) {
          return false;
        }
        return true;
      }
    }

    return false;
  }

  /// Checks whether destination phone or userId belongs to current user.
  static bool isSelfCall(
      {String? destinationPhone, String? destinationUserId}) {
    final myId = currentUserId;
    if (myId != null &&
        myId.isNotEmpty &&
        destinationUserId != null &&
        destinationUserId.isNotEmpty) {
      if (myId == destinationUserId.trim()) return true;
    }

    final myPhone = currentUserPhone;
    if (myPhone != null &&
        myPhone.isNotEmpty &&
        destinationPhone != null &&
        destinationPhone.isNotEmpty) {
      if (isSamePhoneNumber(myPhone, destinationPhone)) return true;
    }

    return false;
  }

  /// Validates before a call. If it's the user's own number, displays warning toast and returns false.
  static bool validateCall(
      {String? destinationPhone, String? destinationUserId}) {
    if (isSelfCall(
      destinationPhone: destinationPhone,
      destinationUserId: destinationUserId,
    )) {
      Utils().fluttertoast(selfCallWarningMessage);
      return false;
    }
    return true;
  }
}

