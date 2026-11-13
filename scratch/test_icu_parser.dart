String handleIcu(String text, String Function(String) translateInner) {
  final trimmed = text.trim();
  if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) {
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

    // Match case tag: e.g. =0, =1, other
    final tagMatch = RegExp(r'^(=[0-9]+|other)\s*\{').firstMatch(rest.substring(idx));
    if (tagMatch == null) break;

    final caseTag = tagMatch.group(1)!;
    idx += tagMatch.end; // now at content inside {

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
  final tests = [
    '{count, plural, =1{1 member} other{{count} members}}',
    '{count, plural, =0{{name}} =1{{name} and 1 other} other{{name} and {count} others}}',
    '{group} ({count, plural, =1{1 Member} other{{count} Members}})',
  ];

  for (final t in tests) {
    print('INPUT:  $t');
    print('OUTPUT: ${handleIcu(t, (s) => 'TR($s)')}');
    print('');
  }
}
