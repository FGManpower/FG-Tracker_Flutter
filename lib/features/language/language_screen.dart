import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'language_controller.dart';
import 'language_options.dart';
import 'language_theme.dart';
import 'widgets/language_card.dart';

/// "Choose your language" — shown once, right after OTP, when no language is
/// saved on this phone. Back does nothing (the choice can't be skipped and
/// the user never returns to OTP).
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key, this.controller});

  /// Injected in tests; defaults to [LanguageController.to].
  final LanguageController? controller;

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late final LanguageController _controller =
      widget.controller ?? LanguageController.to;
  final TextEditingController _search = TextEditingController();

  late LanguageOption _selected;
  late final List<LanguageOption> _ordered;
  String _query = '';
  bool _saving = false;

  static const double _side = 20;
  static const double _gap = 10;
  static const double _buttonHeight = 56;
  static const double _fadeHeight = 28;
  static const double _bottomPad = 12;

  @override
  void initState() {
    super.initState();
    // A new user always starts with English selected (product rule), then
    // picks any language. The order is the fixed order of kAppLanguages
    // (English first); the phone language and any saved language are ignored.
    _selected = kAppLanguages.first;
    _ordered = kAppLanguages;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<LanguageOption> get _visible =>
      _ordered.where((o) => o.matches(_query)).toList(growable: false);

  void _select(LanguageOption option) {
    if (_saving || option.code == _selected.code) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = option);
  }

  Future<void> _continue() async {
    if (_saving) return;
    setState(() => _saving = true);
    FocusScope.of(context).unfocus();
    final route = ModalRoute.of(context);
    try {
      await _controller.setLanguage(_selected.code);
      _controller.finishLanguageStep(route);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    // Large text: one column so long native names are never cut.
    final columns = textScale >= 1.3 ? 1 : 2;
    final visible = _visible;

    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: LanguageColors.page,
        ),
        child: Scaffold(
          backgroundColor: LanguageColors.page,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [LanguageColors.pageGlow, LanguageColors.page],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _header(),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: _side),
                            child: _searchField(),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: visible.isEmpty
                                ? _noMatch()
                                : _grid(visible, columns),
                          ),
                        ],
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _bottomBar(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fade(Widget child, String key) => AnimatedSwitcher(
        duration: kLanguageAnim,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, if (current != null) current],
        ),
        child: KeyedSubtree(key: ValueKey(key), child: child),
      );

  Widget _header() {
    final o = _selected;
    return Padding(
      padding: const EdgeInsets.fromLTRB(_side, 16, _side, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: LanguageColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: LanguageColors.primary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.translate_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(height: 18),
          _fade(
            Text(
              o.title,
              key: const Key('language-title'),
              style: const TextStyle(
                fontSize: 25,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: LanguageColors.text,
              ),
            ),
            'title-${o.code}',
          ),
          const SizedBox(height: 4),
          _fade(
            Text(
              o.subtitle,
              key: const Key('language-subtitle'),
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: LanguageColors.textSecondary,
              ),
            ),
            'subtitle-${o.code}',
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: LanguageColors.cardBorder, width: 1),
    );
    return SizedBox(
      height: 50,
      child: TextField(
        key: const Key('language-search'),
        controller: _search,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 15, color: LanguageColors.text),
        decoration: InputDecoration(
          filled: true,
          fillColor: LanguageColors.card,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          hint: _fade(
            Text(
              _selected.searchHint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 15, color: LanguageColors.textSecondary),
            ),
            'hint-${_selected.code}',
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: LanguageColors.textSecondary, size: 22),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  key: const Key('language-search-clear'),
                  tooltip:
                      MaterialLocalizations.of(context).deleteButtonTooltip,
                  icon: const Icon(Icons.close_rounded,
                      color: LanguageColors.textSecondary, size: 20),
                  onPressed: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide:
                const BorderSide(color: LanguageColors.primary, width: 1.2),
          ),
        ),
      ),
    );
  }

  double get _bottomBarHeight => _fadeHeight + _buttonHeight + _bottomPad;

  Widget _grid(List<LanguageOption> visible, int columns) {
    return GridView.builder(
      key: const Key('language-grid'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(_side, 12, _side, _bottomBarHeight + 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: _gap,
        crossAxisSpacing: _gap,
        mainAxisExtent: 70,
      ),
      itemCount: visible.length,
      itemBuilder: (_, i) {
        final o = visible[i];
        return LanguageCard(
          option: o,
          selected: o.code == _selected.code,
          onTap: () => _select(o),
        );
      },
    );
  }

  Widget _noMatch() {
    return Padding(
      padding: EdgeInsets.only(bottom: _bottomBarHeight),
      child: Center(
        child: _fade(
          Text(
            _selected.noResults,
            key: const Key('language-no-match'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15, color: LanguageColors.textSecondary),
          ),
          'nomatch-${_selected.code}',
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Soft fade so the grid scrolls "behind" the button.
        IgnorePointer(
          child: Container(
            height: _fadeHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  LanguageColors.page.withValues(alpha: 0),
                  LanguageColors.page,
                ],
              ),
            ),
          ),
        ),
        Container(
          color: LanguageColors.page,
          padding: const EdgeInsets.fromLTRB(_side, 0, _side, _bottomPad),
          child: SizedBox(
            height: _buttonHeight,
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('language-continue'),
              onPressed: _saving ? null : _continue,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: LanguageColors.primary,
                disabledBackgroundColor: LanguageColors.primary,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                shadowColor: LanguageColors.primary.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      key: Key('language-continue-loader'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : _fade(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _selected.continueLabel,
                              key: const Key('language-continue-label'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                      'cta-${_selected.code}',
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
