import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';
import 'package:omnix/features/menu/widgets/menu_category_chip_widget.dart';

/// Category chips plus the search / sort / view toolbar of the menu catalog.
class MenuFilterBarWidget extends StatefulWidget {
  const MenuFilterBarWidget({
    super.key,
    required this.controller,
    required this.branchController,
    required this.onManageCategories,
  });

  final MenuController controller;
  final BranchController branchController;
  final VoidCallback onManageCategories;

  @override
  State<MenuFilterBarWidget> createState() => _MenuFilterBarWidgetState();
}

class _MenuFilterBarWidgetState extends State<MenuFilterBarWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MenuController controller = widget.controller;

    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(14),
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
            _buildCategoryRow(controller),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 12),
            _buildToolbar(controller),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryRow(MenuController controller) {
    final Widget chips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: List.generate(controller.categories.length, (int index) {
          final String category = controller.categories[index];

          return MenuCategoryChip(
            label:
                '${category == 'All' ? 'All Items' : category} '
                '(${controller.countForCategory(category)})',
            isSelected: controller.selectedCategory.value == index,
            onTap: () => controller.categoryOnChanged(index),
          );
        }),
      ),
    );

    final Widget manageButton = TextButton.icon(
      onPressed: widget.onManageCategories,
      icon: const Icon(Icons.add_circle_outline, size: 15),
      label: const Text('MANAGE CATEGORIES'),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.amber,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        textStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 820) {
          return Row(
            children: [
              Expanded(child: chips),
              const SizedBox(width: 12),
              manageButton,
            ],
          );
        }

        return Column(
          crossAxisAlignment: .start,
          children: [
            chips,
            const SizedBox(height: 6),
            Align(alignment: .centerRight, child: manageButton),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(MenuController controller) {
    final Widget search = _buildSearchField(controller);
    final Widget branch = _buildBranchChip();
    final Widget sort = _buildSortDropdown(controller);
    final Widget viewToggle = _buildViewToggle(controller);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            spacing: 8,
            children: [
              Expanded(child: search),
              branch,
              sort,
              viewToggle,
            ],
          );
        }

        return Column(
          crossAxisAlignment: .stretch,
          children: [
            search,
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [branch, sort, viewToggle],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField(MenuController controller) {
    return SizedBox(
      height: 38,
      child: TextField(
        key: const Key('menu-search-field'),
        controller: _searchController,
        onChanged: (String value) {
          controller.searchOnChanged(value);
          setState(() {});
        },
        style: const TextStyle(fontSize: 12, color: AppTheme.tablePrimaryText),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.windowWidgetBackgroundBlack,
          prefixIcon: Icon(
            Icons.search,
            size: 17,
            color: AppTheme.tableHeaderText.withValues(alpha: 0.85),
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    controller.searchOnChanged('');
                    setState(() {});
                  },
                  icon: const Icon(Icons.close, size: 15),
                  color: AppTheme.tableHeaderText,
                ),
          hintText: 'Filter by dish title, Bangla name, or code...',
          hintStyle: TextStyle(
            fontSize: 12,
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.35),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: _inputBorder(
            AppTheme.lightAmberWhite.withValues(alpha: 0.16),
          ),
          enabledBorder: _inputBorder(
            AppTheme.lightAmberWhite.withValues(alpha: 0.16),
          ),
          focusedBorder: _inputBorder(AppTheme.amber.withValues(alpha: 0.55)),
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 0.6),
    );
  }

  Widget _buildBranchChip() {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.branchController.selectedBranch,
      builder: (BuildContext context, String? selected, Widget? child) {
        return PopupMenuButton<String>(
          tooltip: 'Select branch',
          color: AppTheme.sidebarBackgroundBlack,
          onSelected: widget.branchController.branchOnChanged,
          itemBuilder: (BuildContext context) {
            return widget.branchController.branches.map((String branch) {
              final bool isSelected = branch == selected;

              return PopupMenuItem<String>(
                value: branch,
                height: 40,
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.storefront_outlined,
                      size: 16,
                      color: isSelected
                          ? AppTheme.amber
                          : AppTheme.tableHeaderText,
                    ),
                    Expanded(
                      child: Text(
                        branch,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? AppTheme.badgeAmberText
                              : AppTheme.tablePrimaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          child: _ToolbarChip(
            icon: Icons.storefront_outlined,
            label: selected ?? 'Select branch',
            trailing: Icons.keyboard_arrow_down,
          ),
        );
      },
    );
  }

  Widget _buildSortDropdown(MenuController controller) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
          width: 0.6,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MenuSortMode>(
          value: controller.sortMode.value,
          isDense: true,
          dropdownColor: AppTheme.sidebarBackgroundBlack,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: AppTheme.tableHeaderText,
          ),
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.tablePrimaryText,
          ),
          onChanged: (MenuSortMode? value) {
            if (value != null) controller.sortOnChanged(value);
          },
          items: MenuSortMode.values.map((MenuSortMode mode) {
            return DropdownMenuItem<MenuSortMode>(
              value: mode,
              child: Row(
                spacing: 7,
                children: [
                  const Icon(
                    Icons.sort,
                    size: 14,
                    color: AppTheme.tableHeaderText,
                  ),
                  Text(mode.label),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildViewToggle(MenuController controller) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewToggleButton(
            icon: Icons.table_rows_outlined,
            tooltip: 'Table view',
            isSelected: controller.viewMode.value == MenuViewMode.table,
            onTap: () => controller.viewModeOnChanged(MenuViewMode.table),
          ),
          _ViewToggleButton(
            icon: Icons.grid_view_outlined,
            tooltip: 'Grid view',
            isSelected: controller.viewMode.value == MenuViewMode.grid,
            onTap: () => controller.viewModeOnChanged(MenuViewMode.grid),
          ),
        ],
      ),
    );
  }
}

class _ToolbarChip extends StatelessWidget {
  const _ToolbarChip({required this.icon, required this.label, this.trailing});

  final IconData icon;
  final String label;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 7,
        children: [
          Icon(icon, size: 15, color: AppTheme.tableHeaderText),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.tablePrimaryText,
              ),
            ),
          ),
          if (trailing != null)
            Icon(trailing, size: 15, color: AppTheme.tableHeaderText),
        ],
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isSelected ? AppTheme.amber : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              icon,
              size: 17,
              color: isSelected
                  ? AppTheme.windowWidgetBackgroundBlack
                  : AppTheme.tableHeaderText,
            ),
          ),
        ),
      ),
    );
  }
}
