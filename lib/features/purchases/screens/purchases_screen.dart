import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/purchases/controller/purchase_controller.dart';
import 'package:omnix/features/purchases/model/vendor_model.dart';
import 'package:omnix/features/purchases/widgets/new_purchase_order_dialog_widget.dart';
import 'package:omnix/features/purchases/widgets/purchases_header_widget.dart';
import 'package:omnix/features/purchases/widgets/purchases_stat_ribbon_widget.dart';
import 'package:omnix/features/purchases/widgets/purchases_tab_bar_widget.dart';
import 'package:omnix/features/purchases/widgets/purchases_table_widget.dart';
import 'package:omnix/features/purchases/widgets/receive_inbound_panel_widget.dart';
import 'package:omnix/features/purchases/widgets/register_supplier_dialog_widget.dart';
import 'package:omnix/features/purchases/widgets/vendor_directory_widget.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();
    final PurchaseController purchaseController =
        Get.find<PurchaseController>();

    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            // Global app bar
            TopBarWidget(branchController: branchController),

            // Breadcrumb, title, search and quick actions
            PurchasesHeaderWidget(
              onSearchChanged: purchaseController.searchOnChanged,
              onRegisterSupplier: () => _registerSupplier(
                context,
                purchaseController,
              ),
              onNewPurchaseOrder: () =>
                  _newPurchaseOrder(context, purchaseController),
            ),

            const SizedBox(height: 12),

            // Procurement metrics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PurchasesStatRibbonWidget(controller: purchaseController),
            ),

            const SizedBox(height: 16),

            // Ledger / vendor tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: .centerLeft,
                child: PurchasesTabBarWidget(controller: purchaseController),
              ),
            ),

            const SizedBox(height: 12),

            // Tab content
            Obx(() {
              if (purchaseController.selectedTab.value ==
                  PurchasesTab.vendors) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: VendorDirectoryWidget(
                    controller: purchaseController,
                    onOrderPo: (Vendor vendor) => _newPurchaseOrder(
                      context,
                      purchaseController,
                      vendor: vendor,
                    ),
                    onRegisterSupplier: () =>
                        _registerSupplier(context, purchaseController),
                  ),
                );
              }

              return _PurchaseOrdersSection(
                controller: purchaseController,
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Opens the supplier onboarding form; the controller owns the new vendor.
  Future<Vendor?> _registerSupplier(
    BuildContext context,
    PurchaseController controller,
  ) {
    return showRegisterSupplierDialog(context: context, controller: controller);
  }

  // Opens the purchase order builder, optionally pre-filled with a vendor.
  Future<bool?> _newPurchaseOrder(
    BuildContext context,
    PurchaseController controller, {
    Vendor? vendor,
  }) {
    return showNewPurchaseOrderDialog(
      context: context,
      controller: controller,
      initialVendor: vendor,
    );
  }
}

// Status chips, the PO ledger and the receive dock for the orders tab
class _PurchaseOrdersSection extends StatelessWidget {
  const _PurchaseOrdersSection({required this.controller});

  final PurchaseController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        // Status filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 34,
            child: Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  children: List.generate(
                    controller.statusFilters.length,
                    (int index) => PurchaseFilterChip(
                      key: Key(
                        'purchases-filter-${controller.statusFilters[index]}',
                      ),
                      label: controller.statusFilters[index],
                      isSelected: controller.selectedStatus.value == index,
                      onTap: () => controller.statusFilterOnChanged(index),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Ledger + receive dock
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Widget table = PurchasesTableWidget(
                controller: controller,
                onSelectPurchase: (purchase) =>
                    controller.selectPurchase(purchase.id),
                onExport: () => controller.exportPurchases(),
              );

              final Widget dock = ReceiveInboundPanelWidget(
                controller: controller,
              );

              if (constraints.maxWidth >= 1200) {
                return Row(
                  crossAxisAlignment: .start,
                  spacing: 16,
                  children: [
                    Expanded(flex: 8, child: table),
                    Expanded(flex: 4, child: dock),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: .stretch,
                children: [table, const SizedBox(height: 16), dock],
              );
            },
          ),
        ),
      ],
    );
  }
}

// Small filter chip used above the table
class PurchaseFilterChip extends StatelessWidget {
  const PurchaseFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.amber : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? AppTheme.amber
                  : AppTheme.lightAmberWhite.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppTheme.windowWidgetBackgroundBlack
                  : AppTheme.lightAmberWhite,
            ),
          ),
        ),
      ),
    );
  }
}
