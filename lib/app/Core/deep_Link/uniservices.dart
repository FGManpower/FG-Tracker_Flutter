import 'dart:developer';

import 'package:fgtracker/app/Core/values/global.dart';

import 'package:flutter/services.dart';

import 'package:app_links/app_links.dart';

final _appLinks = AppLinks();

class UniServices {
  static String _code = "";

  static String get code => _code;

  static bool get hascode => _code.isNotEmpty;

  static void reset() => _code = "";

  static init({Function(bool)? onCompletion}) async {
    try {
      final Uri? uri = await _appLinks.getInitialLink();
      uniHandler(uri, onCompletion: onCompletion);
    } on PlatformException catch (e) {
      log("uxcepected${e.code}");
    } on FormatException catch (e) {
      log("formateException--$e");
    }

    _appLinks.uriLinkStream.listen((Uri? uri) async {
      if (!isHandlerCalled) {
        isHandlerCalled = true;

        Future.delayed(const Duration(milliseconds: 5), () {
          isHandlerCalled = false;
        });

        Future.delayed(const Duration(seconds: 3), () {
          // if(AppLinkStateTracker.isIncomingScreenOpen==true){
          uniHandler(uri, onCompletion: onCompletion);
          // }
        });
      }
    }).onError((error) {
      log("upexpected $error");
    });
  }

  static Future<void> uniHandler(Uri? uri,
      {Function(bool)? onCompletion}) async {
    if (uri == null || uri.queryParameters.isEmpty) return;

    try {
      Map<String, String> param = uri.queryParameters;
      String recievecode = param["page"] ?? '';
      try {
        await Global.init();
      } catch (e) {
        log("exception-error ${e.toString()}");
      }

      if (recievecode == "Walkie") {}
    } catch (e) {
      log("Uni_Link...:$e");
    }
  }
}

bool isHandlerCalled = false;

class AppLinkStateTracker {
  static bool isIncomingScreenOpened = false;
}
