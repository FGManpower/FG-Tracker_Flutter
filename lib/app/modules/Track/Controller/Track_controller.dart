import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';
import 'package:fgtracker/app/Model/UsersWithinRadiusRes.dart';
import 'package:fgtracker/app/Model/live_location_model.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:fgtracker/app/Model/member_live_status.dart';
import 'package:fgtracker/app/modules/Track/Controller/LocationService.dart';
import 'package:fgtracker/app/modules/Track/Controller/SocketServices.dart';
import 'package:fgtracker/app/modules/Track/Widget/Track_widget.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeocodedAddressResult {
  final String address;
  final String area;
  final String city;

  const GeocodedAddressResult({
    this.address = '',
    this.area = '',
    this.city = '',
  });

  bool get isEmpty => address.isEmpty && area.isEmpty && city.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class TrackController extends GetxController {
  RxString selectedRadius = '2'.obs;
  TextEditingController customRadiusController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  RxInt selectedTabIndex = 0.obs;
  RxBool isLoading = false.obs;
  RxString responseError = "".obs;

  RxDouble currentLat = 0.0.obs;
  RxDouble currentLong = 0.0.obs;

  RxList<MemberModel> liveMembers = <MemberModel>[].obs;
  RxList<MemberModel> allFetchedMembers = <MemberModel>[].obs;
  RxList<UsersWithinRadiusData> radiusUsers = <UsersWithinRadiusData>[].obs;
  RxList<UserMemberData> onlineGroupMembers = <UserMemberData>[].obs;

  RxList<GroupsResData> groupList = <GroupsResData>[].obs;
  RxList<GroupsResData> filteredGroups = <GroupsResData>[].obs;
  RxBool isGroupLoading = true.obs;
  RxString groupError = "".obs;

  RxInt liveNowCount = 0.obs;
  RxInt totalMembersCount = 0.obs;

  // Location & Group Name Observables
  RxString currentLocationName = "Locating...".obs;
  RxString currentArea = "".obs;
  RxString currentCity = "".obs;
  RxString selectedGroupName = "FG Manpower".obs;
  RxString selectedGroupId = "".obs;

  // Google Map State
  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Circle> circles = <Circle>{}.obs;
  final Map<String, BitmapDescriptor> _markerIconCache = {};
  final Map<String, String> _addressCache = {};
  final Map<String, GeocodedAddressResult> _detailedAddressCache = {};

  StreamSubscription<List<LiveLocationModel>>? _socketLiveLocationSubscription;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<dynamic>? _groupCountSubscription;

  @override
  void onInit() {
    super.onInit();

    // 1. Instant load user location from multiple sources
    _loadInitialLocation();

    // 2. Check arguments for group name if passed
    final args = Get.arguments;
    if (args is Map) {
      if (args['groupName'] != null &&
          args['groupName'].toString().isNotEmpty) {
        selectedGroupName.value = args['groupName'].toString();
      }
      if (args['groupId'] != null && args['groupId'].toString().isNotEmpty) {
        selectedGroupId.value = args['groupId'].toString();
      }
    }

    // 3. Immediately draw user marker so map opens with user located
    updateMapMarkersAndCircle();

    // 4. Initialize both sockets
    _initSockets();

    // 5. Fetch group list for Group tab, total members from API, and fetch users strictly from /users-within-radius
    fetchGroupData();
    fetchTotalMembers();
    getCurrentLocationAndFetchUsers();
    _startPositionListening();
  }

  Future<void> _loadInitialLocation() async {
    // A. Instant user location & live locations from HomeController
    try {
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();

        if (home.groupCount.value.totalMembers > 0) {
          totalMembersCount.value = home.groupCount.value.totalMembers;
        }

        if (home.currentLocation.value != null) {
          currentLat.value = home.currentLocation.value!.latitude;
          currentLong.value = home.currentLocation.value!.longitude;
          debugPrint("📍 Instant location loaded from HomeController: ${currentLat.value}, ${currentLong.value}");
          reverseGeocodeLocation(currentLat.value, currentLong.value);
        }

        if (home.liveLocations.isNotEmpty) {
          debugPrint("📍 Instant live members loaded from HomeController: ${home.liveLocations.length}");
          _mergeSocketLocations(home.liveLocations);
        }
      }
    } catch (e) {
      debugPrint("Could not read from HomeController: $e");
    }

    // B. Instant user location from LocationService singleton
    if (currentLat.value == 0.0 || currentLong.value == 0.0) {
      try {
        final loc = LocationService.instance.currentPosition;
        if (loc?.latitude != null && loc?.longitude != null) {
          currentLat.value = loc!.latitude!;
          currentLong.value = loc!.longitude!;
          debugPrint("📍 Instant location loaded from LocationService: ${currentLat.value}, ${currentLong.value}");
          reverseGeocodeLocation(currentLat.value, currentLong.value);
        }
      } catch (e) {
        debugPrint("Could not read from LocationService: $e");
      }
    }

    // C. Instant user location from persistent local storage
    if (currentLat.value == 0.0 || currentLong.value == 0.0) {
      try {
        final savedLat = Global.storageServices.getDouble('user_last_lat');
        final savedLng = Global.storageServices.getDouble('user_last_lng');
        if (savedLat != null && savedLng != null && savedLat != 0.0 && savedLng != 0.0) {
          currentLat.value = savedLat;
          currentLong.value = savedLng;
          debugPrint("📍 Instant location loaded from storage: ${currentLat.value}, ${currentLong.value}");
          reverseGeocodeLocation(currentLat.value, currentLong.value);
        }
      } catch (e) {
        debugPrint("Could not read from storage: $e");
      }
    }

    // Immediately update markers with whatever position we have
    updateMapMarkersAndCircle();

    // D. Ultra-fast check from device GPS hardware cache
    try {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        _updateUserLocation(lastPos.latitude, lastPos.longitude);
      }
    } catch (_) {}
  }

  Future<void> _initSockets() async {
    // Dashboard socket
    SocketDashboardService.instance.init();
    _listenToSocketLiveLocations();
    _listenToGroupCounts();

    // Location socket
    try {
      await SocketService.instance.init(ConstRes.socketUrl);
      _listenToLocationSocketUpdates();
      if (selectedGroupId.value.isNotEmpty) {
        _joinGroupSocket(selectedGroupId.value);
      }
    } catch (e) {
      debugPrint("❌ SocketService init error: $e");
    }
  }

  void _listenToGroupCounts() {
    _groupCountSubscription?.cancel();
    _groupCountSubscription =
        SocketDashboardService.instance.groupCountStream.listen((data) {
      if (data != null) {
        try {
          final counts = GroupCountDetail.fromJson(data);
          if (counts.totalMembers > 0) {
            totalMembersCount.value = counts.totalMembers;
          }
        } catch (_) {}
      }
    });
    SocketDashboardService.instance.requestGroupCount();
  }

  Future<void> fetchTotalMembers() async {
    try {
      final res = await TrackRepo.getGroupMember(page: '1', filter: 'all');
      if (res.status == true &&
          res.pagination?.totalRecords != null &&
          res.pagination!.totalRecords! > 0) {
        totalMembersCount.value = res.pagination!.totalRecords!;
        return;
      }
    } catch (e) {
      debugPrint("Could not fetch total members count from API: $e");
    }

    try {
      final userRes = await GroupRepo.getAllUserData();
      if (userRes.status == true &&
          userRes.userData != null &&
          userRes.userData!.isNotEmpty) {
        totalMembersCount.value = userRes.userData!.length;
        return;
      }
    } catch (e) {
      debugPrint("Could not fetch total members from getAllUserData: $e");
    }

    if (selectedGroupId.value.isNotEmpty) {
      await fetchMembersForSelectedGroup(selectedGroupId.value);
    }
  }

  Future<void> fetchMembersForSelectedGroup(String groupId) async {
    try {
      final memberRes = await GroupRepo.getMemberData(groupId);
      if (memberRes.status == true &&
          memberRes.memberData != null &&
          memberRes.memberData!.isNotEmpty) {
        totalMembersCount.value = memberRes.memberData!.length;
      }
    } catch (_) {}
  }

  void _listenToSocketLiveLocations() {
    _socketLiveLocationSubscription?.cancel();
    _socketLiveLocationSubscription =
        SocketDashboardService.instance.liveLocationStream.listen((locations) {
      if (locations.isNotEmpty) {
        debugPrint("📡 Received ${locations.length} live locations from dashboard socket");
        _mergeSocketLocations(locations);
      }
    });
  }

  void _listenToLocationSocketUpdates() {
    SocketService.instance.onGroupLocationUpdate((item) {
      debugPrint("📡 Received group-location-update: $item");
      if (item is Map) {
        final userId = item['userId'];
        final lat = double.tryParse(item['lat']?.toString() ??
            item['latitude']?.toString() ??
            item['userLat']?.toString() ??
            '');
        final lng = double.tryParse(item['lng']?.toString() ??
            item['lon']?.toString() ??
            item['longitude']?.toString() ??
            item['userLong']?.toString() ??
            '');

        String? addr = (item['address'] ?? item['location'])?.toString();
        final String? itemArea = (item['area'] ?? item['subLocality'])?.toString();
        final String? itemCity = (item['city'] ?? item['locality'])?.toString();

        if ((addr == null || addr.isEmpty) &&
            (itemArea != null || itemCity != null)) {
          if (itemArea != null && itemCity != null && itemArea.isNotEmpty && itemCity.isNotEmpty) {
            addr = itemArea.toLowerCase() == itemCity.toLowerCase()
                ? itemCity
                : "$itemArea, $itemCity";
          } else if (itemArea != null && itemArea.isNotEmpty) {
            addr = itemArea;
          } else if (itemCity != null && itemCity.isNotEmpty) {
            addr = itemCity;
          }
        }

        if (userId != null &&
            lat != null &&
            lng != null &&
            lat != 0.0 &&
            lng != 0.0) {
          final nowIso = DateTime.now().toIso8601String();
          final existingIdx = radiusUsers.indexWhere(
              (u) => u.userId.toString() == userId.toString());
          if (existingIdx >= 0) {
            final prev = radiusUsers[existingIdx];
            final bool moved =
                (prev.latitude != null && (prev.latitude! - lat).abs() > 0.0001) ||
                (prev.longitude != null && (prev.longitude! - lng).abs() > 0.0001);
            prev.latitude = lat;
            prev.longitude = lng;
            prev.isOnline = true;
            prev.lastSeen = nowIso;
            if (item['name'] != null && item['name'].toString().isNotEmpty) {
              prev.name = item['name'].toString();
            }
            if (addr != null && addr.isNotEmpty) {
              prev.location = addr;
            }
            _resolveAddressForUser(prev);
          } else {
            final newUser = UsersWithinRadiusData(
              userId: userId,
              name: item['name']?.toString() ?? "Member",
              latitude: lat,
              longitude: lng,
              isOnline: true,
              lastSeen: nowIso,
              team: selectedGroupName.value,
              location: addr,
            );
            radiusUsers.add(newUser);
            _resolveAddressForUser(newUser);
          }
          _refreshMembersAndMap();
        }
      }
    });
  }

  void _mergeSocketLocations(List<LiveLocationModel> socketUsers) {
    final nowIso = DateTime.now().toIso8601String();
    for (var su in socketUsers) {
      if (su.latitude == 0.0 || su.longitude == 0.0) continue;

      String? suAddress = su.address;
      if (suAddress == null || suAddress.isEmpty) {
        if (su.area != null && su.city != null && su.area!.isNotEmpty && su.city!.isNotEmpty) {
          suAddress = su.area!.toLowerCase() == su.city!.toLowerCase()
              ? su.city
              : "${su.area}, ${su.city}";
        } else if (su.area != null && su.area!.isNotEmpty) {
          suAddress = su.area;
        } else if (su.city != null && su.city!.isNotEmpty) {
          suAddress = su.city;
        }
      }

      final existingIndex = radiusUsers
          .indexWhere((u) => u.userId.toString() == su.userId.toString());
      if (existingIndex >= 0) {
        final prev = radiusUsers[existingIndex];
        final bool moved =
            (prev.latitude != null && (prev.latitude! - su.latitude).abs() > 0.0001) ||
            (prev.longitude != null && (prev.longitude! - su.longitude).abs() > 0.0001);
        prev.latitude = su.latitude;
        prev.longitude = su.longitude;
        prev.isOnline = true;
        prev.lastSeen = nowIso;
        if (su.fullName.isNotEmpty && su.fullName != "Member") {
          prev.name = su.fullName;
        }
        if (su.profileImage.isNotEmpty) {
          prev.profileImage = su.profileImage;
        }
        if (suAddress != null && suAddress.isNotEmpty) {
          prev.location = suAddress;
        }
        _resolveAddressForUser(prev);
      } else {
        final newUser = UsersWithinRadiusData(
          userId: su.userId,
          name: su.fullName,
          profileImage: su.profileImage,
          latitude: su.latitude,
          longitude: su.longitude,
          isOnline: true,
          lastSeen: nowIso,
          team: selectedGroupName.value,
          location: suAddress,
        );
        radiusUsers.add(newUser);
        _resolveAddressForUser(newUser);
      }
    }
    _refreshMembersAndMap();
  }

  void _refreshMembersAndMap() {
    final mapped = radiusUsers
        .map((e) => e.toMemberModel(
              currentUserLat: currentLat.value,
              currentUserLong: currentLong.value,
              fallbackTeam: selectedGroupName.value,
            ))
        .toList();

    allFetchedMembers.value = mapped;
    final onlineCount = mapped.where((m) => m.isOnline).length;
    liveNowCount.value = onlineCount > 0 ? onlineCount : mapped.length;
    if (totalMembersCount.value < liveNowCount.value) {
      totalMembersCount.value = liveNowCount.value;
    }
    if (searchController.text.trim().isEmpty) {
      liveMembers.value = mapped;
    } else {
      onSearch(searchController.text.trim());
    }

    updateMapMarkersAndCircle();
  }


  Future<void> fetchGroupData() async {
    try {
      isGroupLoading.value = true;
      groupError.value = "";
      final GroupRes result = await GroupRepo.getGroupData();
      if (result.status == true && result.data?.groupData != null) {
        groupList.value = result.data!.groupData!;
        filteredGroups.value = result.data!.groupData!;

        GroupsResData? validGroup;
        for (var g in groupList) {
          if (g.groupName != null &&
              g.groupName!.trim().isNotEmpty &&
              !g.groupName!.toLowerCase().contains("test")) {
            validGroup = g;
            break;
          }
        }
        if (validGroup != null) {
          selectedGroupName.value = validGroup.groupName!;
          selectedGroupId.value = validGroup.id?.toString() ?? "";
        } else {
          selectedGroupName.value = "FG Manpower";
        }

        int sumMembers = 0;
        for (var g in groupList) {
          if (g.memberCount != null && g.memberCount! > 0) {
            sumMembers += g.memberCount!;
          }
          if (g.id != null) {
            _joinGroupSocket(g.id!.toString());
          }
        }
        if (totalMembersCount.value == 0 && sumMembers > 0) {
          totalMembersCount.value = sumMembers;
        }
      } else {
        groupError.value = result.message ?? "Failed to load groups";
      }
    } catch (e) {
      groupError.value = e.toString();
    } finally {
      isGroupLoading.value = false;
    }
  }

  void _joinGroupSocket(String groupId) {
    try {
      final userId =
          Global.storageServices.get(PrefConst.userId)?.toString() ?? "";
      if (userId.isNotEmpty) {
        SocketService.instance.joinGroup(groupId: groupId, userId: userId);
      }
    } catch (_) {}
  }

  void selectGroup(GroupsResData group) {
    selectedGroupName.value = (group.groupName != null &&
            !group.groupName!.toLowerCase().contains("test"))
        ? group.groupName!
        : "FG Manpower";
    selectedGroupId.value = group.id?.toString() ?? "";
    if (group.memberCount != null && group.memberCount! > 0) {
      totalMembersCount.value = group.memberCount!;
    }
    if (group.id != null) {
      _joinGroupSocket(group.id!.toString());
      fetchMembersForSelectedGroup(group.id!.toString());
    }
    getUsersWithinRadius();
  }

  Future<GeocodedAddressResult> getDetailedCityAreaAddress(
      double lat, double lng) async {
    if (lat == 0.0 && lng == 0.0) return const GeocodedAddressResult();

    final cacheKey = "${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}";
    if (_detailedAddressCache.containsKey(cacheKey)) {
      return _detailedAddressCache[cacheKey]!;
    }

    String area = '';
    String city = '';
    String formattedAddress = '';

    // 1. Native Geocoding via placemarkFromCoordinates
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // 1. Extract Area: subLocality -> thoroughfare -> subAdministrativeArea
        area = place.subLocality?.trim() ?? '';
        if (area.isEmpty) {
          area = place.thoroughfare?.trim() ?? '';
        }
        if (area.isEmpty) {
          area = place.subAdministrativeArea?.trim() ?? '';
        }

        // 2. Extract City: locality -> subAdministrativeArea -> administrativeArea
        city = place.locality?.trim() ?? '';
        if (city.isEmpty) {
          city = place.subAdministrativeArea?.trim() ?? '';
        }
        if (city.isEmpty) {
          city = place.administrativeArea?.trim() ?? '';
        }

        if (area.isNotEmpty && city.isNotEmpty) {
          if (area.toLowerCase() == city.toLowerCase()) {
            formattedAddress = city;
          } else if (area.toLowerCase().contains(city.toLowerCase())) {
            formattedAddress = area;
          } else {
            formattedAddress = "$area, $city";
          }
        } else if (area.isNotEmpty) {
          formattedAddress = area;
        } else if (city.isNotEmpty) {
          formattedAddress = city;
        } else {
          formattedAddress = place.name?.trim() ?? "";
        }
      }
    } catch (e) {
      debugPrint("❌ Native geocoding error for ($lat, $lng): $e");
    }

    // 2. Fallback: Google Geocoding API if native geocoding is empty or unavailable
    if (area.isEmpty && city.isEmpty && formattedAddress.isEmpty) {
      try {
        final dio = Dio();
        final response = await dio.get(
          "https://maps.googleapis.com/maps/api/geocode/json",
          queryParameters: {
            "latlng": "$lat,$lng",
            "key": ConstRes.gMapApiKey,
          },
        );
        if (response.data != null &&
            response.data['results'] is List &&
            (response.data['results'] as List).isNotEmpty) {
          final result = response.data['results'][0];
          final components = result['address_components'] as List?;
          if (components != null) {
            for (var comp in components) {
              final types = (comp['types'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];
              if (types.contains('sublocality') ||
                  types.contains('sublocality_level_1') ||
                  types.contains('neighborhood')) {
                area = comp['long_name']?.toString() ?? '';
              }
              if (types.contains('locality')) {
                city = comp['long_name']?.toString() ?? '';
              }
              if (city.isEmpty &&
                  types.contains('administrative_area_level_2')) {
                city = comp['long_name']?.toString() ?? '';
              }
            }
          }
          if (area.isNotEmpty && city.isNotEmpty) {
            formattedAddress = area.toLowerCase() == city.toLowerCase()
                ? city
                : "$area, $city";
          } else if (area.isNotEmpty) {
            formattedAddress = area;
          } else if (city.isNotEmpty) {
            formattedAddress = city;
          } else {
            formattedAddress = result['formatted_address']?.toString() ?? '';
          }
        }
      } catch (apiErr) {
        debugPrint("❌ Google geocode fallback error: $apiErr");
      }
    }

    final result = GeocodedAddressResult(
      address: formattedAddress,
      area: area,
      city: city,
    );

    if (result.isNotEmpty) {
      _detailedAddressCache[cacheKey] = result;
      _addressCache[cacheKey] = result.address;
    }

    return result;
  }

  Future<String> getCityAreaAddress(double lat, double lng) async {
    final result = await getDetailedCityAreaAddress(lat, lng);
    return result.address;
  }

  Future<GeocodedAddressResult> reverseGeocodeLocation(
      double lat, double lng) async {
    try {
      final res = await getDetailedCityAreaAddress(lat, lng);
      if (res.address.isNotEmpty) {
        currentLocationName.value = res.address;
      } else if (currentLocationName.value.isEmpty ||
          currentLocationName.value == "Locating...") {
        currentLocationName.value = "Current Location";
      }
      if (res.area.isNotEmpty) currentArea.value = res.area;
      if (res.city.isNotEmpty) currentCity.value = res.city;
      return res;
    } catch (_) {
      if (currentLocationName.value.isEmpty ||
          currentLocationName.value == "Locating...") {
        currentLocationName.value = "Current Location";
      }
      return const GeocodedAddressResult();
    }
  }

  Future<void> _resolveAddressForUser(UsersWithinRadiusData user) async {
    if (user.location != null &&
        user.location!.trim().isNotEmpty &&
        user.location != "Locating..." &&
        user.location != "Location" &&
        user.location != "Location unavailable" &&
        user.location != "Active now" &&
        !RegExp(r'^\d+\.\d+,\s*\d+\.\d+$').hasMatch(user.location!)) {
      final cacheKey =
          "${user.latitude?.toStringAsFixed(4)},${user.longitude?.toStringAsFixed(4)}";
      UsersWithinRadiusData.addressCache[cacheKey] = user.location!;
      return;
    }

    if (user.latitude == null || user.longitude == null) return;
    if (user.latitude == 0.0 && user.longitude == 0.0) return;

    try {
      final address = await getCityAreaAddress(user.latitude!, user.longitude!);
      if (address.isNotEmpty) {
        user.location = address;
        final cacheKey =
            "${user.latitude!.toStringAsFixed(4)},${user.longitude!.toStringAsFixed(4)}";
        UsersWithinRadiusData.addressCache[cacheKey] = address;
        _refreshMembersAndMap();
      }
    } catch (_) {}
  }

  Future<void> _resolveAllMembersAddresses() async {
    final futures = <Future>[];
    for (var u in radiusUsers) {
      if (u.latitude != null &&
          u.longitude != null &&
          u.latitude != 0.0 &&
          u.longitude != 0.0) {
        futures.add(_resolveAddressForUser(u));
      }
    }
    if (futures.isNotEmpty) {
      try {
        await Future.wait(futures).timeout(const Duration(seconds: 4));
      } catch (_) {}
    }
  }

  void _updateUserLocation(double lat, double lng) {
    if (lat == 0.0 && lng == 0.0) return;

    final bool firstValidCoords =
        (currentLat.value == 0.0 || currentLong.value == 0.0);
    currentLat.value = lat;
    currentLong.value = lng;

    try {
      Global.storageServices.setDouble('user_last_lat', lat);
      Global.storageServices.setDouble('user_last_lng', lng);
    } catch (_) {}

    // Reverse geocode to extract clean "Area, City" address and emit to sockets
    reverseGeocodeLocation(lat, lng).then((geocoded) {
      final uid = Global.storageServices.get(PrefConst.userId)?.toString();
      if (uid != null && uid.isNotEmpty) {
        final addr = geocoded.address.isNotEmpty
            ? geocoded.address
            : (currentLocationName.value != "Locating..."
                ? currentLocationName.value
                : null);
        final area = geocoded.area.isNotEmpty
            ? geocoded.area
            : (currentArea.value.isNotEmpty ? currentArea.value : null);
        final city = geocoded.city.isNotEmpty
            ? geocoded.city
            : (currentCity.value.isNotEmpty ? currentCity.value : null);

        // 1. Emit to location socket with address, area, and city
        SocketService.instance.emitLocation(
          uid,
          lat,
          lng,
          address: addr,
          area: area,
          city: city,
        );

        // 2. Request live locations from dashboard socket with address, area, and city
        SocketDashboardService.instance.requestLiveLocation(
          userLat: lat,
          userLong: lng,
          radius: selectedRadius.value,
          address: addr,
          area: area,
          city: city,
        );
      }
    });

    final uid = Global.storageServices.get(PrefConst.userId)?.toString();
    if (uid != null && uid.isNotEmpty) {
      SocketService.instance.emitLocation(
        uid,
        lat,
        lng,
        address: currentLocationName.value != "Locating..."
            ? currentLocationName.value
            : null,
        area: currentArea.value.isNotEmpty ? currentArea.value : null,
        city: currentCity.value.isNotEmpty ? currentCity.value : null,
      );
    }

    // Keep user's own location centered right in front of them
    if (mapController != null) {
      recenterMap(zoom: 16.0);
    }

    updateMapMarkersAndCircle();

    // If first time valid coordinates are set, request live members from socket and API
    if (firstValidCoords) {
      _emitSocketLiveLocationRequest();
      getUsersWithinRadius();
    }
  }

  Future<void> getCurrentLocationAndFetchUsers() async {
    // 1. Fast check from LocationService
    final loc = LocationService.instance.currentPosition;
    if (loc != null && loc.latitude != null && loc.longitude != null) {
      _updateUserLocation(loc.latitude!, loc.longitude!);
    } else {
      // 2. Fast check: last known position from GPS cache
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null &&
            (currentLat.value == 0.0 || currentLong.value == 0.0)) {
          _updateUserLocation(lastPos.latitude, lastPos.longitude);
        }
      } catch (_) {}
    }

    // 3. Request high accuracy fresh position
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          Position pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          _updateUserLocation(pos.latitude, pos.longitude);
        }
      }
    } catch (_) {}

    // 4. Trigger socket request
    _emitSocketLiveLocationRequest();

    // 5. Fetch users within radius API
    await getUsersWithinRadius();
  }

  void _startPositionListening() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      ),
    ).listen((position) {
      _updateUserLocation(position.latitude, position.longitude);
      _emitSocketLiveLocationRequest();
    });
  }

  void _emitSocketLiveLocationRequest() {
    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double long = currentLong.value != 0.0 ? currentLong.value : 72.8777;

    final String? currentAddr = currentLocationName.value != "Locating..." &&
            currentLocationName.value.isNotEmpty
        ? currentLocationName.value
        : null;
    final String? area =
        currentArea.value.isNotEmpty ? currentArea.value : null;
    final String? city =
        currentCity.value.isNotEmpty ? currentCity.value : null;

    SocketDashboardService.instance.requestLiveLocation(
      userLat: lat,
      userLong: long,
      radius: selectedRadius.value,
      address: currentAddr,
      area: area,
      city: city,
    );

    // Also send a delayed backup request after socket handshake finishes
    Future.delayed(const Duration(milliseconds: 800), () {
      SocketDashboardService.instance.requestLiveLocation(
        userLat: lat,
        userLong: long,
        radius: selectedRadius.value,
        address: currentAddr,
        area: area,
        city: city,
      );
    });
  }

  Future<void> getUsersWithinRadius() async {
    try {
      isLoading.value = true;
      responseError.value = "";

      final userId = Global.storageServices.get(PrefConst.userId);
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
      final double long = currentLong.value != 0.0 ? currentLong.value : 72.8777;

      final result = await TrackRepo.getUsersWithinRadius(
        userId: userId,
        userLat: lat,
        userLong: long,
        radius: selectedRadius.value,
      );

      if (result.status == true && result.data != null) {
        if (result.totalMembers != null && result.totalMembers! > 0) {
          totalMembersCount.value = result.totalMembers!;
        }

        debugPrint(
            "📍 Loaded ${result.data!.length} users strictly from /users-within-radius");

        final Map<String, UsersWithinRadiusData> existingMap = {
          for (var u in radiusUsers) u.userId.toString(): u
        };

        for (var apiUser in result.data!) {
          final key = apiUser.userId.toString();
          if (existingMap.containsKey(key)) {
            final existing = existingMap[key]!;
            final isNowOnline = existing.isOnline ||
                Tracking().isOnline(rawIsOnline: apiUser.isOnline, lastSeen: apiUser.lastSeen);
            apiUser.isOnline = isNowOnline;

            if (existing.latitude != null &&
                existing.latitude != 0.0 &&
                (apiUser.latitude == null || apiUser.latitude == 0.0)) {
              apiUser.latitude = existing.latitude;
              apiUser.longitude = existing.longitude;
            }
            if (existing.lastSeen != null && apiUser.lastSeen == null) {
              apiUser.lastSeen = existing.lastSeen;
            }
            if ((apiUser.location == null || apiUser.location!.isEmpty) &&
                existing.location != null &&
                existing.location!.isNotEmpty) {
              apiUser.location = existing.location;
            }
            existingMap[key] = apiUser;
          } else {
            apiUser.isOnline = Tracking().isOnline(
              rawIsOnline: apiUser.isOnline,
              lastSeen: apiUser.lastSeen,
            );
            existingMap[key] = apiUser;
          }
        }

        radiusUsers.assignAll(existingMap.values.toList());
        await _resolveAllMembersAddresses();
      } else {
        debugPrint(
            "⚠️ /users-within-radius returned: ${result.message}");
        if (result.data != null && result.data!.isEmpty && radiusUsers.every((u) => !u.isOnline)) {
          radiusUsers.clear();
        }
      }
      _refreshMembersAndMap();
    } catch (e) {
      responseError.value = e.toString();
      debugPrint("❌ Error in getUsersWithinRadius: $e");
      _refreshMembersAndMap();
    } finally {
      isLoading.value = false;
      updateMapMarkersAndCircle();
    }
  }

  void onSearch(String value) {
    if (selectedTabIndex.value == 1) {
      if (value.isEmpty) {
        filteredGroups.value = groupList;
      } else {
        filteredGroups.value = groupList
            .where((g) =>
                (g.groupName ?? "")
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                (g.groupDesc ?? "")
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                (g.groupCode ?? "")
                    .toLowerCase()
                    .contains(value.toLowerCase()))
            .toList();
      }
    } else {
      if (value.isEmpty) {
        liveMembers.value = allFetchedMembers;
      } else {
        liveMembers.value = allFetchedMembers
            .where((m) =>
                m.name.toLowerCase().contains(value.toLowerCase()) ||
                m.team.toLowerCase().contains(value.toLowerCase()) ||
                m.location.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    }
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
    searchController.clear();
    if (index == 1) {
      filteredGroups.value = groupList;
      fetchGroupData();
    } else {
      liveMembers.value = allFetchedMembers;
    }
  }

  void updateRadius(String value) {
    selectedRadius.value = value;

    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double long = currentLong.value != 0.0 ? currentLong.value : 72.8777;

    final String? currentAddr = currentLocationName.value != "Locating..." &&
            currentLocationName.value.isNotEmpty
        ? currentLocationName.value
        : null;
    final String? area =
        currentArea.value.isNotEmpty ? currentArea.value : null;
    final String? city =
        currentCity.value.isNotEmpty ? currentCity.value : null;

    // Trigger Socket Live Location request on radius change with address, area, and city
    SocketDashboardService.instance.requestLiveLocation(
      userLat: lat,
      userLong: long,
      radius: value,
      address: currentAddr,
      area: area,
      city: city,
    );

    if (SocketService.instance.isSocketConnected) {
      try {
        SocketService.instance.socket.emit("radius-change", {
          "userId": Global.storageServices.get(PrefConst.userId),
          "lat": lat,
          "long": long,
          "radius": value,
          if (currentAddr != null) "address": currentAddr,
          if (area != null) "area": area,
          if (city != null) "city": city,
        });
      } catch (_) {}
    }

    // Call GET API /users-within-radius
    getUsersWithinRadius();

    // Dynamically update radius circle & map zoom
    updateMapMarkersAndCircle();
    _zoomForRadius(double.tryParse(value) ?? 2.0);
  }

  Future<void> updateMapMarkersAndCircle() async {
    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double lng = currentLong.value != 0.0 ? currentLong.value : 72.8777;
    final double radiusKm = double.tryParse(selectedRadius.value) ?? 2.0;
    final double radiusMeters = radiusKm * 1000.0;

    // Update Radius Circle
    circles.value = {
      Circle(
        circleId: const CircleId('tracking_radius_circle'),
        center: LatLng(lat, lng),
        radius: radiusMeters,
        fillColor: AppColors.darkBlue.withOpacity(0.12),
        strokeColor: AppColors.darkBlue.withOpacity(0.65),
        strokeWidth: 2,
      ),
    };

    // Update Markers
    final Set<Marker> newMarkers = {};

    final String myProfileImg =
        Global.storageServices.get(PrefConst.profileImage)?.toString() ?? '';
    final String myName =
        Global.storageServices.get(PrefConst.userName)?.toString() ?? 'You';

    BitmapDescriptor userIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    final cacheKey = "me_${myProfileImg}_custom_sm";
    if (_markerIconCache.containsKey(cacheKey)) {
      userIcon = _markerIconCache[cacheKey]!;
    } else {
      try {
        userIcon = await getCustomIcon(myProfileImg, true, isMe: true);
        _markerIconCache[cacheKey] = userIcon;
      } catch (_) {}
    }

    // Current User Marker ("You") right in front
    newMarkers.add(
      Marker(
        markerId: const MarkerId('current_user_pin'),
        position: LatLng(lat, lng),
        icon: userIcon,
        zIndex: 999.0,
        infoWindow: InfoWindow(
          title: "📍 $myName (You)",
          snippet: currentLocationName.value.isNotEmpty &&
                  currentLocationName.value != "Locating..."
              ? currentLocationName.value
              : "Your Current Location",
        ),
      ),
    );

    // Member markers
    for (var u in radiusUsers) {
      if (u.latitude != null &&
          u.longitude != null &&
          u.latitude != 0.0 &&
          u.longitude != 0.0) {
        final cacheKey = "${u.userId}_${u.profileImage}_${u.isOnline}_sm";
        BitmapDescriptor customIcon;

        if (_markerIconCache.containsKey(cacheKey)) {
          customIcon = _markerIconCache[cacheKey]!;
        } else {
          try {
            customIcon = await getCustomIcon(u.profileImage ?? '', u.isOnline);
            _markerIconCache[cacheKey] = customIcon;
          } catch (_) {
            customIcon = BitmapDescriptor.defaultMarkerWithHue(
              u.isOnline ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
            );
          }
        }

        final String locSnippet = (u.location != null &&
                u.location!.isNotEmpty &&
                u.location != "Active now" &&
                u.location != "Location")
            ? "${u.location} • "
            : "";
        final distanceText =
            u.distance != null ? "${u.distance} km away" : "Nearby";

        newMarkers.add(
          Marker(
            markerId: MarkerId('user_${u.userId}'),
            position: LatLng(u.latitude!, u.longitude!),
            icon: customIcon,
            infoWindow: InfoWindow(
              title: u.name ?? "Member",
              snippet: "$locSnippet$distanceText",
            ),
          ),
        );
      }
    }

    markers.value = newMarkers;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    recenterMap(zoom: 16.0);
  }

  void _zoomForRadius(double radiusKm) {
    if (mapController == null) return;
    double zoomLevel = 15.0;
    if (radiusKm <= 2) {
      zoomLevel = 15.0;
    } else if (radiusKm <= 4) {
      zoomLevel = 14.0;
    } else if (radiusKm <= 6) {
      zoomLevel = 13.2;
    } else if (radiusKm <= 8) {
      zoomLevel = 12.5;
    } else {
      zoomLevel = 11.5;
    }

    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double lng = currentLong.value != 0.0 ? currentLong.value : 72.8777;

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: zoomLevel,
        ),
      ),
    );
  }

  void fitAllMembers() {
    if (mapController == null) return;
    final List<LatLng> points = [];
    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double lng = currentLong.value != 0.0 ? currentLong.value : 72.8777;
    points.add(LatLng(lat, lng));

    for (var u in radiusUsers) {
      if (u.latitude != null &&
          u.longitude != null &&
          u.latitude != 0.0 &&
          u.longitude != 0.0) {
        points.add(LatLng(u.latitude!, u.longitude!));
      }
    }

    if (points.length <= 1) {
      recenterMap();
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    if (minLat == maxLat) {
      minLat -= 0.01;
      maxLat += 0.01;
    }
    if (minLng == maxLng) {
      minLng -= 0.01;
      maxLng += 0.01;
    }

    try {
      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          55.0,
        ),
      );
    } catch (_) {
      recenterMap();
    }
  }

  void zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void recenterMap({double zoom = 16.0}) {
    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double lng = currentLong.value != 0.0 ? currentLong.value : 72.8777;
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: zoom,
        ),
      ),
    );
  }

  void focusMemberById(String userId) {
    for (var u in radiusUsers) {
      if (u.userId.toString() == userId &&
          u.latitude != null &&
          u.longitude != null &&
          u.latitude != 0.0) {
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(u.latitude!, u.longitude!),
              zoom: 17.0,
            ),
          ),
        );
        return;
      }
    }
  }

  @override
  void onClose() {
    _socketLiveLocationSubscription?.cancel();
    _positionStreamSubscription?.cancel();
    _groupCountSubscription?.cancel();
    customRadiusController.dispose();
    searchController.dispose();
    mapController?.dispose();
    super.onClose();
  }
}