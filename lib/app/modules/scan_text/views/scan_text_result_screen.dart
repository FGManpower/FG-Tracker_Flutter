import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/global_widget/app_back_button.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

class ScanTextResultScreen extends StatefulWidget {
  final String scannedText;
  final String? imagePath;
  final bool isForChat;

  const ScanTextResultScreen({
    super.key,
    required this.scannedText,
    this.imagePath,
    this.isForChat = false,
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

  void _sendToChat() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      Utils().fluttertoast("No text to send");
      return;
    }
    Get.back(result: text);
  }

  void _rescan() {
    Get.back(result: '__RESCAN__');
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
              AppBackButton(
                onTap: () => Get.back(
                  result: widget.isForChat ? null : _textController.text,
                ),
              ),
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
                      () => Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "${_wordCount.value} words • ${_charCount.value} chars",
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.interSemiBold,
                            color: const Color(0xFF5D47F1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Clear Text Button
              IconButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    _textController.clear();
                  }
                },
                tooltip: "Clear Text",
                icon: Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.clear_rounded,
                    color: const Color(0xFF64748B),
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              // Copy Text Button
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
            // Enhanced Editable Text Card
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Sub-header bar inside the card
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(17.r),
                            topRight: Radius.circular(17.r),
                          ),
                          border: const Border(
                            bottom: BorderSide(color: Color(0xFFEDE9FE), width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              size: 18.sp,
                              color: const Color(0xFF5D47F1),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                "Editable Scanned Text",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontFamily: FontFamily.interSemiBold,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4338CA),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Text Field Area
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                            cursorColor: const Color(0xFF5D47F1),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontFamily: FontFamily.interRegular,
                              color: const Color(0xFF1E293B),
                              height: 1.55,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: "Scanned text will appear here. Tap anywhere to edit...",
                              hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Bar: Send Button Provided Exactly 1 Time
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: widget.isForChat
                    ? [
                        // Chat Mode: Copy, Rescan, and Send (Single Send Button!)
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.copy_rounded,
                            label: "Copy",
                            backgroundColor: const Color(0xFFEDE9FE),
                            textColor: const Color(0xFF5D47F1),
                            iconColor: const Color(0xFF5D47F1),
                            onTap: _copyText,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.refresh_rounded,
                            label: "Rescan",
                            backgroundColor: const Color(0xFFF1F5F9),
                            textColor: const Color(0xFF334155),
                            iconColor: const Color(0xFF334155),
                            onTap: _rescan,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.send_rounded,
                            label: "Send",
                            backgroundColor: const Color(0xFF5D47F1),
                            textColor: Colors.white,
                            iconColor: Colors.white,
                            onTap: _sendToChat,
                          ),
                        ),
                      ]
                    : [
                        // Standalone Mode: Copy, Share, Rescan
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
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.refresh_rounded,
                            label: "Rescan",
                            backgroundColor: const Color(0xFFF1F5F9),
                            textColor: const Color(0xFF334155),
                            iconColor: const Color(0xFF334155),
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
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.sp, color: iconColor),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: FontFamily.interBold,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
