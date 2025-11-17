import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:fgtracker/app/modules/home/Controller/banner_controller.dart';

class BannerUi extends StatelessWidget {
  final BannerController controller = Get.put(BannerController());

  BannerUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Skeletonizer(
        enabled: controller.isLoading.value,
        child: SizedBox(
          height: 160.h,
          child: Swiper(
            controller: controller.swiperController,
            scrollDirection: Axis.horizontal,
            autoplay: false,
            autoplayDelay: 4000,
            duration: 800,
            curve: Curves.easeInOut,
            itemBuilder: (BuildContext context, int index) {
              final banner = controller.bannerList.isNotEmpty
                  ? controller.bannerList[index]
                  : null;

              return Padding(
                padding: EdgeInsets.all(8.0.r),
                child: GestureDetector(
                  child: Container(
                    height: 160.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      image: DecorationImage(
                        image: NetworkImage(
                          banner?['bannerImage'] ??
                              'https://via.placeholder.com/400x200?text=Loading...',
                        ),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: controller.bannerList.isEmpty
                ? 3
                : controller.bannerList.length,
            pagination: SwiperPagination(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(bottom: 20.h),
              builder: DotSwiperPaginationBuilder(
                color: Colors.grey,
                activeColor: Colors.deepPurple,
                size: 8.sp,
              ),
            ),
            onIndexChanged: (index) => controller.onIndexChanged(index),
          ),
        ),
      );
    });
  }
}
