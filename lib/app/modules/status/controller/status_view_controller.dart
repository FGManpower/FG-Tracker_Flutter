import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';

class StatusViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final int totalStatuses;
  final int initialIndex;

  StatusViewController({
    required this.totalStatuses,
    required this.initialIndex,
  });

  late AnimationController progressController;
  final TextEditingController replyController = TextEditingController();
  final LayerLink menuLink = LayerLink();
  OverlayEntry? menuEntry;

  var currentIndex = 0.obs;
  var isLiked = false.obs;
  var hasText = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = initialIndex;

    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        goNext();
      }
    });
    progressController.forward();

    replyController.addListener(() {
      hasText.value = replyController.text.trim().isNotEmpty;
    });
  }

  @override
  void onClose() {
    removeMenu();
    progressController.dispose();
    replyController.dispose();
    super.onClose();
  }

  void goNext() {
    if (currentIndex.value < totalStatuses - 1) {
      currentIndex.value++;
      progressController.forward(from: 0.0);
    } else {
      Get.back();
    }
  }

  void goPrev() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      progressController.forward(from: 0.0);
    } else {
      progressController.forward(from: 0.0);
    }
  }

  void pause() {
    progressController.stop();
  }

  void resume() {
    if (menuEntry == null) {
      progressController.forward();
    }
  }

  void toggleLike() {
    isLiked.value = !isLiked.value;
  }

  void sendReply() {
    final text = replyController.text.trim();
    if (text.isEmpty) return;

    replyController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    resume();

    Get.snackbar(
      "Reply sent",
      text,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF6B4DFF),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(12.w),
      borderRadius: 12.r,
    );
  }

  void removeMenu() {
    menuEntry?.remove();
    menuEntry = null;
  }

  void showMenu(BuildContext context) {
    removeMenu();
    pause();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    menuEntry = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  removeMenu();
                  resume();
                },
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: menuLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: Offset(0, 8.h),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200.w,
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _menuItem(Icons.download_rounded, "Save to Gallery"),
                      _menuItem(Icons.share_rounded, "Share"),
                      _menuItem(Icons.delete_outline_rounded, "Delete Status"),
                      _menuItem(Icons.info_outline_rounded, "Status Privacy"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(menuEntry!);
  }

  Widget _menuItem(IconData icon, String label) {
    return InkWell(
      onTap: () {
        removeMenu();
        resume();
      },
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2B1B54), size: 20.sp),
            SizedBox(width: 12.w),
            reausabletext(
              label,
              fontsize: 13.sp,
              fontfamily: FontFamily.interMedium,
              color: const Color(0xFF2B1B54),
            ),
          ],
        ),
      ),
    );
  }
}