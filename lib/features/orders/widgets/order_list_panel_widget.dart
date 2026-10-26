import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/orders/controller/order_controller.dart';
import 'package:omnix/features/orders/model/order_model.dart';
import 'package:omnix/features/orders/widgets/order_badges.dart';

/// Scrollable ledger of the shift tickets.
class OrderListPanelWidget extends StatefulWidget {
  const OrderListPanelWidget({
    super.key,
    required this.orderController,
    required this.onOrderTap,
  });

  final OrderController orderController;
  final ValueChanged<Order> onOrderTap;

  @override
  State<OrderListPanelWidget> createState() => _OrderListPanelWidgetState();
}

class _OrderListPanelWidgetState extends State<OrderListPanelWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Order> orders = widget.orderController.filteredOrders;
      final DateTime now = widget.orderController.now.value;
      final String? selectedId = widget.orderController.selectedOrderId.value;

      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppTheme.windowWidgetBackgroundBlack,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
            width: 0.6,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPanelHeader(orders.length),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool compact = constraints.maxWidth < 620;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildColumnHeader(compact: compact),
                      Expanded(
                        child: orders.isEmpty
                            ? _buildEmptyState()
                            : Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                interactive: true,
                                thickness: 5,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.only(bottom: 6),
                                  itemCount: orders.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        final Order order = orders[index];

                                        return _OrderRow(
                                          order: order,
                                          now: now,
                                          selected: order.id == selectedId,
                                          compact: compact,
                                          onTap: () => widget.onOrderTap(order),
                                        );
                                      },
                                ),
                              ),
                      ),
                      _buildFooter(orders.length),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPanelHeader(int visibleCount) {
    final int unpaid = widget.orderController.unpaidCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBackgroundBlack,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 16,
            color: AppTheme.amber,
          ),
          const SizedBox(width: 7),
          const Text(
            'Shift orders',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Today · $visibleCount tickets',
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.tableHeaderText,
            ),
          ),
          const Spacer(),
          if (unpaid > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$unpaid unpaid',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.badgeAmberText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader({required bool compact}) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack.withValues(alpha: 0.55),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 96, child: _ColumnLabel('ORDER')),
          const Expanded(flex: 3, child: _ColumnLabel('SOURCE')),
          if (!compact) const Expanded(flex: 3, child: _ColumnLabel('ITEMS')),
          const SizedBox(
            width: 128,
            child: _ColumnLabel('AMOUNT', alignRight: true),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(int visibleCount) {
    final bool filtered = visibleCount != widget.orderController.totalOrders;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack.withValues(alpha: 0.55),
        border: Border(
          top: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            filtered
                ? 'Showing $visibleCount of ${widget.orderController.totalOrders} tickets'
                : '$visibleCount tickets in this shift',
            style: const TextStyle(
              fontSize: 9.5,
              color: AppTheme.tableHeaderText,
            ),
          ),
          const Spacer(),
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppTheme.lightGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'Refreshes every 30s',
            style: TextStyle(fontSize: 9, color: AppTheme.tableHeaderText),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 34,
            color: AppTheme.tableHeaderText.withValues(alpha: 0.5),
          ),
          const Text(
            'No tickets match these filters',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightAmberWhite,
            ),
          ),
          const Text(
            'Try another status, channel or search phrase.',
            style: TextStyle(fontSize: 10.5, color: AppTheme.tableHeaderText),
          ),
          TextButton.icon(
            onPressed: widget.orderController.clearFilters,
            icon: const Icon(Icons.filter_alt_off_outlined, size: 14),
            label: const Text('Clear filters'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.amber,
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.order,
    required this.now,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final Order order;
  final DateTime now;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool rush = order.isRush(now);

    return Material(
      color: selected
          ? AppTheme.amber.withValues(alpha: 0.06)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppTheme.amber.withValues(alpha: 0.035),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? AppTheme.amber : Colors.transparent,
                width: 2,
              ),
              bottom: BorderSide(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.07),
                width: 0.6,
              ),
            ),
          ),
          child: Row(
            children: [
              // order number and age
              SizedBox(
                width: 96,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                        color: selected ? AppTheme.amber : AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      spacing: 3,
                      children: [
                        if (rush)
                          const Icon(
                            Icons.local_fire_department,
                            size: 11,
                            color: AppTheme.dangerRedLight,
                          ),
                        Flexible(
                          child: Text(
                            order.elapsedLabel(now),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: rush
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: rush
                                  ? AppTheme.dangerRedLight
                                  : AppTheme.tableHeaderText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // channel, table / customer
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    OrderChannelMark(channel: order.channel, size: 30),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderSourceTitle(order),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.tablePrimaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            orderSourceSubtitle(order),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppTheme.tableHeaderText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // item summary
              if (!compact)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _itemsTitle(order),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.tablePrimaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _itemsSubtitle(order),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: AppTheme.tableHeaderText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // amount, status and payment
              SizedBox(
                width: 128,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatTakaSymbol(order.total),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    OrderStatusPill(status: order.status, dense: true),
                    const SizedBox(height: 3),
                    Text(
                      paymentSummary(order),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: paymentStatusColor(order.paymentStatus),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _itemsTitle(Order order) {
    if (order.lines.isEmpty) return 'No items';

    return order.lines
        .take(2)
        .map((OrderLine line) => '${line.quantity}x ${line.name}')
        .join(', ');
  }

  String _itemsSubtitle(Order order) {
    final String items = '${order.itemCount} items';
    final String kot = order.kotPrintedAt == null ? 'KOT pending' : 'KOT sent';
    return '$items · $kot';
  }
}

class _ColumnLabel extends StatelessWidget {
  const _ColumnLabel(this.label, {this.alignRight = false});

  final String label;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: AppTheme.tableHeaderText,
        ),
      ),
    );
  }
}
