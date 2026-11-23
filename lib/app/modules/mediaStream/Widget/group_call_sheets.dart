import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/group_participants_sheet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/theme/appTheme.dart';
import '../../../Core/values/utility.dart';
import '../../../global_widget/auto_fit_text.dart';
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
        color: const Color(0xFF1E262C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: Colors.white12, width: 0.8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Obx(() {
        if (sheetCtrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF25D366)),
          );
        }

        final inCall = sheetCtrl.inCallList.toList();
        final notIn = sheetCtrl.notInCallList.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Header title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Call Participants",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "${inCall.length} in call",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontFamily: FontFamily.interBold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // In-Call Section
            Text(
              context.l10n.call_inThisCall(inCall.length),
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: FontFamily.interMedium,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 10.h),
            if (inCall.isEmpty)
              Text(
                context.l10n.call_noActiveParticipants,
                style: TextStyle(fontSize: 13.sp, color: Colors.white38),
              )
            else
              SizedBox(
                height: 80.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: inCall.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (_, index) {
                    return _InCallChip(
                      participant: inCall[index],
                      key: ValueKey('in_${inCall[index].userId}'),
                    );
                  },
                ),
              ),
            SizedBox(height: 20.h),

            // Not In Call / Add Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.call_notInThisCall(notIn.length),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interMedium,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  "Tap to invite",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interRegular,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            Expanded(
              child: notIn.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.call_everyoneInCall,
                        style: TextStyle(fontSize: 14.sp, color: Colors.white38),
                      ),
                    )
                  : ListView.separated(
                      itemCount: notIn.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final participant = notIn[index];
                        final imageUrl =
                            Utility.isNullEmptyOrFalse(participant.profileImage)
                                ? MyAppTheme.ProfilenotFoundImg
                                : (participant.profileImage!.startsWith('http')
                                    ? participant.profileImage!
                                    : ConstRes.aImageBaseUrl +
                                        participant.profileImage!);

                        return Container(
                          key: ValueKey('out_${participant.userId}'),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A3942),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.white10, width: 0.6),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22.r,
                                backgroundColor: Colors.white12,
                                backgroundImage: NetworkImage(imageUrl),
                                onBackgroundImageError: (_, __) {},
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      participant.name ?? '',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: FontFamily.interMedium,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      context.l10n.call_tapNotifyToInvite,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => sheetCtrl.notify(participant),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF25D366),
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF25D366).withOpacity(0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.phone_forwarded_rounded,
                                        color: Colors.black,
                                        size: 15.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        "Ring",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: FontFamily.interSemiBold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
        : (participant.profileImage!.startsWith('http')
            ? participant.profileImage!
            : ConstRes.aImageBaseUrl + participant.profileImage!);

    return Container(
      width: 145.w,
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3942),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10, width: 0.6),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.white12,
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (_, __) {},
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  participant.isLocal
                      ? context.l10n.call_nameYou(participant.name.toString())
                      : participant.name.toString(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interMedium,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Obx(
                  () => Row(
                    children: [
                      Icon(
                        participant.isMuted.value
                            ? Icons.mic_off_rounded
                            : Icons.volume_up_rounded,
                        size: 12.sp,
                        color: participant.isMuted.value
                            ? const Color(0xFFFF5252)
                            : const Color(0xFF25D366),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          participant.isMuted.value
                              ? context.l10n.call_muted
                              : context.l10n.call_inCall,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontFamily: FontFamily.interRegular,
                            color: participant.isMuted.value
                                ? const Color(0xFFFF5252)
                                : const Color(0xFF25D366),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
