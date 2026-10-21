import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/common/widgets/scrollable_table_body.dart';
import 'package:omnix/features/dashboard/controller/dash_board_controller.dart';
import 'package:omnix/features/dashboard/model/recent_order_model.dart';
import 'package:omnix/features/dashboard/widgets/order_status_badge_widget.dart';

// Recent orders table, the header stays pinned while the rows scroll
class RecentOrderTableWidget extends StatelessWidget {
  const RecentOrderTableWidget({super.key, required this.dashBoardController});

  final DashBoardController dashBoardController;

  // column split of the 622 wide table: 129 / 232 / 150 / 111
  static const int idFlex = 129;
  static const int itemsFlex = 232;
  static const int statusFlex = 150;
  static const int amountFlex = 111;

  // height of one header cell row and one data row
  static const double headerHeight = 39;
  static const double rowHeight = 52;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<RecentOrder> orders = dashBoardController.recentOrders;

      return Column(
        crossAxisAlignment: .stretch,
        children: [
          buildHeaderRow(),

          // body scrolls, the header above stays visible
          Expanded(
            child: orders.isEmpty
                ? const Center(
                    child: Text(
                      'No recent orders',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.tableHeaderText,
                      ),
                    ),
                  )
                : ScrollableTableBody(
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: orders.map(buildRow).toList(),
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget buildHeaderRow() {
    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.tableDivider, width: 1),
        ),
      ),
      child: Row(
        children: [
          buildHeaderCell('Order ID', flex: idFlex),
          buildHeaderCell('Ordered Items', flex: itemsFlex),
          buildHeaderCell('Status', flex: statusFlex),
          buildHeaderCell('Amount', flex: amountFlex, alignRight: true),
        ],
      ),
    );
  }

  Widget buildHeaderCell(
    String label, {
    required int flex,
    bool alignRight = false,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(
          alignment: alignRight ? .centerRight : .centerLeft,
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              height: 1.4,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(RecentOrder order) {
    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.tableDivider, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          // order id
          Expanded(
            flex: idFlex,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: .centerLeft,
                child: Text(
                  order.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.43,
                    color: AppTheme.badgeAmberText,
                  ),
                ),
              ),
            ),
          ),

          // ordered items
          Expanded(
            flex: itemsFlex,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: .centerLeft,
                child: Text(
                  order.items,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    color: AppTheme.tablePrimaryText,
                  ),
                ),
              ),
            ),
          ),

          // status pill
          Expanded(
            flex: statusFlex,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: .centerLeft,
                child: OrderStatusBadgeWidget(status: order.status),
              ),
            ),
          ),

          // amount, monospaced so the digits line up
          Expanded(
            flex: amountFlex,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: .centerRight,
                child: Text(
                  '৳${formatNumber(order.amount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontFamilyFallback: [
                      'Courier New',
                      'Menlo',
                      'DejaVu Sans Mono',
                    ],
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                    color: AppTheme.tablePrimaryText,
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
