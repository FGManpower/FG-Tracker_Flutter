import 'dart:developer';
import 'package:fgtracker/l10n/l10n.dart';
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
                : appL10n.account_deletedToast,
          );
          await LogoutUser().logout();
        } else {
          CommonDialog.errorMessage(result.message ?? appL10n.account_deleteFailed);
        }
      } catch (e) {
        log('deleteUserAccount API error: ');
        final errMsg = e.toString();
        if (errMsg.contains('401') ||
            errMsg.toLowerCase().contains('unauthorized') ||
            errMsg.toLowerCase().contains('already deleted')) {
          await LogoutUser().logout();
        } else {
          CommonDialog.errorMessage(appL10n.account_deleteFailed);
        }
      }
    } finally {
      Loading().dismissloading();
      isDeleting.value = false;
    }
  }
}
