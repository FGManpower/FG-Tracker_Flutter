import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteOption {
  final String id;
  final String name;
  final double distanceKm;
  final int etaMin;
  final bool recommended;
  final Color color;

  RouteOption(
      this.id,
      this.name,
      this.distanceKm,
      this.etaMin, {
        this.recommended = false,
        required this.color,
      });
}

class GroupRouteMember {
  final String name;
  final String start;
  final String end;
  final String routeName;
  final String avatar;
  final Color dot;

  GroupRouteMember({
    required this.name,
    required this.start,
    required this.end,
    required this.routeName,
    required this.avatar,
    required this.dot,
  });
}

class SafeRouteController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  GoogleMapController? individualMapController;
  GoogleMapController? groupMapController;

  final TextEditingController searchController = TextEditingController();

  final RxString selectedMember = "Rahul Verma".obs;
  final RxString memberPhone = "+91 98765 43210".obs;
  final RxString startLocation = "Chembur, Mumbai".obs;
  final RxString destinationLocation = "Ghatkopar, Mumbai".obs;

  final RxString selectedGroup = "FG Manpower Team".obs;
  final RxInt selectedGroupMemberIndex = 0.obs;

  final List<GroupRouteMember> groupMembers = [
    GroupRouteMember(
      name: "Rahul Verma",
      start: "Chembur",
      end: "Ghatkopar",
      routeName: "Route A",
      avatar: "https://i.pravatar.cc/150?img=11",
      dot: Colors.green,
    ),
    GroupRouteMember(
      name: "Aamir Khan",
      start: "Andheri",
      end: "Bandra",
      routeName: "Route B",
      avatar: "https://i.pravatar.cc/150?img=12",
      dot: Colors.orange,
    ),
    GroupRouteMember(
      name: "Sameer Shaikh",
      start: "Kurla",
      end: "Powai",
      routeName: "Route C",
      avatar: "https://i.pravatar.cc/150?img=13",
      dot: Colors.blue,
    ),
    GroupRouteMember(
      name: "Vikram Singh",
      start: "Thane",
      end: "Dadar",
      routeName: "Route A",
      avatar: "https://i.pravatar.cc/150?img=14",
      dot: Colors.purple,
    ),
  ];

  final List<RouteOption> routes = [
    RouteOption(
      "A",
      "Route A",
      12.4,
      28,
      recommended: true,
      color: const Color(0xFF5A3EFE),
    ),
    RouteOption(
      "B",
      "Route B",
      13.1,
      31,
      color: const Color(0xFFB8B0FF),
    ),
    RouteOption(
      "C",
      "Route C",
      14.6,
      35,
      color: const Color(0xFFB8B0FF),
    ),
  ];

  final RxString selectedRouteId = "A".obs;

  final List<double> deviationOptions = [100, 250, 500, 1000, 2000, 5000];
  final RxInt individualDeviationIndex = 2.obs;
  final RxInt groupDeviationIndex = 2.obs;

  final LatLng startLatLng = const LatLng(19.0522, 72.8973);
  final LatLng endLatLng = const LatLng(19.0863, 72.9080);

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    searchController.text = "Chembur, Mumbai";

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        reCenter(isGroup: tabController.index == 1);
      }
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    individualMapController?.dispose();
    groupMapController?.dispose();
    searchController.dispose();
    super.onClose();
  }

  bool get isGroupTab => tabController.index == 1;

  RouteOption get selectedRoute =>
      routes.firstWhere((r) => r.id == selectedRouteId.value);

  double get individualDeviation =>
      deviationOptions[individualDeviationIndex.value];

  double get groupDeviation => deviationOptions[groupDeviationIndex.value];

  double deviationFor({required bool isGroup}) =>
      isGroup ? groupDeviation : individualDeviation;

  GroupRouteMember get currentGroupMember =>
      groupMembers[selectedGroupMemberIndex.value];

  void selectRoute(String id) {
    selectedRouteId.value = id;
  }

  void swapLocations() {
    final tmp = startLocation.value;
    startLocation.value = destinationLocation.value;
    destinationLocation.value = tmp;
  }

  void setStartLocation(String value) {
    startLocation.value = value;
  }

  void setDestinationLocation(String value) {
    destinationLocation.value = value;
  }

  void onDeviationSlider(double val, {required bool isGroup}) {
    if (isGroup) {
      groupDeviationIndex.value = val.round();
    } else {
      individualDeviationIndex.value = val.round();
    }
  }

  void searchLocation(String query) {
    if (query.trim().isEmpty) return;
    // TODO: Geocoding API se LatLng lao
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void clearSearch() {
    searchController.clear();
  }

  void onMapCreated(GoogleMapController controller, {required bool isGroup}) {
    if (isGroup) {
      groupMapController = controller;
    } else {
      individualMapController = controller;
    }
    fitRouteBounds(isGroup: isGroup);
  }

  void reCenter({required bool isGroup}) {
    fitRouteBounds(isGroup: isGroup);
  }

  void zoomIn({required bool isGroup}) {
    final map = isGroup ? groupMapController : individualMapController;
    map?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut({required bool isGroup}) {
    final map = isGroup ? groupMapController : individualMapController;
    map?.animateCamera(CameraUpdate.zoomOut());
  }

  void fitRouteBounds({required bool isGroup}) {
    final map = isGroup ? groupMapController : individualMapController;
    if (map == null) return;

    final points = polylineFor(selectedRouteId.value);
    if (points.isEmpty) {
      map.animateCamera(CameraUpdate.newLatLngZoom(startLatLng, 12.5));
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    map.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
    );
  }

  String formatDeviation(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      return "${km % 1 == 0 ? km.toInt() : km} km";
    }
    return "${meters.toInt()} m";
  }

  List<LatLng> polylineFor(String id) {
    switch (id) {
      case "A":
        return const [
          LatLng(19.0522, 72.8973),
          LatLng(19.0580, 72.8990),
          LatLng(19.0650, 72.9020),
          LatLng(19.0720, 72.9045),
          LatLng(19.0800, 72.9065),
          LatLng(19.0863, 72.9080),
        ];
      case "B":
        return const [
          LatLng(19.0522, 72.8973),
          LatLng(19.0550, 72.9050),
          LatLng(19.0620, 72.9100),
          LatLng(19.0720, 72.9120),
          LatLng(19.0800, 72.9100),
          LatLng(19.0863, 72.9080),
        ];
      case "C":
      default:
        return const [
          LatLng(19.0522, 72.8973),
          LatLng(19.0480, 72.9000),
          LatLng(19.0550, 72.9150),
          LatLng(19.0700, 72.9200),
          LatLng(19.0820, 72.9120),
          LatLng(19.0863, 72.9080),
        ];
    }
  }

  Set<Marker> get routeMarkers => {
    Marker(
      markerId: const MarkerId('start'),
      position: startLatLng,
      infoWindow: const InfoWindow(title: 'Start'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ),
    Marker(
      markerId: const MarkerId('end'),
      position: endLatLng,
      infoWindow: const InfoWindow(title: 'End'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
  };

  Set<Polyline> get currentPolylines {
    final id = selectedRouteId.value;
    return {
      Polyline(
        polylineId: PolylineId(id),
        points: polylineFor(id),
        color: const Color(0xFF5A3EFE),
        width: 5,
      ),
    };
  }
}