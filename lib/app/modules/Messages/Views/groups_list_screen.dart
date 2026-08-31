// import 'package:fgtracker/app/Core/theme/AppText.dart';
// import 'package:fgtracker/app/global_widget/common_widget.dart';
// import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
// import 'package:fgtracker/app/modules/home/Home_Widget/CreatedGroupUi.dart';
// import 'package:fgtracker/app/modules/home/Home_Widget/NewlyGroupUi.dart';
// import 'package:fgtracker/gen/assets.gen.dart';
// import 'package:fgtracker/gen/fonts.gen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// class GroupsListScreen extends StatelessWidget {
//   GroupsListScreen({super.key});
//
//   final groupController = Get.find<GroupController>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () => Get.back(),
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
//         ),
//         title: reausabletext(
//           "My Groups",
//           fontsize: 18.sp,
//           fontfamily: FontFamily.interBold,
//           color: Colors.black87,
//         ),
//         centerTitle: true,
//       ),
//       body: RefreshIndicator(
//         color: const Color(0xFF6B4DFF),
//         onRefresh: () async {
//           await groupController.getGroupData();
//         },
//         child: ListView(
//           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//           children: [
//             // ---------- Newly Created Group ----------
//             Padding(
//               padding: EdgeInsets.only(left: 5.w, bottom: 10.h),
//               child: reausabletext(
//                 "Newly Created Group",
//                 fontfamily: FontFamily.interSemiBold,
//                 fontsize: 18,
//               ),
//             ),
//             Obx(() {
//               if (groupController.responseError.value.isNotEmpty) {
//                 return LostinternetConnection(
//                   retry: groupController.getGroupData,
//                   messgae: groupController.responseError.value.toString(),
//                 );
//               } else if (groupController.groupDataLoading.value) {
//                 return NewlyGroupUi(
//                   isLoading: true,
//                   groupController: groupController,
//                 );
//               } else if (groupController.newlyCreatedGroups.isEmpty) {
//                 return Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20.h),
//                   child: Center(
//                     child: reausabletext(
//                       AppText.youHaventJoindOrCreatedGroup,
//                       align: TextAlign.center,
//                       color: Colors.grey[600],
//                       fontsize: 14,
//                     ),
//                   ),
//                 );
//               } else {
//                 return NewlyGroupUi(
//                   groupData: groupController.newlyCreatedGroups,
//                   isLoading: false,
//                   groupController: groupController,
//                 );
//               }
//             }),
//
//             SizedBox(height: 15.h),
//
//             Padding(
//               padding: EdgeInsets.only(left: 5.w, top: 5.h, bottom: 10.h),
//               child: reausabletext(
//                 "Created Group",
//                 fontfamily: FontFamily.interSemiBold,
//                 fontsize: 18,
//               ),
//             ),
//             Obx(() {
//               if (groupController.createdGroups.isEmpty) {
//                 return Center(
//                   child: DataEmpty(
//                     imgname: Assets.images.notFount.path,
//                     type: "png",
//                   ),
//                 );
//               }
//               return CreatedGroupUi(
//                 groupData: groupController.createdGroups,
//                 isLoading: false,
//                 groupController: groupController,
//               );
//             }),
//             SizedBox(height: 20.h),
//           ],
//         ),
//       ),
//     );
//   }
// }