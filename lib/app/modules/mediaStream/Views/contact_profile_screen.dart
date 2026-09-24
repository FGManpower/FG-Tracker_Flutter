import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ContactProfileScreen extends StatelessWidget {
  final Map<String, dynamic> contactData;

  const ContactProfileScreen({super.key, required this.contactData});

  @override
  Widget build(BuildContext context) {
    final String name = contactData['name'] ?? 'Unknown Contact';
    final String phone =
        contactData['phone'] ?? contactData['callerId'] ?? '+91 00000 00000';
    final String? avatar = contactData['avatar'];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      extendBodyBehindAppBar:
          true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.8),
                  radius: 1.2,
                  colors: [
                    const Color(0xFFE2DDFD).withOpacity(0.9),
                    const Color(0xFFF4F5FA).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  _buildProfileHeader(name, phone, avatar),
                  SizedBox(height: 24.h),
                  _buildActionButtons(),
                  SizedBox(height: 20.h),
                  _buildContactInfo(phone),
                  SizedBox(height: 20.h),
                  _buildRecentCallsStatic(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
      _buildBottomActionsCard(context, name, phone, avatar),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 65.w,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18.sp, color: const Color(0xFF4818F0)),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Icon(Icons.more_vert_rounded, color: const Color(0xFF4818F0)),
        )
      ],
    );
  }

  Widget _buildProfileHeader(String name, String phone, String? avatar) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 45.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: Utility.isNullEmptyOrFalse(avatar)
                    ? null
                    : NetworkImage(ConstRes.aImageBaseUrl + avatar!),
                child: Utility.isNullEmptyOrFalse(avatar)
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                            fontSize: 32.sp,
                            color: const Color(0xFF4818F0),
                            fontFamily: FontFamily.interBold),
                      )
                    : null,
              ),
            ),
            Container(
              width: 22.w,
              height: 22.w,
              margin: EdgeInsets.only(bottom: 4.h, right: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.w),
              ),
            )
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          name,
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: FontFamily.interBold,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          phone,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: FontFamily.interSemiBold,
            color: const Color(0xFF4818F0),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(
                    color: Color(0xFF22C55E), shape: BoxShape.circle)),
            SizedBox(width: 6.w),
            Text("Online",
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontFamily: FontFamily.interMedium)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 19.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionCard(Icons.call_rounded, "Audio Call"),
          _actionCard(Icons.videocam_rounded, "Video Call"),
          _actionCard(Icons.chat_bubble_rounded, "Message"),
        ],
      ),
    );
  }

  Widget _actionCard(IconData icon, String title) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: const Color(0xFF4818F0).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF4818F0), size: 22.sp),
            ),
            SizedBox(height: 8.h),
            Text(title,
                style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: const Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }  Widget _buildContactInfo(String phone) {
    return _cardWrapper(
      child: Column(
        children: [
          _infoTile(Icons.person_rounded, "Contact Information",
              isHeader: true),
          const Divider(color: Color(0xFFF1F1F5), height: 1),
          _infoTile(Icons.call_rounded, phone,
              subtitle: "Mobile", trailingIcon: Icons.call),
          const Divider(color: Color(0xFFF1F1F5), height: 1),
          _infoTile(Icons.location_on_rounded, "Mumbai, Maharashtra, India",
              subtitle: "Location", trailingIcon: Icons.near_me_rounded),
        ],
      ),
    );
  }

  Widget _buildRecentCallsStatic() {
    return _cardWrapper(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                _iconWrapper(Icons.access_time_rounded),
                SizedBox(width: 12.w),
                Expanded(
                    child: Text("Recent Calls",
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: FontFamily.interSemiBold,
                            color: const Color(0xFF0F172A)))),
                Text("View All",
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF4818F0),
                        fontFamily: FontFamily.interSemiBold)),
                Icon(Icons.chevron_right_rounded,
                    size: 16.sp, color: const Color(0xFF4818F0)),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1F1F5), height: 1),
          _callStaticTile(Icons.call_received_rounded, "Incoming Call",
              "Today, 11:45 AM", "02:35", const Color(0xFF22C55E)),
          const Divider(color: Color(0xFFF1F1F5), height: 1),
          _callStaticTile(Icons.call_made_rounded, "Outgoing Call",
              "Yesterday, 06:20 PM", "05:12", const Color(0xFF4818F0)),
          const Divider(color: Color(0xFFF1F1F5), height: 1),
          _callStaticTile(Icons.call_missed_rounded, "Missed Call",
              "Yesterday, 10:15 AM", "-", const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _callStaticTile(
      IconData icon, String title, String time, String duration, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: FontFamily.interSemiBold,
                        color: color == const Color(0xFFEF4444)
                            ? color
                            : Colors.black87)),
                SizedBox(height: 2.h),
                Text(time,
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                        fontFamily: FontFamily.interMedium)),
              ],
            ),
          ),
          Text(duration,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontFamily: FontFamily.interMedium)),
          SizedBox(width: 8.w),
          Icon(Icons.info_outline_rounded,
              size: 20.sp, color: const Color(0xFF4818F0)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, String name, String phone, String? avatar) {
    return Container(
      padding: EdgeInsets.only(
          top: 12.h,
          bottom: MediaQuery.of(context).padding.bottom + 12.h,
          left: 10.w,
          right: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomAction(
              Icons.star_rounded, "Add to Favorites", const Color(0xFF4818F0)),
          _bottomAction(Icons.person_add_alt_1_rounded, "Share Contact",
              const Color(0xFF4818F0)),
          _bottomAction(
              Icons.edit_rounded, "Edit Contact", const Color(0xFF4818F0),
              onTap: () {
            _showEditBottomSheet(context, name, phone, avatar);
          }),
          _bottomAction(
              Icons.block_rounded, "Block Contact", const Color(0xFFEF4444)),
        ],
      ),
    );
  }
  Widget _buildBottomActionsCard(
      BuildContext context, String name, String phone, String? avatar) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _bottomAction(
                Icons.star_rounded, "Add to Favorites", const Color(0xFF4818F0)),
          ),
          // Vertical Divider
          Container(width: 1, height: 36.h, color: const Color(0xFFE8E8EE)),
          Expanded(
            child: _bottomAction(Icons.person_add_alt_1_rounded, "Share Contact",
                const Color(0xFF4818F0)),
          ),
          // Vertical Divider
          Container(width: 1, height: 36.h, color: const Color(0xFFE8E8EE)),
          Expanded(
            child: _bottomAction(
                Icons.edit_rounded, "Edit Contact", const Color(0xFF4818F0),
                onTap: () {
                  _showEditBottomSheet(context, name, phone, avatar);
                }),
          ),
          // Vertical Divider
          Container(width: 1, height: 36.h, color: const Color(0xFFE8E8EE)),
          Expanded(
            child: _bottomAction(
                Icons.block_rounded, "Block Contact", const Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }

  Widget _bottomAction(IconData icon, String title, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 6.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontFamily: FontFamily.interMedium,
                color: color == const Color(0xFFEF4444)
                    ? color
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showEditBottomSheet(
      BuildContext context, String name, String phone, String? avatar) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r))),
            SizedBox(height: 20.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Edit Contact",
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: FontFamily.interBold,
                        color: const Color(0xFF0F172A))),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4DFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                    minimumSize: Size(80.w, 36.h),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text("Save",
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontFamily: FontFamily.interSemiBold)),
                )
              ],
            ),
            SizedBox(height: 24.h),

            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 45.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: Utility.isNullEmptyOrFalse(avatar)
                      ? null
                      : NetworkImage(ConstRes.aImageBaseUrl + avatar!),
                  child: Utility.isNullEmptyOrFalse(avatar)
                      ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                        fontSize: 30.sp,
                        color: const Color(0xFF4818F0),
                        fontFamily: FontFamily.interBold),
                  )
                      : null,
                ),
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1), blurRadius: 5)
                      ]),
                  child: Icon(Icons.camera_alt_rounded,
                      size: 16.sp, color: const Color(0xFF6B4DFF)),
                )
              ],
            ),
            SizedBox(height: 24.h),

            _bottomSheetTextField("Full Name", name, Icons.person_rounded),
            SizedBox(height: 16.h),
            _bottomSheetTextField("Mobile Number", phone, Icons.call_rounded),
            SizedBox(height: 16.h),
            _bottomSheetTextField(
                "Location", "Mumbai, Maharashtra, India", Icons.location_on_rounded,
                isDropdown: true),

            SizedBox(height: 24.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 11.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded,
                      color: const Color(0xFFEF4444), size: 20.sp),
                  SizedBox(width: 8.w),
                  Text("Delete Contact",
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: FontFamily.interSemiBold,
                          color: const Color(0xFFEF4444))),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheetTextField(String label, String value, IconData icon,
      {bool isDropdown = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
              bottom: 8.h),
          child: _iconWrapper(icon),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight(700),
                      color: Colors.grey.shade600,
                      fontFamily: FontFamily.interMedium)),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(value,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: FontFamily.interSemiBold,
                            color: const Color(0xFF0F172A))),
                    if (isDropdown)
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade600),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _cardWrapper({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _infoTile(IconData leadingIcon, String title,
      {String? subtitle, IconData? trailingIcon, bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          _iconWrapper(leadingIcon),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) ...[
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF0F172A),
                          fontFamily: FontFamily.interSemiBold)),
                  SizedBox(height: 2.h),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isHeader ? 14.sp : 13.sp,
                    fontFamily: isHeader
                        ? FontFamily.interSemiBold
                        : FontFamily.interMedium,
                    color: isHeader
                        ? const Color(0xFF0F172A)
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                  color: const Color(0xFFF4F5FA), shape: BoxShape.circle),
              child: Icon(trailingIcon,
                  size: 18.sp, color: const Color(0xFF4818F0)),
            ),
        ],
      ),
    );
  }

  Widget _iconWrapper(IconData icon) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: const Color(0xFF4818F0).withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF4818F0), size: 18.sp),
    );
  }
}
