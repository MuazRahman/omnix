import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/orders/controller/order_controller.dart';

/// Compact shift metric used in the strip above the ledger.
class OrderMetricCard extends StatelessWidget {
  const OrderMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.accent,
    this.valueSuffix,
    this.captionColor,
  });

  final String title;
  final String value;
  final String? valueSuffix;
  final String caption;
  final IconData icon;
  final Color accent;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
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
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: accent),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: AppTheme.white,
                  ),
                ),
              ),
              if (valueSuffix != null) ...[
                const SizedBox(width: 3),
                Text(
                  valueSuffix!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: captionColor ?? AppTheme.tableHeaderText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Four shift metrics. They sit in a single row on wide windows and become a
/// horizontal strip on narrow ones so the ledger keeps its vertical space.
class OrdersSummaryWidget extends StatelessWidget {
  const OrdersSummaryWidget({super.key, required this.orderController});

  final OrderController orderController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int average = orderController.averageTurnaround;
      final int rush = orderController.rushCount;

      final List<Widget> cards = <Widget>[
        OrderMetricCard(
          title: 'Orders today',
          value: '${orderController.totalOrders}',
          caption: '${orderController.liveKitchenCount} live in the queue',
          icon: Icons.receipt_long_outlined,
          accent: AppTheme.amber,
          captionColor: AppTheme.badgeAmberText,
        ),
        OrderMetricCard(
          title: 'Live kitchen',
          value: '${orderController.liveKitchenCount}',
          caption: rush == 0
              ? 'Every ticket within target'
              : '$rush rush over 15 minutes',
          icon: Icons.soup_kitchen_outlined,
          accent: rush == 0 ? AppTheme.lightGreen : AppTheme.dangerRedLight,
          captionColor: rush == 0
              ? AppTheme.lightGreen
              : AppTheme.dangerRedLight,
        ),
        OrderMetricCard(
          title: 'Net revenue',
          value: formatTakaSymbol(orderController.netRevenue),
          caption:
              'Cash ${formatTakaSymbol(orderController.cashRevenue)} · '
              'Wallet ${formatTakaSymbol(orderController.walletRevenue)}',
          icon: Icons.payments_outlined,
          accent: AppTheme.lightGreen,
        ),
        OrderMetricCard(
          title: 'Avg turnaround',
          value: '$average',
          valueSuffix: 'min',
          caption: average <= 22
              ? 'Target under 22 minutes'
              : 'Above the 22 minute target',
          icon: Icons.timer_outlined,
          accent: AppTheme.infoBlueLight,
          captionColor: average <= 22
              ? AppTheme.lightGreen
              : AppTheme.dangerRedLight,
        ),
      ];

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth >= 760) {
            return Row(
              spacing: 12,
              children: cards
                  .map((Widget card) => Expanded(child: card))
                  .toList(growable: false),
            );
          }

          return SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(width: 200, child: cards[index]);
              },
            ),
          );
        },
      );
    });
  }
}
