import 'dart:convert';
import 'package:fgtracker/app/Data/Repositories/Profile_Repo.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../Model/banner_model.dart'; // Ensure model path is correct

class HomeController extends GetxController {
  RxBool ProfileData_loading = false.obs;
  var Respone_Error = "".obs;
  var isLoadingBanners = false.obs;

  var bannerList = <Data>[].obs;
  Rx<UserData> userData = UserData().obs;

  final String _baseUrl = "http://fgtracker.in:3000";

  // Possible endpoint variants to handle backend routing differences
  final List<String> _possibleEndpoints = [
    '/api/getBanners',
    '/api/v1/getBanners',
    '/api/banners',
    '/getBanners',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> getProfileData() async {
    try {
      ProfileData_loading.value = true;
      var profileData = await ProfileRepo.getProfileData();
      if (profileData.status == true) {
        userData.value = profileData.data!;
        Respone_Error.value = "";
      }
    } catch (e) {
      Respone_Error.value = e.toString();
    } finally {
      ProfileData_loading.value = false;
    }
  }

  Future<void> fetchBanners() async {
    try {
      isLoadingBanners(true);
      bool fetchedSuccessfully = false;

      for (String endpoint in _possibleEndpoints) {
        final Uri url = Uri.parse('$_baseUrl$endpoint');
        debugPrint("Trying Banner Endpoint: $url");

        try {
          final response = await http.get(url).timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            var result = json.decode(response.body);
            bannermodel model = bannermodel.fromJson(result);

            if (model.success == true && model.data != null && model.data!.isNotEmpty) {
              // Parse images and prepend domain if relative path is returned
              for (var item in model.data!) {
                if (item.imageUrl != null && !item.imageUrl!.startsWith('http')) {
                  item.imageUrl = "$_baseUrl${item.imageUrl}";
                }
              }
              bannerList.assignAll(model.data!);
              fetchedSuccessfully = true;
              debugPrint("Successfully loaded ${bannerList.length} banners from $endpoint");
              break;
            }
          }
        } catch (e) {
          debugPrint("Failed fetching from $endpoint: $e");
        }
      }

      if (!fetchedSuccessfully) {
        bannerList.clear();
      }
    } catch (e) {
      debugPrint("Error fetching banners: $e");
      bannerList.clear();
    } finally {
      isLoadingBanners(false);
    }
  }
}