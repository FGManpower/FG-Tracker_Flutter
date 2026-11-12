import 'package:flutter/material.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fgtracker/app/Core/util/rt_log.dart';

import '../../../modules/Attendance/controller/attendance_controller.dart';

Future<void> showAttendanceSheet({
  BuildContext? context,
  required int groupId,
  List<dynamic>? groupMembers,
  void Function(Map<String, dynamic> data)? onCreated,
}) {
  return showModalBottomSheet(
    context: context ?? Get.context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => AttendanceSheet(
      groupId: groupId,
      groupMembers: groupMembers,
      onCreated: onCreated,
    ),
  );
}

class AttendanceOptionItem {
  final int index;
  final TextEditingController controller;

  AttendanceOptionItem({
    required this.index,
    required String text,
  }) : controller = TextEditingController(text: text);
}

class AttendanceSheet extends StatefulWidget {
  final int groupId;
  final List<dynamic>? groupMembers;

  /// Receives the create response (attendanceId, messageId, ...) so the chat
  /// can show the attendance card immediately.
  final void Function(Map<String, dynamic> data)? onCreated;

  const AttendanceSheet({
    super.key,
    required this.groupId,
    this.groupMembers,
    this.onCreated,
  });

  @override
  State<AttendanceSheet> createState() => _AttendanceSheetState();
}

class _AttendanceSheetState extends State<AttendanceSheet> {
  late final TextEditingController _questionController;
  final RxInt _questionLength = 28.obs;
  static const int _maxQuestionLength = 100;
  static const int _maxOptions = 6;

  /// Attendance is always for today: the date is fixed (not editable) and is
  /// re-read on submit, so a sheet left open past midnight uses the new day.
  final Rx<DateTime> _selectedDate = DateUtils.dateOnly(DateTime.now()).obs;

  final RxList<AttendanceOptionItem> _options = <AttendanceOptionItem>[
    AttendanceOptionItem(index: 1, text: "Present"),
    AttendanceOptionItem(index: 2, text: "Absent"),
  ].obs;

  /// Option that requires a live photo (-1 = none). Defaults to "Present".
  final RxInt _selectedOptionIndex = 0.obs;
  final RxBool _allowVoteChange = true.obs;
  /// "Close at end of day" is coming soon: off and not changeable for now.
  final RxBool _autoClose = false.obs;

  void _toggleOption(int index) {
    if (_selectedOptionIndex.value == index) {
      _selectedOptionIndex.value = -1;
    } else {
      _selectedOptionIndex.value = index;
    }
  }

  // Validation States
  final RxnString _questionError = RxnString();
  final RxnString _optionsError = RxnString();
  final RxBool _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: "Will you be available today?");
    _questionLength.value = _questionController.text.length;

    _questionController.addListener(() {
      _questionLength.value = _questionController.text.length;
      if (_questionError.value != null &&
          _questionController.text.trim().length >= 3) {
        _questionError.value = null;
      }
    });

    for (final opt in _options) {
      opt.controller.addListener(_onOptionChanged);
    }
  }

  void _onOptionChanged() {
    if (_optionsError.value != null) {
      final allFilled =
      _options.every((o) => o.controller.text.trim().isNotEmpty);
      if (allFilled) {
        _optionsError.value = null;
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final opt in _options) {
      opt.controller.removeListener(_onOptionChanged);
      opt.controller.dispose();
    }
    super.dispose();
  }

  String get _formattedDate {
    return appDateFormat("dd MMM yyyy, EEE").format(_selectedDate.value);
  }

  void _addOption() {
    if (_options.length >= _maxOptions) {
      Get.snackbar(
        appL10n.attendance_limitReached,
        appL10n.attendance_maxOptions(_maxOptions),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF1F5F9),
        colorText: const Color(0xFF0F172A),
      );
      return;
    }
    final newIdx = _options.length + 1;
    final opt = AttendanceOptionItem(index: newIdx, text: "");
    opt.controller.addListener(_onOptionChanged);
    _options.add(opt);
  }

  void _removeOption(int index) {
    if (_options.length > 2) {
      final removed = _options.removeAt(index);
      removed.controller.removeListener(_onOptionChanged);
      removed.controller.dispose();
      final photoIdx = _selectedOptionIndex.value;
      if (photoIdx == index) {
        _selectedOptionIndex.value = -1;
      } else if (photoIdx > index) {
        _selectedOptionIndex.value = photoIdx - 1;
      }
      _onOptionChanged();
    }
  }

  bool _validateForm() {
    bool isValid = true;

    // 1. Question validation
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      _questionError.value = appL10n.attendance_questionRequired;
      isValid = false;
    } else if (question.length < 3) {
      _questionError.value = appL10n.attendance_questionTooShort(3);
      isValid = false;
    } else {
      _questionError.value = null;
    }

    // 2. Options validation
    if (_options.length < 2) {
      _optionsError.value = appL10n.attendance_minOptions(2);
      isValid = false;
    } else if (_options.any((o) => o.controller.text.trim().isEmpty)) {
      _optionsError.value = appL10n.attendance_optionLabelRequired;
      isValid = false;
    } else {
      final uniqueSet = <String>{};
      bool hasDuplicate = false;
      for (final opt in _options) {
        final text = opt.controller.text.trim().toLowerCase();
        if (uniqueSet.contains(text)) {
          hasDuplicate = true;
          break;
        }
        uniqueSet.add(text);
      }
      if (hasDuplicate) {
        _optionsError.value = appL10n.attendance_optionsUnique;
        isValid = false;
      } else {
        _optionsError.value = null;
      }
    }

    return isValid;
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      borderRadius: 12.r,
    );
  }

  Future<void> _submit() async {
    rtLog("[ATTENDANCE_DEBUG] submit tapped (groupId=${widget.groupId})");
    if (_isSubmitting.value) return;

    final isValid = _validateForm();
    rtLog("[ATTENDANCE_DEBUG] validation => $isValid "
        "q=${_questionError.value} opt=${_optionsError.value}");
    if (!isValid) {
      _showError(
        appL10n.attendance_validationError,
        _questionError.value ??
            _optionsError.value ??
            appL10n.attendance_fixErrors,
      );
      return;
    }

    if (widget.groupId <= 0) {
      _showError(appL10n.attendance_failed, appL10n.attendance_invalidGroup);
      return;
    }

    final options = _options.map((o) => o.controller.text.trim()).toList();
    final photoIdx = _selectedOptionIndex.value;
    final photoOption =
        photoIdx >= 0 && photoIdx < options.length ? options[photoIdx] : null;
    _selectedDate.value = DateUtils.dateOnly(DateTime.now());
    final date = _selectedDate.value;
    final deadline = _autoClose.value
        ? DateTime(date.year, date.month, date.day, 23, 59)
        : null;
    if (deadline != null && deadline.isBefore(DateTime.now())) {
      _showError(appL10n.attendance_failed,
          appL10n.attendance_dateEnded);
      return;
    }

    _isSubmitting.value = true;
    FocusScope.of(context).unfocus();

    try {
      rtLog("[ATTENDANCE_DEBUG] request sent: groupId=${widget.groupId} "
          "date=$date photoOption=$photoOption deadline=$deadline");
      final data = await AttendanceController.instance.createPoll(
        groupId: widget.groupId,
        title: "Attendance • ${DateFormat("dd MMM").format(date)}",
        description: _questionController.text.trim(),
        eventDate: date,
        options: options,
        photoRequiredOptionLabel: photoOption,
        allowVoteChange: _allowVoteChange.value,
        deadlineAt: deadline,
      );
      rtLog("[ATTENDANCE_DEBUG] response received: $data");

      widget.onCreated?.call(data);
      rtLog("[ATTENDANCE_DEBUG] message added to chat (messageId=${data["messageId"]})");

      if (!mounted) return;
      Navigator.pop(context);
      rtLog("[ATTENDANCE_DEBUG] sheet closed");

      Get.snackbar(
        appL10n.attendance_created,
        appL10n.attendance_sentToGroup,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF5A3EFE),
        colorText: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        borderRadius: 12.r,
      );
    } catch (e, st) {
      rtLog("[ATTENDANCE_DEBUG] create failed: $e\n$st");
      _showError(appL10n.attendance_failed, e.toString());
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top Handle ──
          SizedBox(height: 10.h),
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // ── Header Row ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.event_available_rounded,
                    color: const Color(0xFF5A3EFE),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appL10n.attendance_createTitle,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        appL10n.attendance_createSubtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF5A3EFE),
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // ── Scrollable Body ──
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Question Input ──
                  _buildQuestionSection(),

                  SizedBox(height: 12.h),

                  // ── Date Selector ──
                  _buildDateSection(),

                  SizedBox(height: 14.h),

                  // ── Poll Options ──
                  _buildPollSection(),

                  SizedBox(height: 14.h),

                  // ── Settings ──
                  _buildSettingsSection(),

                  SizedBox(height: 18.h),
                ],
              ),
            ),
          ),

          // ── Bottom Create Attendance Button ──
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: Obx(
                      () => ElevatedButton(
                    onPressed: _isSubmitting.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A3EFE),
                      disabledBackgroundColor:
                      const Color(0xFF5A3EFE).withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: _isSubmitting.value
                        ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 14.sp,
                            color: const Color(0xFF5A3EFE),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          appL10n.attendance_createTitle,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.assignment_outlined,
                color: const Color(0xFF5A3EFE),
                size: 22.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Obx(
                    () {
                  final hasError = _questionError.value != null;
                  return Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: hasError
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE2E8F0),
                        width: hasError ? 1.4 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appL10n.attendance_questionLabel,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: hasError
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _questionController,
                                maxLength: _maxQuestionLength,
                                buildCounter: (
                                    _, {
                                      required currentLength,
                                      required isFocused,
                                      maxLength,
                                    }) =>
                                null,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: appL10n.attendance_questionHint,
                                  hintStyle: TextStyle(
                                    fontSize: 13.5.sp,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ),
                            Obx(
                                  () => Text(
                                "${_questionLength.value}/$_maxQuestionLength",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: _questionLength.value >=
                                      _maxQuestionLength
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Obx(() {
          if (_questionError.value == null) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(left: 54.w, top: 4.h),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: const Color(0xFFEF4444),
                  size: 13.sp,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    _questionError.value!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.calendar_month_rounded,
            color: const Color(0xFF5A3EFE),
            size: 22.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          // Fixed to today: no date picker.
          child: Semantics(
            label: appL10n.attendance_dateTodaySemantics,
            readOnly: true,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appL10n.attendance_dateToday,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                            () => Text(
                          _formattedDate,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.lock_outline_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 18.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPollSection() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FE),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: const Color(0xFF5A3EFE),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appL10n.attendance_askCommunity,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      appL10n.attendance_selectPhotoOption,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Obx(
                () => Column(
              children: _options.asMap().entries.map((entry) {
                final index = entry.key;
                final opt = entry.value;
                final hasError = _optionsError.value != null &&
                    opt.controller.text.trim().isEmpty;
                final isSelected = _selectedOptionIndex.value == index;

                return GestureDetector(
                    onTap: () => _toggleOption(index),
                    child: Container(
                      margin: EdgeInsets.only(top: 8.h),
                      padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: hasError
                              ? const Color(0xFFEF4444)
                              : (isSelected
                              ? const Color(0xFF5A3EFE)
                              : const Color(0xFFEEF2F6)),
                          width: (hasError || isSelected) ? 1.4 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _toggleOption(index),
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 20.w,
                                height: 20.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF5A3EFE)
                                        : const Color(0xFF94A3B8),
                                    width: isSelected ? 2.0 : 1.8,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                  child: Container(
                                    width: 10.w,
                                    height: 10.w,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF5A3EFE),
                                    ),
                                  ),
                                )
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSelected
                                      ? appL10n.attendance_optionPhotoRequired(index + 1)
                                      : appL10n.attendance_optionNumber(index + 1),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextField(
                                  controller: opt.controller,
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    hintText: appL10n.attendance_optionHint,
                                    hintStyle: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_options.length > 2) ...[
                            GestureDetector(
                              onTap: () => _removeOption(index),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.red.shade300,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                          ],
                          Icon(
                            Icons.drag_indicator_rounded,
                            color: const Color(0xFFA5B4FC),
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ));
              }).toList(),
            ),
          ),
          Obx(() {
            if (_optionsError.value == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: 8.h, left: 4.w),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: const Color(0xFFEF4444),
                    size: 13.sp,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      _optionsError.value!,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 10.h),
          InkWell(
            onTap: _addOption,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFA5B4FC),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_rounded,
                    color: const Color(0xFF5A3EFE),
                    size: 18.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    appL10n.attendance_addOption,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5A3EFE),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    Widget toggleRow({
      required IconData icon,
      required String title,
      required String subtitle,
      required RxBool value,
      bool comingSoon = false,
    }) {
      final mutedColor = const Color(0xFF94A3B8);
      // A "coming soon" row never reads [value], and an Obx without any
      // observable read throws GetX's "improper use" error, so only live
      // rows are wrapped in Obx.
      Widget buildRow(bool current) => Container(
          margin: EdgeInsets.only(top: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: comingSoon ? const Color(0xFFF8FAFC) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFEEF2F6)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: comingSoon ? mutedColor : const Color(0xFF5A3EFE),
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 2.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: comingSoon
                                ? mutedColor
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        if (comingSoon)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(20.r),
                              border:
                                  Border.all(color: const Color(0xFFFED7AA)),
                            ),
                            child: Text(
                              appL10n.common_comingSoon,
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFC2410C),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: comingSoon
                            ? mutedColor
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: current,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF5A3EFE),
                // null disables the switch (greyed out, not tappable).
                onChanged: comingSoon ? null : (v) => value.value = v,
              ),
            ],
          ),
        );

      if (comingSoon) return buildRow(false);
      return Obx(() => buildRow(value.value));
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FE),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appL10n.common_settings,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            appL10n.attendance_sentToAllMembers,
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          toggleRow(
            icon: Icons.swap_horiz_rounded,
            title: appL10n.attendance_allowChange,
            subtitle: appL10n.attendance_allowChangeSubtitle,
            value: _allowVoteChange,
          ),
          toggleRow(
            icon: Icons.timer_outlined,
            title: appL10n.attendance_closeEndOfDay,
            subtitle: appL10n.attendance_closeEndOfDaySubtitle(
                appTime(DateTime(2000, 1, 1, 23, 59))),
            value: _autoClose,
            comingSoon: true,
          ),
        ],
      ),
    );
  }
}
