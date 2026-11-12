import 'dart:io';
import 'package:fgtracker/l10n/l10n.dart';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/attendance_frame_encoder.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';
import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
/// Live attendance selfie: front camera only, auto-captured when the member
/// blinks (open → closed → open) with exactly one centered face in frame.
/// Pops with the captured file path when the member taps Submit.
class AttendanceCameraScreen extends StatefulWidget {
  final String groupName;
  final int memberCount;

  const AttendanceCameraScreen({
    super.key,
    this.groupName = "",
    this.memberCount = 0,
  });

  @override
  State<AttendanceCameraScreen> createState() => _AttendanceCameraScreenState();
}

enum _BlinkStage { waitingOpen, waitingClose, waitingReopen }

class _AttendanceCameraScreenState extends State<AttendanceCameraScreen>
    with WidgetsBindingObserver {
  static const _accent = Color(0xFF5A3EFE);
  static const _textDark = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);
  static const _ok = Color(0xFF16A34A);
  static const _warn = Color(0xFFF59E0B);
  static const _error = Color(0xFFEF4444);

  // Eye-open probability thresholds for the blink sequence.
  static const double _eyeOpen = 0.7;
  static const double _eyeClosed = 0.3;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.2,
    ),
  );

  CameraController? _camera;
  CameraDescription? _frontCamera;
  bool _isInitializing = true;
  bool _permissionDenied = false;
  String? _initError;

  bool _isDetecting = false;
  bool _isCapturing = false;
  _BlinkStage _stage = _BlinkStage.waitingOpen;
  String _status = appL10n.attendance_cameraStarting;
  Color _statusColor = _textMuted;
  bool _faceReady = false;

  String? _capturedPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Release the camera in the background; reopen it on return.
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _releaseCamera();
    } else if (state == AppLifecycleState.resumed &&
        _capturedPath == null &&
        _camera == null &&
        !_isInitializing) {
      // Also covers returning from app settings after granting permission.
      _initCamera();
    }
  }

  bool _disposed = false;
  bool _detectorClosed = false;

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _releaseCamera(notify: false);
    // Closing the detector while a frame is still being processed crashes
    // the native ML Kit side; if one is in flight, close when it finishes.
    if (!_isDetecting) _closeDetector();
    super.dispose();
  }

  void _closeDetector() {
    if (_detectorClosed) return;
    _detectorClosed = true;
    _faceDetector.close();
  }

  Future<void> _releaseCamera({bool notify = true}) async {
    final camera = _camera;
    _camera = null;
    if (camera == null) return;
    // dispose() also ends the image stream. Calling stopImageStream first
    // makes the Android plugin rebuild its capture session right as it is
    // being closed, a native crash on some devices.
    try {
      await camera.dispose();
    } catch (e) {
      AppLog.d("Attendance camera dispose failed: $e");
    }
    if (notify && mounted) setState(() {});
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    setState(() {
      _isInitializing = true;
      _permissionDenied = false;
      _initError = null;
    });

    try {
      final cameras = await availableCameras();
      _frontCamera = cameras.cast<CameraDescription?>().firstWhere(
            (c) => c!.lensDirection == CameraLensDirection.front,
            orElse: () => null,
          );
      if (_frontCamera == null) {
        setState(() {
          _isInitializing = false;
          _initError = appL10n.attendance_noFrontCamera;
        });
        return;
      }

      final controller = CameraController(
        _frontCamera!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      _camera = controller;
      _resetBlink();
      await controller.startImageStream(_processFrame);
      setState(() => _isInitializing = false);
    } on CameraException catch (e) {
      final denied = e.code.startsWith("CameraAccessDenied") ||
          e.code == "CameraAccessRestricted";
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _permissionDenied = denied;
        _initError = denied ? null : appL10n.attendance_cameraStartFailedCode(e.code);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _initError = appL10n.attendance_cameraStartFailed;
      });
    }
  }

  void _resetBlink() {
    _stage = _BlinkStage.waitingOpen;
    _faceReady = false;
    _setStatus(appL10n.attendance_lookAtCamera, _textMuted);
  }

  void _setStatus(String text, Color color) {
    if (_status == text && _statusColor == color) return;
    if (!mounted) return;
    setState(() {
      _status = text;
      _statusColor = color;
    });
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_disposed || _detectorClosed) return;
    if (_isDetecting || _isCapturing || _capturedPath != null) return;
    final camera = _frontCamera;
    if (camera == null) return;

    _isDetecting = true;
    try {
      final input = _toInputImage(image, camera);
      if (input == null) return;
      final faces = await _faceDetector.processImage(input);
      if (!mounted || _disposed || _capturedPath != null) return;

      // Rotated frame size (sensor is landscape; 90/270 swaps the axes).
      final rotated = camera.sensorOrientation % 180 != 0;
      final frameW = (rotated ? image.height : image.width).toDouble();
      final frameH = (rotated ? image.width : image.height).toDouble();
      _evaluate(faces, frameW, frameH, image);
    } catch (e) {
      AppLog.d("Face detection error: $e");
    } finally {
      _isDetecting = false;
      if (_disposed) _closeDetector();
    }
  }

  void _evaluate(
    List<Face> faces,
    double frameW,
    double frameH,
    CameraImage frame,
  ) {
    if (faces.isEmpty) {
      _stage = _BlinkStage.waitingOpen;
      _faceReady = false;
      _setStatus(appL10n.attendance_noFace, _error);
      return;
    }
    if (faces.length > 1) {
      _stage = _BlinkStage.waitingOpen;
      _faceReady = false;
      _setStatus(appL10n.attendance_multipleFaces, _error);
      return;
    }

    final face = faces.first;
    final box = face.boundingBox;
    final cx = box.center.dx / frameW;
    final cy = box.center.dy / frameH;
    final widthRatio = box.width / frameW;

    if (cx < 0.25 || cx > 0.75 || cy < 0.2 || cy > 0.8) {
      _stage = _BlinkStage.waitingOpen;
      _faceReady = false;
      _setStatus(appL10n.attendance_keepFaceInCircle, _warn);
      return;
    }
    if (widthRatio < 0.3) {
      _stage = _BlinkStage.waitingOpen;
      _faceReady = false;
      _setStatus(appL10n.attendance_moveCloser, _warn);
      return;
    }

    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left == null || right == null) {
      _setStatus(appL10n.attendance_lookStraight, _warn);
      return;
    }

    final open = left > _eyeOpen && right > _eyeOpen;
    final closed = left < _eyeClosed && right < _eyeClosed;

    switch (_stage) {
      case _BlinkStage.waitingOpen:
        if (open) {
          _stage = _BlinkStage.waitingClose;
          _faceReady = true;
          _setStatus(appL10n.attendance_faceDetectedBlink, _ok);
        } else {
          _setStatus(appL10n.attendance_openEyes, _warn);
        }
        break;
      case _BlinkStage.waitingClose:
        if (closed) _stage = _BlinkStage.waitingReopen;
        break;
      case _BlinkStage.waitingReopen:
        if (open) _capture(frame);
        break;
    }
  }

  InputImage? _toInputImage(CameraImage image, CameraDescription camera) {
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    if (Platform.isAndroid) {
      // NV21 arrives as a single plane; YUV_420_888 (3 planes) is converted.
      final bytes = image.planes.length == 1
          ? image.planes.first.bytes
          : _yuv420ToNv21(image);
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width,
        ),
      );
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format != InputImageFormat.bgra8888 || image.planes.length != 1) {
      return null;
    }
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format!,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final y = image.planes[0];
    final u = image.planes[1];
    final v = image.planes[2];
    final out = Uint8List(width * height * 3 ~/ 2);

    var index = 0;
    for (var row = 0; row < height; row++) {
      out.setRange(index, index + width, y.bytes, row * y.bytesPerRow);
      index += width;
    }
    final uPixel = u.bytesPerPixel ?? 1;
    final vPixel = v.bytesPerPixel ?? 1;
    for (var row = 0; row < height ~/ 2; row++) {
      for (var col = 0; col < width ~/ 2; col++) {
        out[index++] = v.bytes[row * v.bytesPerRow + col * vPixel];
        out[index++] = u.bytes[row * u.bytesPerRow + col * uPixel];
      }
    }
    return out;
  }

  /// Captures the selfie once the blink is confirmed.
  ///
  /// Android: the photo is built from [frame], the exact frame in which the
  /// eyes reopened (no `takePicture`). On the Android camera plugin,
  /// `stopImageStream` + `takePicture` races the capture-session rebuild and
  /// crashes natively on many devices; this path never touches the session.
  /// It is also stronger liveness: the saved photo is the verified frame.
  ///
  /// iOS: AVFoundation takes pictures reliably while streaming, so the
  /// native full-quality capture is kept.
  Future<void> _capture(CameraImage frame) async {
    final camera = _camera;
    if (_isCapturing || camera == null || _capturedPath != null) return;
    _isCapturing = true;
    _setStatus(appL10n.attendance_holdStill, _ok);

    try {
      final String path;
      if (Platform.isAndroid) {
        path = await _saveFrameAsJpeg(
          frame,
          _frontCamera?.sensorOrientation ?? 0,
        );
      } else {
        path = (await camera.takePicture()).path;
      }
      if (!mounted || _disposed) return;
      setState(() {
        _capturedPath = path;
        _status = appL10n.attendance_capturedCheck;
        _statusColor = _ok;
      });
      // The preview is shown from the file; free the camera meanwhile.
      await _releaseCamera();
    } catch (e) {
      AppLog.d("Attendance capture failed: $e");
      if (!mounted || _disposed) return;
      _resetBlink();
      _setStatus(appL10n.attendance_captureFailedBlink, _error);
    } finally {
      _isCapturing = false;
    }
  }

  /// Converts a stream frame to an upright JPEG on a background isolate and
  /// writes it to the temp directory.
  Future<String> _saveFrameAsJpeg(CameraImage frame, int rotation) async {
    final Uint8List bytes;
    final int bytesPerRow;
    if (frame.planes.length == 1) {
      bytes = Uint8List.fromList(frame.planes.first.bytes);
      bytesPerRow = frame.planes.first.bytesPerRow;
    } else {
      bytes = _yuv420ToNv21(frame);
      bytesPerRow = frame.width;
    }
    final jpeg = await compute(
      encodeAttendanceFrame,
      AttendanceFramePayload(
        bytes: bytes,
        width: frame.width,
        height: frame.height,
        bytesPerRow: bytesPerRow,
        rotation: rotation,
      ),
    );
    final dir = await getTemporaryDirectory();
    final file = File(
      "${dir.path}/attendance_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );
    await file.writeAsBytes(jpeg, flush: true);
    return file.path;
  }

  Future<void> _retake() async {
    final old = _capturedPath;
    setState(() => _capturedPath = null);
    if (old != null) {
      try {
        await File(old).delete();
      } catch (_) {}
    }
    await _initCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _accent, size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          appL10n.attendance_photoTitle,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: _capturedPath != null ? _buildPreview() : _buildCapture(),
        ),
      ),
    );
  }

  Widget _buildCapture() {
    return Column(
      children: [
        Text(
          appL10n.attendance_photoSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, color: _textMuted),
        ),
        SizedBox(height: 16.h),
        _buildCameraCircle(),
        SizedBox(height: 14.h),
        if (!_permissionDenied && _initError == null) _buildStatusChip(),
        SizedBox(height: 18.h),
        _buildInstructions(),
      ],
    );
  }

  Widget _buildCameraCircle() {
    final size = 0.72.sw;
    final camera = _camera;
    final previewSize = camera?.value.previewSize;

    Widget content;
    if (_permissionDenied) {
      content = _buildBlockedMessage(
        icon: Icons.no_photography_outlined,
        text: appL10n.attendance_cameraPermissionRequired,
        action: appL10n.chatList_openSettings,
        onTap: () async {
          await openAppSettings();
        },
      );
    } else if (_initError != null) {
      content = _buildBlockedMessage(
        icon: Icons.error_outline_rounded,
        text: _initError!,
        action: appL10n.common_retry,
        onTap: _initCamera,
      );
    } else if (_isInitializing ||
        camera == null ||
        !camera.value.isInitialized ||
        previewSize == null) {
      content = const Center(
        child: CircularProgressIndicator(color: _accent),
      );
    } else {
      // previewSize is landscape; swap for the portrait preview.
      content = ClipOval(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize.height,
            height: previewSize.width,
            child: CameraPreview(camera),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEEF2FF),
        border: Border.all(
          color: _faceReady ? _ok : const Color(0xFFCBD5E1),
          width: 4,
        ),
      ),
      child: content,
    );
  }

  Widget _buildBlockedMessage({
    required IconData icon,
    required String text,
    required String action,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36.sp, color: _error),
          SizedBox(height: 10.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5.sp, color: _textDark),
          ),
          SizedBox(height: 10.h),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _status,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: _statusColor,
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    final steps = [
      appL10n.attendance_stepEyeLevel,
      appL10n.attendance_keepFaceInCircle,
      appL10n.attendance_stepBlink,
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appL10n.attendance_howToTakePhoto,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          SizedBox(height: 10.h),
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${i + 1}",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: TextStyle(fontSize: 13.sp, color: _textDark),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 4.h),
          Text(
            appL10n.attendance_photoRules,
            style: TextStyle(fontSize: 11.5.sp, color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F9EF),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: _ok, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                appL10n.attendance_photoCaptured,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _ok,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Image.file(
            File(_capturedPath!),
            width: double.infinity,
            height: 0.6.sw * 1.25,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: OutlinedButton.icon(
                  onPressed: _retake,
                  icon: const Icon(Icons.refresh_rounded, color: _accent),
                  label: AutoFitText(
                    appL10n.attendance_retakePhoto,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _accent, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _capturedPath),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: AutoFitText(
                    appL10n.common_submit,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
