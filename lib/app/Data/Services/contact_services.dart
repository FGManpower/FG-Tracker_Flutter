import 'dart:developer';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  static List<Contact>? _cachedContacts;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 2);

  /// Clears in-memory contact cache (e.g., on logout or force refresh).
  static void clearCache() {
    _cachedContacts = null;
    _lastFetchTime = null;
  }

  Future<List<Contact>> getContacts({bool force = false}) async {
    if (!force && _cachedContacts != null && _lastFetchTime != null) {
      if (DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return _cachedContacts!;
      }
    }

    try {
      final bool granted =
          await FlutterContacts.requestPermission(readonly: true);

      if (!granted) {
        log("Contact permission denied");
        return _cachedContacts ?? [];
      }

      // Optimization: withThumbnail: false avoids transferring megabytes of
      // bitmap buffers across the method channel. FG uses server photos or initial avatars.
      final List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );

      final filtered = contacts.where((contact) {
        return contact.phones.isNotEmpty;
      }).toList();

      _cachedContacts = filtered;
      _lastFetchTime = DateTime.now();
      return filtered;
    } catch (e) {
      log("Contact Fetch Error: $e");
      return _cachedContacts ?? [];
    }
  }

  Future<List<String>> getMobileNumbers({bool force = false}) async {
    try {
      final List<Contact> contacts = await getContacts(force: force);

      final Set<String> numbers = {};

      for (final Contact contact in contacts) {
        for (final Phone phone in contact.phones) {
          String mobileNo = phone.number;

          mobileNo = mobileNo.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          );

          if (mobileNo.startsWith('91') && mobileNo.length > 10) {
            mobileNo = mobileNo.substring(2);
          }

          if (mobileNo.length > 10) {
            mobileNo = mobileNo.substring(mobileNo.length - 10);
          }

          if (mobileNo.length == 10) {
            numbers.add(mobileNo);
          }
        }
      }

      return numbers.toList();
    } catch (e) {
      log("Mobile Number Error: $e");
      return [];
    }
  }
}
