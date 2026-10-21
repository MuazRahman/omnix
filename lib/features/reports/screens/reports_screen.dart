import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/custom_container_widget.dart';
import 'package:omnix/features/common/widgets/section_header_widget.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/reports/controller/report_controller.dart';
import 'package:omnix/features/reports/model/report_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();
    final ReportController reportController = Get.find<ReportController>();

    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,
      body: Column(
        children: [
          // Appbar Header
          TopBarWidget(branchController: branchController),

          // Title and range selector
          Obx(
            () => SectionHeaderWidget(
              title: 'Reports',
              subtitle:
                  reportController.ranges[reportController.selectedRange.value],
              actionLabel: 'Export',
              actionIcon: Icons.download_outlined,
              onAction: () {},
            ),
          ),

          // Range selector
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 8,
                children: List.generate(
                  reportController.ranges.length,
                  (int index) => ReportRangeChip(
                    label: reportController.ranges[index],
                    isSelected: reportController.selectedRange.value == index,
                    onTap: () => reportController.rangeOnChanged(index),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Report cards
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: .stretch,
                spacing: 16,
                children: [
                  // Sales metrics
                  Obx(
                    () => GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 260,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2.1,
                          ),
                      itemCount: reportController.salesReport.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ReportEntry entry =
                            reportController.salesReport[index];
                        return ReportMetricCard(entry: entry);
                      },
                    ),
                  ),

                  // Top selling items
                  Obx(
                    () => CustomContainerWidget(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: .stretch,
                          children: [
                            const Text(
                              'Top Selling Items',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white,
                              ),
                            ),

                            const SizedBox(height: 12),

                            ...reportController.topSellingItems.map(
                              (TopSellingItem item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      child: Text(
                                        '${reportController.topSellingItems.indexOf(item) + 1}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.amber,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.tablePrimaryText,
                                        ),
                                      ),
                                    ),

                                    Text(
                                      '${item.quantitySold} sold',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.tableHeaderText,
                                      ),
                                    ),

                                    const SizedBox(width: 20),

                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        formatTaka(item.revenue),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.badgeAmberText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Staff performance
                  Obx(
                    () => CustomContainerWidget(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: .stretch,
                          children: [
                            const Text(
                              'Staff Performance',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white,
                              ),
                            ),

                            const SizedBox(height: 12),

                            ...reportController.staffPerformance.map(
                              (ReportEntry entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      entry.icon,
                                      style: const TextStyle(fontSize: 16),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Text(
                                        entry.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.tablePrimaryText,
                                        ),
                                      ),
                                    ),

                                    Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.badgeAmberText,
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    _ChangeLabel(
                                      changePercent: entry.changePercent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Metric card of the sales report
class ReportMetricCard extends StatelessWidget {
  const ReportMetricCard({super.key, required this.entry});

  final ReportEntry entry;

  @override
  Widget build(BuildContext context) {
    return CustomContainerWidget(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // icon
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(entry.icon, style: const TextStyle(fontSize: 16)),
            ),

            const SizedBox(width: 12),

            // label, value and change
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.lightAmberWhite.withValues(alpha: 0.6),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.white,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      _ChangeLabel(changePercent: entry.changePercent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Green or red percentage against the previous period
class _ChangeLabel extends StatelessWidget {
  const _ChangeLabel({required this.changePercent});

  final double changePercent;

  @override
  Widget build(BuildContext context) {
    final bool isUp = changePercent >= 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        Icon(
          isUp ? Icons.trending_up : Icons.trending_down,
          size: 12,
          color: isUp ? AppTheme.lightGreen : AppTheme.dangerRed,
        ),

        Text(
          '${isUp ? '+' : ''}$changePercent%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isUp ? AppTheme.lightGreen : AppTheme.dangerRed,
          ),
        ),
      ],
    );
  }
}

// Small range chip of the report header
class ReportRangeChip extends StatelessWidget {
  const ReportRangeChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.amber : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? AppTheme.amber
                  : AppTheme.lightAmberWhite.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppTheme.windowWidgetBackgroundBlack
                  : AppTheme.lightAmberWhite,
            ),
          ),
        ),
      ),
    );
  }
}
