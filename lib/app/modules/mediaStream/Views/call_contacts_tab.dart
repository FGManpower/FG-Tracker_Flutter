import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_controller.dart';
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
  final CallController controller = CallController.instance;

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
    final int count = loading ? 8 : contactData.length;

    return RefreshIndicator(
      color: const Color(0xFF4818F0),
      onRefresh: controller.refreshContacts,
      child: Skeletonizer(
        enabled: loading,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 90.h),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (int index = 0; index < count; index++) ...[
                    if (index > 0)
                      Divider(
                        height: 1,
                        thickness: 0.8,
                        color: const Color(0xFFF1F3F9),
                        indent: 62.w,
                        endIndent: 14.w,
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      child: loading
                          ? const SkeletonContactRow()
                          : _ContactRow(
                              user: contactData[index],
                              onTapAudio: () {
                                CallService().startCall(
                                  context,
                                  callerId: Global.storageServices
                                      .get(PrefConst.userId)
                                      .toString(),
                                  remoteUserId:
                                      contactData[index].userId.toString(),
                                  is_video: false,
                                  callerName:
                                      contactData[index].name.toString(),
                                );
                              },
                              onTapVideo: () {
                                CallService().startCall(
                                  context,
                                  callerId: Global.storageServices
                                      .get(PrefConst.userId)
                                      .toString(),
                                  remoteUserId:
                                      contactData[index].userId.toString(),
                                  is_video: true,
                                  callerName:
                                      contactData[index].name.toString(),
                                );
                              },
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ContactRow({
    required final UserListData user,
    required void Function() onTapAudio,
    required void Function() onTapVideo,
  }) {
    final String? avatar = user.profileImage;
    final String name = user.name ?? '';

    return Row(
      children: [
        _buildAvatar(name, avatar),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: FontFamily.interSemiBold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                user.mobileNo ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF6B4DFF),
                  fontFamily: FontFamily.interMedium,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        CallActionChip(
          icon: Icons.videocam_rounded,
          onTap: onTapVideo,
        ),
        SizedBox(width: 8.w),
        CallActionChip(
          icon: Icons.call_rounded,
          onTap: onTapAudio,
        ),
      ],
    );
  }

  String _buildAvatarUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    raw = raw.trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('/')) raw = raw.substring(1);
    return '${ConstRes.aImageBaseUrl}$raw';
  }

  Widget _buildAvatar(String name, String? avatar) {
    final String avatarUrl = _buildAvatarUrl(avatar);
    final String initial = (name.isNotEmpty ? name[0] : '?').toUpperCase();

    return ClipOval(
      child: Container(
        width: 42.w,
        height: 42.w,
        color: const Color(0xFFECEAFD),
        child: avatarUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: FontFamily.interBold,
                      color: const Color(0xFF4818F0),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: FontFamily.interBold,
                      color: const Color(0xFF4818F0),
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF4818F0),
                  ),
                ),
              ),
      ),
    );
  }
}

class SkeletonContactRow extends StatelessWidget {
  const SkeletonContactRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 21.r, backgroundColor: Colors.grey.shade200),
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
        const CallActionChip(icon: Icons.videocam_rounded),
        SizedBox(width: 8.w),
        const CallActionChip(icon: Icons.call_rounded),
      ],
    );
  }
}
