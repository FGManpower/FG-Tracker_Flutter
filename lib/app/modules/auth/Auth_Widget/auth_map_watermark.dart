import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// Reusable Watermark widget for Login and OTP screens.
///
/// Converts a black-and-white map/arc image into a transparent,
/// custom-colored watermark (default: [AppColors.darkRed]) on the fly
/// using GPU color matrix filtering.
class AuthMapWatermark extends StatelessWidget {
  final Color color;
  final BoxFit fit;
  final Alignment alignment;

  const AuthMapWatermark({
    super.key,
    this.color = AppColors.darkRed,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    final matrix = _createColorMatrix(color);

    return ColorFiltered(
      colorFilter: ColorFilter.matrix(matrix),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    return Assets.images.authMapWatermark.image(
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }

  /// Generates a 4x5 ColorFilter matrix:
  /// - Black pixels (0,0,0) -> Alpha becomes 0.0 (100% transparent).
  /// - White pixels (1,1,1) -> Tinted to [color] with full opacity.
  /// - Anti-aliased/gray pixels -> Smoothly blended.
  static List<double> _createColorMatrix(Color targetColor) {
    final double r = targetColor.red / 255.0;
    final double g = targetColor.green / 255.0;
    final double b = targetColor.blue / 255.0;

    return [
      r * 0.299, r * 0.587, r * 0.114, 0, 0,
      g * 0.299, g * 0.587, g * 0.114, 0, 0,
      b * 0.299, b * 0.587, b * 0.114, 0, 0,
      0.299,     0.587,     0.114,     0, 0,
    ];
  }
}
