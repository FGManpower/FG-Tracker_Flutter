import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';
import 'package:fgtracker/app/Model/UsersWithinRadiusRes.dart';
import 'package:fgtracker/app/Model/member_live_status.dart';
import 'package:fgtracker/app/modules/Track/Controller/LocationService.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class TrackController extends GetxController {
  RxString selectedRadius = '2'.obs;
  TextEditingController customRadiusController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  RxInt selectedTabIndex = 0.obs;
  RxBool isLoading = false.obs;
  RxString responseError = "".obs;

  RxDouble currentLat = 0.0.obs;
  RxDouble currentLong = 0.0.obs;

  RxList<MemberModel> liveMembers = <MemberModel>[].obs;
  RxList<MemberModel> allFetchedMembers = <MemberModel>[].obs;
  RxList<UsersWithinRadiusData> radiusUsers = <UsersWithinRadiusData>[].obs;
  RxList<UserMemberData> onlineGroupMembers = <UserMemberData>[].obs;

  RxList<GroupsResData> groupList = <GroupsResData>[].obs;
  RxList<GroupsResData> filteredGroups = <GroupsResData>[].obs;
  RxBool isGroupLoading = false.obs;
  RxString groupError = "".obs;

  RxInt liveNowCount = 0.obs;
  RxInt totalMembersCount = 0.obs;

  @override
  void onInit() {
    super.onInit();

    fetchLiveMembers();
    fetchGroupData();
    getCurrentLocationAndFetchUsers();
  }



  Future<void> fetchGroupData() async {
    try {
      isGroupLoading.value = true;
      groupError.value = "";
      final GroupRes result = await GroupRepo.getGroupData();
      if (result.status == true && result.data?.groupData != null) {
        groupList.value = result.data!.groupData!;
        filteredGroups.value = result.data!.groupData!;
      } else {
        groupError.value = result.message ?? "Failed to load groups";
      }
    } catch (e) {
      groupError.value = e.toString();
    } finally {
      isGroupLoading.value = false;
    }
  }

  Future<void> fetchLiveMembers() async {
    try {
      final MemberLiveStatus result = await TrackRepo.getGroupMember(
        page: '0',
        filter: 'online',
      );

      if (result.status == true && result.data != null && result.data!.isNotEmpty) {
        final onlineList = result.data!
            .where((m) => m.isOnline == 1 || m.online)
            .toList();
        final listToUse = onlineList.isNotEmpty ? onlineList : result.data!;
        onlineGroupMembers.value = listToUse;
        liveNowCount.value = listToUse.length;
        if (result.pagination?.totalRecords != null) {
          totalMembersCount.value = result.pagination!.totalRecords!;
        }

        if (radiusUsers.isEmpty) {
          final mapped = listToUse.map((m) {
            String avatar = "https://i.pravatar.cc/150?img=11";
            if (m.profileImage != null && m.profileImage!.isNotEmpty) {
              avatar = m.profileImage!.startsWith("http")
                  ? m.profileImage!
                  : "${ConstRes.aImageBaseUrl}${m.profileImage}";
            }
            return MemberModel(
              name: m.name?.isNotEmpty == true
                  ? m.name!
                  : "Member ${m.userId ?? ''}",
              team: "FG Live Member",
              location:
                  m.lastSeen?.isNotEmpty == true ? m.lastSeen! : "Active now",
              distance: "0.5",
              battery: 85,
              avatarUrl: avatar,
            );
          }).toList();

          allFetchedMembers.value = mapped;
          if (searchController.text.trim().isEmpty) {
            liveMembers.value = mapped;
          } else {
            onSearch(searchController.text.trim());
          }
        }
      }
    } catch (_) {}
  }

  Future<void> getCurrentLocationAndFetchUsers() async {
    try {
      final loc = LocationService.instance.currentPosition;
      if (loc != null && loc.latitude != null && loc.longitude != null) {
        currentLat.value = loc.latitude!;
        currentLong.value = loc.longitude!;
      } else {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            Position pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
              ),
            );
            currentLat.value = pos.latitude;
            currentLong.value = pos.longitude;
          }
        }
      }
    } catch (_) {}

    await getUsersWithinRadius();
  }

  Future<void> getUsersWithinRadius() async {
    try {
      isLoading.value = true;
      responseError.value = "";

      final userId = Global.storageServices.get(PrefConst.userId);
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
      final double long = currentLong.value != 0.0 ? currentLong.value : 72.8777;

      final result = await TrackRepo.getUsersWithinRadius(
        userId: userId,
        userLat: lat,
        userLong: long,
        radius: selectedRadius.value,
      );

      if (result.status == true && result.data != null && result.data!.isNotEmpty) {
        radiusUsers.value = result.data!;
        final mappedList = result.data!.map((e) => e.toMemberModel()).toList();
        allFetchedMembers.value = mappedList;
        liveNowCount.value = mappedList.length;
        if (searchController.text.trim().isEmpty) {
          liveMembers.value = mappedList;
        } else {
          onSearch(searchController.text.trim());
        }
      } else if (onlineGroupMembers.isNotEmpty) {
        final mapped = onlineGroupMembers.map((m) {
          String avatar = "https://i.pravatar.cc/150?img=11";
          if (m.profileImage != null && m.profileImage!.isNotEmpty) {
            avatar = m.profileImage!.startsWith("http")
                ? m.profileImage!
                : "${ConstRes.aImageBaseUrl}${m.profileImage}";
          }
          return MemberModel(
            name: m.name?.isNotEmpty == true
                ? m.name!
                : "Member ${m.userId ?? ''}",
            team: "FG Live Member",
            location:
                m.lastSeen?.isNotEmpty == true ? m.lastSeen! : "Active now",
            distance: "0.5",
            battery: 85,
            avatarUrl: avatar,
          );
        }).toList();

        allFetchedMembers.value = mapped;
        if (searchController.text.trim().isEmpty) {
          liveMembers.value = mapped;
        } else {
          onSearch(searchController.text.trim());
        }
      }
    } catch (e) {
      responseError.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String value) {
    if (selectedTabIndex.value == 1) {
      if (value.isEmpty) {
        filteredGroups.value = groupList;
      } else {
        filteredGroups.value = groupList
            .where((g) =>
                (g.groupName ?? "").toLowerCase().contains(value.toLowerCase()) ||
                (g.groupDesc ?? "").toLowerCase().contains(value.toLowerCase()) ||
                (g.groupCode ?? "").toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    } else {
      if (value.isEmpty) {
        liveMembers.value = allFetchedMembers;
      } else {
        liveMembers.value = allFetchedMembers
            .where((m) =>
                m.name.toLowerCase().contains(value.toLowerCase()) ||
                m.team.toLowerCase().contains(value.toLowerCase()) ||
                m.location.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    }
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
    searchController.clear();
    if (index == 1) {
      filteredGroups.value = groupList;
      if (groupList.isEmpty) {
        fetchGroupData();
      }
    } else {
      liveMembers.value = allFetchedMembers;
    }
  }

  void updateRadius(String value) {
    selectedRadius.value = value;
    getUsersWithinRadius();
  }

  @override
  void onClose() {
    customRadiusController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
