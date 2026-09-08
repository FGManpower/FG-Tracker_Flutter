import 'dart:math';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Track/Widget/ToBitDescription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getCustomIcon(
    String imageUrl, dynamic isOnline, {bool isMe = false}) async {
  return MarkerWidget(imageUrl: imageUrl, isOnline: isOnline, isMe: isMe)
      .toBitmapDescriptor(
    logicalSize: Size(70.w, 84.h),
    imageSize: Size(140.w, 168.h),
  );
}

class MarkerWidget extends StatelessWidget {
  final String imageUrl;
  final dynamic isOnline;
  final bool isMe;

  const MarkerWidget({
    super.key,
    required this.imageUrl,
    required this.isOnline,
    this.isMe = false,
  });

  Color get randomColor {
    final Random random = Random(imageUrl.hashCode);
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullUrl = imageUrl.isEmpty
        ? ""
        : (imageUrl.startsWith("http")
            ? imageUrl
            : ConstRes.aImageBaseUrl + imageUrl);

    final Color pinColor =
        isMe ? AppColors.darkBlue : ToggleThemeData.Appcolor;
    final Color borderColor = isMe
        ? AppColors.darkBlue
        : (isOnline == true ? AppColors.primaryElementStatus : AppColors.darkRed);

    return Container(
      width: 70.w,
      height: 84.h,
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Icon(
              Icons.location_pin,
              size: 70.sp,
              color: pinColor,
            ),
          ),
          Positioned(
            top: 24.5.h,
            child: Stack(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: Border.all(
                      color: borderColor,
                      width: 2.0,
                    ),
                  ),
                  child: ClipOval(
                    child: fullUrl.isNotEmpty
                        ? Image.network(
                            fullUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint("❌ Image load error: $fullUrl");
                              return Icon(
                                isMe ? Icons.person_pin : Icons.person,
                                size: 21.sp,
                                color: isMe
                                    ? AppColors.darkBlue
                                    : AppColors.grey,
                              );
                            },
                          )
                        : Icon(
                            isMe ? Icons.person_pin : Icons.person,
                            size: 21.sp,
                            color:
                                isMe ? AppColors.darkBlue : AppColors.grey,
                          ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: isMe
                        ? const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1)
                        : EdgeInsets.zero,
                    width: isMe ? null : 8.5.w,
                    height: isMe ? null : 8.5.w,
                    decoration: BoxDecoration(
                      shape: isMe ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius:
                          isMe ? BorderRadius.circular(4.r) : null,
                      color: isMe
                          ? AppColors.darkBlue
                          : (isOnline == true ? AppColors.primaryElementStatus : AppColors.darkRed),
                      border: Border.all(color: AppColors.white, width: 1.2),
                    ),
                    child: isMe
                        ? const Text(
                            "YOU",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 6,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
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
