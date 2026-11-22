import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Services/MethodChannel.dart';
import 'package:fgtracker/l10n/l10n.dart';

import 'package:meta/meta.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

part 'update_state.dart';

class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit() : super(UpdateState());

  final ShorebirdUpdater updater = ShorebirdUpdater();

  bool get isShorebirdAvailable => updater.isAvailable;

  void restartApp() async {
    if (Platform.isAndroid) {
      RestartHelper().restartApplication();
    } else {
      exit(0);
    }
  }

  Future<int?> getCurrentPatchNumber() async {
    try {
      final patch = await updater.readCurrentPatch();
      return patch?.number;
    } catch (_) {
      return null;
    }
  }

  Future<bool> checkForUpdate() async {
    try {
      if (!updater.isAvailable) {
        return false;
      }
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

      if (!updater.isAvailable) {
        Utils().fluttertoast(appL10n.appUpdate_updateUnavailable);
        return;
      }

      final status = await updater.checkForUpdate(track: state.currentTrack);

      switch (status) {
        case UpdateStatus.upToDate:
          Utils().fluttertoast(appL10n.appUpdate_noUpdateAvailable);
          break;
        case UpdateStatus.outdated:
          _downloadUpdate();
          break;
        case UpdateStatus.restartRequired:
          emit(state.copyWith(isRestartApp: true));
          restartApp();
          break;
        case UpdateStatus.unavailable:
          Utils().fluttertoast(appL10n.appUpdate_updateUnavailable);
          break;
      }
    } catch (error) {
      Utils().fluttertoast(appL10n.appUpdate_checkError(error.toString()));
    } finally {
      emit(state.copyWith(isCheckingForUpdates: false));
    }
  }

  Future<void> _downloadUpdate() async {
    Timer? progressTimer;
    try {
      emit(state.copyWith(isUpdating: true, progress: 0));

      // Shorebird downloads the patch asynchronously; animate smoothly up to 90%
      // until updater.update() finishes, then jump to 100%.
      progressTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
        if (state.progress < 90) {
          emit(state.copyWith(progress: state.progress + 5));
        }
      });

      await updater.update(track: state.currentTrack);

      progressTimer.cancel();
      emit(state.copyWith(progress: 100, isRestartApp: true, isUpdating: false));
      Utils().fluttertoast(appL10n.appUpdate_restartApp);
    } on UpdateException catch (error) {
      progressTimer?.cancel();
      emit(state.copyWith(isUpdating: false));
      Utils().fluttertoast(error.message);
    } catch (e) {
      progressTimer?.cancel();
      emit(state.copyWith(isUpdating: false));
      Utils().fluttertoast(e.toString());
    }
  }
}
