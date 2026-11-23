import 'dart:io';

import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/AppUpdate/Controller/UpdateCubit/update_cubit.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/themes_data.dart';

class ShorebirdAppUpdateScreen extends StatefulWidget {
  const ShorebirdAppUpdateScreen({super.key});

  @override
  State<ShorebirdAppUpdateScreen> createState() => _ShorebirdAppUpdateScreenState();
}

class _ShorebirdAppUpdateScreenState extends State<ShorebirdAppUpdateScreen> {
  final UpdateCubit cubit = UpdateCubit();
  int? currentPatch;

  @override
  void initState() {
    super.initState();
    _initUpdateCheck();
  }

  void _initUpdateCheck() async {
    final patch = await cubit.getCurrentPatchNumber();
    if (mounted) {
      setState(() {
        currentPatch = patch;
      });
    }
    cubit.updateCheck();
  }

  Future<void> _handlePop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      await CommonDialog.ConfirmationDialog(
        title: appL10n.appUpdate_exitConfirmTitle,
        cancel: appL10n.common_no,
        confirm: appL10n.common_yes,
        onConfirm: () => exit(0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handlePop();
      },
      child: BlocBuilder<UpdateCubit, UpdateState>(
        bloc: cubit,
        builder: (context, state) => Scaffold(
          backgroundColor: Colors.white,
          appBar: trackerAppBar(
            context,
            context.l10n.appUpdate_updateApp,
            onBack: _handlePop,
          ),
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
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  reausabletext(
                    context.l10n.appUpdate_updatingProgress(state.progress.toInt()),
                    fontsize: 13,
                    fontfamily: FontFamily.interSemiBold,
                  ),
                  SizedBox(height: 8.h),
                ],
                reausablebutton(
                  title: state.isRestartApp
                      ? context.l10n.appUpdate_restartApp
                      : (state.isCheckingForUpdates
                          ? "Checking..."
                          : context.l10n.appUpdate_updateApp),
                  ontap: (state.isUpdating || state.isCheckingForUpdates)
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Center(
                  child: reausabletext(
                    context.l10n.appUpdate_updateAvailable,
                    color: ToggleThemeData.Appcolor,
                    fontsize: 19,
                    fontfamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 6.h),
                Center(
                  child: reausabletext(
                    state.isRestartApp
                        ? "Update installed. Please restart to apply changes."
                        : context.l10n.appUpdate_updateAvailableMessage,
                    fontsize: 13,
                    fontfamily: FontFamily.interSemiBold,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (currentPatch != null) ...[
                  SizedBox(height: 8.h),
                  Center(
                    child: reausabletext(
                      "Current Patch: #$currentPatch",
                      fontsize: 12,
                      color: Colors.grey.shade600,
                      fontfamily: FontFamily.interMedium,
                    ),
                  ),
                ],
                SizedBox(height: 30.h),
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
