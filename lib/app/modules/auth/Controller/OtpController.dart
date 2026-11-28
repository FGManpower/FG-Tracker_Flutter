import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/otp_charge_repo.dart';
import 'package:fgtracker/app/Model/otp_charge_model.dart';
import 'package:fgtracker/app/Data/Services/NotificationServices.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:otp_autofill/otp_autofill.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/values/loading.dart';
import '../../../Core/values/logoutuser.dart';
import '../../../Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/modules/status/binding/status_binding.dart';
import 'package:fgtracker/app/Data/Services/GroupCountService.dart';
import 'package:fgtracker/app/Data/Services/notification_marker_service.dart';

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
  bool _isVerifying = false;
  final isResendBlocked = false.obs;
  final resendAttemptsRemaining = RxnInt();
  final resendBlockedUntil = Rxn<DateTime>();

  Map<String, dynamic>? arguments = Get.arguments;

  @override
  void onInit() {
    super.onInit();

    registerPushTokens();

    try {
      otpController = OTPTextEditController(
        codeLength: 4,
        onCodeReceive: (code) {
          log("OTP AutoFill received code: $code");
          if (code.length == 4) {
            veriefyOtp();
          }
        },
        otpInteractor: otpInteractor,
      )..startListenUserConsent(
          (code) {
            final exp = RegExp(r'(\d{4})');
            return exp.stringMatch(code ?? '') ?? '';
          },
        );
    } catch (e) {
      log("OTP autofill initialization error: $e");
    }

    mobileNumber.value = arguments?['mobNo'] ?? '';
    _applyResendInfo(arguments?['otpResend'] as OtpResendInfo?);
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
      final String? token =
          await FlutterCallkitIncoming.getDevicePushTokenVoIP();

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

  /// v2 resend limit: 3 attempts, then a 6-hour block
  void _applyResendInfo(OtpResendInfo? info) {
    if (info == null) return;
    isResendBlocked.value = info.isBlocked;
    resendAttemptsRemaining.value = info.attemptsRemaining;
    resendBlockedUntil.value = info.blockedUntil ??
        (info.retryAfterSeconds > 0
            ? DateTime.now().add(Duration(seconds: info.retryAfterSeconds))
            : null);
  }

  bool get resendBlocked {
    final until = resendBlockedUntil.value;
    return isResendBlocked.value &&
        (until == null || DateTime.now().isBefore(until));
  }

  /// "Too many OTP requests. Please wait 6 hours."
  String get resendBlockedText {
    final until = resendBlockedUntil.value;
    if (until == null) return "Too many OTP requests. Please try again later.";
    final minutes = until.difference(DateTime.now()).inMinutes + 1;
    final hours = (minutes / 60).ceil();
    return hours > 1
        ? "Too many OTP requests. Please wait $hours hours."
        : "Too many OTP requests. Please wait $minutes minute${minutes == 1 ? '' : 's'}.";
  }

  /// "Resend It (2 attempts remaining)"
  String get resendLabel {
    final left = resendAttemptsRemaining.value;
    if (left == null || left > 2) return "Resend It";
    return "Resend It ($left attempt${left == 1 ? '' : 's'} remaining)";
  }

  void resendOtp() async {
    if (resendBlocked) return;
    try {
      Loading().showloading();
      dynamic param = {
        "MobileNo": arguments?['mobNo'],
        "countryCode": arguments?['countryCode'],
      };

      var result = await OtpChargeRepo.resendOtp(param);
      Loading().dismissloading();
      _applyResendInfo(result.otpResend);

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
    try {
      if (otpController is OTPTextEditController) {
        (otpController as OTPTextEditController).stopListen();
      }
    } catch (_) {}
    super.onClose();
  }

  Future<void> veriefyOtp() async {
    if (_isVerifying) return;
    if (!validateOtp()) return;
    _isVerifying = true;
    try {
      Loading().showloading();

      if (deviceId.value.isEmpty) {
        try {
          final token = await firebaseNotificationServices().getDiviceToken();
          if (token.isNotEmpty) {
            deviceId.value = token;
          }
        } catch (_) {}
      }

      dynamic param = {
        "countryCode": arguments?['countryCode'],
        "MobileNo": arguments?['mobNo'],
        "otp": otpController.text,
        'Device_Id': deviceId.value,
        'Voip_Device': voipDeviceId.value,
        'Platform': Platform.isAndroid ? "android" : "ios",
      };

      var result = await OtpChargeRepo.verifyOtp(param);
      if (result.status == true) {
        Loading().dismissloading();

        // 0. Ensure fresh clean storage slate before writing new user credentials
        await Global.storageServices.clearAllUserData();

        // 1. Save auth credentials FIRST before initializing sockets
        await Global.storageServices.setString(
          PrefConst.STORAGE_USER_TOKEN_KEY,
          result.data!.token.toString(),
        );
        await Global.storageServices.setString(
          PrefConst.userId,
          result.data!.userId.toString(),
        );
        if (result.data?.locationSharing != null) {
          await Global.storageServices.setBool(
            PrefConst.locationSharing,
            result.data!.locationSharing!,
          );
        } else {
          try {
            final privateRes = await TrackRepo.getPrivateMembers(limit: 50);
            final myId = result.data!.userId?.toString();
            if (privateRes.user?.isLocationSharing != null) {
              await Global.storageServices.setBool(
                PrefConst.locationSharing,
                privateRes.user!.isLocationSharing!,
              );
            } else if (myId != null && privateRes.data?.private != null) {
              final isPrivate = privateRes.data!.private!.any(
                (m) => m.userId?.toString() == myId,
              );
              await Global.storageServices.setBool(
                PrefConst.locationSharing,
                !isPrivate,
              );
            }
          } catch (_) {}
        }

        // 2. Establish grace period for this newly logged-in device
        LogoutUser.recordLoginSuccess();

        // 3. Initialize sockets for user
        try {
          if (result.data!.userId != null) {
            SignallingService.instance.init(
              websocketUrl: ConstRes.socketUrl,
              selfCallerID: result.data!.userId.toString(),
            );

            GroupWalkieService.instance.init(
              websocketUrl: ConstRes.socketUrl,
              selfUserId: result.data!.userId.toString(),
            );

            Socket_GroupCallService.instance
                .init(result.data!.userId.toString());

            SocketDashboardService().init();

            StatusBinding().dependencies();

            GroupCountService.instance;
            NotificationMarkerService.instance;
          }
        } catch (e) {
          log("login_SocketException====$e");
        }

        if (result.data?.isNewUser == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.toNamed(Routes.Register, arguments: {
              "mobNo": arguments?['mobNo'],
            });
          });
        } else {
          await Global.storageServices.setString(
            PrefConst.userName,
            result.data!.userName ?? "Unknown",
          );

          await Global.storageServices.setString(
            PrefConst.profileImage,
            result.data!.profileImage ?? "Unknown",
          );

          await Global.storageServices.setString(
            PrefConst.isRegistered,
            "true",
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(Routes.permissionSetup);
          });
        }
      } else {
        Loading().dismissloading();
        otpController.clear();
        otpErrorText.value = result.message ?? "Invalid OTP code";
        CommonDialog.errorMessage(result.message);
        focusNode.requestFocus();
      }
    } catch (e) {
      Loading().dismissloading();
      otpController.clear();
      otpErrorText.value = e.toString();
      CommonDialog.errorMessage(e.toString());
      focusNode.requestFocus();
    } finally {
      _isVerifying = false;
    }
  }
}
