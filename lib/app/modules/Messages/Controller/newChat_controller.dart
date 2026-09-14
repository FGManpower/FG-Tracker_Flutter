import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:get/get.dart';

class NewChatController extends GetxController {
  final ContactService _contactService = ContactService();

  // All users fetched from backend
  var allUsers = <UserListData>[].obs;

  // Contacts who have the app (Start a New Chat)
  var matchedUsers = <UserListData>[].obs;
  var filteredMatchedUsers = <UserListData>[].obs;

  // Other users registered on tracker but not in device phonebook (Invite/Connect)
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

      // 1. Fetch contact numbers from physical device
      final contactNumbers = await _contactService.getMobileNumbers();

      // 2. Fetch all users from backend tracker database
      final result = await GroupRepo.getAllUserData();

      if (result.status == true) {
        final List<UserListData> users = result.userData ?? [];
        final Set<String> contactNumberSet = contactNumbers.map((num) => _normalizePhone(num)).toSet();

        final List<UserListData> matched = [];
        final List<UserListData> unmatched = [];

        // Distribute backend users based on contact list matching
        for (var user in users) {
          final String normalizedUserPhone = _normalizePhone(user.mobileNo ?? '');
          if (contactNumberSet.contains(normalizedUserPhone)) {
            matched.add(user);
          } else {
            unmatched.add(user);
          }
        }

        allUsers.value = users;
        matchedUsers.value = matched;
        otherUsers.value = unmatched;

        // Apply active search filter
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