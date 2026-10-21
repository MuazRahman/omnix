import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/custom_container_widget.dart';
import 'package:omnix/features/common/widgets/data_table_widget.dart';
import 'package:omnix/features/common/widgets/section_header_widget.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';
import 'package:omnix/features/menu/widgets/menu_item_image_widget.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();
    final MenuController menuController = Get.find<MenuController>();

    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,
      body: Column(
        children: [
          // Appbar Header
          TopBarWidget(branchController: branchController),

          // Title, search and add button
          Obx(
            () => SectionHeaderWidget(
              title: 'Menu',
              subtitle:
                  '${menuController.availableCount} available · ${menuController.unavailableCount} unavailable',
              searchHint: 'Search menu items',
              onSearchChanged: menuController.searchOnChanged,
              actionLabel: 'Add Item',
              actionIcon: Icons.add,
              onAction: () {},
            ),
          ),

          // Category filter
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 8,
                children: List.generate(
                  menuController.categories.length,
                  (int index) => MenuCategoryChip(
                    label: menuController.categories[index],
                    isSelected: menuController.selectedCategory.value == index,
                    onTap: () => menuController.categoryOnChanged(index),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Menu table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomContainerWidget(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Obx(() {
                    final List<MenuItem> items = menuController.filteredItems;

                    return DataTableWidget(
                      columns: const [
                        DataTableColumn(label: 'Item', flex: 232),
                        DataTableColumn(label: 'Category', flex: 150),
                        DataTableColumn(label: 'Prep Time', flex: 129),
                        DataTableColumn(label: 'Status', flex: 150),
                        DataTableColumn(
                          label: 'Price',
                          flex: 111,
                          alignRight: true,
                          monospace: true,
                        ),
                      ],
                      rows: items
                          .map(
                            (MenuItem item) =>
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

  List<Widget> buildCells(MenuItem item) {
    return [
      // dish photo plus name, mirrors the POS tiles
      Row(
        spacing: 10,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              width: 34,
              height: 34,
              child: MenuItemImageWidget(imageUrl: item.imageUrl),
            ),
          ),
          Expanded(
            child: DataTableWidget.text(
              item.name,
              color: AppTheme.badgeAmberText,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
      DataTableWidget.text(item.category, weight: FontWeight.w500),
      DataTableWidget.text(
        '${item.preparationTime} min',
        color: AppTheme.tableHeaderText,
      ),
      StatusPillWidget(
        label: item.isAvailable ? 'Available' : 'Unavailable',
        tone: item.isAvailable ? PillTone.green : PillTone.neutral,
      ),
      DataTableWidget.text(
        '৳${formatNumber(item.price)}',
        weight: FontWeight.w700,
        monospace: true,
      ),
    ];
  }
}

// Small category chip used above the table
class MenuCategoryChip extends StatelessWidget {
  const MenuCategoryChip({
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
