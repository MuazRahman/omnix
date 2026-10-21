import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/widgets/pos_menu_item_card_widget.dart';

/// Scrollable dish grid for the current category and search query.
class PosMenuGridWidget extends StatelessWidget {
  const PosMenuGridWidget({super.key, required this.posController});

  final PosController posController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<MenuItem> items = posController.filteredItems;

      // Read the cart during the Obx build so the grid rebuilds when a line
      // is added, incremented or removed. The lazy itemBuilder alone does not
      // register a GetX dependency on the cart.
      final Map<String, int> cartQuantities = <String, int>{
        for (final line in posController.cart) line.menuItemId: line.quantity,
      };

      if (items.isEmpty) {
        return const _EmptyMenuWidget();
      }

      return GridView.builder(
        primary: false,
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 224,
        ),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final MenuItem item = items[index];

          return PosMenuItemCardWidget(
            item: item,
            quantityInCart: cartQuantities[item.id] ?? 0,
            onAdd: () => posController.addToCart(item),
          );
        },
      );
    });
  }
}

class _EmptyMenuWidget extends StatelessWidget {
  const _EmptyMenuWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 34,
            color: AppTheme.tableHeaderText.withValues(alpha: 0.6),
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
