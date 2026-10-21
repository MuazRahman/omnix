// One bar in the sales chart (an hour today, or a day in a range)
class SalesBucket {
  const SalesBucket({required this.label, required this.sales});

  final String label;
  final double sales;
}
