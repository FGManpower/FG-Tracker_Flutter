import 'dart:async';

import 'package:fgtracker/app/Data/Repositories/Profile_Repo.dart';
import 'package:fgtracker/app/Data/Repositories/banner_Repo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:fgtracker/app/Model/live_location_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  StreamSubscription<List<LiveLocationModel>>? _liveLocationSubscription;



  @override
  void onInit() {
    super.onInit();
    startLiveLocationSession();
    SocketDashboardService.instance.init();

    _listenGroupCount();
    _listenLiveLocations();

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
      }
    } catch (e) {
      isLoadingBanners(false);
      BannerResponeMessage.value = e.toString();
    }
  }


  void _listenLiveLocations() {
    _liveLocationSubscription?.cancel();

    _liveLocationSubscription =
        SocketDashboardService.instance.liveLocationStream.listen(
              (locations) {
            liveLocations.assignAll(locations);
          },
        );
  }

  void requestLiveMembers({
    required double latitude,
    required double longitude,
    double radius = 2,
  }) {
    SocketDashboardService.instance.requestLiveLocation(
      userLat: latitude,
      userLong: longitude,
      radius: radius,
    );
  }

  Future<void> startLiveLocationSession() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      Respone_Error.value = 'Please enable location services';
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Respone_Error.value = 'Location permission is required';
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    currentLocation.value = LatLng(
      position.latitude,
      position.longitude,
    );

    SocketDashboardService.instance.requestLiveLocation(
      userLat: position.latitude,
      userLong: position.longitude,
      radius: selectedRadius.value,
    );

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      currentLocation.value = LatLng(
        position.latitude,
        position.longitude,
      );

      SocketDashboardService.instance.requestLiveLocation(
        userLat: position.latitude,
        userLong: position.longitude,
        radius: selectedRadius.value,
      );
    });
  }

  void updateRadius(dynamic radius) {
    selectedRadius.value = radius.toString();

    final location = currentLocation.value;

    if (location != null) {
      SocketDashboardService.instance.requestLiveLocation(
        userLat: location.latitude,
        userLong: location.longitude,
        radius: radius.toString(),
      );
    }
  }

  @override
  void onClose() {
    _groupCountSubscription?.cancel();
    _liveLocationSubscription?.cancel();

    super.onClose();
  }


}
