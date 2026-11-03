import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/common/widgets/data_table_widget.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/purchases/controller/purchase_controller.dart';
import 'package:omnix/features/purchases/model/purchase_model.dart';
import 'package:omnix/features/purchases/widgets/purchase_badges.dart';

/// Purchase order ledger card with a sub-header and a footer summary.
class PurchasesTableWidget extends StatelessWidget {
  const PurchasesTableWidget({
    super.key,
    required this.controller,
    required this.onSelectPurchase,
    required this.onExport,
  });

  final PurchaseController controller;
  final ValueChanged<Purchase> onSelectPurchase;
  final VoidCallback onExport;

  static const double _rowHeight = 78;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Read the reactive list here, an Obx only tracks observables read
      // inside its own build callback.
      final List<Purchase> purchases = controller.filteredPurchases;

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final _PurchasesTableLayout layout = constraints.maxWidth >= 1150
              ? _PurchasesTableLayout.full
              : (constraints.maxWidth >= 860
                    ? _PurchasesTableLayout.compact
                    : _PurchasesTableLayout.narrow);

          final double tableHeight = purchases.isEmpty
              ? 170
              : 39 + (purchases.length * _rowHeight);

          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppTheme.windowWidgetBackgroundBlack,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
                width: 0.6,
              ),
            ),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                _TableSubHeader(
                  title: 'Purchase Requisitions',
                  count: purchases.length,
                  total: controller.filteredTotal,
                  onExport: onExport,
                ),
                SizedBox(
                  height: tableHeight,
                  child: DataTableWidget(
                    columns: _buildColumns(layout),
                    rows: purchases
                        .map(
                          (Purchase purchase) => DataTableRow(
                            onTap: () => onSelectPurchase(purchase),
                            cells: _buildCells(purchase, layout),
                          ),
                        )
                        .toList(),
                    rowHeight: _rowHeight,
                    emptyMessage: 'No purchase orders match the filter',
                  ),
                ),
                _TableFooter(controller: controller, shown: purchases.length),
              ],
            ),
          );
        },
      );
    });
  }

  List<DataTableColumn> _buildColumns(_PurchasesTableLayout layout) {
    switch (layout) {
      case _PurchasesTableLayout.full:
        return const [
          DataTableColumn(label: 'PO & Supplier', flex: 245),
          DataTableColumn(label: 'Timeline', flex: 180),
          DataTableColumn(label: 'Commodities', flex: 205),
          DataTableColumn(label: 'Total & Payment', flex: 145),
          DataTableColumn(label: 'Receiving Gate', flex: 160),
          DataTableColumn(label: 'Action', flex: 175),
        ];
      case _PurchasesTableLayout.compact:
        return const [
          DataTableColumn(label: 'PO & Supplier', flex: 245),
          DataTableColumn(label: 'Timeline', flex: 175),
          DataTableColumn(label: 'Total & Payment', flex: 140),
          DataTableColumn(label: 'Receiving Gate', flex: 150),
          DataTableColumn(label: 'Action', flex: 155),
        ];
      case _PurchasesTableLayout.narrow:
        return const [
          DataTableColumn(label: 'PO & Supplier', flex: 220),
          DataTableColumn(label: 'Total', flex: 120, alignRight: true),
          DataTableColumn(label: 'Action', flex: 140, alignRight: true),
        ];
    }
  }

  List<Widget> _buildCells(Purchase purchase, _PurchasesTableLayout layout) {
    final Widget po = _PoCell(purchase: purchase);
    final Widget timeline = _TimelineCell(purchase: purchase);
    final Widget commodities = _CommoditiesCell(purchase: purchase);
    final Widget total = _TotalCell(purchase: purchase);
    final Widget gate = _GateCell(purchase: purchase);
    final Widget action = _ActionCell(
      purchase: purchase,
      isCompact: layout == _PurchasesTableLayout.narrow,
      onSelect: () => onSelectPurchase(purchase),
    );

    switch (layout) {
      case _PurchasesTableLayout.full:
        return [po, timeline, commodities, total, gate, action];
      case _PurchasesTableLayout.compact:
        return [po, timeline, total, gate, action];
      case _PurchasesTableLayout.narrow:
        return [po, total, action];
    }
  }
}

enum _PurchasesTableLayout { full, compact, narrow }

class _TableSubHeader extends StatelessWidget {
  const _TableSubHeader({
    required this.title,
    required this.count,
    required this.total,
    required this.onExport,
  });

  final String title;
  final int count;
  final int total;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.tableDivider.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        spacing: 12,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.tablePrimaryText,
            ),
          ),
          Text(
            '$count · ${formatTakaSymbol(total)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.tableHeaderText,
            ),
          ),
          const Spacer(),
          _GhostButton(
            label: 'Export CSV',
            icon: Icons.download_outlined,
            onTap: onExport,
          ),
        ],
      ),
    );
  }
}

class _TableFooter extends StatelessWidget {
  const _TableFooter({required this.controller, required this.shown});

  final PurchaseController controller;
  final int shown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.tableDivider.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Showing $shown of ${controller.purchases.length} purchase orders',
            style: const TextStyle(
              fontSize: 11.5,
              color: AppTheme.tableHeaderText,
            ),
          ),
          const Spacer(),
          const Text(
            'Page 1',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.tablePrimaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _PoCell extends StatelessWidget {
  const _PoCell({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          spacing: 6,
          children: [
            Text(
              purchase.id,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontFamilyFallback: ['Courier New', 'Menlo'],
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.badgeAmberText,
              ),
            ),
            _Tag(label: purchase.supplierId),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          purchase.supplier,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.tablePrimaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${purchase.lineCount} line item'
          '${purchase.lineCount == 1 ? '' : 's'} · ${purchase.destination}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppTheme.tableHeaderText,
          ),
        ),
      ],
    );
  }
}

class _TimelineCell extends StatelessWidget {
  const _TimelineCell({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Ordered: ${purchase.orderedAt}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: AppTheme.tablePrimaryText,
          ),
        ),
        const SizedBox(height: 4),
        _TimelineStatus(purchase: purchase),
      ],
    );
  }
}

class _TimelineStatus extends StatelessWidget {
  const _TimelineStatus({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    if (purchase.isOpen) {
      final Color color = purchaseStatusColor(purchase.status);
      return _CaptionLine(
        icon: Icons.schedule,
        color: color,
        text: purchase.expectedAt ?? 'Awaiting schedule',
      );
    }

    if (purchase.receivedAt != null) {
      return _CaptionLine(
        icon: Icons.check_circle_outline,
        color: AppTheme.lightGreen,
        text: 'Recv: ${purchase.receivedAt}',
      );
    }

    return const _CaptionLine(
      icon: Icons.block,
      color: AppTheme.badgeNeutralText,
      text: 'Not scheduled',
    );
  }
}

class _CaptionLine extends StatelessWidget {
  const _CaptionLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Icon(icon, size: 14, color: color),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _CommoditiesCell extends StatelessWidget {
  const _CommoditiesCell({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    final PurchaseLine first = purchase.lines.first;

    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${purchase.lineCount} Line'
          '${purchase.lineCount == 1 ? '' : 's'}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.tablePrimaryText,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          first.summary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppTheme.tableHeaderText,
          ),
        ),
        if (purchase.lineCount > 1) ...[
          const SizedBox(height: 2),
          Text(
            '+${purchase.lineCount - 1} more item'
            '${purchase.lineCount - 1 == 1 ? '' : 's'}',
            maxLines: 1,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ],
      ],
    );
  }
}

class _TotalCell extends StatelessWidget {
  const _TotalCell({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatTakaSymbol(purchase.amount),
          maxLines: 1,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 5),
        StatusPillWidget(
          label: purchase.paymentStatus.label,
          tone: purchasePaymentTone(purchase.paymentStatus),
          showDot: false,
        ),
      ],
    );
  }
}

class _GateCell extends StatelessWidget {
  const _GateCell({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    final String caption = purchase.isOpen
        ? (purchase.carrier ?? 'Truck at ${purchase.gate}')
        : (purchase.receivedBy != null
              ? 'By ${purchase.receivedBy} (Verified)'
              : purchase.gate);

    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusPillWidget(
          label: purchase.status.label,
          tone: purchaseStatusTone(purchase.status),
          showDot: purchase.isOpen,
        ),
        const SizedBox(height: 5),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppTheme.tableHeaderText,
          ),
        ),
      ],
    );
  }
}

class _ActionCell extends StatelessWidget {
  const _ActionCell({
    required this.purchase,
    required this.isCompact,
    required this.onSelect,
  });

  final Purchase purchase;
  final bool isCompact;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    if (purchase.isOpen) {
      return _PrimaryButton(
        label: isCompact ? 'Receive' : 'Receive & Verify',
        icon: Icons.scale_outlined,
        onTap: onSelect,
      );
    }

    return _GhostButton(
      label: isCompact ? 'Invoice' : 'View Invoice',
      icon: Icons.receipt_long_outlined,
      onTap: onSelect,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.amber,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: AppTheme.deepAmberWhite,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(
                icon,
                size: 15,
                color: AppTheme.windowWidgetBackgroundBlack,
              ),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.windowWidgetBackgroundBlack,
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

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.badgeNeutralBackground.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: AppTheme.amber.withValues(alpha: 0.12),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(icon, size: 15, color: AppTheme.tablePrimaryText),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.tablePrimaryText,
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppTheme.badgeNeutralBackground.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppTheme.badgeNeutralText,
        ),
      ),
    );
  }
}
