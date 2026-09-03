import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/Track_controller.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';

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
              _buildSearchAndRadius(),
              _buildStaticMapSection(),
              _buildStatsCard(),
              _buildLiveMembersList(),
              _buildBottomShareButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                const SizedBox(height: 2),
                Text(
                  "Live location tracking",
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _iconButton(
            icon: Icons.help_outline,
            onTap: () {},
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
              color: Colors.black.withValues(alpha: 0.03),
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
              color: Colors.black.withValues(alpha: 0.02),
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
            onTap: (index) => controller.selectedTabIndex.value = index,
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
                    Icon(Icons.history, size: 15),
                    SizedBox(width: 6),
                    Text("History"),
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
              child: const TextField(
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
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

  Widget _buildStaticMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAED),
        borderRadius: BorderRadius.circular(18),
        image: const DecorationImage(
          image: NetworkImage("https://i.stack.imgur.com/HILmr.png"),
          fit: BoxFit.cover,
          opacity: 0.55,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            _buildMapAvatar(top: 36, left: 36, img: "11"),
            _buildMapAvatar(top: 50, right: 54, img: "12"),
            _buildMapAvatar(bottom: 64, left: 70, img: "5"),
            _buildMapAvatar(bottom: 46, right: 80, img: "9"),

            Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.14),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.22),
                          width: 1.5,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "You",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.45),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              right: 10,
              bottom: 56,
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
                            onPressed: () {},
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
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      icon: const Icon(Icons.my_location, size: 15),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Live badge
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people, color: primaryColor, size: 15),
                    const SizedBox(width: 6),
                    const Text(
                      "8 Members Live",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 12,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.bar_chart, color: primaryColor, size: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapAvatar({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String img,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 15,
              backgroundImage:
                  NetworkImage("https://i.pravatar.cc/150?img=$img"),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
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
          _statItem(Icons.people, "Total Members", "18", primaryColor),
          _divider(),
          _statItem(Icons.circle, "Live Now", "8", Colors.green, iconSize: 8),
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
              fontSize: 18,
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
              Text(
                "View All →",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
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
                Row(
                  children: [
                    Icon(Icons.location_on, color: primaryColor, size: 11),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        member.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: primaryColor, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${member.distance} km away",
                style: TextStyle(color: primaryColor, fontSize: 10),
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
                    color: primaryColor.withValues(alpha: 0.7),
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
}
