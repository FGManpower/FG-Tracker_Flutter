import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fgtracker/l10n/l10n.dart';

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
  const AudioBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: CallColors.audioIncoming,
        ),
      ),
    );
  }
}

/// One round button of the in-call control bar (mute, speaker, camera …).
///
/// * [active]: the toggle is ON (muted, speaker, camera off, sharing). The
///   button is filled (white on video, purple on audio) so the state is
///   clear at a glance, like WhatsApp.
/// * [videoInactive]: the action is not available right now (call not
///   connected yet, upgrade in progress). The button is faded and taps are
///   ignored by the caller.
/// * [iconColor]: optional override of the idle icon colour.
/// * [size]: circle size (52 in a bar, 54 in the connected-audio grid).
/// * [activeIconColor]: icon colour on the filled (active) circle when
///   [isVideo]; purple on the connected-audio screen.
Widget ctrl({
  required IconData icon,
  required String label,
  required bool isVideo,
  required VoidCallback onTap,
  bool active = false,
  bool videoInactive = false,
  Color? iconColor,
  double size = 52,
  Color? activeIconColor,
}) {
  return _CallControlButton(
    icon: icon,
    label: label,
    isVideo: isVideo,
    onTap: onTap,
    active: active,
    disabled: videoInactive,
    iconColor: iconColor,
    size: size,
    activeIconColor: activeIconColor,
  );
}

/// Colours of the 1:1 call screens (design "FG Tracker – Audio / Video
/// call UI options").
class CallColors {
  CallColors._();

  static const Color primary = Color(0xFF5B3FD0);
  static const Color primaryLight = Color(0xFF7B61FF);
  static const Color end = Color(0xFFF04438);
  static const Color accept = Color(0xFF16B364);
  static const Color name = Color(0xFF1B1446);
  static const Color videoBg = Color(0xFF0E0C14);

  /// Glass behind the video controls: rgba(20, 16, 36, .55).
  static const Color videoGlass = Color.fromRGBO(20, 16, 36, 0.55);

  /// Audio · 1 outgoing / connecting.
  static const List<Color> audioRinging = [
    Color(0xFF6B4FE8),
    Color(0xFF4B32B8),
    Color(0xFF2E1F7A),
  ];

  /// Audio · 2 connected.
  static const List<Color> audioConnected = [
    Color(0xFF6B4FE8),
    Color(0xFF4B32B8),
    Color(0xFF2E1F7A),
  ];

  /// Audio · 3 incoming.
  static const List<Color> audioIncoming = [
    Color(0xFF6B4FE8),
    Color(0xFF4B32B8),
    Color(0xFF2E1F7A),
  ];
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.isVideo,
    required this.onTap,
    required this.active,
    required this.disabled,
    this.iconColor,
    this.size = 52,
    this.activeIconColor,
  });

  final IconData icon;
  final String label;
  final bool isVideo;
  final VoidCallback onTap;
  final bool active;
  final bool disabled;
  final Color? iconColor;
  final double size;
  final Color? activeIconColor;

  static const Color _videoActiveIcon = Color(0xFF1B1530);

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (isVideo) {
      bg = active ? Colors.white : Colors.white.withOpacity(0.14);
      fg = active
          ? (activeIconColor ?? _videoActiveIcon)
          : (iconColor ?? Colors.white);
    } else {
      bg = active ? AppColors.primaryPurple : Colors.white;
      fg = active ? Colors.white : (iconColor ?? AppColors.primaryPurple);
    }

    return Semantics(
      button: true,
      enabled: !disabled,
      toggled: active,
      label: label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: disabled ? 0.4 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: size.r,
              height: size.r,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: isVideo && !active
                    ? Border.all(color: Colors.white.withOpacity(0.18))
                    : null,
                boxShadow: isVideo
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primaryPurple
                              .withOpacity(active ? 0.35 : 0.12),
                          blurRadius: active ? 14 : 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Material(
                type: MaterialType.transparency,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  splashColor: (isVideo ? Colors.white : AppColors.primaryPurple)
                      .withOpacity(0.20),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        icon,
                        key: ValueKey<int>(icon.codePoint),
                        color: fg,
                        size: (size * 0.46).r,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 7.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: (size + 12).w),
              child: AutoFitText(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: isVideo
                      ? Colors.white.withOpacity(0.92)
                      : CallColors.name.withOpacity(0.85),
                  fontFamily: FontFamily.interMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Red hang-up button of the in-call control bar. [size] 52 sits in a row
/// with the other controls; 68 is the big stand-alone button.
Widget endCallButton({
  required String label,
  required bool isVideo,
  required VoidCallback onTap,
  double size = 64,
}) {
  const Color red = CallColors.end;
  return Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size.r,
          height: size.r,
          decoration: BoxDecoration(
            color: red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: red.withOpacity(0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const ValueKey<String>('call_end_button'),
              onTap: onTap,
              splashColor: Colors.white24,
              child: Center(
                child: Icon(Icons.call_end_rounded,
                    color: Colors.white, size: (size * 0.46).r),
              ),
            ),
          ),
        ),
        SizedBox(height: 7.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 70.w),
          child: AutoFitText(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size >= 64 ? 13.sp : 11.5.sp,
              color: isVideo
                  ? Colors.white.withOpacity(0.92)
                  : CallColors.name.withOpacity(0.85),
              fontFamily: FontFamily.interMedium,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Round profile picture of the other person on the call screens. Falls
/// back to the first letter of [name] on a colour picked from the name
/// when there is no picture or it fails to load.
class CallAvatar extends StatelessWidget {
  const CallAvatar({
    super.key,
    required this.name,
    required this.image,
    required this.size,
    this.ringColor,
  });

  final String name;

  /// Full URL, server path, or null / empty / "false".
  final Object? image;
  final double size;

  /// Optional outline (green on the incoming audio screen, white on dark).
  final Color? ringColor;

  static const List<Color> _palette = <Color>[
    Color(0xFF7B58FF),
    Color(0xFFFF7A45),
    Color(0xFF14B8A6),
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
    Color(0xFF22A06B),
    Color(0xFFF59E0B),
  ];

  static String? resolveUrl(Object? raw) {
    if (raw == null) return null;
    final String path = raw.toString().trim();
    if (path.isEmpty || path == 'null' || path == 'false') return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final base = ConstRes.aImageBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    final clean = path.replaceFirst(RegExp(r'^/+'), '');
    final resolved = clean.startsWith('uploads/') ? clean : 'uploads/Auth/$clean';
    return '$base/$resolved';
  }

  Widget _initial() {
    final String n = name.trim();
    final Color bg = n.isEmpty
        ? _palette.first
        : _palette[n.codeUnits.fold<int>(0, (a, b) => a + b) % _palette.length];
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: n.isEmpty
          ? Icon(Icons.person_rounded, color: Colors.white, size: size * 0.5)
          : Text(
              n.characters.first.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.40,
                fontFamily: FontFamily.interSemiBold,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? url = resolveUrl(image);
    final Widget pic = url == null
        ? _initial()
        : Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initial(),
          );
    return Container(
      width: size,
      height: size,
      padding: ringColor == null ? null : EdgeInsets.all(size * 0.035),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ringColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(child: SizedBox.expand(child: pic)),
    );
  }
}

/// "05:07" or "1:05:07" for a call duration in seconds (the controller's
/// own formatter has no hours).
String formatCallDuration(int totalSeconds) {
  final int h = totalSeconds ~/ 3600;
  final String m = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final String s = (totalSeconds % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
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

/// Translated text for a section title made by [formatSectionTitle]
/// (the English title stays the stable map key).
String localizedSectionTitle(AppLocalizations l, String title) {
  switch (title) {
    case 'Recent':
      return l.call_tabRecent;
    case 'Today':
      return l.common_today;
    case 'Yesterday':
      return l.common_yesterday;
    case 'This Week':
      return l.call_sectionThisWeek;
    case 'Last Week':
      return l.call_sectionLastWeek;
    case 'Older':
      return l.call_sectionOlder;
  }
  return title;
}

/// Translated call type label for a recent-call row, built from the stable
/// `typeStatus` / `typeKind` / `typeGroup` fields of the row.
String recentCallTypeLabel(AppLocalizations l, Map<String, String> call) {
  if (!call.containsKey('typeKind')) return call['type'] ?? '';
  final String status = call['typeStatus'] ?? '';
  final String kind = call['typeKind'] ?? 'call';
  final bool group = call['typeGroup'] == 'true';
  final String callType = callKindLabel(l, kind, group: group);
  switch (status) {
    case 'missed':
      return l.call_historyMissed(callType);
    case 'rejected':
      return l.call_historyRejected(callType);
    case 'outgoing':
      return l.call_historyOutgoing(callType);
    case 'incoming':
      return l.call_historyIncoming(callType);
  }
  return callType;
}

/// "Video Call" / "Group Audio Call" / "Call" … in the app language.
/// [kind] is 'video', 'audio', 'call' or a raw API type.
String callKindLabel(AppLocalizations l, String kind, {bool group = false}) {
  switch (kind.toLowerCase()) {
    case 'video':
      return group ? l.call_kindGroupVideo : l.call_kindVideo;
    case 'audio':
      return group ? l.call_kindGroupAudio : l.call_kindAudio;
    case 'call':
    case '':
      return group ? l.call_kindGroupCall : l.call_kindCall;
  }
  return group ? l.call_kindGroupOther(kind) : l.call_kindOther(kind);
}

/// Translated text for a call status value (`callStatus` of the calling
/// controllers). Our own values ("Calling", "Connected", "Reconnecting...")
/// and known server values are mapped; any other server value is shown as is.
String callStatusLabel(AppLocalizations l, String status) {
  final String base = status.trim().replaceAll(RegExp(r'[.…]+$'), '');
  switch (base.toLowerCase()) {
    case 'calling':
      return l.call_statusCalling;
    case 'connecting':
      return l.call_statusConnecting;
    case 'connected':
      return l.call_statusConnected;
    case 'video connecting':
      return l.call_statusVideoConnecting;
    case 'reconnecting':
      return l.call_statusReconnecting;
    case 'ringing':
      return l.call_statusRinging;
    case 'busy':
      return l.call_statusBusy;
    // 1:1 call screen (calling Phase 3): callee on another call, CallKit hold.
    case 'on another call':
      return l.call_onAnotherCall;
    case 'on hold':
      return l.call_onHold;
  }
  return base;
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
  if (raw.trim().isEmpty) return appL10n.call_unknown;
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
  static String get selfCallWarningMessage => appL10n.call_selfCallWarning;

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

