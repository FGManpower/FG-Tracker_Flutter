import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Endpoint config', () {
    test('package list URL is built from the one base URL', () {
      expect(Urls.packages, endsWith('/api/packages'));
      // Same host as every other API (no hardcoded second server)
      final base = Uri.parse(Urls.initialize);
      expect(Uri.parse(Urls.packages).host, base.host);
      expect(Uri.parse(Urls.packages).port, base.port);
    });
  });

  group('PackageListResponse', () {
    test('parses {data: {packages: []}}', () {
      final res = PackageListResponse.fromJson({
        'status': true,
        'data': {
          'packages': [
            {'moduleKey': 'walkie_talkie', 'title': 'Walkie-Talkie'},
          ],
        },
      });
      expect(res.status, isTrue);
      expect(res.packages.single.title, 'Walkie-Talkie');
    });

    test('parses {data: []} and ignores non-object items', () {
      final res = PackageListResponse.fromJson({
        'status': true,
        'data': [
          {'moduleKey': 'attendance', 'title': 'Attendance'},
          'junk',
          null,
          42,
        ],
      });
      expect(res.packages.length, 1);
    });

    test('null / non-map body gives an empty, failed response', () {
      expect(PackageListResponse.fromJson(null).packages, isEmpty);
      expect(PackageListResponse.fromJson('oops').status, isFalse);
      expect(PackageListResponse.fromJson([1, 2]).packages, isEmpty);
    });

    test('missing data key gives an empty list', () {
      expect(PackageListResponse.fromJson({'status': true}).packages, isEmpty);
    });
  });

  group('PackageItem', () {
    test('missing fields fall back safely', () {
      final item = PackageItem.fromJson(const {});
      expect(item.title, 'Package');
      expect(item.moduleKey, '');
      expect(item.highlights, isEmpty);
      expect(item.sortOrder, 0);
      expect(item.badge, isNull);
    });

    test('numbers as strings parse the same', () {
      final item = PackageItem.fromJson({'id': '7', 'sortOrder': '3'});
      expect(item.id, 7);
      expect(item.sortOrder, 3);
    });

    test('garbage numbers become defaults, not a crash', () {
      final item = PackageItem.fromJson({'id': 'abc', 'sortOrder': double.nan});
      expect(item.id, isNull);
      expect(item.sortOrder, 0);
    });

    test('only Walkie-Talkie is available; others are Coming soon', () {
      final walkie = PackageItem.fromJson(
          {'moduleKey': 'walkie_talkie', 'isAvailable': true});
      expect(walkie.isAvailable, isTrue);
      for (final key in ['attendance', 'safe_zone_route', 'live_tracking']) {
        expect(
            PackageItem.fromJson({'moduleKey': key, 'isAvailable': true})
                .isAvailable,
            isFalse,
            reason: key);
      }
    });

    test('backend can still switch Walkie-Talkie off', () {
      for (final v in [false, 'false', 0, '0']) {
        expect(
            PackageItem.fromJson(
                    {'moduleKey': 'walkie_talkie', 'isAvailable': v})
                .isAvailable,
            isFalse);
      }
    });

    test('Walkie-Talkie defaults to available when the flag is missing', () {
      expect(PackageItem.fromJson({'moduleKey': 'walkie_talkie'}).isAvailable,
          isTrue);
    });

    test('blank strings become null', () {
      final item = PackageItem.fromJson(
          {'tagline': '  ', 'badge': 'null', 'iconUrl': ''});
      expect(item.tagline, isNull);
      expect(item.badge, isNull);
      expect(item.iconUrl, isNull);
    });

    test('highlights skip null and blank entries', () {
      final item = PackageItem.fromJson({
        'highlights': ['Live map', null, '', '  ', 'History'],
      });
      expect(item.highlights, ['Live map', 'History']);
    });
  });
}
