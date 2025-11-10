
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyAppTheme {
  static String ProfilenotFoundImg =
      "https://www.pngitem.com/pimgs/m/150-1503945_transparent-user-png-default-user-image-png-png.png";
  static String notFoundImg =
      "https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png";

  static Widget roundOutlinedTextButton(
      {required String btnText,
      void Function()? onPressed,
      Color? textColor,
      double textSize = 18.0,
      double radius = 18.0,
      Color? buttonColor,
      Color? fillColor,
      Color borderColor = Colors.white}) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(buttonColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: BorderSide(color: borderColor)))),
      child: Text(
        " $btnText ",
        softWrap: false,
        style: TextStyle(
            color: textColor, fontSize: textSize.sp, fontFamily: 'poppins'),
      ),
    );
  }

  static Widget customizedTextFormField(
    BuildContext context, {
    bool enabled = true,
    bool readOnly = false,
    InputDecoration? decoration,
    TextStyle? hintstyle,
    bool obscureText = false,
    TextInputType? keyboardType = TextInputType.text,
    TextInputAction? textInputAction = TextInputAction.next,
    Widget? prefix,
    Widget? suffix,
    Function(PointerDownEvent)? onTapOutside,
    Widget? prefixIcon,
    TextEditingController? controller,
    void Function()? onEditingComplete,
    void Function(String? value)? onChanged,
    void Function()? onTap,
    void Function(String? value)? onSaved,
    void Function(String? value)? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLength,
    var maxLines = null,
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
    EdgeInsetsGeometry? contentPadding,
    int OutlineInputBorderRadius = 14,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        key: key,
        cursorColor:
            context.isDarkMode ? ToggleThemeData.white : ToggleThemeData.black,
        cursorHeight: cursorHeight,

        keyboardType: keyboardType,
        onTapOutside: onTapOutside,
        decoration: InputDecoration(
            enabled: enabled,
            prefixIcon: prefixIcon,
            labelStyle: const TextStyle(
              color: Colors.black,
              fontFamily: FontFamily.interMedium,
            ),

            enabledBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(OutlineInputBorderRadius.r)),
                borderSide: const BorderSide(
                    width: 1,
                    style: BorderStyle.solid,
                    color: ToggleThemeData.darkPurple)),
            disabledBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(OutlineInputBorderRadius.r)),
                borderSide: const BorderSide(
                    width: 1,
                    style: BorderStyle.solid,
                    color: ToggleThemeData.darkPurple)),

            focusedBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(OutlineInputBorderRadius.r)),
                borderSide: const BorderSide(
                    width: 2,

                    style: BorderStyle.solid,
                    color: ToggleThemeData.darkPurple)),
            counterText: "",
            border: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1,

                    style: BorderStyle.solid,
                    color: ToggleThemeData.darkPurple),
              borderRadius:
                  BorderRadius.all(Radius.circular(OutlineInputBorderRadius.r)),
            ),
            hintText: hintText,
            hintStyle: hintstyle,
            labelText: labelText,
            prefix: prefix,
            filled: filled,
            fillColor: fillColor,
            contentPadding: contentPadding,
            suffixIcon: suffix,
            suffixStyle: const TextStyle(
              color: Colors.black,
              fontFamily: FontFamily.interMedium,
            )),

        focusNode: focusNode,
        onChanged: onChanged,

        controller: controller,
        validator: validator,
        textInputAction: textInputAction,
        readOnly: readOnly,
        enabled: enabled,
        obscureText:
            Utility.isNullEmptyOrFalse(obscureText) ? false : obscureText,
        onEditingComplete: onEditingComplete,
        onSaved: onSaved,

        onTap: onTap,
        inputFormatters: inputFormatters,
        initialValue: initialValue,
        //inputFormatters: inputFormatters,
        onFieldSubmitted: onFieldSubmitted,
        style: TextStyle(
          // color: Colors.black,
          fontFamily: FontFamily.interMedium,
          fontSize: 15.sp,
        ),
        maxLength: maxLength,
        maxLines: maxLines,
      ),
    );
  }

  static Widget customized_UpdateProfile_TextFormField(BuildContext context,
      {bool enabled = true,
      bool readOnly = false,
      InputDecoration? decoration,
      TextStyle? hintstyle,
      bool obscureText = false,
      TextInputType? keyboardType = TextInputType.text,
      TextInputAction? textInputAction = TextInputAction.next,
      Widget? prefix,
      Widget? suffix,
      Widget? prefixIcon,
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
      bool requiredtextfieldtext = true}) {
    return SizedBox(
      width: width,
      child: Material(
        child: TextFormField(
          key: key,
          cursorColor: context.isDarkMode
              ? ToggleThemeData.white
              : ToggleThemeData.black,
          cursorHeight: cursorHeight,
          keyboardType: keyboardType,
          decoration: InputDecoration(
              enabled: enabled,
              prefixIcon: prefixIcon,
              disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: context.isDarkMode
                          ? ToggleThemeData.white
                          : Colors.black)),
              labelStyle: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(133, 133, 133, 1)),
              counterText: "",
              hintText: hintText,
              hintStyle: hintstyle,
              // labelText: labelText,
              label: Text.rich(
                  style: TextStyle(fontSize: 16.sp),
                  TextSpan(children: [
                    TextSpan(
                      text: '$labelText',
                    ),
                    TextSpan(
                        text: requiredtextfieldtext == true ? ' *' : "",
                        style: TextStyle(color: Colors.red)),
                  ])),
              prefix: prefix,
              filled: filled,
              fillColor: fillColor,
              suffixIcon: suffix,
              suffixStyle: const TextStyle(
                color: Colors.black,
                fontFamily: FontFamily.interMedium,
              )),
          focusNode: focusNode,
          onChanged: onChanged,
          controller: controller,
          validator: validator,
          textInputAction: textInputAction,
          readOnly: readOnly,
          enabled: enabled,
          obscureText:
              Utility.isNullEmptyOrFalse(obscureText) ? false : obscureText,
          onEditingComplete: onEditingComplete,
          onSaved: onSaved,
          onTap: onTap,
          inputFormatters: inputFormatters,
          initialValue: initialValue,
          onFieldSubmitted: onFieldSubmitted,
          style: TextStyle(
            fontFamily: FontFamily.interMedium,
            fontSize: 15.sp,
          ),
          maxLength: maxLength,
          maxLines: maxLines,
        ),
      ),
    );
  }
}

