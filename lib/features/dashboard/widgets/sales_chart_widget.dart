import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/dashboard/controller/dash_board_controller.dart';
import 'package:omnix/features/dashboard/model/sales_bucket_model.dart';

// Sales bar chart, scrolls sideways when bars don't fit
class SalesChartWidget extends StatelessWidget {
  const SalesChartWidget({super.key, required this.dashBoardController});

  final DashBoardController dashBoardController;

  // width of one bar slot
  static const double slotWidth = 44;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (dashBoardController.isLoadingSales.value) {
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.amber,
          ),
        );
      }

      final data = dashBoardController.salesBuckets;

      if (data.isEmpty) {
        return const Center(
          child: Text(
            'No sales data yet',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          // grows with bars, scroll when it does not fit
          final width = max(constraints.maxWidth, data.length * slotWidth);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: BarChart(
                BarChartData(
                  maxY: dashBoardController.maxSale * 1.15,
                  barGroups: buildBarGroups(data),
                  gridData: buildGridData(),
                  borderData: FlBorderData(show: false),
                  barTouchData: buildTouchData(data),
                  titlesData: buildTitles(data),
                ),
                duration: const Duration(milliseconds: 300),
              ),
            ),
          );
        },
      );
    });
  }

  List<BarChartGroupData> buildBarGroups(List<SalesBucket> data) {
    return data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.sales,
            width: 18,
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [AppTheme.amber, AppTheme.deepAmberWhite],
            ),
          ),
        ],
      );
    }).toList();
  }

  FlGridData buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) => FlLine(
        color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
        strokeWidth: 1,
      ),
    );
  }

  BarTouchData buildTouchData(List<SalesBucket> data) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => AppTheme.windowWidgetBackgroundBlack,
        tooltipBorder: BorderSide(color: AppTheme.amber.withValues(alpha: 0.4)),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            '${data[groupIndex].label}\n',
            const TextStyle(
              color: AppTheme.lightAmberWhite,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            children: [
              TextSpan(
                text: '${rod.toY.round()} TK',
                style: const TextStyle(
                  color: AppTheme.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  FlTitlesData buildTitles(List<SalesBucket> data) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

      // left side, sale amount
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          interval: yInterval,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            child: Text(
              formatAmount(value),
              style: TextStyle(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),

      // bottom side, hour or day
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 26,
          getTitlesWidget: (value, meta) {
            final index = value.round();

            if (index < 0 || index >= data.length) {
              return const SizedBox.shrink();
            }

            return SideTitleWidget(
              meta: meta,
              child: Text(
                data[index].label,
                style: TextStyle(
                  color: AppTheme.lightAmberWhite.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // y axis step, rounded to a clean number like 1000, 2000, 5000
  double get yInterval {
    final maxSale = dashBoardController.maxSale;
    if (maxSale <= 0) return 1000;

    final step = (maxSale / 4 / 1000).round() * 1000;
    return step < 1000 ? 1000.0 : step.toDouble();
  }

  // 12000 -> 12k
  String formatAmount(double value) {
    if (value >= 1000) {
      final k = value / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return value.toInt().toString();
  }
}
