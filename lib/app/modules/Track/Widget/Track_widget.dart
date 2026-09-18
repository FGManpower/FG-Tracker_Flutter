import 'dart:math';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/modules/Track/Widget/ToBitDescription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getCustomIcon(
    String imageUrl, dynamic isOnline,
    {bool isMe = false, String name = ""}) async {
  return MarkerWidget(
          imageUrl: imageUrl, isOnline: isOnline, isMe: isMe, name: name)
      .toBitmapDescriptor(
    logicalSize: isMe ? Size(54.w, 64.h) : Size(48.w, 48.h),
    imageSize: isMe ? Size(108.w, 128.h) : Size(96.w, 96.h),
  );
}

class MarkerWidget extends StatelessWidget {
  final String imageUrl;
  final dynamic isOnline;
  final bool isMe;
  final String name;

  const MarkerWidget({
    super.key,
    required this.imageUrl,
    required this.isOnline,
    this.isMe = false,
    this.name = "",
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return SizedBox(
        width: 54.w,
        height: 64.h,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFF4338CA),
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "You",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10.sp,
                ),
              ),
            ),
            CustomPaint(
              size: Size(8.w, 4.h),
              painter: _TrianglePainter(color: const Color(0xFF4338CA)),
            ),
            SizedBox(height: 2.h),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4338CA).withOpacity(0.24),
              ),
              padding: EdgeInsets.all(3.w),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4338CA),
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final String raw = imageUrl.trim();
    final String fullUrl = (raw.isEmpty || raw.toLowerCase() == 'null')
        ? ""
        : (raw.startsWith("http://") || raw.startsWith("https://")
            ? raw
            : (ConstRes.aImageBaseUrl.endsWith('/') && raw.startsWith('/')
                ? "${ConstRes.aImageBaseUrl}${raw.substring(1)}"
                : (!ConstRes.aImageBaseUrl.endsWith('/') && !raw.startsWith('/')
                    ? "${ConstRes.aImageBaseUrl}/$raw"
                    : "${ConstRes.aImageBaseUrl}$raw")));

    final bool online = isOnline == true ||
        isOnline == 1 ||
        isOnline == 'true' ||
        isOnline == '1';

    final Color ringColor = online
        ? const Color(0xFF10B981)
        : const Color(0xFF94A3B8);

    return SizedBox(
      width: 48.w,
      height: 48.w,
      child: Center(
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: ringColor,
              width: 2.8.w,
            ),
            boxShadow: [
              BoxShadow(
                color: online
                    ? const Color(0xFF10B981).withOpacity(0.35)
                    : Colors.black.withOpacity(0.12),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipOval(
            child: fullUrl.isNotEmpty
                ? Image.network(
                    fullUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _fallbackAvatar(online),
                  )
                : _fallbackAvatar(online),
          ),
        ),
      ),
    );
  }

  Widget _fallbackAvatar(bool online) {
    final String initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : "";
    return Container(
      color: online ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: initial.isNotEmpty
          ? Text(
              initial,
              style: TextStyle(
                color: online
                    ? const Color(0xFF059669)
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.w800,
                fontSize: 18.sp,
              ),
            )
          : Icon(
              Icons.person,
              color:
                  online ? const Color(0xFF059669) : const Color(0xFF64748B),
              size: 22.sp,
            ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
