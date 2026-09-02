part of 'update_cubit.dart';

@immutable
class UpdateState {
  final UpdateTrack currentTrack;
  final bool isCheckingForUpdates;
  final bool isRestartApp;
  final bool updateAvailable;
  final bool isUpdating;
  final double progress; // New field for update progress

  const UpdateState({
    this.currentTrack = UpdateTrack.stable,
    this.isCheckingForUpdates = false,
    this.isRestartApp = false,
    this.updateAvailable = false,
    this.isUpdating = false,
    this.progress = 0.0, // Default to 0
  });

  UpdateState copyWith({
    UpdateTrack? currentTrack,
    bool? isCheckingForUpdates,
    bool? isRestartApp,
    bool? updateAvailable,
    bool? isUpdating,
    double? progress,
  }) {
    return UpdateState(
      currentTrack: currentTrack ?? this.currentTrack,
      isCheckingForUpdates: isCheckingForUpdates ?? this.isCheckingForUpdates,
      isRestartApp: isRestartApp ?? this.isRestartApp,
      updateAvailable: updateAvailable ?? this.updateAvailable,
      isUpdating: isUpdating ?? this.isUpdating,
      progress: progress ?? this.progress,
    );
  }
}
