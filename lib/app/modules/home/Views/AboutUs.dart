import 'dart:developer';

import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../gen/fonts.gen.dart';
import 'About.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';
class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(backgroundColor: Colors.white,
      appBar: reusableAppbar(l10n.about_title, ontap: () => Navigator.pop(context)),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          RowWidget(
              title: l10n.about_aboutUs,
              ontap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const About(),
                    ));
              }),



          RowWidget(
            title: l10n.about_contactUs,
            ontap: () async {
              try {
                final Uri url =
                    Uri.parse('https://www.fgmanpower.co.in/contact/');
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  AppLog.d('Could not launch $url');
                }
              } catch (e) {
                log(e.toString());
              }
            },
          ),

          RowWidget(
            title: l10n.about_privacyPolicy,
            ontap: () async {
              try {
                final Uri url = Uri.parse(
                    'https://www.fgmanpower.co.in/privacy-policy/');
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  AppLog.d('Could not launch $url');
                }
              } catch (e) {
                log(e.toString());
              }
            },
          ),

          RowWidget(
            title: l10n.about_termsConditions,
            ontap: () async {
              try {
                final Uri url = Uri.parse(
                    'https://www.fgmanpower.co.in/terms-conditions/');
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  AppLog.d('Could not launch $url');
                }
              } catch (e) {
                log(e.toString());
              }
            },
          ),

        ],
      ),
    );
  }

  Widget RowWidget({required String title, required void Function() ontap}) {
    return InkWell(
      onTap: ontap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: AutoFitText(title,
                  style: TextStyle(
                      fontFamily: FontFamily.interMedium, fontSize: 12.sp)),
            ),
            reausableIcon(
              icon: Icons.arrow_forward_ios_rounded,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}
