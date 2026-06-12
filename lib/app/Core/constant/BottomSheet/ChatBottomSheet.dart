import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/themes_data.dart';
import '../../../global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:get/get.dart';

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
    required VoidCallback onVideo,
    required VoidCallback onDocument,
    required VoidCallback onContact,
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
                  Center(
                    child: reausabletext(
                      "Upload File",
                      fontsize: 18,
                      fontfamily: FontFamily.interBold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      rowFile(
                          title: "Gallery",
                          icon: Icons.browse_gallery,
                          iconColor: Colors.blue,
                          onTap: onGallery),
                      rowFile(
                        title: "Video",
                        icon: Icons.videocam_outlined,
                        iconColor: Colors.purple,
                        onTap: onVideo,
                      ),
                      rowFile(
                        title: "Document",
                        icon: Icons.file_copy_outlined,
                        iconColor: Colors.deepPurple,
                        onTap: onDocument,
                      ),
                      rowFile(
                        title: "Contact",
                        icon: Icons.person,
                        iconColor: Colors.grey,
                        onTap: onContact,
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
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
                color: color.withOpacity(0.12),
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
