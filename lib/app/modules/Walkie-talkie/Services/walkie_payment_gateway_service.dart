import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class CashfreeOrderResult {
  final bool isSuccess;
  final String? orderId;
  final String? paymentSessionId;
  final String? paymentUrl;
  final String? orderStatus;
  final String? errorMessage;
  final Map<String, dynamic>? rawResponse;

  const CashfreeOrderResult({
    required this.isSuccess,
    this.orderId,
    this.paymentSessionId,
    this.paymentUrl,
    this.orderStatus,
    this.errorMessage,
    this.rawResponse,
  });
}

class WalkiePaymentGatewayService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  static String get cashfreeBaseUrl => ConstRes.isPaymentLive
      ? 'https://api.cashfree.com/pg'
      : 'https://sandbox.cashfree.com/pg';

  /// Create a new order on Cashfree Gateway
  static Future<CashfreeOrderResult> createCashfreeOrder({
    required num amount,
    required String planTitle,
    required String durationName,
    required int memberCount,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    String? couponCode,
    String? userToken,
  }) async {
    final String orderId = 'FG_${DateTime.now().millisecondsSinceEpoch}';
    final String cleanPhone = customerPhone.replaceAll(RegExp(r'\D'), '');
    final String formattedPhone = cleanPhone.length >= 10
        ? cleanPhone.substring(cleanPhone.length - 10)
        : '9876543210';
    final String formattedEmail =
        customerEmail.isNotEmpty && customerEmail.contains('@')
            ? customerEmail
            : 'support@fgtracker.in';
    final String formattedName =
        customerName.isNotEmpty ? customerName : 'FG Tracker User';
    final String formattedCustId = customerId.isNotEmpty
        ? customerId
        : 'cust_${DateTime.now().millisecondsSinceEpoch}';

    final Map<String, dynamic> requestData = {
      'order_id': orderId,
      'order_amount': double.parse(amount.toStringAsFixed(2)),
      'order_currency': 'INR',
      'customer_details': {
        'customer_id': formattedCustId,
        'customer_name': formattedName,
        'customer_email': formattedEmail,
        'customer_phone': formattedPhone,
      },
      'order_meta': {
        'return_url': 'https://fgtracker.in/payment/status?order_id=$orderId',
        'notify_url': '${ConstRes.aBaseUrl}walkie/payment/webhook',
      },
      'order_note': '$planTitle ($durationName) - $memberCount member(s)',
      'order_tags': {
        'plan_title': planTitle,
        'duration': durationName,
        'member_count': memberCount.toString(),
        if (couponCode != null && couponCode.isNotEmpty) 'coupon': couponCode,
        if (userToken != null && userToken.isNotEmpty) 'token_present': 'true',
      }
    };

    final Map<String, String> headers = {
      'x-client-id': ConstRes.activePaymentKey,
      'x-client-secret': '',
      'x-api-version': '2023-08-01',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      debugPrint(
          "🚀 [Cashfree] Creating Order: $orderId at $cashfreeBaseUrl/orders");
      debugPrint("📋 [Cashfree] Payload: ${jsonEncode(requestData)}");

      final response = await _dio.post(
        '$cashfreeBaseUrl/orders',
        options: Options(headers: headers),
        data: requestData,
      );

      debugPrint("✅ [Cashfree] Response Code: ${response.statusCode}");
      debugPrint("📦 [Cashfree] Response Body: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final String? paymentSessionId = data['payment_session_id']?.toString();
        final String? orderStatus = data['order_status']?.toString();

        // Construct or retrieve checkout URL
        String? paymentUrl;
        if (data['payments'] is Map && data['payments']['url'] != null) {
          paymentUrl = data['payments']['url'].toString();
        } else if (paymentSessionId != null && paymentSessionId.isNotEmpty) {
          paymentUrl = ConstRes.isPaymentLive
              ? 'https://payments.cashfree.com/forms/$paymentSessionId'
              : 'https://sandbox.cashfree.com/pg/orders/sessions/$paymentSessionId';
        }

        return CashfreeOrderResult(
          isSuccess: true,
          orderId: orderId,
          paymentSessionId: paymentSessionId,
          paymentUrl: paymentUrl,
          orderStatus: orderStatus ?? 'ACTIVE',
          rawResponse: data is Map<String, dynamic> ? data : null,
        );
      } else {
        return CashfreeOrderResult(
          isSuccess: false,
          errorMessage:
              "Failed to create payment session: ${response.statusMessage}",
        );
      }
    } on DioException catch (dioErr) {
      debugPrint(
          "❌ [Cashfree] DioException: ${dioErr.message} | Response: ${dioErr.response?.data}");
      String msg = "Payment initiation failed.";
      if (dioErr.response?.data is Map) {
        final map = dioErr.response!.data as Map;
        msg = map['message']?.toString() ??
            map['error']?.toString() ??
            "Cashfree error (${dioErr.response?.statusCode})";
      } else if (dioErr.error is SocketException) {
        msg = "No internet connection. Please check your network.";
      }
      return CashfreeOrderResult(
        isSuccess: false,
        errorMessage: msg,
        rawResponse: dioErr.response?.data is Map<String, dynamic>
            ? dioErr.response!.data as Map<String, dynamic>
            : null,
      );
    } catch (e) {
      debugPrint("❌ [Cashfree] Error: $e");
      return CashfreeOrderResult(
        isSuccess: false,
        errorMessage: "Unable to process payment: $e",
      );
    }
  }

  /// Check / Verify Order status from Cashfree
  static Future<String?> checkOrderStatus(String orderId) async {
    final Map<String, String> headers = {
      'x-client-id': ConstRes.activePaymentKey,
      'x-client-secret': '',
      'x-api-version': '2023-08-01',
      'Accept': 'application/json',
    };

    try {
      final response = await _dio.get(
        '$cashfreeBaseUrl/orders/$orderId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final status = response.data['order_status']?.toString();
        debugPrint("🔍 [Cashfree] Order $orderId Status: $status");
        return status;
      }
    } catch (e) {
      debugPrint("❌ [Cashfree] Verify status error: $e");
    }
    return null;
  }

  /// Launch Payment URL
  static Future<bool> launchPaymentUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (e) {
      debugPrint("❌ [Cashfree] Launch URL Error: $e");
      try {
        final uri = Uri.parse(url);
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e2) {
        debugPrint("❌ [Cashfree] Launch External URL Error: $e2");
        return false;
      }
    }
  }
}
