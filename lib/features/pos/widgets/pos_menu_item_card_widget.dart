import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';
import 'package:omnix/features/menu/widgets/menu_item_image_widget.dart';

/// One dish tile of the POS menu grid.
///
/// The dish photo fills the whole tile and the details sit on a dark scrim
/// along the bottom, so the picture stays the hero of the card.
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
      opacity: isAvailable ? 1 : 0.6,
      child: Material(
        color: AppTheme.windowWidgetBackgroundBlack,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isInCart
                ? AppTheme.amber.withValues(alpha: 0.75)
                : AppTheme.lightAmberWhite.withValues(alpha: 0.14),
            width: isInCart ? 1.2 : 0.6,
          ),
        ),
        child: InkWell(
          onTap: isAvailable ? onAdd : null,
          hoverColor: AppTheme.amber.withValues(alpha: 0.06),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full bleed dish photo
              MenuItemImageWidget(imageUrl: item.imageUrl),

              // Scrim that keeps the name, price and button readable
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xC0000000),
                      Color(0xF5000000),
                    ],
                    stops: [0.22, 0.62, 1],
                  ),
                ),
              ),

              if (!isAvailable) _buildSoldOutOverlay(),

              if (isInCart) _buildQuantityBadge(),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: isAvailable
                              ? AppTheme.white
                              : AppTheme.tableHeaderText,
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 6),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.category} · ${item.preparationTime} min',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightAmberWhite.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '৳ ${formatNumber(item.price)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.amber,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _AddButton(
                            isAvailable: isAvailable,
                            quantity: quantityInCart,
                            onTap: onAdd,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoldOutOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
      ),
      child: const Center(
        child: Text(
          'SOLD OUT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppTheme.dangerRedLight,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.amber,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
    );
  }
}

// Add action pinned to the bottom right of the dish tile
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
        : Colors.black.withValues(alpha: 0.45);
    final Color foreground = isInCart
        ? AppTheme.windowWidgetBackgroundBlack
        : AppTheme.lightAmberWhite;

    return Material(
      color: isAvailable
          ? background
          : Colors.black.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isInCart
              ? AppTheme.amber
              : AppTheme.lightAmberWhite.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        hoverColor: AppTheme.amber.withValues(alpha: 0.18),
        child: SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                if (isAvailable)
                  Icon(Icons.add, size: 15, color: foreground),
                Text(
                  isAvailable
                      ? (isInCart ? 'Add · $quantity' : 'Add')
                      : 'Sold out',
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
