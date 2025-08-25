import 'package:get/get.dart';

class PrivacyTermsController extends GetxController {
  var showTerms = false.obs;
  var isAtBottom = false.obs;

  void setShowTerms(bool value) => showTerms.value = value;
  void setIsAtBottom(bool value) => isAtBottom.value = value;
}
