import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/safe_route_controller.dart';

class SafeRouteView extends StatelessWidget {
  const SafeRouteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SafeRouteController());

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
            Text("Safe Route",
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Text("Set a safe route for your team...",
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

  Widget _buildIndividualTab(SafeRouteController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("1. Select Member",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          _buildSelectionBox("Rahul Verma"),

          SizedBox(height: 16.h),
          Text("2. Set Start & Destination",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                  child: _buildLocationInput(
                      "Start", "Chembur, Mumbai", Colors.green)),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Icon(Icons.swap_horiz)),
              Expanded(
                  child: _buildLocationInput(
                      "Destination", "Ghatkopar, Mumbai", Colors.red)),
            ],
          ),

          SizedBox(height: 16.h),
          Text("3. Select Route",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          _buildMapPlaceholder(), // Map View with Polyline Routing goes here

          SizedBox(height: 16.h),
          Text("4. Set Deviation Limit",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [250.0, 500.0, 1000.0, 2000.0, 5000.0]
                .map((val) => _buildDeviationPill(val, controller))
                .toList(),
          ),

          SizedBox(height: 24.h),
          _buildSaveButton("Save & Activate Safe Route")
        ],
      ),
    );
  }

  Widget _buildGroupTab(SafeRouteController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("1. Select Group",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          _buildSelectionBox("FG Manpower Team"),

          SizedBox(height: 16.h),
          Text("2. Set Routes for Members",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          SizedBox(
            height: 60.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Obx(() => GestureDetector(
                      onTap: () =>
                          controller.selectedGroupMemberIndex.value = index,
                      child: Container(
                        margin: EdgeInsets.only(right: 12.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color:
                              controller.selectedGroupMemberIndex.value == index
                                  ? Color(0xFFF9F8FF)
                                  : Colors.white,
                          border: Border.all(
                              color:
                                  controller.selectedGroupMemberIndex.value ==
                                          index
                                      ? Color(0xFF6B4DFF)
                                      : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 16.r,
                                backgroundColor: Colors.grey.shade300,
                                child: Icon(Icons.person,
                                    size: 16.sp, color: Colors.white)),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Member $index",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold)),
                                Text("Route A",
                                    style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Color(0xFF6B4DFF))),
                              ],
                            )
                          ],
                        ),
                      ),
                    ));
              },
            ),
          ),

          SizedBox(height: 16.h),
          Text("3. Set Start & Destination",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                  child: _buildLocationInput("Start", "Chembur", Colors.green)),
              Icon(Icons.swap_horiz),
              Expanded(
                  child: _buildLocationInput("Dest", "Ghatkopar", Colors.red)),
            ],
          ),

          SizedBox(height: 16.h),
          _buildMapPlaceholder(), // Maps

          SizedBox(height: 16.h),
          Text("4. Set Deviation Limit",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          Obx(() => Slider(
                value: controller.deviationLimit.value,
                min: 100,
                max: 5000,
                activeColor: Color(0xFF6B4DFF),
                onChanged: (val) => controller.deviationLimit.value = val,
              )),

          SizedBox(height: 24.h),
          _buildSaveButton("Save & Activate Safe Route for Group")
        ],
      ),
    );
  }

  // --- Reusable widgets ---

  Widget _buildSelectionBox(String text) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(text), Icon(Icons.keyboard_arrow_down)]),
    );
  }

  Widget _buildLocationInput(String label, String value, Color dotColor) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
          Row(
            children: [
              Icon(Icons.circle, size: 8.sp, color: dotColor),
              SizedBox(width: 4.w),
              Text(value,
                  style:
                      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ],
          )
        ],
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
          child: Text("Google Map View Here\n(Draw Polylines + Live tracking)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600))),
    );
  }

  Widget _buildDeviationPill(double value, SafeRouteController controller) {
    return Obx(() {
      bool isSelected = controller.deviationLimit.value == value;
      return GestureDetector(
        onTap: () => controller.deviationLimit.value = value,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF6B4DFF) : Colors.white,
            border: Border.all(
                color: isSelected ? Color(0xFF6B4DFF) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
              "${value >= 1000 ? '${value / 1000} km' : '${value.toInt()} m'}",
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 12.sp)),
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
