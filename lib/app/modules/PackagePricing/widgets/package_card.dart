import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:fgtracker/app/modules/PackagePricing/widgets/package_common_widgets.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One module on the Packages & Pricing screen
class PackageCard extends StatelessWidget {
  final PackageItem item;
  final VoidCallback? onTap;

  const PackageCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final style =
        PackageModuleStyle.of(item.moduleKey, hexColor: item.themeColor);
    final price = item.startingPrice;
    final activeUntil = formatPackageDate(item.activeUntil);

    final semanticsLabel = [
      item.title,
      if (item.tagline != null) item.tagline!,
      if (!item.isAvailable)
        'Coming soon'
      else if (price != null)
        'Starts at ${formatPackageMoney(price, item.currency)} ${item.priceUnit ?? ''}',
      if (item.isSubscribed)
        activeUntil != null ? 'Active until $activeUntil' : 'Active',
    ].join('. ');

    return Semantics(
      button: true,
      enabled: item.isAvailable,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Opacity(
        opacity: item.isAvailable ? 1 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: PackageUi.border),
            boxShadow: PackageUi.cardShadow,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18.r),
              child: Padding(
                padding: EdgeInsets.all(14.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PackageModuleIcon(
                            style: style, iconUrl: item.iconUrl, size: 48.r),
                        SizedBox(width: 12.w),
                        Expanded(child: _titleBlock(style)),
                        SizedBox(width: 4.w),
                        Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Icon(Icons.chevron_right_rounded,
                              size: 22.sp, color: style.color),
                        ),
                      ],
                    ),
                    if (item.highlights.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: item.highlights
                            .take(3)
                            .map((h) => PackagePill(
                                  text: h,
                                  color: PackageUi.text,
                                  background: PackageUi.bg,
                                ))
                            .toList(),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    const Divider(height: 1, color: PackageUi.divider),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(child: _priceLine(price)),
                        if (item.isSubscribed) ...[
                          SizedBox(width: 8.w),
                          PackagePill(
                            text: activeUntil != null
                                ? 'Active · till $activeUntil'
                                : 'Active',
                            color: PackageUi.green,
                            background: PackageUi.greenBg,
                            icon: Icons.check_circle_rounded,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleBlock(PackageModuleStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontFamily: FontFamily.interBold,
                  fontWeight: FontWeight.w700,
                  color: PackageUi.text,
                ),
              ),
            ),
            if (item.badge != null) ...[
              SizedBox(width: 6.w),
              PackagePill(text: item.badge!, color: style.color),
            ],
          ],
        ),
        if (item.tagline != null) ...[
          SizedBox(height: 3.h),
          Text(
            item.tagline!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: FontFamily.interRegular,
              color: PackageUi.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }

  Widget _priceLine(num? price) {
    if (!item.isAvailable) {
      return Text(
        'Coming soon',
        style: TextStyle(
          fontSize: 13.sp,
          fontFamily: FontFamily.interSemiBold,
          fontWeight: FontWeight.w600,
          color: PackageUi.textSecondary,
        ),
      );
    }
    if (price == null) {
      return Text(
        'View plans',
        style: TextStyle(
          fontSize: 13.sp,
          fontFamily: FontFamily.interSemiBold,
          fontWeight: FontWeight.w600,
          color: PackageUi.accent,
        ),
      );
    }
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 11.5.sp,
          fontFamily: FontFamily.interRegular,
          color: PackageUi.textSecondary,
        ),
        children: [
          const TextSpan(text: 'Starts at  '),
          TextSpan(
            text: formatPackageMoney(price, item.currency),
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: FontFamily.interExtraBold,
              fontWeight: FontWeight.w800,
              color: PackageUi.text,
              fontFeatures: PackageUi.tabular,
            ),
          ),
          if (item.priceUnit != null) TextSpan(text: ' ${item.priceUnit}'),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
