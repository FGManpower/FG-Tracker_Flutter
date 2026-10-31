import 'package:fgtracker/app/Data/Services/NotificationServices.dart';
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
  final firebaseNotificationServices notificationServices =
  firebaseNotificationServices();
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
    // PermissionItem(
    //   title: 'Other Permissions',
    //   description:
    //       'Include only permissions confirmed as needed by actual features, with a clear explanation.',
    //   why:
    //       'Additional permissions will be requested only when required by a supported feature. Their purpose will be explained before requesting access.',
    //   icon: Icons.settings_rounded,
    // ),
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

    _checkInitialLocationAndContinue();
  }

  Future<void> _checkInitialLocationAndContinue() async {
    final locationGranted =
        await _hasAlwaysLocation() && await _location.serviceEnabled();

    if (locationGranted) {
      Get.offAllNamed(Routes.Home_Screen);
      return;
    }

    // Location pending hai, tabhi Permission Setup ke statuses load karo.
    await checkAllPermissionStatus();
  }


  Future<void> checkAllPermissionStatus() async {
    grantedItems.clear();

    // LOCATION
    final locationGranted =
        await _hasAlwaysLocation() && await _location.serviceEnabled();

    if (locationGranted) {
      grantedItems.add(0);
    }

    // CAMERA
    final camera = await Permission.camera.status;
    if (camera.isGranted || camera.isLimited) {
      grantedItems.add(1);
    }

    // MICROPHONE
    final microphone = await Permission.microphone.status;
    if (microphone.isGranted) {
      grantedItems.add(2);
    }

    // CONTACTS
    final contacts = await Permission.contacts.status;
    if (contacts.isGranted || contacts.isLimited) {
      grantedItems.add(3);
    }

    // NOTIFICATIONS
    final notification = await Permission.notification.status;
    if (notification.isGranted || notification.isLimited) {
      grantedItems.add(4);
    }

    grantedItems.refresh();
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

      // 0. LOCATION
      if (idx == 0) {
        final granted = await _requestLocation();

        if (granted) {
          _markGrantedAndAdvance(idx);
        }
        return;
      }

      // 2. MICROPHONE / AUDIO
      if (idx == 2) {
        await requestMicrophoneAudioPermission();
        return;
      }

    // 4. NOTIFICATIONS
// 4. NOTIFICATIONS
      if (idx == 4) {
        var status = await Permission.notification.status;

        // Already granted
        if (status.isGranted || status.isLimited) {
          _markGrantedAndAdvance(idx);
          return;
        }

        // Permanently denied: Open Settings
        if (status.isPermanentlyDenied || status.isRestricted) {
          await _showSettingsDialog();
          return;
        }

        // Not granted: Request native permission popup
        status = await Permission.notification.request();

        if (status.isGranted || status.isLimited) {
          _markGrantedAndAdvance(idx);
        } else if (status.isPermanentlyDenied || status.isRestricted) {
          await _showSettingsDialog();
        }

        return;
      }      // CAMERA, CONTACTS, NOTIFICATIONS
      final permission = _permissionForIndex(idx);

      if (permission == null) {
        _showMessage('Permission is not configured.');
        return;
      }

      var status = await permission.status;

      if (status.isGranted || status.isLimited) {
        _markGrantedAndAdvance(idx);
        return;
      }

      if (status.isPermanentlyDenied || status.isRestricted) {
        await _showSettingsDialog();
        return;
      }

      // Request permission
      status = await permission.request();

      if (status.isGranted || status.isLimited) {
        _markGrantedAndAdvance(idx);
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        await _showSettingsDialog();
      } else {
        _showMessage(
          '${currentItem.title} permission was not granted. Please try again.',
        );
      }
    } on PlatformException catch (e) {
      _showMessage(e.message ?? 'Unable to request permission.');
    } catch (e) {
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

  Future<void> skipAllRemaining() async {
    if (loading.value) return;

    final locationGranted =
        await _hasAlwaysLocation() && await _location.serviceEnabled();

    if (!locationGranted) {
      selectedIndex.value = 0;

      _showMessage(
        'Location permission and GPS are required to continue.',
      );

      return;
    }

    Get.offAllNamed(Routes.Home_Screen);
  }

  void _advanceSelection(int fromIndex) {
    // Location is mandatory. Always prioritize it if pending.
    if (!grantedItems.contains(0)) {
      _selectAndExpandPermission(0);
      return;
    }

    // Find next pending permission.
    for (int i = 1; i < items.length; i++) {
      if (!grantedItems.contains(i)) {
        _selectAndExpandPermission(i);
        return;
      }
    }

    // All permissions completed.
    Get.offAllNamed(Routes.Home_Screen);
  }

  void _selectAndExpandPermission(int index) {
    selectedIndex.value = index;

    expandedItems.clear();
    expandedItems.add(index);

    expandedItems.refresh();
  }


  Future<void> verifyCurrentPermission() async {
    await checkAllPermissionStatus();

    if (!grantedItems.contains(0)) {
      selectedIndex.value = 0;

      expandedItems.clear();
      expandedItems.add(0);
      expandedItems.refresh();

      return;
    }

    final nextPendingIndex = items.indexWhere(
          (item) => !grantedItems.contains(items.indexOf(item)),
    );

    if (nextPendingIndex != -1) {
      selectedIndex.value = nextPendingIndex;

      expandedItems.clear();
      expandedItems.add(nextPendingIndex);
      expandedItems.refresh();
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
    if (grantedItems.contains(idx)) {
      _advanceSelection(idx);
      return;
    }
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

  Future<void> requestMicrophoneAudioPermission() async {
    try {
      var status = await Permission.microphone.status;

      if (status.isGranted) {
        _markGrantedAndAdvance(2);
        return;
      }

      if (status.isPermanentlyDenied || status.isRestricted) {
        await _showSettingsDialog();
        return;
      }

      status = await Permission.microphone.request();

      if (status.isGranted) {
        _markGrantedAndAdvance(2);
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        await _showSettingsDialog();
      } else {
        _showMessage(
          'Microphone permission was not granted. Please try again.',
        );
      }
    } catch (e) {
      _showMessage('Unable to request Microphone permission.');
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
