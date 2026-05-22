import 'package:fgtracker/app/Core/values/BottomSheets/BottomSheetUi.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';

import '../../../routes/app_pages.dart';
import '../Widget/TrackLAppBar.dart';

class LocationTrackingPage extends StatefulWidget {
  const LocationTrackingPage({super.key});

  @override
  State<LocationTrackingPage> createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage> {
  final controller = TrackingController.instance;
  final groupController = Get.put(GroupController());

  late int groupId;
  late String groupName;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    groupId = args['groupId'];
    groupName = args['groupName'] ?? "Group";

    final String? targetUserId = args['targetUserId'];

    controller.clearMapMarkers();

    controller.loadMapStyle();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.initGroupTracking(
        groupId.toString(),
      );

      await controller.getGroupLocationData(
        context,
        groupId,
      );

      if (targetUserId != null && targetUserId.isNotEmpty) {
        int retries = 0;

        while (retries < 50) {
          await Future.delayed(
            const Duration(milliseconds: 100),
          );

          final hasMarker = controller.markers.toList().any(
                (m) => m.markerId.value == targetUserId,
              );

          if (hasMarker && controller.mapController != null) {
            break;
          }

          retries++;
        }

        controller.searchUserAndZoom(
          groupId.toString(),
          targetUserId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: buildTrackAppBar(
          context,
          groupName: groupName,
          onPressMembers: () {
            BottomSheetUi().showMemberBottomSheet(
              context,
              controller.groupWiseUserData[groupId.toString()] ?? [],
            );
          },
          onPressRefresh: () {
            controller.initGroupTracking(
              groupId.toString(),
            );

            controller.getGroupLocationData(
              context,
              groupId,
            );
          },
          onPressTheme: () {
            controller.showMapThemeBottomSheet(
              context,
            );
          },
          onSearch: () {
            Get.toNamed(
              Routes.SearchMembers,
              arguments: {
                "GroupMembers":
                    controller.groupWiseUserData[groupId.toString()],
              },
            )?.then((value) {
              if (value != null && value.toString().isNotEmpty) {
                controller.searchUserAndZoom(
                  groupId.toString(),
                  value,
                );
              }
            });
          },
        ),
        body: SafeArea(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: controller.locationService.currentPosition != null
                  ? LatLng(
                      controller.locationService.currentPosition!.latitude!,
                      controller.locationService.currentPosition!.longitude!,
                    )
                  : const LatLng(
                      19.093394,
                      72.9137016,
                    ),
              zoom: 15,
            ),
            mapType: controller.currentMapType.value,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (mapController) async {
              controller.mapController = mapController;

              if (controller.isDarkMode) {
                await mapController.setMapStyle(
                  controller.darkMapStyle,
                );
              }
            },
            markers: controller.markers.toSet(),
          ),
        ),
      ),
    );
  }
}
