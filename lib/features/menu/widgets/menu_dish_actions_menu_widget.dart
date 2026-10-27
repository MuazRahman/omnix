import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';

/// Overflow menu with the per-dish actions, used by the compact table and grid.
class MenuDishActionsMenu extends StatelessWidget {
  const MenuDishActionsMenu({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDuplicate,
    required this.onArchive,
    required this.onRestock,
    this.buttonSize = 30,
    this.iconSize = 17,
  });

  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onArchive;
  final VoidCallback onRestock;
  final double buttonSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Dish actions',
      color: AppTheme.sidebarBackgroundBlack,
      padding: EdgeInsets.zero,
      onSelected: (String value) {
        switch (value) {
          case 'edit':
            onEdit();
          case 'duplicate':
            onDuplicate();
          case 'restock':
            onRestock();
          case 'archive':
            onArchive();
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          _actionItem('edit', Icons.edit_outlined, 'Edit dish'),
          if (item.isAvailable)
            _actionItem('duplicate', Icons.content_copy, 'Duplicate dish')
          else
            _actionItem('restock', Icons.restart_alt, 'Restock dish'),
          _actionItem(
            'archive',
            Icons.delete_outline,
            'Archive dish',
            isDanger: true,
          ),
        ];
      },
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: Icon(
          Icons.more_vert,
          size: iconSize,
          color: AppTheme.tableHeaderText,
        ),
      ),
    );
  }

  PopupMenuItem<String> _actionItem(
    String value,
    IconData icon,
    String label, {
    bool isDanger = false,
  }) {
    final Color color = isDanger
        ? AppTheme.dangerRedLight
        : AppTheme.tablePrimaryText;

    return PopupMenuItem<String>(
      value: value,
      height: 38,
      child: Row(
        spacing: 8,
        children: [
          Icon(icon, size: 16, color: color),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
