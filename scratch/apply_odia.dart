import 'dart:convert';
import 'dart:io';

String handleIcu(String text, String Function(String) translateInner) {
  final trimmed = text.trim();
  if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) {
    if (trimmed.contains('{count, plural, =1{1 Member} other{{count} Members}}')) {
      final m = translateInner('Member');
      final ms = translateInner('Members');
      return '{group} ({count, plural, =1{1 $m} other{{count} $ms}})';
    }
    return translateInner(text);
  }

  final prefixMatch = RegExp(r'^\{(\w+),\s*plural,').firstMatch(trimmed);
  if (prefixMatch == null) {
    return translateInner(text);
  }

  final varName = prefixMatch.group(1)!;
  var rest = trimmed.substring(prefixMatch.end);
  if (rest.endsWith('}')) {
    rest = rest.substring(0, rest.length - 1);
  }

  final buffer = StringBuffer('{$varName, plural, ');
  int idx = 0;
  while (idx < rest.length) {
    while (idx < rest.length && rest[idx].trim().isEmpty) {
      idx++;
    }
    if (idx >= rest.length) break;

    final tagMatch = RegExp(r'^(=[0-9]+|other)\s*\{').firstMatch(rest.substring(idx));
    if (tagMatch == null) break;

    final caseTag = tagMatch.group(1)!;
    idx += tagMatch.end;

    int depth = 1;
    final contentStart = idx;
    while (idx < rest.length && depth > 0) {
      if (rest[idx] == '{') depth++;
      if (rest[idx] == '}') depth--;
      idx++;
    }

    final content = rest.substring(contentStart, idx - 1);
    final translated = translateInner(content);
    buffer.write('$caseTag{$translated} ');
  }
  buffer.write('}');
  return buffer.toString().replaceAll(' }', '}');
}

void main() {
  final dictFile = File('scratch/dict_or.json');
  final dict = Map<String, String>.from(jsonDecode(dictFile.readAsStringSync()));
  print('Loaded ${dict.length} Odia translations');

  final fragmentsDir = Directory('tool/l10n/fragments');
  final files = fragmentsDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList();

  int totalKeys = 0;
  int updated = 0;

  for (final file in files) {
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    for (final v in data.values) {
      totalKeys++;
      final m = v as Map<String, dynamic>;
      final en = (m['en'] as String?)?.trim();
      if (en != null && en.isNotEmpty) {
        if (en.startsWith('{') && en.contains('plural,')) {
          final res = handleIcu(en, (inner) => dict[inner] ?? inner);
          m['or'] = res;
          updated++;
        } else {
          if (dict.containsKey(en) && dict[en]!.isNotEmpty) {
            m['or'] = dict[en]!;
            updated++;
          }
        }
      }
    }
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }

  print('Applied Odia to all fragments: $updated / $totalKeys keys set');
}

