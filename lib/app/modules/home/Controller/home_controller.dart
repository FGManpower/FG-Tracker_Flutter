import 'dart:async';

import 'package:fgtracker/app/Data/Repositories/Profile_Repo.dart';
import 'package:fgtracker/app/Data/Repositories/banner_Repo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:get/get.dart';

import '../../../Model/banner_model.dart';

class HomeController extends GetxController {
  RxBool ProfileData_loading = false.obs;
  RxString Respone_Error = ''.obs;

  Rx<UserData> userData = UserData().obs;
  Rx<GroupCountDetail> groupCount = GroupCountDetail().obs;
  StreamSubscription<dynamic>? _groupCountSubscription;

  RxList<BannerData> bannerList = <BannerData>[].obs;
  RxString BannerResponeMessage = ''.obs;
  RxBool isLoadingBanners = false.obs;

  @override
  void onInit() {
    super.onInit();
    SocketDashboardService.instance.init();
    _listenGroupCount();
    fetchBanners();
  }

  void _listenGroupCount() {
    _groupCountSubscription?.cancel();
    _groupCountSubscription =
        SocketDashboardService.instance.groupCountStream.listen((data) {
      groupCount.value = GroupCountDetail.fromJson(data);
    });
  }

  void refreshGroupCount() {
    SocketDashboardService.instance.requestGroupCount();
  }

  Future<void> getProfileData() async {
    try {
      ProfileData_loading.value = true;
      final profileData = await ProfileRepo.getProfileData();
      if (profileData.status == true) {
        userData.value = profileData.data!;
        Respone_Error.value = '';
      }
    } catch (e) {
      Respone_Error.value = e.toString();
    } finally {
      ProfileData_loading.value = false;
    }
  }

  Future<void> fetchBanners() async {
    try {
      isLoadingBanners.value = true;

      var result = await BannerRepo.getBanner();
      if (result.success == true) {
        isLoadingBanners(false);
        bannerList.value = result.data!;
        BannerResponeMessage.value = "";
      } else {
        isLoadingBanners(false);
        // BannerResponeMessage.value = result.message.toString();
      }
    } catch (e) {
      isLoadingBanners(false);
      BannerResponeMessage.value = e.toString();
    }
  }

  @override
  void onClose() {
    _groupCountSubscription?.cancel();
    super.onClose();
  }
}
