import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/model/cart_item_model.dart';
import 'package:omnix/features/pos/widgets/pos_quantity_stepper_widget.dart';

/// One line of the live cart.
class PosCartLineWidget extends StatelessWidget {
  const PosCartLineWidget({
    super.key,
    required this.posController,
    required this.line,
  });

  final PosController posController;
  final CartItem line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.badgeAmberText,
                  ),
                ),
                if (line.note != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    line.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.lightGreen.withValues(alpha: 0.8),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  '${formatTakaSymbol(line.price)} each',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatTakaSymbol(line.lineTotal),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tablePrimaryText,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PosQuantityStepperWidget(
                    quantity: line.quantity,
                    onDecrement: () =>
                        posController.removeFromCart(line.menuItemId),
                    onIncrement: () =>
                        posController.addToCartId(line.menuItemId),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: 'Remove item',
                    child: InkWell(
                      onTap: () => posController.removeLine(line.menuItemId),
                      borderRadius: BorderRadius.circular(4),
                      hoverColor: AppTheme.dangerRed.withValues(alpha: 0.12),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: AppTheme.tableHeaderText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
