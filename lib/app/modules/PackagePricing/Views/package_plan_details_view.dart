import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:fgtracker/app/modules/PackagePricing/Controller/package_plan_details_controller.dart';
import 'package:fgtracker/app/modules/PackagePricing/widgets/package_common_widgets.dart';
import 'package:fgtracker/app/modules/PackagePricing/widgets/plan_option_widgets.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Pricing details for one module: tier → duration → members → Buy.
class PackagePlanDetailsView extends GetView<PackagePlanDetailsController> {
  const PackagePlanDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PackageUi.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: PackageUi.maxContentWidth),
            child: Obx(() {
              final hasPlans = controller.details.value != null;
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
                    child: PackageHeader(
                      title: controller.title,
                      subtitle: 'Plans & pricing',
                      onBack: () => Get.back(),
                    ),
                  ),
                  Expanded(child: _content()),
                  if (hasPlans) _buyBar(),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  PackageModuleStyle get _style => PackageModuleStyle.of(
        controller.moduleKey,
        hexColor: controller.package.value?.themeColor,
      );

  Widget _content() {
    if (controller.isLoading.value && controller.details.value == null) {
      return _skeleton();
    }
    final details = controller.details.value;
    if (details == null) {
      return PackageStatusView(
        message: controller.errorMessage.value.isNotEmpty
            ? controller.errorMessage.value
            : 'No plans are available for this package right now.',
        onRetry: () => controller.fetchPlans(),
      );
    }

    final tier = controller.tier;
    final durations = controller.durations;
    final features = controller.features;
    final duration = controller.duration;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PackageHeroCard(
            style: _style,
            title: details.title,
            description: controller.description,
            iconUrl: controller.package.value?.iconUrl,
            isSubscribed: controller.isSubscribed,
            activeUntil: controller.package.value?.activeUntil,
          ),
          SizedBox(height: 22.h),

          // Tier
          if (controller.tiers.length > 1) ...[
            const PackageSectionTitle('Choose a plan'),
            PackageTierSelector(
              tiers: controller.tiers,
              selectedIndex: controller.selectedTier.value,
              onSelect: controller.selectTier,
            ),
            if (tier?.description != null) ...[
              SizedBox(height: 8.h),
              Text(
                tier!.description!,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interRegular,
                  color: PackageUi.textSecondary,
                ),
              ),
            ],
            SizedBox(height: 22.h),
          ],

          // Duration
          const PackageSectionTitle('Billing period'),
          for (var i = 0; i < durations.length; i++)
            PackageDurationTile(
              duration: durations[i],
              monthlyReference: tier?.monthlyReference,
              currency: controller.currency,
              perMember: controller.showMemberPicker,
              selected: i == controller.selectedDuration.value,
              onTap: () => controller.selectDuration(i),
            ),
          SizedBox(height: 12.h),

          // Members
          if (controller.showMemberPicker && tier != null) ...[
            const PackageSectionTitle('Team size'),
            PackageMemberPicker(
              count: controller.members.value,
              min: tier.minMembers,
              max: tier.maxMembers,
              pricePerMemberLabel: formatPackageMoney(
                  duration?.pricePerMember ?? 0, controller.currency),
              onIncrement: controller.incrementMembers,
              onDecrement: controller.decrementMembers,
              onEdit: _editMembers,
            ),
            SizedBox(height: 22.h),
          ],

          // Features
          if (features.isNotEmpty) ...[
            PackageSectionTitle("What's included", trailing: tier?.name),
            PackageFeatureList(features: features),
            SizedBox(height: 22.h),
          ],

          // Summary
          if (duration != null) ...[
            const PackageSectionTitle('Price summary'),
            PackagePriceSummary(
              currency: controller.currency,
              pricePerMember: duration.pricePerMember,
              members: controller.members.value,
              perMember: controller.showMemberPicker,
              periodLabel: duration.periodLabel,
              subtotal: controller.subtotal,
              gstPercent: controller.gstPercent,
              priceIncludesGst: controller.priceIncludesGst,
              gstAmount: controller.gstAmount,
              total: controller.total,
              termsNote: details.termsNote,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buyBar() {
    final duration = controller.duration;
    final members = controller.members.value;
    final caption = [
      if (controller.showMemberPicker)
        '$members ${members == 1 ? 'member' : 'members'}',
      if (duration != null) duration.periodLabel,
      if (controller.tier != null) controller.tier!.name,
    ].join(' · ');

    return PackageBuyBar(
      totalLabel: formatPackageMoney(controller.total, controller.currency),
      caption: caption,
      buttonLabel: controller.buyLabel,
      loading: controller.isPaying.value,
      enabled: controller.canBuy,
      onPressed: controller.onBuy,
    );
  }

  void _editMembers() {
    if (controller.tier == null) return;
    Get.dialog(_MemberInputDialog(controller: controller));
  }

  Widget _skeleton() {
    const sample = [
      PackageDuration(planId: 1, durationMonths: 1, pricePerMember: 99),
      PackageDuration(planId: 2, durationMonths: 3, pricePerMember: 270),
      PackageDuration(planId: 3, durationMonths: 12, pricePerMember: 990),
    ];
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PackageHeroCard(
              style: _style,
              title: controller.title,
              description: 'Loading the plans available for this package',
            ),
            SizedBox(height: 22.h),
            const PackageSectionTitle('Billing period'),
            for (final d in sample)
              PackageDurationTile(
                duration: d,
                monthlyReference: null,
                currency: 'INR',
                perMember: true,
                selected: false,
                onTap: () {},
              ),
            SizedBox(height: 12.h),
            const PackageFeatureList(features: [
              PackageFeature(title: 'Feature included in this plan'),
              PackageFeature(title: 'Another feature in this plan'),
              PackageFeature(title: 'One more feature here'),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Lets the user type a team size instead of tapping + many times
class _MemberInputDialog extends StatefulWidget {
  final PackagePlanDetailsController controller;
  const _MemberInputDialog({required this.controller});

  @override
  State<_MemberInputDialog> createState() => _MemberInputDialogState();
}

class _MemberInputDialogState extends State<_MemberInputDialog> {
  late final TextEditingController _text;
  String? _error;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(
        text: widget.controller.members.value.toString());
    _text.selection =
        TextSelection(baseOffset: 0, extentOffset: _text.text.length);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _apply() {
    final error = widget.controller.setMembers(int.tryParse(_text.text.trim()));
    if (error == null) {
      Get.back();
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = widget.controller.tier;
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      title: Text(
        'Number of members',
        style: TextStyle(
          fontSize: 16.sp,
          fontFamily: FontFamily.interBold,
          fontWeight: FontWeight.w700,
          color: PackageUi.text,
        ),
      ),
      content: TextField(
        controller: _text,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(5),
        ],
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _apply(),
        cursorColor: PackageUi.accent,
        style: TextStyle(
          fontSize: 15.sp,
          fontFamily: FontFamily.interSemiBold,
          color: PackageUi.text,
        ),
        decoration: InputDecoration(
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontFamily: FontFamily.interRegular,
            color: PackageUi.textSecondary,
          ),
          errorStyle: TextStyle(
            fontSize: 11.5.sp,
            fontFamily: FontFamily.interMedium,
          ),
          hintText: tier != null
              ? '${tier.minMembers}–${tier.maxMembers}'
              : null,
          errorText: _error,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: PackageUi.accent, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: FontFamily.interMedium,
                color: PackageUi.textSecondary,
              )),
        ),
        TextButton(
          onPressed: _apply,
          child: Text('Apply',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: FontFamily.interBold,
                fontWeight: FontWeight.w700,
                color: PackageUi.accent,
              )),
        ),
      ],
    );
  }
}
