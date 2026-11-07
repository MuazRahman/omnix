import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';

/// Title block plus the search / view / add toolbar of the Branches section.
class BranchHeaderWidget extends StatelessWidget {
  const BranchHeaderWidget({
    super.key,
    required this.controller,
    required this.onAddBranch,
  });

  final BranchController controller;
  final VoidCallback onAddBranch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          _buildTitleBlock(),
          const SizedBox(height: 14),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          spacing: 6,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'HOSPITALITY CLUSTER',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppTheme.amber,
                ),
              ),
            ),
            Text(
              '/',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.tableHeaderText.withValues(alpha: 0.7),
              ),
            ),
            const Flexible(
              child: Text(
                'SULTANS DINE ENTERPRISE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: AppTheme.tableHeaderText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Branch Management',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 1.15,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Manage outlets, assign branch managers, and track multi-location '
          'sales & inventory throughput in real-time.',
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    final Widget search = _BranchSearchField(controller: controller);
    final Widget toggle = _BranchViewToggle(controller: controller);
    final Widget addButton = _AddBranchButton(onTap: onAddBranch);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 820) {
          return Row(
            spacing: 10,
            children: [
              Expanded(child: search),
              toggle,
              addButton,
            ],
          );
        }

        return Column(
          crossAxisAlignment: .stretch,
          children: [
            search,
            const SizedBox(height: 10),
            Row(children: [toggle, const Spacer(), addButton]),
          ],
        );
      },
    );
  }
}

class _BranchSearchField extends StatefulWidget {
  const _BranchSearchField({required this.controller});

  final BranchController controller;

  @override
  State<_BranchSearchField> createState() => _BranchSearchFieldState();
}

class _BranchSearchFieldState extends State<_BranchSearchField> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        key: const Key('branch-search-field'),
        controller: _searchController,
        onChanged: (String value) {
          widget.controller.searchOnChanged(value);
          setState(() {});
        },
        style: const TextStyle(fontSize: 12, color: AppTheme.tablePrimaryText),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.windowWidgetBackgroundBlack,
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: AppTheme.tableHeaderText.withValues(alpha: 0.85),
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    widget.controller.searchOnChanged('');
                    setState(() {});
                  },
                  icon: const Icon(Icons.close, size: 15),
                  color: AppTheme.tableHeaderText,
                ),
          hintText: 'Search branch name, code or manager...',
          hintStyle: TextStyle(
            fontSize: 12,
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.35),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: _border(AppTheme.lightAmberWhite.withValues(alpha: 0.16)),
          enabledBorder: _border(
            AppTheme.lightAmberWhite.withValues(alpha: 0.16),
          ),
          focusedBorder: _border(AppTheme.amber.withValues(alpha: 0.55)),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 0.6),
    );
  }
}

class _BranchViewToggle extends StatelessWidget {
  const _BranchViewToggle({required this.controller});

  final BranchController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: 40,
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
              icon: Icons.grid_view_outlined,
              tooltip: 'Grid view',
              isSelected: controller.viewMode.value == BranchViewMode.grid,
              onTap: () => controller.viewModeOnChanged(BranchViewMode.grid),
            ),
            _ViewToggleButton(
              icon: Icons.view_list_outlined,
              tooltip: 'Compact view',
              isSelected: controller.viewMode.value == BranchViewMode.compact,
              onTap: () => controller.viewModeOnChanged(BranchViewMode.compact),
            ),
          ],
        ),
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
            width: 34,
            height: 34,
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

class _AddBranchButton extends StatelessWidget {
  const _AddBranchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.amber,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.deepAmberWhite,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.amber, width: 0.6),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(
                Icons.add_business_outlined,
                size: 17,
                color: AppTheme.windowWidgetBackgroundBlack,
              ),
              Text(
                'Add New Branch',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.windowWidgetBackgroundBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
