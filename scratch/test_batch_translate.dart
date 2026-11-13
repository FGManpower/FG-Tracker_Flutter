import 'dart:convert';
import 'dart:io';

Future<String> translateText(HttpClient client, String text, String targetLang) async {
  if (text.trim().isEmpty) return text;
  
  // Extract placeholders
  final phRegex = RegExp(r'\{(\w+)\}');
  final placeholders = <String>[];
  var processed = text.replaceAllMapped(phRegex, (m) {
    placeholders.add(m.group(1)!);
    return '___PH${placeholders.length - 1}___';
  });

  try {
    final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$targetLang&dt=t&q=${Uri.encodeComponent(processed)}');
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
      return result;
    }
  } catch (e) {
    print('Error translating "$text" to $targetLang: $e');
  }
  return text;
}

Future<void> main() async {
  final client = HttpClient();
  final testStrings = [
    'Choose your language',
    'Delete 1 call?',
    'Your location is being shared with {count} family members',
    'Code: {code}',
  ];
  
  for (final lang in ['or', 'as', 'ur', 'ne']) {
    print('--- Testing $lang ---');
    for (final s in testStrings) {
      final t = await translateText(client, s, lang);
      print('$s -> $t');
    }
  }
  client.close();
}

