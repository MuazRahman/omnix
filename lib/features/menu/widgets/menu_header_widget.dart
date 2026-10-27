import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Title block of the Menu section with its quick actions.
class MenuHeaderWidget extends StatelessWidget {
  const MenuHeaderWidget({
    super.key,
    required this.modifierGroupCount,
    required this.onBulkImport,
    required this.onOpenModifiers,
    required this.onAddDish,
  });

  final int modifierGroupCount;
  final VoidCallback onBulkImport;
  final VoidCallback onOpenModifiers;
  final VoidCallback onAddDish;

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
                    'CATALOG ENGINE',
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
                    'STANDARD RECIPES',
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
                'Menu Management',
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
                'Configure the food & beverage catalog, recipe margins, '
                'modifiers, and branch availability.',
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
              MenuActionButton(
                label: 'Bulk Import',
                icon: Icons.upload_file_outlined,
                onTap: onBulkImport,
              ),
              MenuActionButton(
                label: 'Global Modifiers ($modifierGroupCount)',
                icon: Icons.tune,
                onTap: onOpenModifiers,
              ),
              MenuActionButton(
                label: 'Add New Dish',
                icon: Icons.add,
                onTap: onAddDish,
                isPrimary: true,
              ),
            ],
          );

          if (constraints.maxWidth >= 980) {
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

/// Quick action button of the menu header.
class MenuActionButton extends StatelessWidget {
  const MenuActionButton({
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
