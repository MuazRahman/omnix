// 84650 -> 84,650
String formatNumber(num value) {
  final String digits = value.round().toString();
  return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}

// 84650 -> 84,650 TK
String formatTaka(num value) => '${formatNumber(value)} TK';

// 84650 -> ৳ 84,650
String formatTakaSymbol(num value) => '৳ ${formatNumber(value)}';
