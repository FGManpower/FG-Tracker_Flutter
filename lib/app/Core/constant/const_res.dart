import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ConstRes {
  ///------------------------ App Version ------------------------///
  static const String appVersion = '2.0.8';
  static const int appBuildNumber = 340;

  ///------------------------ Environment Switch ------------------------///
  /// Set [isProduction] = true to connect to AWS Cloud Production (Mumbai ap-south-1).
  /// Set [isProduction] = false to connect to the existing Hostinger VPS for Testing.
  /// Can also be toggled at compile-time via:
  ///   flutter run --dart-define=IS_PROD=true
  ///   flutter run --dart-define=IS_PROD=false
  static const bool isProduction =
      bool.fromEnvironment('IS_PROD', defaultValue: false);

  ///------------------------ Server Endpoints By Environment ------------------------///
  // AWS Production (Mumbai ap-south-1 - HTTPS & WSS via ALB)
  static const String _awsServerUrl = 'https://api.fgtracker.fgmanpower.co.in/';
  static const String _awsSocketUrl = 'https://api.fgtracker.fgmanpower.co.in';
  static const String _awsDeepLinkUrl = 'https://fgtracker.fgmanpower.co.in';

  // Hostinger VPS Server (Testing / Staging - HTTP & WS)
  static const String _vpsServerUrl = 'http://89.116.23.2:3000/';
  static const String _vpsSocketUrl = 'http://89.116.23.2:3000';
  static const String _vpsDeepLinkUrl = 'https://fgtracker.in';

  ///------------------------ Active Backend URLs & Keys ------------------------///
  static const String production = isProduction ? _awsServerUrl : _vpsServerUrl;
  static const String aBaseUrl = '${production}api/';
  static const String aImageBaseUrl = production;
  static const String socketUrl = isProduction ? _awsSocketUrl : _vpsSocketUrl;
  static const String DeepLink_Url = isProduction ? _awsDeepLinkUrl : _vpsDeepLinkUrl;
  static String gMapApiKey = "AIzaSyAgt-V8kmcQJb_6Cj6LHArWfhWjVPh7N_Q";

  ///------------------------ Payment Gateway Credentials ------------------------///
  // Environment Switch: true = Production (Live), false = Testing (Sandbox)
  static const bool isPaymentLive = true;

  // Razorpay Key IDs (Public Keys for Mobile SDK)
  static const String razorpayTestKey = 'rzp_test_ThoFEwOj0pMgTH';
  static const String razorpayLiveKey = 'rzp_live_TjQUIgRmscuMhF';

  static const String activePaymentKey =
      isPaymentLive ? razorpayLiveKey : razorpayTestKey;

  static BaseOptions networkOptions = BaseOptions(
    baseUrl: aBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  );

  final Dio _dio = Dio();
  ConstRes() {
    BaseOptions options = BaseOptions(
      baseUrl: aBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      // Declares support for attendance polls; without it the backend sends
      // attendance messages as plain text.
      headers: {"x-attendance-supported": "1"},
    );
    _dio.options = options;
    _dio.interceptors.add(PrettyDioLogger(enabled: false));
  }
  Dio get sendRequest => _dio;
}
