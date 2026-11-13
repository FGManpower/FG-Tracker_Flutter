import 'dart:convert';
import 'dart:io';

void main() {
  final fragmentsDir = Directory('tool/l10n/fragments');
  final files = fragmentsDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList();

  final uniqueStrings = <String>{};
  for (final file in files) {
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    for (final v in data.values) {
      final m = v as Map<String, dynamic>;
      final en = (m['en'] as String?)?.trim();
      if (en != null && en.isNotEmpty) {
        uniqueStrings.add(en);
      }
    }
  }

  final dictFile = File('scratch/dict_as.json');
  final dict = Map<String, String>.from(jsonDecode(dictFile.readAsStringSync()));
  final strList = uniqueStrings.toList();
  final toTranslate = strList.where((s) => !dict.containsKey(s) || dict[s]!.isEmpty).toList();

  print('Remaining for as: ${toTranslate.length}');
  print('First 5 remaining:');
  for (int i = 0; i < 5 && i < toTranslate.length; i++) {
    print('[$i]: "${toTranslate[i]}"');
  }
}

