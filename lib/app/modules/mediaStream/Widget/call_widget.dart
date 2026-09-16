import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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