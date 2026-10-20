import 'package:get/get.dart';
import 'package:omnix/features/dashboard/dummy_data/dummy_branch_performance_data.dart';
import 'package:omnix/features/dashboard/dummy_data/dummy_order_table_data.dart';
import 'package:omnix/features/dashboard/dummy_data/dummy_sales_data.dart';
import 'package:omnix/features/dashboard/dummy_data/dummy_today_stats_data.dart';
import 'package:omnix/features/dashboard/model/branch_performance_model.dart';
import 'package:omnix/features/dashboard/model/recent_order_model.dart';
import 'package:omnix/features/dashboard/model/sales_bucket_model.dart';
import 'package:omnix/features/dashboard/model/today_stats_model.dart';

class DashBoardController extends GetxController {
  final dayRanges = const ['Today', '7 Days', '30 Days'];

  // how many rows the recent orders table shows
  static const int recentOrdersLimit = 5;

  // how many branches the branch performance card shows, the top sellers
  static const int branchPerformanceLimit = 3;

  final selectedDayRange = 0.obs;

  final salesBuckets = <SalesBucket>[].obs;

  final recentOrders = <RecentOrder>[].obs;

  final branchPerformance = <BranchPerformance>[].obs;

  final isLoadingSales = false.obs;

  // summary cards always show today, the day range only drives the chart
  final todayStats = const TodayStats(
    sale: 0,
    saleChangePercent: 0,
    activeOrders: 0,
    averageTicket: 0,
    lowStockItems: 0,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchSales();
    fetchTodayStats();
    fetchRecentOrders();
    fetchBranchPerformance();
  }

  void dayRangeOnChanged(int index) {
    selectedDayRange.value = index;
    fetchSales();
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchSales() async {
    isLoadingSales.value = true;

    // bucket count per range: today = 16 hours, 7 days = 7, 30 days = 30
    switch (selectedDayRange.value) {
      case 1:
        salesBuckets.assignAll(DummySalesData.days(7));
      case 2:
        salesBuckets.assignAll(DummySalesData.days(30));
      default:
        salesBuckets.assignAll(DummySalesData.hours);
    }

    isLoadingSales.value = false;
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchTodayStats() async {
    todayStats.value = DummyTodayStatsData.todayStats;
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchRecentOrders() async {
    // swap this for the API call, the shape stays the same
    // final response = await api.get('/orders/recent?limit=$recentOrdersLimit');
    // recentOrders.assignAll(
    //   (response as List)
    //       .map((e) => RecentOrder.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    // the api returns the newest orders first, only the latest ones are shown
    recentOrders.assignAll(
      DummyOrderTableData.recentOrders.take(recentOrdersLimit).toList(),
    );
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchBranchPerformance() async {
    // swap this for the API call, the shape stays the same
    // final response =
    //     await api.get('/branches/performance?limit=$branchPerformanceLimit&sort=sale:desc');
    // branchPerformance.assignAll(
    //   (response as List)
    //       .map((e) => BranchPerformance.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    // only the top selling branches are shown, sorted by sale
    final List<BranchPerformance> branches =
        List<BranchPerformance>.from(
          DummyBranchPerformanceData.branchPerformance,
        )..sort(
          (BranchPerformance a, BranchPerformance b) =>
              b.sale.compareTo(a.sale),
        );

    branchPerformance.assignAll(branches.take(branchPerformanceLimit).toList());
  }

  double get maxSale {
    if (salesBuckets.isEmpty) return 0;
    return salesBuckets.map((e) => e.sales).reduce((a, b) => a > b ? a : b);
  }

  // caption under the chart title
  String get chartSubtitle {
    switch (selectedDayRange.value) {
      case 1:
        return 'Daily sales, last 7 days';
      case 2:
        return 'Daily sales, last 30 days';
      default:
        return 'Hourly sales, 8 AM to 11 PM';
    }
  }
}
