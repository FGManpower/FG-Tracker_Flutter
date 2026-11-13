import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<String> fetchTranslation(HttpClient client, String text, String lang) async {
  if (text.trim().isEmpty) return text;

  final phRegex = RegExp(r'\{(\w+)\}');
  final placeholders = <String>[];
  var processed = text.replaceAllMapped(phRegex, (m) {
    placeholders.add(m.group(1)!);
    return '___PH${placeholders.length - 1}___';
  });

  try {
    final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$lang&dt=t&q=${Uri.encodeComponent(processed)}');
    final req = await client.getUrl(uri).timeout(const Duration(seconds: 5));
    final res = await req.close().timeout(const Duration(seconds: 5));
    if (res.statusCode == 200) {
      final body = await res.transform(utf8.decoder).join().timeout(const Duration(seconds: 5));
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
    }
  } catch (e) {
    print('Error translating "$text" to $lang: $e');
  }
  return text;
}

void main() async {
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 5);
  final res = await fetchTranslation(client, 'Hello world', 'or');
  print('Result: $res');
  client.close();
}

