import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('tool/l10n/fragments/track_misc.json');
  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  (data['voice_audioChip'] as Map<String, dynamic>)['or'] = 'ଅଡିଓ';
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  print('Updated voice_audioChip to ଅଡିଓ');
}

