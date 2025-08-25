import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Services/MethodChannel.dart';


import 'package:meta/meta.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';


part 'update_state.dart';

class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit() : super(UpdateState());

  final ShorebirdUpdater updater = ShorebirdUpdater();

  void restartApp() async {
    if(Platform.isAndroid){
      RestartHelper().restartApplication();
    }else{
     exit(0);
    }

  }

  Future<bool> checkForUpdate() async {
    try {
      var currentTrack = UpdateTrack.stable;
      final status = await updater.checkForUpdate(track: currentTrack);

      if (status == UpdateStatus.outdated ||
          status == UpdateStatus.restartRequired) {
        emit(state.copyWith(updateAvailable: true));
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  Future<void> updateCheck() async {
    if (state.isCheckingForUpdates) return;

    try {
      emit(state.copyWith(isCheckingForUpdates: true));

      final status = await updater.checkForUpdate(track: state.currentTrack);

      switch (status) {
        case UpdateStatus.upToDate:
          Utils().fluttertoast("No Update Available");
          break;
        case UpdateStatus.outdated:
          _downloadUpdate();
          break;
        case UpdateStatus.restartRequired:
          restartApp();
          break;
        case UpdateStatus.unavailable:
          Utils().fluttertoast("Update unavailable");
          break;
      }
    } catch (error) {
      Utils().fluttertoast('Error checking for update: $error');
    } finally {
      emit(state.copyWith(isCheckingForUpdates: false));
    }
  }

  Future<void> _downloadUpdate() async {
    try {
      emit(state.copyWith(isUpdating: true, progress: 0));

      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(Duration(milliseconds: 500));
        emit(state.copyWith(progress: i.toDouble()));
      }

      await updater.update(track: state.currentTrack);

      emit(state.copyWith(isRestartApp: true, isUpdating: false));
      // Utils().fluttertoast("Update Completed. Restart Required.");
    } on UpdateException catch (error) {
      emit(state.copyWith(isUpdating: false));
      Utils().fluttertoast(error.message);
    }
  }
}
