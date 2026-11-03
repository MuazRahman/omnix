import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/purchases/controller/purchase_controller.dart';

/// Segmented selector that switches between the PO ledger and the vendors.
class PurchasesTabBarWidget extends StatelessWidget {
  const PurchasesTabBarWidget({super.key, required this.controller});

  final PurchaseController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final PurchasesTab active = controller.selectedTab.value;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.windowWidgetBackgroundBlack,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            PurchasesTabButton(
              key: const Key('purchases-tab-orders'),
              label: 'Purchase Orders',
              icon: Icons.inventory_2_outlined,
              count: controller.openPurchaseCount,
              isSelected: active == PurchasesTab.purchaseOrders,
              onTap: () => controller.selectTab(PurchasesTab.purchaseOrders),
            ),
            PurchasesTabButton(
              key: const Key('purchases-tab-vendors'),
              label: 'Vendor Directory',
              icon: Icons.contacts_outlined,
              count: controller.vendors.length,
              isSelected: active == PurchasesTab.vendors,
              onTap: () => controller.selectTab(PurchasesTab.vendors),
            ),
          ],
        ),
      );
    });
  }
}

/// One tab of the purchases selector.
class PurchasesTabButton extends StatelessWidget {
  const PurchasesTabButton({
    super.key,
    required this.label,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = isSelected
        ? AppTheme.windowWidgetBackgroundBlack
        : AppTheme.lightAmberWhite;

    return Material(
      color: isSelected ? AppTheme.amber : Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        hoverColor: isSelected
            ? AppTheme.deepAmberWhite
            : AppTheme.amber.withValues(alpha: 0.1),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: isSelected
                  ? AppTheme.amber
                  : AppTheme.lightAmberWhite.withValues(alpha: 0.16),
              width: 0.6,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(icon, size: 16, color: foreground),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: foreground,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.windowWidgetBackgroundBlack.withValues(
                          alpha: 0.16,
                        )
                      : AppTheme.badgeNeutralBackground.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppTheme.windowWidgetBackgroundBlack
                        : AppTheme.badgeNeutralText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
