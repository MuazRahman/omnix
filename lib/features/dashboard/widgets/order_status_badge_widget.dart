import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/dashboard/model/recent_order_model.dart';

// Status pill of the recent orders table, colored per status
class OrderStatusBadgeWidget extends StatelessWidget {
  const OrderStatusBadgeWidget({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    // background of the pill, its text color and the optional leading dot
    final Color background;
    final Color foreground;
    final Color? dot;

    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.preparing:
        background = AppTheme.amber.withValues(alpha: 0.2);
        foreground = AppTheme.badgeAmberText;
        dot = AppTheme.amber;
      case OrderStatus.ready:
        background = AppTheme.successGreen.withValues(alpha: 0.2);
        foreground = AppTheme.lightGreen;
        dot = AppTheme.lightGreen;
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        background = AppTheme.badgeNeutralBackground;
        foreground = AppTheme.badgeNeutralText;
        dot = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (dot != null)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),

          // flexible so the pill never overflows a narrow column
          Flexible(
            child: Text(
              _label(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1.4,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label() {
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
}
