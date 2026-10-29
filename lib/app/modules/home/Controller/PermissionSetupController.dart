import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' hide PermissionStatus;
import 'package:geolocator/geolocator.dart';

import '../../../routes/app_pages.dart';

class PermissionItem {
  final String title;
  final String description;
  final IconData icon;
  final bool required;
  final String why;

  const PermissionItem({
    required this.title,
    required this.description,
    required this.icon,
    this.required = false,
    required this.why,
  });
}

class PermissionSetupController extends GetxController
    with WidgetsBindingObserver {
  final Location _location = Location();

  final RxInt selectedIndex = 0.obs;

  final RxSet<int> expandedItems = <int>{0}.obs;

  final RxSet<int> grantedItems = <int>{}.obs;

  final RxBool loading = false.obs;

  bool _waitingForSettings = false;

  final List<PermissionItem> items = const [
    PermissionItem(
      title: 'Location',
      description:
          'Needed for real-time tracking and background location when the app is not in use.',
      why:
          'Used for the app\'s required location and background tracking functionality, including when the app is not in the foreground.',
      icon: Icons.location_on_rounded,
      required: true,
    ),
    PermissionItem(
      title: 'Camera',
      description: 'Used by the app features that capture photos or videos.',
      why:
          'Allows you to capture photos and videos for supported profile, chat and other app features.',
      icon: Icons.camera_alt_rounded,
    ),
    PermissionItem(
      title: 'Microphone / Audio',
      description:
          'Used by voice, walkie-talkie, and calling features where applicable.',
      why:
          'Allows voice communication, walkie-talkie transmission and calls when you use these features.',
      icon: Icons.mic_rounded,
    ),
    PermissionItem(
      title: 'Contacts',
      description:
          'Used to discover or select contacts for contact-related app features.',
      why:
          'Helps you find and select contacts when using supported contact-related features.',
      icon: Icons.groups_rounded,
    ),
    PermissionItem(
      title: 'Notifications',
      description:
          'Used to alert the user about relevant messages, calls, and app updates.',
      why:
          'Helps you receive relevant message alerts, call notifications and other important app updates.',
      icon: Icons.notifications_rounded,
    ),
    PermissionItem(
      title: 'Other Permissions',
      description:
          'Include only permissions confirmed as needed by actual features, with a clear explanation.',
      why:
          'Additional permissions will be requested only when required by a supported feature. Their purpose will be explained before requesting access.',
      icon: Icons.settings_rounded,
    ),
  ];

  PermissionItem get currentItem => items[selectedIndex.value];

  bool get showAllowAsPrimary {
    final idx = selectedIndex.value;
    if (grantedItems.contains(idx)) return false;
    if (items[idx].required) return true;
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForSettings) {
      _waitingForSettings = false;
      verifyCurrentPermission();
    }
  }

  void toggleExpanded(int index) {
    if (expandedItems.contains(index)) {
      expandedItems.remove(index);
    } else {
      expandedItems.add(index);
    }
    expandedItems.refresh();
  }

  void selectCard(int index) {
    selectedIndex.value = index;
  }

  Future<void> allowCurrentPermission() async {
    if (loading.value) return;

    loading.value = true;

    try {
      final idx = selectedIndex.value;

      if (idx == 0) {
        final granted = await _requestLocation();
        if (granted) {
          _markGrantedAndAdvance(idx);
        }
      } else {
        final permission = _permissionForIndex(idx);

        if (permission != null) {
          final status = await permission.status;

          if (status.isGranted) {
            _markGrantedAndAdvance(idx);
          } else if (status.isPermanentlyDenied || status.isRestricted) {
            await _showSettingsDialog();
          } else {
            final result = await permission.request();

            if (result.isGranted || result.isLimited) {
              _markGrantedAndAdvance(idx);
            } else if (result.isPermanentlyDenied || result.isRestricted) {
              await _showSettingsDialog();
            } else {
              _showMessage(
                'Permission was not granted. You can try again or skip.',
              );
            }
          }
        }
      }
    } on PlatformException catch (e) {
      _showMessage(e.message ?? 'Unable to request permission.');
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      loading.value = false;
    }
  }

  void skipCurrentPermission() {
    if (loading.value) return;
    final idx = selectedIndex.value;
    if (items[idx].required) return;
    _advanceSelection(idx);
  }

  void _markGrantedAndAdvance(int index) {
    grantedItems.add(index);
    grantedItems.refresh();
    _advanceSelection(index);
  }

  void skipAllRemaining() {
    if (loading.value) return;

    Get.offAllNamed(Routes.Home_Screen);
  }

  void _advanceSelection(int fromIndex) {
    for (int i = fromIndex + 1; i < items.length; i++) {
      if (!grantedItems.contains(i)) {
        selectedIndex.value = i;
        if (!expandedItems.contains(i)) {}
        return;
      }
    }
    Get.offAllNamed(Routes.Home_Screen);
  }

  Future<void> verifyCurrentPermission() async {
    final idx = selectedIndex.value;
    if (idx == 0) {
      final always = await _hasAlwaysLocation();
      final gps = await _location.serviceEnabled();
      if (always && gps) _markGrantedAndAdvance(idx);
    } else {
      final permission = _permissionForIndex(idx);
      if (permission != null && await permission.isGranted) {
        _markGrantedAndAdvance(idx);
      }
    }
  }

  Future<bool> _hasAlwaysLocation() async {
    if (GetPlatform.isIOS) {
      return await Geolocator.checkPermission() == LocationPermission.always;
    }

    final whenInUse = await Permission.locationWhenInUse.status;
    final always = await Permission.locationAlways.status;

    return whenInUse.isGranted && always.isGranted;
  }

  Permission? _permissionForIndex(int index) {
    switch (index) {
      case 1:
        return Permission.camera;
      case 2:
        return Permission.microphone;
      case 3:
        return Permission.contacts;
      case 4:
        return Permission.notification;
      default:
        return null;
    }
  }


  Future<bool> _requestLocation() async {
    // STEP 1: Foreground location permission
    if (GetPlatform.isAndroid) {
      var foreground = await Permission.locationWhenInUse.status;

      if (!foreground.isGranted) {
        foreground = await Permission.locationWhenInUse.request();
      }

      if (!foreground.isGranted) {
        if (foreground.isPermanentlyDenied) {
          await _showSettingsDialog();
        } else {
          _showMessage(
            'Location permission is required to continue.',
          );
        }
        return false;
      }

      // STEP 2: Background / Always location permission
      var background = await Permission.locationAlways.status;

      if (!background.isGranted) {
        background = await Permission.locationAlways.request();
      }

      if (!background.isGranted) {
        if (background.isPermanentlyDenied ||
            background.isRestricted) {
          await _showSettingsDialog();
        } else {
          _showMessage(
            'Please allow background location access to continue.',
          );
        }
        return false;
      }
    } else {
      // iOS: request permission and verify Always access.
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.always) {
        await _showSettingsDialog();
        return false;
      }
    }

    // STEP 3: Verify and enable device GPS
    bool gpsEnabled = await _location.serviceEnabled();

    if (!gpsEnabled) {
      gpsEnabled = await _location.requestService();
    }

    if (!gpsEnabled) {
      _showMessage(
        'Please enable device location/GPS to continue.',
      );
      return false;
    }

    // STEP 4: Verify both mandatory requirements again.
    final alwaysGranted = await _hasAlwaysLocation();
    final serviceEnabled = await _location.serviceEnabled();

    if (!alwaysGranted || !serviceEnabled) {
      _showMessage(
        'Always location permission and GPS are required to continue.',
      );
      return false;
    }

    return true;
  }

  Future<void> _showSettingsDialog() async {
    final context = Get.context;
    if (context == null) return;

    final idx = selectedIndex.value;
    final isRequired = items[idx].required;

    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission required'),
        content: Text(
          isRequired
              ? 'This permission is mandatory. Please enable it in app settings to continue.'
              : 'This permission can be enabled in app settings. You can also skip it for now.',
        ),
        actions: [
          if (!isRequired)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Skip'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (openSettings == true) {
      _waitingForSettings = true;
      await openAppSettings();
    } else if (openSettings == false && !isRequired) {
      _advanceSelection(idx);
    }
  }

  void _showMessage(String message) {
    final context = Get.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
