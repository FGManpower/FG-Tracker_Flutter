import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import '../../../Model/banner_model.dart';

class BannerUi extends StatelessWidget {
  BannerUi({super.key});

  final HomeController controller = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingBanners.value) {
        return Container(
          height: 140.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.bannerList.isEmpty) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 140.h,
        child: Swiper(
          itemCount: controller.bannerList.length,
          autoplay: true,
          autoplayDelay: 3500,
          duration: 800,
          pagination: SwiperPagination(
            alignment: Alignment.bottomCenter,
            builder: DotSwiperPaginationBuilder(
              activeColor: const Color(0xFF6B4DFF),
              color: Colors.white.withOpacity(0.6),
              size: 6.0.r,
              activeSize: 8.0.r,
              space: 4.0.w,
            ),
          ),
          itemBuilder: (BuildContext context, int index) {
            final Data banner = controller.bannerList[index];

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  banner.imageUrl ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    });
  }
}