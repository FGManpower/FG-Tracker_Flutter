import 'dart:developer';
import 'package:get/get.dart';
import '../../../Core/values/Dialog/Common_dialog.dart';
import '../../../Core/values/Utils.dart';
import '../../../Core/values/loading.dart';
import '../../../Core/values/logoutuser.dart';
import '../../../Data/Repositories/Auth_repo.dart';

class AccountDeletionController extends GetxController {
  final RxBool isDeleting = false.obs;

  Future<void> deleteUserAccount({String? reason, String? feedback}) async {
    try {
      isDeleting.value = true;
      Loading().showloading();

      try {
        final result = await AuthRepo.deleteAccount(
          reason: reason ?? 'User requested account deletion via mobile app',
          feedback: feedback,
        );

        if (result.status == true) {
          Utils().fluttertoast(
            result.message != null && result.message!.toString().trim().isNotEmpty
                ? result.message.toString()
                : 'Account deleted successfully',
          );
          await LogoutUser().logout();
        } else {
          CommonDialog.errorMessage(result.message ?? 'Failed to delete account. Please try again.');
        }
      } catch (e) {
        log('deleteUserAccount API error: ');
        final errMsg = e.toString();
        if (errMsg.contains('401') ||
            errMsg.toLowerCase().contains('unauthorized') ||
            errMsg.toLowerCase().contains('already deleted')) {
          await LogoutUser().logout();
        } else {
          CommonDialog.errorMessage('Failed to delete account: ');
        }
      }
    } finally {
      Loading().dismissloading();
      isDeleting.value = false;
    }
  }
}
