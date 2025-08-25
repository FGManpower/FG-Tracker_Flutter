import 'dart:io';


import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/AppUpdate/Controller/UpdateCubit/update_cubit.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/themes_data.dart';


class ShorebirdAppUpdateScreen extends StatefulWidget {
  const ShorebirdAppUpdateScreen({super.key});

  @override
  State<ShorebirdAppUpdateScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ShorebirdAppUpdateScreen> {
  UpdateCubit cubit = UpdateCubit();

  Future<bool> _onWillPop() async {
    await CommonDialog.ConfirmationDialog(
      title: "Do you want to Exit?",
      cancel: "NO",
      confirm: "YES",
      onConfirm: () => exit(0),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocBuilder<UpdateCubit, UpdateState>(
        bloc: cubit,
        builder: (context, state) => Scaffold(
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isUpdating) ...[
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: LinearProgressIndicator(
                      value: state.progress / 100, // Convert 0-100 to 0.0-1.0
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  reausabletext(
                    "Updating... ${state.progress.toInt()}%",
                    fontsize: 13,
                    fontfamily: FontFamily.interSemiBold,
                  ),
                ],
                reausablebutton(
                  title: state.isRestartApp ? "Restart App" : "Update App",
                  ontap: state.isUpdating
                      ? null
                      : state.isRestartApp
                      ? cubit.restartApp
                      : cubit.updateCheck,
                ),
              ],
            ),
          ),

          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 100.h),
                Center(
                  child: reausabletext(
                    "Update Available",
                    color: ToggleThemeData.Appcolor,
                    fontsize: 19,
                    fontfamily: FontFamily.interBold,
                  ),
                ),
                Center(
                  child: reausabletext(
                    "A new update is available. Please update the app",
                    fontsize: 13,
                    fontfamily: FontFamily.interSemiBold,
                  ),
                ),
                SizedBox(height: 40.h),
                Center(child: Image.asset(Assets.images.appUpdate.path)),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
