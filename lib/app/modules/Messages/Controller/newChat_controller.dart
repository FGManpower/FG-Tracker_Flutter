import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class NewChatController extends GetxController {
  final ContactService _contactService = ContactService();

  var allUsers = <UserListData>[].obs;

  var matchedUsers = <UserListData>[].obs;
  var filteredMatchedUsers = <UserListData>[].obs;

  var otherUsers = <UserListData>[].obs;
  var filteredOtherUsers = <UserListData>[].obs;

  final RxString searchQuery = ''.obs;
  final RxBool contactLoading = false.obs;
  final RxString responseError = "".obs;

  @override
  void onInit() {
    super.onInit();
    getRegisteredContacts();
  }

  Future<void> getRegisteredContacts() async {
    try {
      contactLoading.value = true;
      responseError.value = "";

      final List<Contact> deviceContacts = await _contactService.getContacts();

      final result = await GroupRepo.getAllUserData();

      if (result.status == true) {
        final List<UserListData> users = result.userData ?? [];

        final Map<String, UserListData> registeredMap = {};
        for (var user in users) {
          final String norm = _normalizePhone(user.mobileNo ?? '');
          if (norm.isNotEmpty) {
            registeredMap[norm] = user;
          }
        }

        final List<UserListData> matched = [];
        final List<UserListData> unmatched = [];
        final Set<String> processedPhones = {};

        for (var contact in deviceContacts) {
          for (var phone in contact.phones) {
            final String normalized = _normalizePhone(phone.number);

            if (normalized.length == 10 && !processedPhones.contains(normalized)) {
              processedPhones.add(normalized);

              final String contactDisplayName = contact.displayName.trim().isNotEmpty
                  ? contact.displayName.trim()
                  : phone.number;

              if (registeredMap.containsKey(normalized)) {
                final registeredUser = registeredMap[normalized]!;
                matched.add(UserListData(
                  userId: registeredUser.userId,
                  name: contactDisplayName,
                  mobileNo: phone.number,
                  profileImage: registeredUser.profileImage,
                ));
              }
              else {
                unmatched.add(UserListData(
                  userId: null,
                  name: contactDisplayName,
                  mobileNo: phone.number,
                  profileImage: null,
                ));
              }
            }
          }
        }

        allUsers.value = users;
        matchedUsers.value = matched;
        otherUsers.value = unmatched;

        filterContacts(searchQuery.value);
      } else {
        responseError.value = result.message ?? "Something went wrong";
      }
    } catch (e) {
      responseError.value = e.toString();
    } finally {
      contactLoading.value = false;
    }
  }

  void filterContacts(String query) {
    searchQuery.value = query;
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      filteredMatchedUsers.value = matchedUsers;
      filteredOtherUsers.value = otherUsers;
    } else {
      filteredMatchedUsers.value = matchedUsers.where((user) {
        return (user.name ?? '').toLowerCase().contains(q) ||
            (user.mobileNo ?? '').toLowerCase().contains(q);
      }).toList();

      filteredOtherUsers.value = otherUsers.where((user) {
        return (user.name ?? '').toLowerCase().contains(q) ||
            (user.mobileNo ?? '').toLowerCase().contains(q);
      }).toList();
    }
  }

  String _normalizePhone(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('91') && digits.length > 10) {
      digits = digits.substring(2);
    }
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }
    return digits;
  }
}