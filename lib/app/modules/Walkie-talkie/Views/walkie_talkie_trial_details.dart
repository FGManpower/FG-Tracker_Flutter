import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_group_select_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/app/global_widget/blend_mask.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WalkieTalkieTrialDetailsScreen extends StatefulWidget {
  const WalkieTalkieTrialDetailsScreen({super.key});

  @override
  State<WalkieTalkieTrialDetailsScreen> createState() =>
      _WalkieTalkieTrialDetailsScreenState();
}

class _WalkieTalkieTrialDetailsScreenState
    extends State<WalkieTalkieTrialDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FE),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 4.h),
              _buildHeroGraphic(),
              SizedBox(height: 10.h),
              _buildHeadingSection(),
              SizedBox(height: 12.h),
              _buildFreeTrialStatusCard(),
              SizedBox(height: 10.h),
              _buildFeaturesAndCtaCard(context),
              SizedBox(height: 10.h),
              _buildPurchasePlanCard(),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF6F8FE),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 65.h,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20.sp,
                color: const Color(0xFF6B4DFF),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                reausabletext(
                  "Walkie Talkie",
                  fontsize: 18.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                SizedBox(height: 2.h),
                reausabletext(
                  "Instantly communicate with your group",
                  fontsize: 11.5.sp,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGraphic() {
    return Container(
      width: double.infinity,
      height: 250.h.clamp(220.0, 280.0),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Center(
        child: BlendMask(
          blendMode: BlendMode.multiply,
          child: Assets.walkieTalkie.walkieTrialHero.image(
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildHeadingSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          reausabletext(
            "Stay Connected, Talk Instantly",
            fontsize: 17.5.sp,
            fontfamily: FontFamily.interBold,
            color: const Color(0xFF1E1B4B),
            align: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            "Use push-to-talk voice communication with your group without making a phone call.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: const Color(0xFF6B7280),
              fontFamily: FontFamily.interRegular,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeTrialStatusCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFFF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: BlendMask(
                  blendMode: BlendMode.multiply,
                  child: Assets.walkieTalkie.walkieTrialGift.image(
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    reausabletext(
                      "FREE TRIAL",
                      fontsize: 13.sp,
                      fontfamily: FontFamily.interBold,
                      color: const Color(0xFF1E1B4B),
                    ),
                    SizedBox(height: 2.h),
                    reausabletext(
                      "1 Hour Free",
                      fontsize: 14.5.sp,
                      fontfamily: FontFamily.interBold,
                      color: const Color(0xFF5B4DFF),
                    ),
                    SizedBox(height: 2.h),
                    reausabletext(
                      "Use your 1-hour trial anytime within 7 days.",
                      fontsize: 11.5.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFE),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFEFF0F6)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    reausabletext(
                      "Trial Usage",
                      fontsize: 12.sp,
                      fontfamily: FontFamily.interMedium,
                      color: const Color(0xFF1E1B4B),
                    ),
                    reausabletext(
                      "0:00 / 1:00:00",
                      fontsize: 12.sp,
                      fontfamily: FontFamily.interSemiBold,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 6.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 12.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B4DFF),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EFFF),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Icon(
                            Icons.hourglass_empty_rounded,
                            size: 13.sp,
                            color: const Color(0xFF6B4DFF),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        reausabletext(
                          "7 Days Trial Period",
                          fontsize: 11.5.sp,
                          fontfamily: FontFamily.interMedium,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ],
                    ),
                    reausabletext(
                      "Expires in 7 days",
                      fontsize: 11.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesAndCtaCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 2x2 grid features
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.mic_rounded,
                  title: "Push-to-talk\ncommunication",
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.touch_app_rounded,
                  title: "Hold to talk",
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.groups_rounded,
                  title: "Quick group\ncommunication",
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.group_work_rounded,
                  title: "Easy group\ncoordination",
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Start Free Trial Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B4DFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              onPressed: () {
                _showStartFreeTrialBottomSheet(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  reausabletext(
                    "Start Free Trial",
                    fontsize: 15.sp,
                    fontfamily: FontFamily.interBold,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFFF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6B4DFF),
            size: 19.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: FontFamily.interMedium,
              color: const Color(0xFF1E1B4B),
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchasePlanCard() {
    return GestureDetector(
      onTap: () {
        Get.to(() => const WalkieTalkiePlanDetails(initialTabIndex: 0));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFFF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: BlendMask(
              blendMode: BlendMode.multiply,
              child: Assets.walkieTalkie.walkieTrialCrown.image(
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  "After your free trial",
                  fontsize: 10.5.sp,
                  color: const Color(0xFF6B7280),
                ),
                SizedBox(height: 2.h),
                reausabletext(
                  "₹500 / person",
                  fontsize: 15.sp,
                  fontfamily: FontFamily.interBold,
                  color: const Color(0xFF1E1B4B),
                ),
                SizedBox(height: 2.h),
                reausabletext(
                  "Continue with Walkie Talkie",
                  fontsize: 10.5.sp,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => const WalkieTalkiePlanDetails(initialTabIndex: 0));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFF6B4DFF).withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: reausabletext(
                "Purchase for ₹500",
                fontsize: 12.sp,
                fontfamily: FontFamily.interSemiBold,
                color: const Color(0xFF5B4DFF),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  void _showStartFreeTrialBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 14.h),
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4B7CC),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reausabletext(
                          "Start Your Free Trial",
                          fontsize: 19.sp,
                          fontfamily: FontFamily.interBold,
                          color: const Color(0xFF1E1B4B),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Enjoy all Walkie Talkie features free for 1 hour.\nNo payment required.",
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF6B7280),
                            fontFamily: FontFamily.interRegular,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // 2 side-by-side trial highlight cards
              Row(
                children: [
                  Expanded(
                    child: _buildTrialHighlightCard(
                      icon: Icons.card_giftcard_rounded,
                      title: "1 Hour Free",
                      subtitle:
                          "Full access to all premium Walkie Talkie features",
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildTrialHighlightCard(
                      icon: Icons.hourglass_empty_rounded,
                      title: "Valid for 7 Days",
                      subtitle: "Use your 1-hour trial anytime within 7 days",
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              reausabletext(
                "What you can do during the trial",
                fontsize: 14.5.sp,
                fontfamily: FontFamily.interBold,
                color: const Color(0xFF1E1B4B),
              ),
              SizedBox(height: 10.h),
              // 2x2 Feature Boxes
              Row(
                children: [
                  Expanded(
                    child: _buildTrialMiniFeature(
                      icon: Icons.mic_rounded,
                      title: "Push-to-talk",
                      desc: "Instant voice\ncommunication",
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildTrialMiniFeature(
                      icon: Icons.groups_rounded,
                      title: "Group Communication",
                      desc: "Connect with your\nteam",
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTrialMiniFeature(
                      icon: Icons.graphic_eq_rounded,
                      title: "Clear Audio",
                      desc: "High quality\nvoice",
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildTrialMiniFeature(
                      icon: Icons.all_inclusive_rounded,
                      title: "Unlimited Usage",
                      desc: "Use without any\nlimits",
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              // Info banner
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFFF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: const Color(0xFF5B4DFF),
                      size: 20.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        "No payment needed now. After your trial, you can choose to continue with a paid plan (₹500/person) if you like.",
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF4338CA),
                          fontFamily: FontFamily.interMedium,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Start 1 Hour Free Trial Button
              SafeArea(
                top: false,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B4DFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Get.back();
                          Utils().fluttertoast("Free trial activated!");
                          Get.to(() => const WalkieGroupSelectScreen());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                            SizedBox(width: 8.w),
                            reausabletext(
                              "Start 1 Hour Free Trial",
                              fontsize: 15.sp,
                              fontfamily: FontFamily.interBold,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    reausabletext(
                      "Use anytime within 7 days  •  No credit card required",
                      fontsize: 11.sp,
                      color: const Color(0xFF6B7280),
                      align: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrialHighlightCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5FF),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE9E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: const BoxDecoration(
              color: Color(0xFFECEBFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6B4DFF),
              size: 18.sp,
            ),
          ),
          SizedBox(height: 10.h),
          reausabletext(
            title,
            fontsize: 13.sp,
            fontfamily: FontFamily.interBold,
            color: const Color(0xFF1E1B4B),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.5.sp,
              color: const Color(0xFF6B7280),
              fontFamily: FontFamily.interRegular,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialMiniFeature({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFE),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFEFF0F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFFF),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6B4DFF),
              size: 16.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: FontFamily.interRegular,
                    height: 1.2,
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

class _DashedLineConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6356F6).withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // 4 target avatar centers
    final nodeTL = Offset(size.width * 0.18, size.height * 0.22);
    final nodeBL = Offset(size.width * 0.18, size.height * 0.78);
    final nodeTR = Offset(size.width * 0.82, size.height * 0.22);
    final nodeBR = Offset(size.width * 0.82, size.height * 0.78);

    _drawDashedLine(canvas, nodeTL, center, paint);
    _drawDashedLine(canvas, nodeBL, center, paint);
    _drawDashedLine(canvas, nodeTR, center, paint);
    _drawDashedLine(canvas, nodeBR, center, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);
    final double steps = distance / (dashWidth + dashSpace);
    final double unitX = dx / distance;
    final double unitY = dy / distance;

    for (int i = 0; i < steps; i++) {
      final double startDist = i * (dashWidth + dashSpace);
      final double endDist = startDist + dashWidth;
      if (endDist > distance) break;

      canvas.drawLine(
        Offset(p1.dx + unitX * startDist, p1.dy + unitY * startDist),
        Offset(p1.dx + unitX * endDist, p1.dy + unitY * endDist),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
