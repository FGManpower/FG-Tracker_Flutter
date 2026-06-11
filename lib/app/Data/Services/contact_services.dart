import 'dart:developer';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  Future<List<Contact>> getContacts() async {
    try {
      final permission =
      await FlutterContacts.permissions.request(
        PermissionType.read
      );

      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.limited) {
        log("Contact permission denied");
        return [];
      }

      final contacts = await FlutterContacts.getAll(
        properties: {
          ContactProperty.name,
          ContactProperty.phone,
          ContactProperty.photoThumbnail,
        },
      );

      return contacts.where((contact) {
        return contact.phones.isNotEmpty;
      }).toList();
    } catch (e) {
      log("Contact Fetch Error: $e");
      return [];
    }
  }

  Future<List<String>> getMobileNumbers() async {
    try {
      final contacts = await getContacts();

      final Set<String> numbers = {};

      for (final contact in contacts) {
        for (final phone in contact.phones) {
          String mobileNo = phone.number;

          mobileNo = mobileNo.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          );

          if (mobileNo.startsWith('91') &&
              mobileNo.length > 10) {
            mobileNo = mobileNo.substring(2);
          }

          if (mobileNo.length > 10) {
            mobileNo = mobileNo.substring(
              mobileNo.length - 10,
            );
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