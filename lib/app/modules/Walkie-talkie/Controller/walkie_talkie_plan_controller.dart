import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Repositories/walkie_plan_repo.dart';
import 'package:fgtracker/app/Model/walkie_plan_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_purchase_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalkieTalkiePlanController extends GetxController {
  // 0 = Individual, 1 = Team Plan
  final RxInt selectedTab = 0.obs;

  // Loading states
  final RxBool isLoadingIndividual = false.obs;
  final RxBool isLoadingGroup = false.obs;
  final RxBool isSubmitting = false.obs;

  // Plans lists from API
  final RxList<WalkiePlanItem> individualPlans = <WalkiePlanItem>[].obs;
  final RxList<WalkiePlanItem> groupPlans = <WalkiePlanItem>[].obs;

  // Selected plan indices
  final RxInt selectedIndividualPlan = 0.obs;
  final RxInt selectedTeamDuration = 0.obs; // Index in groupPlans or fallback

  // Team Plan State
  final RxInt teamMemberCount = 1.obs;
  final RxnString appliedPromoCode = RxnString();
  final RxDouble promoDiscountPercent = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBothPlans();
  }

  // Quick Getters
  bool get isTeam => selectedTab.value == 1;

  bool get isLoading =>
      isTeam ? isLoadingGroup.value : isLoadingIndividual.value;

  List<WalkiePlanItem> get currentPlans =>
      isTeam ? groupPlans : individualPlans;

  bool get hasPlans => currentPlans.isNotEmpty;

  WalkiePlanItem? get activeIndividualPlan {
    if (individualPlans.isEmpty) return null;
    final idx = selectedIndividualPlan.value.clamp(0, individualPlans.length - 1);
    return individualPlans[idx];
  }

  WalkiePlanItem? get activeGroupPlan {
    if (groupPlans.isEmpty) return null;
    final idx = selectedTeamDuration.value.clamp(0, groupPlans.length - 1);
    return groupPlans[idx];
  }

  WalkiePlanItem? get activePlan =>
      isTeam ? activeGroupPlan : activeIndividualPlan;

  String get durationName {
    if (activeGroupPlan != null) {
      return activeGroupPlan!.durationLabel;
    }
    switch (selectedTeamDuration.value) {
      case 0:
        return "Monthly";
      case 1:
        return "Quarterly";
      case 2:
        return "Yearly";
      default:
        return "Monthly";
    }
  }

  int get ratePerMember {
    if (activeGroupPlan != null) {
      return activeGroupPlan!.safePrice;
    }
    switch (selectedTeamDuration.value) {
      case 0:
        return 500;
      case 1:
        return 2400;
      case 2:
        return 4020;
      default:
        return 500;
    }
  }

  int get originalTotal => teamMemberCount.value * ratePerMember;

  // double get teamSavingsRate => 0.20; // commented out
  double get teamSavingsRate => 0.0;

  int get discountedTotal {
    int total = (originalTotal * (1 - teamSavingsRate)).round();
    if (promoDiscountPercent.value > 0) {
      total = (total * (1 - promoDiscountPercent.value)).round();
    }
    return total;
  }

  String get buttonText {
    if (isLoading) {
      return "Loading plans...";
    }
    if (!hasPlans) {
      return "No Plans Available";
    }
    if (isTeam) {
      return "Continue to Payment";
    }
    final plan = activeIndividualPlan;
    if (plan != null) {
      return "Continue with ${plan.displayTitle}";
    }
    switch (selectedIndividualPlan.value) {
      case 0:
        return "Continue with Monthly Plan";
      case 1:
        return "Continue with Quarterly Plan";
      case 2:
        return "Continue with Yearly Plan";
      default:
        return "Continue with Monthly Plan";
    }
  }

  String get planTitle {
    if (isTeam) {
      return activeGroupPlan?.displayTitle ?? "Team Plan ($durationName)";
    }
    return activeIndividualPlan?.displayTitle ?? "Individual Plan";
  }

  int get effectiveMemberCount => isTeam ? teamMemberCount.value : 1;

  // Actions
  void setTab(int tab) {
    selectedTab.value = tab;
    if (tab == 0) {
      fetchIndividualPlans();
    } else if (tab == 1) {
      fetchGroupPlans();
    }
  }

  void setIndividualPlan(int index) {
    selectedIndividualPlan.value = index;
  }

  void setTeamDuration(int index) {
    selectedTeamDuration.value = index;
  }

  void showTopWhiteMessage(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.09),
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
      ],
      messageText: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF5B4DF5),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 250),
    );
  }

  void incrementMembers() {
    final max = activeGroupPlan?.safeMaxMembers ?? 99;
    if (teamMemberCount.value < max) {
      teamMemberCount.value++;
    } else {
      showTopWhiteMessage("Maximum limit of $max members reached");
    }
  }

  void decrementMembers() {
    final min = activeGroupPlan?.safeMinMembers ?? 1;
    if (teamMemberCount.value > min) {
      teamMemberCount.value--;
    } else {
      showTopWhiteMessage("Minimum team size is $min member");
    }
  }

  void setMemberCount(int count) {
    final min = activeGroupPlan?.safeMinMembers ?? 1;
    final max = activeGroupPlan?.safeMaxMembers ?? 99;
    if (count >= min && count <= max) {
      teamMemberCount.value = count;
    }
  }

  Future<void> fetchBothPlans() async {
    await Future.wait([
      fetchIndividualPlans(),
      fetchGroupPlans(),
    ]);
  }

  Future<void> fetchIndividualPlans() async {
    try {
      isLoadingIndividual.value = true;
      final res = await WalkiePlanRepo.getPlans(planType: "individual");
      if (res.status == true && res.data?.plans != null) {
        individualPlans.assignAll(res.data!.plans!);
        if (selectedIndividualPlan.value >= individualPlans.length) {
          selectedIndividualPlan.value = 0;
        }
      }
    } catch (e) {
      debugPrint("Error fetching individual plans: $e");
    } finally {
      isLoadingIndividual.value = false;
    }
  }

  Future<void> fetchGroupPlans() async {
    try {
      isLoadingGroup.value = true;
      final res = await WalkiePlanRepo.getPlans(planType: "group");
      if (res.status == true && res.data?.plans != null) {
        groupPlans.assignAll(res.data!.plans!);
        if (selectedTeamDuration.value >= groupPlans.length) {
          selectedTeamDuration.value = 0;
        }
        if (groupPlans.isNotEmpty) {
          final first = groupPlans.first;
          final min = first.safeMinMembers;
          final max = first.safeMaxMembers;
          if (teamMemberCount.value < min) {
            teamMemberCount.value = min;
          } else if (teamMemberCount.value > max) {
            teamMemberCount.value = max;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching group plans: $e");
    } finally {
      isLoadingGroup.value = false;
    }
  }

  bool applyPromoCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      Utils().fluttertoast("Please enter a valid code");
      return false;
    }

    appliedPromoCode.value = cleanCode;
    promoDiscountPercent.value = 0.10;
    Utils().fluttertoast("Promo code $cleanCode applied!");
    return true;
  }

  void removePromoCode() {
    appliedPromoCode.value = null;
    promoDiscountPercent.value = 0.0;
  }

  String formatCurrency(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return str;
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (Match m) => '${m[1]},',
    );
    return '$formattedRest,$lastThree';
  }

  String getValidTillDate([int? duration]) {
    int months = 1;
    final plan = activePlan;
    if (plan?.durationMonths != null && plan!.durationMonths! > 0) {
      months = plan.durationMonths!;
    } else if (duration != null) {
      months = duration == 0 ? 1 : (duration == 1 ? 3 : 12);
    }

    final now = DateTime.now();
    final expiryDate = DateTime(now.year, now.month + months, now.day);
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${expiryDate.day} ${monthNames[expiryDate.month - 1]} ${expiryDate.year}";
  }

  void openPurchaseSuccessScreen() {
    if (!hasPlans || isLoading) return;
    Get.to(() => WalkieTalkiePurchaseSuccessScreen(
          isTeam: isTeam,
          planTitle: planTitle,
          memberCount: effectiveMemberCount,
          validTill: getValidTillDate(),
        ));
  }
}

// Aliases for flexible naming
typedef WalkiePlanController = WalkieTalkiePlanController;
typedef walkie_talkie_plan_controller = WalkieTalkiePlanController;
