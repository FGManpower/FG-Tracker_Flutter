import 'package:fgtracker/app/modules/mediaStream/controller/call_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CallDialPad extends StatelessWidget {
  const CallDialPad({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CallController.instance;

    return Obx(() {
      if (!controller.isDialPadOpen.value) return const SizedBox.shrink();

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 9.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 8.h),
            _buildDisplayBox(controller),
            SizedBox(height: 11.h),
            _buildKeypad(controller),
            SizedBox(height: 7.h),
            _buildActionControlRow(controller),
            SizedBox(height: 7.h),
          ],
        ),
      );
    });
  }

  Widget _buildDisplayBox(CallController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4FB),
        borderRadius: BorderRadius.circular(10.r),
      ),
      alignment: Alignment.center,
      child: Obx(() {
        final number = controller.dialNumber.value;

        return Text(
          number.isEmpty ? "Enter number" : number,
          style: TextStyle(
            fontSize: number.isEmpty ? 13.sp : 20.sp,
            fontFamily: FontFamily.interBold,
            color: number.isEmpty
                ? Colors.grey
                : const Color(0xFF4818F0),
            letterSpacing: number.isEmpty ? 0 : 1.3,
          ),
        );
      }),
    );
  }

  Widget _buildKeypad(CallController controller) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
    ];

    final labels = [
      ['', 'ABC', 'DEF'],
      ['GHI', 'JKL', 'MNO'],
      ['PQRS', 'TUV', 'WXYZ'],
      ['', '+', ''],
    ];

    return Column(
      children: List.generate(4, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(bottom: 5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (colIndex) {
              final val = keys[rowIndex][colIndex];
              final sub = labels[rowIndex][colIndex];

              return _DialPadButton(
                digit: val,
                subLabel: sub,
                onTap: () => controller.addDigit(val),
                onLongPress: val == '0'
                    ? () => controller.addDigit('+')
                    : null,
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildActionControlRow(CallController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: controller.removeLastDigit,
          onLongPress: controller.clearDialNumber,
          child: Container(
            width: 52.w,
            height: 52.w,
            alignment: Alignment.center,
            child: Icon(
              Icons.backspace_outlined,
              size: 21.sp,
              color: const Color(0xFF6B4DFF),
            ),
          ),
        ),
        GestureDetector(
          onTap: controller.makeCall,
          child: Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: const Color(0xFF4818F0),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4818F0).withValues(alpha: 0.3),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.call,
              size: 23.sp,
              color: Colors.white,
            ),
          ),
        ),
        GestureDetector(
          onTap: controller.toggleDialPad,
          child: Container(
            width: 52.w,
            height: 52.w,
            alignment: Alignment.center,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 27.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialPadButton extends StatefulWidget {
  const _DialPadButton({
    required this.digit,
    required this.subLabel,
    required this.onTap,
    this.onLongPress,
  });

  final String digit;
  final String subLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<_DialPadButton> createState() => _DialPadButtonState();
}

class _DialPadButtonState extends State<_DialPadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 58.w,
        height: 58.w,
        decoration: BoxDecoration(
          color: _isPressed
              ? const Color(0xFF4818F0).withValues(alpha: 0.15)
              : const Color(0xFFF5F4FB),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.digit,
              style: TextStyle(
                fontSize: 21.sp,
                fontFamily: FontFamily.interBold,
                color: Colors.black87,
                height: 1.0,
              ),
            ),
            if (widget.subLabel.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text(
                widget.subLabel,
                style: TextStyle(
                  fontSize: 7.sp,
                  fontFamily: FontFamily.interSemiBold,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.1,
                  height: 0.9,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}