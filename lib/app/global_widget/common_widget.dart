import 'dart:io';

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
import 'package:table_calendar/table_calendar.dart';

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
              child: Icon(
                FontAwesomeIcons.close,
                size: 15.sp, //Icon Size
                color: AppColors.white, //Color Of Icon
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
                : Colors.black, // Text color
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
                    : const Color(0xffDEDEDE), // Border color for dark mode
                width: 0.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode
                    ? ToggleThemeData.backgroundWhite
                    : borderColor, // Enabled border color
                width: 0.0,
              ),
            ),
            hintText: hintname,
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode
                    ? ToggleThemeData.backgroundWhite
                    : borderColor, // Disabled border color
                width: 0.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode
                    ? ToggleThemeData.backgroundWhite
                    : Colors.grey, // Focused border color
                width: 0.0,
              ),
            ),
            suffixIcon: suffix,
            contentPadding:
                EdgeInsets.only(top: top.h, left: left.w, bottom: bottom.h),
            hintStyle: TextStyle(
              color: isDarkMode
                  ? ToggleThemeData.backgroundWhite
                  : hintcolor, // Hint text color
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
                ? SizedBox()
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
    // {int height = 30,
    // int width = 150,
    // int fontsize = 17,
    // int textheight = 30,
    // int textwidth = 120,
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
          // border: Border.all(color: Colors.grey),
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
      // SizedBox(width: 8,),
      Container(
        width: textwidth.w,
        height: textheight.h,
        decoration: const BoxDecoration(
          // color: Colors.grey,
          // border: Border.all(color: Colors.black),
          // borderRadius: BorderRadius.circular(0),

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
          // borderRadius: const BorderRadius.only(
          //   topLeft: Radius.circular(2.0),
          //   topRight: Radius.circular(2.0),
          // ),
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
            child: Icon(
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
            ?
            //------------------------ Internet Lost ------------------ //
            Column(
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
            //------------------------ Server Error ------------------ //
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
      // height: 220.h,
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
        // height: 220.h,
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
          // color: Colors.white,
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

class LanguageCalendarDialog extends StatefulWidget {
  final DateTime? initialSelectedDate;
  final Function(DateTime)? onDateSelected;

  const LanguageCalendarDialog({
    Key? key,
    this.initialSelectedDate,
    this.onDateSelected,
  }) : super(key: key);

  @override
  State<LanguageCalendarDialog> createState() => _LanguageCalendarDialogState();
}

class _LanguageCalendarDialogState extends State<LanguageCalendarDialog> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _currentLocale = 'en_US'; // Default to English

  // Map of language options for display
  final Map<String, String> _locales = {
    'en_US': 'English',
    'hi_IN': 'हिंदी (Hindi)', // Hindi locale
    'ur_PK': 'اردو (Urdu)', // Urdu locale
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialSelectedDate ?? _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language Selection Dropdown
            DropdownButton<String>(
              value: _currentLocale,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentLocale = newValue;
                  });
                }
              },
              items: _locales.keys.map<DropdownMenuItem<String>>((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(_locales[key]!),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),

            // Table Calendar Widget
            TableCalendar(
              locale: _currentLocale, // Set the locale dynamically
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2050, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` as well
                });
                // Optionally call a callback immediately on selection
                // widget.onDateSelected?.call(selectedDay);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16.0),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(_selectedDay); // Return selected date
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget DataEmpty({String? imgname, type}) {
  return Align(
    alignment: Alignment.center,
    child: Image.asset(imgname!),
  );
}
