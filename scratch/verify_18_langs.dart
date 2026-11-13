import 'dart:convert';
import 'dart:io';

const langs18 = [
  'en', 'hi', 'mr', 'gu', 'kn', 'bn', 'ml', 'ta', 'te', 'pa', 'or',
  'es', 'fr', 'de', 'ar', 'pt', 'ja', 'zh'
];

void main() {
  final fragmentsDir = Directory('tool/l10n/fragments');
  final files = fragmentsDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList();

  int totalKeys = 0;
  final missing = {for (final l in langs18) l: <String>[]};

  for (final file in files) {
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    for (final entry in data.entries) {
      totalKeys++;
      final m = entry.value as Map<String, dynamic>;
      for (final l in langs18) {
        final val = (m[l] as String?)?.trim() ?? '';
        if (val.isEmpty) {
          missing[l]!.add(entry.key);
        }
      }
    }
  }

  print('Total keys checked: $totalKeys');
  for (final l in langs18) {
    print('Lang $l: ${missing[l]!.length} missing');
    if (missing[l]!.isNotEmpty && missing[l]!.length < 10) {
      print('  Missing keys: ${missing[l]}');
    }
  }
}

