import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/branches/model/branch_model.dart';

/// Cross-branch hourly order throughput strip.
class BranchNetworkChartWidget extends StatelessWidget {
  const BranchNetworkChartWidget({super.key, required this.controller});

  final BranchController controller;

  // palette assigned to the active outlets, in list order
  static const List<Color> _palette = [
    AppTheme.amber,
    AppTheme.lightGreen,
    AppTheme.infoBlue,
    AppTheme.badgeAmberText,
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Branch> branches = controller.activeBranches;
      final List<BranchThroughputSlot> slots = controller.throughput;

      if (branches.isEmpty || slots.isEmpty) {
        return const SizedBox.shrink();
      }

      final int max = _maxOrders(slots);

      return Container(
        padding: const EdgeInsets.all(16),
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
          spacing: 14,
          children: [_buildHeader(branches), _buildChart(slots, branches, max)],
        ),
      );
    });
  }

  Widget _buildHeader(List<Branch> branches) {
    final Widget legend = Wrap(
      spacing: 14,
      runSpacing: 6,
      children: List.generate(branches.length, (int index) {
        final Branch branch = branches[index];
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _palette[index % _palette.length],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '${_shortName(branch.name)} (${branch.id})',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.badgeNeutralText,
              ),
            ),
          ],
        );
      }),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const Widget title = Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(Icons.bar_chart_outlined, size: 18, color: AppTheme.amber),
            Flexible(
              child: Text(
                'Cross-Branch Hourly Order Throughput',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.tablePrimaryText,
                ),
              ),
            ),
          ],
        );

        if (constraints.maxWidth >= 760) {
          return Row(
            spacing: 16,
            children: [
              Flexible(child: title),
              legend,
            ],
          );
        }

        return Column(
          crossAxisAlignment: .start,
          spacing: 10,
          children: [title, legend],
        );
      },
    );
  }

  Widget _buildChart(
    List<BranchThroughputSlot> slots,
    List<Branch> branches,
    int max,
  ) {
    return SizedBox(
      height: 190,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double slotWidth = 56;
          final double contentWidth = slots.length * slotWidth;
          final bool scrollable = contentWidth > constraints.maxWidth;
          final double width = scrollable ? contentWidth : constraints.maxWidth;

          final Widget chart = SizedBox(
            width: width,
            child: Row(
              crossAxisAlignment: .stretch,
              children: slots
                  .map(
                    (BranchThroughputSlot slot) => Expanded(
                      child: _ThroughputGroup(
                        slot: slot,
                        branches: branches,
                        palette: _palette,
                        max: max,
                      ),
                    ),
                  )
                  .toList(),
            ),
          );

          if (!scrollable) return chart;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: chart,
          );
        },
      ),
    );
  }

  int _maxOrders(List<BranchThroughputSlot> slots) {
    int max = 1;
    for (final BranchThroughputSlot slot in slots) {
      for (final int value in slot.orders.values) {
        if (value > max) max = value;
      }
    }
    return max;
  }

  String _shortName(String name) {
    return name.replaceAll(' Branch', '').replaceAll(' Outlet', '').trim();
  }
}

class _ThroughputGroup extends StatelessWidget {
  const _ThroughputGroup({
    required this.slot,
    required this.branches,
    required this.palette,
    required this.max,
  });

  final BranchThroughputSlot slot;
  final List<Branch> branches;
  final List<Color> palette;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: .end,
            children: List.generate(branches.length, (int index) {
              final int value = slot.orders[branches[index].id] ?? 0;
              final double factor = (value / max).clamp(0.04, 1.0).toDouble();

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: factor,
                      widthFactor: 0.8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: palette[index % palette.length],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          slot.hour,
          maxLines: 1,
          style: const TextStyle(fontSize: 10, color: AppTheme.tableHeaderText),
        ),
      ],
    );
  }
}
