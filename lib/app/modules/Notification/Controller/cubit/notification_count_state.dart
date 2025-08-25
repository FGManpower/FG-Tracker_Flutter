part of 'notification_count_cubit.dart';

@immutable
 class NotificationCountState {}


class NotificationCountLoading extends NotificationCountState {
}
class NotificationCountLoaded extends NotificationCountState {
   bool showBadge;
  NotificationCountLoaded({
    required this.showBadge,
  });

}