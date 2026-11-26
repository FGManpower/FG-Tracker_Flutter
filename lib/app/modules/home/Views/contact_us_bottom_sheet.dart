import 'dart:developer';

import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/modules/Legal/legal_documents.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows the Contact Us bottom sheet with customer support illustration
/// and complete contact details from the Legal module:
/// Phone, Email, WhatsApp, Website, and Office Address.
void showContactUsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const ContactUsBottomSheet(),
  );
}

class ContactUsBottomSheet extends StatelessWidget {
  const ContactUsBottomSheet({super.key});

  static const String companyPhone = '+91 93727 23727';
  static const String companyEmail = 'fgtracker@fgmanpower.com';
  static const String companyWhatsApp = '919372723727';
  static const String companyAddress =
      'Ghatkopar West, Mumbai, Maharashtra 400086, India';

  Future<void> _launchUrl(
    BuildContext context,
    String urlString, {
    String? errorMessage,
  }) async {
    try {
      final uri = Uri.parse(urlString);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          Utils().fluttertoast(
            errorMessage ?? context.l10n.chat_unableToOpen,
          );
        }
      }
    } catch (e) {
      log('ContactUsBottomSheet launch error: $e');
      if (context.mounted) {
        Utils().fluttertoast(
          errorMessage ?? context.l10n.chat_unableToOpen,
        );
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final Uri waAppUri = Uri.parse('whatsapp://send?phone=$companyWhatsApp');
    final Uri waWebUri = Uri.parse('https://wa.me/$companyWhatsApp');
    try {
      if (await canLaunchUrl(waAppUri)) {
        await launchUrl(waAppUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(waWebUri)) {
        await launchUrl(waWebUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          Utils().fluttertoast(context.l10n.chatList_whatsappOpenFailed);
        }
      }
    } catch (e) {
      log('ContactUsBottomSheet whatsapp error: $e');
      try {
        await launchUrl(waWebUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (context.mounted) {
          Utils().fluttertoast(context.l10n.chatList_whatsappOpenFailed);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxSheetHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10.h),
              // Drag handle
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2DCF3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Title and Subtitle Header
              Text(
                context.l10n.about_contactUs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: FontFamily.interBold,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E202B),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "We're here to help you",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: FontFamily.interRegular,
                  color: const Color(0xFF7A7F93),
                ),
              ),
              SizedBox(height: 16.h),

              // Phone Option
              _buildContactOption(
                context,
                icon: Icons.call_outlined,
                title: context.l10n.call_phone,
                subtitle: companyPhone,
                onTap: () {
                  Navigator.pop(context);
                  _launchUrl(context, 'tel:+919372723727');
                },
              ),
              _buildDivider(),

              // Email Option
              _buildContactOption(
                context,
                icon: Icons.mail_outline_rounded,
                title: context.l10n.call_infoEmail,
                subtitle: companyEmail,
                onTap: () {
                  Navigator.pop(context);
                  _launchUrl(context, 'mailto:$companyEmail');
                },
              ),
              _buildDivider(),

              // WhatsApp Option
              _buildContactOption(
                context,
                iconWidget: FaIcon(
                  FontAwesomeIcons.whatsapp,
                  size: 22.sp,
                  color: const Color(0xFF5D47F1),
                ),
                title: 'WhatsApp',
                subtitle: companyPhone,
                onTap: () {
                  Navigator.pop(context);
                  _openWhatsApp(context);
                },
              ),
              _buildDivider(),

              // Website (Tracker Weblink from Legal)
              _buildContactOption(
                context,
                icon: Icons.language_rounded,
                title: context.l10n.about_website,
                subtitle: 'fgtracker.fgmanpower.com',
                onTap: () {
                  Navigator.pop(context);
                  _launchUrl(context, legalWebsiteUrl);
                },
              ),
              _buildDivider(),

              // Office Address (from Legal)
              _buildContactOption(
                context,
                icon: Icons.location_on_outlined,
                title: context.l10n.about_address,
                subtitle: companyAddress,
                onTap: () {
                  Navigator.pop(context);
                  final mapsUri = Uri.https('www.google.com', '/maps/search/', {
                    'api': '1',
                    'query': companyAddress,
                  }).toString();
                  _launchUrl(context, mapsUri);
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFFF0ECFC),
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    IconData? icon,
    Widget? iconWidget,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: iconWidget ??
                  Icon(
                    icon,
                    size: 22.sp,
                    color: const Color(0xFF5D47F1),
                  ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: FontFamily.interBold,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E202B),
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: FontFamily.interRegular,
                        color: const Color(0xFF7A7F93),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 24.sp,
              color: const Color(0xFF7E69F7),
            ),
          ],
        ),
      ),
    );
  }
}
