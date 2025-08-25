
import 'package:bloc/bloc.dart';
import 'package:fgtracker/app/Core/util/http/Constant.dart';
import 'package:fgtracker/app/Core/values/global.dart';

import 'package:meta/meta.dart';

part 'notification_count_state.dart';

class NotificationCountCubit extends Cubit<NotificationCountState> {
  NotificationCountCubit() : super(NotificationCountLoading());

  showBadge() async {
    final bool showBadge =
        await Global.storageServices.getBool(Constant.notificationBadge);
    emit(NotificationCountLoaded(showBadge: showBadge));
  }
}
