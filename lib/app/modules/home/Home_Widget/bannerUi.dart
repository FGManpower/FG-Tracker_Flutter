import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/local_banner_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _localBannerFile;
  bool _isLoadingLocal = true;

  @override
  void initState() {
    super.initState();
    _loadLocalBanner();

    final int count = _totalSlides;
    final initialPage = count > 1 ? (count * _initialPageFactor) : 0;
    _pageController = PageController(initialPage: initialPage);
    _startAutoPlay();
  }

  Future<void> _loadLocalBanner() async {
    final file = await LocalBannerService.getLocalBanner();
    if (mounted) {
      setState(() {
        _localBannerFile = file;
        _isLoadingLocal = false;
      });
    }
  }

  /// Up to 7 API banners + 1 dedicated 8th Local Custom Banner slide
  int get _apiCount {
    return widget.bannerList.length > 7 ? 7 : widget.bannerList.length;
  }

  int get _totalSlides {
    return _apiCount + 1;
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
    if (_totalSlides <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 3800), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 700),
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
    if (_isLoadingLocal) {
      return SizedBox(
        height: 160.h,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final int count = _totalSlides;
    final int apiCount = _apiCount;

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
              final int slideIndex = index % count;

              // Slides 0 through (apiCount - 1) -> Remote API Banners
              if (slideIndex < apiCount) {
                final BannerData banner = widget.bannerList[slideIndex];
                return _buildApiBanner(banner);
              }

              // Final Slide (index == apiCount) -> Local Custom User Banner
              return _buildLocalBannerSlide();
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
                  final bool isLocalSlide = index == (count - 1);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 2.5.w),
                    width: isActive ? 12.0.w : 6.0.r,
                    height: 6.0.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.r),
                      color: isActive
                          ? (isLocalSlide
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF6B4DFF))
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

  /// Renders server-fetched API promotional banners
  Widget _buildApiBanner(BannerData banner) {
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
          memCacheWidth: 800,
          maxWidthDiskCache: 1200,
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

  /// Renders the 8th Local Custom Banner (either user's image or upload prompt)
  Widget _buildLocalBannerSlide() {
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
        child: _localBannerFile != null
            ? _buildCustomBannerView()
            : _buildUploadPromptCard(),
      ),
    );
  }

  /// State 1: When user has uploaded their custom banner
  Widget _buildCustomBannerView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          _localBannerFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Top Right Badge: "My Banner"
        Positioned(
          top: 10.h,
          right: 10.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_pin_rounded, color: Colors.white, size: 13.sp),
                SizedBox(width: 4.w),
                Text(
                  "My Banner",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Tap overlay to manage banner
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showOptionsSheet,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.all(10.r),
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 16.sp,
                  color: const Color(0xFF6B4DFF),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// State 2: When user has not uploaded yet (Interactive upload prompt)
  Widget _buildUploadPromptCard() {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: _showPickerSheet,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF6B4DFF).withValues(alpha: 0.35),
              width: 1.5,
            ),
            gradient: const LinearGradient(
              colors: [Color(0xFFF5F3FF), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4DFF).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_photo_alternate_rounded,
                  color: const Color(0xFF6B4DFF),
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Custom Banner",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1B4B),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B4DFF),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            "NEW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Upload your own photo or company banner. Displays only on your phone!",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: Colors.grey.shade600,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: const Color(0xFF6B4DFF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sheet to Replace or Delete an existing custom banner
  void _showOptionsSheet() {
    _stopAutoPlay();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 14.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Text(
                "Manage Custom Banner",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: Color(0xFF6B4DFF)),
                title: Text("Replace Banner", style: TextStyle(fontSize: 14.sp)),
                subtitle: Text("Select a new photo from Gallery or Camera",
                    style: TextStyle(fontSize: 11.sp)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showPickerSheet();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent),
                title: Text("Remove Banner",
                    style: TextStyle(
                        color: Colors.redAccent, fontSize: 14.sp)),
                subtitle: Text("Revert back to default upload slot",
                    style: TextStyle(fontSize: 11.sp)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await LocalBannerService.deleteLocalBanner();
                  if (mounted) {
                    setState(() => _localBannerFile = null);
                  }
                  _startAutoPlay();
                },
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _startAutoPlay());
  }

  /// Sheet to select Camera or Gallery source
  void _showPickerSheet() {
    _stopAutoPlay();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 14.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Text(
                "Select Banner Photo",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: Color(0xFF6B4DFF)),
                title: Text("Choose from Gallery",
                    style: TextStyle(fontSize: 14.sp)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await LocalBannerService.pickAndSaveBanner(
                      ImageSource.gallery);
                  if (file != null && mounted) {
                    setState(() => _localBannerFile = file);
                  }
                  _startAutoPlay();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: Color(0xFF6B4DFF)),
                title:
                    Text("Take a Photo", style: TextStyle(fontSize: 14.sp)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await LocalBannerService.pickAndSaveBanner(
                      ImageSource.camera);
                  if (file != null && mounted) {
                    setState(() => _localBannerFile = file);
                  }
                  _startAutoPlay();
                },
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _startAutoPlay());
  }
}
