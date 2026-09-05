import 'package:fgtracker/app/modules/auth/Controller/OtpController.dart';
import 'package:fgtracker/app/modules/auth/Auth_Widget/hexagon_badge.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPScreen extends GetView<OtpController> {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final String mobileNumber = args?["mobNo"] ?? "";
    final String countryCode = args?["countryCode"] ?? "+91";
    final String formattedMobile = countryCode.isNotEmpty
        ? (countryCode.startsWith('+')
            ? "$countryCode $mobileNumber"
            : "+$countryCode $mobileNumber")
        : "+$mobileNumber";

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7664F6),
              Color(0xFF8F7EF8),
              Color(0xFFD6CEFD),
              Color(0xFFF3F1FE),
            ],
            stops: [0.0, 0.35, 0.72, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20.h,
              right: -20.w,
              child: SizedBox(
                width: 190.w,
                height: 190.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      Assets.images.lock3d.path,
                      width: 170.w,
                      height: 170.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "OTP\nVerification",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontFamily.interBold,
                                        height: 1.15,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Container(
                                      width: 42.w,
                                      height: 3.5.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF5D47F1),
                                        borderRadius:
                                            BorderRadius.circular(2.r),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    SizedBox(
                                      width: 220.w,
                                      child: Text(
                                        "Please verify your identity by entering the One-Time Password (OTP) sent to your registered mobile number.",
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 13.sp,
                                          fontFamily: FontFamily.interRegular,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 25.h),
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topCenter,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 40.h),
                                    padding: EdgeInsets.only(
                                      left: 20.w,
                                      right: 20.w,
                                      top: 48.h,
                                      bottom: 26.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4B3FDD)
                                              .withValues(alpha: 0.12),
                                          blurRadius: 28,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Please enter the 4 digit code that sent to your",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF333333),
                                            fontSize: 13.sp,
                                            fontFamily: FontFamily.interRegular,
                                          ),
                                        ),
                                        SizedBox(height: 3.h),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: "mobile number ",
                                            style: TextStyle(
                                              color: const Color(0xFF333333),
                                              fontSize: 13.sp,
                                              fontFamily:
                                                  FontFamily.interRegular,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: formattedMobile,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xFF5D47F1),
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontFamily.interBold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 25.h),
                                        Center(
                                          child: PinCodeTextField(
                                            appContext: context,
                                            length: 4,
                                            controller:
                                                controller.otpController,
                                            focusNode: controller.focusNode,
                                            animationType: AnimationType.fade,
                                            keyboardType: TextInputType.number,
                                            animationDuration: const Duration(
                                                milliseconds: 250),
                                            enableActiveFill: true,
                                            pinTheme: PinTheme(
                                              shape: PinCodeFieldShape.box,
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              fieldHeight: 62.w,
                                              fieldWidth: 62.w,
                                              borderWidth: 1.2,
                                              activeColor:
                                                  const Color(0xFF5D47F1),
                                              inactiveColor:
                                                  const Color(0xFFDCD6FD),
                                              selectedColor:
                                                  const Color(0xFF5D47F1),
                                              activeFillColor: Colors.white,
                                              inactiveFillColor: Colors.white,
                                              selectedFillColor: Colors.white,
                                            ),
                                            textStyle: TextStyle(
                                              fontSize: 22.sp,
                                              color: const Color(0xFF1E1E2D),
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontFamily.interBold,
                                            ),
                                            onChanged: (value) => controller
                                                .otpErrorText.value = '',
                                            onCompleted: (otp) {},
                                          ),
                                        ),
                                        Obx(
                                          () => controller
                                                  .otpErrorText.value.isNotEmpty
                                              ? Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 6.h),
                                                  child: Text(
                                                    controller
                                                        .otpErrorText.value,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12.sp,
                                                      fontFamily: FontFamily
                                                          .interMedium,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                        SizedBox(height: 25.h),
                                        AuthGradientButton(
                                          label: "Verify Code",
                                          onTap: () => controller.veriefyOtp(),
                                        ),
                                        SizedBox(height: 25.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: const Color(0xFFE8E3FA),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w),
                                              child: Container(
                                                padding: EdgeInsets.all(5.w),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFEDE9FE),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.shield_rounded,
                                                  size: 14.sp,
                                                  color:
                                                      const Color(0xFF5D47F1),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: const Color(0xFFE8E3FA),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20.h),
                                        Obx(() {
                                          return controller
                                                      .resendSeconds.value >
                                                  0
                                              ? Text(
                                                  "Resend OTP in 00:${controller.resendSeconds.value.toString().padLeft(2, '0')}",
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.grey.shade600,
                                                    fontFamily:
                                                        FontFamily.interMedium,
                                                  ),
                                                )
                                              : Text.rich(
                                                  TextSpan(
                                                    text:
                                                        "Didn't get the code? ",
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: const Color(
                                                          0xFF555555),
                                                      fontFamily: FontFamily
                                                          .interRegular,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: "Resend It",
                                                        style: TextStyle(
                                                          fontSize: 13.sp,
                                                          color: const Color(
                                                              0xFF5D47F1),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: FontFamily
                                                              .interBold,
                                                        ),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap =
                                                                  controller
                                                                      .resendOtp,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                        }),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    child: HexagonBadge(
                                      child: CustomPaint(
                                        size: Size(34.w, 36.h),
                                        painter: _OtpPhoneIconPainter(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              SizedBox(height: 30.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpPhoneIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5D47F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 3, cy), width: 22, height: 32),
      const Radius.circular(5),
    );
    canvas.drawRRect(phoneRect, paint);

    canvas.drawLine(
      Offset(cx - 6, cy - 12),
      Offset(cx, cy - 12),
      paint..strokeWidth = 1.5,
    );

    final bubbleFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final bubbleStroke = Paint()
      ..color = const Color(0xFF5D47F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final bubblePath = Path();
    final bubbleRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 4, cy - 2), width: 17, height: 13),
      const Radius.circular(4),
    );
    bubblePath.addRRect(bubbleRRect);
    bubblePath.moveTo(cx - 1, cy + 3);
    bubblePath.lineTo(cx - 3, cy + 7);
    bubblePath.lineTo(cx + 2, cy + 4);

    canvas.drawPath(bubblePath, bubbleFill);
    canvas.drawPath(bubblePath, bubbleStroke);

    final dotPaint = Paint()
      ..color = const Color(0xFF5D47F1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + 1, cy - 2), 1.0, dotPaint);
    canvas.drawCircle(Offset(cx + 4, cy - 2), 1.0, dotPaint);
    canvas.drawCircle(Offset(cx + 7, cy - 2), 1.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
