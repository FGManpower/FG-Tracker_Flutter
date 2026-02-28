import 'dart:developer';

import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../gen/fonts.gen.dart';
import 'About.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: reusableAppbar("About", ontap: () => Navigator.pop(context)),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          RowWidget(
              title: "About Us",
              ontap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const About(),
                    ));
              }),



          RowWidget(
              title: "Privacy Policy",
            ontap: () async {
              try {
                final Uri url = Uri.parse(
                    'https://www.fgmanpower.co.in/privacy-policy/');
                if (!await launchUrl(
                    url)) {
                  debugPrint(
                      'Could not launch $url');
                }
              } catch (e) {
                log(e.toString());
              }
            },),

          RowWidget(
              title: "Terms & Conditions",
              ontap: () async {
                try {
                  final Uri url = Uri.parse(
                      'https://www.fgmanpower.co.in/terms-conditions/');
                  if (!await launchUrl(
                      url)) {
                    debugPrint(
                        'Could not launch $url');
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
            reausabletext(title,
                fontfamily: FontFamily.interMedium, fontsize: 12),
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
