import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Compact kitchen on/off switch used by the menu table and grid.
///
/// A plain Material [Switch] is too wide for a table cell, so the track and
/// knob are drawn by hand while keeping a 32px tap target.
class MenuAvailabilityToggle extends StatelessWidget {
  const MenuAvailabilityToggle({
    super.key,
    required this.isAvailable,
    required this.onChanged,
    this.showLabel = true,
  });

  final bool isAvailable;
  final ValueChanged<bool> onChanged;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final Color accent = isAvailable
        ? AppTheme.lightGreen
        : AppTheme.dangerRedLight;

    return Semantics(
      button: true,
      toggled: isAvailable,
      label: isAvailable ? 'Dish is active' : 'Dish is paused',
      child: InkWell(
        onTap: () => onChanged(!isAvailable),
        borderRadius: BorderRadius.circular(20),
        hoverColor: accent.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 7,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 36,
                height: 20,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? AppTheme.amber
                      : AppTheme.badgeNeutralBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  alignment: isAvailable ? .centerRight : .centerLeft,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppTheme.windowWidgetBackgroundBlack
                          : AppTheme.badgeNeutralText,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (showLabel)
                Flexible(
                  child: Text(
                    isAvailable ? 'Active' : 'Paused',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: accent,
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
