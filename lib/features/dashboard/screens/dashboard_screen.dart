import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/custom_container_widget.dart';
import 'package:omnix/features/common/widgets/custom_widget_card.dart';
import 'package:omnix/features/common/widgets/see_all_button.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/dashboard/controller/dash_board_controller.dart';
import 'package:omnix/features/dashboard/model/today_stats_model.dart';
import 'package:omnix/features/dashboard/widgets/branch_performance_widget.dart';
import 'package:omnix/features/dashboard/widgets/day_range_button_widget.dart';
import 'package:omnix/features/dashboard/widgets/recent_order_table_widget.dart';
import 'package:omnix/features/dashboard/widgets/sales_chart_widget.dart';
import 'package:omnix/features/main_layout_shell/controller/main_layout_shell_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();
    final DashBoardController dashboardController =
        Get.find<DashBoardController>();
    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Appbar Header
            TopBarWidget(branchController: branchController),

            // Dashboard Overview, current branch name & day range selection
            buildDashboardOverViewAndDayRangeSelector(
              branchController,
              dashboardController,
            ),

            // summary card (today's sale, active order, ticket, stock)
            buildSalesOverview(dashboardController),

            // Sales velocity chart
            buildSalesVelocityChart(dashboardController),

            // Recent Orders & Branch OverView
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              // Recent Order & Branch performance
              child: Row(
                spacing: 16,
                children: [
                  // Recent Order card
                  Expanded(
                    flex: 3,
                    child: CustomContainerWidget(
                      height: 280,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: .stretch,
                          children: [
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              crossAxisAlignment: .center,
                              children: [
                                Text(
                                  'Recent Orders',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: .w600,
                                    color: AppTheme.white,
                                  ),
                                ),

                                // goes to the full orders list
                                SeeAllButton(
                                  onTap: () =>
                                      Get.find<MainLayoutShellController>()
                                          .navigateTo(
                                            MainLayoutShellController
                                                .ordersIndex,
                                          ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Recent Order Table
                            Expanded(
                              child: RecentOrderTableWidget(
                                dashBoardController: dashboardController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Branch performance card
                  Expanded(
                    flex: 2,
                    child: CustomContainerWidget(
                      // same height as the recent orders card next to it
                      height: 280,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              crossAxisAlignment: .center,
                              children: [
                                Text(
                                  'Branch Performance',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: .w600,
                                    color: AppTheme.white,
                                  ),
                                ),

                                // goes to the full branches list
                                SeeAllButton(
                                  onTap: () =>
                                      Get.find<MainLayoutShellController>()
                                          .navigateTo(
                                            MainLayoutShellController
                                                .branchesIndex,
                                          ),
                                ),
                              ],
                            ),

                            // Branch performance list
                            Expanded(
                              child: BranchPerformanceWidget(
                                dashBoardController: dashboardController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSalesVelocityChart(DashBoardController dashboardController) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 260,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadiusGeometry.circular(8),
          border: Border.all(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),

        // Main column
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Sales velocity text row
              Row(
                crossAxisAlignment: .center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        const Text(
                          'Sales Velocity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: .w400,
                            color: AppTheme.white,
                          ),
                        ),

                        Obx(
                          () => Text(
                            dashboardController.chartSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: .w400,
                              color: AppTheme.lightAmberWhite.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 11,
                    width: 11,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.amber,
                        borderRadius: BorderRadiusGeometry.circular(4),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Text(
                    'Sales',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.white,
                      fontWeight: .w300,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Sales chart
              Expanded(
                child: SalesChartWidget(
                  dashBoardController: dashboardController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSalesOverview(DashBoardController dashboardController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(() {
        final TodayStats stats = dashboardController.todayStats.value;

        return Row(
          mainAxisAlignment: .start,
          spacing: 16,
          children: [
            // today's sale card
            Expanded(
              child: CustomCardWidget(
                title: "Today's Sale",
                icon: Icons.credit_card,
                content: formatTaka(stats.sale),
                subtitle: '${stats.saleChangePercent}% vs yesterday',
              ),
            ),

            // active order
            Expanded(
              child: CustomCardWidget(
                title: "Active Order",
                icon: Icons.restaurant_menu_outlined,
                content: '${stats.activeOrders}',
                subtitle: 'Orders today',
              ),
            ),

            Expanded(
              child: CustomCardWidget(
                title: "Average Ticket",
                icon: Icons.bookmark_added,
                content: formatTaka(stats.averageTicket),
                subtitle: 'per order',
              ),
            ),

            Expanded(
              child: CustomCardWidget(
                title: "Low Stock",
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.red.shade700.withValues(alpha: 0.9),
                content: '${stats.lowStockItems}',
                subtitle: 'Items required restock',
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildDashboardOverViewAndDayRangeSelector(
    BranchController branchController,
    DashBoardController dashboardController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        children: [
          // Dashboard Overview & current branch name
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 5,
              children: [
                Text(
                  'Dashboard Overview',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: .bold,
                    color: AppTheme.white,
                  ),
                ),

                Row(
                  spacing: 8,
                  children: [
                    Text(
                      "Sultans Dine",
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.lightAmberWhite,
                        fontWeight: .w200,
                      ),
                    ),

                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.deepAmberWhite,
                        shape: BoxShape.circle,
                      ),
                    ),

                    // branch name
                    Flexible(
                      child: ValueListenableBuilder<String?>(
                        valueListenable: branchController.selectedBranch,
                        builder: (context, branch, child) => Text(
                          branch ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.lightAmberWhite,
                            fontWeight: .w200,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Day range selection (Today / 7 Days / 30 Days)
          Container(
            decoration: BoxDecoration(
              color: AppTheme.windowWidgetBackgroundBlack,
              border: Border.all(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.2),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: SizedBox(
              // fixed width so border doesn't shift on selection
              width: 250,
              child: Row(
                children: List.generate(
                  dashboardController.dayRanges.length,
                  (index) => Expanded(
                    child: DayRangeButtonWidget(
                      dashBoardController: dashboardController,
                      index: index,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
