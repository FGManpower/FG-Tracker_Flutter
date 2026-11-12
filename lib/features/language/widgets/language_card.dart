import 'package:flutter/material.dart';

import '../language_options.dart';
import '../language_theme.dart';

/// Where the selection marker goes: a check badge on the top-right corner
/// (grid) or a radio circle on the right (Settings sheet).
enum LanguageCardMarker { cornerBadge, radio }

/// One language card. Used by the Language screen grid (70 high) and the
/// Settings sheet list (62 high).
class LanguageCard extends StatelessWidget {
  const LanguageCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
    this.height = 70,
    this.marker = LanguageCardMarker.cornerBadge,
  });

  final LanguageOption option;
  final bool selected;
  final VoidCallback onTap;
  final double height;
  final LanguageCardMarker marker;

  static const double _radius = 18;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: kLanguageAnim,
      curve: Curves.easeOut,
      height: height,
      decoration: BoxDecoration(
        color: selected ? LanguageColors.selectedCard : LanguageColors.card,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: selected ? LanguageColors.primary : LanguageColors.cardBorder,
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                LanguageColors.primary.withValues(alpha: selected ? 0.18 : 0.0),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _LetterTile(glyph: option.glyph, selected: selected),
                const SizedBox(width: 10),
                Expanded(child: _Names(option: option)),
                if (marker == LanguageCardMarker.radio) ...[
                  const SizedBox(width: 8),
                  _Radio(selected: selected),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      key: ValueKey('language-card-${option.code}'),
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: '${option.englishName}, ${option.nativeName}',
      onTap: onTap,
      excludeSemantics: true,
      child: marker == LanguageCardMarker.cornerBadge
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                card,
                Positioned(
                  top: -7,
                  right: -7,
                  child: AnimatedScale(
                    duration: kLanguageAnim,
                    curve: Curves.easeOutBack,
                    scale: selected ? 1 : 0,
                    child: const _CheckBadge(),
                  ),
                ),
              ],
            )
          : card,
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({required this.glyph, required this.selected});

  final String glyph;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kLanguageAnim,
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? LanguageColors.primary : LanguageColors.letterTile,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        glyph,
        maxLines: 1,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontSize: 17,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : LanguageColors.primary,
        ),
      ),
    );
  }
}

class _Names extends StatelessWidget {
  const _Names({required this.option});

  final LanguageOption option;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.nativeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15.5,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: LanguageColors.text,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          option.englishName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            height: 1.25,
            color: LanguageColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: LanguageColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kLanguageAnim,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? LanguageColors.primary : Colors.white,
        border: Border.all(
          color: selected ? LanguageColors.primary : LanguageColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}
