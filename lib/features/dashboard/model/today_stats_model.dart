// Live numbers for today, shown on the summary cards
class TodayStats {
  const TodayStats({
    required this.sale,
    required this.saleChangePercent,
    required this.activeOrders,
    required this.averageTicket,
    required this.lowStockItems,
  });

  final double sale;
  final double saleChangePercent;
  final int activeOrders;
  final double averageTicket;
  final int lowStockItems;
}
