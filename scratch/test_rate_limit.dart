import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();
  final uri = Uri.parse(
      'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=as&dt=t&q=hello');
  try {
    final req = await client.getUrl(uri);
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('Status: ${res.statusCode}');
    print('Body: $body');
  } catch (e) {
    print('Error: $e');
  }
}

