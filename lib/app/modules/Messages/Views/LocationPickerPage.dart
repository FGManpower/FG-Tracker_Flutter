import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../config/themes_data.dart';
import '../Controller/location_picker_controller.dart';

class LocationPickerPage extends StatelessWidget {
  const LocationPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LocationPickerController controller =
        Get.put(LocationPickerController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ToggleThemeData.Appcolor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Share Location",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value ||
            controller.selectedLatLng.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.selectedLatLng.value!,
                zoom: 17,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
              markers: controller.markers.toSet(),
              onMapCreated: controller.onMapCreated,
              onTap: controller.updateSelectedLocation,
            ),
            Positioned(
              left: 15.w,
              right: 15.w,
              bottom: 20.h,
              child: _buildAddressCard(controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAddressCard(LocationPickerController controller) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: ToggleThemeData.Appcolor.withOpacity(.12),
                  child: Icon(
                    Icons.location_on,
                    color: ToggleThemeData.Appcolor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.selectedAddress.value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ToggleThemeData.Appcolor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: controller.sendLocation,
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text(
                        "Send Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ToggleThemeData.Appcolor,
                        side: BorderSide(color: ToggleThemeData.Appcolor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: controller.shareLocation,
                      icon: Icon(
                        Icons.share,
                        color: ToggleThemeData.Appcolor,
                      ),
                      label: Text(
                        "Share Location",
                        style: TextStyle(
                          color: ToggleThemeData.Appcolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
