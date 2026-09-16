import 'dart:async';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';
import 'package:fgtracker/app/Model/UsersWithinRadiusRes.dart';
import 'package:fgtracker/app/Model/live_location_model.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:fgtracker/app/Model/member_live_status.dart';
import 'package:fgtracker/app/modules/Track/Controller/LocationService.dart';
import 'package:fgtracker/app/modules/Track/Controller/SocketServices.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackLiveLocationSocketService.dart';
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
  final RxString searchQuery = "".obs;
  final RxBool isSearchDropdownOpen = false.obs;

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
  RxString selectedGroupName = "".obs;
  RxString selectedGroupId = "".obs;

  // Google Map State
  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Circle> circles = <Circle>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final Map<String, BitmapDescriptor> _markerIconCache = {};
  final Map<String, String> _addressCache = {};
  final Map<String, GeocodedAddressResult> _detailedAddressCache = {};

  StreamSubscription<List<LiveLocationModel>>? _socketLiveLocationSubscription;
  StreamSubscription<LiveLocationSocketModel>? _trackLiveSocketSubscription;
  StreamSubscription<UserStatusSocketModel>? _userStatusSocketSubscription;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<dynamic>? _groupCountSubscription;

  @override
  void onInit() {
    super.onInit();

    // 0. Ensure lists start clean so only /users-within-radius API populates live tracking
    radiusUsers.clear();
    liveMembers.clear();
    allFetchedMembers.clear();

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
    // Dashboard socket (for group counts)
    SocketDashboardService.instance.init();
    _listenToGroupCounts();

    // Location socket & Live Location Socket Service
    try {
      await SocketService.instance.init(ConstRes.socketUrl);
      if (SocketService.instance.isSocketConnected) {
        TrackLiveLocationSocketService.instance
            .attachSocket(SocketService.instance.socket);
      } else {
        await TrackLiveLocationSocketService.instance
            .init(socketUrl: ConstRes.socketUrl);
      }
      _listenToLiveLocationSocket();
      _listenToUserStatusSocket();
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

  void _listenToLiveLocationSocket() {
    _trackLiveSocketSubscription?.cancel();
    _trackLiveSocketSubscription = TrackLiveLocationSocketService.instance
        .locationStream
        .listen((liveData) {
      _applyLiveSocketLocationUpdate(liveData);
    });
  }

  void _listenToUserStatusSocket() {
    _userStatusSocketSubscription?.cancel();
    _userStatusSocketSubscription = TrackLiveLocationSocketService.instance
        .userStatusStream
        .listen((status) {
      final idx = radiusUsers
          .indexWhere((u) => u.userId.toString() == status.userId);
      if (idx >= 0) {
        radiusUsers[idx].isOnline = status.isOnline;
      }
      final gIdx = onlineGroupMembers
          .indexWhere((u) => u.userId.toString() == status.userId);
      if (gIdx >= 0) {
        onlineGroupMembers[gIdx].isOnline = status.isOnline ? 1 : 0;
      }
      _refreshMembersAndMap();
    });
  }

  void _applyLiveSocketLocationUpdate(LiveLocationSocketModel data) {
    if (data.lat == 0.0 || data.lng == 0.0) return;

    final String userIdStr = data.userId.toString();
    final nowIso = DateTime.now().toIso8601String();

    String resolvedAddress = data.address;
    if (resolvedAddress.isEmpty) {
      if (data.area.isNotEmpty && data.city.isNotEmpty) {
        resolvedAddress = data.area.toLowerCase() == data.city.toLowerCase()
            ? data.city
            : '${data.area}, ${data.city}';
      } else if (data.area.isNotEmpty) {
        resolvedAddress = data.area;
      } else if (data.city.isNotEmpty) {
        resolvedAddress = data.city;
      }
    }

    final existingIdx =
        radiusUsers.indexWhere((u) => u.userId.toString() == userIdStr);
    if (existingIdx >= 0) {
      final prev = radiusUsers[existingIdx];
      prev.latitude = data.lat;
      prev.longitude = data.lng;
      prev.isOnline = true;
      prev.lastSeen = nowIso;
      if (data.name != null && data.name!.isNotEmpty) {
        prev.name = data.name;
      }
      if (data.profileImage != null && data.profileImage!.isNotEmpty) {
        prev.profileImage = data.profileImage;
      }
      if (resolvedAddress.isNotEmpty) {
        prev.location = resolvedAddress;
      }
      _resolveAddressForUser(prev);
    } else {
      final newUser = UsersWithinRadiusData(
        userId: data.userId,
        name: data.name ?? "Member",
        profileImage: data.profileImage,
        latitude: data.lat,
        longitude: data.lng,
        isOnline: true,
        lastSeen: nowIso,
        team: selectedGroupName.value,
        location: resolvedAddress.isNotEmpty ? resolvedAddress : null,
      );
      radiusUsers.add(newUser);
      _resolveAddressForUser(newUser);
    }

    if (selectedGroupId.value.isNotEmpty &&
        data.groupId != null &&
        data.groupId.toString() == selectedGroupId.value) {
      final groupMemberIdx = onlineGroupMembers
          .indexWhere((m) => m.userId.toString() == userIdStr);
      if (groupMemberIdx >= 0) {
        final gm = onlineGroupMembers[groupMemberIdx];
        gm.latitude = data.lat;
        gm.longitude = data.lng;
        gm.isOnline = 1;
      }
    }

    _refreshMembersAndMap();
  }

  void _listenToLocationSocketUpdates() {
    SocketService.instance.onSendLocation((item) {
      debugPrint("📡 Received send-location via SocketService: $item");
      if (item is Map) {
        final model =
            LiveLocationSocketModel.fromJson(Map<String, dynamic>.from(item));
        _applyLiveSocketLocationUpdate(model);
      }
    });

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
            if (item['battery'] != null) {
              prev.battery = item['battery'];
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
              battery: item['battery'] ?? item['batteryLevel'] ?? item['battery_level'],
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
        if (su.battery != null) {
          prev.battery = su.battery;
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
          battery: su.battery,
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
    double userLat = currentLat.value;
    double userLng = currentLong.value;
    if (userLat == 0.0 || userLng == 0.0) {
      final loc = LocationService.instance.currentPosition;
      if (loc?.latitude != null && loc?.longitude != null) {
        userLat = loc!.latitude!;
        userLng = loc!.longitude!;
      } else {
        final savedLat = Global.storageServices.getDouble('user_last_lat');
        final savedLng = Global.storageServices.getDouble('user_last_lng');
        if (savedLat != null && savedLng != null && savedLat != 0.0 && savedLng != 0.0) {
          userLat = savedLat;
          userLng = savedLng;
        }
      }
    }

    final onlineUsers = radiusUsers.where((u) => u.isOnline).toList();
    final mapped = onlineUsers
        .map((e) => e.toMemberModel(
              currentUserLat: userLat,
              currentUserLong: userLng,
              fallbackTeam: selectedGroupName.value,
            ))
        .toList();

    allFetchedMembers.value = mapped;
    liveNowCount.value = mapped.length;
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

        if (groupList.isNotEmpty) {
          final valid = groupList.firstWhere(
            (g) => g.groupName != null && g.groupName!.trim().isNotEmpty,
            orElse: () => groupList.first,
          );
          selectedGroupName.value = valid.groupName ?? "";
          selectedGroupId.value = valid.id?.toString() ?? "";
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
    selectedGroupName.value = group.groupName ?? "";
    selectedGroupId.value = group.id?.toString() ?? "";
    if (group.memberCount != null && group.memberCount! > 0) {
      totalMembersCount.value = group.memberCount!;
    }
    if (group.id != null) {
      final gId = group.id!.toString();
      _joinGroupSocket(gId);
    }
  }

  Future<void> fetchGroupLocationData(String groupId) async {
    try {
      isLoading.value = true;
      final int? gId = int.tryParse(groupId);
      if (gId == null) return;

      final res = await TrackRepo.getUserLocationData(gId);
      if (res.status == true && res.locations != null && res.locations!.isNotEmpty) {
        final List<UsersWithinRadiusData> groupUsers = [];
        for (var loc in res.locations!) {
          final uId = loc.userId?.toString() ?? '';
          if (uId.isEmpty) continue;

          final double? lat = double.tryParse(loc.latitude?.toString() ?? '');
          final double? lng = double.tryParse(loc.longitude?.toString() ?? '');
          final bool isOnline = loc.isOnline == true ||
              Tracking().isOnline(rawIsOnline: loc.isOnline, lastSeen: loc.lastSeen?.toString());

          groupUsers.add(UsersWithinRadiusData(
            userId: loc.userId,
            name: (loc.name != null && loc.name.toString().trim().isNotEmpty)
                ? loc.name.toString().trim()
                : "Member $uId",
            profileImage: loc.profileImage?.toString(),
            latitude: lat,
            longitude: lng,
            isOnline: isOnline,
            lastSeen: loc.lastSeen?.toString(),
            team: selectedGroupName.value,
            location: null,
          ));
        }

        if (groupUsers.isNotEmpty) {
          radiusUsers.assignAll(groupUsers);
          await _resolveAllMembersAddresses();
          _refreshMembersAndMap();
          fitAllMembers();
        }
      } else {
        // Fallback: fetch from GroupRepo.getMemberData
        final memberRes = await GroupRepo.getMemberData(groupId);
        if (memberRes.status == true && memberRes.memberData != null && memberRes.memberData!.isNotEmpty) {
          final List<UsersWithinRadiusData> groupUsers = [];
          for (var m in memberRes.memberData!) {
            final bool isOnline = m.isOnline == true ||
                Tracking().isOnline(rawIsOnline: m.isOnline, lastSeen: m.lastSeen);
            groupUsers.add(UsersWithinRadiusData(
              userId: m.userId,
              name: m.name ?? m.mobileNo ?? "Member ${m.userId ?? ''}",
              profileImage: m.profileImage,
              latitude: null,
              longitude: null,
              isOnline: isOnline,
              lastSeen: m.lastSeen,
              team: selectedGroupName.value,
              location: null,
            ));
          }
          if (groupUsers.isNotEmpty) {
            radiusUsers.assignAll(groupUsers);
            _refreshMembersAndMap();
          }
        }
      }
    } catch (e) {
      debugPrint("Error in fetchGroupLocationData: $e");
    } finally {
      isLoading.value = false;
    }
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
      } else if (u.location != null &&
          u.location!.trim().isNotEmpty &&
          u.location != "Location unavailable" &&
          u.location != "Locating...") {
        futures.add(() async {
          try {
            final locs = await locationFromAddress(u.location!.trim());
            if (locs.isNotEmpty) {
              u.latitude = locs.first.latitude;
              u.longitude = locs.first.longitude;
              debugPrint("📍 Geocoded '${u.location}' to coords: (${u.latitude}, ${u.longitude})");
              return;
            }
          } catch (_) {}
          try {
            final dio = Dio();
            final res = await dio.get(
              "https://maps.googleapis.com/maps/api/geocode/json",
              queryParameters: {
                "address": u.location!.trim(),
                "key": ConstRes.gMapApiKey,
              },
            );
            if (res.data != null &&
                res.data['results'] is List &&
                (res.data['results'] as List).isNotEmpty) {
              final loc = res.data['results'][0]['geometry']['location'];
              u.latitude = (loc['lat'] as num).toDouble();
              u.longitude = (loc['lng'] as num).toDouble();
              debugPrint("📍 Google Geocoded '${u.location}' to coords: (${u.latitude}, ${u.longitude})");
            }
          } catch (_) {}
        }());
      }
    }
    if (futures.isNotEmpty) {
      try {
        await Future.wait(futures).timeout(const Duration(seconds: 4));
      } catch (_) {}
      _refreshMembersAndMap();
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

    _refreshMembersAndMap();

    // If first time valid coordinates are set, request live members from users-within-radius API
    if (firstValidCoords) {
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

    // 4. Fetch users within radius API strictly
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

        radiusUsers.assignAll(result.data!);
        await _resolveAllMembersAddresses();
      } else {
        debugPrint(
            "⚠️ /users-within-radius returned: ${result.message}");
        radiusUsers.clear();
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
    final query = value.trim().toLowerCase();
    searchQuery.value = value.trim();
    isSearchDropdownOpen.value = value.trim().isNotEmpty;

    if (selectedTabIndex.value == 1) {
      if (query.isEmpty) {
        filteredGroups.value = groupList;
      } else {
        filteredGroups.value = groupList
            .where((g) =>
                (g.groupName ?? "").toLowerCase().contains(query) ||
                (g.groupDesc ?? "").toLowerCase().contains(query) ||
                (g.groupCode ?? "").toLowerCase().contains(query))
            .toList();
      }
    } else {
      if (query.isEmpty) {
        liveMembers.value = allFetchedMembers;
      } else {
        liveMembers.value = allFetchedMembers
            .where((m) =>
                m.name.toLowerCase().contains(query) ||
                m.team.toLowerCase().contains(query) ||
                m.location.toLowerCase().contains(query))
            .toList();
      }
    }
    updateMapMarkersAndCircle();
  }

  void submitSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;

    isSearchDropdownOpen.value = false;

    // Search in online radiusUsers first
    final matchingUsers = radiusUsers.where((u) {
      final name = (u.name ?? "").toLowerCase();
      final team = (u.team ?? "").toLowerCase();
      final loc = (u.location ?? "").toLowerCase();
      return u.isOnline &&
          (name.contains(q) || team.contains(q) || loc.contains(q)) &&
          u.latitude != null &&
          u.longitude != null &&
          u.latitude != 0.0 &&
          u.longitude != 0.0;
    }).toList();

    if (matchingUsers.isNotEmpty) {
      if (matchingUsers.length == 1) {
        final u = matchingUsers.first;
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(u.latitude!, u.longitude!),
              zoom: 17.0,
            ),
          ),
        );
      } else {
        double minLat = matchingUsers.first.latitude!;
        double maxLat = matchingUsers.first.latitude!;
        double minLng = matchingUsers.first.longitude!;
        double maxLng = matchingUsers.first.longitude!;
        for (var u in matchingUsers) {
          if (u.latitude! < minLat) minLat = u.latitude!;
          if (u.latitude! > maxLat) maxLat = u.latitude!;
          if (u.longitude! < minLng) minLng = u.longitude!;
          if (u.longitude! > maxLng) maxLng = u.longitude!;
        }
        if (minLat == maxLat && minLng == maxLng) {
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(minLat, minLng),
                zoom: 17.0,
              ),
            ),
          );
        } else {
          mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(minLat, minLng),
                northeast: LatLng(maxLat, maxLng),
              ),
              80.0,
            ),
          );
        }
      }
      return;
    }

    // Check allFetchedMembers if not in radiusUsers
    final matchingMembers = allFetchedMembers.where((m) {
      final name = m.name.toLowerCase();
      final team = m.team.toLowerCase();
      final loc = m.location.toLowerCase();
      return (name.contains(q) || team.contains(q) || loc.contains(q)) &&
          m.latitude != null &&
          m.longitude != null &&
          m.latitude != 0.0 &&
          m.longitude != 0.0;
    }).toList();

    if (matchingMembers.isNotEmpty) {
      final m = matchingMembers.first;
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(m.latitude!, m.longitude!),
            zoom: 17.0,
          ),
        ),
      );
      return;
    }

    // Check matching groups
    final matchingGroups = groupList.where((g) {
      final name = (g.groupName ?? "").toLowerCase();
      final desc = (g.groupDesc ?? "").toLowerCase();
      final code = (g.groupCode ?? "").toLowerCase();
      return name.contains(q) || desc.contains(q) || code.contains(q);
    }).toList();

    if (matchingGroups.isNotEmpty) {
      selectTab(1);
      return;
    }

    Get.snackbar(
      "Search",
      "No members or groups found for '$query'",
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E1B4B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
    searchController.clear();
    searchQuery.value = "";
    isSearchDropdownOpen.value = false;
    if (index == 1) {
      filteredGroups.value = groupList;
      fetchGroupData();
    } else {
      liveMembers.value = allFetchedMembers;
    }
    updateMapMarkersAndCircle();
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
    _zoomForRadius(double.tryParse(value) ?? 0.1);
  }

  Future<void> updateMapMarkersAndCircle() async {
    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double lng = currentLong.value != 0.0 ? currentLong.value : 72.8777;
    final double radiusKm = double.tryParse(selectedRadius.value) ?? 2.0;
    final double radiusMeters = radiusKm * 1000.0;

    // Update Radius Circle & Dashed Boundary Line
    circles.value = {
      Circle(
        circleId: const CircleId('tracking_radius_circle'),
        center: LatLng(lat, lng),
        radius: radiusMeters,
        fillColor: const Color(0xFF818CF8).withOpacity(0.12),
        strokeWidth: 0,
      ),
    };

    final List<LatLng> dashedPoints = [];
    const int numPoints = 72;
    final double cosLat = math.cos(lat * math.pi / 180.0);
    final double effectiveCosLat = cosLat.abs() < 0.0001 ? 1.0 : cosLat;
    for (int i = 0; i <= numPoints; i++) {
      final double theta = (i / numPoints) * 2 * math.pi;
      final double dLat = (radiusMeters * math.cos(theta)) / 111320.0;
      final double dLng = (radiusMeters * math.sin(theta)) /
          (111320.0 * effectiveCosLat);
      dashedPoints.add(LatLng(lat + dLat, lng + dLng));
    }

    polylines.value = {
      Polyline(
        polylineId: const PolylineId('tracking_radius_dashed_line'),
        points: dashedPoints,
        color: const Color(0xFF6366F1),
        width: 2,
        patterns: [
          PatternItem.dash(12),
          PatternItem.gap(8),
        ],
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

    // Member markers - only show online members on the live map
    final String q = searchController.text.trim().toLowerCase();
    final List<UsersWithinRadiusData> membersToMark =
        radiusUsers.where((u) => u.isOnline).toList();
    for (var u in membersToMark) {
      if (u.latitude != null &&
          u.longitude != null &&
          u.latitude != 0.0 &&
          u.longitude != 0.0) {
        if (q.isNotEmpty) {
          final matches = (u.name ?? "").toLowerCase().contains(q) ||
              (u.team ?? "").toLowerCase().contains(q) ||
              (u.location ?? "").toLowerCase().contains(q) ||
              (u.mobileNo ?? "").toLowerCase().contains(q);
          if (!matches) continue;
        }
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
        final String distanceText;
        if (u.distance != null &&
            u.distance!.trim().isNotEmpty &&
            !u.distance!.toLowerCase().contains("nan")) {
          final dStr = u.distance!.trim();
          if (dStr.contains("away")) {
            distanceText = dStr;
          } else if (dStr.contains("km") || dStr.contains("m")) {
            distanceText = "$dStr away";
          } else {
            distanceText = "$dStr km away";
          }
        } else {
          distanceText = "Nearby";
        }

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
    final double radiusKm = double.tryParse(selectedRadius.value) ?? 2.0;
    _zoomForRadius(radiusKm);
  }

  String formatRadius(String radiusKmStr) {
    final double radiusKm = double.tryParse(radiusKmStr) ?? 0.1;
    final double meters = radiusKm * 1000.0;
    if (meters < 1000) {
      return "${meters.round()} m";
    } else {
      final double km = radiusKm;
      return km == km.toInt()
          ? "${km.toInt()} km"
          : "${km.toStringAsFixed(1)} km";
    }
  }

  String get currentFormattedRadius => formatRadius(selectedRadius.value);

  double calculateZoomForRadius(double radiusKm) {
    final double radiusMeters = radiusKm * 1000.0;
    if (radiusMeters <= 120) return 16.8;
    if (radiusMeters <= 260) return 15.8;
    if (radiusMeters <= 600) return 14.8;
    if (radiusMeters <= 1200) return 13.8;
    if (radiusMeters <= 2500) return 12.8;
    if (radiusMeters <= 5500) return 11.5;
    return 10.5;
  }

  void _zoomForRadius(double radiusKm) {
    if (mapController == null) return;
    final double zoomLevel = calculateZoomForRadius(radiusKm);

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

    final List<UsersWithinRadiusData> membersToFit =
        radiusUsers.where((u) => u.isOnline).toList();
    for (var u in membersToFit) {
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

  void recenterMap({double? zoom}) {
    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double lng = currentLong.value != 0.0 ? currentLong.value : 72.8777;
    final double radiusKm = double.tryParse(selectedRadius.value) ?? 2.0;
    final double targetZoom = zoom ?? calculateZoomForRadius(radiusKm);
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: targetZoom,
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
    for (var m in allFetchedMembers) {
      if (m.userId.toString() == userId &&
          m.latitude != null &&
          m.longitude != null &&
          m.latitude != 0.0) {
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(m.latitude!, m.longitude!),
              zoom: 17.0,
            ),
          ),
        );
        return;
      }
    }
  }

  void focusMember(MemberModel member) {
    if (member.latitude != null &&
        member.longitude != null &&
        member.latitude != 0.0 &&
        member.longitude != 0.0) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(member.latitude!, member.longitude!),
            zoom: 17.0,
          ),
        ),
      );
    } else {
      focusMemberById(member.userId.toString());
    }
  }

  @override
  void onClose() {
    _socketLiveLocationSubscription?.cancel();
    _trackLiveSocketSubscription?.cancel();
    _userStatusSocketSubscription?.cancel();
    _positionStreamSubscription?.cancel();
    _groupCountSubscription?.cancel();
    customRadiusController.dispose();
    searchController.dispose();
    mapController?.dispose();
    super.onClose();
  }
}