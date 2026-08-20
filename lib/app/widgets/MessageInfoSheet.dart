import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Core/constant/const_res.dart';
import '../Model/GetMessage.dart';
import '../Model/MemberDataRes.dart';
import '../modules/Messages/Controller/GroupChatController.dart';

class MessageInfoSheet extends StatelessWidget {
  final MessageData message;
  final GroupMessageController? groupController;
  final MemberData? memberData;

  const MessageInfoSheet({
    Key? key,
    required this.message,
    this.groupController,
    this.memberData,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isGroup = groupController != null;

    final seenMembers = isGroup
        ? _getSeenMembers()
        : <dynamic>[];

    final seenCount = _getSeenCount();

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            SizedBox(height: 14.h),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 24.sp,
                    color: Colors.blueGrey,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    "Message Info",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            Divider(
              height: 1,
              color: Colors.grey.shade300,
            ),

            // Message preview
            _buildMessagePreview(),

            Divider(
              height: 1,
              color: Colors.grey.shade300,
            ),

            // Seen
            _buildSectionTitle(
              icon: Icons.done_all,
              title: "Seen",
              count: seenCount,
            ),

            if (isGroup)
              ...seenMembers.map(
                    (member) => _buildMemberTile(member),
              )
            else
              _buildSingleSeenTile(),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  int _getSeenCount() {
    if (message.seenBy is List) {
      final uniqueIds = (message.seenBy as List)
          .map((id) => id.toString())
          .toSet();

      return uniqueIds.length;
    }

    final count = message.seenCount;

    if (count is int) {
      return count;
    }

    return int.tryParse(count?.toString() ?? "0") ?? 0;
  }

  List<dynamic> _getSeenMembers() {
    if (groupController == null) {
      return [];
    }

    if (message.seenBy is! List) {
      return [];
    }

    final seenIds = (message.seenBy as List)
        .map((id) => id.toString())
        .toSet();

    return groupController!.groupMembers.where((member) {
      return seenIds.contains(member.userId.toString());
    }).toList();
  }

  Widget _buildMessagePreview() {
    String preview;

    switch (message.messageType?.toString()) {
      case "image":
      case "image_text":
        preview = "📷 Photo";
        break;

      case "video":
        preview = "🎥 Video";
        break;

      case "audio":
        preview = "🎤 Voice message";
        break;

      case "document":
        preview = "📄 Document";
        break;

      case "location":
        preview = "📍 Location";
        break;

      case "contact":
        preview = "👤 Contact";
        break;

      default:
        preview = message.content?.toString() ?? "";
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 14.h,
      ),
      child: Row(
        children: [
          Icon(
            _getMessageIcon(),
            color: Colors.grey.shade600,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMessageIcon() {
    switch (message.messageType?.toString()) {
      case "image":
      case "image_text":
        return Icons.image_outlined;

      case "video":
        return Icons.videocam_outlined;

      case "audio":
        return Icons.mic_none;

      case "document":
        return Icons.insert_drive_file_outlined;

      case "location":
        return Icons.location_on_outlined;

      case "contact":
        return Icons.person_outline;

      default:
        return Icons.message_outlined;
    }
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required int count,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        14.h,
        20.w,
        8.h,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (count > 0) ...[
            SizedBox(width: 5.w),
            Text(
              "($count)",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberTile(dynamic member) {
    final name = member.name?.toString().trim().isNotEmpty == true
        ? member.name.toString()
        : "Unknown";

    final image = member.profileImage?.toString() ?? "";

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      leading: CircleAvatar(
        radius: 21.r,
        backgroundImage: image.isNotEmpty
            ? NetworkImage(
          "${ConstRes.aImageBaseUrl}$image",
        )
            : null,
        child: image.isEmpty
            ? Icon(
          Icons.person,
          size: 20.sp,
        )
            : null,
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        "Seen",
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.done_all,
        color: Colors.blue,
        size: 18.sp,
      ),
    );
  }

  Widget _buildSingleSeenTile() {
    final seenCount = _getSeenCount();

    if (seenCount <= 0) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 14.h,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Not seen yet",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    final name =
    memberData?.name?.toString().trim().isNotEmpty == true
        ? memberData!.name.toString()
        : "Unknown";

    final image =
        memberData?.profileImage?.toString() ?? "";

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      leading: CircleAvatar(
        radius: 21.r,
        backgroundImage: image.isNotEmpty
            ? NetworkImage(
          "${ConstRes.aImageBaseUrl}$image",
        )
            : null,
        child: image.isEmpty
            ? Icon(
          Icons.person,
          size: 20.sp,
        )
            : null,
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: const Text(
        "Seen",
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: Icon(
        Icons.done_all,
        color: Colors.blue,
        size: 18.sp,
      ),
    );
  }}