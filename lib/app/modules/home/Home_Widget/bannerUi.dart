import 'package:card_swiper/card_swiper.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../Model/banner_model.dart';

class BannerUi extends StatelessWidget {
  BannerUi({super.key});

  final HomeController controller = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  Widget _buildBannerSkeleton() {
    return SizedBox(
      height: 160.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: 1,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, index) {
          return Skeletonizer(
            enabled: true,
            child: Container(
              width: MediaQuery.of(Get.context!).size.width - 32.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.BannerResponeMessage.value.isNotEmpty) {
        return LostinternetConnection(
            retry: () {
              controller.fetchBanners();
            },
            messgae: controller.BannerResponeMessage.value.toString());
      } else if (controller.isLoadingBanners.value) {
        return _buildBannerSkeleton();
      } else if (controller.bannerList.isEmpty) {
        return DataEmpty_AssetsIcon(assetspath: Assets.images.notFount.path);
      } else {
        return SizedBox(
          height: 160.h,
          child: Swiper(
            itemCount: controller.bannerList.length,
            autoplay: true,
            autoplayDelay: 3500,
            duration: 800,
            pagination: SwiperPagination(
              alignment: Alignment.bottomCenter,
              builder: DotSwiperPaginationBuilder(
                activeColor: const Color(0xFF6B4DFF),
                color: Colors.white.withValues(alpha: 0.6),
                size: 6.0.r,
                activeSize: 8.0.r,
                space: 4.0.w,
              ),
            ),
            itemBuilder: (BuildContext context, int index) {
              BannerData banner = controller.bannerList[index];

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          Utility.isNullEmptyOrFalse(banner.imageUrl)
                              ? MyAppTheme.notFoundImg
                              : banner.imageUrl.toString(),
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

                      // Positioned(
                      //   left: 16.w,
                      //   top: 16.h,
                      //   bottom: 16.h,
                      //   right: MediaQuery.of(context).size.width * 0.4, // Right side image ke liye space chhoda hai
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       if (!Utility.isNullEmptyOrFalse(banner.title)) ...[
                      //         Text(
                      //           banner.title.toString(),
                      //           style: TextStyle(
                      //             fontSize: 16.sp,
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.black87,
                      //           ),
                      //           maxLines: 2,
                      //           overflow: TextOverflow.ellipsis,
                      //         ),
                      //         SizedBox(height: 6.h),
                      //       ],
                      //       if (!Utility.isNullEmptyOrFalse(banner.description)) ...[
                      //         Text(
                      //           banner.description.toString(),
                      //           style: TextStyle(
                      //             fontSize: 10.sp,
                      //             color: Colors.black54,
                      //             height: 1.2,
                      //           ),
                      //           maxLines: 3,
                      //           overflow: TextOverflow.ellipsis,
                      //         ),
                      //       ],
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    });
  }
}