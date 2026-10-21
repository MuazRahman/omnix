import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/custom_container_widget.dart';
import 'package:omnix/features/common/widgets/data_table_widget.dart';
import 'package:omnix/features/common/widgets/section_header_widget.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/staff/controller/staff_controller.dart';
import 'package:omnix/features/staff/dummy_data/dummy_staff_data.dart';
import 'package:omnix/features/staff/model/staff_model.dart';

class StaffSettingsScreen extends StatelessWidget {
  const StaffSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();
    final StaffController staffController = Get.find<StaffController>();

    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,
      body: Column(
        children: [
          // Appbar Header
          TopBarWidget(branchController: branchController),

          // Title, search and add button
          Obx(
            () => SectionHeaderWidget(
              title: 'Staff & Settings',
              subtitle:
                  '${staffController.staff.length} staff · ${staffController.activeCount} active',
              searchHint: 'Search by name, id or branch',
              onSearchChanged: staffController.searchOnChanged,
              actionLabel: 'Add Staff',
              actionIcon: Icons.person_add_alt,
              onAction: () {},
            ),
          ),

          // Staff table on the left, settings on the right
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 16,
                children: [
                  // Staff list
                  Expanded(
                    flex: 3,
                    child: CustomContainerWidget(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Obx(() {
                          final List<Staff> staff =
                              staffController.filteredStaff;

                          return DataTableWidget(
                            columns: const [
                              DataTableColumn(label: 'Name', flex: 200),
                              DataTableColumn(label: 'Role', flex: 129),
                              DataTableColumn(label: 'Branch', flex: 232),
                              DataTableColumn(
                                label: 'Phone',
                                flex: 129,
                                monospace: true,
                              ),
                              DataTableColumn(label: 'Status', flex: 111),
                            ],
                            rows: staff
                                .map(
                                  (Staff member) =>
                                      DataTableRow(cells: buildCells(member)),
                                )
                                .toList(),
                            emptyMessage: 'No staff match the search',
                          );
                        }),
                      ),
                    ),
                  ),

                  // Settings
                  Expanded(
                    flex: 2,
                    child: CustomContainerWidget(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: .stretch,
                          children: [
                            const Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Expanded(
                              child: Obx(
                                () => ListView.separated(
                                  itemCount: staffController.settings.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const Divider(
                                            height: 24,
                                            color: AppTheme.tableDivider,
                                          ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        final SettingToggle setting =
                                            staffController.settings[index];
                                        return _SettingRow(
                                          setting: setting,
                                          onChanged: () => staffController
                                              .toggleSetting(index),
                                        );
                                      },
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

  List<Widget> buildCells(Staff member) {
    return [
      DataTableWidget.text(
        member.name,
        color: AppTheme.badgeAmberText,
        weight: FontWeight.w600,
      ),
      StatusPillWidget(
        label: _roleLabel(member.role),
        tone: _roleTone(member.role),
      ),
      DataTableWidget.text(member.branch, weight: FontWeight.w500),
      DataTableWidget.text(member.phone, color: AppTheme.tableHeaderText),
      StatusPillWidget(
        label: member.isActive ? 'Active' : 'Inactive',
        tone: member.isActive ? PillTone.green : PillTone.neutral,
      ),
    ];
  }

  String _roleLabel(StaffRole role) {
    switch (role) {
      case StaffRole.manager:
        return 'Manager';
      case StaffRole.cashier:
        return 'Cashier';
      case StaffRole.chef:
        return 'Chef';
      case StaffRole.waiter:
        return 'Waiter';
    }
  }

  PillTone _roleTone(StaffRole role) {
    switch (role) {
      case StaffRole.manager:
        return PillTone.blue;
      case StaffRole.cashier:
        return PillTone.amber;
      case StaffRole.chef:
        return PillTone.green;
      case StaffRole.waiter:
        return PillTone.neutral;
    }
  }
}

// One row of the settings panel
class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.setting, required this.onChanged});

  final SettingToggle setting;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // label and description
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                setting.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.badgeAmberText,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                setting.description,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.lightAmberWhite.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // toggle
        Switch(
          value: setting.isOn,
          onChanged: (_) => onChanged(),
          activeThumbColor: AppTheme.amber,
          activeTrackColor: AppTheme.amber.withValues(alpha: 0.4),
          inactiveThumbColor: AppTheme.badgeNeutralText,
          inactiveTrackColor: AppTheme.badgeNeutralBackground,
        ),
      ],
    );
  }
}
