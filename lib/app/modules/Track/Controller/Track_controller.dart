import 'dart:async';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';
import 'package:fgtracker/app/Model/UsersWithinRadiusRes.dart';
import 'package:fgtracker/app/Model/live_location_model.dart';
import 'package:fgtracker/app/Model/member_live_status.dart';
import 'package:fgtracker/app/modules/Track/Controller/LocationService.dart';
import 'package:fgtracker/app/modules/Track/Controller/SocketServices.dart';
import 'package:fgtracker/app/modules/Track/Widget/Track_widget.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  RxBool isGroupLoading = false.obs;
  RxString groupError = "".obs;

  RxInt liveNowCount = 0.obs;
  RxInt totalMembersCount = 0.obs;

  // Location & Group Name Observables
  RxString currentLocationName = "Locating...".obs;
  RxString selectedGroupName = "FG Team".obs;
  RxString selectedGroupId = "".obs;

  // Google Map State
  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Circle> circles = <Circle>{}.obs;
  final Map<String, BitmapDescriptor> _markerIconCache = {};

  StreamSubscription<List<LiveLocationModel>>? _socketLiveLocationSubscription;
  StreamSubscription<Position>? _positionStreamSubscription;

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

    // 5. Fetch group data, members, and GPS coordinates
    fetchLiveMembers();
    fetchGroupData();
    getCurrentLocationAndFetchUsers();
    _startPositionListening();
  }

  Future<void> _loadInitialLocation() async {
    // A. Instant user location from HomeController (if navigating from Home screen)
    try {
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();

        if (home.currentLocation.value != null) {
          currentLat.value = home.currentLocation.value!.latitude;
          currentLong.value = home.currentLocation.value!.longitude;
          debugPrint("📍 Instant location loaded from HomeController: ${currentLat.value}, ${currentLong.value}");
          reverseGeocodeLocation(currentLat.value, currentLong.value);
        }

        if (home.liveLocations.isNotEmpty) {
          debugPrint("👥 Instant ${home.liveLocations.length} live members loaded from HomeController");
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
            '');
        final lng = double.tryParse(item['lng']?.toString() ??
            item['lon']?.toString() ??
            item['longitude']?.toString() ??
            '');

        if (userId != null &&
            lat != null &&
            lng != null &&
            lat != 0.0 &&
            lng != 0.0) {
          final existingIdx = radiusUsers.indexWhere(
              (u) => u.userId.toString() == userId.toString());
          if (existingIdx >= 0) {
            radiusUsers[existingIdx].latitude = lat;
            radiusUsers[existingIdx].longitude = lng;
            radiusUsers[existingIdx].isOnline = true;
          } else {
            radiusUsers.add(UsersWithinRadiusData(
              userId: userId,
              name: item['name']?.toString() ?? "Member",
              latitude: lat,
              longitude: lng,
              isOnline: true,
              team: selectedGroupName.value,
            ));
          }
          _refreshMembersAndMap();
        }
      }
    });
  }

  void _mergeSocketLocations(List<LiveLocationModel> socketUsers) {
    for (var su in socketUsers) {
      if (su.latitude == 0.0 || su.longitude == 0.0) continue;

      final existingIndex = radiusUsers
          .indexWhere((u) => u.userId.toString() == su.userId.toString());
      final updatedUser = UsersWithinRadiusData(
        userId: su.userId,
        name: su.fullName,
        profileImage: su.profileImage,
        latitude: su.latitude,
        longitude: su.longitude,
        isOnline: su.isOnline,
        team: selectedGroupName.value,
      );
      if (existingIndex >= 0) {
        radiusUsers[existingIndex] = updatedUser;
      } else {
        radiusUsers.add(updatedUser);
      }
    }
    _refreshMembersAndMap();
  }

  void _refreshMembersAndMap() {
    final mapped = radiusUsers
        .map((e) => e.toMemberModel(
              currentUserLat: currentLat.value,
              currentUserLong: currentLong.value,
            ))
        .toList();

    allFetchedMembers.value = mapped;
    liveNowCount.value = mapped.length;
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

        if ((selectedGroupName.value.isEmpty ||
                selectedGroupName.value == "FG Team") &&
            groupList.isNotEmpty &&
            groupList.first.groupName != null) {
          selectedGroupName.value = groupList.first.groupName!;
          selectedGroupId.value = groupList.first.id?.toString() ?? "";
        }

        // Fetch location data for all groups so all members' live coordinates load immediately
        for (var g in groupList) {
          if (g.id != null) {
            _joinGroupSocket(g.id!.toString());
            fetchGroupLocations(g.id!);
          }
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

  Future<void> fetchGroupLocations(int groupId) async {
    try {
      final LocationDataRes result =
          await TrackRepo.getUserLocationData(groupId);
      if (result.status == true &&
          result.locations != null &&
          result.locations!.isNotEmpty) {
        debugPrint(
            "📍 Loaded ${result.locations!.length} member locations from /getGrouplocationsData for group $groupId");

        for (var loc in result.locations!) {
          if (loc.userId == null) continue;
          if (loc.latitude == null ||
              loc.longitude == null ||
              loc.latitude == 0.0 ||
              loc.longitude == 0.0) continue;

          final existingIdx = radiusUsers
              .indexWhere((u) => u.userId.toString() == loc.userId.toString());
          final updated = UsersWithinRadiusData(
            userId: loc.userId,
            name: loc.name,
            profileImage: loc.profileImage,
            latitude: loc.latitude,
            longitude: loc.longitude,
            isOnline: loc.isOnline == 1 || loc.isOnline == true,
            team: selectedGroupName.value,
            lastSeen: loc.lastSeen?.toString(),
          );

          if (existingIdx >= 0) {
            radiusUsers[existingIdx] = updated;
          } else {
            radiusUsers.add(updated);
          }
        }

        _refreshMembersAndMap();
      }
    } catch (e) {
      debugPrint("❌ Error fetching group location data: $e");
    }
  }

  void selectGroup(GroupsResData group) {
    selectedGroupName.value = group.groupName ?? "Group";
    selectedGroupId.value = group.id?.toString() ?? "";
    if (group.id != null) {
      _joinGroupSocket(group.id!.toString());
      fetchGroupLocations(group.id!);
    }
    getUsersWithinRadius();
  }

  Future<void> fetchLiveMembers() async {
    try {
      final MemberLiveStatus result = await TrackRepo.getGroupMember(
        page: '0',
        filter: 'online',
      );

      if (result.status == true &&
          result.data != null &&
          result.data!.isNotEmpty) {
        final onlineList = result.data!
            .where((m) => m.isOnline == 1 || m.online)
            .toList();
        final listToUse = onlineList.isNotEmpty ? onlineList : result.data!;
        onlineGroupMembers.value = listToUse;
        liveNowCount.value = listToUse.length;
        if (result.pagination?.totalRecords != null) {
          totalMembersCount.value = result.pagination!.totalRecords!;
        }

        if (radiusUsers.isEmpty) {
          final mapped = listToUse.map((m) {
            String avatar = "https://i.pravatar.cc/150?img=11";
            if (m.profileImage != null && m.profileImage!.isNotEmpty) {
              avatar = m.profileImage!.startsWith("http")
                  ? m.profileImage!
                  : "${ConstRes.aImageBaseUrl}${m.profileImage}";
            }
            return MemberModel(
              name: m.name?.isNotEmpty == true
                  ? m.name!
                  : "Member ${m.userId ?? ''}",
              team: selectedGroupName.value.isNotEmpty
                  ? selectedGroupName.value
                  : "FG Team",
              location:
                  m.lastSeen?.isNotEmpty == true ? m.lastSeen! : "Active now",
              distance: "0.5",
              battery: 85,
              avatarUrl: avatar,
            );
          }).toList();

          allFetchedMembers.value = mapped;
          if (searchController.text.trim().isEmpty) {
            liveMembers.value = mapped;
          } else {
            onSearch(searchController.text.trim());
          }
        }
      }
    } catch (_) {}
  }

  Future<void> reverseGeocodeLocation(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.toString().trim().isNotEmpty).toList();
        if (parts.isNotEmpty) {
          currentLocationName.value = parts.join(", ");
        } else if (place.name != null && place.name!.isNotEmpty) {
          currentLocationName.value = place.name!;
        }
      }
    } catch (_) {
      currentLocationName.value =
          "Lat: ${lat.toStringAsFixed(2)}, Lng: ${lng.toStringAsFixed(2)}";
    }
  }

  void _updateUserLocation(double lat, double lng) {
    currentLat.value = lat;
    currentLong.value = lng;

    try {
      Global.storageServices.setDouble('user_last_lat', lat);
      Global.storageServices.setDouble('user_last_lng', lng);
    } catch (_) {}

    reverseGeocodeLocation(lat, lng);

    // Keep user's own location centered right in front of them
    if (mapController != null) {
      recenterMap(zoom: 16.0);
    }

    updateMapMarkersAndCircle();
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

    SocketDashboardService.instance.requestLiveLocation(
      userLat: lat,
      userLong: long,
      radius: selectedRadius.value,
    );

    // Also send a delayed backup request after socket handshake finishes
    Future.delayed(const Duration(milliseconds: 800), () {
      SocketDashboardService.instance.requestLiveLocation(
        userLat: lat,
        userLong: long,
        radius: selectedRadius.value,
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

      if (result.status == true &&
          result.data != null &&
          result.data!.isNotEmpty) {
        debugPrint(
            "📍 Loaded ${result.data!.length} users from /users-within-radius");

        for (var u in result.data!) {
          if (u.userId == null) continue;
          final existingIdx = radiusUsers.indexWhere(
              (item) => item.userId.toString() == u.userId.toString());
          if (existingIdx >= 0) {
            radiusUsers[existingIdx] = u;
          } else {
            radiusUsers.add(u);
          }
        }
        _refreshMembersAndMap();
      }
    } catch (e) {
      responseError.value = e.toString();
      debugPrint("❌ Error in getUsersWithinRadius: $e");
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
      if (groupList.isEmpty) {
        fetchGroupData();
      }
    } else {
      liveMembers.value = allFetchedMembers;
    }
  }

  void updateRadius(String value) {
    selectedRadius.value = value;

    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double long = currentLong.value != 0.0 ? currentLong.value : 72.8777;

    // Trigger Socket Live Location request on radius change
    SocketDashboardService.instance.requestLiveLocation(
      userLat: lat,
      userLong: long,
      radius: value,
    );

    if (SocketService.instance.isSocketConnected) {
      try {
        SocketService.instance.socket.emit("radius-change", {
          "userId": Global.storageServices.get(PrefConst.userId),
          "lat": lat,
          "long": long,
          "radius": value,
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
        fillColor: const Color(0xFF5C4CFF).withOpacity(0.12),
        strokeColor: const Color(0xFF5C4CFF).withOpacity(0.65),
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
    final cacheKey = "me_${myProfileImg}_custom";
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
        final cacheKey = "${u.userId}_${u.profileImage}_${u.isOnline}";
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

        final distanceText =
            u.distance != null ? "${u.distance} km away" : "Nearby";

        newMarkers.add(
          Marker(
            markerId: MarkerId('user_${u.userId}'),
            position: LatLng(u.latitude!, u.longitude!),
            icon: customIcon,
            infoWindow: InfoWindow(
              title: u.name ?? "Member",
              snippet: distanceText,
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

  @override
  void onClose() {
    _socketLiveLocationSubscription?.cancel();
    _positionStreamSubscription?.cancel();
    customRadiusController.dispose();
    searchController.dispose();
    mapController?.dispose();
    super.onClose();
  }
}