import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/local_banner_service.dart';
import 'package:fgtracker/l10n/l10n.dart';
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

  /// Width / height of one banner card (set in build from the real layout).
  /// The crop after picking a photo is locked to this shape.
  double _bannerAspect = 2.0;

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
    return LayoutBuilder(builder: (context, constraints) {
      // Remember the card's real shape (page width minus the 4.w margins,
      // full height) so the crop after picking matches the banner exactly.
      final cardWidth = constraints.maxWidth - 8.w;
      if (cardWidth > 0 && constraints.maxHeight.isFinite &&
          constraints.maxHeight > 0) {
        _bannerAspect = cardWidth / constraints.maxHeight;
      }
      return _localBannerCard();
    });
  }

  Widget _localBannerCard() {
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
                  context.l10n.banner_myBanner,
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
                          context.l10n.banner_customTitle,
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
                            context.l10n.banner_newBadge,
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
                      context.l10n.banner_customSubtitle,
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
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  context.l10n.banner_manageTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                SizedBox(height: 12.h),
                // Current banner preview
                if (_localBannerFile != null)
                  AspectRatio(
                    aspectRatio: _bannerAspect,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: Image.file(_localBannerFile!, fit: BoxFit.cover),
                    ),
                  ),
                SizedBox(height: 14.h),
                _optionRow(
                  key: const ValueKey('banner_replace'),
                  icon: Icons.photo_library_rounded,
                  color: const Color(0xFF6B4DFF),
                  title: context.l10n.banner_replaceTitle,
                  subtitle: context.l10n.banner_replaceSubtitle,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showPickerSheet();
                  },
                ),
                SizedBox(height: 10.h),
                _optionRow(
                  key: const ValueKey('banner_remove'),
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  title: context.l10n.banner_removeTitle,
                  subtitle: context.l10n.banner_removeSubtitle,
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
      ),
    ).then((_) => _startAutoPlay());
  }

  Widget _optionRow({
    Key? key,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      key: key,
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: color == Colors.redAccent
                            ? Colors.redAccent
                            : const Color(0xFF1E1B4B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }

  /// Picks a photo, then opens the cropper locked to the banner's shape so
  /// the saved image fills the banner without being cut unexpectedly.
  Future<void> _pickBanner(ImageSource source) async {
    final file = await LocalBannerService.pickAndSaveBanner(
      source,
      cropAspectRatio: _bannerAspect,
    );
    if (file != null && mounted) {
      setState(() => _localBannerFile = file);
    }
    _startAutoPlay();
  }

  /// Sheet to select Camera or Gallery source
  void _showPickerSheet() {
    _stopAutoPlay();
    const purple = Color(0xFF6B4DFF);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Header
                Row(
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(Icons.add_photo_alternate_rounded,
                          color: purple, size: 22.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.banner_selectPhotoTitle,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E1B4B),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            context.l10n.banner_selectPhotoSubtitle,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Current banner (only when one is set, i.e. "Replace").
                // With no banner yet, nothing is shown here.
                if (_localBannerFile != null) ...[
                  AspectRatio(
                    aspectRatio: _bannerAspect,
                    child: ClipRRect(
                      key: const ValueKey('banner_current_preview'),
                      borderRadius: BorderRadius.circular(14.r),
                      child: Image.file(_localBannerFile!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                // Source options
                Row(
                  children: [
                    Expanded(
                      child: _sourceOption(
                        key: const ValueKey('banner_pick_gallery'),
                        icon: Icons.photo_library_rounded,
                        title: context.l10n.imagePicker_gallery,
                        subtitle: context.l10n.banner_choosePhoto,
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickBanner(ImageSource.gallery);
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _sourceOption(
                        key: const ValueKey('banner_pick_camera'),
                        icon: Icons.camera_alt_rounded,
                        title: context.l10n.imagePicker_camera,
                        subtitle: context.l10n.banner_takePhoto,
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickBanner(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => _startAutoPlay());
  }

  Widget _sourceOption({
    Key? key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const purple = Color(0xFF6B4DFF);
    return Material(
      key: key,
      color: const Color(0xFFF7F5FF),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: purple.withValues(alpha: 0.18)),
          ),
          child: Column(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: const BoxDecoration(
                  color: purple,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
