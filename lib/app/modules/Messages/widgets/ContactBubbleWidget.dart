import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../gen/fonts.gen.dart';
import '../../../Model/ContactMessage.dart';

class ContactBubbleWidget extends StatelessWidget {
  final String? content;
  final bool isSentByMe;
  final Color textColor;

  const ContactBubbleWidget({
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

    ContactMessage? contact;

    try {
      contact = ContactMessage.fromContent(content!);
    } catch (_) {
      try {
        contact = ContactMessage.fromJson(
          jsonDecode(content!),
        );
      } catch (_) {
        return _errorWidget();
      }
    }

    return Container(
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
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                child: const Icon(Icons.person),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: FontFamily.interMedium,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      contact.phone,
                      style: TextStyle(
                        color: textColor.withOpacity(.7),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _call(contact!),
              icon: const Icon(Icons.call),
              label: const Text("Call"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorWidget() {
    return Text(
      "Contact unavailable",
      style: TextStyle(
        color: textColor,
        fontSize: 12.sp,
      ),
    );
  }

  Future<void> _call(ContactMessage contact) async {
    final uri = Uri.parse("tel:${contact.phone}");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}