import 'dart:math' as math;
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

/// Static Map CustomPainter rendering city background, river, parks,
/// building blocks, roads, and road/place labels in the 390x844 design space.
class MapPainter extends CustomPainter {
  const MapPainter();

  // Feature-specific map colors as private constants
  static const Color _bgColor = Color(0xFFEEF0F5);
  static const Color _riverColor = Color(0xFFCFE3F7);
  static const Color _parkColor = Color(0xFFD7EED9);
  static const Color _buildingColor = Color(0xFFE2E5EF);
  static const Color _stripeColor = Color(0xFFFFE7A8);
  static const Color _labelColor = Color(0xFF9AA0B4);

  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 390.0;
    final double sy = size.height / 844.0;
    final double scaleUniform = (sx + sy) / 2.0;

    double scaleX(double x) => x * sx;
    double scaleY(double y) => y * sy;
    Offset pt(double x, double y) => Offset(x * sx, y * sy);

    // 1. Map Background
    final bgPaint = Paint()..color = _bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. River fill
    // M -10,640 C 60,610 120,650 190,630 S 320,600 400,630 L 400,700
    // C 320,680 250,710 180,700 S 60,690 -10,715 Z
    final riverPaint = Paint()
      ..color = _riverColor
      ..style = PaintingStyle.fill;
    final riverPath = Path();
    riverPath.moveTo(scaleX(-10), scaleY(640));
    riverPath.cubicTo(
      scaleX(60), scaleY(610),
      scaleX(120), scaleY(650),
      scaleX(190), scaleY(630),
    );
    // S 320,600 400,630 (reflection of 120,650 around 190,630 is 260,610)
    riverPath.cubicTo(
      scaleX(260), scaleY(610),
      scaleX(320), scaleY(600),
      scaleX(400), scaleY(630),
    );
    riverPath.lineTo(scaleX(400), scaleY(700));
    riverPath.cubicTo(
      scaleX(320), scaleY(680),
      scaleX(250), scaleY(710),
      scaleX(180), scaleY(700),
    );
    // S 60,690 -10,715 (reflection of 250,710 around 180,700 is 110,690)
    riverPath.cubicTo(
      scaleX(110), scaleY(690),
      scaleX(60), scaleY(690),
      scaleX(-10), scaleY(715),
    );
    riverPath.close();
    canvas.drawPath(riverPath, riverPaint);

    // 3. Parks fill #D7EED9
    // rect(250,120,120,90) radius 14; rect(18,430,70,70) radius 12
    final parkPaint = Paint()
      ..color = _parkColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(scaleX(250), scaleY(120), scaleX(120), scaleY(90)),
        Radius.circular(14 * scaleUniform),
      ),
      parkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(scaleX(18), scaleY(430), scaleX(70), scaleY(70)),
        Radius.circular(12 * scaleUniform),
      ),
      parkPaint,
    );

    // 4. Building blocks fill #E2E5EF, radius 8
    final buildingPaint = Paint()
      ..color = _buildingColor
      ..style = PaintingStyle.fill;

    const buildings = [
      [20.0, 120.0, 70.0, 60.0],
      [110.0, 120.0, 120.0, 60.0],
      [20.0, 210.0, 60.0, 80.0],
      [150.0, 270.0, 90.0, 70.0],
      [260.0, 240.0, 110.0, 60.0],
      [20.0, 320.0, 80.0, 80.0],
      [260.0, 330.0, 60.0, 70.0],
      [120.0, 440.0, 110.0, 60.0],
      [260.0, 440.0, 110.0, 70.0],
      [110.0, 530.0, 80.0, 60.0],
      [220.0, 530.0, 150.0, 50.0],
      [20.0, 530.0, 70.0, 60.0],
    ];

    for (final b in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(scaleX(b[0]), scaleY(b[1]), scaleX(b[2]), scaleY(b[3])),
          Radius.circular(8 * scaleUniform),
        ),
        buildingPaint,
      );
    }

    // 5. Roads, white, round caps
    // - (-20,200)→(410,192) w16
    final roadPaint16 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0 * scaleUniform
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pt(-20, 200), pt(410, 192), roadPaint16);

    // - (-20,420)→(410,418) w16 + centre stripe #FFE7A8 w5
    canvas.drawLine(pt(-20, 420), pt(410, 418), roadPaint16);
    final stripePaint = Paint()
      ..color = _stripeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0 * scaleUniform
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pt(-20, 420), pt(410, 418), stripePaint);

    // - (100,90)→(100,760) w14
    final roadPaint14 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0 * scaleUniform
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pt(100, 90), pt(100, 760), roadPaint14);

    // - (245,90)→(245,760) w14
    canvas.drawLine(pt(245, 90), pt(245, 760), roadPaint14);

    // - M -20,310 C 80,300 200,330 410,315 w10
    final roadPaint10 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0 * scaleUniform
      ..strokeCap = StrokeCap.round;
    final curvedRoad = Path();
    curvedRoad.moveTo(scaleX(-20), scaleY(310));
    curvedRoad.cubicTo(
      scaleX(80), scaleY(300),
      scaleX(200), scaleY(330),
      scaleX(410), scaleY(315),
    );
    canvas.drawPath(curvedRoad, roadPaint10);

    // - (-20,515)→(410,520) w10
    canvas.drawLine(pt(-20, 515), pt(410, 520), roadPaint10);

    // - (330,90)→(338,760) w8
    final roadPaint8 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0 * scaleUniform
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pt(330, 90), pt(338, 760), roadPaint8);

    // 6. Labels (Inter 9px w600 #9AA0B4)
    // "Station Road" (14,196)
    _drawLabel(canvas, "Station Road", pt(14, 182), scale: scaleUniform);

    // "Main Road" (262,414)
    _drawLabel(canvas, "Main Road", pt(262, 402), scale: scaleUniform);

    // "City Park" (268,168)
    _drawLabel(canvas, "City Park", pt(268, 168), scale: scaleUniform);

    // "River" (160,676)
    _drawLabel(canvas, "River", pt(160, 676), scale: scaleUniform);

    // "Market Lane" (104,760) rotated −90°
    _drawLabel(
      canvas,
      "Market Lane",
      pt(112, 760),
      rotation: -math.pi / 2,
      scale: scaleUniform,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset position, {
    double rotation = 0.0,
    double scale = 1.0,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 9.0 * scale,
        fontWeight: FontWeight.w600,
        fontFamily: FontFamily.interSemiBold,
        color: _labelColor,
        letterSpacing: 0.2,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    if (rotation == 0.0) {
      textPainter.paint(canvas, position);
    } else {
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(rotation);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
