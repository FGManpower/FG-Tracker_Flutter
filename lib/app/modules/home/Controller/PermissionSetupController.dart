import 'package:fgtracker/app/Data/Services/NotificationServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  // ORDER: 0 Location, 1 Notifications, 2 Camera, 3 Microphone, 4 Contacts
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
      title: 'Notifications',
      description:
      'Used to alert the user about relevant messages, calls, and app updates.',
      why:
      'Helps you receive relevant message alerts, call notifications and other important app updates.',
      icon: Icons.notifications_rounded,
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
    checkAllPermissionStatus();
  }

  Future<void> _checkInitialLocationAndContinue() async {
    final locationGranted =
        await _hasAlwaysLocation() && await _location.serviceEnabled();

    if (locationGranted) {
      Get.offAllNamed(Routes.Home_Screen);
      return;
    }

    await checkAllPermissionStatus();
  }


  Future<void> checkAllPermissionStatus() async {
    grantedItems.clear();

    final locationGranted =
        await _hasAlwaysLocation() && await _location.serviceEnabled();

    if (locationGranted) {
      grantedItems.add(0);
    }

    final notification = await Permission.notification.status;
    if (notification.isGranted || notification.isLimited) {
      grantedItems.add(1);
    }

    final camera = await Permission.camera.status;
    if (camera.isGranted || camera.isLimited) {
      grantedItems.add(2);
    }

    final microphone = await Permission.microphone.status;
    if (microphone.isGranted) {
      grantedItems.add(3);
    }

    final contacts = await Permission.contacts.status;
    if (contacts.isGranted || contacts.isLimited) {
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

      if (idx == 0) {
        final granted = await _requestLocation();

        if (granted) {
          _markGrantedAndAdvance(idx);
        }
        return;
      }

      if (idx == 3) {
        await requestMicrophoneAudioPermission();
        return;
      }

      if (idx == 1) {
        var status = await Permission.notification.status;

        if (status.isGranted || status.isLimited) {
          _markGrantedAndAdvance(idx);
          return;
        }

        if (status.isPermanentlyDenied || status.isRestricted) {
          await _showSettingsDialog();
          return;
        }

        status = await Permission.notification.request();

        if (status.isGranted || status.isLimited) {
          _markGrantedAndAdvance(idx);
        } else if (status.isPermanentlyDenied || status.isRestricted) {
          await _showSettingsDialog();
        }

        return;
      }

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
    if (!grantedItems.contains(0)) {
      _selectAndExpandPermission(0);
      return;
    }

    for (int i = 1; i < items.length; i++) {
      if (!grantedItems.contains(i)) {
        _selectAndExpandPermission(i);
        return;
      }
    }

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
        return Permission.notification;
      case 2:
        return Permission.camera;
      case 3:
        return Permission.microphone;
      case 4:
        return Permission.contacts;
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
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.always) {
        await _showSettingsDialog();
        return false;
      }
    }

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

  String _settingsMessage(int idx) {
    switch (idx) {
      case 0:
        return 'Location permission ("Allow all the time") and GPS are needed for tracking. Please enable it from app settings.';
      case 1:
        return 'Notification permission is needed to alert you about messages, calls and updates. Please enable it from app settings.';
      case 2:
        return 'Camera permission is needed to capture photos and videos. Please enable it from app settings.';
      case 3:
        return 'Microphone permission is needed for voice, walkie-talkie and calls. Please enable it from app settings.';
      case 4:
        return 'Contacts permission is needed to find and select contacts. Please enable it from app settings.';
      default:
        return 'This permission is needed. Please enable it from app settings.';
    }
  }

  Future<void> _showSettingsDialog() async {
    final context = Get.context;
    if (context == null) return;

    final idx = selectedIndex.value;
    if (grantedItems.contains(idx)) {
      _advanceSelection(idx);
      return;
    }
    final item = items[idx];
    final isRequired = item.required;

    const Color brand = Color(0xFF6C5DD3);
    const Color navy = Color(0xFF11145A);
    const Color grey = Color(0xFF686B9D);

    final openSettings = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brand.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: brand,
                    ),
                    child: Icon(
                      item.icon,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Permission Required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                _settingsMessage(idx),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  height: 1.45,
                  color: grey,
                ),
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46.h,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(ctx, isRequired ? null : false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: brand,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          side: BorderSide(
                            color: brand.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Cancel',
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brand,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Open Settings',
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
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
        _markGrantedAndAdvance(3);
        return;
      }

      if (status.isPermanentlyDenied || status.isRestricted) {
        await _showSettingsDialog();
        return;
      }

      status = await Permission.microphone.request();

      if (status.isGranted) {
        _markGrantedAndAdvance(3);
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