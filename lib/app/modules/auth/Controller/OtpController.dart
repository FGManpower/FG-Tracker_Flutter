// ignore_for_file: unused_import

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/Auth_repo.dart';
import 'package:fgtracker/app/Data/Services/MethodChannel.dart';
import 'package:fgtracker/app/Data/Services/NotificationServices.dart';
import 'package:fgtracker/app/Data/Services/Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/Data/Services/group_Service.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp_autofill/otp_autofill.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/values/loading.dart';
import '../../../Data/Services/SignallingService.dart';

class OtpController extends GetxController {
  TextEditingController otpController = TextEditingController();
  TextEditingController resendOtpController = TextEditingController();
  FocusNode focusNode = FocusNode();
  OTPInteractor otpInteractor = OTPInteractor();
  Timer? _timer;
  var deviceId = "".obs;
  var voipDeviceId = "".obs;
  var resendSeconds = 0.obs;
  var mobileNumber = ''.obs;
  var showOtpSentText = false.obs;
  final otpErrorText = ''.obs;
  late FocusNode phoneFocusNode;

  Map<String, dynamic>? arguments = Get.arguments;

  @override
  void onInit() {
    super.onInit();

    registerPushTokens();

    otpController = OTPTextEditController(
      codeLength: 4,
      onCodeReceive: (code) => log('$code'),
      otpInteractor: otpInteractor,
    )..startListenUserConsent(
        (code) {
          final exp = RegExp(r'(\d{4})');
          return exp.stringMatch(code ?? '') ?? '';
        },
      );

    mobileNumber.value = arguments?['mobNo'] ?? '';
  }

  bool validateOtp() {
    String number = otpController.text.trim();

    if (number.isEmpty) {
      otpErrorText.value = "Otp is required!";
      return false;
    } else if (otpController.text.length < 4) {
      otpErrorText.value = "Otp must be at least 4 digit";
      return false;
    }

    otpErrorText.value = '';
    return true;
  }

  registerPushTokens() async {
    if (Platform.isIOS) {
      final String? token = await ConnectycubeFlutterCallKit.getToken();

      if (token == null) {
        log("Token is null");
        return;
      }
      voipDeviceId.value = token;
      log("Device token: $token");
    }

    firebaseNotificationServices().getDiviceToken().then(
      (value) {
        deviceId.value = value;
      },
    );
  }

  void startResendTimer() {
    _timer?.cancel();
    resendSeconds.value = 59;
    showOtpSentText.value = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value == 0) {
        timer.cancel();
        showOtpSentText.value = false;
      } else {
        resendSeconds.value--;
      }
    });
  }

  void resendOtp() async {
    try {
      Loading().showloading();
      dynamic param = {
        "MobileNo": arguments?['mobNo'],
        "countryCode": arguments?['countryCode'],
      };

      var result = await AuthRepo.ResendOtp(param);
      Loading().dismissloading();

      if (result.status == true) {
        Utils().fluttertoast(result.message.toString());
        startResendTimer();
      } else {
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> veriefyOtp() async {
    if (!validateOtp()) return;
    try {
      Loading().showloading();
      dynamic param = {
        "countryCode": arguments?['countryCode'],
        "MobileNo": arguments?['mobNo'],
        "otp": otpController.text,
        'Device_Id': deviceId.value ?? "",
        'Voip_Device': voipDeviceId.value ?? "",
        'Platform': Platform.isAndroid ? "android" : "ios",
      };
      print("==================VeriefyParam==========${param}");
      var result = await AuthRepo.VeriefyOtp(param);
      if (result.status == true) {
        Loading().dismissloading();

        try {
          SignallingService.instance.init(
            websocketUrl: ConstRes.socketUrl,
            selfCallerID: result.data!.userId.toString(),
          );

          if (result.data!.userId != null) {
            GroupWalkieService.instance.init(
              websocketUrl: ConstRes.socketUrl,
              selfUserId: result.data!.userId.toString(),
            );

          }
        } catch (e) {
          log("login_SocketException====${e}");
        }

        Global.storageServices.setString(
          PrefConst.STORAGE_USER_TOKEN_KEY,
          result.data!.token.toString(),
        );
        Global.storageServices.setString(
          PrefConst.userId,
          result.data!.userId.toString(),
        );
        if (result.data?.isNewUser == true) {
          Get.toNamed(Routes.Register, arguments: {
            "mobNo": arguments?['mobNo'],
          });
        } else {
          Global.storageServices.setString(
            PrefConst.userName,
            result.data!.userName ?? "Unknown",
          );

          Global.storageServices.setString(
            PrefConst.profileImage,
            result.data!.profileImage ?? "Unknown",
          );
          Global.storageServices.setString(
            PrefConst.isRegistered,
            "true",
          );
          Get.offAllNamed(Routes.Home_Screen);
        }
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }
}
