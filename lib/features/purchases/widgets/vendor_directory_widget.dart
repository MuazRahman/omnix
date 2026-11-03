import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/purchases/controller/purchase_controller.dart';
import 'package:omnix/features/purchases/model/vendor_model.dart';

/// Approved supplier directory shown on the vendors tab.
class VendorDirectoryWidget extends StatelessWidget {
  const VendorDirectoryWidget({
    super.key,
    required this.controller,
    required this.onOrderPo,
    required this.onRegisterSupplier,
  });

  final PurchaseController controller;
  final ValueChanged<Vendor> onOrderPo;
  final VoidCallback onRegisterSupplier;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Vendor> vendors = controller.vendors;

      return Column(
        crossAxisAlignment: .stretch,
        children: [
          _DirectoryHeader(
            count: vendors.length,
            onRegisterSupplier: onRegisterSupplier,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const double gap = 12;
              final int columns = constraints.maxWidth >= 1150
                  ? 3
                  : (constraints.maxWidth >= 760 ? 2 : 1);
              final double cardWidth =
                  (constraints.maxWidth - (gap * (columns - 1))) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: vendors
                    .map(
                      (Vendor vendor) => SizedBox(
                        width: cardWidth,
                        child: VendorCard(
                          vendor: vendor,
                          onOrderPo: () => onOrderPo(vendor),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      );
    });
  }
}

class _DirectoryHeader extends StatelessWidget {
  const _DirectoryHeader({required this.count, required this.onRegisterSupplier});

  final int count;
  final VoidCallback onRegisterSupplier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
          width: 0.6,
        ),
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Approved Raw Food & Packaging Suppliers',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.tablePrimaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Verified vendors, payment credit terms, credit balance '
                  'and procurement history.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.lightAmberWhite.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.badgeNeutralBackground.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count Active Vendors',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.badgeNeutralText,
              ),
            ),
          ),
          _RegisterButton(onTap: onRegisterSupplier),
        ],
      ),
    );
  }
}

/// Card for one vendor in the directory grid.
class VendorCard extends StatelessWidget {
  const VendorCard({
    super.key,
    required this.vendor,
    required this.onOrderPo,
  });

  final Vendor vendor;
  final VoidCallback onOrderPo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _TierPill(label: '${vendor.tier} · ${vendor.category}'),
              const Spacer(),
              Text(
                vendor.id,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.tableHeaderText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            vendor.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.tablePrimaryText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            vendor.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 12),
          _VendorStatRow(label: 'Credit Terms', value: vendor.creditTerms),
          _VendorStatRow(
            label: 'Current Outstanding',
            value: vendor.hasOutstanding
                ? formatTakaSymbol(vendor.outstanding)
                : '৳ 0 (Settled)',
            valueColor: vendor.hasOutstanding
                ? AppTheme.dangerRedLight
                : AppTheme.lightGreen,
          ),
          _VendorStatRow(
            label: 'Lifetime Spend',
            value: formatTakaSymbol(vendor.lifetimeSpend),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rep: ${vendor.representative} · ${vendor.phone}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _OrderPoButton(onTap: onOrderPo),
            ],
          ),
        ],
      ),
    );
  }
}

class _VendorStatRow extends StatelessWidget {
  const _VendorStatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.tableHeaderText,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.tablePrimaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierPill extends StatelessWidget {
  const _TierPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: AppTheme.badgeAmberText,
        ),
      ),
    );
  }
}

class _OrderPoButton extends StatelessWidget {
  const _OrderPoButton({required this.onTap});

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
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            'Order PO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.tablePrimaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.onTap});

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
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(
                Icons.person_add_alt,
                size: 15,
                color: AppTheme.windowWidgetBackgroundBlack,
              ),
              Text(
                'Register Supplier',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.windowWidgetBackgroundBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
