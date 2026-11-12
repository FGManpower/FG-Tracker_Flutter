import 'package:flutter/material.dart';

/// Text that keeps its normal font size and only shrinks (never grows) when
/// it does not fit the available width — used for translated labels that are
/// longer than the English text (buttons, chips, tabs, labels in a Row).
///
/// Built on [FittedBox] (no LayoutBuilder), so it is also safe where Flutter
/// measures intrinsic sizes first: popup menu items, AlertDialog, IntrinsicWidth.
///
/// To shrink it needs a bounded width: inside a `Row`, wrap it in `Flexible`
/// / `Expanded`. In a fixed-size box (button, chip) it works as is. With an
/// unbounded width it simply shows the text at its normal size.
class AutoFitText extends StatelessWidget {
  const AutoFitText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.alignment,
    this.maxLines = 1,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// Where the shrunk text sits; defaults from [textAlign] (centre / start).
  final AlignmentGeometry? alignment;

  /// 1 = shrink to fit on one line. More than 1 = wrap up to [maxLines] lines
  /// and end with "…" (no shrinking).
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    if (maxLines > 1) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
    final align = alignment ??
        (textAlign == TextAlign.center
            ? Alignment.center
            : textAlign == TextAlign.end || textAlign == TextAlign.right
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart);
    // scaleDown: identical to a plain Text when it fits; shrinks otherwise.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: align,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}
