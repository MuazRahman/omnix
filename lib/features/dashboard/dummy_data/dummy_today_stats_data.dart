import 'package:omnix/features/dashboard/model/today_stats_model.dart';

// Temporary data for the summary cards.
//
// Delete this file once the backend returns real stats.
class DummyTodayStatsData {
  const DummyTodayStatsData._();

  static const TodayStats todayStats = TodayStats(
    sale: 84650,
    saleChangePercent: 12.4,
    activeOrders: 6,
    averageTicket: 525,
    lowStockItems: 4,
  );
}
