import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/widgets/cutom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: reusableAppbar("About FG Tracker",
          ontap: () => Navigator.pop(context)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            reausabletext("Welcome to FG Tracker",
                fontsize: 20.sp,
                fontweight: FontWeight.bold,
                color: Colors.blueGrey),
            SizedBox(height: 10.h),
            reausabletext(
                "FG Tracker is your go-to companion for staying connected and secure while traveling in a group. Whether you're out on a family road trip, a picnic with friends, or just commuting with colleagues — FG Tracker makes sure no one gets left behind.",
                fontsize: 14.sp,
                height: 1.5.h),
            SizedBox(height: 20.h),
            _sectionTitle("🌟 Why Choose FG Tracker?"),
            _bulletPoint("Real-time location sharing with all group members."),
            _bulletPoint("No need to call or text—track live on the map."),
            _bulletPoint(
                "Easy to use and lightweight app with privacy control."),
            _bulletPoint("Built for families, friends, and small teams."),
            SizedBox(height: 20.h),
            _sectionTitle("⚙️ How It Works"),
            reausabletext(
              "FG Tracker simplifies group travel coordination. Here's how:",
              fontsize: 14.sp),

            SizedBox(height: 8.h),
            _numberedPoint(1, "Create a Group"),
            _numberedPoint(
                2, "Share the group code or QR code with your companions"),
            _numberedPoint(3, "Each member joins using the shared code or QR"),
            _numberedPoint(4,
                "Track everyone’s live location on a shared map in real-time"),
            _numberedPoint(5,
                "Use the sharing feature to invite more people effortlessly"),
            SizedBox(height: 20.h),
            _sectionTitle("🔐 Privacy & Security"),
            reausabletext(
              "Your safety and privacy matter. FG Tracker does not share your location with anyone outside your group. All data is encrypted and only shared with the people you authorize.",
              fontsize: 14.sp),

            SizedBox(height: 20.h),
            _sectionTitle("📩 Support & Developer Info"),
            _infoRow("Support Email", "fgmanpower786@gmail.com"),
            _infoRow("Developer Email", "developer.46solution@gmail.com"),
            _infoRow("Company", "FG Manpower LLP"),
            _infoRow("Address",
                "A3 Sri Sai Leela H Soc, Saki Vihar Rd, Sakinaka, Kurla West, Mumbai, Maharashtra 400072, India"),
            _infoRow("Website", "https://fgmanpower.in/"),
            SizedBox(height: 20.h),
            _sectionTitle("📱 Download App"),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 20.w,
              runSpacing: 20.h,
              alignment: WrapAlignment.center,
              children: [
                _buildStoreColumn(
                  imagePath: 'assets/images/playstore.jpeg',
                  linkText: "https://rb.gy/6e5p5u",
                ),
                _buildStoreColumn(
                  imagePath: 'assets/images/playstore.jpeg',
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
