import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/util/size_config.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Core/theme/appTheme.dart';
import '../Controller/RegisterController.dart';

Widget buildInput({
  required String hintText,
  required IconData icon,
  required TextEditingController controller,
  Widget? suffixIcon,
  bool obscureText = false,
  required String? Function(String?) validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    validator: validator,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockWidth * 4,
        vertical: SizeConfig.blockHeight * 2,
      ),
    ),
    style: TextStyle(fontSize: SizeConfig.getFont(14)),
  );
}

Widget buildTextField(
  IconData? icon,
  String hint, {
  TextEditingController? passwordController,
  required TextEditingController controller,
  bool isPassword = false,
  bool isConfirmPassword = false,
  bool obscureText = false,
  void Function()? toggleVisibility,
  Widget? prefixIcon,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      // Set maxLength dynamically
      int maxLength = 50;
      if (hint.toLowerCase().contains("phone")) {
        maxLength = 10;
      } else if (hint.toLowerCase().contains("password")) {
        maxLength = 12;
      }

      return TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLength: maxLength,
        keyboardType: hint.toLowerCase().contains("email")
            ? TextInputType.emailAddress
            : hint.toLowerCase().contains("phone")
                ? TextInputType.phone
                : TextInputType.text,
        inputFormatters: hint.toLowerCase().contains("name")
            ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))]
            : [],
        buildCounter: (_,
                {required currentLength,
                required isFocused,
                required maxLength}) =>
            null,
        decoration: InputDecoration(
          prefixIcon: prefixIcon ?? (icon != null ? Icon(icon) : null),
          prefixText: (hint.toLowerCase().contains("phone") &&
                  controller.text.isNotEmpty)
              ? '+91 '
              : null,
          prefixStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
          filled: true,
          fillColor: const Color(0xFFF2F2F2),
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          suffixIcon: (isPassword || isConfirmPassword)
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
        onChanged: (value) {
          if (hint.toLowerCase().contains("phone")) {
            setState(() {});
          }
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$hint is required";
          }

          if (hint.toLowerCase().contains("name") && value.trim().length < 2) {
            return AppText.entrValidName;
          }

          if (hint.toLowerCase().contains("email") &&
              !RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$")
                  .hasMatch(value.trim())) {
            return AppText.entrValidEmail;
          }

          if (hint.toLowerCase().contains("phone") &&
              value.trim().length != 10) {
            return AppText.entrValid10DigitNumber;
          }

          if ((isPassword || isConfirmPassword) && value.trim().length < 6) {
            return AppText.psswrdMustBe6Character;
          }

          if (isConfirmPassword &&
              passwordController != null &&
              value.trim() != passwordController.text.trim()) {
            return AppText.psswrdDoNotMatch;
          }

          return null;
        },
      );
    },
  );
}

class ReusableTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool showSuffixIcon;
  final VoidCallback? onSuffixTap;
  final int? maxLength;

  const ReusableTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.showSuffixIcon = false,
    this.onSuffixTap,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      buildCounter: (_,
              {required int currentLength,
              required bool isFocused,
              required int? maxLength}) =>
          null,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: const BorderSide(color: Color(0xffDEDEDE), width: 1.0),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: SizedBox(
            width: 50.w,
            child: Row(
              children: [
                Icon(prefixIcon, size: 25.w),
                SizedBox(width: 10.w),
                Container(
                    height: 40.h, width: 1.w, color: const Color(0xff828282)),
              ],
            ),
          ),
        ),
        suffixIcon: showSuffixIcon
            ? IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: onSuffixTap,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        isDense: false,
        fillColor: const Color(0xffF4F4F4),
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 15.sp),
      ),
    );
  }
}

class CustomHeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 20.h);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 100.h,
      size.width * 0.5,
      size.height - 60.h,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 15.h,
      size.width,
      size.height - 120.h,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextEditingController? passwordController;
  final Widget? prefixIcon;
  final bool isPassword;
  final bool isConfirmPassword;
  final bool obscureText;
  final VoidCallback? toggleVisibility;
  bool isEnable = true;
  final int? maxLength;
  final String? Function(String?)? validator; // Add this to the constructor

  CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.passwordController,
    this.prefixIcon,
    this.isPassword = false,
    this.isConfirmPassword = false,
    this.obscureText = false,
    this.toggleVisibility,
    this.isEnable = true,
    this.maxLength,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final RegistrationController controller;

  @override
  Widget build(BuildContext context) {
    int maxLength = 50;
    if (widget.hint.toLowerCase().contains("password")) {
      maxLength = 12;
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      maxLength: maxLength,
      keyboardType: widget.hint.toLowerCase().contains("email")
          ? TextInputType.emailAddress
          : widget.hint.toLowerCase().contains("phone")
              ? TextInputType.phone
              : TextInputType.text,
      inputFormatters: widget.hint.toLowerCase().contains("name")
          ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))]
          : [],
      buildCounter: (_,
              {required currentLength,
              required isFocused,
              required maxLength}) =>
          null,
      decoration: InputDecoration(
        enabled: widget.isEnable,
        prefixIcon: widget.prefixIcon,
        prefixText: (widget.hint.toLowerCase().contains("phone") &&
                widget.controller.text.isNotEmpty)
            ? ' '
            : null,
        prefixStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        hintText: widget.hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon: (widget.isPassword || widget.isConfirmPassword)
            ? IconButton(
                icon: Icon(widget.obscureText
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: widget.toggleVisibility,
              )
            : null,
      ),
      onChanged: (value) {
        if (widget.hint.toLowerCase().contains("phone")) {
          // controller.phoneNumber.value = value;
          // if (value.length < 10) {
          //   controller.phoneError.value = "Please enter a valid mobile number";
          // } else {
          //   controller.phoneError.value = "";
          // }
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "${widget.hint} is required";
        }

        if (widget.hint.toLowerCase().contains("name") &&
            value.trim().length < 2) {
          return AppText.entrValidName;
        }

        if (widget.hint.toLowerCase().contains("email") &&
            !RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$")
                .hasMatch(value.trim())) {
          return AppText.entrValidEmail;
        }

        if (widget.hint.toLowerCase().contains("phone")) {
          if (value.trim().isEmpty) {
            return "${widget.hint} is required";
          }
          return null;
        }

        if ((widget.isPassword || widget.isConfirmPassword) &&
            value.trim().length < 6) {
          return AppText.psswrdMustBe6Character;
        }

        if (widget.isConfirmPassword &&
            widget.passwordController != null &&
            value.trim() != widget.passwordController!.text.trim()) {
          return AppText.psswrdDoNotMatch;
        }

        return null;
      },
    );
  }
}

Widget inputField(BuildContext context,
    {String? title,
    TextEditingController? textctr,
    String? hintname,
    IconData? prefixicon,
    void Function(String? value)? onChanged,
    FormFieldValidator? validators,
    void Function()? onTap,
    void Function(String? value)? onFieldSubmitted,
    bool enable = true,
    int? maxLength,
    Widget? prefixEmpty,
    int? maxLines,
    TextInputType? keyboradtype,
    GlobalKey? key,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction = TextInputAction.next,
    FocusNode? focusNode}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Utility.isNullEmptyOrFalse(title)
          ? SizedBox()
          : Padding(
              padding: EdgeInsets.only(bottom: 5.h, left: 3.w),
              child: reausabletext(title ?? "",
                  fontsize: 16, fontfamily: FontFamily.interSemiBold),
            ),
      MyAppTheme.customizedTextFormField(
        filled: true,
        onTap: onTap,
        onFieldSubmitted: onFieldSubmitted,
        inputFormatters: inputFormatters,
        OutlineInputBorderRadius: 50,
        focusNode: focusNode,
        fillColor: const Color(0xffF4F4F4),
        context,
        onChanged: onChanged,
        keyboardType: keyboradtype,
        textInputAction: textInputAction,
        enabled: enable,
        maxLength: maxLength,
        maxLines: maxLines,
        controller: textctr,
        validator: validators,
        hintText: hintname,
        prefixIcon: prefixicon == null
            ? prefixEmpty
            : Padding(
                padding: EdgeInsets.only(left: 10.w, right: 10.w),
                child: Icon(
                  prefixicon,
                  size: 23.sp,
                  color: ToggleThemeData.darkPurple,
                ),
              ),
      )
    ],
  );
}
