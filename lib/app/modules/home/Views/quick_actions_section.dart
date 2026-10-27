import 'package:fgtracker/app/modules/Messages/Views/new_chat_screen.dart';
import 'package:fgtracker/app/modules/Track/Views/Tracking_screen.dart';
import 'package:fgtracker/app/modules/call/Views/call_screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Messages/Views/chatlist_screen.dart';
// import '../../Safe_Zone/views/safety_dashboard_view.dart';
import 'package:fgtracker/features/safety/coming_soon/safety_coming_soon_map_screen.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/Data/Services/notification_marker_service.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1F70).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE9ECF4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.bolt_rounded,
                    color: const Color(0xFF6B4DFF),
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontFamily: FontFamily.interBold,
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10153D),
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Everything you need, one tap away.",
                    style: TextStyle(
                      fontFamily: FontFamily.interRegular,
                      fontSize: 10.sp,
                      color: const Color(0xFF7E84A3),
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 6.h),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6.h,
            crossAxisSpacing: 8.w,
            childAspectRatio: 0.98,
            children: [
              _QuickActionCard(
                title: "All contact ",
                imagePath: "assets/icons/new_action_group_chat.png",
                onTap: () =>
                    Get.to(() => const NewChatScreen(fromQuickAction: true)),
              ),
              Obx(() => _QuickActionCard(
                title: "Audio/Video Call",
                imagePath: "assets/icons/new_action_call.png",
                showBadge:
                    NotificationMarkerService.instance.hasCallingMarker.value,
                badgeColor: const Color(0xFFEF4444),
                onTap: () => Get.to(() => CallScreen()),
              )),
              Obx(() => _QuickActionCard(
                title: "Chatting",
                imagePath: "assets/icons/new_action_chat.png",
                showBadge:
                    NotificationMarkerService.instance.hasChattingMarker.value,
                badgeColor: const Color(0xFFEF4444),
                onTap: () => Get.to(() => ChatListScreen()),
              )),
              Obx(() {
                final homeController = Get.isRegistered<HomeController>()
                    ? Get.find<HomeController>()
                    : null;
                final subtitle = homeController?.walkieSubtitle ?? "1 hr free";
                final isExpired = homeController?.isWalkieTrialExpired ?? false;
                final isSubscribed = homeController?.isWalkieSubscribed ?? false;
                final hasWalkieBadge =
                    NotificationMarkerService.instance.hasWalkieMarker.value;

                return _QuickActionCard(
                  title: "Walkie Talkie",
                  subtitle: subtitle,
                  subtitleColor: isExpired
                      ? const Color(0xFFDC2626)
                      : (isSubscribed
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF5338EE)),
                  showBadge: hasWalkieBadge,
                  badgeColor: const Color(0xFFEF4444),
                  imagePath: "assets/icons/new_action_walkie_talkie.png",
                  onTap: () async {
                    await Get.toNamed(Routes.walkieTalkieTrialDetails);
                    homeController?.fetchInitializeData();
                  },
                );
              }),
              _QuickActionCard(
                title: "Tracking",
                imagePath: "assets/icons/new_action_tracking.png",
                onTap: () => Get.to(() => TrackingScreen()),
              ),
              _QuickActionCard(
                title: "Safe Zone",
                imagePath: "assets/icons/new_action_safe_zone.png",
                // onTap: () => Get.to(() => SafetyDashboardView()),
                onTap: () => Get.to(() => const SafetyComingSoonMapScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.imagePath,
    this.subtitle,
    this.subtitleColor,
    this.onTap,
    this.showBadge = false,
    this.badgeColor,
  });

  final String title;
  final String imagePath;
  final String? subtitle;
  final Color? subtitleColor;
  final VoidCallback? onTap;
  final bool showBadge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final bool isCallIcon = imagePath.contains('new_action_call');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B1F70).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE8E7F5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 62.w,
                        height: 62.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F3FE),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Transform.scale(
                            scale: isCallIcon ? 1.2 : 1.12,
                            child: Image.asset(
                              imagePath,
                              width: 54.w,
                              height: 54.w,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.apps_rounded,
                                  color: const Color(0xFF6B4DFF),
                                  size: 32.sp,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      if (showBadge)
                        Positioned(
                          top: 2.h,
                          right: 2.w,
                          child: Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: badgeColor ?? const Color(0xFFE53935),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (badgeColor ?? const Color(0xFFE53935))
                                      .withValues(alpha: 0.45),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamily.interSemiBold,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10153D),
                  height: 1.1,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 1.h),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FontFamily.interSemiBold,
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor ?? const Color(0xFF5338EE),
                    height: 1.0,
                  ),
                ),
              ],
              SizedBox(height: 2.h),
              Container(
                width: 14.w,
                height: 2.2.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF5338EE),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }
}
