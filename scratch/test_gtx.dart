import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  try {
    final client = HttpClient();
    final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=or&dt=t&q=hello%20world');
    final req = await client.getUrl(url);
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('Response status: ${res.statusCode}');
    print('Response body: $body');
  } catch (e) {
    print('Error: $e');
  }
}

