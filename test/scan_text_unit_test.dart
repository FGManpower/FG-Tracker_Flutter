import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fgtracker/app/modules/scan_text/services/scan_text_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScanTextService Unit Tests', () {
    test('extractTextFromImage on non-existent file returns empty string gracefully', () async {
      final service = ScanTextService.instance;
      final result = await service.extractTextFromImage('/path/to/non_existent_image.png');
      expect(result, isEmpty);
    });

    test('extractTextFromImage does not throw or crash on blank/corrupted file', () async {
      final service = ScanTextService.instance;
      final tempFile = File('${Directory.systemTemp.path}/test_empty_image.png');
      tempFile.writeAsBytesSync([]);

      try {
        final result = await service.extractTextFromImage(tempFile.path);
        expect(result, isEmpty);
      } finally {
        if (tempFile.existsSync()) {
          tempFile.deleteSync();
        }
      }
    });
  });
}
