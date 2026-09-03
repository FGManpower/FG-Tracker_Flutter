import 'package:country_code_picker/country_code_picker.dart';
import 'package:fgtracker/app/modules/auth/Controller/login_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<Login_Controller> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
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
                          "Welcome\nBack! 👋",
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
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Great to see you again.\nLog in to access your account\nand explore our latest features.",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13.sp,
                            fontFamily: FontFamily.interRegular,
                            height: 1.4,
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
                          bottom: 30.h,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Log In",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontFamily.interBold,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              "to Continue",
                              style: TextStyle(
                                color: const Color(0xFF5D47F1),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: FontFamily.interBold,
                              ),
                            ),
                            SizedBox(height: 28.h),
                            Form(
                              key: controller.loginKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPhoneInputField(),
                                  Obx(
                                    () => controller
                                            .mobileErrorText.value.isNotEmpty
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                                left: 10.w, top: 8.h),
                                            child: Text(
                                              controller.mobileErrorText.value,
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12.sp,
                                                fontFamily:
                                                    FontFamily.interMedium,
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  SizedBox(height: 28.h),
                                  _buildGradientLoginButton(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: _HexagonBadge(
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 34.sp,
                            color: const Color(0xFF5D47F1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25.h),
                  _buildBottomSecurityBadge(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: const Color(0xFFDCD6FD),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          CountryCodePicker(
            onChanged: (country) {
              controller.selectedDialCode = country.dialCode ?? '+91';
            },
            initialSelection: 'IN',
            favorite: const ['+91', 'IN'],
            showFlagDialog: true,
            showFlagMain: true,
            flagWidth: 20.sp,
            textStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontFamily: FontFamily.interMedium,
            ),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
          ),
          Container(
            height: 24.h,
            width: 1.w,
            color: const Color(0xFFDCD6FD),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.call_rounded,
            color: const Color(0xFF5D47F1),
            size: 19.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextFormField(
              focusNode: controller.phoneFocusNode,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(
                fontSize: 14.5.sp,
                fontFamily: FontFamily.interMedium,
                color: Colors.black,
              ),
              controller: controller.mobNoController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              maxLength: 15,
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: 'Enter Mobile Number',
                hintStyle: TextStyle(
                  fontSize: 13.5.sp,
                  color: const Color(0xFF9E9EAF),
                  fontFamily: FontFamily.interRegular,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) {
                controller.mobileErrorText.value = '';
              },
              onFieldSubmitted: (_) {
                controller.phoneFocusNode.unfocus();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientLoginButton() {
    return InkWell(
      onTap: () async {
        controller.login();
      },
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6E56F8),
              Color(0xFF533EF0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF533EF0).withValues(alpha: 0.38),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              "Log In to Continue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                fontFamily: FontFamily.interBold,
              ),
            ),
            Positioned(
              right: 20.w,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSecurityBadge() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerRight,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: 13.h,
            bottom: 13.h,
            left: 18.w,
            right: 70.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4B3FDD).withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                color: const Color(0xFF5D47F1),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interMedium,
                  ),
                  children: [
                    const TextSpan(text: "Your data is "),
                    TextSpan(
                      text: "100% ",
                      style: TextStyle(
                        color: const Color(0xFF5D47F1),
                        fontWeight: FontWeight.bold,
                        fontFamily: FontFamily.interBold,
                      ),
                    ),
                    const TextSpan(text: "secure"),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 4.w,
          top: -22.h,
          child: Image.asset(
            'assets/images/lock_3d.png',
            height: 64.h,
            width: 64.w,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _HexagonBadge extends StatelessWidget {
  final Widget child;
  const _HexagonBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76.w,
      height: 84.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(76.w, 84.h),
            painter: _HexagonHaloPainter(),
          ),
          CustomPaint(
            size: Size(64.w, 72.h),
            painter: _HexagonCardPainter(),
            child: SizedBox(
              width: 64.w,
              height: 72.h,
              child: Center(child: child),
            ),
          ),
        ],
      ),
    );
  }
}

Path _buildRoundedHexagonPath(Size size, double cornerRadius) {
  final double w = size.width;
  final double h = size.height;
  final double cx = w / 2;
  final double cy = h / 2;

  final List<Offset> vertices = [
    Offset(cx, 0),
    Offset(w, cy * 0.5),
    Offset(w, h - cy * 0.5),
    Offset(cx, h),
    Offset(0, h - cy * 0.5),
    Offset(0, cy * 0.5),
  ];

  final Path path = Path();
  final int count = vertices.length;

  for (int i = 0; i < count; i++) {
    final Offset prev = vertices[(i - 1 + count) % count];
    final Offset curr = vertices[i];
    final Offset next = vertices[(i + 1) % count];

    final Offset dirPrev = (prev - curr);
    final double distPrev = dirPrev.distance;
    final Offset pPrev =
        curr + dirPrev * (cornerRadius.clamp(0.0, distPrev * 0.45) / distPrev);

    final Offset dirNext = (next - curr);
    final double distNext = dirNext.distance;
    final Offset pNext =
        curr + dirNext * (cornerRadius.clamp(0.0, distNext * 0.45) / distNext);

    if (i == 0) {
      path.moveTo(pPrev.dx, pPrev.dy);
    } else {
      path.lineTo(pPrev.dx, pPrev.dy);
    }
    path.quadraticBezierTo(curr.dx, curr.dy, pNext.dx, pNext.dy);
  }
  path.close();
  return path;
}

class _HexagonHaloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildRoundedHexagonPath(size, 14);

    final shadowPaint = Paint()
      ..color = const Color(0xFF5D47F1).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path.shift(const Offset(0, 5)), shadowPaint);

    final auraPaint = Paint()
      ..color = const Color(0xFFF0ECFD)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, auraPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HexagonCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildRoundedHexagonPath(size, 11);

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFE8E2FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
