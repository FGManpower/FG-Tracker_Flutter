import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Legal/Views/legal_app_bar.dart';
import 'package:fgtracker/app/modules/Legal/legal_documents.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [uri] outside the app. Returns false when nothing could open it.
typedef LegalLinkLauncher = Future<bool> Function(Uri uri);

Future<bool> _openExternally(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Side menu → Legal: the legal documents (each opens its page on the FG
/// Tracker website) and the contact details from the website.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, this.launcher});

  /// Test hook; defaults to url_launcher in an external app.
  final LegalLinkLauncher? launcher;

  static const _allowedSchemes = {'https', 'tel', 'mailto'};

  Future<void> _open(BuildContext context, String link, String error) async {
    final uri = Uri.tryParse(link);
    final ok = uri != null &&
        _allowedSchemes.contains(uri.scheme) &&
        await (launcher ?? _openExternally)(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? ToggleThemeData.backgroundBlack : const Color(0xFFF7F7FB),
      appBar: legalAppBar(context, l10n.legal_title),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            if (showLegalDraftNotice) ...[
              _DraftNotice(text: l10n.legal_draftNotice, isDark: isDark),
              SizedBox(height: 14.h),
            ],
            for (final doc in legalDocuments) ...[
              _LegalRow(
                key: ValueKey('legal_row_${doc.id}'),
                icon: Icons.description_outlined,
                title: doc.title(l10n),
                subtitle: doc.subtitle(l10n),
                isDark: isDark,
                onTap: () =>
                    _open(context, doc.websiteUrl, l10n.legal_loadError),
              ),
              SizedBox(height: 10.h),
            ],
            SizedBox(height: 10.h),
            _SectionTitle(text: l10n.about_contactUs, isDark: isDark),
            SizedBox(height: 10.h),
            for (final contact in legalContacts) ...[
              _LegalRow(
                key: ValueKey('legal_contact_${contact.id}'),
                icon: _contactIcon(contact.id),
                title: contact.label(l10n),
                subtitle: contact.value,
                isDark: isDark,
                onTap: () =>
                    _open(context, contact.uri, l10n.chat_unableToOpen),
              ),
              SizedBox(height: 10.h),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _contactIcon(String id) {
    switch (id) {
      case 'phone':
        return Icons.call_outlined;
      case 'email':
        return Icons.mail_outline_rounded;
      case 'address':
        return Icons.location_on_outlined;
      default:
        return Icons.language_rounded;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, required this.isDark});

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 4.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.3,
          fontFamily: FontFamily.interBold,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFFB5B8C6) : const Color(0xFF7A7F93),
        ),
      ),
    );
  }
}

class _DraftNotice extends StatelessWidget {
  const _DraftNotice({required this.text, required this.isDark});

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? const Color(0xFFFFD98A) : const Color(0xFF5C3D00);
    return Container(
      key: const ValueKey('legal_draft_notice'),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3020) : const Color(0xFFFFF4DE),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? const Color(0xFF8A6A2A) : const Color(0xFFF2C46D),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18.sp, color: fg),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.35,
                fontFamily: FontFamily.interMedium,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? ToggleThemeData.darkThemeBackground : Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3A3560)
                      : const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: isDark
                      ? const Color(0xFFB9AEFF)
                      : const Color(0xFF5D47F1),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.25,
                        fontFamily: FontFamily.interBold,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E202B),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.3,
                        fontFamily: FontFamily.interRegular,
                        color: isDark
                            ? const Color(0xFFB5B8C6)
                            : const Color(0xFF7A7F93),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Every row leaves the app (browser, dialer, mail, maps).
              Icon(
                Icons.open_in_new_rounded,
                size: 18.sp,
                color: isDark
                    ? const Color(0xFF8D90A0)
                    : const Color(0xFFB0B3C2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
