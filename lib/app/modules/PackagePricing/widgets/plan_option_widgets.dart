import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:fgtracker/app/modules/PackagePricing/widgets/package_common_widgets.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Module icon, name, description and current subscription status
class PackageHeroCard extends StatelessWidget {
  final PackageModuleStyle style;
  final String title;
  final String? description;
  final String? iconUrl;
  final bool isSubscribed;
  final String? activeUntil;

  const PackageHeroCard({
    super.key,
    required this.style,
    required this.title,
    this.description,
    this.iconUrl,
    this.isSubscribed = false,
    this.activeUntil,
  });

  @override
  Widget build(BuildContext context) {
    final until = formatPackageDate(activeUntil);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: style.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PackageModuleIcon(style: style, iconUrl: iconUrl, size: 56.r),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: FontFamily.interExtraBold,
                    fontWeight: FontWeight.w800,
                    color: PackageUi.text,
                    letterSpacing: -0.2,
                  ),
                ),
                if (description != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontFamily: FontFamily.interRegular,
                      color: PackageUi.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                if (isSubscribed) ...[
                  SizedBox(height: 10.h),
                  PackagePill(
                    text: until != null ? 'Active till $until' : 'Active',
                    color: PackageUi.green,
                    background: PackageUi.greenBg,
                    icon: Icons.check_circle_rounded,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Basic / Pro / Enterprise switcher. Hidden by the caller when only 1 tier.
class PackageTierSelector extends StatelessWidget {
  final List<PackageTier> tiers;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const PackageTierSelector({
    super.key,
    required this.tiers,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      for (var i = 0; i < tiers.length; i++)
        _TierTile(
          tier: tiers[i],
          selected: i == selectedIndex,
          onTap: () => onSelect(i),
        ),
    ];

    // Up to 3 tiers share the width; more scroll sideways
    if (tiers.length <= 3) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) SizedBox(width: 8.w),
              Expanded(child: tiles[i]),
            ],
          ],
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) SizedBox(width: 8.w),
              SizedBox(width: 128.w, child: tiles[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _TierTile extends StatelessWidget {
  final PackageTier tier;
  final bool selected;
  final VoidCallback onTap;

  const _TierTile({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : PackageUi.text;
    final sub = selected
        ? Colors.white.withValues(alpha: 0.85)
        : PackageUi.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: '${tier.name}, ${tier.memberRangeLabel}'
          '${tier.badge != null ? ', ${tier.badge}' : ''}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? PackageUi.accent : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected ? PackageUi.accent : PackageUi.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (tier.badge != null) ...[
                Text(
                  tier.badge!.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontFamily: FontFamily.interBold,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: selected ? Colors.white : PackageUi.accent,
                  ),
                ),
                SizedBox(height: 3.h),
              ],
              Text(
                tier.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: FontFamily.interBold,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                tier.memberRangeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontFamily: FontFamily.interRegular,
                  color: sub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Monthly / Quarterly / Yearly option
class PackageDurationTile extends StatelessWidget {
  final PackageDuration duration;
  final PackageDuration? monthlyReference;
  final String currency;
  final bool perMember;
  final bool selected;
  final VoidCallback onTap;

  const PackageDurationTile({
    super.key,
    required this.duration,
    required this.monthlyReference,
    required this.currency,
    required this.perMember,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final savings = duration.savingsAgainst(monthlyReference);
    final price = formatPackageMoney(duration.pricePerMember, currency);
    final mrp = duration.mrpPerMember;
    final unit = perMember ? '/ member' : '/ ${duration.periodLabel}';
    final hint = duration.durationMonths > 1
        ? '${formatPackageMoney(duration.pricePerMemberPerMonth, currency)}'
            '${perMember ? ' / member' : ''} per month'
        : 'Billed every month';

    return Semantics(
      button: true,
      selected: selected,
      label: '${duration.displayLabel}, $price $unit'
          '${savings != null ? ', save $savings percent' : ''}. $hint',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected ? PackageUi.accent : PackageUi.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              _RadioDot(selected: selected),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          duration.displayLabel,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontFamily: FontFamily.interBold,
                            fontWeight: FontWeight.w700,
                            color: PackageUi.text,
                          ),
                        ),
                        if (savings != null)
                          PackagePill(
                            text: 'Save $savings%',
                            color: PackageUi.green,
                            background: PackageUi.greenBg,
                          ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontFamily: FontFamily.interRegular,
                        color: PackageUi.textSecondary,
                        fontFeatures: PackageUi.tabular,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (mrp != null && mrp > duration.pricePerMember)
                    Text(
                      formatPackageMoney(mrp, currency),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontFamily: FontFamily.interRegular,
                        color: PackageUi.textSecondary,
                        decoration: TextDecoration.lineThrough,
                        fontFeatures: PackageUi.tabular,
                      ),
                    ),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: FontFamily.interExtraBold,
                      fontWeight: FontWeight.w800,
                      color: PackageUi.text,
                      fontFeatures: PackageUi.tabular,
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontFamily: FontFamily.interRegular,
                      color: PackageUi.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20.r,
      height: 20.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? PackageUi.accent : PackageUi.border,
          width: selected ? 6.r : 2,
        ),
      ),
    );
  }
}

/// – count + stepper for per-member plans. Tapping the count lets the user
/// type a number (useful for big teams).
class PackageMemberPicker extends StatelessWidget {
  final int count;
  final int min;
  final int max;
  final String pricePerMemberLabel;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onEdit;

  const PackageMemberPicker({
    super.key,
    required this.count,
    required this.min,
    required this.max,
    required this.pricePerMemberLabel,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: PackageUi.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Members',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interBold,
                    fontWeight: FontWeight.w700,
                    color: PackageUi.text,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$min–$max allowed · $pricePerMemberLabel each',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                    color: PackageUi.textSecondary,
                    fontFeatures: PackageUi.tabular,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _StepButton(
            icon: Icons.remove_rounded,
            label: 'Remove one member',
            enabled: count > min,
            onTap: onDecrement,
          ),
          Semantics(
            button: true,
            label: '$count members. Tap to type a number',
            excludeSemantics: true,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                constraints: BoxConstraints(minWidth: 52.w),
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PackageUi.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: FontFamily.interExtraBold,
                    fontWeight: FontWeight.w800,
                    color: PackageUi.text,
                    fontFeatures: PackageUi.tabular,
                  ),
                ),
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            label: 'Add one member',
            enabled: count < max,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: enabled ? PackageUi.accent : PackageUi.border,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          // Still tappable at the limit so the controller can explain why
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            width: 36.r,
            height: 36.r,
            child: Icon(icon, size: 20.sp, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// ✓ included / – not included
class PackageFeatureList extends StatelessWidget {
  final List<PackageFeature> features;
  const PackageFeatureList({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: PackageUi.border),
      ),
      child: Column(
        children: [
          for (final f in features)
            Semantics(
              label: '${f.included ? 'Included' : 'Not included'}: ${f.title}'
                  '${f.subtitle != null ? '. ${f.subtitle}' : ''}',
              excludeSemantics: true,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      f.included
                          ? Icons.check_circle_rounded
                          : Icons.remove_circle_outline_rounded,
                      size: 18.sp,
                      color: f.included
                          ? PackageUi.green
                          : const Color(0xFFB4B4BE),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontFamily: f.included
                                  ? FontFamily.interMedium
                                  : FontFamily.interRegular,
                              color: f.included
                                  ? PackageUi.text
                                  : const Color(0xFF9A9AA6),
                              height: 1.35,
                            ),
                          ),
                          if (f.subtitle != null)
                            Text(
                              f.subtitle!,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontFamily: FontFamily.interRegular,
                                color: PackageUi.textSecondary,
                                height: 1.35,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Price × members, GST, total
class PackagePriceSummary extends StatelessWidget {
  final String currency;
  final num pricePerMember;
  final int members;
  final bool perMember;
  final String periodLabel;
  final num subtotal;
  final num gstPercent;
  final bool priceIncludesGst;
  final num gstAmount;
  final num total;
  final String? termsNote;

  const PackagePriceSummary({
    super.key,
    required this.currency,
    required this.pricePerMember,
    required this.members,
    required this.perMember,
    required this.periodLabel,
    required this.subtotal,
    required this.gstPercent,
    required this.priceIncludesGst,
    required this.gstAmount,
    required this.total,
    this.termsNote,
  });

  String get _gstLabel => gstPercent == gstPercent.roundToDouble()
      ? gstPercent.toInt().toString()
      : gstPercent.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final showGstRow = !priceIncludesGst && gstPercent > 0;
    final notes = [
      if (priceIncludesGst && gstPercent > 0)
        'Prices include $_gstLabel% GST.',
      if (termsNote != null) termsNote!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: PackageUi.border),
          ),
          child: Column(
            children: [
              _row(
                perMember
                    ? '${formatPackageMoney(pricePerMember, currency)} × $members ${members == 1 ? 'member' : 'members'}'
                    : 'Plan price ($periodLabel)',
                formatPackageMoney(subtotal, currency),
              ),
              if (showGstRow)
                _row('GST ($_gstLabel%)', formatPackageMoney(gstAmount, currency)),
              Container(
                margin: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
                padding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  color: PackageUi.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total for $periodLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: FontFamily.interExtraBold,
                          fontWeight: FontWeight.w800,
                          color: PackageUi.text,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      formatPackageMoney(total, currency),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: FontFamily.interExtraBold,
                        fontWeight: FontWeight.w800,
                        color: PackageUi.accent,
                        fontFeatures: PackageUi.tabular,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (notes.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            notes.join(' '),
            style: TextStyle(
              fontSize: 11.sp,
              fontFamily: FontFamily.interRegular,
              color: PackageUi.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _row(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.symmetric(vertical: 11.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PackageUi.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: FontFamily.interRegular,
                color: const Color(0xFF4A4A4A),
                fontFeatures: PackageUi.tabular,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: FontFamily.interSemiBold,
              fontWeight: FontWeight.w600,
              color: PackageUi.text,
              fontFeatures: PackageUi.tabular,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom bar: total + Buy button
class PackageBuyBar extends StatelessWidget {
  final String totalLabel;
  final String caption;
  final String buttonLabel;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  const PackageBuyBar({
    super.key,
    required this.totalLabel,
    required this.caption,
    required this.buttonLabel,
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: PackageUi.shadow, offset: Offset(0, -2), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              container: true,
              label: 'Total $totalLabel, $caption',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontFamily: FontFamily.interRegular,
                      color: PackageUi.textSecondary,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      totalLabel,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontFamily: FontFamily.interExtraBold,
                        fontWeight: FontWeight.w800,
                        color: PackageUi.text,
                        fontFeatures: PackageUi.tabular,
                      ),
                    ),
                  ),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontFamily: FontFamily.interRegular,
                      color: PackageUi.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            height: 50.h,
            child: ElevatedButton(
              onPressed: enabled ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: PackageUi.accent,
                disabledBackgroundColor:
                    PackageUi.accent.withValues(alpha: 0.5),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: loading
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonLabel,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontFamily: FontFamily.interBold,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(Icons.arrow_forward_rounded,
                            size: 18.sp, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
