import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/bottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


class LocationPermissions {

  bool _isRequestingPermission = false;

  Future<bool> handleLocationPermission() async {

    if (_isRequestingPermission) {
      debugPrint("Location permission request already in progress.");
      return false;
    }

    _isRequestingPermission = true;

    try {

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.whileInUse) {

        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always) {
        return true;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {

        ModalImage(
          onImageSelect: (v) {},
          isImageCroppable: false,
        ).locationPermissionBottomSheet(
          ContextUtility.context!,
        );

        // await CommonDialog.ConfirmationDialog(
        //   icon: Icons.location_on_outlined,
        //   cancel: "Cancel",
        //   confirm: "Settings",
        //   onConfirm: () async {
        //     Navigator.pop(ContextUtility.context!);
        //     await openAppSettings();
        //   },
        //   onCancel: () {
        //     Navigator.pop(ContextUtility.context!);
        //   },
        //   title: "Enable 'Always' Location Permission",
        //   content:
        //   "To track your group in real time and in background, please set Location access to 'Allow all the time' in App Settings.",
        // );
      }

      return false;

    } catch (e) {

      debugPrint(
        "Error while requesting location permission: $e",
      );

      return false;

    } finally {

      _isRequestingPermission = false;
    }
  }
}