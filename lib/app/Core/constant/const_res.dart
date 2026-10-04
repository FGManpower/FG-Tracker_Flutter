import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ConstRes {
  ///------------------------ Backend urls and key ------------------------///

  // static const String development = 'http://192.168.1.21:4000/'; // Development
  static const String production = 'http://fgtracker.in:3000/'; //Prod
  static const String aBaseUrl = '${production}api/';
  static const String aImageBaseUrl = production;
  static String socketUrl = "http://fgtracker.in:3000"; //pro
  // static const String socketUrl = "http://192.168.1.21:4000"; //dev
  static String DeepLink_Url = "https://fgtracker.in";
  static String gMapApiKey = "AIzaSyAgt-V8kmcQJb_6Cj6LHArWfhWjVPh7N_Q";

  ///------------------------ Payment Gateway Credentials ------------------------///
  // Environment Switch: true = Production (Live), false = Testing (Sandbox)
  static const bool isPaymentLive = true;

  // Razorpay Key IDs (Public Keys for Mobile SDK)
  static const String razorpayTestKey = 'rzp_test_ThoFEwOj0pMgTH';
  static const String razorpayLiveKey = 'rzp_live_TjQUIgRmscuMhF';

  // Active Key for Razorpay Package (dynamically switches based on isPaymentLive)
  static const String activePaymentKey =
      isPaymentLive ? razorpayLiveKey : razorpayTestKey;

  static BaseOptions networkOptions = BaseOptions(
    baseUrl: aBaseUrl,
  );

  final Dio _dio = Dio();
  ConstRes() {
    BaseOptions options = BaseOptions(
      baseUrl: aBaseUrl,
    );
    _dio.options = options;
    _dio.interceptors.add(PrettyDioLogger());
  }
  Dio get sendRequest => _dio;
}
