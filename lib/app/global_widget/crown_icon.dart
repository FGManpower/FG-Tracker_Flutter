import 'package:flutter/material.dart';

class CrownIcon extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const CrownIcon({
    super.key,
    this.width = 22,
    this.height = 17,
    this.color = const Color(0xFF5338EE),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _CrownPainter(color: color),
      ),
    );
  }
}

class _CrownPainter extends CustomPainter {
  final Color color;

  _CrownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double w = size.width;
    final double h = size.height;

    final Path path = Path();
    // Start at bottom left base
    path.moveTo(w * 0.12, h * 0.88);

    // Left flare to left peak
    path.lineTo(w * 0.02, h * 0.28);
    path.quadraticBezierTo(w * 0.05, h * 0.18, w * 0.13, h * 0.22);

    // Dip to left valley
    path.lineTo(w * 0.33, h * 0.54);

    // Rise to center peak (tallest)
    path.lineTo(w * 0.46, h * 0.04);
    path.quadraticBezierTo(w * 0.50, h * 0.00, w * 0.54, h * 0.04);

    // Dip to right valley
    path.lineTo(w * 0.67, h * 0.54);

    // Rise to right peak
    path.lineTo(w * 0.87, h * 0.22);
    path.quadraticBezierTo(w * 0.95, h * 0.18, w * 0.98, h * 0.28);

    // Down to bottom right base
    path.lineTo(w * 0.88, h * 0.88);

    // Bottom curve arch
    path.quadraticBezierTo(w * 0.50, h * 0.96, w * 0.12, h * 0.88);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CrownPainter oldDelegate) =>
      oldDelegate.color != color;
}
