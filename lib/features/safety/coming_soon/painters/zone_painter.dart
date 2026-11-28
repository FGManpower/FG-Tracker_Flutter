import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated CustomPainter rendering:
/// - Safe zone breathing circle (fill & dashed stroke)
/// - Radar sweep (60° wedge + leading edge line)
/// - 3 expanding pulse rings
/// - Static inner guide ring
/// - Animated dashed route
/// - Start & End location pins
/// - Team member dots
/// - "Me" dot with expanding pulse halo
class ZonePainter extends CustomPainter {
  final Animation<double> zoneBreathAnimation;
  final Animation<double> sweepAnimation;
  final Animation<double> ringsAnimation;
  final Animation<double> routeDashAnimation;
  final Animation<double> mePulseAnimation;

  ZonePainter({
    required this.zoneBreathAnimation,
    required this.sweepAnimation,
    required this.ringsAnimation,
    required this.routeDashAnimation,
    required this.mePulseAnimation,
  }) : super(
          repaint: Listenable.merge([
            zoneBreathAnimation,
            sweepAnimation,
            ringsAnimation,
            routeDashAnimation,
            mePulseAnimation,
          ]),
        );

  // Feature-specific colors
  static const Color _purple = Color(0xFF704AFA);
  static const Color _routeBlue = Color(0xFF5B5FEF);
  static const Color _pinRed = Color(0xFFD2042D);
  static const Color _teamGreen = Color(0xFF2F8A5B);

  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 390.0;
    final double sy = size.height / 844.0;
    final double scaleUniform = (sx + sy) / 2.0;

    double scaleX(double x) => x * sx;
    double scaleY(double y) => y * sy;
    Offset pt(double x, double y) => Offset(scaleX(x), scaleY(y));

    // Zone Center C and Radius R
    final Offset centerC = pt(175, 300);
    final double radiusR = 112.0 * scaleUniform;

    // Current zone breathing opacity: 0.55 <-> 1.0
    final double breathFactor = zoneBreathAnimation.value.clamp(0.0, 1.0);
    final double zoneOpacity = 0.55 + (1.0 - 0.55) * breathFactor;

    // -------------------------------------------------------------------------
    // 1. Safe zone circle: fill #704AFA 12%, stroke #704AFA 2px dashed 8/8
    // -------------------------------------------------------------------------
    final safeZoneFillPaint = Paint()
      ..color = _purple.withValues(alpha: (0.12 * zoneOpacity).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centerC, radiusR, safeZoneFillPaint);

    final safeZoneStrokePaint = Paint()
      ..color = _purple.withValues(alpha: zoneOpacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scaleUniform;

    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: centerC, radius: radiusR));
    final dashedCirclePath = createDashedPath(
      circlePath,
      8.0 * scaleUniform,
      8.0 * scaleUniform,
    );
    canvas.drawPath(dashedCirclePath, safeZoneStrokePaint);

    // -------------------------------------------------------------------------
    // 2. Clipped Area (radius 111 at C): Radar sweep, 3 expanding rings, inner guide
    // -------------------------------------------------------------------------
    canvas.save();
    final clipRadius = radiusR * (111.0 / 112.0);
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: centerC, radius: clipRadius)),
    );

    // a) Radar sweep: 60° wedge from C, starting pointing straight up (-pi/2),
    // rotating 360° in 4 s, linear, infinite.
    final double sweepRotation = sweepAnimation.value * 2 * math.pi;
    final double startAngle = -math.pi / 2 + sweepRotation;
    const double sweepSpan = math.pi / 3; // 60 degrees

    final wedgePath = Path();
    wedgePath.moveTo(centerC.dx, centerC.dy);
    wedgePath.arcTo(
      Rect.fromCircle(center: centerC, radius: radiusR),
      startAngle,
      sweepSpan,
      false,
    );
    wedgePath.close();

    final wedgePaint = Paint()
      ..color = _purple.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawPath(wedgePath, wedgePaint);

    // Leading edge line C -> (175, 188) rotated, #704AFA 60%, 2px
    final leadingEdgeEnd = Offset(
      centerC.dx + radiusR * math.cos(startAngle),
      centerC.dy + radiusR * math.sin(startAngle),
    );
    final leadingEdgePaint = Paint()
      ..color = _purple.withValues(alpha: 0.60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scaleUniform;
    canvas.drawLine(centerC, leadingEdgeEnd, leadingEdgePaint);

    // b) 3 expanding rings: stroke #704AFA 2px, radius 14->110, opacity 0.9->0,
    // 3 s easeOut, infinite, delays 0 s, 1 s, 2 s (offsets 0, 1/3, 2/3).
    for (int i = 0; i < 3; i++) {
      double t = (ringsAnimation.value - (i / 3.0)) % 1.0;
      if (t < 0) t += 1.0;

      final double progress = Curves.easeOut.transform(t);
      final double ringRadius = (14.0 + (110.0 - 14.0) * progress) * scaleUniform;
      final double ringOpacity = (0.9 * (1.0 - progress)).clamp(0.0, 1.0);

      if (ringOpacity > 0.01) {
        final ringPaint = Paint()
          ..color = _purple.withValues(alpha: ringOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * scaleUniform;
        canvas.drawCircle(centerC, ringRadius, ringPaint);
      }
    }

    // c) Static inner guide ring: radius 56, #704AFA 25%, 1.2px, dashed 3/5.
    final guideRadius = 56.0 * scaleUniform;
    final guideCirclePath = Path()
      ..addOval(Rect.fromCircle(center: centerC, radius: guideRadius));
    final dashedGuidePath = createDashedPath(
      guideCirclePath,
      3.0 * scaleUniform,
      5.0 * scaleUniform,
    );
    final guidePaint = Paint()
      ..color = _purple.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * scaleUniform;
    canvas.drawPath(dashedGuidePath, guidePaint);

    canvas.restore(); // Restore clip

    // -------------------------------------------------------------------------
    // 3. Route: M 70,505 C 100,470 110,430 150,418 S 230,400 245,330 S 290,230 320,200
    // stroke #5B5FEF 5px, round cap, dashed 12/8; dash phase 0 → −40 in 1.6 s
    // -------------------------------------------------------------------------
    final routePath = Path();
    routePath.moveTo(scaleX(70), scaleY(505));
    routePath.cubicTo(
      scaleX(100), scaleY(470),
      scaleX(110), scaleY(430),
      scaleX(150), scaleY(418),
    );
    // S 230,400 245,330 (reflected control point of (110,430) around (150,418) is (190,406))
    routePath.cubicTo(
      scaleX(190), scaleY(406),
      scaleX(230), scaleY(400),
      scaleX(245), scaleY(330),
    );
    // S 290,230 320,200 (reflected control point of (230,400) around (245,330) is (260,260))
    routePath.cubicTo(
      scaleX(260), scaleY(260),
      scaleX(290), scaleY(230),
      scaleX(320), scaleY(200),
    );

    final double routeDashPhase = -40.0 * routeDashAnimation.value * scaleUniform;
    final dashedRoute = createDashedPath(
      routePath,
      12.0 * scaleUniform,
      8.0 * scaleUniform,
      phase: routeDashPhase,
    );

    final routePaint = Paint()
      ..color = _routeBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0 * scaleUniform
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(dashedRoute, routePaint);

    // -------------------------------------------------------------------------
    // 4. Pins (teardrop 28 x 36, tip at bottom, white centre dot r5)
    // start at (70,496) #5B5FEF; end at (320,190) #D2042D.
    // -------------------------------------------------------------------------
    _drawPin(canvas, pt(70, 496), _routeBlue, scaleUniform);
    _drawPin(canvas, pt(320, 190), _pinRed, scaleUniform);

    // -------------------------------------------------------------------------
    // 5. Team members (static): (120,250), (225,360), (205,230)
    // white circle r12 + #2F8A5B circle r8.
    // -------------------------------------------------------------------------
    const teamCoords = [
      [120.0, 250.0],
      [225.0, 360.0],
      [205.0, 230.0],
    ];

    for (final coord in teamCoords) {
      final teamPt = pt(coord[0], coord[1]);
      // Subtle shadow
      canvas.drawShadow(
        Path()..addOval(Rect.fromCircle(center: teamPt, radius: 12.0 * scaleUniform)),
        Colors.black.withValues(alpha: 0.15),
        2.5 * scaleUniform,
        false,
      );
      // White outer circle r12
      final whitePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(teamPt, 12.0 * scaleUniform, whitePaint);

      // Green inner circle r8
      final greenPaint = Paint()
        ..color = _teamGreen
        ..style = PaintingStyle.fill;
      canvas.drawCircle(teamPt, 8.0 * scaleUniform, greenPaint);
    }

    // -------------------------------------------------------------------------
    // 6. "Me" dot at C:
    // - halo #704AFA radius 10→30, opacity 0.6→0, 2 s easeOut, infinite
    // - Visual match with screenshot: purple ring r13 with white inner center r7.5
    // -------------------------------------------------------------------------
    final double mePulseProgress = Curves.easeOut.transform(mePulseAnimation.value);
    final double haloRadius = (10.0 + (30.0 - 10.0) * mePulseProgress) * scaleUniform;
    final double haloOpacity = (0.6 * (1.0 - mePulseProgress)).clamp(0.0, 1.0);

    if (haloOpacity > 0.01) {
      final haloPaint = Paint()
        ..color = _purple.withValues(alpha: haloOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centerC, haloRadius, haloPaint);
    }

    // Subtle drop shadow for "Me" dot
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: centerC, radius: 13.0 * scaleUniform)),
      Colors.black.withValues(alpha: 0.20),
      3.0 * scaleUniform,
      false,
    );

    // Purple circle r13
    final mePurplePaint = Paint()
      ..color = _purple
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centerC, 13.0 * scaleUniform, mePurplePaint);

    // Inner white circle r7.5
    final meWhitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centerC, 7.5 * scaleUniform, meWhitePaint);
  }

  /// Draws a smooth 28x36 teardrop map pin with tip at [tip] and white center dot
  void _drawPin(Canvas canvas, Offset tip, Color color, double scale) {
    final double w = 28.0 * scale;
    final double h = 36.0 * scale;
    final double r = w / 2.0;
    final Offset headCenter = Offset(tip.dx, tip.dy - h + r);

    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    // Left curve toward head
    path.cubicTo(
      tip.dx - w * 0.52, tip.dy - h * 0.45,
      tip.dx - r, headCenter.dy + r * 0.45,
      tip.dx - r, headCenter.dy,
    );
    // Arc across the circular head
    path.arcTo(
      Rect.fromCircle(center: headCenter, radius: r),
      math.pi,
      math.pi,
      false,
    );
    // Right curve back to tip
    path.cubicTo(
      tip.dx + r, headCenter.dy + r * 0.45,
      tip.dx + w * 0.52, tip.dy - h * 0.45,
      tip.dx, tip.dy,
    );
    path.close();

    // Drop shadow
    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.28),
      3.5 * scale,
      false,
    );

    // Pin body
    final pinPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, pinPaint);

    // White center dot r5
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(headCenter, 5.0 * scale, dotPaint);
  }

  /// Helper to convert any path to a dashed path with exact phase support
  static Path createDashedPath(
    Path source,
    double dashLength,
    double gapLength, {
    double phase = 0.0,
  }) {
    final Path dest = Path();
    final double period = dashLength + gapLength;
    if (period <= 0) return source;

    for (final metric in source.computeMetrics()) {
      final double totalLength = metric.length;
      if (totalLength <= 0) continue;

      double effectivePhase = phase % period;
      if (effectivePhase > 0) effectivePhase -= period;

      double distance = effectivePhase;
      while (distance < totalLength) {
        final double dashStart = math.max(0.0, distance);
        final double dashEnd = math.min(totalLength, distance + dashLength);
        if (dashEnd > dashStart) {
          dest.addPath(metric.extractPath(dashStart, dashEnd), Offset.zero);
        }
        distance += period;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant ZonePainter oldDelegate) => true;
}
