import 'dart:developer';
import 'package:get/get.dart';
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

        if (result.message != null && result.message!.toString().trim().isNotEmpty) {
          Utils().fluttertoast(result.message.toString());
        } else {
          Utils().fluttertoast('Account deleted successfully');
        }
      } catch (e) {
        log('deleteUserAccount API error: ');
        Utils().fluttertoast('Account deletion processed');
      }
    } finally {
      Loading().dismissloading();
      isDeleting.value = false;
      await LogoutUser().logout();
    }
  }
}
