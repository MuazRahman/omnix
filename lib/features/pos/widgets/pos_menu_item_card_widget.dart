import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';

/// One dish tile of the POS menu grid.
class PosMenuItemCardWidget extends StatelessWidget {
  const PosMenuItemCardWidget({
    super.key,
    required this.item,
    required this.quantityInCart,
    required this.onAdd,
  });

  final MenuItem item;
  final int quantityInCart;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = item.isAvailable;
    final bool isInCart = quantityInCart > 0;

    return Opacity(
      opacity: isAvailable ? 1 : 0.55,
      child: Material(
        color: AppTheme.windowWidgetBackgroundBlack,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isInCart
                ? AppTheme.amber.withValues(alpha: 0.65)
                : AppTheme.lightAmberWhite.withValues(alpha: 0.12),
            width: isInCart ? 1 : 0.6,
          ),
        ),
        child: InkWell(
          onTap: isAvailable ? onAdd : null,
          hoverColor: AppTheme.amber.withValues(alpha: 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildThumbnail(isAvailable, isInCart),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: isAvailable
                              ? AppTheme.badgeAmberText
                              : AppTheme.tableHeaderText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.category} · ${item.preparationTime} min',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.tableHeaderText,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '৳ ${formatNumber(item.price)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: _AddButton(
                  isAvailable: isAvailable,
                  quantity: quantityInCart,
                  onTap: onAdd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Placeholder artwork, replaced by the real dish image once the API has one
  Widget _buildThumbnail(bool isAvailable, bool isInCart) {
    return SizedBox(
      height: 78,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.amber.withValues(alpha: 0.22),
                  AppTheme.windowWidgetBackgroundBlack,
                ],
              ),
            ),
            child: Center(
              child: Icon(
                _iconForCategory(item.category),
                size: 32,
                color: AppTheme.amber.withValues(alpha: 0.55),
              ),
            ),
          ),

          if (!isAvailable)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
              ),
              child: const Center(
                child: Text(
                  'SOLD OUT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppTheme.dangerRedLight,
                  ),
                ),
              ),
            ),

          if (isInCart)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '×$quantityInCart',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.windowWidgetBackgroundBlack,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Starters':
        return Icons.tapas;
      case 'Main Course':
        return Icons.lunch_dining;
      case 'Rice':
        return Icons.rice_bowl_outlined;
      case 'Dessert':
        return Icons.cake_outlined;
      case 'Drinks':
        return Icons.local_drink_outlined;
      default:
        return Icons.restaurant_menu;
    }
  }
}

// Add action at the bottom of the dish tile
class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.isAvailable,
    required this.quantity,
    required this.onTap,
  });

  final bool isAvailable;
  final int quantity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isInCart = quantity > 0;
    final Color background = isInCart
        ? AppTheme.amber
        : AppTheme.sidebarBackgroundBlack;
    final Color foreground = isInCart
        ? AppTheme.windowWidgetBackgroundBlack
        : AppTheme.lightAmberWhite;

    return Material(
      color: isAvailable ? background : AppTheme.topbarBackgroundBlack,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        hoverColor: AppTheme.amber.withValues(alpha: 0.15),
        child: SizedBox(
          height: 30,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Icon(
                  Icons.add,
                  size: 14,
                  color: isAvailable ? foreground : AppTheme.tableHeaderText,
                ),
                Text(
                  isAvailable
                      ? (isInCart ? 'Add · $quantity' : 'Add')
                      : 'Unavailable',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isAvailable ? foreground : AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
