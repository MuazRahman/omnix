import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/custom_container_widget.dart';
import 'package:omnix/features/common/widgets/data_table_widget.dart';
import 'package:omnix/features/common/widgets/section_header_widget.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/purchases/controller/purchase_controller.dart';
import 'package:omnix/features/purchases/model/purchase_model.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();
    final PurchaseController purchaseController =
        Get.find<PurchaseController>();

    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,
      body: Column(
        children: [
          // Appbar Header
          TopBarWidget(branchController: branchController),

          // Title, search and add button
          Obx(
            () => SectionHeaderWidget(
              title: 'Purchases',
              subtitle:
                  '${purchaseController.purchases.length} orders · ${formatTaka(purchaseController.filteredTotal)}',
              searchHint: 'Search by id, supplier or item',
              onSearchChanged: purchaseController.searchOnChanged,
              actionLabel: 'New Purchase',
              actionIcon: Icons.add,
              onAction: () {},
            ),
          ),

          // Status filter
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 8,
                children: List.generate(
                  purchaseController.statusFilters.length,
                  (int index) => PurchaseFilterChip(
                    label: purchaseController.statusFilters[index],
                    isSelected:
                        purchaseController.selectedStatus.value == index,
                    onTap: () =>
                        purchaseController.statusFilterOnChanged(index),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Purchase table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomContainerWidget(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Obx(() {
                    final List<Purchase> purchases =
                        purchaseController.filteredPurchases;

                    return DataTableWidget(
                      columns: const [
                        DataTableColumn(
                          label: 'PO Number',
                          flex: 129,
                          monospace: true,
                        ),
                        DataTableColumn(label: 'Supplier', flex: 200),
                        DataTableColumn(label: 'Items', flex: 232),
                        DataTableColumn(label: 'Status', flex: 129),
                        DataTableColumn(label: 'Ordered At', flex: 150),
                        DataTableColumn(
                          label: 'Amount',
                          flex: 111,
                          alignRight: true,
                          monospace: true,
                        ),
                      ],
                      rows: purchases
                          .map(
                            (Purchase purchase) =>
                                DataTableRow(cells: buildCells(purchase)),
                          )
                          .toList(),
                      emptyMessage: 'No purchases match the filter',
                    );
                  }),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> buildCells(Purchase purchase) {
    return [
      DataTableWidget.text(
        purchase.id,
        color: AppTheme.badgeAmberText,
        weight: FontWeight.w600,
        monospace: true,
      ),
      DataTableWidget.text(purchase.supplier, weight: FontWeight.w600),
      DataTableWidget.text(purchase.itemsSummary, weight: FontWeight.w500),
      StatusPillWidget(
        label: _statusLabel(purchase.status),
        tone: _statusTone(purchase.status),
      ),
      DataTableWidget.text(purchase.orderedAt, color: AppTheme.tableHeaderText),
      DataTableWidget.text(
        '৳${formatNumber(purchase.amount)}',
        weight: FontWeight.w700,
        monospace: true,
      ),
    ];
  }

  String _statusLabel(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.draft:
        return 'Draft';
      case PurchaseStatus.ordered:
        return 'Ordered';
      case PurchaseStatus.received:
        return 'Received';
      case PurchaseStatus.cancelled:
        return 'Cancelled';
    }
  }

  PillTone _statusTone(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.draft:
        return PillTone.blue;
      case PurchaseStatus.ordered:
        return PillTone.amber;
      case PurchaseStatus.received:
        return PillTone.green;
      case PurchaseStatus.cancelled:
        return PillTone.neutral;
    }
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
