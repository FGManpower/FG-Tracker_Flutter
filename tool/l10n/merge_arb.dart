// Builds lib/l10n/app_<code>.arb from tool/l10n/fragments/*.json, then runs
// `flutter gen-l10n`.
//
//   dart run tool/l10n/merge_arb.dart            # merge + gen-l10n
//   dart run tool/l10n/merge_arb.dart --no-gen   # merge only
//
// Fragment format (one file per area, e.g. walkie.json):
//   {
//     "walkie_holdToTalk": {
//       "en": "Hold to talk", "hi": "...", "mr": "...", ... all 10 ...,
//       "description": "optional", "placeholders": { "name": {"type": "String"} }
//     }
//   }
//
// Fails (exit 1) when a key is defined twice, a language is missing or empty,
// or a placeholder used in English is missing in a translation.
// A lock file keeps parallel runs from writing the ARB files at the same time.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

const codes = [
  'en',
  'hi',
  'mr',
  'gu',
  'kn',
  'bn',
  'ml',
  'ta',
  'te',
  'pa',
  'or',
  'es',
  'fr',
  'de',
  'ar',
  'pt',
  'ja',
  'zh',
  'zh_Hant',
  'ur',
];
const fragmentsDir = 'tool/l10n/fragments';
const lockPath = 'build/l10n_merge.lock';

Future<void> main(List<String> args) async {
  Directory('build').createSync(recursive: true);
  final lock = await _acquireLock();
  try {
    final errors = <String>[];
    final merged = <String, Map<String, dynamic>>{};
    final owner = <String, String>{};
    final files = Directory(fragmentsDir)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final f in files) {
      final name = f.uri.pathSegments.last;
      Map<String, dynamic> data;
      try {
        data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      } catch (e) {
        errors.add('$name: invalid JSON: $e');
        continue;
      }
      for (final e in data.entries) {
        final key = e.key;
        if (!RegExp(r'^[a-z][a-zA-Z0-9_]*$').hasMatch(key)) {
          errors.add('$name: bad key "$key"');
          continue;
        }
        if (owner.containsKey(key)) {
          errors.add('$name: key "$key" already defined in ${owner[key]}');
          continue;
        }
        owner[key] = name;
        final v = e.value as Map<String, dynamic>;
        for (final c in codes) {
          final s = v[c];
          if (s is! String || s.trim().isEmpty) {
            errors.add('$name: "$key" missing $c');
          }
        }
        final en = v['en'];
        if (en is String) {
          final ph = RegExp(r'\{(\w+)[,}]')
              .allMatches(en)
              .map((m) => m.group(1)!)
              .toSet();
          for (final c in codes.skip(1)) {
            final s = v[c];
            if (s is! String) continue;
            for (final p in ph) {
              if (!s.contains('{$p')) {
                errors.add('$name: "$key" ($c) lacks placeholder {$p}');
              }
            }
          }
        }
        merged[key] = v;
      }
    }
    if (errors.isNotEmpty) {
      print(errors.join('\n'));
      print('merge_arb: ${errors.length} error(s); ARB files NOT written.');
      exitCode = 1;
      return;
    }
    const enc = JsonEncoder.withIndent('  ');
    final keys = merged.keys.toList()..sort();
    for (final c in codes) {
      final out = <String, Object>{'@@locale': c};
      for (final k in keys) {
        final v = merged[k]!;
        out[k] = v[c] as String;
        if (c == 'en') {
          final meta = <String, Object>{};
          if (v['description'] is String) meta['description'] = v['description'];
          if (v['placeholders'] is Map) meta['placeholders'] = v['placeholders'];
          if (meta.isNotEmpty) out['@$k'] = meta;
        }
      }
      File('lib/l10n/app_$c.arb').writeAsStringSync('${enc.convert(out)}\n');
    }
    print('merge_arb: ${keys.length} keys × ${codes.length} languages '
        'from ${files.length} fragment(s).');
    if (!args.contains('--no-gen')) {
      final r = await Process.run('flutter', ['gen-l10n'], runInShell: true);
      if (r.exitCode != 0) {
        stdout.write(r.stdout);
        stderr.write(r.stderr);
        print('merge_arb: flutter gen-l10n failed.');
        exitCode = 1;
      } else {
        print('merge_arb: gen-l10n done.');
      }
    }
  } finally {
    try {
      lock.deleteSync();
    } catch (_) {}
  }
}

Future<File> _acquireLock() async {
  final f = File(lockPath);
  for (var i = 0; i < 600; i++) {
    try {
      f.createSync(exclusive: true);
      return f;
    } on FileSystemException {
      // Stale lock (older than 5 minutes) → take it over.
      try {
        if (DateTime.now().difference(f.lastModifiedSync()).inMinutes >= 5) {
          f.deleteSync();
          continue;
        }
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }
  throw StateError('merge_arb: could not get $lockPath');
}
