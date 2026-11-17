import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The one back button for app bars: white circle, purple
/// `arrow_back_rounded`, the whole circle tappable. Use it everywhere a
/// screen needs Back so every page looks the same.
///
/// Put it in an app bar that does not change on scroll
/// (`scrolledUnderElevation: 0`, `surfaceTintColor: Colors.transparent`),
/// see [AppBarStyle].
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap, this.color});

  /// Defaults to `Navigator.maybePop`.
  final VoidCallback? onTap;

  /// Icon colour; the brand purple by default.
  final Color? color;

  static const Color purple = Color(0xFF5045B9);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: GestureDetector(
        key: const ValueKey('app_back_button'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap ?? () => Navigator.maybePop(context),
        child: Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: purple.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.arrow_back_rounded,
              color: color ?? purple, size: 20.sp),
        ),
      ),
    );
  }
}

/// App bar settings that keep the bar (and the back button) identical while
/// the page scrolls. Material 3 otherwise tints and elevates the bar under
/// scrolled content, which made the back button look broken.
class AppBarStyle {
  AppBarStyle._();

  static const double scrolledUnderElevation = 0;
  static const Color surfaceTintColor = Colors.transparent;

  /// Width for `leadingWidth` so the 40×40 button has a 16 px side gap.
  static double get leadingWidth => 16.w + 40.w + 8.w;

  /// `leading:` widget with the standard left gap.
  static Widget leading({VoidCallback? onTap}) => Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: Center(child: AppBackButton(onTap: onTap)),
      );
}
