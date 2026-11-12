import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/blend_mask.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalkieHeroSection extends StatelessWidget {
  const WalkieHeroSection({super.key});

  static const Color textColor = AppColors.authTextNavy;
  static const Color subtitleColor = AppColors.primarySecondaryElementText;

  double _sp(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return size;
    return size.sp.clamp(size * 0.85, size * 1.25);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: BlendMask(
            blendMode: BlendMode.multiply,
            child: Assets.walkieTalkie.walkieTrialHero.image(
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              reausabletext(
                context.l10n.walkie_heroTitle,
                fontsize: _sp(context, 17.5),
                fontfamily: FontFamily.interBold,
                color: textColor,
                align: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              Text(
                context.l10n.walkie_heroSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _sp(context, 11.5),
                  color: subtitleColor,
                  fontFamily: FontFamily.interRegular,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
