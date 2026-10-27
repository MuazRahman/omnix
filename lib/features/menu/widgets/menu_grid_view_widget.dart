import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';
import 'package:omnix/features/menu/widgets/menu_availability_toggle_widget.dart';
import 'package:omnix/features/menu/widgets/menu_dish_actions_menu_widget.dart';
import 'package:omnix/features/menu/widgets/menu_item_image_widget.dart';
import 'package:omnix/features/menu/widgets/menu_pagination_footer_widget.dart';

/// Card view of the catalog, toggled from the toolbar.
class MenuGridViewWidget extends StatelessWidget {
  const MenuGridViewWidget({
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<MenuItem> items = controller.pagedItems;

      return Column(
        crossAxisAlignment: .stretch,
        children: [
          if (items.isEmpty)
            const _EmptyGridState()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 310,
                mainAxisExtent: 262,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (BuildContext context, int index) {
                final MenuItem item = items[index];

                return _DishGridCard(
                  item: item,
                  onEdit: () => onEdit(item),
                  onDuplicate: () => onDuplicate(item),
                  onArchive: () => onArchive(item),
                  onRestock: () => onToggleAvailability(item),
                  onToggleAvailability: () => onToggleAvailability(item),
                );
              },
            ),
          const SizedBox(height: 12),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
                width: 0.6,
              ),
            ),
            child: MenuPaginationFooter(controller: controller),
          ),
        ],
      );
    });
  }
}

class _DishGridCard extends StatelessWidget {
  const _DishGridCard({
    required this.item,
    required this.onEdit,
    required this.onDuplicate,
    required this.onArchive,
    required this.onRestock,
    required this.onToggleAvailability,
  });

  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onArchive;
  final VoidCallback onRestock;
  final VoidCallback onToggleAvailability;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = item.isAvailable
        ? (item.isLowStock
              ? AppTheme.amber.withValues(alpha: 0.5)
              : AppTheme.lightAmberWhite.withValues(alpha: 0.14))
        : AppTheme.lightAmberWhite.withValues(alpha: 0.08);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          SizedBox(
            height: 108,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: item.isAvailable ? 1 : 0.42,
                  child: MenuItemImageWidget(
                    imageUrl: item.imageUrl,
                    imageBytes: item.imageBytes,
                  ),
                ),
                if (!item.isAvailable)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    alignment: Alignment.center,
                    child: const Text(
                      'SOLD OUT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppTheme.dangerRedLight,
                      ),
                    ),
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x44000000), Colors.transparent],
                      stops: [0, 0.55],
                    ),
                  ),
                ),
                Positioned(top: 8, left: 8, child: _PhotoTag(label: item.id)),
                if (item.isBestseller)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: _PhotoTag(
                      label: 'BESTSELLER',
                      color: AppTheme.lightGreen,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Row(
                    crossAxisAlignment: .start,
                    spacing: 4,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.tablePrimaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.banglaName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.tableHeaderText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MenuDishActionsMenu(
                        item: item,
                        onEdit: onEdit,
                        onDuplicate: onDuplicate,
                        onArchive: onArchive,
                        onRestock: onRestock,
                        buttonSize: 26,
                        iconSize: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    spacing: 5,
                    children: [
                      Flexible(
                        child: Text(
                          item.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.badgeNeutralText,
                          ),
                        ),
                      ),
                      Text(
                        '· ${item.preparationTime} min',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.tableHeaderText,
                        ),
                      ),
                      if (item.isLowStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.amber.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'LOW',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: AppTheme.amber,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: .end,
                    children: [
                      Expanded(
                        child: Text(
                          '৳ ${formatNumber(item.price)}',
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1,
                            color: AppTheme.amber,
                          ),
                        ),
                      ),
                      Text(
                        '${item.grossMargin.toStringAsFixed(1)}%',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: item.grossMargin >= MenuController.targetMargin
                              ? AppTheme.lightGreen
                              : (item.grossMargin >= 55
                                    ? AppTheme.badgeAmberText
                                    : AppTheme.dangerRedLight),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      MenuAvailabilityToggle(
                        isAvailable: item.isAvailable,
                        showLabel: false,
                        onChanged: (bool _) => onToggleAvailability(),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.isAvailable ? 'Active' : 'Paused',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: item.isAvailable
                              ? AppTheme.lightGreen
                              : AppTheme.dangerRedLight,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '৳ ${formatNumber(item.netMargin)} net',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppTheme.tableHeaderText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTag extends StatelessWidget {
  const _PhotoTag({required this.label, this.color = AppTheme.badgeAmberText});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyGridState extends StatelessWidget {
  const _EmptyGridState();

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
            Icons.restaurant_menu_outlined,
            size: 28,
            color: AppTheme.tableHeaderText.withValues(alpha: 0.7),
          ),
          const Text(
            'No dishes match this filter',
            style: TextStyle(fontSize: 12, color: AppTheme.tableHeaderText),
          ),
        ],
      ),
    );
  }
}
