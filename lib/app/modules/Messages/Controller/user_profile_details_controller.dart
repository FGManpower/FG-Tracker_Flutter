import 'package:get/get.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';
import '../../../Model/profile_details_model.dart';

class UserProfileDetailsController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<ProfileDetailsData?> profileData = Rx<ProfileDetailsData?>(null);

  final RxBool isBlocked = false.obs;
  final RxBool isBlocking = false.obs;
  final RxBool isUnblocking = false.obs;

  /// [silent] = refresh without the skeleton loader and keep the current
  /// data on failure (used after "Clear chat").
  Future<void> fetchProfileDetails(int chatId, {bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;

      final response = await MessageRepo.getProfileDetails(chatId: chatId);

      if (response.status == true) {
        profileData.value = response.data;
        final bs = response.data?.blockStatus;
        if (bs != null) {
          isBlocked.value = bs.isBlocked == true || bs.blockedByMe == true;
        }
      } else if (!silent) {
        profileData.value = null;
      }
    } catch (e) {
      if (!silent) profileData.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Direct API block user call (used when MessageController is not registered, e.g. from Group Chat)
  Future<String?> blockUser(int blockedUserId) async {
    if (isBlocking.value) return null;
    isBlocking.value = true;

    try {
      final response = await MessageRepo.blockUser(
        blockedUserId: blockedUserId,
      );

      if (response is Map && response["status"] == true) {
        isBlocked.value = true;
        final current = profileData.value;
        if (current != null) {
          current.blockStatus = BlockStatus(
            isBlocked: true,
            blockedByMe: true,
            canMessage: false,
          );
          profileData.refresh();
        }
        return response["message"]?.toString() ?? "User blocked successfully";
      }

      return response is Map ? response["message"]?.toString() : null;
    } catch (e) {
      return null;
    } finally {
      isBlocking.value = false;
    }
  }

  /// Direct API unblock user call (used when MessageController is not registered, e.g. from Group Chat)
  Future<String?> unblockUser(int blockedUserId) async {
    if (isUnblocking.value) return null;
    isUnblocking.value = true;

    try {
      final response = await MessageRepo.unblockUser(
        blockedUserId: blockedUserId,
      );

      if (response is Map && response["status"] == true) {
        isBlocked.value = false;
        final current = profileData.value;
        if (current != null) {
          current.blockStatus = BlockStatus(
            isBlocked: false,
            blockedByMe: false,
            canMessage: true,
          );
          profileData.refresh();
        }
        return response["message"]?.toString() ?? "User unblocked successfully";
      }

      return response is Map ? response["message"]?.toString() : null;
    } catch (e) {
      return null;
    } finally {
      isUnblocking.value = false;
    }
  }

  /// After "Clear chat": the Media / Links / Docs card must not keep showing
  /// the cleared files until the screen is reopened.
  void clearMediaLocally() {
    final data = profileData.value;
    if (data == null) return;
    data.media = null;
    data.mediaSummary = null;
    profileData.refresh();
  }
}
