
import 'package:fgtracker/app/modules/auth/Controller/OtpController.dart';
import 'package:fgtracker/app/modules/auth/Controller/RegisterController.dart';
import 'package:fgtracker/app/modules/auth/Controller/login_controller.dart';
import 'package:get/get.dart';



class Auth_Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Login_Controller>(
      () => Login_Controller(),
    );
  }
}

class Registeration_Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistrationController>(
          () => RegistrationController(),
    );
  }
}

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(
          () => OtpController(),
    );
  }
}


