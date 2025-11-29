//
//
// import 'package:fgtracker/app/modules/Notification/controller/Notification_Controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
//
// import '../../../global_widget/common_widget.dart';
// import 'Notification_widget.dart';
//
// class Notification_screen extends GetView<NotificationController> {
//   Notification_screen({Key? key}) : super(key: key);
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:
//           reusableAppbar("Notification".tr, ontap: () => Navigator.pop(context)),
//       body: Obx(() {
//         if (controller.Respone_Error.value.isNotEmpty) {
//           return LostinternetConnection(
//               retry: () {
//                 controller.getNotificationData();
//               },
//               messgae: controller.Respone_Error.value.toString());
//         } else if (controller.notificationdata.value == null &&
//             controller.loading.value == true) {
//           return NotificationLoadingUi(context,
//               logincontroller: logincontroller,
//               Productcontroller: Productcontroller);
//         } else if (controller.notificationdata.value?.response.toString() ==
//             "{}") {
//           return DataEmpty_AssetsIcon(assetspath: Assets.images.prouductempty.path);
//         } else {
//           return NotificationListData(
//               listitem: controller.notificationdata.value!);
//         }
//       }),
//     );
//   }
//
//   Widget NotificationListData({required NotificationRes listitem}) {
//     return MyCustomPullToRefresh(
//       Indicatorekey: GlobalKey<LiquidPullToRefreshState>(),
//       onTap2Callback: () {
//         controller.getNotificationData();
//       },
//       child: ListView.builder(
//         physics: const ClampingScrollPhysics(),
//         itemCount: listitem.response.length,
//         itemBuilder: (context, index) {
//           int reversedIndex = listitem.response.length - 1 - index;
//           String date = listitem.response.keys.elementAt(reversedIndex);
//           List<NotificationData> listdata = listitem.response[date]!;
//           return NotificationUi(context,
//               listdata: listdata,
//               logincontroller: logincontroller,
//               Productcontroller: Productcontroller);
//         },
//       ),
//     );
//   }
// }
