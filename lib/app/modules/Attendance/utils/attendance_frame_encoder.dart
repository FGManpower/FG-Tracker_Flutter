import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// One camera stream frame, sent to a background isolate for encoding.
class AttendanceFramePayload {
  /// NV21 bytes (Android: full-res Y plane followed by interleaved V/U).
  final Uint8List bytes;
  final int width;
  final int height;

  /// Bytes per row of the Y plane.
  final int bytesPerRow;

  /// Clockwise degrees needed to make the frame upright (the camera's
  /// `sensorOrientation`, the same value used for face detection).
  final int rotation;

  const AttendanceFramePayload({
    required this.bytes,
    required this.width,
    required this.height,
    required this.bytesPerRow,
    required this.rotation,
  });
}

/// NV21 frame → upright JPEG. Top-level so it can run via `compute`.
Uint8List encodeAttendanceFrame(AttendanceFramePayload p) {
  final w = p.width;
  final h = p.height;
  final stride = p.bytesPerRow < w ? w : p.bytesPerRow;
  final ySize = stride * h;
  final bytes = p.bytes;
  if (bytes.length < ySize + (h ~/ 2) * stride) {
    throw StateError(
      "Frame too small: ${bytes.length} bytes for ${w}x$h (stride $stride)",
    );
  }

  final out = img.Image(width: w, height: h);
  for (var y = 0; y < h; y++) {
    final yRow = y * stride;
    final uvRow = ySize + (y >> 1) * stride;
    for (var x = 0; x < w; x++) {
      final yy = bytes[yRow + x];
      final uvIndex = uvRow + (x & ~1);
      final v = bytes[uvIndex] - 128;
      final u = bytes[uvIndex + 1] - 128;
      final r = (yy + 1.370705 * v).round();
      final g = (yy - 0.337633 * u - 0.698001 * v).round();
      final b = (yy + 1.732446 * u).round();
      out.setPixelRgb(
        x,
        y,
        r < 0 ? 0 : (r > 255 ? 255 : r),
        g < 0 ? 0 : (g > 255 ? 255 : g),
        b < 0 ? 0 : (b > 255 ? 255 : b),
      );
    }
  }

  final upright =
      p.rotation % 360 == 0 ? out : img.copyRotate(out, angle: p.rotation);
  return img.encodeJpg(upright, quality: 90);
}
