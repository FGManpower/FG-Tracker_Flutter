import 'dart:async';
import 'dart:convert';
import 'dart:io';

const targetLangs = ['or', 'as', 'ur', 'ne'];

final icuRegex = RegExp(r'^\{(\w+),\s*plural,\s*(.+)\}$', dotAll: true);

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

  // Protect placeholders
  final phRegex = RegExp(r'\{(\w+)\}');
  final placeholders = <String>[];
  var processed = text.replaceAllMapped(phRegex, (m) {
    placeholders.add(m.group(1)!);
    return '___PH${placeholders.length - 1}___';
  });

  try {
    final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$lang&dt=t&q=${Uri.encodeComponent(processed)}');
    final req = await client.getUrl(uri);
    final res = await req.close();
    if (res.statusCode == 200) {
      final body = await res.transform(utf8.decoder).join();
      final decoded = jsonDecode(body);
      final sentences = decoded[0] as List;
      var result = sentences.map((s) => s[0] as String).join();

      // Restore placeholders
      for (int i = 0; i < placeholders.length; i++) {
        final ph = placeholders[i];
        final pattern = RegExp('_{1,3}\\s*PH\\s*$i\\s*_{1,3}', caseSensitive: false);
        result = result.replaceAll(pattern, '{$ph}');
      }

      // Final check: if any placeholder wasn't restored, append or fix
      for (final ph in placeholders) {
        if (!result.contains('{$ph}')) {
          result = '$result {$ph}';
        }
      }

      return result.trim();
    }
  } catch (e) {
    // Retry once on failure
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final uri = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$lang&dt=t&q=${Uri.encodeComponent(processed)}');
      final req = await client.getUrl(uri);
      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        final decoded = jsonDecode(body);
        final sentences = decoded[0] as List;
        var result = sentences.map((s) => s[0] as String).join();
        for (int i = 0; i < placeholders.length; i++) {
          final ph = placeholders[i];
          final pattern = RegExp('_{1,3}\\s*PH\\s*$i\\s*_{1,3}', caseSensitive: false);
          result = result.replaceAll(pattern, '{$ph}');
        }
        return result.trim();
      }
    } catch (_) {}
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

  final client = HttpClient();

  for (final lang in targetLangs) {
    print('\n================== Processing $lang ==================');
    final cacheFile = File('scratch/cache_$lang.json');
    Map<String, String> cache = {};
    if (cacheFile.existsSync()) {
      cache = Map<String, String>.from(jsonDecode(cacheFile.readAsStringSync()));
      print('Loaded ${cache.length} cached translations for $lang');
    }

    int translatedCount = 0;

    for (final file in files) {
      final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      bool changed = false;

      for (final entry in data.entries) {
        final key = entry.key;
        final map = entry.value as Map<String, dynamic>;
        final enVal = (map['en'] as String?)?.trim() ?? '';
        final currentVal = (map[lang] as String?)?.trim() ?? '';

        if (enVal.isEmpty) continue;
        if (currentVal.isNotEmpty) continue; // Already translated

        // Check cache
        if (cache.containsKey(enVal)) {
          map[lang] = cache[enVal]!;
          changed = true;
          continue;
        }

        // Translate
        String result;
        if (enVal.startsWith('{') && enVal.contains('plural,')) {
          // ICU Plural
          final segments = <String>[];
          handleIcu(enVal, (inner) {
            segments.add(inner);
            return inner;
          });

          final translatedSegments = <String, String>{};
          for (final seg in segments) {
            if (!translatedSegments.containsKey(seg)) {
              if (cache.containsKey(seg)) {
                translatedSegments[seg] = cache[seg]!;
              } else {
                final t = await fetchTranslation(client, seg, lang);
                translatedSegments[seg] = t;
                cache[seg] = t;
              }
            }
          }

          result = handleIcu(enVal, (inner) => translatedSegments[inner] ?? inner);
        } else {
          result = await fetchTranslation(client, enVal, lang);
        }

        cache[enVal] = result;
        map[lang] = result;
        changed = true;
        translatedCount++;

        if (translatedCount % 50 == 0) {
          print('$lang: translated $translatedCount strings... (saving cache)');
          cacheFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(cache));
        }

        // Small throttle to be courteous
        await Future.delayed(const Duration(milliseconds: 15));
      }

      if (changed) {
        file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
      }
    }

    cacheFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(cache));
    print('Completed $lang: translated $translatedCount new strings. Cache size: ${cache.length}');
  }

  client.close();
  print('\nAll target languages processed successfully!');
}

