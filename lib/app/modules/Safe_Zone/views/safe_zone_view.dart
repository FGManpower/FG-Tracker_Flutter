import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/safe_zone_controller.dart';

class SafeZoneView extends StatelessWidget {
  const SafeZoneView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SafeZoneController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: Colors.black, size: 16.sp),
            onPressed: () => Get.back()),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Safe Zone",
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Text("Define a safe area. Get alerts...",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
          ],
        ),
      ),
      body: Column(
        children: [
          // TabBar
          Container(
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
                color: Color(0xFFF9F8FF),
                borderRadius: BorderRadius.circular(12.r)),
            child: TabBar(
              controller: controller.tabController,
              indicator: BoxDecoration(
                  color: Color(0xFF6B4DFF),
                  borderRadius: BorderRadius.circular(12.r)),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text("Individual")
                    ])),
                Tab(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.group),
                      SizedBox(width: 8),
                      Text("Group")
                    ])),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildIndividualTab(controller),
                _buildGroupTab(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualTab(SafeZoneController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("1. Select Member",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          _buildSelectionCard(
              Obx(() => Text(controller.selectedIndividualMember.value))),

          SizedBox(height: 16.h),
          Text("2. Select Location on Map",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          _buildMapPlaceholder(), // SOCKET MAP GOES HERE

          SizedBox(height: 16.h),
          Text("3. Set Safe Zone Radius",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          Obx(() => Slider(
                value: controller.individualRadius.value,
                min: 100,
                max: 5000,
                activeColor: Color(0xFF6B4DFF),
                onChanged: (val) => controller.individualRadius.value = val,
              )),

          SizedBox(height: 16.h),
          _buildSaveButton("Save & Activate Safe Zone")
        ],
      ),
    );
  }

  Widget _buildGroupTab(SafeZoneController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("1. Select Group",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          _buildSelectionCard(Obx(() => Text(controller.selectedGroup.value))),

          SizedBox(height: 16.h),
          Text("2. Select Location on Map",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          _buildMapPlaceholder(),

          SizedBox(height: 16.h),
          Text("3. Set Safe Zone Radius",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRadiusPill(500, controller, isGroup: true),
              _buildRadiusPill(1000, controller, isGroup: true),
              _buildRadiusPill(2000, controller, isGroup: true),
              _buildRadiusPill(5000, controller, isGroup: true),
            ],
          ),

          SizedBox(height: 24.h),
          _buildSaveButton("Save & Activate Safe Zone for Group")
        ],
      ),
    );
  }

  // --- Reusable UI Widgets for this page ---

  Widget _buildSelectionCard(Widget child) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [child, Icon(Icons.keyboard_arrow_down)],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300)),
      child: Center(
        child: Text("Google Map View Here\n(Socket live tracking overlay)",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600)),
      ),
    );
  }

  Widget _buildRadiusPill(double value, SafeZoneController controller,
      {required bool isGroup}) {
    return Obx(() {
      bool isSelected = (isGroup
              ? controller.groupRadius.value
              : controller.individualRadius.value) ==
          value;
      return GestureDetector(
        onTap: () {
          if (isGroup)
            controller.groupRadius.value = value;
          else
            controller.individualRadius.value = value;
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF6B4DFF) : Colors.white,
            border: Border.all(
                color: isSelected ? Color(0xFF6B4DFF) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
              "${value >= 1000 ? '${value / 1000} km' : '${value.toInt()} m'}",
              style:
                  TextStyle(color: isSelected ? Colors.white : Colors.black)),
        ),
      );
    });
  }

  Widget _buildSaveButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6B4DFF),
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r))),
        onPressed: () {},
        child:
            Text(text, style: TextStyle(fontSize: 16.sp, color: Colors.white)),
      ),
    );
  }
}
