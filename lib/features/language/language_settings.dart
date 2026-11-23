import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fgtracker/app/global_widget/app_back_button.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'language_controller.dart';
import 'language_options.dart';
import 'language_theme.dart';
import 'widgets/language_card.dart';

/// Sizes of [LanguageSettingsRow]. The side menu passes its ScreenUtil values
/// (15.sp title, 12.sp subtitle, 44.w tile …) so the row matches the other
/// menu items exactly; the defaults are the same numbers unscaled.
class LanguageRowSizes {
  const LanguageRowSizes({
    this.tile = 44,
    this.tileRadius = 14,
    this.icon = 22,
    this.gap = 14,
    this.title = 15,
    this.subtitleGap = 3,
    this.subtitle = 12,
    this.chevron = 24,
    this.padV = 8,
    this.padH = 8,
    this.radius = 15,
    this.appBarHeight = 50,
    this.appBarTitle = 20,
    this.appBarIcon = 20,
  });

  final double tile, tileRadius, icon, gap, title, subtitleGap, subtitle;
  final double chevron, padV, padH, radius;

  /// Language screen app bar, same as the app's `reusableAppbar`
  /// (50.h toolbar, 20.sp title, 20.sp back icon).
  final double appBarHeight, appBarTitle, appBarIcon;
}

/// Side menu → Language item (one shared widget). Same look as the other
/// side menu items: translate icon in a lavender tile, the word "Language"
/// in the current language with "Change app language" under it (no
/// selected-language name), chevron. Tap → closes the drawer (when inside one) → opens
/// [showLanguageSheet].
class LanguageSettingsRow extends StatelessWidget {
  const LanguageSettingsRow({
    super.key,
    this.controller,
    this.sizes = const LanguageRowSizes(),
  });

  final LanguageController? controller;
  final LanguageRowSizes sizes;

  void _open(BuildContext context, LanguageController c) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      // Open the sheet from the Scaffold's context: the drawer (and this
      // row's context) is removed once it has closed.
      final host = scaffold.context;
      scaffold.closeDrawer();
      showLanguageSheet(host, controller: c, sizes: sizes);
      return;
    }
    showLanguageSheet(context, controller: c, sizes: sizes);
  }

  @override
  Widget build(BuildContext context) {
    final c = controller ?? LanguageController.to;
    return Obx(() {
      final current = c.current;
      return Semantics(
        button: true,
        label: '${current.languageLabel}, ${current.englishName}',
        onTap: () => _open(context, c),
        excludeSemantics: true,
        child: InkWell(
          key: const Key('settings-language-row'),
          borderRadius: BorderRadius.circular(sizes.radius),
          onTap: () => _open(context, c),
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: sizes.padV, horizontal: sizes.padH),
            child: Row(
              children: [
                Container(
                  width: sizes.tile,
                  height: sizes.tile,
                  decoration: BoxDecoration(
                    color: LanguageColors.letterTile,
                    borderRadius: BorderRadius.circular(sizes.tileRadius),
                  ),
                  child: Icon(Icons.translate_rounded,
                      color: LanguageColors.primary, size: sizes.icon),
                ),
                SizedBox(width: sizes.gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.languageLabel,
                        key: const Key('settings-language-title'),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: sizes.title,
                          fontFamily: FontFamily.interBold,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E202B),
                        ),
                      ),
                      SizedBox(height: sizes.subtitleGap),
                      Text(
                        current.menuSubtitle,
                        key: const Key('settings-language-subtitle'),
                        // Always one line, like the other menu subtitles.
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: sizes.subtitle,
                          fontFamily: FontFamily.interRegular,
                          color: Color(0xFF7A7F93),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: const Color(0xFF7E69F7), size: sizes.chevron),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Opens the full-screen language list (side menu → Language), with the same
/// app bar as the other screens. Picking a language saves it, closes the
/// screen and applies it to the whole app instantly.
Future<void> showLanguageSheet(
  BuildContext context, {
  LanguageController? controller,
  LanguageRowSizes sizes = const LanguageRowSizes(),
}) {
  final c = controller ?? LanguageController.to;
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: _languageAppBar(context, c.current.languageLabel, sizes),
        body: SafeArea(
          top: false,
          child: LanguageSheet(
            controller: c,
            isFullScreen: true,
            showHeader: false,
          ),
        ),
      ),
    ),
  );
}

/// Same look as `reusableAppbar` (lib/app/global_widget/common_widget.dart).
AppBar _languageAppBar(
    BuildContext context, String title, LanguageRowSizes sizes) {
  const Color purple = Color(0xFF5045B9);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AppBar(
    key: const Key('language-sheet-appbar'),
    backgroundColor: isDark ? ToggleThemeData.darkThemeBackground : Colors.white,
    elevation: 1,
    scrolledUnderElevation: 1,
    surfaceTintColor: AppBarStyle.surfaceTintColor,
    shadowColor: purple.withValues(alpha: 0.1),
    centerTitle: false,
    iconTheme: const IconThemeData(color: purple),
    automaticallyImplyLeading: false,
    leadingWidth: AppBarStyle.leadingWidth,
    leading: AppBarStyle.leading(
      onTap: () => Navigator.of(context).maybePop(),
    ),
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class LanguageSheet extends StatefulWidget {
  const LanguageSheet({
    super.key,
    required this.controller,
    this.isFullScreen = true,
    this.showHeader = true,
  });

  final LanguageController controller;
  final bool isFullScreen;

  /// Title, subtitle and close button at the top. Off when the screen has
  /// its own app bar.
  final bool showHeader;

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  bool _busy = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<LanguageOption> get _visible => _query.trim().isEmpty
      ? kWorkingLanguages
      : kWorkingLanguages
          .where((o) => o.matches(_query))
          .toList(growable: false);

  Future<void> _pick(LanguageOption option) async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    if (option.code == widget.controller.current.code &&
        widget.controller.hasSavedLanguage) {
      navigator.pop();
      return;
    }
    _busy = true;
    navigator.pop();
    await widget.controller.setLanguage(option.code);
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.controller.current;
    final media = MediaQuery.of(context);
    final visible = _visible;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 520,
        ),
        child: Container(
          key: const Key('language-sheet'),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.isFullScreen) ...[
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: LanguageColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
              if (widget.showHeader)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              current.title,
                              style: const TextStyle(
                                fontSize: 22,
                                height: 1.3,
                                fontWeight: FontWeight.w700,
                                color: LanguageColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              current.subtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.35,
                                color: LanguageColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        key: const Key('language-sheet-close'),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: LanguageColors.textSecondary,
                          size: 26,
                        ),
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              if (!widget.showHeader) const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    key: const Key('language-sheet-search'),
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: LanguageColors.text,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: LanguageColors.card,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: current.searchHint,
                      hintStyle: const TextStyle(
                        fontSize: 14.5,
                        color: LanguageColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: LanguageColors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: LanguageColors.textSecondary,
                                size: 18,
                              ),
                              onPressed: () {
                                _search.clear();
                                setState(() => _query = '');
                              },
                            ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: LanguageColors.cardBorder,
                          width: 1,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: LanguageColors.cardBorder,
                          width: 1,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: LanguageColors.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            current.noResults,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: LanguageColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                            20, 4, 20, 24 + media.viewPadding.bottom),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final o = visible[i];
                          return LanguageCard(
                            option: o,
                            height: 64,
                            marker: LanguageCardMarker.radio,
                            selected: o.code == current.code,
                            onTap: () => _pick(o),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
