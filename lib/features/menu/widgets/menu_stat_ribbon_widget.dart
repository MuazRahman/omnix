import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';

/// Four health metrics shown above the catalog toolbar.
class MenuStatRibbonWidget extends StatelessWidget {
  const MenuStatRibbonWidget({super.key, required this.controller});

  final MenuController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int total = controller.menuItems.length;
      final int active = controller.activeCount;
      final double activeShare = total == 0 ? 0 : (active / total) * 100;
      final double marginGap =
          controller.averageMargin - MenuController.targetMargin;

      final List<Widget> cards = [
        MenuStatCard(
          label: 'Active Dishes',
          value: '$active',
          valueSuffix: ' / $total total',
          icon: Icons.restaurant_menu_outlined,
          accent: AppTheme.white,
          footer: Row(
            spacing: 8,
            children: [
              _MicroPill(
                label: '${activeShare.toStringAsFixed(0)}%',
                color: AppTheme.lightGreen,
                icon: Icons.trending_up,
              ),
              const Expanded(
                child: Text(
                  'Operational ready on POS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.badgeNeutralText,
                  ),
                ),
              ),
            ],
          ),
        ),
        MenuStatCard(
          label: 'Avg Food Cost Margin',
          value: '${controller.averageMargin.toStringAsFixed(1)}%',
          icon: Icons.pie_chart_outline,
          accent: AppTheme.lightGreen,
          footer: Row(
            spacing: 8,
            children: [
              const MenuSparkline(color: AppTheme.lightGreen),
              Expanded(
                child: Text(
                  '${marginGap >= 0 ? '+' : ''}'
                  '${marginGap.toStringAsFixed(1)}% vs '
                  '${MenuController.targetMargin.toStringAsFixed(0)}% target',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: AppTheme.badgeNeutralText,
                  ),
                ),
              ),
            ],
          ),
        ),
        MenuStatCard(
          label: 'Kitchen Availability',
          value: '${controller.alertCount}',
          valueSuffix: ' Alerts',
          icon: Icons.inventory_2_outlined,
          accent: AppTheme.dangerRedLight,
          footer: Row(
            spacing: 7,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.dangerRed,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  '${controller.soldOutCount} sold out · '
                  '${controller.lowStockCount} low stock',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.dangerRedLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        MenuStatCard(
          label: 'Top Grossing Segment',
          value: controller.topCategoryName,
          icon: Icons.star_outline,
          accent: AppTheme.badgeAmberText,
          footer: Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  '${controller.topCategoryShare.toStringAsFixed(0)}% '
                  'of gross revenue',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.badgeNeutralText,
                  ),
                ),
              ),
              Text(
                '${formatTakaSymbol(controller.topCategoryRevenue)}/day',
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tablePrimaryText,
                ),
              ),
            ],
          ),
        ),
      ];

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double gap = 12;
          final int columns = constraints.maxWidth >= 1150
              ? 4
              : (constraints.maxWidth >= 700 ? 2 : 1);
          final double cardWidth =
              (constraints.maxWidth - (gap * (columns - 1))) / columns;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: cards
                .map((Widget card) => SizedBox(width: cardWidth, child: card))
                .toList(),
          );
        },
      );
    });
  }
}

/// One metric tile of the menu ribbon.
class MenuStatCard extends StatelessWidget {
  const MenuStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.footer,
    this.valueSuffix,
  });

  final String label;
  final String value;
  final String? valueSuffix;
  final IconData icon;
  final Color accent;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    height: 1.25,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 19, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: .centerLeft,
            child: Row(
              crossAxisAlignment: .end,
              spacing: 3,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -0.6,
                    color: accent,
                  ),
                ),
                if (valueSuffix != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      valueSuffix!,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.tableHeaderText,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          footer,
        ],
      ),
    );
  }
}

class _MicroPill extends StatelessWidget {
  const _MicroPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 3,
        children: [
          Icon(icon, size: 11, color: color),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiny trend line used by the margin metric.
class MenuSparkline extends StatelessWidget {
  const MenuSparkline({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 16,
      child: CustomPaint(painter: _SparklinePainter(color)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const List<double> values = [0.82, 0.68, 0.52, 0.58, 0.3, 0.12];
    final Path path = Path();

    for (int index = 0; index < values.length; index++) {
      final double x = (index / (values.length - 1)) * size.width;
      final double y = values[index] * size.height;

      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.color != color;
}
