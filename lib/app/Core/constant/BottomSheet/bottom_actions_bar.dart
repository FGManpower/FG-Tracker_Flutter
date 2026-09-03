import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/util/validator.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> showCreateGroupSheet() {
  return Get.bottomSheet(
    const CreateGroupSheet(),
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
  );
}

class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final GroupController _controller = Get.find<GroupController>();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  final RxBool _isSubmitting = false.obs;
  final RxBool _attemptedSubmit = false.obs;

  @override
  void dispose() {
    _nameFocus.dispose();
    _descFocus.dispose();
    _isSubmitting.close();
    _attemptedSubmit.close();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting.value) return;
    FocusScope.of(context).unfocus();
    _attemptedSubmit.value = true;
    if (!_controller.createGroupKey.currentState!.validate()) return;

    _isSubmitting.value = true;
    final bool isCreated = await _controller.createGroup(
      context,
      controller: _controller,
    );
    if (!mounted) return;
    _isSubmitting.value = false;

    if (isCreated) {
      _controller.groupName.clear();
      _controller.groupDesc.clear();
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 24.h),
            child: Obx(() => Form(
              key: _controller.createGroupKey,
              autovalidateMode: _attemptedSubmit.value
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SheetHandle(),
                  SizedBox(height: 18.h),
                  _SheetHeader(),
                  SizedBox(height: 18.h),
                  const Divider(height: 1, color: Color(0xFFF0EEF7)),
                  SizedBox(height: 24.h),
                  _FieldLabel(
                    icon: Icons.groups_outlined,
                    title: AppText.groupName,
                    required: true,
                  ),
                  SizedBox(height: 12.h),
                  _RoundedField(
                    controller: _controller.groupName,
                    hint: AppText.enterGroupName,
                    icon: Icons.groups_outlined,
                    maxLength: 50,
                    maxLines: 1,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    validator: (value) => Validator.validate(
                      value: value,
                      title: "Group Name",
                    ),
                    onFieldSubmitted: (_) => _descFocus.requestFocus(),
                  ),
                  SizedBox(height: 20.h),
                  _FieldLabel(
                    icon: Icons.description_outlined,
                    title: "Group Description",
                    required: false,
                  ),
                  SizedBox(height: 12.h),
                  _RoundedField(
                    controller: _controller.groupDesc,
                    hint: "Enter Group Description",
                    icon: Icons.description_outlined,
                    maxLength: 200,
                    maxLines: 1,
                    focusNode: _descFocus,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  _CharacterCounter(controller: _controller.groupDesc),
                  SizedBox(height: 24.h),
                  _SubmitButton(
                    isSubmitting: _isSubmitting.value,
                    onTap: _submit,
                  ),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: const Color(0xFFD8D9E4),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B78FF), Color(0xFF6B4DFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B4DFF).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child:
          Icon(Icons.group_add_rounded, color: Colors.white, size: 24.sp),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.createNewGroup,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontFamily.interBold,
                  color: const Color(0xFF1F1F39),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                "Fill in the details below",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                  fontFamily: FontFamily.interRegular,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8EAF1)),
            ),
            child: Icon(
              Icons.close,
              size: 16.sp,
              color: const Color(0xFF1F1F39),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.icon,
    required this.title,
    required this.required,
  });

  final IconData icon;
  final String title;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE8EAF1)),
          ),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF6B4DFF)),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.interBold,
            color: const Color(0xFF1F1F39),
          ),
        ),
        if (required) ...[
          SizedBox(width: 4.w),
          Text(
            "*",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
            ),
          ),
        ],
      ],
    );
  }
}

class _CharacterCounter extends StatelessWidget {
  const _CharacterCounter({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Padding(
          padding: EdgeInsets.only(top: 6.h, right: 6.w),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${value.text.length}/200',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}

class _RoundedField extends StatelessWidget {
  const _RoundedField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.maxLength,
    required this.maxLines,
    this.focusNode,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLength;
  final int maxLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      maxLines: maxLines,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      cursorColor: const Color(0xFF6B4DFF),
      style: TextStyle(
        color: const Color(0xFF1F1F39),
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        fontFamily: FontFamily.interRegular,
      ),
      decoration: InputDecoration(
        counterText: "",
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF6B4DFF).withValues(alpha: 0.45),
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF6B4DFF).withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: BorderSide(color: ToggleThemeData.Appcolor, width: 1.2.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: BorderSide(color: ToggleThemeData.Appcolor, width: 1.2.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: BorderSide(color: Color(0xFF6B4DFF), width: 1.2.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.w),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.2.w),
        ),
        errorStyle: TextStyle(fontSize: 11.sp, color: Colors.redAccent),
        errorMaxLines: 2,
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isSubmitting, required this.onTap});

  final bool isSubmitting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B78FF), Color(0xFF6B4DFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4DFF).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: isSubmitting ? null : onTap,
          borderRadius: BorderRadius.circular(30.r),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSubmitting
                  ? SizedBox(
                key: const ValueKey('loading'),
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : Text(
                "Create Group",
                key: const ValueKey('label'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontFamily.interBold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
