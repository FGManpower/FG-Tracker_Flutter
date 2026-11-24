import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

/// Bottom sheet for reviewing and editing scanned text before sending as a chat message.
class ScanTextPreviewSheet extends StatefulWidget {
  final String initialText;

  const ScanTextPreviewSheet({
    super.key,
    required this.initialText,
  });

  @override
  State<ScanTextPreviewSheet> createState() => _ScanTextPreviewSheetState();
}

class _ScanTextPreviewSheetState extends State<ScanTextPreviewSheet> {
  late final TextEditingController _textController;
  int _wordCount = 0;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _updateCounts();
    _textController.addListener(_updateCounts);
  }

  void _updateCounts() {
    final text = _textController.text.trim();
    setState(() {
      _charCount = text.length;
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_updateCounts);
    _textController.dispose();
    super.dispose();
  }

  void _copyText() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      Utils().fluttertoast("No text to copy");
      return;
    }
    Clipboard.setData(ClipboardData(text: text));
    Utils().fluttertoast("Copied");
  }

  void _sendAsMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      Utils().fluttertoast("Cannot send empty message");
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 16.h + bottomInset),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Top Header Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.document_scanner_rounded,
                    color: const Color(0xFF5D47F1),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Scanned Text Preview",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: FontFamily.interBold,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E202B),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "$_wordCount words • $_charCount characters",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interRegular,
                          color: const Color(0xFF7A7F93),
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                InkWell(
                  onTap: () => Navigator.of(context).pop(null),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Editable Text Area
            Flexible(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE2DCF3), width: 1),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interRegular,
                    color: const Color(0xFF1F2937),
                    height: 1.45,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: "Edit scanned text here...",
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Action Buttons: Copy and Send As Message
            Row(
              children: [
                // Copy Button
                InkWell(
                  onTap: _copyText,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    height: 46.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 17.sp,
                          color: const Color(0xFF5D47F1),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "Copy",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: FontFamily.interSemiBold,
                            color: const Color(0xFF5D47F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // Primary "Send As Message" Button
                Expanded(
                  child: InkWell(
                    onTap: _sendAsMessage,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      height: 46.h,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5D47F1),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5D47F1).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            size: 17.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              "Send As Message",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontFamily: FontFamily.interBold,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
