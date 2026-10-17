import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/group_participants_sheet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/theme/appTheme.dart';
import '../../../Core/values/utility.dart';
import '../../../global_widget/common_widget.dart';
import '../../../Model/group_call_participant.dart';

class GroupParticipantsSheet {
  static const String _tag = 'group_participants_sheet';

  static Future<void> show(GroupCallingController callController) {
    if (Get.isRegistered<GroupParticipantsSheetController>(tag: _tag)) {
      Get.delete<GroupParticipantsSheetController>(tag: _tag);
    }

    final sheetCtrl = Get.put(
      GroupParticipantsSheetController(callController),
      tag: _tag,
    );

    return Get.bottomSheet(
      _GroupParticipantsSheetView(sheetCtrl: sheetCtrl),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
    ).whenComplete(() {
      if (Get.isRegistered<GroupParticipantsSheetController>(tag: _tag)) {
        Get.delete<GroupParticipantsSheetController>(tag: _tag);
      }
    });
  }
}

class _GroupParticipantsSheetView extends StatelessWidget {
  const _GroupParticipantsSheetView({required this.sheetCtrl});

  final GroupParticipantsSheetController sheetCtrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.75,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Obx(() {
        if (sheetCtrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6E5CA4)),
          );
        }

        final inCall = sheetCtrl.inCallList.toList();
        final notIn = sheetCtrl.notInCallList.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            reausabletext(
              'In this call (${inCall.length})',
              fontsize: 16,
              fontfamily: FontFamily.interSemiBold,
              color: const Color(0xFF1E1147),
            ),
            SizedBox(height: 10.h),
            if (inCall.isEmpty)
              reausabletext(
                'No active participants',
                fontsize: 13,
                color: Colors.grey,
              )
            else
              SizedBox(
                height: 84.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: inCall.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (_, index) {
                    return _InCallChip(
                      participant: inCall[index],
                      key: ValueKey('in_${inCall[index].userId}'),
                    );
                  },
                ),
              ),
            SizedBox(height: 18.h),
            reausabletext(
              'Not in this call (${notIn.length})',
              fontsize: 16,
              fontfamily: FontFamily.interSemiBold,
              color: const Color(0xFF1E1147),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: notIn.isEmpty
                  ? Center(
                      child: reausabletext(
                        'Everyone is already in the call',
                        fontsize: 14,
                        color: Colors.grey,
                      ),
                    )
                  : ListView.separated(
                      itemCount: notIn.length,
                      separatorBuilder: (_, __) => SizedBox(height: 14.h),
                      itemBuilder: (context, index) {
                        final participant = notIn[index];
                        final imageUrl =
                            Utility.isNullEmptyOrFalse(participant.profileImage)
                                ? MyAppTheme.ProfilenotFoundImg
                                : ConstRes.aImageBaseUrl +
                                    (participant.profileImage ?? '');

                        return Row(
                          key: ValueKey('out_${participant.userId}'),
                          children: [
                            CircleAvatar(
                              radius: 24.r,
                              backgroundColor: Colors.black12,
                              backgroundImage: NetworkImage(imageUrl),
                              onBackgroundImageError: (_, __) {},
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  reausabletext(
                                    participant.name ?? '',
                                    fontsize: 15,
                                    fontfamily: FontFamily.interMedium,
                                    color: const Color(0xFF1E1147),
                                  ),
                                  SizedBox(height: 2.h),
                                  reausabletext(
                                    'Tap notify to invite',
                                    fontsize: 12,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                              child: InkWell(
                                onTap: () => sheetCtrl.notify(participant),
                                borderRadius: BorderRadius.circular(20.r),
                                splashColor: const Color(0xFF6E5CA4).withValues(alpha: 0.15),
                                highlightColor: const Color(0xFF6E5CA4).withValues(alpha: 0.10),
                                child: Ink(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9E5FE),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.notifications_active,
                                        color: Color(0xFF6E5CA4),
                                        size: 18,
                                      ),
                                      SizedBox(width: 6.w),
                                      reausabletext(
                                        'Notify',
                                        fontsize: 12,
                                        fontfamily: FontFamily.interSemiBold,
                                        color: const Color(0xFF6E5CA4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _InCallChip extends StatelessWidget {
  const _InCallChip({super.key, required this.participant});

  final GroupCallParticipant participant;

  @override
  Widget build(BuildContext context) {
    final imageUrl = Utility.isNullEmptyOrFalse(participant.profileImage)
        ? MyAppTheme.ProfilenotFoundImg
        : ConstRes.aImageBaseUrl + (participant.profileImage ?? '');

    return Container(
      width: 150.w,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (_, __) {},
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                reausabletext(
                  participant.isLocal
                      ? '${participant.name} (You)'
                      : participant.name.toString(),
                  fontsize: 12,
                  fontfamily: FontFamily.interMedium,
                  maxline: 1,
                ),
                Obx(
                  () => reausabletext(
                    participant.isMuted.value ? 'Muted' : 'In call',
                    fontsize: 11,
                    color: participant.isMuted.value
                        ? Colors.redAccent
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
