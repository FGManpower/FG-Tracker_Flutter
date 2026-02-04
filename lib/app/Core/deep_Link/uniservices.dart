import 'dart:developer';

import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/modules/DashboardController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../../modules/Walkie-talkie/Controller/walkieController.dart';
import '../../modules/Walkie-talkie/soundTesting.dart';
import '../values/Context_Utility.dart';

// final _appLinks = AppLinks();
// final controller = Get.put(DashboardCtr());
//
// class UniServices {
//   static String _code = "";
//
//   static String get code => _code;
//
//   static bool get hascode => _code.isNotEmpty;
//
//   static void reset() => _code = "";
//
//   static init(BuildContext context, {Function(bool)? onCompletion}) async {
//     try {
//       final Uri? uri = await _appLinks.getInitialLink();
//       uniHandler(context, uri, onCompletion: onCompletion);
//     } on PlatformException catch (e) {
//       log("Failed to recieve${e.code}");
//     } on FormatException catch (e) {
//       log("Format to recieve$e");
//     }
//
//     _appLinks.uriLinkStream.listen((Uri? uri) async {
//       if (!isHandlerCalled) {
//         isHandlerCalled = true;
//
//         Future.delayed(const Duration(milliseconds: 5), () {
//           isHandlerCalled = false;
//         });
//
//         Future.delayed(const Duration(seconds: 3), () {
//           // if(AppLinkStateTracker.isIncomingScreenOpened==true){
//
//           uniHandler(context, uri, onCompletion: onCompletion);
//           // }
//         });
//       }
//     }).onError((error) {
//       log("onUriException$error");
//     });
//   }
//
//   static Future<void> uniHandler(BuildContext context, Uri? uri,
//       {Function(bool)? onCompletion}) async {
//     if (uri == null || uri.queryParameters.isEmpty) return;
//
//     try {
//       Map<String, String> param = uri.queryParameters;
//       String recievecode = param["page"] ?? '';
//       try {
//         await Global.init();
//       } catch (e) {
//         log("Exeption${e.toString()}");
//       }
//
//       if (recievecode == "Walkie") {
//         if (AppLinkStateTracker.isIncomingScreenOpened == false) {
//
//           // if (Utility.isNotNullEmptyOrFalse(notificationData.callerId)) {
//             try {
//               Future.delayed(Duration(seconds: 3));
//
//               // WalkieController().onIncoming(
//               //   remoteUserId: data['fromUserId'],
//               //   callerName: data['fromUserName'] ?? "Unknown",
//               //   profileImage: data['fromUserProfile'] ?? "",
//               // );
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => RealtimeAudioScreen(
//
//                   ),
//                 ),
//               ).then((value) {
//                 AppLinkStateTracker.isIncomingScreenOpened = false;
//                 controller.DeeplinkWithStartJob.value = true;
//               });
//             } catch (e) {
//               log("NavigatorException--------${e.toString()}");
//             }
//           // } else {
//           //   log("DeepLink: Notification data is null, skipping navigation.");
//           // }
//         }
//       }
//     } catch (e) {
//       log("Uni_Link...:$e");
//     }
//   }
// }
//
// bool isHandlerCalled = false;
//
// class AppLinkStateTracker {
//   static bool isIncomingScreenOpened = false;
// }

final controller = Get.put(DashboardCtr());
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

      if (recievecode == "Walkie") {

        // if (AppLinkStateTracker.isIncomingScreenOpened == false) {



            Navigator.push(
              ContextUtility.context!,
              MaterialPageRoute(
                builder: (context) => RealtimeAudioScreen(
                ),
              ),
            ).then((value) {
              print(
                  "-------isIncomingScreenOpened---------${AppLinkStateTracker.isIncomingScreenOpened}");
              if (value == "true") {
                AppLinkStateTracker.isIncomingScreenOpened = false;
                controller.DeeplinkWithStartJob.value = true;
              }
            });

        // }
      }
    } catch (e) {
      log("Uni_Link...:$e");
    }
  }
}

bool isHandlerCalled = false;

class AppLinkStateTracker {
  static bool isIncomingScreenOpened = false;
}
