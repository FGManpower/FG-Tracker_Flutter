import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../gen/fonts.gen.dart';
import '../../../Model/LocationMessage.dart';

class LocationBubbleWidget extends StatelessWidget {
  final String? content;
  final bool isSentByMe;
  final Color textColor;

  const LocationBubbleWidget({
    super.key,
    required this.content,
    required this.isSentByMe,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (content == null || content!.isEmpty) {
      return _errorWidget();
    }

    LocationMessage? location;

    try {
      location = LocationMessage.fromContent(content!);
    } catch (_) {
      try {
        location = LocationMessage.fromJson(jsonDecode(content!));
      } catch (_) {
        return _errorWidget();
      }
    }

    final bubbleColor = isSentByMe
        ? Colors.white.withOpacity(.10)
        : const Color(0xffF7F7F9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: Colors.redAccent,
              size: 18,
            ),
            SizedBox(width: 5.w),
            Text(
              "Shared Location",
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: FontFamily.interMedium,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),

        SizedBox(height: 6.h),

        InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => _openMap(location!),
          child: Container(
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(14.r),
              border: isSentByMe
                  ? null
                  : Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(14.r),
                  ),
                  child: SizedBox(
                    height: 85.h,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: const Color(0xffECEFF3),
                        ),

                        IgnorePointer(
                          child: Opacity(
                            opacity: .35,
                            child: Image.asset(
                              "assets/images/map_placeholder.png",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),

                        const Center(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 42,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.locationName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13.sp,
                          height: 1.35,
                          fontFamily: FontFamily.interRegular,
                        ),
                      ),

                      SizedBox(height: 10.h),

                      Container(
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: isSentByMe
                              ? Colors.white
                              : const Color(0xff6C4EF6),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30.r),
                            onTap: () => _openMap(location!),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  size: 20,
                                  color: isSentByMe
                                      ? const Color(0xff6C4EF6)
                                      : Colors.white,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  "Open in Google Maps",
                                  style: TextStyle(
                                    color: isSentByMe
                                        ? const Color(0xff6C4EF6)
                                        : Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.sp,
                                    fontFamily: FontFamily.interMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorWidget() {
    return Text(
      "Location unavailable",
      style: TextStyle(
        color: textColor,
        fontSize: 12.sp,
      ),
    );
  }

  Future<void> _openMap(LocationMessage location) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      Get.snackbar(
        "Error",
        "Unable to open Google Maps",
      );
    }
  }
}