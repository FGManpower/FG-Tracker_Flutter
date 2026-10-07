import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Data/Repositories/call_repo.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import 'package:fgtracker/app/Model/recent_call.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart' hide navigator;
import 'package:permission_handler/permission_handler.dart';

class CallController extends GetxController {
  static CallController get instance => Get.isRegistered<CallController>()
      ? Get.find<CallController>()
      : Get.put(CallController());

  final GroupController _groupController = Get.isRegistered<GroupController>()
      ? Get.find<GroupController>()
      : Get.put(GroupController());

  final ContactService _contactService = ContactService();
  final TextEditingController searchController = TextEditingController();
  final Map<String, String> phoneContactNameMap = {};

  final RxInt selectedTab = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxBool contactLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString responseError = "".obs;
  final RxBool isContactPermissionGranted = false.obs;
  final RxBool hasAllowedContacts = false.obs;

  var allUserProfileData = <UserListData>[].obs;
  var filteredUsers = <UserListData>[].obs;

  final RxBool recentCallLoading = false.obs;
  final RxBool recentCallLoadingMore = false.obs;
  final RxString recentCallResponseError = "".obs;
  final RxInt pagination = 1.obs;
  final RxBool hasMoreRecentCalls = true.obs;
  final RxString recentCallFilter = 'All'.obs;
  final RxList<Map<String, String>> recentCallList =
      <Map<String, String>>[].obs;

  final List<_RecentEntry> _recentRaw = <_RecentEntry>[];

  // Dial pad state
  final RxBool isDialPadOpen = false.obs;
  final RxString dialNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkContactPermission();
    loadGroups();
    getRecentCall();

    // Automatically re-resolve names and avatars when groups or contacts update
    ever(_groupController.groupData, (_) {
      if (_recentRaw.isNotEmpty) {
        _rebuildRecentDisplay();
      }
    });
    ever(allUserProfileData, (_) {
      if (_recentRaw.isNotEmpty) {
        _rebuildRecentDisplay();
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    searchQuery.close();
    selectedTab.close();
    contactLoading.close();
    responseError.close();
    recentCallLoading.close();
    recentCallLoadingMore.close();
    recentCallResponseError.close();
    recentCallFilter.close();
    hasMoreRecentCalls.close();

    isDialPadOpen.close();
    dialNumber.close();
    super.onClose();
  }

  UserListData? selectedDialUser;

  void toggleDialPad() {
    isDialPadOpen.value = !isDialPadOpen.value;
    if (isDialPadOpen.value) {
      FocusManager.instance.primaryFocus?.unfocus();
    } else {
      clearDialNumber();
    }
    filterUsers(_query);
  }

  void selectUserToDial(UserListData user) {
    selectedDialUser = user;
    final String raw = (user.mobileNo ?? '').trim();
    final String digits = _normalizePhone(raw);
    dialNumber.value = digits.isNotEmpty ? digits : raw;
    isDialPadOpen.value = true;
    filterUsers(_query);
  }

  void addDigit(String digit) {
    selectedDialUser = null;
    if (dialNumber.value.length >= 15) return;
    dialNumber.value += digit;
    filterUsers(_query);
  }

  void removeLastDigit() {
    selectedDialUser = null;
    if (dialNumber.value.isEmpty) return;
    dialNumber.value =
        dialNumber.value.substring(0, dialNumber.value.length - 1);
    filterUsers(_query);
  }

  void clearDialNumber() {
    selectedDialUser = null;
    dialNumber.value = '';
    filterUsers(_query);
  }

  void makeCall({bool isVideo = false}) {
    final String input = dialNumber.value.trim();
    if (input.isEmpty) {
      Utils().fluttertoast("Please enter a phone number");
      return;
    }

    final String inputDigits = _normalizePhone(input);
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString();

    if (currentUserId == null || currentUserId.isEmpty) {
      Utils().fluttertoast("Please login to make a call");
      return;
    }

    // 1. Try selectedDialUser if available AND matches current input
    UserListData? targetUser;
    if (selectedDialUser != null) {
      final String selDigits = _normalizePhone(selectedDialUser?.mobileNo ?? '');
      if (selDigits.isNotEmpty && (selDigits == inputDigits || selDigits.endsWith(inputDigits))) {
        targetUser = selectedDialUser;
      } else {
        selectedDialUser = null;
      }
    }

    // 2. Try finding exact or ending mobile number match in allUserProfileData
    if (targetUser == null && inputDigits.isNotEmpty) {
      targetUser = allUserProfileData.firstWhereOrNull(
        (u) => _normalizePhone(u.mobileNo ?? '') == inputDigits ||
            (inputDigits.length >= 10 && _normalizePhone(u.mobileNo ?? '').endsWith(inputDigits)),
      );
    }

    // 3. Try finding match from recent calls by phone number or callerId
    String? remoteUserId;
    String targetName = "User";

    if (targetUser != null && targetUser.userId != null) {
      remoteUserId = targetUser.userId.toString();
      targetName = targetUser.name ?? "User";
    } else {
      // Check resolved recentCallList
      final recentRowMatch = recentCallList.firstWhereOrNull((r) {
        final phone = _normalizePhone(r['mobileNo'] ?? r['phone'] ?? '');
        final cId = (r['callerId'] ?? '').trim();
        return (phone.isNotEmpty &&
                (phone == inputDigits ||
                    (inputDigits.length >= 10 && phone.endsWith(inputDigits)))) ||
            cId == input ||
            cId == inputDigits;
      });

      if (recentRowMatch != null) {
        final rId = (recentRowMatch['callerId'] ?? '').trim();
        if (rId.isNotEmpty && rId != currentUserId) {
          remoteUserId = rId;
          targetName =
              recentRowMatch['name'] ?? _formatPhoneForDisplay(input);
        }
      }

      // Also check raw recent call records
      if (remoteUserId == null) {
        final recentMatch = _recentRaw.firstWhereOrNull((r) {
          final phone = _normalizePhone(r.call.contact?.phoneNumber ?? '');
          final cId = (r.call.contact?.id ??
                  r.call.callerId ??
                  r.call.receiverId ??
                  '')
              .trim();
          return (phone.isNotEmpty &&
                  (phone == inputDigits ||
                      (inputDigits.length >= 10 && phone.endsWith(inputDigits)))) ||
              cId == input ||
              cId == inputDigits;
        });

        if (recentMatch != null) {
          final call = recentMatch.call;
          final contact = call.contact;
          String rId = (contact?.id ?? '').trim();
          if (rId.isEmpty || rId == currentUserId) {
            if ((call.callerId ?? '').isNotEmpty &&
                call.callerId != currentUserId) {
              rId = call.callerId!.trim();
            } else if ((call.receiverId ?? '').isNotEmpty &&
                call.receiverId != currentUserId) {
              rId = call.receiverId!.trim();
            }
          }
          if (rId.isNotEmpty) {
            remoteUserId = rId;
            targetName = [contact?.firstName, contact?.lastName]
                .whereType<String>()
                .join(' ')
                .trim();
            if (targetName.isEmpty || targetName.toLowerCase() == 'unknown') {
              targetName = call.callerName ?? _formatPhoneForDisplay(input);
            }
          }
        }
      }

      // 4. If not found in recents, try matching by userId directly from registered users
      if (remoteUserId == null) {
        final userById = allUserProfileData.firstWhereOrNull(
          (u) => u.userId?.toString() == input,
        );
        if (userById != null && userById.userId != null) {
          remoteUserId = userById.userId.toString();
          targetName = userById.name ?? "User";
        }
      }
    }

    if (remoteUserId != null && remoteUserId.isNotEmpty) {
      if (currentUserId == remoteUserId) {
        Utils().fluttertoast("Cannot call yourself");
        return;
      }

      isDialPadOpen.value = false;
      selectedDialUser = null;

      final ctx = Get.context;
      if (ctx != null) {
        CallService().startCall(
          ctx,
          callerId: currentUserId,
          remoteUserId: remoteUserId,
          is_video: isVideo,
          callerName: targetName,
        );
      }
    } else {
      selectedDialUser = null;
      Utils().fluttertoast("No contact found");
    }
  }

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

  Future<void> getRegisteredContacts() async {
    try {
      contactLoading.value = true;
      responseError.value = "";

      final startTime = DateTime.now();

      final List<Contact> deviceContacts = await _contactService.getContacts();
      phoneContactNameMap.clear();
      for (final Contact contact in deviceContacts) {
        final String displayName = contact.displayName.trim();
        if (displayName.isEmpty) continue;
        for (final Phone phone in contact.phones) {
          final String norm = _normalizePhone(phone.number);
          if (norm.isNotEmpty) {
            phoneContactNameMap[norm] = displayName;
          }
        }
      }

      debugPrint(
        "⏱️ Device Contacts: "
        "${DateTime.now().difference(startTime).inMilliseconds} ms (Total ${phoneContactNameMap.length} mapped)",
      );

      isContactPermissionGranted.value = true;

      final apiStartTime = DateTime.now();

      List<UserListData> processedUsers = [];

      try {
        final GroupMemberModel groupMemberRes = await TrackRepo.getGroupMember(
          page: '1',
          filter: 'all',
          limit: 10,
        );

        final List<GroupMemberData> members =
            groupMemberRes.data?.allMember?.memberList ??
                groupMemberRes.data?.allMemberList ??
                [];

        if (members.isNotEmpty) {
          processedUsers = members.map((member) {
            final String phoneNum = member.mobileNo ?? member.phone ?? '';
            final String normMobile = _normalizePhone(phoneNum);
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
        }
      } catch (e) {
        debugPrint("Error fetching all group members for call contacts: $e");
      }

      // If all-members API returned empty or failed, fallback to getAllUserData
      if (processedUsers.isEmpty) {
        final result = await GroupRepo.getAllUserData();
        if (result.status == true) {
          final users = result.userData ?? [];
          processedUsers = users.map((user) {
            final String normMobile = _normalizePhone(user.mobileNo ?? '');
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
        } else {
          responseError.value = result.message ?? "Something went wrong";
        }
      }

      debugPrint(
        "⏱️ Contacts Members API: "
        "${DateTime.now().difference(apiStartTime).inMilliseconds} ms (Total ${processedUsers.length} members)",
      );

      if (processedUsers.isNotEmpty) {
        // Sort so that contacts matched in phonebook appear first, but ALL company contacts are preserved
        processedUsers.sort((a, b) {
          final aInPhone = phoneContactNameMap.containsKey(_normalizePhone(a.mobileNo ?? ''));
          final bInPhone = phoneContactNameMap.containsKey(_normalizePhone(b.mobileNo ?? ''));
          if (aInPhone && !bInPhone) return -1;
          if (!aInPhone && bInPhone) return 1;
          return (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase());
        });

        allUserProfileData.value = processedUsers;
        filterUsers(searchQuery.value);
      }
    } catch (e) {
      responseError.value = e.toString();
    } finally {
      contactLoading.value = false;
    }
  }

  static const Map<String, String> _t9LetterToDigit = {
    'a': '2', 'b': '2', 'c': '2',
    'd': '3', 'e': '3', 'f': '3',
    'g': '4', 'h': '4', 'i': '4',
    'j': '5', 'k': '5', 'l': '5',
    'm': '6', 'n': '6', 'o': '6',
    'p': '7', 'q': '7', 'r': '7', 's': '7',
    't': '8', 'u': '8', 'v': '8',
    'w': '9', 'x': '9', 'y': '9', 'z': '9',
  };

  String _nameToT9(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final char = text[i].toLowerCase();
      buffer.write(_t9LetterToDigit[char] ?? '');
    }
    return buffer.toString();
  }

  bool _matchesT9(String name, String queryDigits) {
    if (queryDigits.isEmpty) return false;
    final nameLower = name.toLowerCase();
    final fullT9 = _nameToT9(nameLower);
    if (fullT9.contains(queryDigits)) return true;

    // Check each word in name (e.g. John Doe)
    final words = nameLower.split(RegExp(r'\s+'));
    for (final word in words) {
      if (_nameToT9(word).startsWith(queryDigits)) return true;
    }
    return false;
  }

  void filterUsers(String value) {
    final trimmed = value.trim().toLowerCase();

    if (trimmed.isEmpty) {
      filteredUsers.value = allUserProfileData;
      return;
    }

    final String queryDigits = _normalizePhone(trimmed);

    filteredUsers.value = allUserProfileData.where((user) {
      final String name = (user.name ?? '').toLowerCase();
      final String mobile = (user.mobileNo ?? '').toLowerCase();
      final bool nameTextMatch = name.contains(trimmed);
      final bool mobileMatch = mobile.contains(trimmed) ||
          (queryDigits.isNotEmpty && _normalizePhone(user.mobileNo ?? '').contains(queryDigits));
      final bool t9Match = queryDigits.isNotEmpty && _matchesT9(name, queryDigits);

      return nameTextMatch || mobileMatch || t9Match;
    }).toList();
  }

  String _formatPhoneForDisplay(String raw) {
    if (raw.trim().isEmpty) return 'Unknown';
    final clean = raw.trim();
    final digits = clean.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) {
      return "+91 ${digits.substring(0, 5)} ${digits.substring(5)}";
    } else if (digits.length == 12 && digits.startsWith('91')) {
      final sub = digits.substring(2);
      return "+91 ${sub.substring(0, 5)} ${sub.substring(5)}";
    }
    if (!clean.startsWith('+') && digits.length >= 10) {
      return "+$clean";
    }
    return clean;
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

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filteredUsers.value = allUserProfileData;
  }

  Future<void> refreshContacts() async {
    await checkContactPermission();
  }

  // =========================================================================
  // STATIC MOCKUP DATA (COMMENTED OUT AS REQUESTED)
  // Dynamic API integration is active below in getRecentCall()
  // =========================================================================
  /*
  final List<Map<String, String>> _staticMockRecentCalls = [
    // --- TODAY ---
    {
      'name': 'Vikram Singh',
      'type': 'Outgoing Video Call',
      'time': 'Today, 10:24 AM',
      'avatar': '',
      'callType': 'video',
      'callerId': '101',
      'mobileNo': '9876543210',
      'section': 'today',
      'isOnline': 'false',
    },
    {
      'name': 'Anjali Gupta',
      'type': 'Missed Audio Call',
      'time': 'Today, 09:58 AM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '102',
      'mobileNo': '9876543211',
      'section': 'today',
      'isOnline': 'true',
    },
    {
      'name': 'Karan Malhotra',
      'type': 'Outgoing Audio Call',
      'time': 'Today, 08:32 AM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '103',
      'mobileNo': '9876543212',
      'section': 'today',
      'isOnline': 'false',
    },
    {
      'name': 'Neha Yadav',
      'type': 'Outgoing Video Call',
      'time': 'Today, 07:45 AM',
      'avatar': '',
      'callType': 'video',
      'callerId': '104',
      'mobileNo': '9876543213',
      'section': 'today',
      'isOnline': 'true',
    },
    {
      'name': 'Sandeep Yadav',
      'type': 'Incoming Audio Call',
      'time': 'Today, 06:12 AM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '105',
      'mobileNo': '9876543214',
      'section': 'today',
      'isOnline': 'false',
    },
    {
      'name': 'Manoj Kumar',
      'type': 'Missed Video Call',
      'time': 'Today, 04:36 AM',
      'avatar': '',
      'callType': 'video',
      'callerId': '106',
      'mobileNo': '9876543215',
      'section': 'today',
      'isOnline': 'false',
    },
    {
      'name': 'Pooja Verma',
      'type': 'Outgoing Audio Call',
      'time': 'Today, 02:17 AM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '107',
      'mobileNo': '9876543216',
      'section': 'today',
      'isOnline': 'true',
    },
    {
      'name': 'Amit Singh',
      'type': 'Outgoing Video Call',
      'time': 'Today, 01:03 AM',
      'avatar': '',
      'callType': 'video',
      'callerId': '108',
      'mobileNo': '9876543217',
      'section': 'today',
      'isOnline': 'false',
    },
    // --- YESTERDAY ---
    {
      'name': 'Rakesh Patel',
      'type': 'Outgoing Audio Call',
      'time': 'Yesterday, 11:20 PM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '109',
      'mobileNo': '9876543218',
      'section': 'yesterday',
      'isOnline': 'true',
    },
    {
      'name': 'Deepak Sharma',
      'type': 'Outgoing Video Call',
      'time': 'Yesterday, 09:15 PM',
      'avatar': '',
      'callType': 'video',
      'callerId': '110',
      'mobileNo': '9876543219',
      'section': 'yesterday',
      'isOnline': 'true',
    },
    {
      'name': 'Sahil Mehta',
      'type': 'Missed Audio Call',
      'time': 'Yesterday, 07:40 PM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '111',
      'mobileNo': '9876543220',
      'section': 'yesterday',
      'isOnline': 'false',
    },
    {
      'name': 'Sheetal Gupta',
      'type': 'Outgoing Audio Call',
      'time': 'Yesterday, 05:30 PM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '112',
      'mobileNo': '9876543221',
      'section': 'yesterday',
      'isOnline': 'true',
    },
    {
      'name': 'Rahul Verma',
      'type': 'Incoming Video Call',
      'time': 'Yesterday, 03:12 PM',
      'avatar': '',
      'callType': 'video',
      'callerId': '113',
      'mobileNo': '9876543222',
      'section': 'yesterday',
      'isOnline': 'true',
    },
    {
      'name': 'Priya Sharma',
      'type': 'Outgoing Audio Call',
      'time': 'Yesterday, 12:45 PM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '114',
      'mobileNo': '9876543223',
      'section': 'yesterday',
      'isOnline': 'true',
    },
  ];
  */

  Future<void> getRecentCall() async {
    if (recentCallLoading.value || recentCallLoadingMore.value) return;

    recentCallLoading.value = true;
    recentCallResponseError.value = "";

    final stopwatch = Stopwatch()..start();

    try {
      final result = await CallRepo.getRecentCall(
        page: pagination.value.toString(),
      );

      debugPrint(
        "⏱️ Recent Calls API Time: ${stopwatch.elapsedMilliseconds} ms",
      );

      if (result.status == true) {
        final data = result.data;

        if (data != null) {
          if (data.allSections.isNotEmpty) {
            data.allSections.forEach((sec, list) {
              _addBucket(sec, list);
            });
          } else {
            _addBucket('today', data.today);
            _addBucket('yesterday', data.yesterday);
            _addBucket('older', data.older);
          }

          _rebuildRecentDisplay();

          final meta = result.pagination;

          if (meta != null) {
            hasMoreRecentCalls.value = meta.hasNextPage ??
                (meta.totalRecords != null &&
                    recentCallList.length < meta.totalRecords!);
          }
        } else {
          hasMoreRecentCalls.value = false;
        }
      } else {
        recentCallResponseError.value =
            result.message ?? "Something went wrong";
      }
    } catch (e) {
      recentCallResponseError.value = e.toString();
    } finally {
      stopwatch.stop();
      recentCallLoading.value = false;
    }
  }

  Future<void> loadMoreRecentCalls() async {
    if (recentCallLoading.value ||
        recentCallLoadingMore.value ||
        !hasMoreRecentCalls.value) {
      return;
    }
    recentCallLoadingMore.value = true;
    try {
      final int nextPage = pagination.value + 1;
      final result = await CallRepo.getRecentCall(
        page: nextPage.toString(),
      );
      if (result.status == true) {
        final int before = _recentRaw.length;
        final data = result.data;
        if (data != null) {
          if (data.allSections.isNotEmpty) {
            data.allSections.forEach((sec, list) {
              _addBucket(sec, list);
            });
          } else {
            _addBucket('today', data.today);
            _addBucket('yesterday', data.yesterday);
            _addBucket('older', data.older);
          }
        }
        if (_recentRaw.length == before) {
          hasMoreRecentCalls.value = false;
        } else {
          pagination.value = nextPage;
          _rebuildRecentDisplay();
          final meta = result.pagination;
          if (meta != null) {
            hasMoreRecentCalls.value = meta.hasNextPage ??
                (meta.totalRecords != null &&
                    recentCallList.length < meta.totalRecords!);
          }
        }
      } else {
        hasMoreRecentCalls.value = false;
      }
    } catch (_) {
    } finally {
      recentCallLoadingMore.value = false;
    }
  }

  Future<void> refreshRecentCalls() async {
    _recentRaw.clear();
    recentCallList.clear();
    pagination.value = 1;
    hasMoreRecentCalls.value = true;
    recentCallLoading.value = false;
    recentCallLoadingMore.value = false;
    await getRecentCall();
  }

  void _addBucket(String section, List<CallingDetail>? items) {
    if (items == null) return;
    for (final CallingDetail call in items) {
      _recentRaw.add(_RecentEntry(section, call));
    }
  }

  void _rebuildRecentDisplay() {
    recentCallList.value = _recentRaw.map(_buildRow).toList();
  }

  Map<String, String> _buildRow(_RecentEntry entry) {
    final CallingDetail call = entry.call;
    final RecentContact? contact = call.contact;

    String name = [
      contact?.firstName,
      contact?.lastName,
    ].whereType<String>().join(' ').trim();

    String mobileNo = (contact?.phoneNumber ?? '').trim();
    String avatar = (contact?.avatar ?? '').trim();
    
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';

    // Determine the remote user ID (ensure we don't pick current user's ID)
    String callerId = (contact?.id ?? '').trim();
    if (callerId.isEmpty || callerId == currentUserId) {
      if ((call.callerId ?? '').isNotEmpty && call.callerId != currentUserId) {
        callerId = call.callerId!.trim();
      } else if ((call.receiverId ?? '').isNotEmpty && call.receiverId != currentUserId) {
        callerId = call.receiverId!.trim();
      } else {
        callerId = (call.callerId ?? call.receiverId ?? '').trim();
      }
    }

    final String targetGroupId =
        (call.groupId ?? contact?.groupId ?? '').trim();

    GroupsResData? matchedGroup;
    if (targetGroupId.isNotEmpty) {
      final int? gId = int.tryParse(targetGroupId);
      matchedGroup = _groupController.groupData.firstWhereOrNull(
        (g) =>
            (g.id != null && g.id == gId) || g.id?.toString() == targetGroupId,
      );
    }

    if (matchedGroup == null && callerId.isNotEmpty) {
      final int? cId = int.tryParse(callerId);
      matchedGroup = _groupController.groupData.firstWhereOrNull(
        (g) => (g.id != null && g.id == cId) || g.id?.toString() == callerId,
      );
    }

    final bool isGroupCall = call.isGroup == true ||
        contact?.isGroup == true ||
        matchedGroup != null ||
        (targetGroupId.isNotEmpty && targetGroupId != "0") ||
        (call.groupName != null && call.groupName!.trim().isNotEmpty) ||
        (contact?.groupName != null && contact!.groupName!.trim().isNotEmpty) ||
        (call.type ?? '').toLowerCase().contains('group');

    String resolvedGroupId = '';
    String memberCount = '0';

    if (isGroupCall) {
      resolvedGroupId = matchedGroup?.id?.toString() ??
          (targetGroupId.isNotEmpty ? targetGroupId : callerId);

      final String groupNameFound = (matchedGroup?.groupName ??
              call.groupName ??
              contact?.groupName ??
              '')
          .trim();

      if (groupNameFound.isNotEmpty) {
        name = groupNameFound;
      } else if (name.isEmpty || name.toLowerCase() == 'unknown') {
        name = resolvedGroupId.isNotEmpty
            ? 'Group $resolvedGroupId'
            : 'Group Call';
      }

      final String groupImg =
          (matchedGroup?.groupProfile ?? call.groupProfile ?? '').trim();
      if (groupImg.isNotEmpty) {
        avatar = groupImg;
      }

      memberCount = matchedGroup?.memberCount?.toString() ??
          call.memberCount?.toString() ??
          '0';
    } else {
      // Direct 1-on-1 contact matching
      UserListData? matchedUser;
      if (callerId.isNotEmpty) {
        final int? contactUserId = int.tryParse(callerId);
        if (contactUserId != null) {
          matchedUser = allUserProfileData.firstWhereOrNull(
            (user) => user.userId == contactUserId,
          );
        }
      }

      if (matchedUser == null && mobileNo.isNotEmpty) {
        final String normMobile = _normalizePhone(mobileNo);
        if (normMobile.isNotEmpty) {
          matchedUser = allUserProfileData.firstWhereOrNull(
            (user) => _normalizePhone(user.mobileNo ?? '') == normMobile,
          );
        }
      }

      if (matchedUser != null) {
        if (mobileNo.isEmpty) {
          mobileNo = (matchedUser.mobileNo ?? '').trim();
        }

        if ((name.isEmpty || name.toLowerCase() == 'unknown') &&
            (matchedUser.name ?? '').isNotEmpty) {
          name = matchedUser.name!.trim();
        }

        if (avatar.isEmpty && (matchedUser.profileImage ?? '').isNotEmpty) {
          avatar = matchedUser.profileImage!.trim();
        }
      }

      final String normMobile = _normalizePhone(mobileNo);
      if (phoneContactNameMap.containsKey(normMobile) &&
          (phoneContactNameMap[normMobile] ?? '').trim().isNotEmpty) {
        name = phoneContactNameMap[normMobile]!.trim();
      }

      // Check caller name from API
      if ((name.isEmpty || name.toLowerCase() == 'unknown') &&
          (call.callerName ?? '').trim().isNotEmpty &&
          call.callerId != currentUserId) {
        name = call.callerName!.trim();
      }

      // If still empty or Unknown, format phone number or User ID for display
      if (name.isEmpty || name.toLowerCase() == 'unknown') {
        if (mobileNo.isNotEmpty) {
          name = _formatPhoneForDisplay(mobileNo);
        } else if (callerId.isNotEmpty) {
          name = 'User $callerId';
        } else {
          name = 'Unknown';
        }
      }
    }

    return {
      'name': name.isEmpty ? 'Unknown' : name,
      'phone': mobileNo.isNotEmpty ? mobileNo : callerId,
      'type': _composeTypeLabel(call, isGroup: isGroupCall),
      'time': _composeTimeLabel(entry),
      'avatar': avatar,
      'callType': (call.type ?? '').trim(),
      'callerId': callerId,
      'mobileNo': mobileNo,
      'section': (call.section ?? entry.section).trim(),
      'isGroup': isGroupCall ? 'true' : 'false',
      'groupId': resolvedGroupId,
      'memberCount': memberCount,
      'apiTime': (call.time ?? '').trim(),
      'apiDate': (call.date ?? '').trim(),
      'apiDay': (call.day ?? '').trim(),
      'apiWeek': (call.week ?? '').trim(),
      'displayTime': (call.displayTime ?? '').trim(),
      'calledAt': (call.calledAt ?? '').trim(),
      'duration': (call.duration ?? '').trim(),
    };
  }

  String _composeTypeLabel(CallingDetail call, {bool isGroup = false}) {
    final String type = (call.type ?? '').trim().toLowerCase();
    final String direction = (call.direction ?? '').trim().toLowerCase();
    final String status = (call.status ?? '').trim().toLowerCase();

    String kind;
    if (type.contains('video')) {
      kind = 'Video';
    } else if (type.contains('audio')) {
      kind = 'Audio';
    } else {
      kind = type.isEmpty ? 'Call' : _capitalize(type);
    }

    final bool showGroupTag = isGroup && !kind.toLowerCase().contains('group');
    final String groupTag = showGroupTag ? 'Group ' : '';

    if (status.contains('missed')) return 'Missed $groupTag$kind Call';
    if (status.contains('cancel') ||
        status.contains('reject') ||
        status.contains('declin')) {
      return 'Rejected $kind Call';

    }
    if (direction.contains('in')) return 'Incoming $groupTag$kind Call';
    if (direction.contains('out')) return 'Outgoing $groupTag$kind Call';
    return '$groupTag$kind Call';
  }

  String _composeTimeLabel(_RecentEntry entry) {
    final CallingDetail call = entry.call;

    // 1. If API provides display_time directly, use it
    if ((call.displayTime ?? '').trim().isNotEmpty) {
      String dt = call.displayTime!.trim();
      final bool isToday = entry.section.toLowerCase() == 'today' ||
          (call.date ?? '').toLowerCase().contains('today') ||
          (call.day ?? '').toLowerCase().contains('today');
      if (isToday) {
        dt = dt
            .replaceAll(RegExp(r'^today,?\s*', caseSensitive: false), '')
            .trim();
      }
      final bool isYesterday = entry.section.toLowerCase() == 'yesterday' ||
          (call.date ?? '').toLowerCase().contains('yesterday') ||
          (call.day ?? '').toLowerCase().contains('yesterday');
      if (isYesterday) {
        dt = dt
            .replaceAll(RegExp(r'^yesterday,?\s*', caseSensitive: false), '')
            .trim();
      }
      return dt;
    }

    // 2. Direct values from API
    final String apiTime = (call.time ?? '').trim();
    final String apiDate = (call.date ?? '').trim();
    final String apiDay = (call.day ?? '').trim();
    final String apiWeek = (call.week ?? '').trim();
    final String sec = (call.section ?? entry.section).trim().toLowerCase();

    // Clean any leading "Today, " or "Yesterday, " prefix from time
    String cleanTime = apiTime
        .replaceAll(
            RegExp(r'^(today|yesterday),?\s*', caseSensitive: false), '')
        .trim();

    // Fallback if time is completely empty in API
    if (cleanTime.isEmpty && (call.calledAt ?? '').isNotEmpty) {
      final DateTime? dt = DateTime.tryParse(call.calledAt!);
      if (dt != null) {
        final int hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final String minute = dt.minute.toString().padLeft(2, '0');
        final String period = dt.hour >= 12 ? 'PM' : 'AM';
        cleanTime = '$hour:$minute $period';
      }
    }

    final bool isToday = sec == 'today' ||
        apiDate.toLowerCase().contains('today') ||
        apiDay.toLowerCase().contains('today');

    // For Today: Only show API time (e.g. "5:05 AM")
    if (isToday) {
      return cleanTime.isNotEmpty ? cleanTime : apiTime;
    }

    final bool isYesterday = sec == 'yesterday' ||
        apiDate.toLowerCase().contains('yesterday') ||
        apiDay.toLowerCase().contains('yesterday');

    // For Yesterday: Only show API time (e.g. "3:34 PM")
    if (isYesterday) {
      cleanTime = cleanTime
          .replaceAll(RegExp(r'^yesterday,?\s*', caseSensitive: false), '')
          .trim();
      if (cleanTime.isNotEmpty) {
        return cleanTime;
      }
      final String timeWithoutYesterday = apiTime
          .replaceAll(RegExp(r'^yesterday,?\s*', caseSensitive: false), '')
          .trim();
      return timeWithoutYesterday.isNotEmpty
          ? timeWithoutYesterday
          : 'Yesterday';
    }

    // Weekday name from API (e.g. "Monday, 5:05 AM")
    if (apiDay.isNotEmpty &&
        apiDay.toLowerCase() != 'today' &&
        apiDay.toLowerCase() != 'yesterday') {
      final String dayTitle = _capitalize(apiDay);
      return cleanTime.isNotEmpty ? '$dayTitle, $cleanTime' : dayTitle;
    }

    // Date from API (e.g. "15 Sep, 5:19 PM")
    if (apiDate.isNotEmpty) {
      final String formattedDate = _formatDate(apiDate);
      return cleanTime.isNotEmpty
          ? '$formattedDate, $cleanTime'
          : formattedDate;
    }

    // Week from API (e.g. "This Week")
    if (apiWeek.isNotEmpty) {
      return cleanTime.isNotEmpty ? '$apiWeek, $cleanTime' : apiWeek;
    }

    if ((call.calledAt ?? '').isNotEmpty) {
      final String formattedDate = _formatDate(call.calledAt!);
      return cleanTime.isNotEmpty
          ? '$formattedDate, $cleanTime'
          : formattedDate;
    }

    return cleanTime.isNotEmpty ? cleanTime : apiTime;
  }

  String _formatDate(String raw) {
    final DateTime? dt = DateTime.tryParse(raw);
    if (dt != null) {
      const List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]}';
    }
    return raw;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  void setRecentCallFilter(String value) {
    if (recentCallFilter.value == value) return;
    recentCallFilter.value = value;
  }

  List<Map<String, String>> get filteredRecentCalls {
    final String query = _query;
    final String filter = recentCallFilter.value;
    final String queryDigits = _normalizePhone(query);

    return recentCallList.where((call) {
      final String name = (call['name'] ?? '').toLowerCase().trim();
      final String type = (call['type'] ?? '').toLowerCase();
      final String callerId = (call['callerId'] ?? '').trim();
      final String mobileNo = (call['mobileNo'] ?? '').trim();
      final String groupId = (call['groupId'] ?? '').trim();
      final String day = (call['apiDay'] ?? '').toLowerCase().trim();
      final String date = (call['apiDate'] ?? '').toLowerCase().trim();
      final String week = (call['apiWeek'] ?? '').toLowerCase().trim();
      final String phone = (call['phone'] ?? '').trim();

      final String normalizedCallerId = _normalizePhone(callerId);
      final String normalizedMobileNo = _normalizePhone(mobileNo);
      final String normalizedPhone = _normalizePhone(phone);

      final bool nameMatch = query.isNotEmpty && name.contains(query);

      final bool callerIdMatch = (query.isNotEmpty && callerId.contains(query)) ||
          (queryDigits.isNotEmpty && normalizedCallerId.contains(queryDigits));

      final bool mobileMatch = (query.isNotEmpty && (mobileNo.contains(query) || phone.contains(query))) ||
          (queryDigits.isNotEmpty &&
              (normalizedMobileNo.contains(queryDigits) ||
                  normalizedPhone.contains(queryDigits)));

      final bool t9Match =
          queryDigits.isNotEmpty && _matchesT9(name, queryDigits);

      final bool groupMatch =
          query.isNotEmpty && (groupId.contains(query) || name.contains(query));

      final bool apiDateMatch = query.isNotEmpty &&
          (day.contains(query) || date.contains(query) || week.contains(query));

      final bool matchQuery = query.isEmpty ||
          nameMatch ||
          callerIdMatch ||
          mobileMatch ||
          t9Match ||
          groupMatch ||
          apiDateMatch ||
          type.contains(query);

      bool matchFilter = filter == 'All';

      if (filter == 'Missed') {
        matchFilter = type.contains('missed');
      } else if (filter == 'Outgoing') {
        matchFilter = type.contains('outgoing');
      } else if (filter == 'Incoming') {
        matchFilter = type.contains('incoming');
      }

      return matchQuery && matchFilter;
    }).toList();
  }

  Map<String, List<Map<String, String>>> get groupedRecentCalls {
    final Map<String, List<Map<String, String>>> groups = {};

    for (final call in filteredRecentCalls) {
      final String rawSec = (call['section'] ?? '').trim();
      final String secTitle = _formatSectionTitle(rawSec);

      groups.putIfAbsent(secTitle, () => <Map<String, String>>[]).add(call);
    }

    return groups;
  }

  String _formatSectionTitle(String raw) {
    if (raw.isEmpty) return 'Recent';
    final lower = raw.toLowerCase().replaceAll(RegExp(r'[_-]'), ' ').trim();
    if (lower == 'today') return 'Today';
    if (lower == 'yesterday') return 'Yesterday';
    if (lower == 'this week' || lower == 'thisweek' || lower == 'week') {
      return 'This Week';
    }
    if (lower == 'last week' || lower == 'lastweek') return 'Last Week';
    if (lower == 'older') return 'Older';

    // Capitalize words
    return lower.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  List<GroupsResData> get filteredGroups {
    final String query = _query;
    if (query.isEmpty) return _groupController.groupData;
    return _groupController.groupData.where((group) {
      final String name = (group.groupName ?? '').toLowerCase();
      final String code = (group.groupCode ?? '').toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();
  }

  bool get isGroupsLoading => _groupController.groupDataLoading.value;
  String get groupsError => _groupController.responseError.value;
  List<GroupsResData> get groups => _groupController.groupData;

  String get _query {
    if (isDialPadOpen.value && dialNumber.value.trim().isNotEmpty) {
      return dialNumber.value.trim().toLowerCase();
    }
    return searchQuery.value.trim().toLowerCase();
  }

  void switchTab(int index) {
    if (selectedTab.value != index) {
      selectedTab.value = index;
    }
    if (isDialPadOpen.value) {
      isDialPadOpen.value = false;
    }
    clearDialNumber();
    clearSearch();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    filterUsers(value);
  }

  void loadGroups() => _groupController.getGroupData();
}

class _RecentEntry {
  _RecentEntry(this.section, this.call);

  final String section;
  final CallingDetail call;
}
