import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/purchases/controller/purchase_controller.dart';

/// Four procurement metrics shown above the tabs.
class PurchasesStatRibbonWidget extends StatelessWidget {
  const PurchasesStatRibbonWidget({super.key, required this.controller});

  final PurchaseController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int open = controller.openPurchaseCount;
      final int arriving = controller.arrivingTodayCount;
      final int payables = controller.payableInvoiceCount;

      final List<Widget> cards = [
        PurchasesStatCard(
          label: 'Active Suppliers',
          value: '${controller.activeSupplierCount}',
          icon: Icons.storefront_outlined,
          accent: AppTheme.lightGreen,
          caption: 'Registered verified partners',
        ),
        PurchasesStatCard(
          label: 'Open POs',
          value: '$open',
          icon: Icons.local_shipping_outlined,
          accent: AppTheme.badgeAmberText,
          caption: arriving > 0
              ? '$arriving arriving today for the prep line'
              : 'No deliveries scheduled today',
        ),
        PurchasesStatCard(
          label: 'MTD Purchases',
          value: formatTakaSymbol(controller.monthToDateSpend),
          icon: Icons.shopping_basket_outlined,
          accent: AppTheme.white,
          caption: 'Raw meat, staples & dairy',
        ),
        PurchasesStatCard(
          label: 'Outstanding Payables',
          value: formatTakaSymbol(controller.outstandingPayables),
          icon: Icons.account_balance_wallet_outlined,
          accent: controller.outstandingPayables > 0
              ? AppTheme.dangerRedLight
              : AppTheme.lightGreen,
          caption: payables > 0
              ? '$payables supplier invoices open'
              : 'All supplier invoices settled',
        ),
      ];

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double gap = 12;
          final int columns = constraints.maxWidth >= 1150
              ? 4
              : (constraints.maxWidth >= 700 ? 2 : 1);
          final double cardWidth =
              (constraints.maxWidth - (gap * (columns - 1))) / columns;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: cards
                .map((Widget card) => SizedBox(width: cardWidth, child: card))
                .toList(),
          );
        },
      );
    });
  }
}

/// One metric tile of the purchases ribbon.
class PurchasesStatCard extends StatelessWidget {
  const PurchasesStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.caption,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(14),
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
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    height: 1.25,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: .centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: -0.5,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.2,
              color: AppTheme.badgeNeutralText,
            ),
          ),
        ],
      ),
    );
  }
}
