import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'language_controller.dart';
import 'language_options.dart';
import 'language_theme.dart';
import 'widgets/language_card.dart';

/// Side menu → Language item (one shared widget). Same look as the other
/// side menu items: translate icon in a lavender tile, the word "Language"
/// in the current language, the current language in its own script on the
/// right, chevron. Tap → closes the drawer (when inside one) → opens
/// [showLanguageSheet].
class LanguageSettingsRow extends StatelessWidget {
  const LanguageSettingsRow({super.key, this.controller});

  final LanguageController? controller;

  void _open(BuildContext context, LanguageController c) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      // Open the sheet from the Scaffold's context: the drawer (and this
      // row's context) is removed once it has closed.
      final host = scaffold.context;
      scaffold.closeDrawer();
      showLanguageSheet(host, controller: c);
      return;
    }
    showLanguageSheet(context, controller: c);
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
          borderRadius: BorderRadius.circular(15),
          onTap: () => _open(context, c),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: LanguageColors.letterTile,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.translate_rounded,
                        color: LanguageColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      current.languageLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E202B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      current.nativeName,
                      key: const Key('settings-language-current'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: LanguageColors.primary,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF7E69F7), size: 24),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Opens the full-screen "Choose your language" screen. Picking a language saves
/// it, closes the screen and applies it to the whole app instantly.
Future<void> showLanguageSheet(BuildContext context,
    {LanguageController? controller}) {
  final c = controller ?? LanguageController.to;
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LanguageSheet(controller: c, isFullScreen: true),
        ),
      ),
    ),
  );
}

class LanguageSheet extends StatefulWidget {
  const LanguageSheet({
    super.key,
    required this.controller,
    this.isFullScreen = true,
  });

  final LanguageController controller;
  final bool isFullScreen;

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
      : kWorkingLanguages.where((o) => o.matches(_query)).toList(growable: false);

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
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
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
