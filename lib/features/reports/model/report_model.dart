// One row of a report, a metric with its value and change
class ReportEntry {
  const ReportEntry({
    required this.label,
    required this.value,
    required this.changePercent,
    required this.icon,
  });

  final String label;
  final String value;
  final double changePercent;
  final String icon;
}

/// One line of the top selling items report
class TopSellingItem {
  const TopSellingItem({
    required this.name,
    required this.quantitySold,
    required this.revenue,
  });

  final String name;
  final int quantitySold;
  final int revenue;
}
