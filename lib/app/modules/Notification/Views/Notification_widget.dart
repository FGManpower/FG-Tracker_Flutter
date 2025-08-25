//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:skeletonizer/skeletonizer.dart';
//
// import '../../../Model/NotificationData.dart';
//
// List<NotificationData> generateDummyData() {
//   return [
//     NotificationData(
//       messageId: 1,
//       date: '2024-07-01',
//       time: '12:00 PM',
//       title: 'Job Assigned',
//       body: 'You have been assigned a new job.',
//       parameterIndexId: 101,
//       parameterLabourId: 1001,
//       parameterEmployerId: 2001,
//       parameterChildJobId: 301,
//       parameterParentJobId: 401,
//       parameterDate: '2024-07-01',
//       parameterTime: '12:00 PM',
//       parameterDateTime: '2024-07-01 12:00 PM',
//       parameterOfferType: 'Full-time',
//       parameterJobType: 'Plumbing',
//       parameterRole: 'Labour',
//       parameterScreenName: 'job_detail',
//     ),
//     NotificationData(
//       messageId: 2,
//       date: '2024-07-02',
//       time: '02:00 PM',
//       title: 'Job Completed',
//       body: 'The job you were assigned has been completed.',
//       parameterIndexId: 102,
//       parameterLabourId: 1002,
//       parameterEmployerId: 2002,
//       parameterChildJobId: 302,
//       parameterParentJobId: 402,
//       parameterDate: '2024-07-02',
//       parameterTime: '02:00 PM',
//       parameterDateTime: '2024-07-02 02:00 PM',
//       parameterOfferType: 'Part-time',
//       parameterJobType: 'Carpentry',
//       parameterRole: 'Labour',
//       parameterScreenName: 'active_labour',
//     ),
//     NotificationData(
//       messageId: 3,
//       date: '2024-07-03',
//       time: '04:00 PM',
//       title: 'New Job Offer',
//       body: 'You have received a new job offer.',
//       parameterIndexId: 103,
//       parameterLabourId: 1003,
//       parameterEmployerId: 2003,
//       parameterChildJobId: 303,
//       parameterParentJobId: 403,
//       parameterDate: '2024-07-03',
//       parameterTime: '04:00 PM',
//       parameterDateTime: '2024-07-03 04:00 PM',
//       parameterOfferType: 'Contract',
//       parameterJobType: 'Electrical',
//       parameterRole: 'Labour',
//       parameterScreenName: 'open_labour',
//     ),
//   ];
// }
//
// Widget NotificationLoadingUi(BuildContext context,
//     {required Login_Controller logincontroller,
//     required Product_Controller Productcontroller}) {
//   return Skeletonizer(
//     enabled: true,
//     child: ListView.builder(
//         itemCount: 5,
//         itemBuilder: (context, index) {
//           return NotificationUi(context,
//               logincontroller: logincontroller,
//               Productcontroller: Productcontroller,
//               listdata: generateDummyData());
//         }),
//   );
// }
//
// Widget NotificationUi(BuildContext context,
//     {List<NotificationData>? listdata,
//     required Login_Controller logincontroller,
//     required Product_Controller Productcontroller}) {
//   return Padding(
//     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 10.w),
//           child: reausabletext(
//             "${listdata?.first.date}",
//             fontsize: 12,
//             fontfamily: FontFamily.interBold,
//             // color: Colors.black,
//           ),
//         ),
//         SizedBox(height: 10.h),
//         for (var item in listdata!)
//           Padding(
//             padding: EdgeInsets.only(bottom: 7.h),
//             child: Card(
//               // color: Color(0xffF1F1F1),
//               surfaceTintColor: Colors.white,
//               elevation: 6,
//               child: InkWell(
//                 onTap: () {
//                   if (item.parameterScreenName == 'profile') {
//                     Get.toNamed(Routes.Profile);
//                   } else if (item.parameterScreenName == 'product_detail') {
//                     // Productcontroller?.Get_Product_Detail_Data(context,
//                     //     productid:
//                     //     int.parse(item.parameterIndexId.toString()));
//                     Get.toNamed(Routes.Product_Detail, arguments: {
//                       "productid": int.parse(item.parameterIndexId.toString()),
//                       "type": "",
//                     });
//                   } else if (item.parameterScreenName == 'order_detail') {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => OrderDetailScreen(
//                                 id: int.parse(
//                                     item.parameterIndexId.toString()))));
//                   } else {
//                     Get.toNamed(Routes.Bottom_Navigation);
//                   }
//                 },
//                 child: Container(
//                   padding:
//                       EdgeInsets.symmetric(vertical: 15.w, horizontal: 10.h),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       reausabletext(
//                         "${item.title}",
//                         fontsize: 13,
//                         fontfamily: FontFamily.interSemiBold,
//                         color: context.isDarkMode
//                             ? ToggleThemeData.white
//                             : const Color(0xff525252),
//                         height: 1.4,
//                         maxline: 3,
//                         textoverflow: TextOverflow.ellipsis,
//                       ),
//                       SizedBox(
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               flex: 4,
//                               child: reausabletext(
//                                 "${item.body}",
//                                 fontsize: 12,
//                                 fontfamily: FontFamily.interMedium,
//                                 color: context.isDarkMode
//                                     ? ToggleThemeData.white
//                                     : const Color(0xff525252),
//                                 height: 1.4,
//                                 maxline: 3,
//                                 textoverflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             Expanded(
//                               flex: 1,
//                               child: reausabletext(
//                                 "${item.time}",
//                                 align: TextAlign.start,
//                                 fontsize: 12,
//                                 fontfamily: FontFamily.interSemiBold,
//                               ),
//                             )
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           )
//       ],
//     ),
//   );
// }
