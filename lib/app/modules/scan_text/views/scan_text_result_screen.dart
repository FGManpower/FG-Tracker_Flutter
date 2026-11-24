import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/global_widget/app_back_button.dart';
import 'package:fgtracker/app/modules/scan_text/services/scan_text_service.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

class ScanTextResultScreen extends StatefulWidget {
  final String scannedText;
  final String? imagePath;

  const ScanTextResultScreen({
    super.key,
    required this.scannedText,
    this.imagePath,
  });

  @override
  State<ScanTextResultScreen> createState() => _ScanTextResultScreenState();
}

class _ScanTextResultScreenState extends State<ScanTextResultScreen> {
  late final TextEditingController _textController;
  final RxInt _charCount = 0.obs;
  final RxInt _wordCount = 0.obs;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.scannedText);
    _updateStats(_widgetText());
    _textController.addListener(() {
      _updateStats(_textController.text);
    });
  }

  String _widgetText() => widget.scannedText;

  void _updateStats(String text) {
    _charCount.value = text.length;
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _wordCount.value = 0;
    } else {
      _wordCount.value = trimmed.split(RegExp(r'\s+')).length;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _copyText() {
    final text = _textController.text;
    if (text.isEmpty) {
      Utils().fluttertoast("No text to copy");
      return;
    }
    Clipboard.setData(ClipboardData(text: text));
    Utils().fluttertoast("Copied");
  }

  void _shareText() {
    final text = _textController.text;
    if (text.isEmpty) {
      Utils().fluttertoast("No text to share");
      return;
    }
    Share.share(text);
  }

  void _rescan() {
    if (Navigator.canPop(context)) {
      Get.back();
    } else {
      ScanTextService.instance.openCameraScanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.h),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: AppBarStyle.scrolledUnderElevation,
          surfaceTintColor: AppBarStyle.surfaceTintColor,
          backgroundColor: const Color(0xFFF8F9FE),
          titleSpacing: 16.w,
          title: Row(
            children: [
              AppBackButton(onTap: () => Get.back()),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Scan Result",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: FontFamily.interBold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Obx(
                      () => Text(
                        "${_wordCount.value} words • ${_charCount.value} characters",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interRegular,
                          color: const Color(0xFF7A7F93),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _copyText,
                tooltip: "Copy Text",
                icon: Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.copy_rounded,
                    color: const Color(0xFF5D47F1),
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Editable Text Area
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontFamily: FontFamily.interRegular,
                      color: const Color(0xFF1F2937),
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: "Scanned text will appear here...",
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom 3 Action Buttons: Copy, Share, Rescan
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 1. Copy Button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.copy_rounded,
                      label: "Copy",
                      backgroundColor: const Color(0xFF5D47F1),
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      onTap: _copyText,
                    ),
                  ),
                  SizedBox(width: 10.w),

                  // 2. Share Button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.share_rounded,
                      label: "Share",
                      backgroundColor: const Color(0xFFEDE9FE),
                      textColor: const Color(0xFF5D47F1),
                      iconColor: const Color(0xFF5D47F1),
                      onTap: _shareText,
                    ),
                  ),
                  SizedBox(width: 10.w),

                  // 3. Rescan Button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.refresh_rounded,
                      label: "Rescan",
                      backgroundColor: const Color(0xFFF3F4F6),
                      textColor: const Color(0xFF374151),
                      iconColor: const Color(0xFF374151),
                      onTap: _rescan,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 46.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.sp, color: iconColor),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontFamily: FontFamily.interBold,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
