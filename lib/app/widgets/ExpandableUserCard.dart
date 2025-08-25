import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpandableUserCard extends StatelessWidget {
  final Widget Function(bool isExpanded) childBuilder;
  final dynamic data;
  final bool isExpanded;
  final VoidCallback onTap;

  const ExpandableUserCard({
    Key? key,
    required this.childBuilder,
    required this.data,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCreator = data?.isCreator == true;

    return GestureDetector(
      onTap: () {
        if (!isCreator) onTap();
      },
      child: Stack(
        children: [
          childBuilder(isExpanded),
          
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue, size: 20.sp),
        ),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 10.sp)),
      ],
    );
  }


}
