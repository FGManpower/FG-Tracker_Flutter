import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../gen/fonts.gen.dart';
import '../../../Model/LocationMessage.dart';
import '../Views/LiveLocationViewScreen.dart';

class LocationBubbleWidget extends StatelessWidget {
  final String? content;
  final bool isSentByMe;
  final Color textColor;
  final String? senderName;
  final String? senderImage;
  final VoidCallback? onStopLiveLocation;

  const LocationBubbleWidget({
    super.key,
    required this.content,
    required this.isSentByMe,
    required this.textColor,
    this.senderName,
    this.senderImage,
    this.onStopLiveLocation,
  });

  @override
  Widget build(BuildContext context) {
    if (content == null || content!.trim().isEmpty) {
      return _errorWidget();
    }

    LocationMessage? location;
    try {
      location = LocationMessage.fromContent(content!);
    } catch (_) {
      try {
        final decoded = jsonDecode(content!);
        if (decoded is Map<String, dynamic>) {
          location = LocationMessage.fromJson(decoded);
        } else if (decoded is Map) {
          location = LocationMessage.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        return _errorWidget();
      }
    }

    if (location == null) return _errorWidget();

    return location.isLive
        ? _buildLiveLocationBubble(context, location)
        : _buildStaticLocationBubble(context, location);
  }

  /// WhatsApp-style Static Location Bubble
  Widget _buildStaticLocationBubble(
      BuildContext context, LocationMessage location) {
    final bubbleColor = isSentByMe
        ? Colors.white.withOpacity(0.12)
        : const Color(0xffF7F7F9);

    final staticMapUrl = ConstRes.gMapApiKey.isNotEmpty
        ? "https://maps.googleapis.com/maps/api/staticmap"
            "?center=${location.latitude},${location.longitude}"
            "&zoom=15"
            "&size=500x240"
            "&scale=2"
            "&maptype=roadmap"
            "&markers=color:0x8274FD%7C${location.latitude},${location.longitude}"
            "&key=${ConstRes.gMapApiKey}"
        : "";

    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () => _openMap(location),
      child: Container(
        width: 250.w,
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14.r),
          border: isSentByMe
              ? null
              : Border.all(color: Colors.grey.shade300, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Snapshot
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
              child: SizedBox(
                height: 110.h,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: const Color(0xffECEFF3)),
                    if (staticMapUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: staticMapUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _mapFallback(),
                      )
                    else
                      _mapFallback(),
                  ],
                ),
              ),
            ),

            // Place details
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.locationName.isNotEmpty
                        ? location.locationName
                        : "Location",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.interMedium,
                    ),
                  ),
                  if (location.address != null &&
                      location.address!.trim().isNotEmpty &&
                      location.address != location.locationName) ...[
                    SizedBox(height: 3.h),
                    Text(
                      location.address!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor.withOpacity(0.75),
                        fontSize: 11.5.sp,
                        height: 1.3,
                        fontFamily: FontFamily.interRegular,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// WhatsApp-style Live Location Bubble
  Widget _buildLiveLocationBubble(
      BuildContext context, LocationMessage location) {
    final isEnded = location.isEnded;
    final bubbleColor = isSentByMe
        ? Colors.white.withOpacity(0.12)
        : const Color(0xffF7F7F9);

    final avatarUrl = senderImage != null && senderImage!.isNotEmpty
        ? (senderImage!.startsWith('http')
            ? senderImage!
            : "${ConstRes.aImageBaseUrl}$senderImage")
        : "";

    return Container(
      width: 260.w,
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(14.r),
        border: isSentByMe
            ? null
            : Border.all(color: Colors.grey.shade300, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Snapshot with Avatar Marker
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
            child: SizedBox(
              height: 110.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: isEnded
                        ? Colors.grey.shade300
                        : const Color(0xFFE2E8F0),
                  ),
                  _mapFallback(),

                  // Live pulsing circle with user avatar
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(isEnded ? 0 : 3.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isEnded
                            ? Colors.transparent
                            : ToggleThemeData.Appcolor.withValues(alpha: 0.35),
                      ),
                      child: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: Colors.white,
                        backgroundImage: avatarUrl.isNotEmpty
                            ? CachedNetworkImageProvider(avatarUrl)
                            : null,
                        child: avatarUrl.isEmpty
                            ? Icon(Icons.person,
                                size: 22.sp, color: Colors.grey.shade700)
                            : null,
                      ),
                    ),
                  ),

                  // LIVE badge / ENDED badge
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: isEnded
                            ? Colors.black54
                            : ToggleThemeData.Appcolor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isEnded)
                            Container(
                              width: 6.w,
                              height: 6.h,
                              margin: EdgeInsets.only(right: 4.w),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          Text(
                            isEnded ? "ENDED" : "LIVE",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Live details
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isEnded
                          ? Icons.location_off_outlined
                          : Icons.share_location_rounded,
                      size: 16.sp,
                      color: isEnded
                          ? Colors.grey.shade600
                          : ToggleThemeData.Appcolor,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        isEnded ? "Live location ended" : location.liveUntilText,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isEnded
                              ? textColor.withOpacity(0.65)
                              : textColor,
                        ),
                      ),
                    ),
                  ],
                ),

                if (location.comment != null &&
                    location.comment!.trim().isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    location.comment!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.85),
                    ),
                  ),
                ],

                SizedBox(height: 10.h),

                // Action buttons: "View live location" + "Stop sharing"
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 34.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEnded
                                ? Colors.grey.shade400
                                : ToggleThemeData.Appcolor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                          onPressed: () {
                            Get.to(
                              () => LiveLocationViewScreen(
                                location: location,
                                isSentByMe: isSentByMe,
                                senderName: senderName,
                                senderImage: senderImage,
                                onStopSharing: onStopLiveLocation,
                              ),
                            );
                          },
                          child: Text(
                            "View live location",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isSentByMe && !isEnded) ...[
                      SizedBox(width: 8.w),
                      SizedBox(
                        height: 34.h,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                          onPressed: onStopLiveLocation,
                          child: Text(
                            "Stop",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapFallback() {
    return Stack(
      children: [
        Image.asset(
          "assets/images/map_placeholder.png",
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xffECEFF3),
            child: Center(
              child: Icon(Icons.map_outlined,
                  size: 40.sp, color: Colors.grey.shade400),
            ),
          ),
        ),
        Center(
          child: Icon(
            Icons.location_on,
            color: ToggleThemeData.Appcolor,
            size: 34.sp,
          ),
        ),
      ],
    );
  }

  Widget _errorWidget() {
    return Text(
      appL10n.chat_locationUnavailable,
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
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        appL10n.common_error,
        appL10n.chat_unableToOpenGoogleMaps,
      );
    }
  }
}
