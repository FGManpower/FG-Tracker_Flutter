import 'dart:async';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/InitializeRepo.dart';
import 'package:fgtracker/app/Data/Repositories/Profile_Repo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Data/Repositories/banner_Repo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:fgtracker/app/Model/initialize_model.dart';
import 'package:fgtracker/app/Model/live_location_model.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/LocationService.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import '../../../Model/banner_model.dart';

class HomeController extends GetxController {
  RxBool ProfileData_loading = false.obs;
  RxString Respone_Error = ''.obs;
  Rx<UserData> userData = UserData().obs;

  StreamSubscription<dynamic>? _groupCountSubscription;
  RxList<BannerData> bannerList = <BannerData>[].obs;
  RxString InitializeResponeMessage = ''.obs;
  RxBool isLoadingBanners = false.obs;
  final RxList<LiveLocationModel> liveLocations = <LiveLocationModel>[].obs;
  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  RxString selectedRadius = '2'.obs;

  final Rx<InitializeModel?> initializeModel = Rx<InitializeModel?>(null);
  final RxBool isInitializing = false.obs;

  bool get canUseWalkie =>
      initializeModel.value?.data?.walkie?.access?.canUseWalkie ?? false;

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  init() {
    fetchInitializeData();


    fetchBanners();
    getProfileData();
    SocketDashboardService().init();
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
      } else {
        isLoadingBanners(false);
      }
    } catch (e) {
      isLoadingBanners(false);
    }
  }

  Future<void> fetchInitializeData() async {
    try {
      isInitializing.value = true;
      final result = await InitializeRepo.getInitializeData();
      if (result.status == true) {
        initializeModel.value = result;
        InitializeResponeMessage.value = "";
      }
    } catch (e) {
      InitializeResponeMessage.value = e.toString();
    } finally {
      isInitializing.value = false;
    }
  }

  @override
  void onClose() {
    _groupCountSubscription?.cancel();
    _positionStreamSubscription?.cancel();

    super.onClose();
  }
}
