import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/controller/call_controller.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Core/constant/pref_res.dart';

class CallContactsTab extends StatefulWidget {
  const CallContactsTab({super.key});

  @override
  State<CallContactsTab> createState() => _CallContactsTabState();
}

class _CallContactsTabState extends State<CallContactsTab> {
  final CallController controller = Get.put(CallController());

  @override
  void initState() {
    super.initState();
    controller.getRegisteredContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.responseError.value.isNotEmpty) {
        return LostinternetConnection(
          retry: () {
            controller.getRegisteredContacts();
          },
          messgae: controller.responseError.value.toString(),
        );
      }
      if (controller.contactLoading.value) {
        return callListUi(isLoading: true);
      }
      if (controller.allUserProfileData.isEmpty) {
        return DataEmpty_AssetsIcon(assetspath: Assets.images.notFount.path);
      }
      return callListUi(
        contactData: controller.filteredUsers,
        isLoading: false,
      );
    });
  }

  Widget callListUi({List<UserListData>? contactData, bool isLoading = false}) {
    final bool loading = isLoading || contactData == null;
    return Skeletonizer(
      enabled: loading,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 120.h),
        itemCount: loading ? 8 : contactData.length,
        itemBuilder: (context, index) {
          if (loading) {
            return SkeletonContactRow();
          }
          return _ContactRow(
            user: contactData[index],
            onTapAudio: () {
              CallService().startCall(
                context,
                callerId:
                    Global.storageServices.get(PrefConst.userId).toString(),
                remoteUserId: contactData[index].userId.toString(),
                is_video: false,
                callerName: contactData[index].name.toString(),
              );
            },
            onTapVideo: () {
              CallService().startCall(
                context,
                callerId:
                    Global.storageServices.get(PrefConst.userId).toString(),
                remoteUserId: contactData[index].userId.toString(),
                is_video: true,
                callerName: contactData[index].name.toString(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _ContactRow(
      {required final UserListData user,
      required void Function() onTapAudio,
      required void Function() onTapVideo}) {
    final String? avatar = user.profileImage;
    final bool hasAvatar = avatar != null && avatar.isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: hasAvatar
                ? NetworkImage(ConstRes.aImageBaseUrl + avatar)
                : null,
            child: hasAvatar
                ? null
                : reausabletext(
                    (user.name?.isNotEmpty == true ? user.name![0] : '?')
                        .toUpperCase(),
                    fontsize: 16.sp,
                    fontfamily: FontFamily.interBold,
                    color: const Color(0xFF6B4DFF),
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  user.name ?? '',
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interSemiBold,
                  color: Colors.black87,
                ),
                SizedBox(height: 3.h),
                reausabletext(
                  user.mobileNo ?? '',
                  fontsize: 11.sp,
                  color: const Color(0xFF6B4DFF).withOpacity(0.7),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: onTapVideo,
            child: CallActionChip(
              icon: Icons.videocam_rounded,
            ),
          ),
          SizedBox(width: 10.w),
          InkWell(
            onTap: onTapAudio,
            child: CallActionChip(icon: Icons.call_rounded),
          ),
        ],
      ),
    );
  }
}

class SkeletonContactRow extends StatelessWidget {
  const SkeletonContactRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          CircleAvatar(radius: 22.r, backgroundColor: Colors.grey.shade200),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Loading contact",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interSemiBold,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  "Loading number",
                  style: TextStyle(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          CallActionChip(icon: Icons.videocam_rounded),
          SizedBox(width: 10.w),
          CallActionChip(icon: Icons.call_rounded),
        ],
      ),
    );
  }
}
