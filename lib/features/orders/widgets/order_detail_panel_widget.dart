import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/orders/controller/order_controller.dart';
import 'package:omnix/features/orders/model/order_model.dart';
import 'package:omnix/features/orders/widgets/order_badges.dart';
import 'package:omnix/features/orders/widgets/order_dialogs.dart';

/// Right hand inspector for the selected ticket.
class OrderDetailPanelWidget extends StatelessWidget {
  const OrderDetailPanelWidget({
    super.key,
    required this.orderController,
    this.onClose,
    this.onPrinterSettings,
  });

  final OrderController orderController;

  /// Shown when the panel is opened as a dialog on a narrow window.
  final VoidCallback? onClose;
  final VoidCallback? onPrinterSettings;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Order? order = orderController.selectedOrder;

      if (order == null) {
        return _buildEmptyState();
      }

      final DateTime now = orderController.now.value;

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
            _buildHeader(context, order, now),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMetaCards(order),
                    if (order.status == OrderStatus.cancelled) ...[
                      const SizedBox(height: 8),
                      _buildCancellationBanner(order),
                    ],
                    const SizedBox(height: 14),
                    _SectionHeader(
                      label: 'ITEMS',
                      trailing: '${order.itemCount} items',
                    ),
                    const SizedBox(height: 7),
                    ...order.lines.map(_buildLine),
                    const SizedBox(height: 12),
                    _buildBill(order),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildFooter(context, order),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
          width: 0.6,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 38,
                color: AppTheme.tableHeaderText.withValues(alpha: 0.45),
              ),
              const Text(
                'Select a ticket',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightAmberWhite,
                ),
              ),
              const Text(
                'Pick an order from the ledger to inspect the items, settle '
                'the bill and reprint tickets.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.4,
                  color: AppTheme.tableHeaderText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Order order, DateTime now) {
    final bool isPrinting = orderController.isPrintingOrder(order.id);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        '#${order.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OrderStatusPill(status: order.status),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Token #${order.token} · Tax invoice · '
                  '${order.channel.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Placed ${formatClock(order.placedAt)} · '
                  '${order.elapsedLabel(now)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: order.isRush(now)
                        ? AppTheme.dangerRedLight
                        : AppTheme.badgeNeutralText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          _PanelIconButton(
            icon: isPrinting
                ? Icons.hourglass_top_outlined
                : Icons.receipt_long_outlined,
            tooltip: 'Preview receipt',
            onTap: () => _openReceiptPreview(context, order),
          ),
          PopupMenuButton<String>(
            tooltip: 'More actions',
            color: AppTheme.sidebarBackgroundBlack,
            position: PopupMenuPosition.under,
            onSelected: (String value) {
              switch (value) {
                case 'preview':
                  _openReceiptPreview(context, order);
                case 'copy':
                  orderController.copyOrderSummary(order);
                case 'printer':
                  onPrinterSettings?.call();
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                _menuItem(
                  value: 'preview',
                  icon: Icons.receipt_long_outlined,
                  label: 'Preview receipt',
                ),
                _menuItem(
                  value: 'copy',
                  icon: Icons.copy_all_outlined,
                  label: 'Copy order summary',
                ),
                if (onPrinterSettings != null)
                  _menuItem(
                    value: 'printer',
                    icon: Icons.print_outlined,
                    label: 'Printer settings',
                  ),
              ];
            },
            child: const _PanelIcon(icon: Icons.more_horiz),
          ),
          if (onClose != null)
            _PanelIconButton(
              icon: Icons.close,
              tooltip: 'Close',
              onTap: onClose!,
            ),
        ],
      ),
    );
  }

  Widget _buildMetaCards(Order order) {
    final _MetaData primary;
    final IconData primaryIcon;

    switch (order.channel) {
      case OrderChannel.dineIn:
        primary = _MetaData(
          label: 'TABLE / SEATING',
          title:
              '${order.tableLabel ?? '—'}${order.areaLabel == null ? '' : ' · ${order.areaLabel}'}',
          subtitle: '${order.guests} guests',
        );
        primaryIcon = Icons.table_restaurant_outlined;
      case OrderChannel.takeaway:
        primary = _MetaData(
          label: 'PICKUP',
          title: order.customerName,
          subtitle: order.customerPhone ?? 'Counter pickup',
        );
        primaryIcon = Icons.shopping_bag_outlined;
      case OrderChannel.delivery:
        primary = _MetaData(
          label: 'DELIVERY',
          title: order.customerName,
          subtitle: <String>[
            order.riderLabel ?? 'Rider',
            if (order.riderCode != null && order.riderCode!.isNotEmpty)
              order.riderCode!,
          ].join(' · '),
        );
        primaryIcon = Icons.delivery_dining_outlined;
    }

    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: _MetaCard(
            data: primary,
            icon: primaryIcon,
            accent: channelColor(order.channel),
          ),
        ),
        Expanded(
          child: _MetaCard(
            data: _MetaData(
              label: 'STAFF / TERMINAL',
              title: order.serverName,
              subtitle: order.terminal,
            ),
            icon: Icons.badge_outlined,
            accent: AppTheme.lightGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildCancellationBanner(Order order) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.dangerRed.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.dangerRed.withValues(alpha: 0.24),
          width: 0.6,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const Icon(
            Icons.block_outlined,
            size: 15,
            color: AppTheme.dangerRedLight,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.paymentStatus == PaymentStatus.refunded
                      ? 'Cancelled · refunded'
                      : 'Cancelled · voided',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.dangerRedLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.cancellationReason ?? 'No reason recorded.',
                  style: const TextStyle(
                    fontSize: 9.5,
                    height: 1.35,
                    color: AppTheme.badgeNeutralText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(OrderLine line) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.09),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 21,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${line.quantity}x',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.badgeAmberText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.tablePrimaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${line.quantity} × ${formatTakaSymbol(line.unitPrice)}',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppTheme.tableHeaderText,
                      ),
                    ),
                    if (line.note != null && line.note!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        line.note!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          height: 1.3,
                          color: AppTheme.lightAmberWhite.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatTakaSymbol(line.total),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
          if (line.modifiers.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: line.modifiers
                    .map((String modifier) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.amber.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          modifier,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.badgeAmberText,
                          ),
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBill(Order order) {
    final bool isPaid = order.paymentStatus == PaymentStatus.paid;
    final bool isRefunded = order.paymentStatus == PaymentStatus.refunded;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'BILL SUMMARY',
            style: TextStyle(
              fontSize: 8.5,
              letterSpacing: 0.7,
              fontWeight: FontWeight.w700,
              color: AppTheme.tableHeaderText,
            ),
          ),
          const SizedBox(height: 7),
          _SummaryRow(
            label: 'Subtotal',
            value: formatTakaSymbol(order.subtotal),
          ),
          if (order.discount > 0)
            _SummaryRow(
              label: 'Discount',
              value: '- ${formatTakaSymbol(order.discount)}',
              color: AppTheme.lightGreen,
            ),
          _SummaryRow(
            label: 'VAT (${_percent(order.vatPercent)}%)',
            value: formatTakaSymbol(order.vat),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Divider(
              height: 1,
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
            ),
          ),
          _SummaryRow(
            label: 'Net total',
            value: formatTakaSymbol(order.total),
            isTotal: true,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.sidebarBackgroundBlack,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      isPaid
                          ? Icons.check_circle_outline
                          : (isRefunded
                                ? Icons.undo_outlined
                                : Icons.schedule_outlined),
                      size: 14,
                      color: paymentStatusColor(order.paymentStatus),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isPaid
                            ? 'Paid via ${order.paymentMethod.label}'
                            : (isRefunded
                                  ? 'Refunded to guest'
                                  : 'Payment pending'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: paymentStatusColor(order.paymentStatus),
                        ),
                      ),
                    ),
                    PaymentStatusPill(paymentStatus: order.paymentStatus),
                  ],
                ),
                if (isPaid) ...[
                  const SizedBox(height: 5),
                  _SummaryRow(
                    label: 'Tendered',
                    value: formatTakaSymbol(order.tenderedAmount),
                    compact: true,
                  ),
                  if (order.changeDue > 0)
                    _SummaryRow(
                      label: 'Change returned',
                      value: formatTakaSymbol(order.changeDue),
                      color: AppTheme.lightGreen,
                      compact: true,
                    ),
                ] else if (!isRefunded) ...[
                  const SizedBox(height: 5),
                  _SummaryRow(
                    label: 'Balance due',
                    value: formatTakaSymbol(order.balanceDue),
                    color: AppTheme.badgeAmberText,
                    compact: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Order order) {
    final bool isPrintingReceipt = orderController.isPrintingOrder(order.id);
    final bool isPrintingKot = orderController.isPrintingKot(order.id);
    final bool isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBackgroundBlack,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
            width: 0.6,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: _primaryAction(context, order),
              icon: isPrintingReceipt && order.status == OrderStatus.completed
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.windowWidgetBackgroundBlack,
                      ),
                    )
                  : Icon(primaryActionIcon(order), size: 17),
              label: Text(
                isPrintingReceipt && order.status == OrderStatus.completed
                    ? 'Printing receipt...'
                    : primaryActionLabel(order),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.amber,
                foregroundColor: AppTheme.windowWidgetBackgroundBlack,
                disabledBackgroundColor: AppTheme.sidebarBackgroundBlack,
                disabledForegroundColor: AppTheme.tableHeaderText,
                elevation: 0,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                textStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            spacing: 6,
            children: [
              Expanded(
                child: _FooterAction(
                  icon: Icons.print_outlined,
                  label: isPrintingReceipt ? 'Printing' : 'Receipt',
                  onTap: isCancelled
                      ? null
                      : () => orderController.printReceipt(order),
                  isLoading: isPrintingReceipt,
                ),
              ),
              Expanded(
                child: _FooterAction(
                  icon: Icons.soup_kitchen_outlined,
                  label: isPrintingKot ? 'Sending' : 'KOT',
                  onTap: isCancelled
                      ? null
                      : () => orderController.printKitchenTicket(order),
                  isLoading: isPrintingKot,
                ),
              ),
              Expanded(
                child: _FooterAction(
                  icon: Icons.cancel_outlined,
                  label: 'Void',
                  danger: true,
                  onTap: isCancelled ? null : () => _openVoid(context, order),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  VoidCallback? _primaryAction(BuildContext context, Order order) {
    switch (order.status) {
      case OrderStatus.cancelled:
        return null;
      case OrderStatus.completed:
        return () => orderController.printReceipt(order);
      case OrderStatus.ready:
        if (requiresSettlement(order)) {
          return () => _openSettlement(context, order);
        }
        return () => orderController.completeOrder(order);
      case OrderStatus.pending:
      case OrderStatus.preparing:
        return () => orderController.advanceStatus(order);
    }
  }

  Future<void> _openSettlement(BuildContext context, Order order) async {
    final OrderSettlement? settlement = await showDialog<OrderSettlement>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (BuildContext context) {
        return OrderSettlementDialog(order: order);
      },
    );

    if (settlement == null) return;

    orderController.completeOrder(
      order,
      method: settlement.method,
      cashReceived: settlement.cashReceived,
    );
  }

  Future<void> _openVoid(BuildContext context, Order order) async {
    await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (BuildContext context) {
        return OrderVoidDialog(
          order: order,
          onSubmit: (String pin, String reason) async {
            return orderController.voidOrder(order, pin, reason);
          },
        );
      },
    );
  }

  void _openReceiptPreview(BuildContext context, Order order) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (BuildContext context) {
        return OrderReceiptPreviewDialog(
          order: order,
          orderController: orderController,
        );
      },
    );
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 38,
      child: Row(
        spacing: 8,
        children: [
          Icon(icon, size: 14, color: AppTheme.tableHeaderText),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppTheme.lightAmberWhite,
            ),
          ),
        ],
      ),
    );
  }

  String _percent(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

class _MetaData {
  const _MetaData({
    required this.label,
    required this.title,
    required this.subtitle,
  });

  final String label;
  final String title;
  final String subtitle;
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({
    required this.data,
    required this.icon,
    required this.accent,
  });

  final _MetaData data;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.09),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 7.5,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              Icon(icon, size: 13, color: accent),
            ],
          ),
          const Spacer(),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.tablePrimaryText,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.trailing});

  final String label;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8.5,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
            color: AppTheme.tableHeaderText,
          ),
        ),
        const Spacer(),
        Text(
          trailing,
          style: const TextStyle(fontSize: 9, color: AppTheme.tableHeaderText),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.color,
    this.isTotal = false,
    this.compact = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool isTotal;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 1 : 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 11.5 : (compact ? 9.5 : 10.5),
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
                color: isTotal
                    ? AppTheme.tablePrimaryText
                    : AppTheme.tableHeaderText,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 15 : (compact ? 9.5 : 10.5),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color:
                  color ??
                  (isTotal ? AppTheme.amber : AppTheme.tablePrimaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final Color color = !enabled
        ? AppTheme.tableHeaderText.withValues(alpha: 0.55)
        : danger
        ? AppTheme.dangerRedLight
        : AppTheme.lightAmberWhite;

    return Tooltip(
      message: label,
      child: Material(
        color: danger
            ? AppTheme.dangerRed.withValues(alpha: 0.07)
            : AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: (danger ? AppTheme.dangerRed : AppTheme.amber).withValues(
            alpha: 0.08,
          ),
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: danger
                    ? AppTheme.dangerRed.withValues(alpha: 0.22)
                    : AppTheme.lightAmberWhite.withValues(alpha: 0.12),
                width: 0.6,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: color,
                    ),
                  )
                else
                  Icon(icon, size: 13, color: color),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelIconButton extends StatelessWidget {
  const _PanelIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: AppTheme.amber.withValues(alpha: 0.1),
          child: _PanelIcon(icon: icon),
        ),
      ),
    );
  }
}

class _PanelIcon extends StatelessWidget {
  const _PanelIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Icon(icon, size: 16, color: AppTheme.tableHeaderText),
    );
  }
}
