import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Title block of the Purchases section with its search field and quick actions.
class PurchasesHeaderWidget extends StatelessWidget {
  const PurchasesHeaderWidget({
    super.key,
    required this.onSearchChanged,
    required this.onRegisterSupplier,
    required this.onNewPurchaseOrder,
  });

  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRegisterSupplier;
  final VoidCallback onNewPurchaseOrder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget titleBlock = Column(
            crossAxisAlignment: .start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                spacing: 6,
                children: [
                  const Text(
                    'PROCUREMENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppTheme.amber,
                    ),
                  ),
                  Text(
                    '/',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.tableHeaderText.withValues(alpha: 0.7),
                    ),
                  ),
                  const Text(
                    'INBOUND LEDGER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppTheme.tableHeaderText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Purchases & Vendor Supply',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  height: 1.15,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Raise purchase orders, verify inbound shipments at the dock '
                'and track supplier payables.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppTheme.lightAmberWhite.withValues(alpha: 0.55),
                ),
              ),
            ],
          );

          final Widget actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PurchasesSearchField(
                key: const Key('purchases-search-field'),
                onChanged: onSearchChanged,
              ),
              PurchasesActionButton(
                key: const Key('purchases-register-supplier'),
                label: 'Register Supplier',
                icon: Icons.person_add_alt,
                onTap: onRegisterSupplier,
              ),
              PurchasesActionButton(
                key: const Key('purchases-new-order'),
                label: 'New Purchase Order',
                icon: Icons.post_add,
                onTap: onNewPurchaseOrder,
                isPrimary: true,
              ),
            ],
          );

          if (constraints.maxWidth >= 1080) {
            return Row(
              crossAxisAlignment: .end,
              spacing: 16,
              children: [
                Expanded(child: titleBlock),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: actions,
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: .start,
            children: [titleBlock, const SizedBox(height: 12), actions],
          );
        },
      ),
    );
  }
}

/// Search field of the purchases header, styled like the shared section search.
class PurchasesSearchField extends StatelessWidget {
  const PurchasesSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      width: 260,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: AppTheme.lightAmberWhite),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.windowWidgetBackgroundBlack,
          prefixIcon: Icon(
            Icons.search_outlined,
            size: 18,
            color: AppTheme.deepAmberWhite.withValues(alpha: 0.5),
          ),
          hintText: 'Search PO #, vendor, ingredient',
          hintStyle: TextStyle(
            fontSize: 13,
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.4),
          ),
          border: _border(AppTheme.lightAmberWhite.withValues(alpha: 0.2)),
          enabledBorder: _border(
            AppTheme.lightAmberWhite.withValues(alpha: 0.2),
          ),
          focusedBorder: _border(AppTheme.amber.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: color, width: 0.5),
    );
  }
}

/// Quick action button of the purchases header.
class PurchasesActionButton extends StatelessWidget {
  const PurchasesActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final Color background = isPrimary
        ? AppTheme.amber
        : AppTheme.windowWidgetBackgroundBlack;
    final Color foreground = isPrimary
        ? AppTheme.windowWidgetBackgroundBlack
        : AppTheme.lightAmberWhite;
    final Color borderColor = isPrimary
        ? AppTheme.amber
        : AppTheme.lightAmberWhite.withValues(alpha: 0.16);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: isPrimary
            ? AppTheme.deepAmberWhite
            : AppTheme.amber.withValues(alpha: 0.1),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 7,
            children: [
              Icon(icon, size: 16, color: foreground),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
