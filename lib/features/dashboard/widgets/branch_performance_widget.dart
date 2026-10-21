import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/common/widgets/scrollable_table_body.dart';
import 'package:omnix/features/dashboard/controller/dash_board_controller.dart';
import 'package:omnix/features/dashboard/model/branch_performance_model.dart';

/// Branch performance list shown on the dashboard next to the recent orders.
class BranchPerformanceWidget extends StatelessWidget {
  const BranchPerformanceWidget({super.key, required this.dashBoardController});

  final DashBoardController dashBoardController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<BranchPerformance> branches =
          dashBoardController.branchPerformance;

      if (branches.isEmpty) {
        return const Center(
          child: Text(
            'No branch data yet',
            style: TextStyle(fontSize: 12, color: AppTheme.tableHeaderText),
          ),
        );
      }

      return ScrollableTableBody(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              for (int i = 0; i < branches.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                buildBranchRow(branches[i]),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget buildBranchRow(BranchPerformance branch) {
    final bool isUp = branch.changePercent >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // branch name and code
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  branch.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.badgeAmberText,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '${branch.branchId} · ${branch.orders} orders',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // sale and the change against yesterday
          Column(
            crossAxisAlignment: .end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatTaka(branch.sale),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tablePrimaryText,
                ),
              ),

              const SizedBox(height: 2),

              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Icon(
                    isUp ? Icons.trending_up : Icons.trending_down,
                    size: 12,
                    color: isUp ? AppTheme.lightGreen : AppTheme.dangerRed,
                  ),

                  Text(
                    '${isUp ? '+' : ''}${branch.changePercent}%',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isUp ? AppTheme.lightGreen : AppTheme.dangerRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
