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
    } catch (e) {
      try {
        location = LocationMessage.fromJson(
          jsonDecode(content!),
        );
      } catch (_) {
        return _errorWidget();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 20,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                "📍 Shared Location",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  fontFamily: FontFamily.interMedium,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isSentByMe
                ? Colors.white.withOpacity(.12)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.locationName,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openMap(location!),
                  icon: const Icon(Icons.map),
                  label: const Text("Open in Maps"),
                ),
              ),
            ],
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
