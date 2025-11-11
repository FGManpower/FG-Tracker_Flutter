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
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
        'bannerName': 'Travel The World',
      },
      {
        'bannerImage':
        'https://images.unsplash.com/photo-1522202176988-66273c2fd55f',
        'bannerName': 'Explore Nature',
      },
      {
        'bannerImage':
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
        'bannerName': 'Adventure Awaits',
      },
    ]);
    isLoading.value = false;
  }

  void onIndexChanged(int index) {}
}
