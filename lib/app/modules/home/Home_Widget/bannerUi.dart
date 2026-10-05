import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
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
      if (controller.isLoadingBanners.value) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: _buildBannerSkeleton(),
        );
      } else {
        if (controller.bannerList.isEmpty) {
          return const SizedBox();
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: BannerSlider(bannerList: controller.bannerList),
        );
      }
    });
  }
}

class BannerSlider extends StatefulWidget {
  final List<BannerData> bannerList;

  const BannerSlider({super.key, required this.bannerList});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;
  static const int _initialPageFactor = 1000;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.bannerList.length > 1
        ? (widget.bannerList.length * _initialPageFactor)
        : 0;
    _pageController = PageController(initialPage: initialPage);
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant BannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bannerList.length != widget.bannerList.length) {
      _stopAutoPlay();
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    if (widget.bannerList.length <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.bannerList.length;

    return SizedBox(
      height: 160.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: count > 1 ? null : count,
            onPageChanged: (index) {
              if (mounted) {
                setState(() {
                  _currentIndex = index % count;
                });
              }
            },
            itemBuilder: (context, index) {
              final BannerData banner = widget.bannerList[index % count];
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
                  child: CachedNetworkImage(
                    imageUrl: Utility.isNullEmptyOrFalse(banner.imageUrl)
                        ? MyAppTheme.notFoundImg
                        : banner.imageUrl.toString(),
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          if (count > 1)
            Positioned(
              bottom: 8.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(count, (index) {
                  final bool isActive = _currentIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 2.0.w),
                    width: isActive ? 8.0.r : 6.0.r,
                    height: isActive ? 8.0.r : 6.0.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFF6B4DFF)
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
