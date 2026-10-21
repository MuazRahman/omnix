import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Color tones available for a [StatusPillWidget].
enum PillTone { amber, green, neutral, red, blue }

/// Small rounded label used to show a status, a type or a category.
class StatusPillWidget extends StatelessWidget {
  const StatusPillWidget({
    super.key,
    required this.label,
    this.tone = PillTone.neutral,
    this.showDot = true,
  });

  final String label;
  final PillTone tone;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    // background of the pill, its text color and the optional leading dot
    final Color background;
    final Color foreground;
    final Color? dot;

    switch (tone) {
      case PillTone.amber:
        background = AppTheme.amber.withValues(alpha: 0.2);
        foreground = AppTheme.badgeAmberText;
        dot = AppTheme.amber;
      case PillTone.green:
        background = AppTheme.successGreen.withValues(alpha: 0.2);
        foreground = AppTheme.lightGreen;
        dot = AppTheme.lightGreen;
      case PillTone.red:
        background = AppTheme.dangerRed.withValues(alpha: 0.2);
        foreground = AppTheme.dangerRedLight;
        dot = AppTheme.dangerRed;
      case PillTone.blue:
        background = AppTheme.infoBlue.withValues(alpha: 0.2);
        foreground = AppTheme.infoBlueLight;
        dot = AppTheme.infoBlue;
      case PillTone.neutral:
        background = AppTheme.badgeNeutralBackground;
        foreground = AppTheme.badgeNeutralText;
        dot = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (showDot && dot != null)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),

          // flexible so the pill never overflows a narrow column
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1.4,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
