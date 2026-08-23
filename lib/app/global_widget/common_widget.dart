import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/ViewImage.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../Core/values/colors.dart';

Widget exitdialogbtn({void Function()? ontap}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: InkWell(
          onTap: ontap,
          child: Container(
            height: 30.h,
            width: 30.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkRed,
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.close,
                size: 15.sp,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget ReausableLoading() {
  return Center(
    child: SizedBox(
        height: 70.h,
        width: 70.w,
        child: const CircularProgressIndicator(
          backgroundColor: Color(0xffD0D0D0),
          color: AppColors.darkBlue,
          strokeWidth: 10,
        )),
  );
}

Widget CNetworkImage(
    {String? imageurl,
      int height = 170,
      int width = 340,
      double borderradius = 8,
      String? circlindicator}) {
  return SizedBox(
      height: height.h,
      width: width.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderradius.r),
        child: CachedNetworkImage(
          height: height.h,
          imageUrl: "$imageurl",
          fit: BoxFit.fill,
          placeholder: (context, string) => circlindicator == "no"
              ? const SizedBox()
              : const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ));
}

Widget ContainerNetworkImage(
    {String? imageurl,
      int height = 100,
      int width = 100,
      double borderradius = 8,
      String? circlindicator}) {
  return Container(
      height: height.h,
      width: width.w,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          image: DecorationImage(
              alignment: const Alignment(-.2, 0),
              image: NetworkImage(imageurl.toString()),
              fit: BoxFit.contain)));
}

Widget reausableIcon(
    {required IconData icon,
      Color? color,
      double size = 20,
      void Function()? ontap}) {
  return InkWell(
    onTap: ontap,
    child: Icon(
      icon,
      color: color,
      size: size.sp,
    ),
  );
}

Widget reausababletextfield(
    TextEditingController textctr,
    String hintname, {
      double? height,
      double? width,
      double top = 5,
      double left = 15,
      double bottom = 0,
      TextInputType? keyboardtype,
      FormFieldValidator? validators,
      Color hintcolor = Colors.black,
      int? maxline,
      bool? dense,
      double? hintfontsize,
      bool? enable,
      Color fillColor = Colors.white,
      String? otptext,
      bool? filled,
      String? postcode,
      Widget? suffix,
      void Function(String value)? onsubmitted,
      void Function(String value)? onchange,
      Color borderColor = AppColors.textbordercolor,
    }) {
  return Builder(
    builder: (context) {
      final isDarkMode = context.isDarkMode;

      return SizedBox(
        width: width,
        child: TextFormField(
          enabled: enable,
          onChanged: onchange,
          onFieldSubmitted: onsubmitted,
          controller: textctr,
          validator: validators,
          maxLines: maxline,
          keyboardType: keyboardtype,
          style: TextStyle(
            color: isDarkMode
                ? ToggleThemeData.backgroundWhite
                : Colors.black,
          ),
          decoration: InputDecoration(
            filled: filled,
            isDense: dense,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode
                    ? ToggleThemeData.backgroundWhite
                    : const Color(0xffDEDEDE),
                width: 0.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode
                    ? ToggleThemeData.backgroundWhite
                    : borderColor,
                width: 0.0,
              ),
            ),
            hintText: hintname,
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode
                    ? ToggleThemeData.backgroundWhite
                    : borderColor,
                width: 0.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode
                    ? ToggleThemeData.backgroundWhite
                    : Colors.grey,
                width: 0.0,
              ),
            ),
            suffixIcon: suffix,
            contentPadding:
            EdgeInsets.only(top: top.h, left: left.w, bottom: bottom.h),
            hintStyle: TextStyle(
              color: isDarkMode
                  ? ToggleThemeData.backgroundWhite
                  : hintcolor,
              fontSize: hintfontsize,
            ),
          ),
        ),
      );
    },
  );
}

Widget reausablebuttons(
    {void Function()? ontap,
      String? title,
      int width = 320,
      int height = 50,
      Color textcolor = Colors.white,
      double borderradiues = 30,
      List<Color>? colors,
      bool enable = true,
      int buttonfontsize = 18}) {
  colors ??= [
    AppColors.darkBlue,
    AppColors.blue,
  ];
  return GestureDetector(
    onTap: enable == false ? null : ontap,
    child: Container(
      height: height.h,
      width: width.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderradiues.r),
          gradient: enable == false
              ? LinearGradient(colors: [
            Colors.grey.shade300,
            Colors.grey.shade300,
          ])
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          )),
      child: Center(
        child: Text(
          "$title",
          style: TextStyle(
              fontSize: buttonfontsize.sp,
              fontFamily: FontFamily.interSemiBold,
              color: textcolor),
        ),
      ),
    ),
  );
}

Widget reausablebutton(
    {void Function()? ontap,
      String? title,
      double width = double.maxFinite,
      int height = 50,
      Color textcolor = Colors.white,
      double borderradiues = 10,
      bool enable = true,
      String? type,
      int fontSize = 18,
      Color backgroundColor = ToggleThemeData.darkPurple,
      IconData? icon,
      double iconSize = 20,
      Color iconColor = Colors.white}) {
  return GestureDetector(
    onTap: enable == false ? null : ontap,
    child: Container(
        height: height.h,
        width: width.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderradiues.r),
            color: backgroundColor),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon == null
                ? const SizedBox()
                : Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: reausableIcon(
                  icon: icon, size: iconSize, color: iconColor),
            ),
            Center(
              child: Text(
                "$title",
                style: TextStyle(
                    fontSize: fontSize.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: textcolor),
              ),
            ),
          ],
        )),
  );
}

Widget ReusableJobDetail(String type, var value,
    {int height = 30,
      int width = 90,
      int fontsize = 17,
      int textheight = 30,
      int textwidth = 75,
      int textfontsize = 15}) {
  return Row(
    children: [
      Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                fontSize: fontsize.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      Container(
        width: textwidth.w,
        height: textheight.h,
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.black,
              width: 0,
            ),
            top: BorderSide(
              color: Colors.black,
              width: 0,
            ),
            bottom: BorderSide(
              color: Colors.black,
              width: 0,
            ),
          ),
        ),
        child: Center(
          child: Text(
            value,
            maxLines: 2,
            style: TextStyle(
              fontSize: textfontsize.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget ReusableUpderline() {
  return const Divider(
    color: Colors.black,
  );
}

AppBar reusableAppbar(
    String title, {
      void Function()? ontap,
      Color color = AppColors.darkBlue,
      BuildContext? context,
      bool showActions = false,
    }) {
  return AppBar(
    toolbarHeight: 50.h,
    backgroundColor: ContextUtility.context!.isDarkMode
        ? ToggleThemeData.darkThemeBackground
        : color,
    scrolledUnderElevation: 0,
    leading: InkWell(
      onTap: ontap ?? () => Navigator.pop(ContextUtility.navigator!.context),
      child: Icon(
        Icons.arrow_back_ios_new,
        color: Colors.white,
        size: 20.sp,
      ),
    ),
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    elevation: 0,
    actions: [
      if (showActions == true)
        Padding(
          padding: EdgeInsets.only(right: 5.w),
          child: InkWell(
            onTap: () async {},
            child: FaIcon(
              FontAwesomeIcons.ellipsisVertical,
              color: Colors.white,
              size: 25.sp,
            ),
          ),
        )
    ],
  );
}

Widget LostinternetConnection(
    {String? showbutton, void Function()? retry, required String messgae}) {
  return Align(
    alignment: Alignment.center,
    child: Center(
        child: messgae == "An error occured please try again!"
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Assets.images.lostInternets.path),
            reausabletext("Lost Connection",
                fontsize: 24, fontfamily: FontFamily.interBold),
            SizedBox(
              height: 10.h,
            ),
            reausabletext(AppText.woopsNoInternet,
                fontsize: 15,
                color: Colors.grey,
                fontfamily: FontFamily.interMedium,
                widths: 260,
                align: TextAlign.center),
            SizedBox(
              height: 30.h,
            ),
            showbutton == "no"
                ? const SizedBox()
                : reausablebutton(
                width: 180,
                title: "Try Again",
                textcolor: Colors.white,
                ontap: retry)
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Assets.images.serverError.path),
            reausabletext(AppText.smthngWentWrong,
                fontsize: 24, fontfamily: FontFamily.interBold),
            SizedBox(
              height: 10.h,
            ),
            reausabletext(AppText.refreshThePage,
                fontsize: 15,
                color: Colors.grey,
                fontfamily: FontFamily.interMedium,
                widths: 260,
                align: TextAlign.center),
            SizedBox(
              height: 30.h,
            ),
            showbutton == "no"
                ? const SizedBox()
                : reausablebutton(
                width: 180,
                title: AppText.tryAgain,
                textcolor: Colors.white,
                ontap: retry)
          ],
        )),
  );
}

Widget ReausableAssetsIcon(
    {String? assetspath, double? height, double? width}) {
  return Align(
    alignment: Alignment.center,
    child: Image.asset(
      height: height,
      width: width,
      "$assetspath",
    ),
  );
}

Widget DataEmpty_AssetsIcon(
    {String? assetspath, double? height, double? width}) {
  return Align(
    alignment: Alignment.center,
    child: Center(
      child: Image.asset(
        height: height,
        width: width,
        "$assetspath",
      ),
    ),
  );
}

Widget DataEmpty_SvgImage({required String assetspath}) {
  return Align(
    alignment: Alignment.center,
    child: SvgPicture.asset(assetspath),
  );
}

Widget reausabletext(String title,
    {double fontsize = 20,
      Color? color,
      String fontfamily = "geographeditwebbold",
      FontWeight? fontweight,
      double? height,
      double? widths,
      TextDecoration? decoration,
      Color? backcolor,
      Color? decorationcolor,
      TextAlign? align,
      int? maxline,
      TextOverflow? textoverflow,
      var letterSpacing,
      void Function()? onTap}) {
  return InkWell(
    onTap: onTap,
    child: SizedBox(
      width: widths?.w,
      child: Text(
        textAlign: align,
        title,
        overflow: textoverflow,
        maxLines: maxline,
        style: TextStyle(
            decoration: decoration,
            backgroundColor: backcolor,
            height: height,
            fontFamily: fontfamily,
            fontSize: fontsize.sp,
            color: color,
            decorationColor: decorationcolor,
            letterSpacing: letterSpacing,
            fontWeight: fontweight),
      ),
    ),
  );
}

void FullImageView(BuildContext context, {String? title, img}) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ViewFullImage(title: title.toString(), pimgurl: img.toString()),
      ));
}

Widget BackpressIcon(BuildContext context,
    {Color color = ToggleThemeData.darkPurple}) {
  return GestureDetector(
    onTap: () async {
      Navigator.pop(context);
    },
    child: Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.w)),
      height: 40.h,
      width: 40.w,
      child: Center(
        child: Icon(
          Icons.arrow_back_outlined,
          color: color,
          size: 25.sp,
        ),
      ),
    ),
  );
}

Widget DataEmpty({String? imgname, type}) {
  return Align(
    alignment: Alignment.center,
    child: Image.asset(imgname!),
  );
}

class CustomWaveformPainter extends CustomPainter {
  final double progress;
  final List<double> samples;
  final Color activeColor;
  final Color inactiveColor;

  CustomWaveformPainter({
    required this.progress,
    required this.samples,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    final double barWidth = 3.0.w;
    final double spacing = 2.0.w;
    final int totalBars = (size.width / (barWidth + spacing)).floor();
    final double step = samples.length / totalBars;

    final Paint activePaint = Paint()
      ..color = activeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    final Paint inactivePaint = Paint()
      ..color = inactiveColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    for (int i = 0; i < totalBars; i++) {
      final int sampleIndex = (i * step).floor().clamp(0, samples.length - 1);
      final double normalizedHeight = samples[sampleIndex].clamp(0.1, 1.0);
      final double barHeight = size.height * normalizedHeight;

      final double x = i * (barWidth + spacing) + (barWidth / 2);
      final double startY = (size.height - barHeight) / 2;
      final double endY = startY + barHeight;

      final double currentProgressRatio = i / totalBars;
      final bool isPlayed = currentProgressRatio <= progress;

      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        isPlayed ? activePaint : inactivePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}

class CustomSpeedBadge extends StatelessWidget {
  final double speed;
  final VoidCallback onTap;
  final Color activeColor;
  final Color backgroundColor;

  const CustomSpeedBadge({
    super.key,
    required this.speed,
    required this.onTap,
    required this.activeColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final String label = speed == 1.0 ? '1x' : '${speed}x';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
            color: activeColor,
          ),
        ),
      ),
    );
  }
}

class WhatsAppVoicePlayerPreview extends StatefulWidget {
  final String voicePath;
  final VoidCallback onDelete;
  final VoidCallback onSend;

  const WhatsAppVoicePlayerPreview({
    super.key,
    required this.voicePath,
    required this.onDelete,
    required this.onSend,
  });

  @override
  State<WhatsAppVoicePlayerPreview> createState() =>
      _WhatsAppVoicePlayerPreviewState();
}

class _WhatsAppVoicePlayerPreviewState
    extends State<WhatsAppVoicePlayerPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool isPlaying = false;
  double progress = 0.0;
  final List<double> speeds = [1.0, 1.5, 2.0];
  int speedIndex = 0;

  final List<double> samples = const [
    0.3, 0.5, 0.8, 0.4, 0.6, 1.0, 0.5, 0.7, 0.9, 0.3,
    0.6, 0.8, 0.4, 0.7, 1.0, 0.5, 0.3, 0.8, 0.9, 0.4,
    0.6, 0.3, 0.8, 0.5, 0.4, 0.7, 0.9, 0.5, 0.3, 0.6,
    0.4, 0.8, 0.6, 0.9, 0.3, 0.5, 0.7, 0.4, 0.8, 0.6
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
      setState(() => progress = _animController.value);
      if (_animController.isCompleted) {
        setState(() {
          isPlaying = false;
          _animController.reset();
          progress = 0.0;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _animController.forward(from: progress);
      } else {
        _animController.stop();
      }
    });
  }

  void _toggleSpeed() {
    setState(() {
      speedIndex = (speedIndex + 1) % speeds.length;
      final currentSpeed = speeds[speedIndex];
      _animController.duration = Duration(
        milliseconds: (10000 / currentSpeed).round(),
      );
      if (isPlaying) {
        _animController.forward(from: progress);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const activeThemeColor = Color(0xFF075E54);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 22.sp),
            onPressed: widget.onDelete,
          ),
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: activeThemeColor,
              size: 34.sp,
            ),
            onPressed: _togglePlayPause,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) {
                    final double tapPos = details.localPosition.dx;
                    final double width = constraints.maxWidth;
                    final double newProgress = (tapPos / width).clamp(0.0, 1.0);
                    setState(() {
                      progress = newProgress;
                      _animController.value = newProgress;
                    });
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 36.h),
                    painter: CustomWaveformPainter(
                      progress: progress,
                      samples: samples,
                      activeColor: activeThemeColor,
                      inactiveColor: Colors.grey.shade300,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 8.w),
          CustomSpeedBadge(
            speed: speeds[speedIndex],
            onTap: _toggleSpeed,
            activeColor: Colors.black87,
            backgroundColor: Colors.grey.shade200,
          ),
          SizedBox(width: 4.w),
          IconButton(
            icon: Icon(Icons.send, color: activeThemeColor, size: 22.sp),
            onPressed: widget.onSend,
          ),
        ],
      ),
    );
  }
}

class VoiceMessagePlayerBubble extends StatefulWidget {
  final String audioUrl;
  final bool isSender;

  const VoiceMessagePlayerBubble({
    super.key,
    required this.audioUrl,
    required this.isSender,
  });

  @override
  State<VoiceMessagePlayerBubble> createState() =>
      _VoiceMessagePlayerBubbleState();
}

class _VoiceMessagePlayerBubbleState extends State<VoiceMessagePlayerBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool isPlaying = false;
  double progress = 0.0;
  final List<double> speeds = [1.0, 1.5, 2.0];
  int speedIndex = 0;

  final List<double> samples = const [
    0.4, 0.6, 0.9, 0.3, 0.5, 0.8, 0.4, 0.7, 1.0, 0.3,
    0.5, 0.8, 0.4, 0.6, 0.9, 0.5, 0.3, 0.7, 1.0, 0.4,
    0.6, 0.3, 0.8, 0.5, 0.4, 0.7, 0.9, 0.5, 0.3, 0.6,
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(() {
      setState(() => progress = _animController.value);
      if (_animController.isCompleted) {
        setState(() {
          isPlaying = false;
          _animController.reset();
          progress = 0.0;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _animController.forward(from: progress);
      } else {
        _animController.stop();
      }
    });
  }

  void _toggleSpeed() {
    setState(() {
      speedIndex = (speedIndex + 1) % speeds.length;
      final currentSpeed = speeds[speedIndex];
      _animController.duration = Duration(
        milliseconds: (12000 / currentSpeed).round(),
      );
      if (isPlaying) {
        _animController.forward(from: progress);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor =
    widget.isSender ? Colors.white : const Color(0xFF075E54);
    final inactiveColor = widget.isSender
        ? Colors.white.withOpacity(0.4)
        : Colors.grey.shade300;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      constraints: BoxConstraints(maxWidth: 260.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: activeColor,
              size: 34.sp,
            ),
            onPressed: _togglePlayPause,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) {
                    final double tapPos = details.localPosition.dx;
                    final double width = constraints.maxWidth;
                    final double newProgress = (tapPos / width).clamp(0.0, 1.0);
                    setState(() {
                      progress = newProgress;
                      _animController.value = newProgress;
                    });
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 34.h),
                    painter: CustomWaveformPainter(
                      progress: progress,
                      samples: samples,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 6.w),
          CustomSpeedBadge(
            speed: speeds[speedIndex],
            onTap: _toggleSpeed,
            activeColor: activeColor,
            backgroundColor: widget.isSender
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}