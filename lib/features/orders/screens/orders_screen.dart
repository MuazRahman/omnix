import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/custom_container_widget.dart';
import 'package:omnix/features/common/widgets/data_table_widget.dart';
import 'package:omnix/features/common/widgets/section_header_widget.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/orders/controller/order_controller.dart';
import 'package:omnix/features/orders/model/order_model.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();
    final OrderController orderController = Get.find<OrderController>();

    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,
      body: Column(
        children: [
          // Appbar Header
          TopBarWidget(branchController: branchController),

          // Title, search and totals
          Obx(
            () => SectionHeaderWidget(
              title: 'Orders',
              subtitle:
                  '${orderController.filteredCount} orders · ${formatTaka(orderController.filteredTotal)}',
              searchHint: 'Search by id, customer or item',
              onSearchChanged: orderController.searchOnChanged,
              actionLabel: 'New Order',
              actionIcon: Icons.add,
              onAction: () {},
            ),
          ),

          // Status filter
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 8,
                children: List.generate(
                  orderController.statusFilters.length,
                  (int index) => _FilterChip(
                    label: orderController.statusFilters[index],
                    isSelected: orderController.selectedStatus.value == index,
                    onTap: () => orderController.statusFilterOnChanged(index),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Order table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomContainerWidget(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Obx(() {
                    final List<Order> orders = orderController.filteredOrders;

                    return DataTableWidget(
                      columns: const [
                        DataTableColumn(
                          label: 'Order ID',
                          flex: 129,
                          monospace: true,
                        ),
                        DataTableColumn(label: 'Customer', flex: 150),
                        DataTableColumn(label: 'Items', flex: 232),
                        DataTableColumn(label: 'Status', flex: 130),
                        DataTableColumn(label: 'Time', flex: 100),
                        DataTableColumn(
                          label: 'Amount',
                          flex: 111,
                          alignRight: true,
                          monospace: true,
                        ),
                      ],
                      rows: orders
                          .map(
                            (Order order) =>
                                DataTableRow(cells: buildCells(order)),
                          )
                          .toList(),
                      emptyMessage: 'No orders match the filter',
                    );
                  }),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> buildCells(Order order) {
    return [
      DataTableWidget.text(
        order.id,
        color: AppTheme.badgeAmberText,
        weight: FontWeight.w600,
        monospace: true,
      ),
      DataTableWidget.text(order.customer, weight: FontWeight.w600),
      DataTableWidget.text(order.items, weight: FontWeight.w500),
      StatusPillWidget(
        label: _statusLabel(order.status),
        tone: _statusTone(order.status),
      ),
      DataTableWidget.text(order.placedAt, color: AppTheme.tableHeaderText),
      DataTableWidget.text(
        '৳${formatNumber(order.amount)}',
        weight: FontWeight.w700,
        monospace: true,
      ),
    ];
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  PillTone _statusTone(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.preparing:
        return PillTone.amber;
      case OrderStatus.ready:
      case OrderStatus.completed:
        return PillTone.green;
      case OrderStatus.cancelled:
        return PillTone.neutral;
    }
  }
}

// Small filter chip used above the table
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.amber : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? AppTheme.amber
                  : AppTheme.lightAmberWhite.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppTheme.windowWidgetBackgroundBlack
                  : AppTheme.lightAmberWhite,
            ),
          ),
        ),
      ),
    );
  }
}
