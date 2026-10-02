import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/Model/status_model.dart';
import 'package:fgtracker/app/modules/status/controller/status_feed_controller.dart';
import 'package:fgtracker/app/modules/status/views/StatusViewScreen.dart';
import 'package:fgtracker/app/modules/status/views/add_status_screen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatusSection extends StatefulWidget {
  const StatusSection({super.key});

  @override
  State<StatusSection> createState() => _StatusSectionState();
}

class _StatusSectionState extends State<StatusSection> {
  final GlobalKey _myStatusKey = GlobalKey();
  OverlayEntry? _popupEntry;

  StatusFeedController get controller =>
      Get.isRegistered<StatusFeedController>()
          ? Get.find<StatusFeedController>()
          : Get.put(StatusFeedController(), permanent: true);

  @override
  void dispose() {
    _removePopup();
    super.dispose();
  }

  void _removePopup() {
    _popupEntry?.remove();
    _popupEntry = null;
  }

  void _showPrivacySheet() {
    final options = [
      {
        'label': 'All Contacts',
        'value': 'ALL_CONTACTS',
        'icon': Icons.public_rounded,
      },
      {
        'label': 'Except Contacts',
        'value': 'EXCEPT_USERS',
        'icon': Icons.person_remove_alt_1_rounded,
      },
      {
        'label': 'Only Share With',
        'value': 'ONLY_SHARE_WITH',
        'icon': Icons.lock_outline_rounded,
      },
    ];

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              reausabletext(
                'Status Privacy',
                fontsize: 16.sp,
                fontfamily: FontFamily.interBold,
                color: Colors.black87,
              ),
              SizedBox(height: 12.h),
              ...options.map((opt) {
                final label = opt['label'] as String;
                final value = opt['value'] as String;
                final icon = opt['icon'] as IconData;
                return Obx(() {
                  final selected =
                      controller.defaultPrivacyType.value == value;
                  return InkWell(
                    onTap: () {
                      controller.defaultPrivacyType.value = value;
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFE9E7FF)
                            : const Color(0xFFF7F7FB),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF6B4DFF)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            color: const Color(0xFF6B4DFF),
                            size: 22.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: reausabletext(
                              label,
                              fontsize: 14.sp,
                              fontfamily: FontFamily.interMedium,
                              color: Colors.black87,
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: const Color(0xFF6B4DFF),
                              size: 20.sp,
                            ),
                        ],
                      ),
                    ),
                  );
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showMyStatusPopup() {
    _removePopup();

    final RenderBox? box =
    _myStatusKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset pos = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    _popupEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removePopup,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: pos.dx.clamp(
                8.0,
                MediaQuery.of(context).size.width - 190.w,
              ),
              top: pos.dy + size.height - 18.h,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 175.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _popupTile(
                        icon: Icons.visibility_outlined,
                        title: 'View My Status',
                        onTap: () {
                          _removePopup();
                          if (controller.myStatuses.isEmpty) {
                            Get.to(() => const AddStatusScreen());
                            return;
                          }
                          Get.to(
                                () => StatusViewScreen(
                              isOwnStatus: true,
                              userName: 'My Status',
                              statuses: controller.myStatuses.toList(),
                              currentIndex: 0,
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.withValues(alpha: 0.15),
                        indent: 12.w,
                        endIndent: 12.w,
                      ),
                      _popupTile(
                        icon: Icons.add_circle_outline_rounded,
                        title: 'Add to My Status',
                        onTap: () {
                          _removePopup();
                          Get.to(() => const AddStatusScreen());
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.withValues(alpha: 0.15),
                        indent: 12.w,
                        endIndent: 12.w,
                      ),
                      _popupTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Status Privacy',
                        color: Colors.black87,
                        onTap: () {
                          _removePopup();
                          _showPrivacySheet();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_popupEntry!);
  }

  Widget _popupTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF6B4DFF),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: color),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interMedium,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, top: 4.h, bottom: 10.h),
          child: reausabletext(
            'Status',
            fontsize: 13.sp,
            fontfamily: FontFamily.interBold,
            color: Colors.black87,
          ),
        ),
        SizedBox(
          height: 100.h,
          child: Obx(() {
            final groups = controller.contactGroups;
            final hasMyStatus = controller.myStatuses.isNotEmpty;

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: groups.length + 1,
              separatorBuilder: (_, __) => SizedBox(width: 14.w),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final lastStatus = hasMyStatus ? controller.myStatuses.last : null;
                  final myPreviewImage = lastStatus == null
                      ? null
                      : (lastStatus.type == 'video'
                      ? lastStatus.thumbnailUrl
                      : lastStatus.mediaUrl);

                  return _statusItem(
                    key: _myStatusKey,
                    name: 'My Status',
                    subtitle: hasMyStatus ? '${controller.myStatuses.length} active' : '',
                    image: myPreviewImage,
                    borderColor: const Color(0xFF6B4DFF),
                    dotColor: null,
                    isMe: true,
                    onTap: () {
                      if (_popupEntry != null) {
                        _removePopup();
                      } else {
                        _showMyStatusPopup();
                      }
                    },
                  );
                }

                final ContactStatusGroupModel group = groups[index - 1];
                final bool isHighlighted =
                controller.highlightedUserIds.contains(group.user.id);

                return _statusItem(
                  name: group.user.name,
                  subtitle: group.isAllViewed ? 'Viewed' : 'New',
                  image: group.user.profilePic,
                  borderColor: isHighlighted
                      ? const Color(0xFF6B4DFF)
                      : group.ringColor,
                  dotColor: group.ringColor,
                  isMe: false,
                  onTap: () {
                    if (group.statuses.isEmpty) return;
                    final firstUnviewedIndex =
                    group.statuses.indexWhere((s) => !s.isViewed);
                    Get.to(
                          () => StatusViewScreen(
                        isOwnStatus: false,
                        userName: group.user.name,
                        userAvatar: group.user.profilePic,
                        statuses: group.statuses,
                        currentIndex:
                        firstUnviewedIndex >= 0 ? firstUnviewedIndex : 0,
                      ),
                    );
                  },
                );
              },
            );
          }),
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _statusItem({
    Key? key,
    required String name,
    required String subtitle,
    required String? image,
    required Color borderColor,
    required Color? dotColor,
    required bool isMe,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: SizedBox(
        width: 64.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: 2.2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 26.r,
                    backgroundColor:
                    isMe ? const Color(0xFFE9E7FF) : Colors.grey.shade300,
                    backgroundImage: (image != null && image.isNotEmpty)
                        ? NetworkImage(image)
                        : null,
                    child: (image == null || image.isEmpty)
                        ? Icon(
                      Icons.person,
                      color:
                      isMe ? const Color(0xFF6B4DFF) : Colors.white,
                      size: 26.sp,
                    )
                        : null,
                  ),
                ),
                if (isMe)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B4DFF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (!isMe && dotColor != null)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            Center(
              child: reausabletext(
                name,
                fontsize: 10.sp,
                fontfamily: FontFamily.interBold,
                color: Colors.black87,
                maxline: 1,
              ),
            ),
            if (subtitle.isNotEmpty)
              Center(
                child: reausabletext(
                  subtitle,
                  fontsize: 8.sp,
                  color: borderColor,
                  maxline: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}