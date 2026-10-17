import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/call/Controller/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widget/call_widget.dart';

class ContactController extends GetxController {
  static ContactController get instance => Get.isRegistered<ContactController>()
      ? Get.find<ContactController>()
      : Get.put(ContactController());

  final RxString responseError = "".obs;

  final ContactService _contactService = ContactService();
  final Map<String, String> phoneContactNameMap = {};
  final RxBool contactLoading = false.obs;

  final RxBool isContactPermissionGranted = false.obs;
  final RxBool hasAllowedContacts = false.obs;
  final RxInt contactPagination = 1.obs;
  static const int contactPageLimit = 10;

  final RxBool contactLoadingMore = false.obs;
  final RxBool hasMoreContacts = true.obs;

  final RxString searchQuery = ''.obs;
  var allUserProfileData = <UserListData>[].obs;
  var filteredUsers = <UserListData>[].obs;

  Future<void> checkContactPermission() async {
    try {
      final bool granted =
          await FlutterContacts.requestPermission(readonly: true);
      isContactPermissionGranted.value = granted;
      if (granted) {
        hasAllowedContacts.value = true;
        await getRegisteredContacts();
      }
    } catch (e) {
      debugPrint("Error checking contact permission: $e");
    }
  }

  Future<void> requestContactPermission() async {
    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        isContactPermissionGranted.value = true;
        hasAllowedContacts.value = true;
        await getRegisteredContacts();
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      } else {
        isContactPermissionGranted.value = false;
      }
    } catch (e) {
      debugPrint("Error requesting contact permission: $e");
    }
  }

  Future<void> getRegisteredContacts({bool loadMore = false}) async {
    if (loadMore) {
      if (contactLoading.value ||
          contactLoadingMore.value ||
          !hasMoreContacts.value) {
        return;
      }
      contactLoadingMore.value = true;
    } else {
      if (contactLoading.value) return;
      contactLoading.value = true;
      responseError.value = "";
      contactPagination.value = 1;
      hasMoreContacts.value = true;
      allUserProfileData.clear();
      filteredUsers.clear();
    }

    try {
      if (phoneContactNameMap.isEmpty) {
        final List<Contact> deviceContacts =
            await _contactService.getContacts();
        phoneContactNameMap.clear();
        for (final Contact contact in deviceContacts) {
          final String displayName = contact.displayName.trim();
          if (displayName.isEmpty) continue;
          for (final Phone phone in contact.phones) {
            final String norm = normalizePhone(phone.number);
            if (norm.isNotEmpty) {
              phoneContactNameMap[norm] = displayName;
            }
          }
        }
      }

      isContactPermissionGranted.value = true;

      List<UserListData> pageUsers = <UserListData>[];

      try {
        final GroupMemberModel groupMemberRes = await TrackRepo.getGroupMember(
          page: contactPagination.value.toString(),
          filter: 'all',
          limit: contactPageLimit,
        );

        final List<GroupMemberData> members =
            groupMemberRes.data?.allMember?.memberList ??
                groupMemberRes.data?.allMemberList ??
                [];

        pageUsers = members.map((member) {
          final String phoneNum = member.mobileNo ?? member.phone ?? '';
          final String normMobile = normalizePhone(phoneNum);
          final String? phoneBookName = phoneContactNameMap[normMobile];
          final String resolvedName =
              (phoneBookName != null && phoneBookName.trim().isNotEmpty)
                  ? phoneBookName.trim()
                  : ((member.name != null && member.name!.trim().isNotEmpty)
                      ? member.name!.trim()
                      : 'Unknown');

          return UserListData(
            userId: member.userId,
            profileImage: member.profileImage,
            name: resolvedName,
            mobileNo: phoneNum,
            isOnline: member.online,
          );
        }).toList();
      } catch (e) {
        debugPrint("Error fetching all group members for call contacts: $e");
      }

      if (pageUsers.isEmpty && !loadMore) {
        final result = await GroupRepo.getAllUserData();
        if (result.status == true) {
          pageUsers = (result.userData ?? []).map((user) {
            final String normMobile = normalizePhone(user.mobileNo ?? '');
            final String? phoneBookName = phoneContactNameMap[normMobile];
            final String resolvedName =
                (phoneBookName != null && phoneBookName.trim().isNotEmpty)
                    ? phoneBookName.trim()
                    : ((user.name != null && user.name!.trim().isNotEmpty)
                        ? user.name!.trim()
                        : 'Unknown');

            return UserListData(
              userId: user.userId,
              profileImage: user.profileImage,
              name: resolvedName,
              mobileNo: user.mobileNo,
              isOnline: user.isOnline,
            );
          }).toList();
          hasMoreContacts.value = false;
        } else {
          responseError.value = result.message ?? "Something went wrong";
        }
      }

      if (pageUsers.isEmpty) {
        hasMoreContacts.value = false;
      } else {
        hasMoreContacts.value = pageUsers.length >= contactPageLimit;
        contactPagination.value = contactPagination.value + 1;

        final List<UserListData> merged =
            List<UserListData>.from(allUserProfileData);
        final Set<int?> seen = allUserProfileData.map((e) => e.userId).toSet();

        for (final UserListData user in pageUsers) {
          if (seen.add(user.userId)) {
            merged.add(user);
          }
        }

        merged.sort((a, b) {
          final bool aInPhone =
              phoneContactNameMap.containsKey(normalizePhone(a.mobileNo ?? ''));
          final bool bInPhone =
              phoneContactNameMap.containsKey(normalizePhone(b.mobileNo ?? ''));
          if (aInPhone && !bInPhone) return -1;
          if (!aInPhone && bInPhone) return 1;
          return (a.name ?? '')
              .toLowerCase()
              .compareTo((b.name ?? '').toLowerCase());
        });

        allUserProfileData.value = merged;
      }

      filterUsers(searchQuery.value);
    } catch (e) {
      if (!loadMore) responseError.value = e.toString();
    } finally {
      if (loadMore) {
        contactLoadingMore.value = false;
      } else {
        contactLoading.value = false;
      }
    }
  }

  Future<void> loadMoreContacts() => getRegisteredContacts(loadMore: true);

  Future<void> refreshContacts() async {
    phoneContactNameMap.clear();
    await getRegisteredContacts();
  }

  void filterUsers(String query) {
    final String q = query.trim().toLowerCase();

    if (q.isEmpty) {
      filteredUsers.value = List<UserListData>.from(allUserProfileData);
      return;
    }

    final String digits = q.replaceAll(RegExp(r'[^0-9]'), '');

    filteredUsers.value = allUserProfileData.where((UserListData user) {
      final String name = (user.name ?? '').toLowerCase();
      final String phone =
          (user.mobileNo ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      if (name.contains(q)) return true;
      if (digits.isNotEmpty && phone.contains(digits)) return true;
      return false;
    }).toList();
  }

  void applySearch(String query) {
    if (searchQuery.value == query) return;
    searchQuery.value = query;
    filterUsers(query);
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<CallController>()) {
      ever<String>(CallController.instance.searchQuery, applySearch);
    }
    checkContactPermission();
  }

  @override
  void onClose() {
    responseError.close();
    contactLoading.close();
    isContactPermissionGranted.close();
    hasAllowedContacts.close();
    contactPagination.close();
    contactLoadingMore.close();
    hasMoreContacts.close();
    searchQuery.close();
    allUserProfileData.close();
    filteredUsers.close();
    super.onClose();
  }
}
