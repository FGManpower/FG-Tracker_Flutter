import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class AttendanceCameraScreen extends StatefulWidget {
  final String groupName;
  final int memberCount;

  const AttendanceCameraScreen({
    super.key,
    this.groupName = "Site Team",
    this.memberCount = 12,
  });

  @override
  State<AttendanceCameraScreen> createState() => _AttendanceCameraScreenState();
}

class _AttendanceCameraScreenState extends State<AttendanceCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Find front camera first for attendance selfie verification
        final frontIndex = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
        _selectedCameraIndex = frontIndex != -1 ? frontIndex : 0;
        await _setupCamera();
      }
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }

  Future<void> _setupCamera() async {
    if (_cameras.isEmpty) return;

    await _cameraController?.dispose();
    _cameraController = null;
    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
      });
    }

    try {
      final controller = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Camera setup error: $e");
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isCapturing) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
    });

    try {
      if (_cameraController != null &&
          _cameraController!.value.isInitialized &&
          !_cameraController!.value.isTakingPicture) {
        final XFile photo = await _cameraController!.takePicture();
        if (mounted) {
          Navigator.pop(context, photo.path);
        }
        return;
      }

      // Camera fallback using front camera (strictly no gallery)
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (mounted && picked != null) {
        Navigator.pop(context, picked.path);
      }
    } catch (e) {
      debugPrint("Failed to capture photo: $e");
      try {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
          imageQuality: 85,
        );
        if (mounted && picked != null) {
          Navigator.pop(context, picked.path);
        }
      } catch (_) {}
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          child: Column(
            children: [
              _buildAttendanceCard(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded,
            color: const Color(0xFF5A3EFE), size: 22.sp),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF5A3EFE),
            ),
            child: Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.groupName,
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "${widget.memberCount} Members",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.phone_rounded,
              color: const Color(0xFF5A3EFE), size: 20.sp),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.videocam_rounded,
              color: const Color(0xFF5A3EFE), size: 22.sp),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.more_vert_rounded,
              color: const Color(0xFF5A3EFE), size: 20.sp),
          onPressed: () {},
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Camera top icon container
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B6BFE), Color(0xFF5A3EFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5A3EFE).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 26.sp,
            ),
          ),
          SizedBox(height: 12.h),

          // Title
          Text(
            "Attendance Photo",
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 4.h),

          // Subtitle
          Text(
            "Take a live photo to verify\nyour attendance",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          SizedBox(height: 18.h),

          // Camera Viewfinder Box
          _buildViewfinderBox(),

          SizedBox(height: 20.h),

          // Take Photo Button
          Container(
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6E52FE), Color(0xFF5A3EFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5A3EFE).withValues(alpha: 0.32),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isCapturing ? null : _takePhoto,
                borderRadius: BorderRadius.circular(14.r),
                child: Center(
                  child: _isCapturing
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 19.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Take Photo",
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Required Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFDDD6FE),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: const Color(0xFF5A3EFE),
                  size: 17.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Photo required for Present verification",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A3EFE),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinderBox() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera Stream / Placeholder
            if (_isCameraInitialized &&
                _cameraController != null &&
                _cameraController!.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 300,
                  height: _cameraController!.value.previewSize?.width ?? 300,
                  child: CameraPreview(_cameraController!),
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Color(0xFF8B6BFE),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Starting Front Camera...",
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 4 Clean Viewfinder Corner Brackets
            Padding(
              padding: EdgeInsets.all(26.w),
              child: CustomPaint(
                painter: _ViewfinderCornersPainter(),
                child: const SizedBox.expand(),
              ),
            ),

            // Align Face pill at top
            Positioned(
              top: 12.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.face_retouching_natural_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        "Align face inside frame",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Flip Camera Button
            if (_cameras.length > 1)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: GestureDetector(
                  onTap: _switchCamera,
                  child: Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.flip_camera_ios_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ViewfinderCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Subtle shadow behind corners for high contrast & clarity
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 26.0;
    const cornerRadius = 8.0;
    final w = size.width;
    final h = size.height;

    // Top-Left corner bracket
    final tl = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..lineTo(cornerLength, 0);
    canvas.drawPath(tl, shadowPaint);
    canvas.drawPath(tl, paint);

    // Top-Right corner bracket
    final tr = Path()
      ..moveTo(w - cornerLength, 0)
      ..lineTo(w - cornerRadius, 0)
      ..quadraticBezierTo(w, 0, w, cornerRadius)
      ..lineTo(w, cornerLength);
    canvas.drawPath(tr, shadowPaint);
    canvas.drawPath(tr, paint);

    // Bottom-Left corner bracket
    final bl = Path()
      ..moveTo(0, h - cornerLength)
      ..lineTo(0, h - cornerRadius)
      ..quadraticBezierTo(0, h, cornerRadius, h)
      ..lineTo(cornerLength, h);
    canvas.drawPath(bl, shadowPaint);
    canvas.drawPath(bl, paint);

    // Bottom-Right corner bracket
    final br = Path()
      ..moveTo(w - cornerLength, h)
      ..lineTo(w - cornerRadius, h)
      ..quadraticBezierTo(w, h, w, h - cornerRadius)
      ..lineTo(w, h - cornerLength);
    canvas.drawPath(br, shadowPaint);
    canvas.drawPath(br, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
