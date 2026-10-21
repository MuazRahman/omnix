import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/widgets/pos_category_chip_widget.dart';

/// Horizontal list of menu categories.
class PosCategoryBarWidget extends StatelessWidget {
  const PosCategoryBarWidget({super.key, required this.posController});

  final PosController posController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: List.generate(posController.categories.length, (int index) {
            final String category = posController.categories[index];

            return PosCategoryChipWidget(
              label: category == 'All' ? 'All Items' : category,
              isSelected: posController.selectedCategory.value == index,
              onTap: () => posController.categoryOnChanged(index),
            );
          }),
        ),
      );
    });
  }
}
