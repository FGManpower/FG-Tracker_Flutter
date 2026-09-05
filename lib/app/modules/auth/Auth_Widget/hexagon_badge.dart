import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable hexagon badge widget used on auth screens
/// (login card icon, OTP card icon, etc.)
class HexagonBadge extends StatelessWidget {
  final Widget child;
  const HexagonBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76.w,
      height: 84.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(76.w, 84.h),
            painter: _HexagonHaloPainter(),
          ),
          CustomPaint(
            size: Size(64.w, 72.h),
            painter: _HexagonCardPainter(),
            child: SizedBox(
              width: 64.w,
              height: 72.h,
              child: Center(child: child),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable gradient button with arrow icon used on auth screens
class AuthGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6E56F8),
              Color(0xFF533EF0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF533EF0).withValues(alpha: 0.38),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                fontFamily: FontFamily.interBold,
              ),
            ),
            Positioned(
              right: 20.w,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hexagon Painters (shared) ──────────────────────────────────────

Path _buildRoundedHexagonPath(Size size, double cornerRadius) {
  final double w = size.width;
  final double h = size.height;
  final double cx = w / 2;
  final double cy = h / 2;

  final List<Offset> vertices = [
    Offset(cx, 0),
    Offset(w, cy * 0.5),
    Offset(w, h - cy * 0.5),
    Offset(cx, h),
    Offset(0, h - cy * 0.5),
    Offset(0, cy * 0.5),
  ];

  final Path path = Path();
  final int count = vertices.length;

  for (int i = 0; i < count; i++) {
    final Offset prev = vertices[(i - 1 + count) % count];
    final Offset curr = vertices[i];
    final Offset next = vertices[(i + 1) % count];

    final Offset dirPrev = (prev - curr);
    final double distPrev = dirPrev.distance;
    final Offset pPrev =
        curr + dirPrev * (cornerRadius.clamp(0.0, distPrev * 0.45) / distPrev);

    final Offset dirNext = (next - curr);
    final double distNext = dirNext.distance;
    final Offset pNext =
        curr + dirNext * (cornerRadius.clamp(0.0, distNext * 0.45) / distNext);

    if (i == 0) {
      path.moveTo(pPrev.dx, pPrev.dy);
    } else {
      path.lineTo(pPrev.dx, pPrev.dy);
    }
    path.quadraticBezierTo(curr.dx, curr.dy, pNext.dx, pNext.dy);
  }
  path.close();
  return path;
}

class _HexagonHaloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildRoundedHexagonPath(size, 14);

    final shadowPaint = Paint()
      ..color = const Color(0xFF5D47F1).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path.shift(const Offset(0, 5)), shadowPaint);

    final auraPaint = Paint()
      ..color = const Color(0xFFF0ECFD)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, auraPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HexagonCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildRoundedHexagonPath(size, 11);

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFE8E2FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
