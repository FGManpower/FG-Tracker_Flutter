import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom card presenting the "Coming Soon" information with:
/// - Pulsing chip
/// - Main title & description
/// - Two feature tiles: "Safe Zone" and "Safe Route"
/// Fully responsive across all devices with ScreenUtil.
class ComingSoonCard extends StatelessWidget {
  final Animation<double>? chipPulseAnimation;

  const ComingSoonCard({
    super.key,
    this.chipPulseAnimation,
  });

  static const Color _purple = Color(0xFF704AFA);
  static const Color _routeBlue = Color(0xFF5B5FEF);
  static const Color _redPin = AppColors.darkRed; // #D2042D
  static const Color _chipBg = AppColors.authIconBgCircle; // #EEEDFD
  static const Color _titleNavy = AppColors.darkText; // #0F0B4C
  static const Color _descGrey =
      AppColors.primarySecondaryElementText; // #666666
  static const Color _tileBg = AppColors.primarySecondaryBackground; // #F7F7F9

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(16, 16, 64, 0.14),
            blurRadius: 28.r,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 16.h,
        left: 14.w,
        right: 14.w,
        bottom: 14.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. "COMING SOON" Chip with pulsing dot
          _buildComingSoonChip(),

          SizedBox(height: 7.h),

          // 2. Heading
          Text(
            'Coming Soon',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              fontFamily: FontFamily.interExtraBold,
              color: _titleNavy,
              height: 1.2,
            ),
          ),

          SizedBox(height: 6.h),

          // 3. Subtitle description (centred, responsive max width)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 270.w),
            child: Text(
              'Smart safety features to protect your team are on the way.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                fontFamily: FontFamily.interRegular,
                color: _descGrey,
                height: 1.45,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // 4. Row of 2 equal feature tiles
          Row(
            children: [
              Expanded(
                child: _FeatureTile(
                  title: 'Safe Zone',
                  subtitle: 'Area protection',
                  icon: const _ShieldIcon(),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _FeatureTile(
                  title: 'Safe Route',
                  subtitle: 'Route protection',
                  icon: const _RouteIcon(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.5.h),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPulsingDot(),
          SizedBox(width: 6.w),
          Text(
            'COMING SOON',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              fontFamily: FontFamily.interBold,
              letterSpacing: 1.0,
              color: _purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot() {
    if (chipPulseAnimation == null) {
      return Container(
        width: 6.5.w,
        height: 6.5.w,
        decoration: const BoxDecoration(
          color: _purple,
          shape: BoxShape.circle,
        ),
      );
    }

    return AnimatedBuilder(
      animation: chipPulseAnimation!,
      builder: (context, child) {
        final double t = chipPulseAnimation!.value;
        final double scale = 0.9 + (1.25 - 0.9) * t;
        final double opacity = (0.7 * (1.0 - t)).clamp(0.0, 1.0);

        return SizedBox(
          width: 10.w,
          height: 10.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse halo behind
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 6.5.w,
                  height: 6.5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _purple.withValues(alpha: opacity),
                  ),
                ),
              ),
              // Solid front dot
              Container(
                width: 6.5.w,
                height: 6.5.w,
                decoration: const BoxDecoration(
                  color: _purple,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Feature Tile inside the bottom card
class _FeatureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;

  const _FeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: ComingSoonCard._tileBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 36px circle with background #EEEDFD
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: ComingSoonCard._chipBg,
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.interSemiBold,
                      color: ComingSoonCard._titleNavy,
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: FontFamily.interRegular,
                      color: ComingSoonCard._descGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painted shield icon with white center location dot
class _ShieldIcon extends StatelessWidget {
  const _ShieldIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18.w,
      height: 18.w,
      child: const CustomPaint(
        painter: _ShieldPainter(),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  const _ShieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Shield path
    final path = Path();
    path.moveTo(w * 0.5, h * 0.12);
    path.lineTo(w * 0.84, h * 0.24);
    path.cubicTo(
      w * 0.84,
      h * 0.58,
      w * 0.5,
      h * 0.86,
      w * 0.5,
      h * 0.90,
    );
    path.cubicTo(
      w * 0.5,
      h * 0.86,
      w * 0.16,
      h * 0.58,
      w * 0.16,
      h * 0.24,
    );
    path.close();

    final paint = Paint()
      ..color = ComingSoonCard._routeBlue
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Inner white location dot
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.48), 2.5, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painted route icon with start circle and red pin
class _RouteIcon extends StatelessWidget {
  const _RouteIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18.w,
      height: 18.w,
      child: const CustomPaint(
        painter: _RoutePainter(),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final trackPaint = Paint()
      ..color = ComingSoonCard._routeBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // S-curve track
    final path = Path();
    path.moveTo(w * 0.32, h * 0.68);
    path.cubicTo(
      w * 0.62,
      h * 0.68,
      w * 0.38,
      h * 0.34,
      w * 0.70,
      h * 0.34,
    );
    canvas.drawPath(path, trackPaint);

    // Bottom-left start circle
    final startPaint = Paint()
      ..color = ComingSoonCard._routeBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(Offset(w * 0.30, h * 0.68), 2.5, startPaint);

    // Top-right red pin dot
    final pinPaint = Paint()
      ..color = ComingSoonCard._redPin
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.70, h * 0.32), 2.8, pinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
