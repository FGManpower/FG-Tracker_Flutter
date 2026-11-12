import 'package:fgtracker/l10n/l10n.dart';

String formatTime(String timestamp) {
  final dateTime = DateTime.parse(timestamp).toLocal();
  return appDateFormat('hh:mm a').format(dateTime);
}

String formatDateHeader(String timestamp) {
  final dateTime = DateTime.parse(timestamp).toLocal();
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDate == today) {
    return appL10n.common_today;
  } else if (messageDate == today.subtract(Duration(days: 1))) {
    return appL10n.common_yesterday;
  } else {
    return appDateFormat('dd MMM yyyy').format(dateTime);
  }


}

String formatDuration(
    Duration duration,
    ) {
  String twoDigits(int n) =>
      n.toString().padLeft(2, '0');

  final minutes = twoDigits(
    duration.inMinutes.remainder(60),
  );

  final seconds = twoDigits(
    duration.inSeconds.remainder(60),
  );

  return "$minutes:$seconds";
}