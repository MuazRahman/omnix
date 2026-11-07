import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';

/// Consolidated network overview shown above the branch list.
class BranchOverviewBannerWidget extends StatelessWidget {
  const BranchOverviewBannerWidget({super.key, required this.controller});

  final BranchController controller;

  /// Height shared by the stat tiles and the sync panel beside them.
  static const double _tileHeight = 118;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Every observable has to be read *inside* this closure. Widgets that
      // build later (LayoutBuilder, child widgets) would not register a read.
      final int activeCount = controller.activeCount;
      final int combinedRevenue = controller.combinedRevenue;
      final String networkCoverage = controller.networkCoverage;
      final double revenueChange = controller.networkRevenueChangePercent;
      final int totalStaff = controller.totalStaff;
      final int totalPosTerminals = controller.totalPosTerminals;
      final int combinedOrders = controller.combinedOrders;

      final Widget tiles = _buildTiles(
        activeCount: activeCount,
        combinedRevenue: combinedRevenue,
        networkCoverage: networkCoverage,
        revenueChange: revenueChange,
        totalStaff: totalStaff,
        totalPosTerminals: totalPosTerminals,
      );

      final Widget sync = _SyncPanel(
        combinedOrders: combinedOrders,
        onExport: () => controller.showComingSoon('Consolidated report export'),
      );

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
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth >= 1050) {
              return Row(
                crossAxisAlignment: .start,
                spacing: 16,
                children: [
                  Expanded(child: tiles),
                  SizedBox(width: 300, height: _tileHeight, child: sync),
                ],
              );
            }

            return Column(
              crossAxisAlignment: .stretch,
              spacing: 12,
              children: [tiles, sync],
            );
          },
        ),
      );
    });
  }

  Widget _buildTiles({
    required int activeCount,
    required int combinedRevenue,
    required String networkCoverage,
    required double revenueChange,
    required int totalStaff,
    required int totalPosTerminals,
  }) {
    final List<Widget> tiles = [
      _OverviewTile(
        label: 'Network Footprint',
        value: '$activeCount',
        valueSuffix: 'Active Outlets',
        accent: AppTheme.lightGreen,
        showDot: true,
        footer: Text(
          networkCoverage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.badgeNeutralText,
          ),
        ),
      ),
      _OverviewTile(
        label: 'Combined Today Gross',
        value: formatTakaSymbol(combinedRevenue),
        accent: AppTheme.amber,
        icon: Icons.account_balance_wallet_outlined,
        footer: Row(
          spacing: 5,
          children: [
            const Icon(Icons.trending_up, size: 13, color: AppTheme.lightGreen),
            Text(
              '+${revenueChange.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightGreen,
              ),
            ),
            const Expanded(
              child: Text(
                "vs yesterday's close",
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
      _OverviewTile(
        label: 'Staff Deployment',
        value: '$totalStaff',
        valueSuffix: 'On Active Shifts',
        accent: AppTheme.tablePrimaryText,
        icon: Icons.groups_outlined,
        footer: Text(
          '$activeCount Managers · $totalPosTerminals POS Operators',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.badgeNeutralText,
          ),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = 12;
        final int columns = constraints.maxWidth >= 640 ? 3 : 1;
        final double width =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: tiles
              .map((Widget tile) => SizedBox(width: width, child: tile))
              .toList(),
        );
      },
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.label,
    required this.value,
    required this.accent,
    required this.footer,
    this.valueSuffix,
    this.icon,
    this.showDot = false,
  });

  final String label;
  final String value;
  final String? valueSuffix;
  final Color accent;
  final Widget footer;
  final IconData? icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: BranchOverviewBannerWidget._tileHeight,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (showDot)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.lightGreen,
                    shape: BoxShape.circle,
                  ),
                )
              else if (icon != null)
                Icon(icon, size: 17, color: accent.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: .centerLeft,
            child: Row(
              crossAxisAlignment: .end,
              spacing: 6,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -0.5,
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

class _SyncPanel extends StatelessWidget {
  const _SyncPanel({required this.combinedOrders, required this.onExport});

  final int combinedOrders;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        mainAxisAlignment: .center,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatBlock(
                  label: 'Sync State',
                  child: const Row(
                    spacing: 6,
                    children: [
                      _PulseDot(),
                      Flexible(
                        child: Text(
                          'Master Cloud Stream Live',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 34,
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _StatBlock(
                  label: 'Total Tickets',
                  alignEnd: true,
                  child: Text(
                    '$combinedOrders Orders',
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.tablePrimaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          _ExportButton(onTap: onExport),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.child,
    this.alignEnd = false,
  });

  final String label;
  final Widget child;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: alignEnd ? 14 : 0,
        right: alignEnd ? 0 : 14,
      ),
      child: Column(
        crossAxisAlignment: alignEnd ? .end : .start,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppTheme.tableHeaderText,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppTheme.lightGreen,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.sidebarBackgroundBlack,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.amber.withValues(alpha: 0.1),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
              width: 0.6,
            ),
          ),
          child: const Row(
            mainAxisAlignment: .center,
            spacing: 8,
            children: [
              Icon(
                Icons.download_outlined,
                size: 16,
                color: AppTheme.lightAmberWhite,
              ),
              Flexible(
                child: Text(
                  'Export Consolidated Report',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightAmberWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
