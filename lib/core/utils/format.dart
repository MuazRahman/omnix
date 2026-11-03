// 84650 -> 84,650
String formatNumber(num value) {
  final String digits = value.round().toString();
  return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}

// 84650 -> 84,650 TK
String formatTaka(num value) => '${formatNumber(value)} TK';

// 42.0 -> "42", 12.5 -> "12.5" (drops the trailing ".0" of whole numbers)
String formatQuantity(num value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toString();
}

// 84650 -> ৳ 84,650
String formatTakaSymbol(num value) => '৳ ${formatNumber(value)}';

// 20:14 -> 8:14 PM
String formatClock(DateTime time) {
  final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final String period = time.hour < 12 ? 'AM' : 'PM';
  final String minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute $period';
}

// month abbreviations used by formatShortDate
const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

// Oct 25
String formatShortDate(DateTime date) =>
    '${_monthNames[date.month - 1]} ${date.day}';

// Today / Tomorrow / Oct 25, relative to the current day
String formatDayLabel(DateTime date) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime target = DateTime(date.year, date.month, date.day);
  final int days = target.difference(today).inDays;

  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  return formatShortDate(date);
}

// "Tomorrow, 9:00 AM"
String formatSchedule(DateTime date) =>
    '${formatDayLabel(date)}, ${formatClock(date)}';
