import 'dart:math';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Track/Widget/ToBitDescription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getCustomIcon(
    String imageUrl, dynamic isOnline) async {
  return MarkerWidget(imageUrl: imageUrl, isOnline: isOnline)
      .toBitmapDescriptor(
    logicalSize: Size(100.w, 120.h),
    imageSize: Size(200.w, 240.h), // high-res (2x)
  );
}

class MarkerWidget extends StatelessWidget {
  final String imageUrl;
  final dynamic isOnline;

  const MarkerWidget(
      {super.key, required this.imageUrl, required this.isOnline});

  Color get randomColor {
    final Random random =
        Random(imageUrl.hashCode); // consistent color for same user
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 120.h,
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Marker Pin
          Positioned(
            bottom: 0,
            child: Icon(
              Icons.location_pin,
              size: 100.sp,
              color: ToggleThemeData.Appcolor,
            ),
          ),

          Positioned(
            top: 35.h,
            child: Stack(
              children: [
                // Profile image
                // Container(
                //   width: 52.w,
                //   height: 52.w,
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Colors.grey,
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black12,
                //         blurRadius: 4,
                //       )
                //     ],
                //   ),
                //   child: ClipOval(
                //     child: CachedNetworkImage(
                //       imageUrl: Utility.isNotNullEmptyOrFalse(imageUrl)
                //           ? ConstRes.aImageBaseUrl + imageUrl
                //           : MyAppTheme.notFoundImg,
                //       fit: BoxFit.cover,
                //       placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
                //       errorWidget: (context, url, error) {
                //         print('Image failed to load: $url, error: $error');
                //         return Icon(Icons.person, size: 30.sp);
                //       },
                //     ),
                //   ),
                //
                // ),
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // to distinguish background
                    border: Border.all(color: Colors.red, width: 1), // add border for visibility
                  ),
                  child: ClipOval(
                    child: Image.network(
                      ConstRes.aImageBaseUrl + imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print("❌ Image load error: ${ConstRes.aImageBaseUrl + imageUrl}");
                        return Icon(Icons.person, size: 30.sp);
                      },
                    ),
                  ),

                ),

                // Online/Offline Dot
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline ? Colors.green : Colors.green,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
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


Widget buildNavActionButton(IconData icon, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24.sp, color: Colors.blueAccent),
        ),
        SizedBox(height: 4.h),
        reausabletext(
          label,
          fontsize: 12, color: Colors.black87,
        ),
      ],
    ),
  );
}
