import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Model/CommonRes.dart';
import 'package:fgtracker/app/Model/OtpVeriefy.dart';
import 'package:http_parser/http_parser.dart';

import 'package:fgtracker/app/modules/auth/Controller/RegisterController.dart';


class AuthRepo {
  static Future<CommonResponse> login(dynamic param) async {
    var response = await HttpUtil().post(Urls.sendOtp, data: param);
    return CommonResponse.fromJson(response);
  }

  static Future<VeriefyOtpResponse> VeriefyOtp(dynamic param) async {
    var response = await HttpUtil().post(Urls.verifyOtp, data: param);
    return VeriefyOtpResponse.fromJson(response);
  }

  static Future<CommonResponse> logOutUser() async {
    var response = await HttpUtil().get(Urls.logOut);
    return CommonResponse.fromJson(response);
  }
  static Future<VeriefyOtpResponse> ResendOtp(dynamic param) async {
    var response = await HttpUtil().post(Urls.resendOtp, data: param);
    return VeriefyOtpResponse.fromJson(response);
  }

  static Future<CommonResponse> Register(
      RegistrationController controller) async {
    final Map<String, dynamic> formMap = {
      'Name': controller.nameController.text.trim(),
      'MobileNo': controller.phoneController.text.trim(),
      'Gender': controller.gender.value.isNotEmpty ? controller.gender.value : 'male',
    };

    if (controller.emailController.text.trim().isNotEmpty) {
      final emailVal = controller.emailController.text.trim();
      formMap['Email'] = emailVal;
      formMap['email'] = emailVal;
      formMap['email_id'] = emailVal;
      formMap['EmailId'] = emailVal;
      formMap['userEmail'] = emailVal;
      formMap['UserEmail'] = emailVal;
    }

    if (Utility.isNotNullEmptyOrFalse(controller.selectedImage.value)) {
      formMap['ProfileImage'] = await MultipartFile.fromFile(
        controller.selectedImage.value.toString(),
        filename: controller.selectedImage.value.toString().split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
    }

    FormData data = FormData.fromMap(formMap);
    var response =
        await HttpUtil().Authpost(Urls.updateProfile, formdata: data, type: "formdata");
    return CommonResponse.fromJson(response);
  }

  static Future<CommonResponse> updateProfile(
      RegistrationController controller) async {
    final Map<String, dynamic> formMap = {
      'Name': controller.nameController.text.trim(),
      'name': controller.nameController.text.trim(),
      'Gender': controller.gender.value.isNotEmpty ? controller.gender.value : 'male',
      'gender': controller.gender.value.isNotEmpty ? controller.gender.value : 'male',
    };

    if (controller.phoneController.text.trim().isNotEmpty) {
      formMap['MobileNo'] = controller.phoneController.text.trim();
      formMap['mobileNo'] = controller.phoneController.text.trim();
    }

    if (controller.hasExistingEmail.value && controller.emailController.text.trim().isNotEmpty) {
      final emailVal = controller.emailController.text.trim();
      formMap['Email'] = emailVal;
      formMap['email'] = emailVal;
      formMap['email_id'] = emailVal;
      formMap['EmailId'] = emailVal;
      formMap['userEmail'] = emailVal;
      formMap['UserEmail'] = emailVal;
    }

    if (Utility.isNotNullEmptyOrFalse(controller.selectedImage.value)) {
      formMap['ProfileImage'] = await MultipartFile.fromFile(
        controller.selectedImage.value.toString(),
        filename: controller.selectedImage.value.toString().split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
    }

    final data = FormData.fromMap(formMap);

    var response = await HttpUtil()
        .Authpost(Urls.updateProfile, formdata: data, type: "formdata");
    return CommonResponse.fromJson(response);
  }
}
