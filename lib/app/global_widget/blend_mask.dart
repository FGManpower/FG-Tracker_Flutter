import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that applies a [BlendMode] (such as [BlendMode.multiply] to remove
/// white backgrounds) to its child when compositing onto the canvas.
class BlendMask extends SingleChildRenderObjectWidget {
  final BlendMode blendMode;
  final double opacity;

  const BlendMask({
    super.key,
    required this.blendMode,
    this.opacity = 1.0,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBlendMask(blendMode, opacity);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBlendMask renderObject) {
    renderObject
      ..blendMode = blendMode
      ..opacity = opacity;
  }
}

class RenderBlendMask extends RenderProxyBox {
  BlendMode blendMode;
  double opacity;

  RenderBlendMask(this.blendMode, this.opacity);

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..blendMode = blendMode
      ..color = Color.fromRGBO(255, 255, 255, opacity);
    context.canvas.saveLayer(rect, paint);
    super.paint(context, offset);
    context.canvas.restore();
  }
}
