import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MarkerCache {
  static final Map<String, BitmapDescriptor> descriptorCache = {};
  static final Map<String, Uint8List> byteCache = {};
}

String formatMarkerImageUrl(String rawUrl) {
  if (rawUrl.isEmpty || rawUrl.trim().toLowerCase() == 'null') return '';
  String url = rawUrl.replaceAll(r'\', '/').trim();
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  String base = ConstRes.aImageBaseUrl.trim();
  if (base.endsWith('/') && url.startsWith('/')) {
    url = url.substring(1);
  } else if (!base.endsWith('/') && !url.startsWith('/')) {
    url = '/$url';
  }
  return '$base$url';
}

String getMarkerInitials(String? name, bool isMe) {
  if (name == null ||
      name.trim().isEmpty ||
      name.trim().toLowerCase() == 'member') {
    return isMe ? "YOU" : "M";
  }
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    final first = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    final second = parts[1].isNotEmpty ? parts[1][0].toUpperCase() : '';
    final initials = '$first$second';
    return initials.isNotEmpty ? initials : (isMe ? "YOU" : "M");
  } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
    return parts[0].length >= 2
        ? parts[0].substring(0, 2).toUpperCase()
        : parts[0][0].toUpperCase();
  }
  return isMe ? "YOU" : "M";
}

Future<ui.Image?> _fetchAndDecodeImage(String url, int targetSize) async {
  if (url.isEmpty) return null;
  try {
    Uint8List? bytes = MarkerCache.byteCache[url];
    if (bytes == null) {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme) return null;
      final response =
          await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        bytes = response.bodyBytes;
        MarkerCache.byteCache[url] = bytes;
      }
    }
    if (bytes != null && bytes.isNotEmpty) {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetSize,
        targetHeight: targetSize,
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    }
  } catch (e) {
    debugPrint("⚠️ Marker image load failed for $url: $e");
  }
  return null;
}

Future<BitmapDescriptor> getCustomIcon(
  String imageUrl,
  dynamic isOnline, {
  bool isMe = false,
  String? name,
}) async {
  final bool online = isOnline == true ||
      isOnline == 1 ||
      isOnline == 'true' ||
      isOnline == '1';

  final String formattedUrl = formatMarkerImageUrl(imageUrl);
  final String initials = getMarkerInitials(name, isMe);
  final String cacheKey =
      "${isMe ? 'me' : 'user'}_${formattedUrl}_${online}_$initials";

  if (MarkerCache.descriptorCache.containsKey(cacheKey)) {
    return MarkerCache.descriptorCache[cacheKey]!;
  }

  try {
    // Preload image if URL is present
    ui.Image? avatarImage;
    if (formattedUrl.isNotEmpty) {
      avatarImage = await _fetchAndDecodeImage(formattedUrl, 200);
    }

    // Canvas dimensions (crisp high-density 140 x 175 - larger for clear map visibility)
    const double canvasWidth = 140.0;
    const double canvasHeight = 175.0;
    const double cx = canvasWidth / 2; // 70.0
    final double cy = isMe ? 65.0 : 58.0;
    const double headRadius = 42.0;
    final double tipY = canvasHeight - 8.0; // 167.0

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Teardrop pin body path
    final teardropPath = Path();
    teardropPath.moveTo(cx, tipY);

    // Left curve from tip up to circle tangent
    teardropPath.cubicTo(
      cx - 5.0, tipY - 32.0,
      cx - headRadius * 1.04, cy + headRadius * 0.50,
      cx - headRadius, cy,
    );

    // Arc across the top circle
    teardropPath.arcToPoint(
      Offset(cx + headRadius, cy),
      radius: const Radius.circular(headRadius),
      clockwise: true,
    );

    // Right curve back down to bottom tip
    teardropPath.cubicTo(
      cx + headRadius * 1.04, cy + headRadius * 0.50,
      cx + 5.0, tipY - 32.0,
      cx, tipY,
    );
    teardropPath.close();

    // 1. Drop shadow for map depth
    canvas.drawShadow(teardropPath, Colors.black.withOpacity(0.38), 6.0, true);

    // 2. Solid Purple Fill (matches screenshot)
    final pinColor = isMe ? const Color(0xFF654CE8) : const Color(0xFF755FE2);
    canvas.drawPath(
      teardropPath,
      Paint()
        ..color = pinColor
        ..style = PaintingStyle.fill,
    );

    // 3. Avatar dimensions inside pin head (enlarged for crisp recognition)
    const double avatarRadius = 31.0;
    final Offset avatarCenter = Offset(cx, cy);

    // Draw user photo or fallback initials
    if (avatarImage != null) {
      canvas.save();
      final clipPath = Path()
        ..addOval(Rect.fromCircle(center: avatarCenter, radius: avatarRadius));
      canvas.clipPath(clipPath);

      final double imgW = avatarImage.width.toDouble();
      final double imgH = avatarImage.height.toDouble();
      final double srcSize = min(imgW, imgH);
      final Rect srcRect = Rect.fromCenter(
        center: Offset(imgW / 2, imgH / 2),
        width: srcSize,
        height: srcSize,
      );
      final Rect dstRect =
          Rect.fromCircle(center: avatarCenter, radius: avatarRadius);

      canvas.drawImageRect(
        avatarImage,
        srcRect,
        dstRect,
        Paint()..filterQuality = FilterQuality.medium,
      );
      canvas.restore();
    } else {
      // Fallback: Gradient avatar circle with user initials
      final avatarRect =
          Rect.fromCircle(center: avatarCenter, radius: avatarRadius);
      final gradient = ui.Gradient.linear(
        avatarRect.topLeft,
        avatarRect.bottomRight,
        [const Color(0xFF5B43D6), const Color(0xFF4330A8)],
      );
      canvas.drawCircle(
        avatarCenter,
        avatarRadius,
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.fill,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: initials.length > 2 ? 14.0 : 18.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          cx - (textPainter.width / 2),
          cy - (textPainter.height / 2),
        ),
      );
    }

    // 4. White circular border around avatar photo
    canvas.drawCircle(
      avatarCenter,
      avatarRadius + 1.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    // 5. Curved accent ring & dot at top-right
    const double arcRadius = avatarRadius + 4.5;
    const Color accentColor = Color(0xFFFF4858); // Coral red accent

    canvas.drawArc(
      Rect.fromCircle(center: avatarCenter, radius: arcRadius),
      -110 * pi / 180,
      135 * pi / 180,
      false,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // Dot at end of arc (at 25 degrees)
    const double dotAngle = 25 * pi / 180;
    final double dotX = cx + arcRadius * cos(dotAngle);
    final double dotY = cy + arcRadius * sin(dotAngle);

    canvas.drawCircle(
      Offset(dotX, dotY),
      4.8,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(dotX, dotY),
      3.0,
      Paint()..color = accentColor,
    );

    // 6. Optional "YOU" badge for current user pin
    if (isMe) {
      const double badgeWidth = 44.0;
      const double badgeHeight = 18.0;
      final badgeRRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, 13.0),
          width: badgeWidth,
          height: badgeHeight,
        ),
        const Radius.circular(8.0),
      );

      canvas.drawRRect(
        badgeRRect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      final badgeText = TextPainter(
        text: const TextSpan(
          text: "YOU",
          style: TextStyle(
            color: Color(0xFF654CE8),
            fontSize: 9.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      badgeText.paint(
        canvas,
        Offset(
          cx - (badgeText.width / 2),
          11.0 - (badgeText.height / 2),
        ),
      );
    }

    // Finalize picture and convert to PNG bytes
    final picture = recorder.endRecording();
    final ui.Image finalImage =
        await picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());
    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      final pngBytes = byteData.buffer.asUint8List();
      final descriptor = BitmapDescriptor.fromBytes(pngBytes);
      MarkerCache.descriptorCache[cacheKey] = descriptor;
      return descriptor;
    }
  } catch (e) {
    debugPrint("❌ Error creating map marker icon: $e");
  }

  // Safe fallback if anything fails
  return BitmapDescriptor.defaultMarkerWithHue(
    isMe
        ? BitmapDescriptor.hueViolet
        : (online ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure),
  );
}

class MarkerWidget extends StatelessWidget {
  final String imageUrl;
  final dynamic isOnline;
  final bool isMe;

  const MarkerWidget({
    super.key,
    required this.imageUrl,
    required this.isOnline,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final String fullUrl = formatMarkerImageUrl(imageUrl);
    final bool online = isOnline == true ||
        isOnline == 1 ||
        isOnline == 'true' ||
        isOnline == '1';

    final Color ringColor = isMe
        ? const Color(0xFF4338CA)
        : (online ? const Color(0xFF10B981) : const Color(0xFF94A3B8));

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
    return Container(
      color: online ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
      child: Icon(
        Icons.person,
        color: online ? const Color(0xFF059669) : const Color(0xFF64748B),
        size: 22.sp,
      ),
    );
  }
}
