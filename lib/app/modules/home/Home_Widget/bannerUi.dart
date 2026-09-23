import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
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
        return BannerCarousel(
          banners: controller.bannerList.toList(),
        );
      }
    });
  }
}

class BannerCarousel extends StatefulWidget {
  final List<BannerData> banners;

  const BannerCarousel({
    super.key,
    required this.banners,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initController();
    _startAutoPlay();
  }

  void _initController() {
    _pageController = PageController(
      initialPage: widget.banners.length > 1 ? 1 : 0,
    );
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.banners.length <= 1) return;

    _timer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      final page = _pageController.page?.round() ?? 1;
      _pageController.animateToPage(
        page + 1,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  void _pauseAutoPlay() {
    _timer?.cancel();
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _timer?.cancel();
      _pageController.dispose();
      _currentIndex = 0;
      _initController();
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBannerCard(BannerData banner) {
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
          fit: BoxFit.cover,
          width: double.infinity,
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
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;

    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    if (banners.length == 1) {
      return SizedBox(
        height: 160.h,
        child: _buildBannerCard(banners.first),
      );
    }

    final virtualCount = banners.length + 2;

    return SizedBox(
      height: 160.h,
      child: Listener(
        onPointerDown: (_) => _pauseAutoPlay(),
        onPointerUp: (_) => _startAutoPlay(),
        onPointerCancel: (_) => _startAutoPlay(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              final page = _pageController.page?.round() ?? 1;
              if (page == virtualCount - 1) {
                _pageController.jumpToPage(1);
              } else if (page == 0) {
                _pageController.jumpToPage(banners.length);
              }
            }
            return false;
          },
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: virtualCount,
                onPageChanged: (index) {
                  int realIndex;
                  if (index == 0) {
                    realIndex = banners.length - 1;
                  } else if (index == virtualCount - 1) {
                    realIndex = 0;
                  } else {
                    realIndex = index - 1;
                  }
                  if (_currentIndex != realIndex) {
                    setState(() {
                      _currentIndex = realIndex;
                    });
                  }
                },
                itemBuilder: (context, index) {
                  int realIndex;
                  if (index == 0) {
                    realIndex = banners.length - 1;
                  } else if (index == virtualCount - 1) {
                    realIndex = 0;
                  } else {
                    realIndex = index - 1;
                  }
                  return _buildBannerCard(banners[realIndex]);
                },
              ),
              Positioned(
                bottom: 10.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(banners.length, (index) {
                    final isActive = index == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      width: isActive ? 8.r : 6.r,
                      height: isActive ? 8.r : 6.r,
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
        ),
      ),
    );
  }
}
