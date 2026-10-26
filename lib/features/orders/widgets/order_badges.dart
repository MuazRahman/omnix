import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/orders/model/order_model.dart';

/// Shared visual language for the order ledger. Keeping the mapping here means
/// the list, the detail panel and the dialogs always agree on a colour.
PillTone orderStatusTone(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return PillTone.blue;
    case OrderStatus.preparing:
      return PillTone.amber;
    case OrderStatus.ready:
      return PillTone.green;
    case OrderStatus.completed:
      return PillTone.green;
    case OrderStatus.cancelled:
      return PillTone.red;
  }
}

PillTone paymentStatusTone(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.paid:
      return PillTone.green;
    case PaymentStatus.unpaid:
      return PillTone.amber;
    case PaymentStatus.refunded:
      return PillTone.blue;
    case PaymentStatus.voided:
      return PillTone.red;
  }
}

Color paymentStatusColor(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.paid:
      return AppTheme.lightGreen;
    case PaymentStatus.unpaid:
      return AppTheme.badgeAmberText;
    case PaymentStatus.refunded:
      return AppTheme.infoBlueLight;
    case PaymentStatus.voided:
      return AppTheme.dangerRedLight;
  }
}

IconData channelIcon(OrderChannel channel) {
  switch (channel) {
    case OrderChannel.dineIn:
      return Icons.table_restaurant_outlined;
    case OrderChannel.takeaway:
      return Icons.shopping_bag_outlined;
    case OrderChannel.delivery:
      return Icons.delivery_dining_outlined;
  }
}

Color channelColor(OrderChannel channel) {
  switch (channel) {
    case OrderChannel.dineIn:
      return AppTheme.amber;
    case OrderChannel.takeaway:
      return AppTheme.infoBlueLight;
    case OrderChannel.delivery:
      return AppTheme.lightGreen;
  }
}

String orderSourceTitle(Order order) {
  switch (order.channel) {
    case OrderChannel.dineIn:
      return 'Table ${order.tableLabel ?? '—'}';
    case OrderChannel.takeaway:
    case OrderChannel.delivery:
      return order.customerName;
  }
}

String orderSourceSubtitle(Order order) {
  switch (order.channel) {
    case OrderChannel.dineIn:
      final List<String> parts = <String>[
        if (order.areaLabel != null && order.areaLabel!.isNotEmpty)
          order.areaLabel!,
        if (order.guests > 0) '${order.guests} guests',
        if (order.serverName.isNotEmpty) order.serverName,
      ];
      return parts.join(' · ');
    case OrderChannel.takeaway:
      return order.customerPhone == null || order.customerPhone!.trim().isEmpty
          ? 'Counter pickup'
          : 'Takeaway · ${order.customerPhone}';
    case OrderChannel.delivery:
      final String rider = <String>[
        order.riderLabel ?? 'Delivery',
        if (order.riderCode != null && order.riderCode!.isNotEmpty)
          order.riderCode!,
      ].join(' ');
      return rider;
  }
}

String paymentSummary(Order order) {
  return '${order.paymentMethod.label} · ${order.paymentStatus.label}';
}

bool requiresSettlement(Order order) {
  return order.status == OrderStatus.ready &&
      order.paymentStatus == PaymentStatus.unpaid;
}

String primaryActionLabel(Order order) {
  switch (order.status) {
    case OrderStatus.pending:
      return 'Send to Kitchen';
    case OrderStatus.preparing:
      return 'Mark Ready';
    case OrderStatus.ready:
      return requiresSettlement(order) ? 'Settle & Complete' : 'Complete Order';
    case OrderStatus.completed:
      return 'Print Receipt';
    case OrderStatus.cancelled:
      return 'Order Cancelled';
  }
}

IconData primaryActionIcon(Order order) {
  switch (order.status) {
    case OrderStatus.pending:
      return Icons.local_fire_department_outlined;
    case OrderStatus.preparing:
      return Icons.room_service_outlined;
    case OrderStatus.ready:
      return requiresSettlement(order)
          ? Icons.payments_outlined
          : Icons.task_alt_outlined;
    case OrderStatus.completed:
      return Icons.print_outlined;
    case OrderStatus.cancelled:
      return Icons.block_outlined;
  }
}

/// Compact status pill used across the ledger.
class OrderStatusPill extends StatelessWidget {
  const OrderStatusPill({super.key, required this.status, this.dense = false});

  final OrderStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return StatusPillWidget(
      label: status.label,
      tone: orderStatusTone(status),
      showDot: !dense,
    );
  }
}

/// Payment badge, e.g. "Cash · Paid" or "bKash · Unpaid".
class PaymentStatusPill extends StatelessWidget {
  const PaymentStatusPill({
    super.key,
    required this.paymentStatus,
    this.method,
  });

  final PaymentStatus paymentStatus;
  final PaymentMethod? method;

  @override
  Widget build(BuildContext context) {
    final String label = method == null
        ? paymentStatus.label
        : '${method!.label} · ${paymentStatus.label}';

    return StatusPillWidget(
      label: label,
      tone: paymentStatusTone(paymentStatus),
      showDot: false,
    );
  }
}

/// Rounded channel glyph used as the leading marker of an order row.
class OrderChannelMark extends StatelessWidget {
  const OrderChannelMark({super.key, required this.channel, this.size = 32});

  final OrderChannel channel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = channelColor(channel);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 0.6),
      ),
      child: Icon(channelIcon(channel), size: size * 0.5, color: color),
    );
  }
}
