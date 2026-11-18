import 'package:fgtracker/l10n/l10n.dart';

/// Shows "These documents are drafts and may change." at the top of the
/// Legal screen. Off: the list now opens the published website pages.
const bool showLegalDraftNotice = false;

/// One legal document: its list labels, its page on the FG Tracker website
/// (opened on tap) and the bundled Markdown copy.
///
/// To replace a document, swap the `.md` file in `assets/legal/` (same name)
/// or change [assetPath] here. No UI change is needed.
class LegalDocument {
  const LegalDocument({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.websiteUrl,
  });

  /// Stable id, passed as the route argument to the document screen.
  final String id;

  /// Localized title (list row and document app bar).
  final String Function(AppLocalizations l10n) title;

  /// Localized one-line description shown under the title.
  final String Function(AppLocalizations l10n) subtitle;

  /// Bundled Markdown file. The document text itself stays English.
  final String assetPath;

  /// Published page on the FG Tracker website. Tapping the row opens it.
  final String websiteUrl;
}

/// The Legal screen shows these, in this order.
final List<LegalDocument> legalDocuments = [
  LegalDocument(
    id: 'privacy_policy',
    title: (l) => l.legal_privacyTitle,
    subtitle: (l) => l.legal_privacySubtitle,
    assetPath: 'assets/legal/01_global_privacy_policy.md',
    websiteUrl: '${legalWebsiteUrl}privacy-policy/',
  ),
  LegalDocument(
    id: 'terms_eula',
    title: (l) => l.legal_termsTitle,
    subtitle: (l) => l.legal_termsSubtitle,
    assetPath: 'assets/legal/02_terms_and_eula.md',
    websiteUrl: '${legalWebsiteUrl}terms/',
  ),
  LegalDocument(
    id: 'enterprise_service_agreement',
    title: (l) => l.legal_enterpriseTitle,
    subtitle: (l) => l.legal_enterpriseSubtitle,
    assetPath: 'assets/legal/03_enterprise_service_agreement.md',
    websiteUrl: '${legalWebsiteUrl}enterprise-service-agreement/',
  ),
  LegalDocument(
    id: 'data_processing_agreement',
    title: (l) => l.legal_dpaTitle,
    subtitle: (l) => l.legal_dpaSubtitle,
    assetPath: 'assets/legal/04_data_processing_agreement.md',
    websiteUrl: '${legalWebsiteUrl}data-processing-agreement/',
  ),
  LegalDocument(
    id: 'data_retention_deletion',
    title: (l) => l.legal_retentionTitle,
    subtitle: (l) => l.legal_retentionSubtitle,
    assetPath: 'assets/legal/05_data_retention_and_deletion_policy.md',
    websiteUrl: '${legalWebsiteUrl}data-retention-policy/',
  ),
  LegalDocument(
    id: 'data_protection_security',
    title: (l) => l.legal_securityTitle,
    subtitle: (l) => l.legal_securitySubtitle,
    assetPath:
        'assets/legal/06_data_protection_and_information_security_policy.md',
    websiteUrl: '${legalWebsiteUrl}information-security-policy/',
  ),
];

/// The document with [id], or null when there is none.
LegalDocument? legalDocumentById(Object? id) {
  for (final doc in legalDocuments) {
    if (doc.id == id) return doc;
  }
  return null;
}

/// FG Tracker website (legal pages and contact details are published here).
const String legalWebsiteUrl = 'https://fgtracker.fgmanpower.com/';

/// A contact row on the Legal screen. Values are copied from the website
/// footer / contact page; [uri] is what opens on tap.
class LegalContact {
  const LegalContact({
    required this.id,
    required this.label,
    required this.value,
    required this.uri,
  });

  final String id;
  final String Function(AppLocalizations l10n) label;
  final String value;
  final String uri;
}

const String _legalOfficeAddress =
    'Ghatkopar West, Mumbai, Maharashtra 400086, India';

/// Contact details shown under the documents, in this order.
final List<LegalContact> legalContacts = [
  LegalContact(
    id: 'phone',
    label: (l) => l.call_phone,
    value: '+91 93727 23727',
    uri: 'tel:+919372723727',
  ),
  LegalContact(
    id: 'email',
    label: (l) => l.call_infoEmail,
    value: 'fgtracker@fgmanpower.com',
    uri: 'mailto:fgtracker@fgmanpower.com',
  ),
  LegalContact(
    id: 'address',
    label: (l) => l.about_address,
    value: _legalOfficeAddress,
    uri: Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': _legalOfficeAddress,
    }).toString(),
  ),
  LegalContact(
    id: 'website',
    label: (l) => l.about_website,
    value: 'fgtracker.fgmanpower.com',
    uri: legalWebsiteUrl,
  ),
];
