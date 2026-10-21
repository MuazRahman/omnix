import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/model/pos_order_type_model.dart';
import 'package:omnix/features/pos/widgets/pos_panel_widget.dart';

/// Order type, table and guest count selector above the menu.
class PosOperationalBarWidget extends StatelessWidget {
  const PosOperationalBarWidget({super.key, required this.posController});

  final PosController posController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Widget modeToggle = _OrderTypeToggle(
        selected: posController.orderType.value,
        onChanged: posController.orderTypeOnChanged,
      );

      final Widget tableChip = _TableChip(
        table: posController.tableLabel.value,
        tables: posController.tables,
        onChanged: posController.tableOnChanged,
      );

      final Widget paxChip = _PaxChip(
        pax: posController.paxCount.value,
        options: posController.paxOptions,
        onChanged: posController.paxOnChanged,
      );

      return PosPanelWidget(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // the chips wrap on narrow windows instead of overflowing
            if (constraints.maxWidth < 780) {
              return Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // the segmented control shrinks instead of overflowing
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: modeToggle,
                  ),
                  if (posController.isDineIn) ...[tableChip, paxChip],
                ],
              );
            }

            return Row(
              children: [
                modeToggle,
                const Spacer(),
                if (posController.isDineIn) ...[
                  tableChip,
                  const SizedBox(width: 8),
                  paxChip,
                ],
              ],
            );
          },
        ),
      );
    });
  }
}

// Dine-in / Takeaway / Delivery segmented control
class _OrderTypeToggle extends StatelessWidget {
  const _OrderTypeToggle({required this.selected, required this.onChanged});

  final PosOrderType selected;
  final ValueChanged<PosOrderType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: PosOrderType.values.map((PosOrderType type) {
          final bool isSelected = type == selected;

          return Material(
            color: isSelected ? AppTheme.amber : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () => onChanged(type),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    Icon(
                      _iconFor(type),
                      size: 15,
                      color: isSelected
                          ? AppTheme.windowWidgetBackgroundBlack
                          : AppTheme.lightAmberWhite.withValues(alpha: 0.65),
                    ),
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.windowWidgetBackgroundBlack
                            : AppTheme.lightAmberWhite.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconFor(PosOrderType type) {
    switch (type) {
      case PosOrderType.dineIn:
        return Icons.restaurant;
      case PosOrderType.takeaway:
        return Icons.shopping_bag_outlined;
      case PosOrderType.delivery:
        return Icons.delivery_dining;
    }
  }
}

// Assigned table dropdown
class _TableChip extends StatelessWidget {
  const _TableChip({
    required this.table,
    required this.tables,
    required this.onChanged,
  });

  final String table;
  final List<String> tables;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Assign table',
      color: AppTheme.sidebarBackgroundBlack,
      onSelected: onChanged,
      itemBuilder: (BuildContext context) {
        return tables.map((String value) {
          return PopupMenuItem<String>(
            value: value,
            child: Row(
              spacing: 8,
              children: [
                Icon(
                  value == table
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 15,
                  color: value == table
                      ? AppTheme.amber
                      : AppTheme.tableHeaderText,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.lightAmberWhite,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: _chip(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 7,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppTheme.amber,
                shape: BoxShape.circle,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ASSIGNED TABLE',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
                Text(
                  table,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.amber,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppTheme.tableHeaderText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
          width: 0.6,
        ),
      ),
      child: child,
    );
  }
}

// Guest count dropdown
class _PaxChip extends StatelessWidget {
  const _PaxChip({
    required this.pax,
    required this.options,
    required this.onChanged,
  });

  final int pax;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Guest count',
      color: AppTheme.sidebarBackgroundBlack,
      onSelected: onChanged,
      itemBuilder: (BuildContext context) {
        return options.map((int value) {
          return PopupMenuItem<int>(
            value: value,
            child: Text(
              '$value Pax',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.lightAmberWhite,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: AppTheme.topbarBackgroundBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            const Icon(
              Icons.people_alt_outlined,
              size: 15,
              color: AppTheme.tableHeaderText,
            ),
            Text(
              '$pax Pax',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightAmberWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
