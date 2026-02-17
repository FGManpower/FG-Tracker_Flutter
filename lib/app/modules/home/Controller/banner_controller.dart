import 'package:card_swiper/card_swiper.dart';
import 'package:get/get.dart';

class BannerController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> bannerList = <Map<String, dynamic>>[].obs;
  final SwiperController swiperController = SwiperController();

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    await Future.delayed(const Duration(seconds: 2));
    bannerList.assignAll([
      {
        'bannerImage':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-HXvEjUZgwIHKWUSLpkhxu2CMM6GZQGtVGw&s',
        'bannerName': 'Travel The World',
      },
      {
        'bannerImage':
        'https://our.status.im/content/images/2020/03/Secure_Banner_copy.jpg',
        'bannerName': 'Explore Nature',
      },
      {
        'bannerImage':
        'https://trackobit.com/wp-content/uploads/2025/06/bannerImg.png',
        'bannerName': 'Adventure Awaits',
      },
    ]);
    isLoading.value = false;
  }

  void onIndexChanged(int index) {}
}
