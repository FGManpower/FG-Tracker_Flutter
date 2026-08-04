import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

import '../../../Model/ContactMessage.dart';

class ContactPickerController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxList<Contact> contacts = <Contact>[].obs;
  final RxList<Contact> filteredContacts = <Contact>[].obs;

  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadContacts() async {
    try {
      loading.value = true;
      errorMessage.value = null;

      final bool granted =
      await FlutterContacts.requestPermission(readonly: true);

      if (!granted) {
        Get.snackbar(
          "Permission Denied",
          "Contact permission is required to share contacts.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        Get.back();
        return;
      }

      final List<Contact> allContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
      );

      final List<Contact> filtered = allContacts
          .where((contact) => contact.phones.isNotEmpty)
          .toList();

      filtered.sort(
            (a, b) => a.displayName
            .toLowerCase()
            .compareTo(b.displayName.toLowerCase()),
      );

      contacts.assignAll(filtered);
      filteredContacts.assignAll(filtered);
    } catch (e) {
      errorMessage.value = "Failed to load contacts: $e";
    } finally {
      loading.value = false;
    }
  }

  void search(String value) {
    searchQuery.value = value;
    final String query = value.toLowerCase().trim();

    if (query.isEmpty) {
      filteredContacts.assignAll(contacts);
      return;
    }

    final List<Contact> result = contacts.where((contact) {
      final bool nameMatch =
      contact.displayName.toLowerCase().contains(query);

      final bool phoneMatch = contact.phones.any(
            (phone) => phone.number.replaceAll(' ', '').contains(query),
      );

      return nameMatch || phoneMatch;
    }).toList();

    filteredContacts.assignAll(result);
  }

  void clearSearch() {
    searchController.clear();
    search('');
  }

  void selectContact(Contact contact) {
    if (contact.phones.isEmpty) return;

    final String phone = contact.phones.first.number;

    final ContactMessage model = ContactMessage(
      name: contact.displayName,
      phone: phone,
    );

    Get.back(result: model);
  }

  String getInitials(String displayName) {
    if (displayName.trim().isEmpty) return "?";

    final List<String> parts = displayName.trim().split(' ');
    if (parts.length >= 2 &&
        parts.first.isNotEmpty &&
        parts.last.isNotEmpty) {
      return "${parts.first[0]}${parts.last[0]}".toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}