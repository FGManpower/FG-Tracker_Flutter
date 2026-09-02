// ignore_for_file: unused_import

import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Core/values/colors.dart';
import 'common_widget.dart';

Widget InputField(
    {required String title,
    bool enabled = true,
    bool readOnly = false,
    InputDecoration? decoration,
    TextStyle hintstyle =
        const TextStyle(fontFamily: FontFamily.interMedium, fontSize: 15),
    bool obscureText = false,
    TextInputType? keyboardType = TextInputType.text,
    Widget? prefix,
    Widget? suffix,
    Widget? prefixIcon,
    suffixIcon,
    TextEditingController? controller,
    void Function()? onEditingComplete,
    void Function(String? value)? onChanged,
    void Function()? onTap,
    void Function(String? value)? onSaved,
    void Function(String? value)? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLength,
    int? maxLines,
    String? labelText,
    String? hintText,
    double? cursorHeight,
    double? width,
    String? initialValue,
    Color? fillColor,
    bool? filled,
    bool isRequired = false,
    GlobalKey? key,
    FocusNode? focusNode,
    TextCapitalization textCapitalization = TextCapitalization.characters,
    Widget? RowIcon,
    Color? textColor}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 5.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 3.w, bottom: 3.h),
              child: reausabletext(
                title,
                fontfamily: FontFamily.interRegular,
                fontsize: 14,
              ),
            ),
            RowIcon ?? const SizedBox(),
          ],
        ),
        TextFormField(
          keyboardType: keyboardType,

          decoration: InputDecoration(
              enabled: enabled,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              counterText: "",
              labelStyle: const TextStyle(
                color: Colors.black,
                fontFamily: FontFamily.interMedium,
              ),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.r)),
                  borderSide: BorderSide(
                      width: 2.w,
                      style: BorderStyle.solid,
                      color: const Color(0xffDEDEDE))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.r)),
                  borderSide: BorderSide(
                      width: 2.w,
                      style: BorderStyle.solid,
                      color: AppColors.darkBlue)),
              enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: const Color(0xffDEDEDE), width: 1.w),
                  borderRadius: BorderRadius.all(Radius.circular(7.r))),
              hintText: hintText,
              hintStyle: hintstyle,
              prefix: prefix,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              suffix: suffix,
              suffixStyle: const TextStyle(
                color: Colors.black,
                fontFamily: FontFamily.interMedium,
              )),
          focusNode: focusNode,
          onChanged: onChanged,
          controller: controller,
          validator: validator,
          readOnly: readOnly,
          enabled: enabled,
          // textCapitalization: textCapitalization,
          obscureText:
              Utility.isNullEmptyOrFalse(obscureText) ? false : obscureText,
          onEditingComplete: onEditingComplete,
          onSaved: onSaved,
          onTap: onTap,
          inputFormatters: [
            ...?inputFormatters,
          ],
          initialValue: initialValue,
          onFieldSubmitted: onFieldSubmitted,
          style: TextStyle(
              fontFamily: FontFamily.interRegular,
              fontSize: 14.sp,
              color: textColor),

          maxLength: maxLength,
          maxLines: maxLines,
        ),
      ],
    ),
  );
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
