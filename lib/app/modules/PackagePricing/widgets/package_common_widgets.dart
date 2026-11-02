import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Data/Repositories/package_pricing_repo.dart';
import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// Shared look for the Package Pricing screens — app primary colour + Inter font
class PackageUi {
  PackageUi._();
  static const Color accent = AppColors.primaryDarkblue;
  static const Color bg = AppColors.primarySecondaryBackground;
  static const Color text = AppColors.darkText;
  static const Color textSecondary = AppColors.primarySecondaryElementText;
  static const Color border = Color(0xFFE6E4F0);
  static const Color divider = Color(0xFFF1F1F4);
  static const Color green = Color(0xFF15803D);
  static const Color greenBg = AppColors.greenLight;
  static const Color shadow = Color.fromRGBO(16, 16, 64, 0.06);
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  /// Keeps the layout phone-sized on tablets / landscape
  static const double maxContentWidth = 520;

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(color: shadow, offset: Offset(0, 2), blurRadius: 10),
      ];
}

/// Icon + accent colour per module. Backend `themeColor` overrides the colour.
class PackageModuleStyle {
  final IconData icon;
  final Color color;

  const PackageModuleStyle(this.icon, this.color);

  static PackageModuleStyle of(String moduleKey, {String? hexColor}) {
    final base = switch (moduleKey) {
      PackageModuleKey.attendance =>
        const PackageModuleStyle(Icons.how_to_reg_rounded, Color(0xFF16A34A)),
      PackageModuleKey.walkieTalkie => const PackageModuleStyle(
          Icons.settings_voice_rounded, PackageUi.accent),
      PackageModuleKey.safeZoneRoute => const PackageModuleStyle(
          Icons.shield_rounded, Color(0xFFEA580C)),
      PackageModuleKey.liveTracking => const PackageModuleStyle(
          Icons.my_location_rounded, Color(0xFF2563EB)),
      _ => const PackageModuleStyle(
          Icons.workspace_premium_rounded, PackageUi.accent),
    };
    final custom = _parseHex(hexColor);
    return custom == null ? base : PackageModuleStyle(base.icon, custom);
  }

  static Color? _parseHex(String? hex) {
    if (hex == null) return null;
    var h = hex.replaceAll('#', '').trim();
    if (h.length == 6) h = 'FF$h';
    if (h.length != 8) return null;
    final v = int.tryParse(h, radix: 16);
    return v == null ? null : Color(v);
  }
}

/// ₹1,499 / ₹82.50 (Indian grouping)
String formatPackageMoney(num value, [String currency = 'INR']) {
  final code = currency.toUpperCase();
  final symbol = code == 'INR' ? '₹' : '$code ';
  final rounded = (value * 100).round() / 100;
  final whole = rounded == rounded.roundToDouble();
  return NumberFormat.currency(
    locale: 'en_IN',
    symbol: symbol,
    decimalDigits: whole ? 0 : 2,
  ).format(rounded);
}

/// "2026-12-31" → "31 Dec 2026"
String? formatPackageDate(String? iso) {
  if (iso == null) return null;
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final local = d.toLocal();
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}

/// Rounded tile with the module icon (or backend icon image)
class PackageModuleIcon extends StatelessWidget {
  final PackageModuleStyle style;
  final String? iconUrl;
  final double size;

  const PackageModuleIcon({
    super.key,
    required this.style,
    this.iconUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(style.icon, color: style.color, size: size * 0.52);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: (iconUrl == null || iconUrl!.isEmpty)
          ? fallback
          : CachedNetworkImage(
              imageUrl: iconUrl!,
              width: size * 0.56,
              height: size * 0.56,
              fit: BoxFit.contain,
              placeholder: (_, __) => fallback,
              errorWidget: (_, __, ___) => fallback,
            ),
    );
  }
}

class PackageBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const PackageBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Back',
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: const [
              BoxShadow(
                  color: PackageUi.shadow, offset: Offset(0, 1), blurRadius: 6),
            ],
          ),
          child: Icon(Icons.chevron_left_rounded,
              size: 24.sp, color: PackageUi.text),
        ),
      ),
    );
  }
}

/// Back button + title (+ optional subtitle)
class PackageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  const PackageHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PackageBackButton(onTap: onBack),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontFamily: FontFamily.interBold,
                  fontWeight: FontWeight.w700,
                  color: PackageUi.text,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interRegular,
                    color: PackageUi.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class PackageSectionTitle extends StatelessWidget {
  final String text;
  final String? trailing;
  const PackageSectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: FontFamily.interBold,
                  fontWeight: FontWeight.w700,
                  color: PackageUi.text,
                ),
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontFamily: FontFamily.interMedium,
                color: PackageUi.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Small rounded label: "Popular", "Save 20%", "Active"
class PackagePill extends StatelessWidget {
  final String text;
  final Color color;
  final Color? background;
  final IconData? icon;

  const PackagePill({
    super.key,
    required this.text,
    required this.color,
    this.background,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: color),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            maxLines: 1,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontFamily: FontFamily.interSemiBold,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error / empty state with a Retry button
class PackageStatusView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isEmpty;

  const PackageStatusView({
    super.key,
    required this.message,
    required this.onRetry,
    this.isEmpty = false,
  });

  bool get _isOffline {
    final m = message.toLowerCase();
    return m.contains('internet') ||
        m.contains('network') ||
        m.contains('connection');
  }

  @override
  Widget build(BuildContext context) {
    final icon = isEmpty
        ? Icons.inventory_2_outlined
        : (_isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: PackageUi.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30.sp, color: PackageUi.accent),
            ),
            SizedBox(height: 14.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontFamily: FontFamily.interMedium,
                color: PackageUi.text,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 18.sp),
              label: const Text('Try again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PackageUi.accent,
                side: const BorderSide(color: PackageUi.accent),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                textStyle: TextStyle(
                  fontSize: 13.5.sp,
                  fontFamily: FontFamily.interSemiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Debug-only strip so sample prices are never mistaken for real ones
class PackageSampleDataBanner extends StatelessWidget {
  const PackageSampleDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!PackagePricingRepo.useMock) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DE),
        border: Border.all(color: const Color(0xFFF2C46D)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        'Sample data (debug) — connect the /packages API to show real prices.',
        style: TextStyle(
          fontSize: 11.5.sp,
          fontFamily: FontFamily.interMedium,
          color: const Color(0xFF5C3D00),
        ),
      ),
    );
  }
}
