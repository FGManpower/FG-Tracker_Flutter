import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

String ProductionUrl = "http://fgtracker.in:3000/";
String development = "http://10.85.239.223:4000/";
String socketUrl = "http://fgtracker.in:3000"; //pro
// String socketUrl = "http://10.85.239.223:4000"; //dev


final String agoraAppId = "46901509bdc9411a85d1287c9957a42d";

class Constant {
  static String Baseurl = "${ProductionUrl}api";
  static String incomingDeepLinkUrl = "https://fgtracker.in";
  static String ImagebaseUrl = ProductionUrl;
  static BaseOptions networkOptions = BaseOptions(
    baseUrl: Baseurl,
  );

  final Dio _dio = Dio();

  Constant() {
    BaseOptions options = BaseOptions(
      baseUrl: Baseurl,
      // receiveDataWhenStatusError: true, connectTimeout: Duration(seconds: 25), // 60 seconds
      // receiveTimeout: Duration(seconds: 25) // 60 seconds
    );
    _dio.options = options;
    _dio.interceptors.add(PrettyDioLogger());
  }

  Dio get sendRequest => _dio;

  static String CurrentVersion = "";
  static String STORAGE_USER_TOKEN_KEY = "user_token_key";
  static String DEVICE_ID = "device_id";

  static String TermsandCondition = "TermsandCondition";
  static String Location_Permission = "Location_Permission";
  static String isDarkMode = "isDarkMode";
  static String notificationBadge = "notificationBadge";

  static String googleMapApiKey = "AIzaSyDu1PPgXuqRdLfEfA9Gf-6A8QydUlyMq-0";
  static String userId = "userId";
  static String userName = "userName";
  static String profileImage = "profileImage";
  static String isRegistered = "isRegistered";
  static String AcceptPolicy = "AcceptPolicy";
  static String incomingCall = "incomingCall";
}
