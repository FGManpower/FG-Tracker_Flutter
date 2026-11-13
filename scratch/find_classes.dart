import 'dart:io';

void main() {
  final file = File(r'C:\flutter_windows_3.47.2-stable\flutter\packages\flutter_localizations\lib\src\l10n\generated_material_localizations.dart');
  final lines = file.readAsLinesSync();
  final classRegex = RegExp(r'class MaterialLocalization([A-Za-z0-9]+)\s+extends');
  final matches = <String>{};
  for (final l in lines) {
    final m = classRegex.firstMatch(l);
    if (m != null) {
      matches.add(m.group(1)!);
    }
  }
  print('Found ${matches.length} classes:');
  print(matches.toList()..sort());
  
  final indianCodes = ['Hi', 'Bn', 'Te', 'Mr', 'Ta', 'Ur', 'Gu', 'Kn', 'Ml', 'Or', 'Pa', 'As', 'Ne', 'Sd', 'Sa', 'Kok', 'Mai', 'Bho'];
  for (final c in indianCodes) {
    print('$c: ${matches.contains(c)}');
  }
}

