import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Category filter chip used by the menu toolbar.
class MenuCategoryChip extends StatelessWidget {
  const MenuCategoryChip({
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
      color: isSelected ? AppTheme.amber : AppTheme.windowWidgetBackgroundBlack,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.amber.withValues(alpha: 0.12),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppTheme.amber
                  : AppTheme.lightAmberWhite.withValues(alpha: 0.16),
              width: 0.6,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
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
