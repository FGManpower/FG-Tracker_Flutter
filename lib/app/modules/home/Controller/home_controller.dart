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
  StreamSubscription<Position>? _positionStreamSubscription;

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
        if (locations.isNotEmpty) {
          liveLocations.assignAll(locations);
        }
      },
    );
  }

  Future<void> fetchUsersWithinRadius({double? lat, double? lng}) async {
    try {
      final userId = Global.storageServices.get(PrefConst.userId);
      if (userId == null) return;

      final double userLat = lat ?? currentLocation.value?.latitude ?? 18.969458;
      final double userLong = lng ?? currentLocation.value?.longitude ?? 72.830956;

      final result = await TrackRepo.getUsersWithinRadius(
        userId: userId,
        userLat: userLat,
        userLong: userLong,
        radius: selectedRadius.value,
      );

      if (result.status == true && result.data != null) {
        final List<LiveLocationModel> apiLocations = [];
        for (final user in result.data!) {
          final double userLatitude = user.latitude ?? 0.0;
          final double userLongitude = user.longitude ?? 0.0;

          if (userLatitude == 0.0 && userLongitude == 0.0) continue;

          final String fullName = user.name?.trim() ?? 'Member';
          final parts = fullName.split(' ');
          final firstName = parts.isNotEmpty ? parts[0] : 'Member';
          final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

          apiLocations.add(
            LiveLocationModel(
              userId: int.tryParse(user.userId?.toString() ?? '0') ?? 0,
              firstName: firstName,
              lastName: lastName,
              profileImage: user.profileImage ?? '',
              latitude: userLatitude,
              longitude: userLongitude,
              isOnline: user.isOnline,
              address: user.location,
            ),
          );
        }

        if (apiLocations.isNotEmpty) {
          liveLocations.assignAll(apiLocations);
        } else {
          await _fetchGroupMemberLocations();
        }
      } else {
        await _fetchGroupMemberLocations();
      }
    } catch (e) {
      debugPrint("Error in fetchUsersWithinRadius: $e");
      await _fetchGroupMemberLocations();
    }
  }

  Future<void> _fetchGroupMemberLocations() async {
    try {
      if (!Get.isRegistered<GroupController>()) return;
      final groupCtrl = Get.find<GroupController>();
      if (groupCtrl.groupData.isEmpty) {
        await groupCtrl.getGroupData();
      }

      final List<LiveLocationModel> groupMemberLocations = [];

      for (final group in groupCtrl.groupData) {
        if (group.id == null) continue;
        final res = await TrackRepo.getUserLocationData(group.id!);
        if (res.status == true && res.locations != null) {
          for (final loc in res.locations!) {
            final double lat = loc.latitude ?? 0.0;
            final double lng = loc.longitude ?? 0.0;
            if (lat == 0.0 && lng == 0.0) continue;

            final String fullName = (loc.name ?? 'Member').toString().trim();
            final parts = fullName.split(' ');
            final firstName = parts.isNotEmpty ? parts[0] : 'Member';
            final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

            final bool exists = groupMemberLocations.any(
              (m) => m.userId.toString() == loc.userId.toString(),
            );

            if (!exists) {
              groupMemberLocations.add(
                LiveLocationModel(
                  userId: int.tryParse(loc.userId?.toString() ?? '0') ?? 0,
                  firstName: firstName,
                  lastName: lastName,
                  profileImage: loc.profileImage?.toString() ?? '',
                  latitude: lat,
                  longitude: lng,
                  isOnline: loc.isOnline == 1 || loc.isOnline == true,
                ),
              );
            }
          }
        }
      }

      if (groupMemberLocations.isNotEmpty) {
        liveLocations.assignAll(groupMemberLocations);
      } else {
        final onlineRes = await TrackRepo.getGroupMember(filter: 'all', limit: 50);
        if (onlineRes.status == true && onlineRes.data != null) {
          final List<LiveLocationModel> memberLocs = [];
          for (final m in onlineRes.data!) {
            final double lat = m.latitude ?? 0.0;
            final double lng = m.longitude ?? 0.0;
            if (lat != 0.0 && lng != 0.0) {
              final String fullName = (m.name ?? 'Member').toString().trim();
              final parts = fullName.split(' ');
              final firstName = parts.isNotEmpty ? parts[0] : 'Member';
              final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
              memberLocs.add(
                LiveLocationModel(
                  userId: m.userId ?? 0,
                  firstName: firstName,
                  lastName: lastName,
                  profileImage: m.profileImage ?? '',
                  latitude: lat,
                  longitude: lng,
                  isOnline: m.online,
                ),
              );
            }
          }
          if (memberLocs.isNotEmpty) {
            liveLocations.assignAll(memberLocs);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching group member locations: $e");
    }
  }

  void requestLiveMembers({
    required double latitude,
    required double longitude,
    double radius = 2,
  }) {
    fetchUsersWithinRadius(lat: latitude, lng: longitude);
    SocketDashboardService.instance.requestLiveLocation(
      userLat: latitude,
      userLong: longitude,
      radius: radius,
    );
  }

  Future<void> startLiveLocationSession() async {
    final fastPos = LocationService.instance.currentPosition;
    if (fastPos != null && fastPos.latitude != null && fastPos.longitude != null) {
      currentLocation.value = LatLng(fastPos.latitude!, fastPos.longitude!);
      fetchUsersWithinRadius(lat: fastPos.latitude!, lng: fastPos.longitude!);
      SocketDashboardService.instance.requestLiveLocation(
        userLat: fastPos.latitude!,
        userLong: fastPos.longitude!,
        radius: selectedRadius.value,
      );
    }

    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && currentLocation.value == null) {
        currentLocation.value = LatLng(lastKnown.latitude, lastKnown.longitude);
        fetchUsersWithinRadius(lat: lastKnown.latitude, lng: lastKnown.longitude);
        SocketDashboardService.instance.requestLiveLocation(
          userLat: lastKnown.latitude,
          userLong: lastKnown.longitude,
          radius: selectedRadius.value,
        );
      }
    } catch (_) {}

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 8),
            ),
          );
          currentLocation.value = LatLng(position.latitude, position.longitude);
          fetchUsersWithinRadius(lat: position.latitude, lng: position.longitude);
          SocketDashboardService.instance.requestLiveLocation(
            userLat: position.latitude,
            userLong: position.longitude,
            radius: selectedRadius.value,
          );
        }
      }
    } catch (_) {}

    if (currentLocation.value == null) {
      currentLocation.value = const LatLng(18.969458, 72.830956);
      fetchUsersWithinRadius(lat: 18.969458, lng: 72.830956);
      SocketDashboardService.instance.requestLiveLocation(
        userLat: 18.969458,
        userLong: 72.830956,
        radius: selectedRadius.value,
      );
    }

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
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
    final double lat = location?.latitude ?? 18.969458;
    final double lng = location?.longitude ?? 72.830956;

    fetchUsersWithinRadius(lat: lat, lng: lng);
    SocketDashboardService.instance.requestLiveLocation(
      userLat: lat,
      userLong: lng,
      radius: radius.toString(),
    );
  }

  @override
  void onClose() {
    _groupCountSubscription?.cancel();
    _liveLocationSubscription?.cancel();
    _positionStreamSubscription?.cancel();

    super.onClose();
  }
}
