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
    logicalSize: Size(100.w, 120.h),
    imageSize: Size(200.w, 240.h),
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
      width: 100.w,
      height: 120.h,
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Icon(
              Icons.location_pin,
              size: 100.sp,
              color: pinColor,
            ),
          ),
          Positioned(
            top: 35.h,
            child: Stack(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: Border.all(
                      color: borderColor,
                      width: 2.5,
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
                                size: 30.sp,
                                color: isMe
                                    ? AppColors.darkBlue
                                    : AppColors.grey,
                              );
                            },
                          )
                        : Icon(
                            isMe ? Icons.person_pin : Icons.person,
                            size: 30.sp,
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
                            horizontal: 4, vertical: 1)
                        : EdgeInsets.zero,
                    width: isMe ? null : 12.w,
                    height: isMe ? null : 12.w,
                    decoration: BoxDecoration(
                      shape: isMe ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius:
                          isMe ? BorderRadius.circular(6) : null,
                      color: isMe
                          ? AppColors.darkBlue
                          : (isOnline == true ? AppColors.primaryElementStatus : AppColors.darkRed),
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                    child: isMe
                        ? const Text(
                            "YOU",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 7,
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


