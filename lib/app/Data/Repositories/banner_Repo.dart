import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/banner_model.dart';
import 'package:fgtracker/app/Model/paid_banner_models.dart';
import 'package:http_parser/http_parser.dart';

class BannerRepo {
  static Future<bannermodel> getBanner() async {
    var response = await HttpUtil().get(Urls.banner);
    return bannermodel.fromJson(response);
  }

  static Future<List<BannerPlanModel>> getPlans({String? currency}) async {
    final response = await HttpUtil().get(
      Urls.bannerPlans,
      data: {
        if (currency != null && currency.trim().isNotEmpty)
          'currency': currency.trim().toUpperCase(),
      },
    );
    final list = (response['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(BannerPlanModel.fromJson)
        .toList();
  }

  static Future<SlotAvailabilityResponse> getSlotAvailability({
    required int planId,
    required String startDate,
  }) async {
    final response = await HttpUtil().get(
      Urls.bannerSlotsAvailability,
      data: {
        'planId': planId,
        'startDate': startDate,
      },
    );
    return SlotAvailabilityResponse.fromJson(
      (response['data'] as Map<String, dynamic>?) ?? const {},
    );
  }

  static Future<int> createDraft({
    required int planId,
    required int slotNumber,
    required String startDate,
    required String title,
    String? description,
    String? targetUrl,
    String? ctaText,
    required File imageFile,
  }) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;
    final ext = fileName.split('.').last.toLowerCase();
    final subType = ext == 'png'
        ? 'png'
        : (ext == 'webp' ? 'webp' : (ext == 'gif' ? 'gif' : 'jpeg'));

    final formData = dio.FormData.fromMap({
      'planId': planId.toString(),
      'slotNumber': slotNumber.toString(),
      'startDate': startDate,
      'title': title.trim(),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
      if (targetUrl != null && targetUrl.trim().isNotEmpty)
        'targetUrl': targetUrl.trim(),
      if (ctaText != null && ctaText.trim().isNotEmpty)
        'ctaText': ctaText.trim(),
      'banner_image': await dio.MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType('image', subType),
      ),
    });

    final response = await HttpUtil().Authpost(
      Urls.bannerDraft,
      formdata: formData,
      type: 'formdata',
    );
    final data = (response['data'] as Map<String, dynamic>?) ?? const {};
    return (data['id'] as num).toInt();
  }

  static Future<BannerOrderResponse> createOrder(int bannerId) async {
    final response = await HttpUtil().Authpost(
      Urls.bannerCreateOrder,
      data: {'bannerId': bannerId},
    );
    return BannerOrderResponse.fromJson(
      (response['data'] as Map<String, dynamic>?) ?? const {},
    );
  }

  static Future<void> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    await HttpUtil().Authpost(
      Urls.bannerVerifyPayment,
      data: {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );
  }

  static Future<List<UserBannerAdModel>> getMyBanners({
    String status = 'all',
  }) async {
    final response = await HttpUtil().get(
      Urls.myBanners,
      data: {'status': status},
    );
    final list = (response['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(UserBannerAdModel.fromJson)
        .toList();
  }

  static Future<void> resubmitRejectedBanner({
    required int bannerId,
    String? title,
    String? description,
    String? targetUrl,
    String? ctaText,
    File? imageFile,
  }) async {
    final map = <String, dynamic>{};
    if (title != null && title.trim().isNotEmpty) map['title'] = title.trim();
    if (description != null) map['description'] = description.trim();
    if (targetUrl != null) map['targetUrl'] = targetUrl.trim();
    if (ctaText != null) map['ctaText'] = ctaText.trim();

    if (imageFile != null) {
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final ext = fileName.split('.').last.toLowerCase();
      final subType = ext == 'png'
          ? 'png'
          : (ext == 'webp' ? 'webp' : (ext == 'gif' ? 'gif' : 'jpeg'));
      map['banner_image'] = await dio.MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType('image', subType),
      );
    }

    await HttpUtil().Authput(
      Urls.bannerResubmit(bannerId),
      formdata: dio.FormData.fromMap(map),
      type: 'formdata',
    );
  }

  static Future<void> requestRefund(int bannerId, {String? reason}) async {
    await HttpUtil().Authpost(
      Urls.bannerRefund(bannerId),
      data: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  static Future<int> renewBanner({
    required int bannerId,
    required int planId,
    required int slotNumber,
    required String startDate,
  }) async {
    final response = await HttpUtil().Authpost(
      Urls.bannerRenew(bannerId),
      data: {
        'planId': planId,
        'slotNumber': slotNumber,
        'startDate': startDate,
      },
    );
    final data = (response['data'] as Map<String, dynamic>?) ?? const {};
    return (data['id'] as num).toInt();
  }

  static Future<void> deleteDraft(int bannerId) async {
    await HttpUtil().Authdelete(Urls.bannerDeleteDraft(bannerId));
  }

  static Future<void> trackEvent(int bannerId, String event) async {
    try {
      await HttpUtil().post(
        Urls.bannerTrack(bannerId),
        data: {'event': event},
      );
    } catch (_) {
      // Analytics tracking must never disrupt UX
    }
  }
}
