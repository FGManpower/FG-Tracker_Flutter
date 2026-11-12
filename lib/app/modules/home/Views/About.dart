import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(backgroundColor: Colors.white,
      appBar: reusableAppbar(l10n.about_appBarTitle,
          ontap: () => Navigator.pop(context)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            reausabletext(l10n.about_welcomeTitle,
                fontsize: 20.sp,
                fontweight: FontWeight.bold,
                color: Colors.blueGrey),
            SizedBox(height: 10.h),
            reausabletext(
                l10n.about_intro,
                fontsize: 14.sp,
                height: 1.5.h),
            SizedBox(height: 20.h),
            _sectionTitle(l10n.about_whyChooseTitle),
            _bulletPoint(l10n.about_whyRealTime),
            _bulletPoint(l10n.about_whyNoCalls),
            _bulletPoint(l10n.about_whyEasy),
            _bulletPoint(l10n.about_whyBuiltFor),
            SizedBox(height: 20.h),
            _sectionTitle(l10n.about_howItWorksTitle),
            reausabletext(
              l10n.about_howItWorksIntro,
              fontsize: 14.sp),

            SizedBox(height: 8.h),
            _numberedPoint(1, l10n.about_howStep1),
            _numberedPoint(2, l10n.about_howStep2),
            _numberedPoint(3, l10n.about_howStep3),
            _numberedPoint(4, l10n.about_howStep4),
            _numberedPoint(5, l10n.about_howStep5),
            SizedBox(height: 20.h),
            _sectionTitle(l10n.about_privacyTitle),
            reausabletext(
              l10n.about_privacyBody,
              fontsize: 14.sp),

            SizedBox(height: 20.h),
            _sectionTitle(l10n.about_supportTitle),
            _infoRow(l10n.about_supportEmail, "fgmanpower786@gmail.com"),
            _infoRow(l10n.about_developerEmail, "developer.46solution@gmail.com"),
            _infoRow(l10n.about_company, "FG Manpower LLP"),
            _infoRow(l10n.about_address,
                "A3 Sri Sai Leela H Soc, Saki Vihar Rd, Sakinaka, Kurla West, Mumbai, Maharashtra 400072, India"),
            _infoRow(l10n.about_website, "https://fgmanpower.in/"),
            SizedBox(height: 20.h),
            _sectionTitle(l10n.about_downloadTitle),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 20.w,
              runSpacing: 20.h,
              alignment: WrapAlignment.center,
              children: [
                _buildStoreColumn(
                  imagePath: Assets.images.playstore.path,
                  linkText: "https://rb.gy/6e5p5u",
                ),
                _buildStoreColumn(
                  imagePath: Assets.images.playstore.path,
                  linkText: "https://rb.gy/6e5p5u",
                ),
              ],
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          reausabletext("• ", fontsize: 16.sp),
          Expanded(child:  reausabletext(text, fontsize: 14.sp)),
        ],
      ),
    );
  }

  Widget _numberedPoint(int number, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          reausabletext("$number. ",
             fontsize: 14.sp, fontweight: FontWeight.bold),
          Expanded(child:  reausabletext(text, fontsize: 14.sp)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
Widget _buildStoreColumn({required String imagePath, required String linkText}) {
  return Column(
    children: [
      Container(
        height: 120.h,
        width: 120.w,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
      SizedBox(height: 8.h),
      SizedBox(
        width: 140.w, // Ensures text wraps
        child: GestureDetector(
          onTap: () {},
          child: Text(
            linkText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    ],
  );
}
