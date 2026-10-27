import 'dart:math' as math;
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/features/safety/coming_soon/painters/map_painter.dart';
import 'package:fgtracker/features/safety/coming_soon/painters/zone_painter.dart';
import 'package:fgtracker/features/safety/coming_soon/widgets/coming_soon_card.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Safety - Coming Soon (Map) Screen
///
/// Features:
/// - Fully responsive across all device sizes using ScreenUtil (.w, .h, .sp, .r)
/// - Offline custom-drawn vector map (river, roads, parks, building blocks, labels)
/// - Safe zone breathing circle (0.55 <-> 1.0 opacity, 2.4s easeInOut)
/// - Rotating radar sweep (360° in 4s, linear)
/// - 3 expanding pulse rings (delays 0s, 1s, 2s, 3s cycle easeOut)
/// - Static dashed inner guide ring
/// - Animated dashed route (dash phase 0 -> -40 in 1.6s)
/// - Start & destination teardrop pins
/// - "Me" dot with expanding pulse halo
/// - Team member dots
/// - Responsive top bar (Back button + "Safety" pill styled matching app's AppBar standards)
/// - Bottom card with pulsing chip and feature tiles
class SafetyComingSoonMapScreen extends StatefulWidget {
  const SafetyComingSoonMapScreen({super.key});

  @override
  State<SafetyComingSoonMapScreen> createState() =>
      _SafetyComingSoonMapScreenState();
}

class _SafetyComingSoonMapScreenState extends State<SafetyComingSoonMapScreen>
    with TickerProviderStateMixin {
  late final AnimationController _zoneBreathController;
  late final Animation<double> _zoneBreathAnimation;

  late final AnimationController _sweepController;
  late final AnimationController _ringsController;
  late final AnimationController _routeDashController;
  late final AnimationController _mePulseController;
  late final AnimationController _chipPulseController;

  bool _isAnimationRunning = false;

  @override
  void initState() {
    super.initState();

    // 1. Zone Breathing: 2.4 s, easeInOut, repeat reverse
    _zoneBreathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _zoneBreathAnimation = CurvedAnimation(
      parent: _zoneBreathController,
      curve: Curves.easeInOut,
    );

    // 2. Radar sweep: 4 s, linear, infinite repeat
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // 3. 3 expanding rings: 3 s, infinite repeat
    _ringsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 4. Route dash: 1.6 s, linear, infinite repeat
    _routeDashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // 5. "Me" dot pulse: 2 s, infinite repeat
    _mePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 6. Chip pulse: 2 s, infinite repeat
    _chipPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _startAnimations();
  }

  void _startAnimations() {
    if (_isAnimationRunning) return;
    _isAnimationRunning = true;
    _zoneBreathController.repeat(reverse: true);
    _sweepController.repeat();
    _ringsController.repeat();
    _routeDashController.repeat();
    _mePulseController.repeat();
    _chipPulseController.repeat();
  }

  void _stopAnimations() {
    if (!_isAnimationRunning) return;
    _isAnimationRunning = false;
    _zoneBreathController.stop();
    _sweepController.stop();
    _ringsController.stop();
    _routeDashController.stop();
    _mePulseController.stop();
    _chipPulseController.stop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      _stopAnimations();
    } else {
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _zoneBreathController.dispose();
    _sweepController.dispose();
    _ringsController.dispose();
    _routeDashController.dispose();
    _mePulseController.dispose();
    _chipPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final double topBarTop = math.max(statusBarHeight + 8.h, 48.h);
    final double cardBottom = math.max(20.h, bottomInset + 8.h);

    return Scaffold(
      backgroundColor: const Color(0xFFEEF0F5),
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 1. Static Map layer (scales dynamically to viewport)
            const Positioned.fill(
              child: CustomPaint(
                painter: MapPainter(),
              ),
            ),

            // 2. Animated Zone, Radar, Route, Pins & Dots layer
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: ZonePainter(
                    zoneBreathAnimation: _zoneBreathAnimation,
                    sweepAnimation: _sweepController,
                    ringsAnimation: _ringsController,
                    routeDashAnimation: _routeDashController,
                    mePulseAnimation: _mePulseController,
                  ),
                ),
              ),
            ),

            // 3. Responsive Top bar (Back button + "Safety" pill)
            Positioned(
              top: topBarTop,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  _buildBackButton(context),
                  SizedBox(width: 12.w),
                  _buildSafetyPill(),
                ],
              ),
            ),

            // 4. Responsive Bottom card
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: cardBottom,
              child: ComingSoonCard(
                chipPulseAnimation: _chipPulseController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(13.r),
          child: Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13.r),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(16, 16, 64, 0.10),
                  blurRadius: 12.r,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.sp,
                color: const Color(0xFF704AFA),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyPill() {
    return Container(
      height: 42.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.r),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(16, 16, 64, 0.10),
            blurRadius: 12.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'Safety',
        style: TextStyle(
          fontSize: 15.5.sp,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.interSemiBold,
          color: AppColors.darkText,
        ),
      ),
    );
  }
}
