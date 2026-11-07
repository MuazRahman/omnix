import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/branches/model/branch_model.dart';
import 'package:omnix/features/branches/widgets/branch_add_dialog_widget.dart';
import 'package:omnix/features/branches/widgets/branch_card_widget.dart';
import 'package:omnix/features/branches/widgets/branch_compact_list_widget.dart';
import 'package:omnix/features/branches/widgets/branch_header_widget.dart';
import 'package:omnix/features/branches/widgets/branch_network_chart_widget.dart';
import 'package:omnix/features/branches/widgets/branch_overview_banner_widget.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();

    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            // Global app bar
            TopBarWidget(branchController: branchController),

            // Breadcrumb, title, search, view toggle and add action
            BranchHeaderWidget(
              controller: branchController,
              onAddBranch: () => _openBranchDialog(context, branchController),
            ),

            const SizedBox(height: 12),

            // Consolidated network overview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BranchOverviewBannerWidget(controller: branchController),
            ),

            const SizedBox(height: 16),

            // Branch cards or compact table
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final List<Branch> branches = branchController.filteredBranches;

                if (branchController.viewMode.value == BranchViewMode.compact) {
                  return BranchCompactListWidget(
                    branches: branches,
                    onSwitch: branchController.switchToBranch,
                    onEdit: (Branch branch) =>
                        _openBranchDialog(context, branchController, branch),
                    onToggleActive: branchController.toggleBranchActive,
                  );
                }

                return _buildBranchGrid(context, branchController, branches);
              }),
            ),

            const SizedBox(height: 16),

            // Cross-branch throughput chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BranchNetworkChartWidget(controller: branchController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchGrid(
    BuildContext context,
    BranchController controller,
    List<Branch> branches,
  ) {
    if (branches.isEmpty) {
      return const _EmptyBranchState();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = 12;
        final int columns = constraints.maxWidth >= 1180
            ? 3
            : (constraints.maxWidth >= 760 ? 2 : 1);
        final double width =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: branches
              .map(
                (Branch branch) => SizedBox(
                  width: width,
                  child: BranchCardWidget(
                    branch: branch,
                    onSwitch: () => controller.switchToBranch(branch),
                    onEdit: () =>
                        _openBranchDialog(context, controller, branch),
                    onToggleActive: () => controller.toggleBranchActive(branch),
                    onStaff: () => controller.showComingSoon(
                      'Staff assignment for ${branch.name}',
                    ),
                    onConfig: () => controller.showComingSoon(
                      'Terminal configuration for ${branch.name}',
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Future<void> _openBranchDialog(
    BuildContext context,
    BranchController controller, [
    Branch? branch,
  ]) {
    return showBranchDialog(context, controller, branch: branch);
  }
}

class _EmptyBranchState extends StatelessWidget {
  const _EmptyBranchState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
          width: 0.6,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 28,
            color: AppTheme.tableHeaderText.withValues(alpha: 0.7),
          ),
          const Text(
            'No branches match the search',
            style: TextStyle(fontSize: 12, color: AppTheme.tableHeaderText),
          ),
        ],
      ),
    );
  }
}
