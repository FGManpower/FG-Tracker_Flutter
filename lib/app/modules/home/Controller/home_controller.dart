import 'dart:async';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/Profile_Repo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Data/Repositories/banner_Repo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
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
  Rx<GroupCountDetail> groupCount = GroupCountDetail().obs;
  StreamSubscription<dynamic>? _groupCountSubscription;
  RxList<BannerData> bannerList = <BannerData>[].obs;
  RxString BannerResponeMessage = ''.obs;
  RxBool isLoadingBanners = false.obs;
  final RxList<LiveLocationModel> liveLocations = <LiveLocationModel>[].obs;
  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  RxString selectedRadius = '2'.obs;

  StreamSubscription<Position>? _positionStreamSubscription;

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
      if (data != null) {
        try {
          final incoming = GroupCountDetail.fromJson(data);
          groupCount.value = groupCount.value.copyWith(
            totalGroups: incoming.totalGroups > 0
                ? incoming.totalGroups
                : groupCount.value.totalGroups,
            totalMembers: incoming.totalMembers > 0
                ? incoming.totalMembers
                : groupCount.value.totalMembers,
            activeMembers: incoming.activeMembers > 0
                ? incoming.activeMembers
                : groupCount.value.activeMembers,
            locationDisabledMembers: incoming.locationDisabledMembers > 0
                ? incoming.locationDisabledMembers
                : groupCount.value.locationDisabledMembers,
          );
        } catch (e) {
          debugPrint("[HomeController] Error parsing groupCount: $e");
        }
      }
    });
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
      }
    } catch (e) {
      isLoadingBanners(false);
      BannerResponeMessage.value = e.toString();
    }
  }

  @override
  void onClose() {
    _groupCountSubscription?.cancel();
    _positionStreamSubscription?.cancel();

    super.onClose();
  }
}
