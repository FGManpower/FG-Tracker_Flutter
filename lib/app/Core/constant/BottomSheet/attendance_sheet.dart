import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../modules/Messages/Controller/GroupChatController.dart';

Future<void> showAttendanceSheet({
  BuildContext? context,
  List<dynamic>? groupMembers,
  VoidCallback? onCreated,
}) {
  return showModalBottomSheet(
    context: context ?? Get.context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => AttendanceSheet(
      groupMembers: groupMembers,
      onCreated: onCreated,
    ),
  );
}

class AttendanceMemberItem {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
  final RxBool isSelected;

  AttendanceMemberItem({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
    bool selected = true,
  }) : isSelected = selected.obs;
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
  final List<dynamic>? groupMembers;
  final VoidCallback? onCreated;

  const AttendanceSheet({
    super.key,
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

  final Rx<DateTime> _selectedDate = DateTime(2026, 9, 9).obs;

  final RxList<AttendanceOptionItem> _options = <AttendanceOptionItem>[
    AttendanceOptionItem(index: 1, text: "Present"),
    AttendanceOptionItem(index: 2, text: "Absent"),
  ].obs;

  final RxList<AttendanceMemberItem> _members = <AttendanceMemberItem>[].obs;
  final RxBool _selectAll = true.obs;
  final RxInt _selectedOptionIndex = 0.obs;

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
  final RxnString _membersError = RxnString();
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

    _initMembers();
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

  void _initMembers() {
    if (widget.groupMembers != null && widget.groupMembers!.isNotEmpty) {
      final List<AttendanceMemberItem> loaded = [];
      for (int i = 0; i < widget.groupMembers!.length; i++) {
        final gm = widget.groupMembers![i];
        final name = gm.name?.toString() ?? "Member ${i + 1}";
        final phone = gm.mobileNo?.toString() ?? "--";
        final avatar = gm.profileImage?.toString();
        loaded.add(
          AttendanceMemberItem(
            id: gm.id?.toString() ?? i.toString(),
            name: name,
            phone: phone,
            avatarUrl: avatar,
            selected: true,
          ),
        );
      }
      _members.assignAll(loaded);
    } else {
      _members.assignAll([
        AttendanceMemberItem(
          id: "1",
          name: "Rahul Verma",
          phone: "+91 98765 43210",
          selected: true,
        ),
        AttendanceMemberItem(
          id: "2",
          name: "Divesh Shinde",
          phone: "+91 98765 67890",
          selected: true,
        ),
      ]);
    }
    _selectAll.value = true;
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
    return DateFormat("dd MMM yyyy, EEE").format(_selectedDate.value);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate =
        _selectedDate.value.isBefore(now) ? _selectedDate.value : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: firstDate,
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5A3EFE),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _selectedDate.value = picked;
    }
  }

  void _addOption() {
    if (_options.length >= _maxOptions) {
      Get.snackbar(
        "Limit Reached",
        "You can add up to $_maxOptions options only",
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
      _onOptionChanged();
    }
  }

  void _toggleSelectAll(bool? val) {
    final next = val ?? !_selectAll.value;
    _selectAll.value = next;
    for (final m in _members) {
      m.isSelected.value = next;
    }
    if (_membersError.value != null && next) {
      _membersError.value = null;
    }
  }

  void _toggleMember(int index) {
    _members[index].isSelected.toggle();
    _selectAll.value = _members.every((m) => m.isSelected.value);
    if (_membersError.value != null &&
        _members.any((m) => m.isSelected.value)) {
      _membersError.value = null;
    }
  }

  bool _validateForm() {
    bool isValid = true;

    // 1. Question validation
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      _questionError.value = "Attendance question is required";
      isValid = false;
    } else if (question.length < 3) {
      _questionError.value = "Question must be at least 3 characters long";
      isValid = false;
    } else {
      _questionError.value = null;
    }

    // 2. Options validation
    if (_options.length < 2) {
      _optionsError.value = "At least 2 options are required";
      isValid = false;
    } else if (_options.any((o) => o.controller.text.trim().isEmpty)) {
      _optionsError.value = "All options must have a label";
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
        _optionsError.value = "Options must be unique";
        isValid = false;
      } else {
        _optionsError.value = null;
      }
    }

    // 3. Members validation
    final selectedMembers = _members.where((m) => m.isSelected.value).toList();
    if (selectedMembers.isEmpty) {
      _membersError.value = "Please select at least 1 group member";
      isValid = false;
    } else {
      _membersError.value = null;
    }

    return isValid;
  }

  Future<void> _submit() async {
    if (_isSubmitting.value) return;

    final isValid = _validateForm();
    if (!isValid) {
      Get.snackbar(
        "Validation Error",
        "Please fix the highlighted errors before submitting",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        borderRadius: 12.r,
      );
      return;
    }

    _isSubmitting.value = true;
    FocusScope.of(context).unfocus();

    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;
    _isSubmitting.value = false;

    Navigator.pop(context);
    widget.onCreated?.call();

    final selectedCount = _members.where((m) => m.isSelected.value).length;

    if (Get.isRegistered<GroupMessageController>()) {
      Get.find<GroupMessageController>().sendAttendanceMessage(
        question: _questionController.text.trim(),
        date: _formattedDate,
        totalMembers: selectedCount,
      );
    }

    Get.snackbar(
      "Attendance Created",
      "Attendance poll sent to $selectedCount members",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF5A3EFE),
      colorText: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      borderRadius: 12.r,
    );
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
                        "Create Attendance",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Send an attendance poll to this group",
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

                  // ── Group Members ──
                  _buildMembersSection(),

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
                                "Create Attendance",
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
                          "Attendance Question",
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
                                  hintText: "Will you be available today?",
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
                Text(
                  _questionError.value!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w500,
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
          child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14.r),
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
                    "Date",
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
                        Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF5A3EFE),
                        size: 24.sp,
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
                      "Ask your community",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Add options for members to respond",
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
                              "Option ${index + 1}",
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
                                hintText: "Enter option label",
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
                  Text(
                    _optionsError.value!,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
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
                    "Add Another Option",
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

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.groups_rounded,
                color: const Color(0xFF5A3EFE),
                size: 18.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Obx(
              () => Text(
                "Group Members (${_members.length})",
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF5A3EFE),
              size: 20.sp,
            ),
            const Spacer(),
            Text(
              "Select All",
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(width: 6.w),
            Obx(
              () => GestureDetector(
                onTap: () => _toggleSelectAll(null),
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    color: _selectAll.value
                        ? const Color(0xFF5A3EFE)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                      color: _selectAll.value
                          ? const Color(0xFF5A3EFE)
                          : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: _selectAll.value
                      ? Icon(
                          Icons.check_rounded,
                          size: 13.sp,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
        Obx(() {
          if (_membersError.value == null) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: const Color(0xFFEF4444),
                  size: 13.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  _membersError.value!,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 8.h),
        Obx(
          () => Column(
            children: _members.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              return Obx(
                () => Container(
                  margin: EdgeInsets.only(top: 8.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _membersError.value != null &&
                              !member.isSelected.value
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFFF1F5F9),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: const Color(0xFFE2E8F0),
                        child: ClipOval(
                          child: member.avatarUrl != null &&
                                  member.avatarUrl!.isNotEmpty
                              ? Image.network(
                                  member.avatarUrl!,
                                  fit: BoxFit.cover,
                                  width: 40.r,
                                  height: 40.r,
                                  errorBuilder: (_, __, ___) =>
                                      _avatarFallback(member.name),
                                )
                              : _avatarFallback(member.name),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              member.phone,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleMember(index),
                        child: Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: member.isSelected.value
                                ? const Color(0xFF5A3EFE)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: member.isSelected.value
                                  ? const Color(0xFF5A3EFE)
                                  : const Color(0xFFCBD5E1),
                              width: 1.5,
                            ),
                          ),
                          child: member.isSelected.value
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 16.sp,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback(String name) {
    final initials = name.isNotEmpty
        ? name
            .trim()
            .split(" ")
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : "")
            .take(2)
            .join()
        : "U";
    return Container(
      width: 40.r,
      height: 40.r,
      color: const Color(0xFFE0E7FF),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5A3EFE),
        ),
      ),
    );
  }
}
