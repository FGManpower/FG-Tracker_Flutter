import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/modules/scan_text/services/scan_text_service.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

/// Full-screen iOS Live Text Scanner screen ("msg type jese").
/// Displays a clean Message Bubble at the top showing the scanned text in real-time,
/// with Copy and Share actions, and an active Camera Viewfinder at the bottom
/// with yellow targeting brackets [  ], torch toggle, gallery picker, and a blue "Insert" button.
class LiveScanCameraScreen extends StatefulWidget {
  final String? initialText;

  const LiveScanCameraScreen({
    super.key,
    this.initialText,
  });

  @override
  State<LiveScanCameraScreen> createState() => _LiveScanCameraScreenState();
}

class _LiveScanCameraScreenState extends State<LiveScanCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  bool _isInitializing = true;
  bool _isScanning = false;
  bool _isTorchOn = false;
  bool _preferHindi = false;
  bool _permissionDenied = false;
  String? _errorMessage;

  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int _wordCount = 0;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
      _updateCounters();
    }
    _textController.addListener(_updateCounters);
    _initializeCamera();
  }

  void _updateCounters() {
    final text = _textController.text.trim();
    setState(() {
      _charCount = text.length;
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      if (_cameras.isNotEmpty) {
        _setupCamera(_cameras[_selectedCameraIndex]);
      } else {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.removeListener(_updateCounters);
    _textController.dispose();
    try {
      _cameraController?.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _permissionDenied = false;
      _errorMessage = null;
    });

    try {
      final status = await Permission.camera.request();
      if (status.isPermanentlyDenied) {
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _permissionDenied = true;
          _errorMessage =
              "Camera permission permanently denied hai. Settings se allow karein.";
        });
        return;
      } else if (!status.isGranted) {
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _permissionDenied = true;
          _errorMessage =
              "Camera permission denied. Text scan karne ke liye camera allow karein.";
        });
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _errorMessage = "Device par camera nahi mila.";
        });
        return;
      }

      final backIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _selectedCameraIndex = backIndex >= 0 ? backIndex : 0;

      await _setupCamera(_cameras[_selectedCameraIndex]);
    } catch (e) {
      AppLog.e("LiveScanCamera initialization error: $e");
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = "Camera start nahi ho paya. Punah prayas karein.";
      });
    }
  }

  Future<void> _setupCamera(CameraDescription description) async {
    try {
      final controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _cameraController = controller;
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _isInitializing = false;
        _isTorchOn = false;
      });
    } catch (e) {
      AppLog.e("Error setting up camera controller: $e");
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = "Camera preview start nahi ho paya.";
      });
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final nextState = !_isTorchOn;
      await controller.setFlashMode(
        nextState ? FlashMode.torch : FlashMode.off,
      );
      if (mounted) {
        setState(() => _isTorchOn = nextState);
      }
    } catch (e) {
      AppLog.d("Torch toggle error: $e");
    }
  }

  /// Captures current camera view and inserts recognized text into the message box
  Future<void> _captureAndInsert() async {
    final controller = _cameraController;
    if (_isScanning) return;

    if (controller == null || !controller.value.isInitialized) {
      Utils().fluttertoast("Camera ready nahi hai");
      return;
    }

    setState(() => _isScanning = true);

    try {
      final XFile photo = await controller.takePicture();
      final text = await ScanTextService.instance.extractTextFromImage(
        photo.path,
        preferHindi: _preferHindi,
      );

      if (!mounted) return;
      setState(() => _isScanning = false);

      final trimmed = text.trim();
      if (trimmed.isEmpty) {
        Utils().fluttertoast("No text found, try again with clear photo");
        return;
      }

      // Insert directly into the Message Box above
      setState(() {
        _textController.text = trimmed;
      });
      Utils().fluttertoast("Text Inserted!");
    } catch (e) {
      AppLog.e("Capture and insert error: $e");
      if (mounted) {
        setState(() => _isScanning = false);
      }
      Utils().fluttertoast("No text found, try again with clear photo");
    }
  }

  /// Picks image from gallery and inserts text into the message box
  Future<void> _pickFromGallery() async {
    if (_isScanning) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) return;

      setState(() => _isScanning = true);
      final text = await ScanTextService.instance.extractTextFromImage(
        image.path,
        preferHindi: _preferHindi,
      );

      if (!mounted) return;
      setState(() => _isScanning = false);

      final trimmed = text.trim();
      if (trimmed.isEmpty) {
        Utils().fluttertoast("No text found, try again with clear photo");
        return;
      }

      setState(() {
        _textController.text = trimmed;
      });
      Utils().fluttertoast("Text Inserted!");
    } catch (e) {
      AppLog.e("Gallery pick error: $e");
      if (mounted) {
        setState(() => _isScanning = false);
      }
      Utils().fluttertoast("No text found, try again with clear photo");
    }
  }

  void _copyText() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      Utils().fluttertoast("No text to copy");
      return;
    }
    Clipboard.setData(ClipboardData(text: text));
    Utils().fluttertoast("Copied");
  }

  void _shareText() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      Utils().fluttertoast("No text to share");
      return;
    }
    Share.share(text);
  }

  void _clearText() {
    setState(() {
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Language Bar
            _buildTopNavBar(),

            // Top Section: Message Bubble Box ("msg type jese")
            _buildMessageDraftBox(),

            // Bottom Section: Live Camera Viewfinder with Yellow Reticle
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22.r),
                  topRight: Radius.circular(22.r),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Live Camera Feed
                    _buildCameraPreview(),

                    // 2. iOS Yellow Targeting Reticle [   ]
                    if (!_isInitializing && _errorMessage == null)
                      _buildViewfinderReticle(),

                    // 3. Bottom Controls Row (Gallery, Blue Insert Button, Torch)
                    _buildCameraControls(),

                    // 4. Scanning Loader Overlay
                    if (_isScanning) _buildScanningOverlay(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          // Close button
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "Scan Text",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: FontFamily.interBold,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Language Selector Pill (English / Hindi)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLangPill(
                  label: "English",
                  isSelected: !_preferHindi,
                  onTap: () => setState(() => _preferHindi = false),
                ),
                _buildLangPill(
                  label: "हिंदी",
                  isSelected: _preferHindi,
                  onTap: () => setState(() => _preferHindi = true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5D47F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontFamily: FontFamily.interSemiBold,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  /// Top Message Draft Box ("msg type jese")
  Widget _buildMessageDraftBox() {
    final hasText = _textController.text.trim().isNotEmpty;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info: Label + Word count + Action chips
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 13.sp,
                        color: const Color(0xFF5D47F1),
                      ),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: Text(
                          hasText
                              ? "$_wordCount w • $_charCount c"
                              : "Message Text",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontFamily: FontFamily.interSemiBold,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5D47F1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 6.w),

              // Copy Button
              _buildMiniAction(
                icon: Icons.copy_rounded,
                label: "Copy",
                onTap: _copyText,
                enabled: hasText,
              ),
              SizedBox(width: 6.w),

              // Share Button
              _buildMiniAction(
                icon: Icons.share_rounded,
                label: "Share",
                onTap: _shareText,
                enabled: hasText,
              ),

              if (hasText) ...[
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: _clearText,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 13.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h),

          // Message Editable TextField
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 46.h,
              maxHeight: 120.h,
            ),
            child: Scrollbar(
              child: TextField(
                controller: _textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.35,
                  fontFamily: FontFamily.interRegular,
                  color: const Color(0xFF1E202B),
                ),
                decoration: InputDecoration(
                  hintText:
                      "Camera ko text par point karein aur neeche 'Insert' dabayein...",
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF9CA3AF),
                    fontFamily: FontFamily.interRegular,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF3F4F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13.sp,
              color: enabled ? const Color(0xFF4B5563) : Colors.grey.shade400,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontFamily: FontFamily.interSemiBold,
                color: enabled ? const Color(0xFF4B5563) : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5D47F1)),
            ),
            SizedBox(height: 14.h),
            Text(
              "Starting Camera...",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13.sp,
                fontFamily: FontFamily.interMedium,
              ),
            ),
          ],
        ),
      );
    }

    if (_permissionDenied || _errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 38.sp,
                color: Colors.redAccent,
              ),
              SizedBox(height: 12.h),
              Text(
                _errorMessage ?? "Camera access enable karein.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5.sp,
                  fontFamily: FontFamily.interRegular,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D47F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: _permissionDenied ? openAppSettings : _initializeCamera,
                child: Text(_permissionDenied ? "Open Settings" : "Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: Transform.scale(
        scale: 1.0,
        child: Center(
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  /// Exact iOS-style yellow corner brackets [ ] surrounding the target text zone
  Widget _buildViewfinderReticle() {
    return Center(
      child: SizedBox(
        width: 290.w,
        height: 180.h,
        child: CustomPaint(
          painter: _YellowReticlePainter(),
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gallery shortcut button
            InkWell(
              onTap: _pickFromGallery,
              borderRadius: BorderRadius.circular(24.r),
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),

            // Prominent Blue Pill "Insert" Button matching iOS Live Text
            InkWell(
              onTap: _captureAndInsert,
              borderRadius: BorderRadius.circular(28.r),
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 34.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF), // Vibrant iOS blue
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.document_scanner_rounded,
                      color: Colors.white,
                      size: 19.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Insert",
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontFamily: FontFamily.interBold,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Torch Toggle button
            InkWell(
              onTap: _toggleTorch,
              borderRadius: BorderRadius.circular(24.r),
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: _isTorchOn
                      ? const Color(0xFFFFD600).withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isTorchOn
                        ? const Color(0xFFFFD600)
                        : Colors.white.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: _isTorchOn ? const Color(0xFFFFD600) : Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1E202B),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 18,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 30.w,
                height: 30.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Scanning & Inserting...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5.sp,
                  fontFamily: FontFamily.interBold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter that renders exact iOS-style yellow brackets:
/// ┌          ┐
///
/// └          ┘
class _YellowReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD600) // iOS bright golden yellow
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const cornerLength = 30.0;
    const radius = 10.0;

    // Top-Left corner ┌
    final pathTL = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
      ..lineTo(cornerLength, 0);
    canvas.drawPath(pathTL, paint);

    // Top-Right corner ┐
    final pathTR = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(
        Offset(size.width, radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(pathTR, paint);

    // Bottom-Left corner └
    final pathBL = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - radius)
      ..arcToPoint(
        Offset(radius, size.height),
        radius: const Radius.circular(radius),
      )
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(pathBL, paint);

    // Bottom-Right corner ┘
    final pathBR = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - radius, size.height)
      ..arcToPoint(
        Offset(size.width, size.height - radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
