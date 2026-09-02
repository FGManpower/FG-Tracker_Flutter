import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Widget callActionChip(
//     {required IconData icon, required void Function() onTap}) {
//   return InkWell(
//     onTap: onTap,
//     child: CircleAvatar(
//       radius: 20.r,
//       backgroundColor: Color(0xFF4818F0).withOpacity(0.1),
//       child: Icon(icon, size: 16.sp, color: AppColors.darkBlue),
//     ),
//   );
// }

class CallActionChip extends StatelessWidget {
  const CallActionChip({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20.r,
      backgroundColor: Color(0xFF4818F0).withOpacity(0.1),
      child: Icon(icon, size: 16.sp, color: AppColors.darkBlue),
    );
  }
}
