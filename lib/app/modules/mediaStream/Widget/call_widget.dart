import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class CallActionChip extends StatelessWidget {
<<<<<<< HEAD
  const CallActionChip({super.key, required this.icon});
=======
   CallActionChip({required this.icon,this.onTap});
>>>>>>> dad19844ab29312734af3c86f000edf4ffa19d1e

  final IconData icon;
  void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20.r,
        backgroundColor: Color(0xFFECEAFD),
        child: Icon(icon, size: 16.sp, color: AppColors.darkBlue),
      ),
    );
  }
}
