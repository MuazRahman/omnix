import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/branches/model/branch_model.dart';
import 'package:omnix/features/common/widgets/custom_container_widget.dart';
import 'package:omnix/features/common/widgets/data_table_widget.dart';
import 'package:omnix/features/common/widgets/section_header_widget.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();

    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,
      body: Column(
        children: [
          // Appbar Header
          TopBarWidget(branchController: branchController),

          // Title, search and add button
          Obx(
            () => SectionHeaderWidget(
              title: 'Branches',
              subtitle:
                  '${branchController.branchRecords.length} branches · ${branchController.activeCount} active',
              searchHint: 'Search by name, id or manager',
              onSearchChanged: branchController.searchOnChanged,
              actionLabel: 'Add Branch',
              actionIcon: Icons.add_business_outlined,
              onAction: () {},
            ),
          ),

          // Branch table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomContainerWidget(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Obx(() {
                    final List<Branch> branches =
                        branchController.filteredBranches;

                    return DataTableWidget(
                      columns: const [
                        DataTableColumn(label: 'Branch', flex: 200),
                        DataTableColumn(label: 'Address', flex: 232),
                        DataTableColumn(label: 'Manager', flex: 150),
                        DataTableColumn(
                          label: 'Phone',
                          flex: 129,
                          monospace: true,
                        ),
                        DataTableColumn(label: 'Since', flex: 100),
                        DataTableColumn(label: 'Status', flex: 111),
                      ],
                      rows: branches
                          .map(
                            (Branch branch) =>
                                DataTableRow(cells: buildCells(branch)),
                          )
                          .toList(),
                      emptyMessage: 'No branches match the search',
                    );
                  }),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> buildCells(Branch branch) {
    return [
      DataTableWidget.text(
        branch.name,
        color: AppTheme.badgeAmberText,
        weight: FontWeight.w600,
      ),
      DataTableWidget.text(branch.address, weight: FontWeight.w400),
      DataTableWidget.text(branch.manager, weight: FontWeight.w500),
      DataTableWidget.text(branch.phone, color: AppTheme.tableHeaderText),
      DataTableWidget.text(branch.openedAt, color: AppTheme.tableHeaderText),
      StatusPillWidget(
        label: branch.isActive ? 'Active' : 'Inactive',
        tone: branch.isActive ? PillTone.green : PillTone.neutral,
      ),
    ];
  }
}
