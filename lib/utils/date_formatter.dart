import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String formatMonthYear(DateTime dateTime) {
    return DateFormat('MMMM yyyy').format(dateTime);
  }

  static String getMonthAbbr(DateTime dateTime) {
    return DateFormat('MMM').format(dateTime);
  }

  static String getDayNum(DateTime dateTime) {
    return DateFormat('d').format(dateTime);
  }
}
