import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/modules/OtpCharges/Controller/otp_charges_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// Colors from the design that are not (exactly) in AppColors
const Color _warnBg = Color(0xFFFFF4DE);
const Color _warnBorder = Color(0xFFF2C46D);
const Color _warnIcon = Color(0xFF8A5A00);
const Color _warnText = Color(0xFF5C3D00);
const Color _rowLabel = Color(0xFF4A4A4A);
const Color _divider = Color(0xFFF1F1F4);
const Color _shadow = Color.fromRGBO(16, 16, 64, 0.06);

const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

// Keeps the layout phone-sized on tablets / landscape
const double _maxContentWidth = 480;

class OtpChargesView extends GetView<OtpChargesController> {
  const OtpChargesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySecondaryBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
              child: Column(
                children: [
                  _header(),
                  SizedBox(height: 14.h),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _numberCard(),
                            SizedBox(height: 14.h),
                            _priceBlock(),
                            SizedBox(height: 14.h),
                            _warningBox(),
                            SizedBox(height: 14.h),
                            _breakupCard(),
                            SizedBox(height: 14.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _bottomBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Semantics(
          label: 'Back',
          button: true,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: controller.onBack,
            child: Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: const [
                  BoxShadow(color: _shadow, offset: Offset(0, 1), blurRadius: 6),
                ],
              ),
              child: Icon(Icons.chevron_left_rounded,
                  size: 24.sp, color: AppColors.darkText),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            'OTP Charges',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: FontFamily.interBold,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _numberCard() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryDarkblue, width: 2),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: AppColors.primaryDarkblue, shape: BoxShape.circle),
            child: Text(
              controller.countryCode.value,
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: FontFamily.interExtraBold,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Charges apply to',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                    color: AppColors.primarySecondaryElementText,
                  ),
                ),
                SizedBox(height: 2.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    controller.formattedPhone,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: FontFamily.interExtraBold,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: AppColors.darkText,
                      fontFeatures: _tabular,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${controller.countryName.value} (${controller.dialCode.value})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interSemiBold,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDarkblue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceBlock() {
    final total = controller.money(controller.totalPerOtp);
    final gstLabel = _gstLabel();
    return Semantics(
      container: true,
      excludeSemantics: true,
      label:
          'Each OTP costs ${_spokenRupees(controller.totalPerOtp)}, including $gstLabel percent GST',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          children: [
            Text(
              'Each OTP costs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: FontFamily.interMedium,
                color: AppColors.primarySecondaryElementText,
              ),
            ),
            SizedBox(height: 6.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                total,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 40.sp,
                  fontFamily: FontFamily.interExtraBold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1.1,
                  color: AppColors.darkText,
                  fontFeatures: _tabular,
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Including $gstLabel% GST',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontFamily: FontFamily.interRegular,
                color: AppColors.primarySecondaryElementText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _warningBox() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: _warnBg,
        border: Border.all(color: _warnBorder),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Icon(Icons.warning_amber_rounded,
                size: 16.sp, color: _warnIcon),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interRegular,
                  height: 1.5,
                  color: _warnText,
                ),
                children: const [
                  TextSpan(
                    text: 'Your first login was free.',
                    style: TextStyle(
                      fontFamily: FontFamily.interBold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' From now on, every OTP sent to your number, including resends, will be charged.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakupCard() {
    final gstLabel = _gstLabel();
    // Rows take 16 side padding so the total row can sit 8 wider on each side
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          _breakupRow(
              'OTP charge', controller.money(controller.otpCharge.value)),
          _breakupRow(
              'GST ($gstLabel%)', controller.money(controller.gstAmount)),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.authIconBgCircle,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total per OTP',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: FontFamily.interExtraBold,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  controller.money(controller.totalPerOtp),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: FontFamily.interExtraBold,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkblue,
                    fontFeatures: _tabular,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakupRow(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontFamily: FontFamily.interRegular,
                color: _rowLabel,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontFamily: FontFamily.interSemiBold,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
              fontFeatures: _tabular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    // Full-width Pay button, no white bar behind it
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Obx(() {
        final loading = controller.isLoading.value;
        return Semantics(
          button: true,
          enabled: !loading,
          excludeSemantics: true,
          label: 'Pay ${_spokenRupees(controller.totalPerOtp)}',
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: loading ? null : controller.onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkblue,
                disabledBackgroundColor:
                    AppColors.primaryDarkblue.withValues(alpha: 0.6),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: loading
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Pay ${controller.money(controller.totalPerOtp)}',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontFamily: FontFamily.interBold,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFeatures: _tabular,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.arrow_forward_rounded,
                              size: 18.sp, color: Colors.white),
                        ],
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }

  /// 18.0 → "18", 12.5 → "12.5"
  String _gstLabel() {
    final gst = controller.gstPercent.value;
    return gst == gst.roundToDouble()
        ? gst.toInt().toString()
        : gst.toStringAsFixed(1);
  }

  /// 2.36 → "2 rupees 36 paise"
  static String _spokenRupees(double v) {
    final paiseTotal = (v * 100).round();
    final rupees = paiseTotal ~/ 100;
    final paise = paiseTotal % 100;
    final r = '$rupees ${rupees == 1 ? 'rupee' : 'rupees'}';
    return paise == 0 ? r : '$r $paise paise';
  }
}
