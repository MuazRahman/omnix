import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/common/widgets/data_table_widget.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';
import 'package:omnix/features/menu/widgets/menu_availability_toggle_widget.dart';
import 'package:omnix/features/menu/widgets/menu_dish_actions_menu_widget.dart';
import 'package:omnix/features/menu/widgets/menu_item_image_widget.dart';
import 'package:omnix/features/menu/widgets/menu_pagination_footer_widget.dart';

/// Catalog table with responsive columns and a pagination footer.
class MenuTableWidget extends StatelessWidget {
  const MenuTableWidget({
    super.key,
    required this.controller,
    required this.onEdit,
    required this.onDuplicate,
    required this.onArchive,
    required this.onToggleAvailability,
  });

  final MenuController controller;
  final ValueChanged<MenuItem> onEdit;
  final ValueChanged<MenuItem> onDuplicate;
  final ValueChanged<MenuItem> onArchive;
  final ValueChanged<MenuItem> onToggleAvailability;

  static const double _rowHeight = 68;

  @override
  Widget build(BuildContext context) {
    // The table reads filters, sorting and paging from the controller, so the
    // whole card rebuilds whenever any of those reactive values change.
    return Obx(() {
      // Read the reactive state here, not inside LayoutBuilder: an Obx only
      // tracks observables touched during its own build callback.
      final List<MenuItem> items = controller.pagedItems;

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final _MenuTableLayout layout = constraints.maxWidth >= 1180
              ? _MenuTableLayout.full
              : (constraints.maxWidth >= 900
                    ? _MenuTableLayout.compact
                    : _MenuTableLayout.narrow);

          final double tableHeight = items.isEmpty
              ? 170
              : 39 + (items.length * _rowHeight);

          return Container(
            clipBehavior: Clip.antiAlias,
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
              children: [
                SizedBox(
                  height: tableHeight,
                  child: DataTableWidget(
                    columns: _buildColumns(layout),
                    rows: items
                        .map(
                          (MenuItem item) =>
                              DataTableRow(cells: _buildCells(item, layout)),
                        )
                        .toList(),
                    rowHeight: _rowHeight,
                    emptyMessage: 'No dishes match this filter',
                  ),
                ),
                MenuPaginationFooter(controller: controller),
              ],
            ),
          );
        },
      );
    });
  }

  List<DataTableColumn> _buildColumns(_MenuTableLayout layout) {
    switch (layout) {
      case _MenuTableLayout.full:
        return const [
          DataTableColumn(label: 'Dish & Bangla Alias', flex: 280),
          DataTableColumn(label: 'Category', flex: 120),
          DataTableColumn(label: 'Selling Price', flex: 100, alignRight: true),
          DataTableColumn(label: 'Recipe Cost', flex: 90, alignRight: true),
          DataTableColumn(label: 'Gross Margin', flex: 105, alignRight: true),
          DataTableColumn(label: 'Modifiers / Options', flex: 175),
          DataTableColumn(label: 'Kitchen Status', flex: 120),
          DataTableColumn(label: 'Actions', flex: 120, alignRight: true),
        ];
      case _MenuTableLayout.compact:
        return const [
          DataTableColumn(label: 'Dish & Bangla Alias', flex: 300),
          DataTableColumn(label: 'Category', flex: 120),
          DataTableColumn(label: 'Selling Price', flex: 100, alignRight: true),
          DataTableColumn(label: 'Gross Margin', flex: 105, alignRight: true),
          DataTableColumn(label: 'Kitchen Status', flex: 120),
          DataTableColumn(label: 'Actions', flex: 120, alignRight: true),
        ];
      case _MenuTableLayout.narrow:
        return const [
          DataTableColumn(label: 'Dish', flex: 260),
          DataTableColumn(label: 'Price', flex: 100, alignRight: true),
          DataTableColumn(label: 'Status', flex: 120),
          DataTableColumn(label: 'Actions', flex: 100, alignRight: true),
        ];
    }
  }

  List<Widget> _buildCells(MenuItem item, _MenuTableLayout layout) {
    final Widget dish = _DishCell(item: item);
    final Widget category = _CategoryPill(label: item.category);
    final Widget price = DataTableWidget.text(
      '৳ ${formatNumber(item.price)}',
      weight: FontWeight.w700,
      fontSize: 13,
    );
    final Widget cost = DataTableWidget.text(
      '৳ ${formatNumber(item.recipeCost)}',
      color: AppTheme.badgeNeutralText,
      fontSize: 12,
    );
    final Widget margin = _MarginCell(item: item);
    final Widget modifiers = _ModifierCell(item: item);
    final Widget status = MenuAvailabilityToggle(
      isAvailable: item.isAvailable,
      onChanged: (bool _) => onToggleAvailability(item),
    );
    final Widget actions = _MenuRowActions(
      item: item,
      isCompact: layout == _MenuTableLayout.narrow,
      onEdit: () => onEdit(item),
      onDuplicate: () => onDuplicate(item),
      onArchive: () => onArchive(item),
      onRestock: () => onToggleAvailability(item),
    );

    switch (layout) {
      case _MenuTableLayout.full:
        return [
          dish,
          category,
          price,
          cost,
          margin,
          modifiers,
          status,
          actions,
        ];
      case _MenuTableLayout.compact:
        return [dish, category, price, margin, status, actions];
      case _MenuTableLayout.narrow:
        return [dish, price, status, actions];
    }
  }
}

enum _MenuTableLayout { full, compact, narrow }

class _DishCell extends StatelessWidget {
  const _DishCell({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        _DishThumb(item: item),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                spacing: 5,
                children: [
                  Flexible(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.badgeAmberText,
                      ),
                    ),
                  ),
                  if (item.isBestseller)
                    const _TinyTag(
                      label: 'BESTSELLER',
                      color: AppTheme.lightGreen,
                    ),
                  if (item.isLowStock)
                    const _TinyTag(label: 'LOW', color: AppTheme.amber),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                '${item.banglaName} · ${item.preparationTime} min',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.tableHeaderText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DishThumb extends StatelessWidget {
  const _DishThumb({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: SizedBox(
        width: 46,
        height: 46,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: item.isAvailable ? 1 : 0.4,
              child: MenuItemImageWidget(
                imageUrl: item.imageUrl,
                imageBytes: item.imageBytes,
              ),
            ),
            if (!item.isAvailable)
              Container(
                color: Colors.black.withValues(alpha: 0.45),
                alignment: Alignment.center,
                child: const Text(
                  'OUT',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.dangerRedLight,
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                  ),
                ),
                child: Text(
                  item.id,
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.badgeAmberText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.badgeNeutralBackground.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.badgeNeutralText,
        ),
      ),
    );
  }
}

class _MarginCell extends StatelessWidget {
  const _MarginCell({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final double margin = item.grossMargin;
    final Color color = margin >= MenuController.targetMargin
        ? AppTheme.lightGreen
        : (margin >= 55 ? AppTheme.badgeAmberText : AppTheme.dangerRedLight);

    return Column(
      crossAxisAlignment: .end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${margin.toStringAsFixed(1)}%',
          maxLines: 1,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          '৳ ${formatNumber(item.netMargin)} net',
          maxLines: 1,
          style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}

class _ModifierCell extends StatelessWidget {
  const _ModifierCell({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.badgeNeutralBackground.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${item.modifierCount} opt',
            maxLines: 1,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.tablePrimaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            item.modifierSummary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ),
      ],
    );
  }
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}

class _MenuRowActions extends StatelessWidget {
  const _MenuRowActions({
    required this.item,
    required this.onEdit,
    required this.onDuplicate,
    required this.onArchive,
    required this.onRestock,
    this.isCompact = false,
  });

  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onArchive;
  final VoidCallback onRestock;

  // narrow tables collapse the three actions into one overflow menu
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return MenuDishActionsMenu(
        item: item,
        onEdit: onEdit,
        onDuplicate: onDuplicate,
        onArchive: onArchive,
        onRestock: onRestock,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _MenuIconButton(
          icon: Icons.edit_outlined,
          tooltip: 'Edit dish',
          onTap: onEdit,
        ),
        _MenuIconButton(
          icon: item.isAvailable ? Icons.content_copy : Icons.restart_alt,
          tooltip: item.isAvailable ? 'Duplicate dish' : 'Restock dish',
          onTap: item.isAvailable ? onDuplicate : onRestock,
          color: item.isAvailable ? null : AppTheme.amber,
        ),
        _MenuIconButton(
          icon: Icons.delete_outline,
          tooltip: 'Archive dish',
          onTap: onArchive,
          isDanger: true,
        ),
      ],
    );
  }
}

class _MenuIconButton extends StatelessWidget {
  const _MenuIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
    this.isDanger = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final Color foreground = color ?? AppTheme.tableHeaderText;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: (isDanger ? AppTheme.dangerRed : AppTheme.amber)
              .withValues(alpha: 0.12),
          child: SizedBox(
            width: 29,
            height: 29,
            child: Icon(icon, size: 16, color: foreground),
          ),
        ),
      ),
    );
  }
}
