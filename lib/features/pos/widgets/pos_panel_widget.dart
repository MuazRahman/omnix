import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Rounded dark surface used by the POS panels and toolbars.
class PosPanelWidget extends StatelessWidget {
  const PosPanelWidget({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.color,
    this.radius = 12,
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color ?? AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(radius),
        border: showBorder
            ? Border.all(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
                width: 0.6,
              )
            : null,
      ),
      child: child,
    );
  }
}
