import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/category_manager_dialog_widget.dart';
import 'package:omnix/features/common/widgets/custom_container_widget.dart';
import 'package:omnix/features/common/widgets/data_table_widget.dart';
import 'package:omnix/features/common/widgets/section_header_widget.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/inventory/controller/inventory_controller.dart';
import 'package:omnix/features/inventory/model/inventory_item_model.dart';
import 'package:omnix/features/inventory/widgets/inventory_add_stock_dialog_widget.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();
    final InventoryController inventoryController =
        Get.find<InventoryController>();

    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,
      body: Column(
        children: [
          // Appbar Header
          TopBarWidget(branchController: branchController),

          // Title, search and add button
          Obx(
            () => SectionHeaderWidget(
              title: 'Inventory & Stock',
              subtitle:
                  '${inventoryController.items.length} items · ${formatTaka(inventoryController.totalValue)} value',
              searchHint: 'Search stock items',
              onSearchChanged: inventoryController.searchOnChanged,
              actionLabel: 'Add Stock',
              actionIcon: Icons.add,
              onAction: () => _openAddStockDialog(context, inventoryController),
            ),
          ),

          // Summary cards
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: InventoryStatCard(
                      title: 'Low Stock',
                      value: '${inventoryController.lowStockCount}',
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppTheme.amber,
                    ),
                  ),
                  Expanded(
                    child: InventoryStatCard(
                      title: 'Out of Stock',
                      value: '${inventoryController.outOfStockCount}',
                      icon: Icons.error_outline,
                      iconColor: AppTheme.dangerRed,
                    ),
                  ),
                  Expanded(
                    child: InventoryStatCard(
                      title: 'Stock Value',
                      value: formatTaka(inventoryController.totalValue),
                      icon: Icons.savings_outlined,
                      iconColor: AppTheme.lightGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category filter
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 8,
                        children: List.generate(
                          inventoryController.categories.length,
                          (int index) => InventoryCategoryChip(
                            label: inventoryController.categories[index],
                            isSelected:
                                inventoryController.selectedCategory.value ==
                                index,
                            onTap: () =>
                                inventoryController.categoryOnChanged(index),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _ManageCategoriesButton(
                    key: const Key('inventory-manage-categories'),
                    onTap: () =>
                        _openCategoryManager(context, inventoryController),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stock table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomContainerWidget(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Obx(() {
                    final List<InventoryItem> items =
                        inventoryController.filteredItems;

                    return DataTableWidget(
                      columns: const [
                        DataTableColumn(label: 'Item', flex: 232),
                        DataTableColumn(label: 'Category', flex: 150),
                        DataTableColumn(
                          label: 'Quantity',
                          flex: 129,
                          alignRight: true,
                        ),
                        DataTableColumn(
                          label: 'Reorder At',
                          flex: 129,
                          alignRight: true,
                        ),
                        DataTableColumn(label: 'Status', flex: 150),
                        DataTableColumn(
                          label: 'Value',
                          flex: 111,
                          alignRight: true,
                          monospace: true,
                        ),
                      ],
                      rows: items
                          .map(
                            (InventoryItem item) =>
                                DataTableRow(cells: buildCells(item)),
                          )
                          .toList(),
                      emptyMessage: 'No items match the filter',
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

  // Opens the Add Stock dialog and confirms the save once the controller
  // has re-fetched the list behind it.
  Future<void> _openAddStockDialog(
    BuildContext context,
    InventoryController inventoryController,
  ) async {
    final bool? created = await showAddStockDialog(
      context,
      inventoryController,
    );

    if (created != true || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stock item added to the inventory.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Opens the category manager so stock categories can be added, renamed or
  // removed straight from the screen.
  Future<void> _openCategoryManager(
    BuildContext context,
    InventoryController inventoryController,
  ) {
    return showCategoryManagerDialog(
      context: context,
      title: 'Inventory Categories',
      subtitle: 'Add, rename or remove the categories used to file stock.',
      categories: inventoryController.categories,
      usageCount: inventoryController.categoryUsageCount,
      onCreate: inventoryController.addCategory,
      onRename: inventoryController.renameCategory,
      onDelete: inventoryController.removeCategory,
    );
  }

  List<Widget> buildCells(InventoryItem item) {
    return [
      DataTableWidget.text(
        item.name,
        color: AppTheme.badgeAmberText,
        weight: FontWeight.w600,
      ),
      DataTableWidget.text(item.category, weight: FontWeight.w500),
      DataTableWidget.text(
        '${formatQuantity(item.quantity)} ${item.unit}',
        weight: FontWeight.w600,
        monospace: true,
      ),
      DataTableWidget.text(
        '${formatQuantity(item.reorderLevel)} ${item.unit}',
        color: AppTheme.tableHeaderText,
        monospace: true,
      ),
      StatusPillWidget(
        label: _levelLabel(item.level),
        tone: _levelTone(item.level),
      ),
      DataTableWidget.text(
        '৳${formatNumber(item.totalValue)}',
        weight: FontWeight.w700,
        monospace: true,
      ),
    ];
  }

  String _levelLabel(StockLevel level) {
    switch (level) {
      case StockLevel.inStock:
        return 'In Stock';
      case StockLevel.lowStock:
        return 'Low Stock';
      case StockLevel.outOfStock:
        return 'Out of Stock';
    }
  }

  PillTone _levelTone(StockLevel level) {
    switch (level) {
      case StockLevel.inStock:
        return PillTone.green;
      case StockLevel.lowStock:
        return PillTone.amber;
      case StockLevel.outOfStock:
        return PillTone.red;
    }
  }
}

// Small summary card shown above the stock table
class InventoryStatCard extends StatelessWidget {
  const InventoryStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return CustomContainerWidget(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: .start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.lightAmberWhite.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
              ],
            ),

            const Spacer(),

            Icon(icon, color: iconColor, size: 24),
          ],
        ),
      ),
    );
  }
}

// Chip-styled button that opens the category manager from the filter row
class _ManageCategoriesButton extends StatelessWidget {
  const _ManageCategoriesButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        hoverColor: AppTheme.amber.withValues(alpha: 0.1),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppTheme.amber.withValues(alpha: 0.5),
              width: 0.8,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(Icons.tune, size: 14, color: AppTheme.amber),
              Text(
                'Manage',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.amber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small category chip used above the table
class InventoryCategoryChip extends StatelessWidget {
  const InventoryCategoryChip({
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
