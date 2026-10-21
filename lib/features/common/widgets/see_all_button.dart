import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Small "See All" link used on the dashboard cards.
///
/// Tapping it navigates to the full list of the section.
class SeeAllButton extends StatefulWidget {
  const SeeAllButton({super.key, required this.onTap, this.label = 'See All'});

  final VoidCallback onTap;
  final String label;

  @override
  State<SeeAllButton> createState() => _SeeAllButtonState();
}

class _SeeAllButtonState extends State<SeeAllButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            color: _isHovered
                ? AppTheme.deepAmberWhite
                : AppTheme.lightAmberWhite,
            fontSize: 12,
            fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w400,
            decoration: _isHovered ? TextDecoration.underline : null,
            decorationColor: AppTheme.deepAmberWhite,
          ),
        ),
      ),
    );
  }
}
