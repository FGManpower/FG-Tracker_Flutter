import 'dart:async';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/Messages/Controller/newChat_controller.dart';
import 'package:fgtracker/app/modules/call/Controller/call_controller.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart' show normalizePhone;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// Calls → Contacts tab controller.
///
/// Delegates directly to [NewChatController] (the engine of All Contacts)
/// so both screens share the exact same dataset, cache, and state.
class ContactController extends GetxController {
  static ContactController get instance => Get.isRegistered<ContactController>()
      ? Get.find<ContactController>()
      : Get.put(ContactController());

  NewChatController get _nc => Get.isRegistered<NewChatController>()
      ? Get.find<NewChatController>()
      : Get.put(NewChatController(autoLoad: false));

  RxList<UserListData> get allUserProfileData => _nc.matchedUsers;
  RxList<UserListData> get filteredUsers => _nc.filteredMatchedUsers;
  RxList<UserListData> get inviteUsers => _nc.otherUsers;
  RxList<UserListData> get filteredInviteUsers => _nc.filteredOtherUsers;

  RxBool get contactLoading => _nc.contactLoading;
  RxBool get isResolving => _nc.isResolving;
  RxString get responseError => _nc.responseError;

  final RxBool contactLoadingMore = false.obs;

  final RxBool permissionChecked = false.obs;
  final RxBool isContactPermissionGranted = false.obs;
  final RxBool hasAllowedContacts = false.obs;
  final RxBool isFirstLoadDone = false.obs;
  bool _permissionPrompted = false;

  int? chatIdFor(int? userId) {
    if (userId == null) return null;
    final u = _nc.matchedUsers.firstWhereOrNull((u) => u.userId == userId);
    return u?.chatId ?? u?.privateChatId ?? u?.conversationId;
  }

  Map<String, String> get phoneContactNameMap {
    final Map<String, String> map = {};
    for (final u in _nc.matchedUsers) {
      if (u.mobileNo != null && u.name != null) {
        final norm = normalizePhone(u.mobileNo!);
        if (norm.isNotEmpty) map[norm] = u.name!;
      }
    }
    for (final u in _nc.otherUsers) {
      if (u.mobileNo != null && u.name != null) {
        final norm = normalizePhone(u.mobileNo!);
        if (norm.isNotEmpty) map[norm] = u.name!;
      }
    }
    return map;
  }

  Set<String> get savedContactNumbers => phoneContactNameMap.keys.toSet();

  Future<void> getRegisteredContacts({bool forceRefresh = false}) async {
    await _nc.getRegisteredContacts(forceRefresh: forceRefresh);
    if (_nc.matchedUsers.isNotEmpty || _nc.otherUsers.isNotEmpty) {
      isFirstLoadDone.value = true;
    }
  }

  Future<bool> requestContactPermission() async {
    try {
      final bool granted =
          await FlutterContacts.requestPermission(readonly: true);
      isContactPermissionGranted.value = granted;
      permissionChecked.value = true;
      if (granted) {
        hasAllowedContacts.value = true;
        await getRegisteredContacts(forceRefresh: true);
      }
      return granted;
    } catch (_) {
      return false;
    }
  }

  Future<void> checkContactPermission({bool prompt = true}) async {
    bool granted = false;
    try {
      final PermissionStatus status = await Permission.contacts.status;
      granted = status.isGranted || status.isLimited;

      if (!granted && prompt && !_permissionPrompted) {
        _permissionPrompted = true;
        granted = await FlutterContacts.requestPermission(readonly: true);
      }
    } catch (_) {}

    isContactPermissionGranted.value = granted;
    permissionChecked.value = true;

    if (granted) {
      hasAllowedContacts.value = true;
      if (_nc.matchedUsers.isEmpty && _nc.otherUsers.isEmpty) {
        await getRegisteredContacts();
      }
    }
  }

  Future<void> loadMoreContacts() async {}

  Future<void> onTabOpened() async {
    await checkContactPermission(prompt: false);
    if (!isContactPermissionGranted.value) return;

    if (_nc.matchedUsers.isEmpty && _nc.otherUsers.isEmpty) {
      await _nc.getRegisteredContacts();
    }
    if (_nc.matchedUsers.isNotEmpty || _nc.otherUsers.isNotEmpty) {
      isFirstLoadDone.value = true;
    }
  }

  Future<void> onAppResumed() async {
    await checkContactPermission(prompt: false);
    if (isContactPermissionGranted.value) {
      if (_nc.matchedUsers.isEmpty && _nc.otherUsers.isEmpty) {
        await _nc.getRegisteredContacts();
      }
    }
  }

  Future<void> silentRefresh({
    bool force = false,
    bool reloadPhoneBook = false,
  }) =>
      getRegisteredContacts(forceRefresh: force || reloadPhoneBook);

  Future<void> refreshContacts() =>
      getRegisteredContacts(forceRefresh: true);

  void filterUsers(String query) => _nc.filterContacts(query);
  void applySearch(String query) => _nc.filterContacts(query);

  void _onSearchOrDialChanged() {
    if (!Get.isRegistered<CallController>()) return;
    final callCtrl = CallController.instance;
    final String query = (callCtrl.isDialPadOpen.value &&
            callCtrl.dialNumber.value.trim().isNotEmpty)
        ? callCtrl.dialNumber.value.trim()
        : callCtrl.searchQuery.value.trim();

    _nc.filterContacts(query);
  }

  @override
  void onInit() {
    super.onInit();
    if (_nc.matchedUsers.isNotEmpty || _nc.otherUsers.isNotEmpty) {
      isFirstLoadDone.value = true;
    }

    everAll([_nc.matchedUsers, _nc.otherUsers], (_) {
      if (_nc.matchedUsers.isNotEmpty || _nc.otherUsers.isNotEmpty) {
        isFirstLoadDone.value = true;
      }
    });

    if (Get.isRegistered<CallController>()) {
      final callCtrl = CallController.instance;
      ever<String>(callCtrl.searchQuery, (_) => _onSearchOrDialChanged());
      ever<String>(callCtrl.dialNumber, (_) => _onSearchOrDialChanged());
      ever<bool>(callCtrl.isDialPadOpen, (_) => _onSearchOrDialChanged());
      ever<int>(callCtrl.selectedTab, (tabIndex) {
        if (tabIndex == 1) {
          onTabOpened();
        }
      });
    }

    checkContactPermission(prompt: false);
  }

  @override
  void onClose() {
    contactLoadingMore.close();
    permissionChecked.close();
    isContactPermissionGranted.close();
    hasAllowedContacts.close();
    isFirstLoadDone.close();
    super.onClose();
  }
}
