import 'package:fgtracker/l10n/l10n.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/bottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


import 'package:fgtracker/app/Core/util/app_log.dart';
class LocationPermissions {

  bool _isRequestingPermission = false;

  Future<bool> handleLocationPermission() async {

    if (_isRequestingPermission) {
      AppLog.d("Location permission request already in progress.");
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


        await CommonDialog.ConfirmationDialog(
          icon: Icons.location_on_outlined,
          cancel: appL10n.common_cancel,
          confirm: appL10n.common_settings,
          onConfirm: () async {
            Navigator.pop(ContextUtility.context!);
            await openAppSettings();
          },
          onCancel: () {
            Navigator.pop(ContextUtility.context!);
          },
          title: appL10n.perm_alwaysLocationTitle,
          content:
          appL10n.perm_alwaysLocationBody,
        );
      }

      return false;

    } catch (e) {

      AppLog.d(
        "Error while requesting location permission: $e",
      );

      return false;

    } finally {

      _isRequestingPermission = false;
    }
  }
}