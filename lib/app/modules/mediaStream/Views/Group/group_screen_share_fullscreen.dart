import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

import 'package:fgtracker/app/Model/group_call_participant.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart';
import 'package:get/get.dart';

class GroupScreenShareFullScreen extends StatefulWidget {
  final GroupCallingController controller;
  final GroupCallParticipant participant;

  const GroupScreenShareFullScreen({
    super.key,
    required this.controller,
    required this.participant,
  });

  @override
  State<GroupScreenShareFullScreen> createState() =>
      _GroupScreenShareFullScreenState();
}

class _GroupScreenShareFullScreenState
    extends State<GroupScreenShareFullScreen> {
  final TransformationController _transformationController =
  TransformationController();

  static const double _minZoom = 1.0;
  static const double _maxZoom = 4.0;

  double _currentZoom = 1.0;
  Size _viewportSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale =
    _transformationController.value.getMaxScaleOnAxis();

    final zoom = scale
        .clamp(_minZoom, _maxZoom)
        .toDouble();

    if (!mounted || (_currentZoom - zoom).abs() < 0.01) {
      return;
    }

    setState(() {
      _currentZoom = zoom;
    });
  }

  void _setZoom(double requestedZoom) {
    final targetZoom = requestedZoom
        .clamp(_minZoom, _maxZoom)
        .toDouble();

    final currentScale =
    _transformationController.value.getMaxScaleOnAxis();

    if (currentScale <= 0) return;

    if (_viewportSize == Size.zero) {
      _transformationController.value = Matrix4.identity()
        ..scale(targetZoom);
      return;
    }

    // Zoom around the center of the screen instead of the top-left corner.
    final center = Offset(
      _viewportSize.width / 2,
      _viewportSize.height / 2,
    );

    final scaleFactor = targetZoom / currentScale;

    final matrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(scaleFactor)
      ..translate(-center.dx, -center.dy)
      ..multiply(_transformationController.value);

    _transformationController.value = matrix;
  }

  void _zoomIn() {
    _setZoom(_currentZoom * 1.25);
  }

  void _zoomOut() {
    _setZoom(_currentZoom / 1.25);
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  Widget _buildScreenShareView() {
    return Obx(() {
      final isConnected = widget.participant.isConnected.value;
      final renderer = widget.participant.renderer;

      if (!isConnected ||
          renderer == null ||
          renderer.textureId == null ||
          renderer.srcObject == null) {
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: Text(
            'Waiting for screen share...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
            ),
          ),
        );
      }

      return rtc.RTCVideoView(
        renderer,
        mirror: false,
        objectFit:
        rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      );
    });
  }

  Widget _buildZoomControls() {
    final canZoomIn = _currentZoom < _maxZoom;
    final canZoomOut = _currentZoom > _minZoom;

    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Zoom in',
                  onPressed: canZoomIn ? _zoomIn : null,
                  icon: const Icon(Icons.add),
                  color: Colors.white,
                  disabledColor: Colors.white38,
                ),
                Text(
                  '${(_currentZoom * 100).round()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  tooltip: 'Zoom out',
                  onPressed: canZoomOut ? _zoomOut : null,
                  icon: const Icon(Icons.remove),
                  color: Colors.white,
                  disabledColor: Colors.white38,
                ),
                IconButton(
                  tooltip: 'Reset zoom',
                  onPressed: _resetZoom,
                  icon: const Icon(Icons.refresh),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Material(
            color: Colors.black.withOpacity(0.65),
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Close full screen',
              onPressed: widget.controller.closeFullScreenShare,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              _viewportSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );

              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: _minZoom,
                maxScale: _maxZoom,
                panEnabled: true,
                scaleEnabled: true,
                clipBehavior: Clip.hardEdge,
                boundaryMargin: const EdgeInsets.all(80),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: _buildScreenShareView(),
                ),
              );
            },
          ),

          _buildCloseButton(),
          _buildZoomControls(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _transformationController
        .removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }
}