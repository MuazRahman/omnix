// 84650 -> 84,650
String formatNumber(num value) {
  final String digits = value.round().toString();
  return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}

// 84650 -> 84,650 TK
String formatTaka(num value) => '${formatNumber(value)} TK';

// 84650 -> ৳ 84,650
String formatTakaSymbol(num value) => '৳ ${formatNumber(value)}';

// 20:14 -> 8:14 PM
String formatClock(DateTime time) {
  final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final String period = time.hour < 12 ? 'AM' : 'PM';
  final String minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute $period';
}
