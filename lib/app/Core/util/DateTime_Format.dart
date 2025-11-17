import 'package:intl/intl.dart';

String formatTime(String timestamp) {
  final dateTime = DateTime.parse(timestamp).toLocal();
  return DateFormat('hh:mm a').format(dateTime);
}

String formatDateHeader(String timestamp) {
  final dateTime = DateTime.parse(timestamp).toLocal();
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDate == today) {
    return "Today";
  } else if (messageDate == today.subtract(Duration(days: 1))) {
    return "Yesterday";
  } else {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }
}