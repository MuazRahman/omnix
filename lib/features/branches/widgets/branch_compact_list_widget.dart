import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/model/branch_model.dart';
import 'package:omnix/features/common/widgets/data_table_widget.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';

/// Compact table view of the branch network.
class BranchCompactListWidget extends StatelessWidget {
  const BranchCompactListWidget({
    super.key,
    required this.branches,
    required this.onSwitch,
    required this.onEdit,
    required this.onToggleActive,
  });

  final List<Branch> branches;
  final ValueChanged<Branch> onSwitch;
  final ValueChanged<Branch> onEdit;
  final ValueChanged<Branch> onToggleActive;

  @override
  Widget build(BuildContext context) {
    // DataTableWidget draws its own bounded body, so give it an exact height.
    final double height = 39 + (branches.isEmpty ? 2 : branches.length) * 52;

    // Keep the columns readable on narrow windows by scrolling sideways
    // instead of squeezing every cell.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double minTableWidth = 1080;
        final double tableWidth = constraints.maxWidth < minTableWidth
            ? minTableWidth
            : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            height: height,
            child: DataTableWidget(
              columns: const [
                DataTableColumn(label: 'Branch', flex: 200),
                DataTableColumn(label: 'Manager', flex: 150),
                DataTableColumn(label: 'Area', flex: 170),
                DataTableColumn(label: 'Revenue', flex: 120, alignRight: true),
                DataTableColumn(label: 'Orders', flex: 90, alignRight: true),
                DataTableColumn(label: 'Inventory', flex: 110),
                DataTableColumn(label: 'Status', flex: 110),
                DataTableColumn(label: 'Actions', flex: 150, alignRight: true),
              ],
              rows: branches
                  .map(
                    (Branch branch) => DataTableRow(cells: _buildCells(branch)),
                  )
                  .toList(),
              emptyMessage: 'No branches match the search',
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCells(Branch branch) {
    return [
      Row(
        spacing: 8,
        children: [
          Container(
            width: 4,
            height: 26,
            decoration: BoxDecoration(
              color: branch.isCurrent
                  ? AppTheme.amber
                  : (branch.isActive
                        ? AppTheme.lightGreen
                        : AppTheme.badgeNeutralBackground),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.badgeAmberText,
                  ),
                ),
                Text(
                  branch.id,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      DataTableWidget.text(branch.manager, fontSize: 13),
      DataTableWidget.text(branch.area, color: AppTheme.tableHeaderText),
      DataTableWidget.text(
        formatTakaSymbol(branch.todayRevenue),
        weight: FontWeight.w700,
        monospace: true,
      ),
      DataTableWidget.text(
        '${branch.todayOrders}',
        monospace: true,
        weight: FontWeight.w600,
      ),
      _InventoryCell(health: branch.inventoryHealth),
      StatusPillWidget(
        label: branch.isCurrent
            ? 'Operating'
            : (branch.isActive ? 'Active' : 'Inactive'),
        tone: branch.isCurrent
            ? PillTone.amber
            : (branch.isActive ? PillTone.green : PillTone.neutral),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (branch.isActive && !branch.isCurrent)
            _IconAction(
              icon: Icons.sync_alt,
              tooltip: 'Switch to this branch',
              color: AppTheme.badgeAmberText,
              onTap: () => onSwitch(branch),
            ),
          _IconAction(
            icon: Icons.edit_outlined,
            tooltip: 'Edit details',
            onTap: () => onEdit(branch),
          ),
          _IconAction(
            icon: branch.isActive
                ? Icons.pause_circle_outline
                : Icons.play_circle_outline,
            tooltip: branch.isActive ? 'Deactivate' : 'Activate',
            color: branch.isActive
                ? AppTheme.dangerRedLight
                : AppTheme.lightGreen,
            onTap: () => onToggleActive(branch),
          ),
        ],
      ),
    ];
  }
}

class _InventoryCell extends StatelessWidget {
  const _InventoryCell({required this.health});

  final double health;

  @override
  Widget build(BuildContext context) {
    final Color color = health >= 85
        ? AppTheme.lightGreen
        : (health >= 75 ? AppTheme.amber : AppTheme.dangerRedLight);

    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 6,
              color: AppTheme.badgeNeutralBackground.withValues(alpha: 0.5),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: (health / 100).clamp(0.0, 1.0).toDouble(),
                child: Container(color: color),
              ),
            ),
          ),
        ),
        Text(
          '${health.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = AppTheme.tableHeaderText,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: AppTheme.amber.withValues(alpha: 0.12),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}
