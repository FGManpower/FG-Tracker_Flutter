import 'package:fgtracker/l10n/l10n.dart';
import 'package:fgtracker/app/Core/util/validator.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/widgets/group_membership_sheet.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:math' as math;

int _createGroupSheetGeneration = 0;

void _clearCreateGroupDraft() {
  if (!Get.isRegistered<GroupController>()) return;
  final controller = Get.find<GroupController>();
  controller.groupName.clear();
  controller.groupDesc.clear();
  controller.removeSelectedGroupImage();
}

Future<void> showCreateGroupSheet() {
  final int generation = ++_createGroupSheetGeneration;
  _clearCreateGroupDraft();
  return Get.bottomSheet(
    CreateGroupSheet(sheetGeneration: generation),
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
  ).whenComplete(() {
    if (_createGroupSheetGeneration == generation) {
      _clearCreateGroupDraft();
    }
  });
}

class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({super.key, this.sheetGeneration});

  final int? sheetGeneration;

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final GroupController _controller = Get.find<GroupController>();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  final RxBool _isSubmitting = false.obs;
  final RxBool _attemptedSubmit = false.obs;

  bool get _ownsActiveDraft =>
      widget.sheetGeneration == null ||
      _createGroupSheetGeneration == widget.sheetGeneration;

  @override
  void dispose() {
    if (_ownsActiveDraft) {
      _clearCreateGroupDraft();
    }
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
      final createdName = _controller.groupName.text;
      _clearCreateGroupDraft();
      Get.back();
      // Stay on the screen the user created from (Home or Walkie group
      // select); the sheet's "Open Group" opens the chat on top of it.
      GroupMembershipSheet.showCreatedFor(
        groupName: createdName,
        groupController: _controller,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bool keyboardOpen = media.viewInsets.bottom > 0;
    final view = View.of(context);
    final double rawViewTopInset =
        view.viewPadding.top / media.devicePixelRatio;
    final double topInset = math.max(media.viewPadding.top, rawViewTopInset);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double rawMaxHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight - topInset - 12.h
            : media.size.height * 0.88;
        final double maxSheetHeight =
            rawMaxHeight.clamp(220.0, media.size.height * 0.90);

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop && _ownsActiveDraft) {
              _clearCreateGroupDraft();
            }
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: Container(
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
                bottom: !keyboardOpen,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Obx(
                    () => Form(
                      key: _controller.createGroupKey,
                      autovalidateMode: _attemptedSubmit.value
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const _SheetHandle(),
                                SizedBox(height: 12.h),
                                _SheetHeader(),
                                SizedBox(height: 12.h),
                                const Divider(
                                    height: 1, color: Color(0xFFF0EEF7)),
                              ],
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() {
                                    final image =
                                        _controller.selectedGroupImage.value;

                                    return Center(
                                      child: GestureDetector(
                                        key: const ValueKey(
                                            'create_group_image_picker'),
                                        onTap: _controller.pickGroupImage,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(3.r),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: const Color(0xFF6B4DFF)
                                                      .withValues(
                                                          alpha: image != null
                                                              ? 0.9
                                                              : 0.4),
                                                  width: 2.w,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF6B4DFF)
                                                            .withValues(
                                                                alpha: 0.14),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: CircleAvatar(
                                                radius: 46.r,
                                                backgroundColor:
                                                    const Color(0xFFEDE7FF),
                                                backgroundImage: image != null
                                                    ? FileImage(
                                                        File(image.path))
                                                    : null,
                                                child: image == null
                                                    ? Icon(
                                                        Icons
                                                            .camera_alt_outlined,
                                                        size: 34.sp,
                                                        color: const Color(
                                                            0xFF6B4DFF),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                            if (image != null)
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: GestureDetector(
                                                  onTap: _controller
                                                      .removeSelectedGroupImage,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.all(2.w),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: CircleAvatar(
                                                      radius: 12.r,
                                                      backgroundColor:
                                                          Colors.red,
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 14.sp,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  SizedBox(height: 12.h),
                                  _FieldLabel(
                                    icon: Icons.groups_outlined,
                                    title: context.l10n.groupDialog_nameLabel,
                                    required: true,
                                  ),
                                  SizedBox(height: 8.h),
                                  _RoundedField(
                                    controller: _controller.groupName,
                                    hint: context.l10n.groupDialog_nameHint,
                                    icon: Icons.groups_outlined,
                                    maxLength: 50,
                                    maxLines: 1,
                                    focusNode: _nameFocus,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) => Validator.validate(
                                      value: value,
                                      title: context.l10n.groupDialog_nameLabel,
                                    ),
                                    onFieldSubmitted: (_) =>
                                        _descFocus.requestFocus(),
                                  ),
                                  SizedBox(height: 10.h),
                                  _FieldLabel(
                                    icon: Icons.description_outlined,
                                    title: context.l10n.groupDialog_descLabel,
                                    required: false,
                                  ),
                                  SizedBox(height: 8.h),
                                  _RoundedField(
                                    controller: _controller.groupDesc,
                                    hint: context.l10n.groupDialog_descHint,
                                    icon: Icons.description_outlined,
                                    maxLength: 200,
                                    maxLines: 1,
                                    focusNode: _descFocus,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                  ),
                                  _CharacterCounter(
                                      controller: _controller.groupDesc),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFF0EEF7)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              20.w,
                              8.h,
                              20.w,
                              keyboardOpen ? 10.h : 16.h,
                            ),
                            child: _SubmitButton(
                              isSubmitting: _isSubmitting.value,
                              onTap: _submit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B78FF), Color(0xFF6B4DFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B4DFF).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child:
              Icon(Icons.group_add_rounded, color: Colors.white, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.groupDialog_createTitle,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontFamily.interBold,
                  color: const Color(0xFF1F1F39),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                context.l10n.groupDialog_fillDetails,
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
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE8EAF1)),
          ),
          child: Icon(icon, size: 16.sp, color: const Color(0xFF6B4DFF)),
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              fontFamily: FontFamily.interBold,
              color: const Color(0xFF1F1F39),
            ),
          ),
        ),
        if (required) ...[
          SizedBox(width: 4.w),
          Text(
            "*",
            style: TextStyle(
              fontSize: 14.5.sp,
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
      scrollPadding: EdgeInsets.only(bottom: 24.h),
      cursorColor: const Color(0xFF6B4DFF),
      style: TextStyle(
        color: const Color(0xFF1F1F39),
        fontSize: 14.5.sp,
        fontWeight: FontWeight.w500,
        fontFamily: FontFamily.interRegular,
      ),
      decoration: InputDecoration(
        counterText: "",
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF6B4DFF).withValues(alpha: 0.45),
          fontSize: 13.5.sp,
        ),
        prefixIcon:
            Icon(icon, color: const Color(0xFF6B4DFF).withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
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
          borderSide: BorderSide(color: const Color(0xFF6B4DFF), width: 1.2.w),
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
        height: 50.h,
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
                      context.l10n.groupDialog_createButton,
                      key: const ValueKey('label'),
                      style: TextStyle(
                        fontSize: 16.5.sp,
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
