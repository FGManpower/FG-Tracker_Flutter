

import 'package:flutter/material.dart';

class MiniCrownPainter extends CustomPainter {
  final Color color;
  const MiniCrownPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, h * 0.82);
    path.quadraticBezierTo(w * 0.5, h * 0.95, w, h * 0.82);
    path.lineTo(w * 0.92, h * 0.28);
    path.lineTo(w * 0.65, h * 0.55);
    path.lineTo(w * 0.5, h * 0.1);
    path.lineTo(w * 0.35, h * 0.55);
    path.lineTo(w * 0.08, h * 0.28);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Base band line
    final bandPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final bandPath = Path();
    bandPath.moveTo(w * 0.05, h * 0.72);
    bandPath.quadraticBezierTo(w * 0.5, h * 0.82, w * 0.95, h * 0.72);
    canvas.drawPath(bandPath, bandPaint);

    // 3 small tip dots
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(w * 0.08, h * 0.24), 1.6, dotPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.08), 2.0, dotPaint);
    canvas.drawCircle(Offset(w * 0.92, h * 0.24), 1.6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant MiniCrownPainter oldDelegate) =>
      oldDelegate.color != color;
}

class PremiumCrownIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;


    final glowRadius = size.height * 0.48;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFEDE9FE).withOpacity(0.9),
          const Color(0xFFEDE9FE).withOpacity(0.4),
          const Color(0xFFEDE9FE).withOpacity(0.0),
        ],
      ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: glowRadius));
    canvas.drawCircle(Offset(cx, cy), glowRadius, glowPaint);


    final rayPaint = Paint()
      ..color = const Color(0xFF7C3AED)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;


    canvas.drawLine(
        Offset(cx - 28, cy - 10), Offset(cx - 36, cy - 12), rayPaint);

    canvas.drawLine(
        Offset(cx - 26, cy + 6), Offset(cx - 32, cy + 14), rayPaint);

    canvas.drawLine(
        Offset(cx + 28, cy - 10), Offset(cx + 36, cy - 12), rayPaint);
    canvas.drawLine(
        Offset(cx + 26, cy + 6), Offset(cx + 32, cy + 14), rayPaint);


    final crownPath = Path();
    crownPath.moveTo(cx - 23, cy + 12);
    crownPath.quadraticBezierTo(cx, cy + 15, cx + 23, cy + 12);
    crownPath.cubicTo(cx + 24, cy + 4, cx + 23, cy - 4, cx + 21, cy - 7);
    crownPath.quadraticBezierTo(cx + 12, cy + 2, cx + 7, cy + 2);
    crownPath.quadraticBezierTo(cx + 3, cy - 11, cx, cy - 16);
    crownPath.quadraticBezierTo(cx - 3, cy - 11, cx - 7, cy + 2);
    crownPath.quadraticBezierTo(cx - 12, cy + 2, cx - 21, cy - 7);
    crownPath.cubicTo(cx - 23, cy - 4, cx - 24, cy + 4, cx - 23, cy + 12);
    crownPath.close();

    canvas.drawShadow(
        crownPath, const Color(0xFF4F46E5).withOpacity(0.35), 6, true);


    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFA78BFA),
          Color(0xFF7C3AED),
          Color(0xFF4F46E5),
        ],
      ).createShader(Rect.fromLTWH(cx - 25, cy - 18, 50, 35));
    canvas.drawPath(crownPath, bodyPaint);

    final bandPath = Path()
      ..moveTo(cx - 23, cy + 12)
      ..quadraticBezierTo(cx, cy + 15, cx + 23, cy + 12)
      ..quadraticBezierTo(cx, cy + 8, cx - 23, cy + 8)
      ..close();
    final bandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF8B5CF6),
          Color(0xFFC4B5FD),
          Color(0xFF6D28D9),
        ],
      ).createShader(Rect.fromLTWH(cx - 23, cy + 8, 46, 7));
    canvas.drawPath(bandPath, bandPaint);


    void drawJewel(Offset center, double radius) {
      final jewelPaint = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [
            Colors.white,
            Color(0xFFDDD6FE),
            Color(0xFF7C3AED),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, jewelPaint);


      final specPaint = Paint()..color = Colors.white.withOpacity(0.9);
      canvas.drawCircle(
        Offset(center.dx - radius * 0.25, center.dy - radius * 0.25),
        radius * 0.35,
        specPaint,
      );
    }

    drawJewel(Offset(cx - 21, cy - 7), 3.8);
    drawJewel(Offset(cx, cy - 16), 4.8);
    drawJewel(Offset(cx + 21, cy - 7), 3.8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}