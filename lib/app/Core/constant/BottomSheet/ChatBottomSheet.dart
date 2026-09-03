import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/themes_data.dart';
import '../../../global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

class ChatBottomSheet {
  static Future<void> showCallOptions(
      BuildContext context, {
        VoidCallback? onAudioCall,
        VoidCallback? onWalkieTalkieCall,
      }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.33,
          maxChildSize: 0.45,
          minChildSize: 0.25,
          builder: (_, controller) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 5.h,
                      margin: EdgeInsets.only(bottom: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  reausabletext(
                    "Call Options",
                    fontsize: 18,
                    fontfamily: FontFamily.interBold,
                  ),
                  SizedBox(height: 12.h),
                  _callTile(
                    context,
                    title: "Normal Audio Call",
                    subtitle: "Standard clear voice quality",
                    icon: Icons.call_outlined,
                    color: ToggleThemeData.darkPurple,
                    onTap: () {
                      Navigator.pop(context);
                      onAudioCall?.call();
                    },
                  ),
                  SizedBox(height: 8.h),
                  _callTile(
                    context,
                    title: "Walkie-Talkie Call",
                    subtitle: "Push-to-talk communication",
                    icon: Icons.record_voice_over_outlined,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      onWalkieTalkieCall?.call();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> showFileOptions(
      BuildContext context, {
        required VoidCallback onGallery,
        required VoidCallback onCamera,
        required VoidCallback onDocument,
        required VoidCallback onLocation,
        required VoidCallback onContact,
      }) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              SizedBox(height: 18.h),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Attach / Upload",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Share files and media with your team",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(sheetContext),
                    child: Container(
                      height: 32.w,
                      width: 32.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: const Color(0xFF5045B9),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22.h),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 0.85,
                children: [
                  _attachmentItem(
                    icon: Icons.image_rounded,
                    iconColor: const Color(0xFF7B61FF),
                    bgColor: const Color(0xFFF0EBFF),
                    title: "Gallery",
                    onTap: onGallery,
                  ),
                  _attachmentItem(
                    icon: Icons.camera_alt_rounded,
                    iconColor: const Color(0xFF22C55E),
                    bgColor: const Color(0xFFE8F9EF),
                    title: "Camera",
                    onTap: onCamera,
                  ),
                  _attachmentItem(
                    icon: Icons.description_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    bgColor: const Color(0xFFE8F1FF),
                    title: "Document",
                    onTap: onDocument,
                  ),
                  _attachmentItem(
                    icon: Icons.location_on_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    bgColor: const Color(0xFFE8F1FF),
                    title: "Location",
                    onTap: onLocation,
                  ),
                  _attachmentItem(
                    icon: Icons.person_rounded,
                    iconColor: const Color(0xFF7B61FF),
                    bgColor: const Color(0xFFF0EBFF),
                    title: "Contact",
                    onTap: onContact,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }

  static Widget _attachmentItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  static Widget rowFile(
      {required String title,
        required IconData icon,
        Color iconColor = Colors.black,
        required GestureTapCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(color: Colors.grey.shade300)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
              child: reausableIcon(icon: icon, size: 20, color: iconColor),
            ),
          ),
          SizedBox(
            height: 4.h,
          ),
          reausabletext(title, color: Colors.black, fontsize: 14),
        ],
      ),
    );
  }

  // static Future<void> showWalkieTalkie(
  //   BuildContext context,
  //   WalkieController wc,
  // ) async {
  //   return showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) {
  //       return Container(
  //         height: 420.h,
  //         width: double.maxFinite,
  //         padding: EdgeInsets.symmetric(horizontal: 20.w),
  //         decoration: BoxDecoration(
  //           color: const Color(0xFF0E0F14),
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
  //         ),
  //         child: Column(
  //           children: [
  //             Container(
  //               margin: EdgeInsets.symmetric(vertical: 12.h),
  //               width: 42.w,
  //               height: 5.h,
  //               decoration: BoxDecoration(
  //                 color: Colors.white24,
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //             reausabletext(
  //               "Walkie-Talkie",
  //               fontsize: 20,
  //               color: Colors.white,
  //               fontfamily: FontFamily.interBold,
  //             ),
  //             SizedBox(height: 6.h),
  //             Obx(() {
  //               String text;
  //               Color color;
  //
  //               switch (wc.status.value) {
  //                 case WalkieStatus.talking:
  //                   text = "TRANSMITTING";
  //                   color = Colors.greenAccent;
  //                   break;
  //                 case WalkieStatus.listening:
  //                   text = "LISTENING";
  //                   color = Colors.blueAccent;
  //                   break;
  //                 default:
  //                   text = "READY";
  //                   color = Colors.white54;
  //               }
  //
  //               return Text(
  //                 text,
  //                 style: TextStyle(
  //                   color: color,
  //                   fontSize: 13.sp,
  //                   letterSpacing: 1.3,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               );
  //             }),
  //             const Spacer(),
  //             Obx(() {
  //               final isTalking = wc.status.value == WalkieStatus.talking;
  //
  //               return GestureDetector(
  //                 onTapDown: (_) => wc.startTalking(),
  //                 onTapUp: (_) => wc.stopTalking(),
  //                 onTapCancel: wc.stopTalking,
  //                 child: AnimatedContainer(
  //                   duration: const Duration(milliseconds: 160),
  //                   height: isTalking ? 150.w : 130.w,
  //                   width: isTalking ? 150.w : 130.w,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     color:
  //                         isTalking ? Colors.greenAccent : Colors.grey.shade800,
  //                     boxShadow: isTalking
  //                         ? [
  //                             BoxShadow(
  //                               color: Colors.greenAccent.withOpacity(0.6),
  //                               blurRadius: 30,
  //                               spreadRadius: 6,
  //                             )
  //                           ]
  //                         : [],
  //                   ),
  //                   child: Icon(
  //                     Icons.mic_rounded,
  //                     size: 60,
  //                     color: isTalking ? Colors.black : Colors.white70,
  //                   ),
  //                 ),
  //               );
  //             }),
  //             SizedBox(height: 30.h),
  //             Obx(() => Text(
  //                   wc.status.value == WalkieStatus.talking
  //                       ? "Release to stop talking"
  //                       : "Press & hold to talk",
  //                   style: TextStyle(
  //                     color: Colors.white38,
  //                     fontSize: 14.sp,
  //                   ),
  //                 )),
  //             SizedBox(height: 24.h),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  static Widget _callTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reausabletext(
                    title,
                    fontsize: 15,
                    fontweight: FontWeight.w600,
                  ),
                  SizedBox(height: 2.h),
                  reausabletext(
                    subtitle,
                    fontsize: 12,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16.sp, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }
}