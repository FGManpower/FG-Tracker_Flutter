import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  Get.offAllNamed(Routes.Login);
}
