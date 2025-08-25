import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Data/Repositories/Profile_Repo.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class HomeController extends GetxController {
  RxBool ProfileData_loading = false.obs;
  var Respone_Error = "".obs;
  Rx<UserData> userData = UserData().obs; // ✅ make it observable

  Future<void> getProfileData() async {
    try {
      ProfileData_loading.value = true;
      var profileData = await ProfileRepo.getProfileData();
      if (profileData.status == true) {
        userData.value = profileData.data!; // Assign to `.value` of Rx<UserData>
        Respone_Error.value = "";
      }
    } catch (e) {
      Respone_Error.value = e.toString();
    } finally {
      ProfileData_loading.value = false;
    }
  }

}




class BottomNavController extends GetxController with GetSingleTickerProviderStateMixin {
  final RxInt _currentTabIndex = 0.obs;
  int get currentTabIndex => _currentTabIndex.value;

  late PageController pageController;
  late TabController tabController;
  final Rx<DateTime> _selectedDate = DateTime.now().obs;
  DateTime get selectedDate => _selectedDate.value;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: _currentTabIndex.value);
    tabController = TabController(length: 3, vsync: this, initialIndex: _currentTabIndex.value);

    // Listener for PageView changes (e.g., swiping)
    pageController.addListener(() {
      if (pageController.page != null && pageController.page!.round() != _currentTabIndex.value) {
        final int newIndex = pageController.page!.round();
        _currentTabIndex.value = newIndex;
        // Sync TabController's index without triggering its listener's animateToPage immediately
        // This is important to prevent infinite loops or unwanted animations.
        if (tabController.index != newIndex) {
          tabController.index = newIndex;
        }
      }
    });

    // Listener for TabController changes (e.g., user tapping a tab)
    tabController.addListener(() {
      // This listener is primarily for keeping the PageView in sync when TabController changes
      // due to user tapping a different tab.
      if (!tabController.indexIsChanging && tabController.index != _currentTabIndex.value) {
        _currentTabIndex.value = tabController.index;
        // Animate PageView to the new page, ONLY IF we're not navigating away (Qibla tab)
        if (tabController.index != 1) { // Assuming Qibla is index 1
          pageController.animateToPage(
            tabController.index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    tabController.dispose();
    super.onClose();
  }

  // This is the core method called by CustomBottomAppBar when a tab is tapped.
  void onTabSelected(int index) {
    print('Tab selected: $index');

    // First, update the TabController's index.
    // This will handle the visual selection and potentially trigger the tabController.addListener.
    if (tabController.index != index) {
      tabController.animateTo(index, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }

    // Now, perform the specific action for the tapped tab, regardless of selection state.
    switch (index) {
      case 0: // Calendar Tab
        print('Calendar tab (index 0) action triggered.');
        showCalendarDialog();
        break;
      case 1: // Qibla Tab
        print('Qibla tab (index 1) action triggered. Navigating to QiblaScreen.');
        // Navigate to QiblaScreen.
        // The PageView will stay on the previous tab's content until return.
        Get.toNamed(Routes.QiblaScreen);
        break;
      case 2: // Audio Tab (assuming this is index 2 based on your previous code)
        print('Audio tab (index 2) action triggered.');
        // Add specific actions for Audio tab here, e.g., open an audio player UI.
        // If this tab also has a dialog or separate screen, call it here.
        // For now, let's assume it just changes the page content.
        break;
    // Removed case 3 as your tabs are 0, 1, 2 (Calendar, Qibla, Audio)
    // If you have a 4th tab, make sure length in TabController is 4 and PageView children are 4.
      default:
        print('Unknown tab selected: $index');
        break;
    }
  }

  void onPageChanged(int index) {
    // This method is called when the user swipes the PageView.
    // The `pageController.addListener` already handles syncing `_currentTabIndex` and `tabController`.
    // You can add additional print statements or analytics here if needed.
    print('Page changed (from swipe): $index');
  }

  Future<void> showCalendarDialog() async {
    final DateTime? pickedDate = await Get.dialog<DateTime>(
      LanguageCalendarDialog(
        initialSelectedDate: _selectedDate.value,
      ),
      barrierDismissible: true,
    );

    if (pickedDate != null && pickedDate != _selectedDate.value) {
      _selectedDate.value = pickedDate;
      print('Selected date: ${pickedDate.toIso8601String()}');
    }
  }
}

Widget getCustomIcon(
    String name, {
      bool isAsset = true,
      double width = 200.0,
      double height = 200.0,
      Color? color,
    }) {
  if (isAsset) {
    final imageMap = <String, String>{
      'home': 'assets/images/about_us.jpg',
      'profile': 'assets/icons/profile.png',
      'settings': 'assets/icons/settings.png',
      'search': 'assets/icons/search.png',
      'camera': 'assets/icons/camera.png',
      'chat': 'assets/icons/chat.png',
      'map': 'assets/icons/map.png',
      'music': 'assets/icons/music.png',
      'help': 'assets/icons/help.png',
    };

    final assetPath = imageMap[name] ?? 'assets/icons/help.png';

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  } else {
    final iconMap = <String, IconData>{
      'home': Icons.home,
      'profile': Icons.person,
      'settings': Icons.settings,
      'search': Icons.search,
      'camera': Icons.camera_alt,
      'chat': Icons.chat,
      'map': Icons.map,
      'music': Icons.music_note,
      'help': Icons.help_outline,
    };

    return Icon(
      iconMap[name] ?? Icons.help_outline,
      size: width,
      color: color ?? Colors.blueAccent,
    );
  }
}



final List<Map<String, dynamic>> gridItems = [
  {
    'label': 'Home',
    'name': 'home',
    'isAsset': true,
    'width': 120.0,
    'height': 80.0,
    'onTap': () => print('Home tapped'),
  },
  {
    'label': 'Profile',
    'name': 'profile',
    'isAsset': true,
    'width': 45.0,
    'height': 45.0,
    'onTap': () => print('Profile tapped'),
  },
  {
    'label': 'Settings',
    'name': 'settings',
    'isAsset': true,
    'width': 38.0,
    'height': 38.0,
    'onTap': () => print('Settings tapped'),
  },
  {
    'label': 'Search',
    'name': 'search',
    'isAsset': true,
    'width': 42.0,
    'height': 42.0,
    'onTap': () => print('Search tapped'),
  },
  {
    'label': 'Camera',
    'name': 'camera',
    'isAsset': true,
    'width': 50.0,
    'height': 45.0,
    'onTap': () => print('Camera tapped'),
  },
  {
    'label': 'Chat',
    'name': 'chat',
    'isAsset': true,
    'width': 40.0,
    'height': 40.0,
    'onTap': () => print('Chat tapped'),
  },
  {
    'label': 'Map',
    'name': 'map',
    'isAsset': true,
    'width': 44.0,
    'height': 44.0,
    'onTap': () => print('Map tapped'),
  },
  {
    'label': 'Music',
    'name': 'music',
    'isAsset': true,
    'width': 41.0,
    'height': 41.0,
    'onTap': () => print('Music tapped'),
  },
  {
    'label': 'Help',
    'name': 'help',
    'isAsset': true,
    'width': 43.0,
    'height': 43.0,
    'onTap': () => print('Help tapped'),
  },
];
