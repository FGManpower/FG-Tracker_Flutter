import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Legal/Views/legal_app_bar.dart';
import 'package:fgtracker/app/modules/Legal/legal_documents.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows one bundled legal Markdown file (offline, no API).
///
/// Route argument: the document id from [legalDocuments].
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({super.key, this.document, this.bundle});

  /// When null, the document is looked up from the route argument.
  final LegalDocument? document;

  /// Asset bundle to read from; defaults to [rootBundle] (tests can inject).
  final AssetBundle? bundle;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  final ScrollController _scroll = ScrollController();
  late final LegalDocument? _doc =
      widget.document ?? legalDocumentById(Get.arguments);
  Future<String>? _text;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final doc = _doc;
    if (doc == null) return;
    // Future.sync: a bundle that throws right away still ends in the
    // error state (with Retry) instead of breaking the build.
    _text = Future.sync(
        () => (widget.bundle ?? rootBundle).loadString(doc.assetPath));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final doc = _doc;

    return Scaffold(
      backgroundColor: isDark ? ToggleThemeData.backgroundBlack : Colors.white,
      appBar: legalAppBar(context, doc?.title(l10n) ?? l10n.legal_title),
      body: SafeArea(
        top: false,
        child: doc == null
            ? _Message(text: l10n.legal_loadError, isDark: isDark)
            : FutureBuilder<String>(
                future: _text,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return _Message(
                      text: l10n.legal_loadError,
                      isDark: isDark,
                      actionLabel: l10n.common_retry,
                      onAction: () => setState(_load),
                    );
                  }
                  final text = snap.data ?? '';
                  if (text.trim().isEmpty) {
                    return _Message(
                      text: l10n.legal_emptyDocument,
                      isDark: isDark,
                    );
                  }
                  return Scrollbar(
                    controller: _scroll,
                    child: Markdown(
                      key: const ValueKey('legal_markdown'),
                      data: text,
                      controller: _scroll,
                      selectable: true,
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                      styleSheet: _styleSheet(context, isDark),
                      onTapLink: (_, href, __) => _openLink(href),
                    ),
                  );
                },
              ),
      ),
    );
  }

  MarkdownStyleSheet _styleSheet(BuildContext context, bool isDark) {
    final body = isDark ? const Color(0xFFE6E7EE) : const Color(0xFF1E202B);
    final heading = isDark ? Colors.white : const Color(0xFF0F0B4C);
    final border = isDark ? const Color(0xFF4A4B55) : const Color(0xFFDADCE6);
    final link = isDark ? const Color(0xFFB9AEFF) : const Color(0xFF5D47F1);

    // 16 px body text with comfortable line spacing.
    final p = TextStyle(fontSize: 16, height: 1.6, color: body);
    TextStyle h(double size) => TextStyle(
          fontSize: size,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: heading,
        );

    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: p,
      a: p.copyWith(color: link, decoration: TextDecoration.underline),
      strong: const TextStyle(fontWeight: FontWeight.w700),
      em: const TextStyle(fontStyle: FontStyle.italic),
      h1: h(22),
      h2: h(19),
      h3: h(17),
      h4: h(16),
      h5: h(16),
      h6: h(16),
      h1Padding: const EdgeInsets.only(top: 8, bottom: 4),
      h2Padding: const EdgeInsets.only(top: 12, bottom: 2),
      h3Padding: const EdgeInsets.only(top: 8),
      listBullet: p,
      listIndent: 24,
      blockSpacing: 12,
      blockquote: p.copyWith(fontStyle: FontStyle.italic),
      blockquoteDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2F36) : const Color(0xFFF3F2FB),
        border: Border(left: BorderSide(color: link, width: 3)),
      ),
      code: TextStyle(
        fontSize: 14,
        fontFamily: 'monospace',
        color: body,
        backgroundColor:
            isDark ? const Color(0xFF2E2F36) : const Color(0xFFF1F1F4),
      ),
      // Fixed-width columns make the package wrap the table in a horizontal
      // scroll view, so wide tables never overflow; cell text wraps.
      tableColumnWidth: const FixedColumnWidth(180),
      tableHead: TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w700,
        color: heading,
      ),
      tableBody: TextStyle(fontSize: 14, height: 1.4, color: body),
      tableBorder: TableBorder.all(color: border, width: 1),
      tableCellsPadding: const EdgeInsets.all(8),
      tableHeadAlign: TextAlign.start,
      tableScrollbarThumbVisibility: true,
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: border, width: 1)),
      ),
    );
  }

  /// Links inside a document open outside the app; only safe schemes.
  Future<void> _openLink(String? href) async {
    final uri = href == null ? null : Uri.tryParse(href.trim());
    if (uri == null) return;
    const allowed = {'http', 'https', 'mailto', 'tel'};
    if (!allowed.contains(uri.scheme.toLowerCase())) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Nothing to do: the text stays readable in the app.
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.text,
    required this.isDark,
    this.actionLabel,
    this.onAction,
  });

  final String text;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 40.sp,
              color: isDark ? const Color(0xFF8D90A0) : const Color(0xFFB0B3C2),
            ),
            SizedBox(height: 12.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.4,
                color: isDark ? const Color(0xFFE6E7EE) : const Color(0xFF4A4A4A),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 12.h),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
