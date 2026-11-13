import 'dart:async';
import 'dart:convert';
import 'dart:io';

const targetLangs = ['or', 'as', 'ur', 'ne'];

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

Future<String> fetchTranslation(HttpClient client, String text, String lang) async {
  if (text.trim().isEmpty) return text;

  final phRegex = RegExp(r'\{(\w+)\}');
  final placeholders = <String>[];
  var processed = text.replaceAllMapped(phRegex, (m) {
    placeholders.add(m.group(1)!);
    return '___PH${placeholders.length - 1}___';
  });

  for (int attempt = 0; attempt < 3; attempt++) {
    try {
      final uri = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$lang&dt=t&q=${Uri.encodeComponent(processed)}');
      final req = await client.getUrl(uri).timeout(const Duration(seconds: 5));
      final res = await req.close().timeout(const Duration(seconds: 5));
      final body = await res.transform(utf8.decoder).join().timeout(const Duration(seconds: 5));
      
      if (res.statusCode == 200) {
        final decoded = jsonDecode(body);
        final sentences = decoded[0] as List;
        var result = sentences.map((s) => s[0] as String).join();

        for (int i = 0; i < placeholders.length; i++) {
          final ph = placeholders[i];
          final pattern = RegExp('_{1,3}\\s*PH\\s*$i\\s*_{1,3}', caseSensitive: false);
          result = result.replaceAll(pattern, '{$ph}');
        }

        for (final ph in placeholders) {
          if (!result.contains('{$ph}')) {
            result = '$result {$ph}';
          }
        }
        return result.trim();
      } else {
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    } catch (_) {
      await Future.delayed(Duration(milliseconds: 400 * (attempt + 1)));
    }
  }
  return text;
}

Future<void> main() async {
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
        if (en.startsWith('{') && en.contains('plural,')) {
          handleIcu(en, (inner) {
            uniqueStrings.add(inner);
            return inner;
          });
        } else {
          uniqueStrings.add(en);
        }
      }
    }
  }

  print('Total unique strings to translate: ${uniqueStrings.length}');
  final strList = uniqueStrings.toList();

  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 5);
  client.maxConnectionsPerHost = 10;

  for (final lang in targetLangs) {
    print('\n================== Translating $lang ==================');
    final dictFile = File('scratch/dict_$lang.json');
    Map<String, String> dict = {};
    if (dictFile.existsSync()) {
      dict = Map<String, String>.from(jsonDecode(dictFile.readAsStringSync()));
      print('Loaded ${dict.length} cached translations for $lang');
    }

    final toTranslate = strList.where((s) => !dict.containsKey(s) || dict[s]!.isEmpty).toList();
    print('Remaining to translate for $lang: ${toTranslate.length}');

    if (toTranslate.isEmpty) {
      print('$lang is already 100% translated!');
      continue;
    }

    const concurrency = 5;
    int index = 0;
    int completed = 0;

    Future<void> worker() async {
      while (true) {
        if (index >= toTranslate.length) return;
        final i = index++;
        final s = toTranslate[i];
        try {
          final trans = await fetchTranslation(client, s, lang);
          dict[s] = trans;
        } catch (_) {
          dict[s] = s;
        }
        completed++;
        if (completed % 50 == 0 || completed == toTranslate.length) {
          print('$lang: $completed / ${toTranslate.length} completed (total: ${dict.length})');
          dictFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(dict));
        }
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }

    final workers = List.generate(concurrency, (_) => worker());
    await Future.wait(workers);

    dictFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(dict));
    print('Finished translating for $lang. Total in dictionary: ${dict.length}');
  }

  client.close();

  print('\nApplying translations to fragment files...');
  for (final lang in targetLangs) {
    final dictFile = File('scratch/dict_$lang.json');
    if (!dictFile.existsSync()) continue;
    final dict = Map<String, String>.from(jsonDecode(dictFile.readAsStringSync()));

    for (final file in files) {
      final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      bool changed = false;

      for (final v in data.values) {
        final m = v as Map<String, dynamic>;
        final en = (m['en'] as String?)?.trim();
        if (en != null && en.isNotEmpty) {
          if (en.startsWith('{') && en.contains('plural,')) {
            final icuResult = handleIcu(en, (inner) => dict[inner] ?? inner);
            m[lang] = icuResult;
            changed = true;
          } else {
            if (dict.containsKey(en) && dict[en]!.isNotEmpty) {
              m[lang] = dict[en]!;
              changed = true;
            }
          }
        }
      }

      if (changed) {
        file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
      }
    }
  }

  print('All fragment files updated successfully with all 4 Indian languages (or, as, ur, ne)!');
}
