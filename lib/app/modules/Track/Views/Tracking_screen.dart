import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Controller/Track_controller.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

class TrackingScreen extends StatelessWidget {
  TrackingScreen({super.key});

  final TrackController controller = Get.put(TrackController());

  final Color primaryColor = const Color(0xFF5C4CFF);
  final Color bgColor = const Color(0xFFF8F9FE);
  final Color cardColor = Colors.white;
  final Color textDark = const Color(0xFF0F172A);
  final Color textGrey = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildCustomTabs(),
              Obx(() {
                if (controller.selectedTabIndex.value == 1) {
                  return _buildGroupTabContent();
                }
                return Column(
                  children: [
                    _buildSearchAndRadius(),
                    _buildMapSection(),
                    _buildStatsCard(),
                    _buildLiveMembersList(),
                    _buildBottomShareButton(),
                  ],
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _iconButton(
            icon: Icons.arrow_back,
            onTap: () => Get.back(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tracking",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Obx(
                  () => Row(
                    children: [
                      // Group Name chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.groups_rounded,
                                size: 12, color: primaryColor),
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: Text(
                                controller.selectedGroupName.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Location Name chip
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 12, color: Colors.redAccent),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                controller.currentLocationName.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _iconButton(
            icon: Icons.refresh,
            onTap: () {
              controller.getCurrentLocationAndFetchUsers();
            },
          ),
        ],
      ),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  Widget _buildCustomTabs() {
    return DefaultTabController(
      length: 2,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 46,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: TabBar(
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: textGrey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            onTap: (index) => controller.selectTab(index),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sensors, size: 15),
                    SizedBox(width: 6),
                    Text("Live Tracking"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups_rounded, size: 16),
                    SizedBox(width: 6),
                    Text("Group"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndRadius() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearch,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
                  prefixIconConstraints: BoxConstraints(minWidth: 40),
                  hintText: "Search member",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12.5),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Obx(() {
              return PopupMenuButton<String>(
                offset: const Offset(0, 46),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) => controller.updateRadius(value),
                itemBuilder: (context) => ["2", "4", "6", "8"]
                    .map(
                      (r) => PopupMenuItem<String>(
                        value: r,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$r km",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            if (controller.selectedRadius.value == r)
                              Icon(Icons.check, color: primaryColor, size: 16),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.gps_fixed, color: primaryColor, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Radius: ${controller.selectedRadius.value} km",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAED),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Live Interactive Google Map
            Obx(() {
              final lat = controller.currentLat.value != 0.0
                  ? controller.currentLat.value
                  : 19.0760;
              final lng = controller.currentLong.value != 0.0
                  ? controller.currentLong.value
                  : 72.8777;

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, lng),
                  zoom: 16.0,
                ),
                markers: controller.markers.value,
                circles: controller.circles.value,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: false,
                buildingsEnabled: true,
                mapType: MapType.normal,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                onMapCreated: controller.onMapCreated,
              );
            }),

            // Top-left chip: Group Name & Location Name
            Positioned(
              top: 10,
              left: 10,
              child: Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.groups_rounded, color: primaryColor, size: 14),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: Text(
                          controller.selectedGroupName.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        height: 12,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          controller.currentLocationName.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-left badge: Live Members and Radius
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Obx(
                      () => Text(
                        "${controller.liveNowCount.value} Members Live",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 12,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 6),
                    Obx(
                      () => Text(
                        "${controller.selectedRadius.value} km radius",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Map Control Buttons (Zoom in, Zoom out, Recenter)
            Positioned(
              right: 10,
              bottom: 10,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                          width: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: controller.zoomIn,
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                        ),
                        SizedBox(
                          height: 30,
                          width: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: controller.zoomOut,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // My Location Button (re-centers camera right on user)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: "My Location",
                      icon: Icon(Icons.my_location,
                          size: 16, color: primaryColor),
                      onPressed: () => controller.recenterMap(zoom: 16.0),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Fit All Members Button (zooms out to show all members)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: "All Members",
                      icon: const Icon(Icons.zoom_out_map,
                          size: 16, color: Colors.black87),
                      onPressed: controller.fitAllMembers,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Requirement 2 & 8: Group Name shown instead of Total Members
          Obx(
            () => _statItem(
              Icons.groups_rounded,
              "Group",
              controller.selectedGroupName.value,
              primaryColor,
            ),
          ),
          _divider(),
          Obx(
            () => _statItem(
              Icons.circle,
              "Live Now",
              "${controller.liveNowCount.value}",
              Colors.green,
              iconSize: 8,
            ),
          ),
          _divider(),
          Obx(
            () => _statItem(
              Icons.gps_fixed,
              "Tracking Radius",
              "${controller.selectedRadius.value} km",
              primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    IconData icon,
    String title,
    String value,
    Color iconColor, {
    double iconSize = 13,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: iconSize),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(height: 28, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildLiveMembersList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          // Requirement 7: View All button removed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Live Members",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Obx(
                () => Text(
                  "${controller.liveMembers.length} nearby",
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoading.value && controller.liveMembers.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.liveMembers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    "No members found within radius",
                    style: TextStyle(color: textGrey, fontSize: 13),
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.liveMembers.length,
              itemBuilder: (context, index) {
                return _memberCard(controller.liveMembers[index]);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _memberCard(MemberModel member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(member.avatarUrl),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 1),
                // Requirement 2: Show Group Name
                Text(
                  member.team,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                // Requirement 3: Show Location Name
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.redAccent, size: 11),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        member.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textGrey, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Requirement 5: Accurately calculated KM Distance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                member.distance.contains('km') || member.distance.contains('m')
                    ? "${member.distance} away"
                    : "${member.distance} km away",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.battery_5_bar_rounded,
                      color: primaryColor, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    "${member.battery}%",
                    style: TextStyle(color: primaryColor, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Transform.rotate(
              angle: -0.5,
              child: Icon(Icons.send_rounded, color: primaryColor, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomShareButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_alt, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Share Live Location",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Share your live location with team",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward, color: primaryColor, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTabContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearch,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
                prefixIconConstraints: BoxConstraints(minWidth: 40),
                hintText: "Search groups...",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12.5),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Groups",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Obx(
                () => Text(
                  "${controller.filteredGroups.length} Groups",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isGroupLoading.value &&
                controller.filteredGroups.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.filteredGroups.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    controller.groupError.isNotEmpty
                        ? controller.groupError.value
                        : "No groups found",
                    style: TextStyle(color: textGrey, fontSize: 13),
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredGroups.length,
              itemBuilder: (context, index) {
                return _groupCard(controller.filteredGroups[index]);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _groupCard(GroupsResData group) {
    final String? profileUrl =
        group.groupProfile != null && group.groupProfile!.isNotEmpty
            ? (group.groupProfile!.startsWith("http")
                ? group.groupProfile!
                : "${ConstRes.aImageBaseUrl}${group.groupProfile}")
            : null;

    final isSelected =
        controller.selectedGroupId.value == group.id?.toString();

    return GestureDetector(
      onTap: () {
        controller.selectGroup(group);
        Get.toNamed(
          Routes.Memberscreen,
          arguments: {
            "groupId": group.id?.toString() ?? "",
            "groupName": group.groupName ?? "",
            "groupCode": group.groupCode ?? "",
            "isCreator": group.isCreator?.toString() ?? "false",
            "isActive": group.isActive?.toString() ?? "false",
          },
        )?.then((value) {
          if (value == true) {
            controller.fetchGroupData();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade100,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                image: profileUrl != null
                    ? DecorationImage(
                        image: NetworkImage(profileUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profileUrl == null
                  ? Icon(Icons.groups_rounded, color: primaryColor, size: 22)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.groupName ?? "Unnamed Group",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),
                      if (group.isCreator == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Admin",
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    (group.groupDesc != null && group.groupDesc!.isNotEmpty)
                        ? group.groupDesc!
                        : (group.groupCode != null
                            ? "Code: ${group.groupCode}"
                            : "No description"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEEFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, size: 11, color: primaryColor),
                      const SizedBox(width: 3),
                      Text(
                        "${group.memberCount ?? 0}",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
