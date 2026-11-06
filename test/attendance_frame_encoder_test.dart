import 'dart:typed_data';

import 'package:fgtracker/app/modules/Attendance/utils/attendance_frame_encoder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// NV21 frame whose top half is white and bottom half is black.
Uint8List _frame(int w, int h) {
  final bytes = Uint8List(w * h * 3 ~/ 2);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      bytes[y * w + x] = y < h ~/ 2 ? 235 : 16;
    }
  }
  bytes.fillRange(w * h, bytes.length, 128); // neutral chroma
  return bytes;
}

void main() {
  test('encodes NV21 to JPEG and rotates clockwise by sensor orientation', () {
    const w = 64, h = 32;
    final jpeg = encodeAttendanceFrame(AttendanceFramePayload(
      bytes: _frame(w, h),
      width: w,
      height: h,
      bytesPerRow: w,
      rotation: 90,
    ));
    final decoded = img.decodeJpg(jpeg)!;
    expect(decoded.width, h);
    expect(decoded.height, w);
    // Rotated 90° clockwise: the white top half ends up on the right.
    expect(decoded.getPixel(decoded.width - 2, decoded.height ~/ 2).r,
        greaterThan(200));
    expect(decoded.getPixel(1, decoded.height ~/ 2).r, lessThan(50));
  });

  test('rotation 0 keeps orientation and size', () {
    const w = 40, h = 20;
    final decoded = img.decodeJpg(encodeAttendanceFrame(AttendanceFramePayload(
      bytes: _frame(w, h),
      width: w,
      height: h,
      bytesPerRow: w,
      rotation: 0,
    )))!;
    expect(decoded.width, w);
    expect(decoded.height, h);
    expect(decoded.getPixel(w ~/ 2, 1).r, greaterThan(200));
  });

  test('rejects a truncated frame instead of crashing natively', () {
    expect(
      () => encodeAttendanceFrame(AttendanceFramePayload(
        bytes: Uint8List(10),
        width: 64,
        height: 32,
        bytesPerRow: 64,
        rotation: 270,
      )),
      throwsStateError,
    );
  });
}
