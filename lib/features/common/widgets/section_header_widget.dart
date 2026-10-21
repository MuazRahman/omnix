import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Title bar used on top of every section, with an optional search field
/// and an optional action button on the right.
class SectionHeaderWidget extends StatelessWidget {
  const SectionHeaderWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.searchHint,
    this.onSearchChanged,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        crossAxisAlignment: .center,
        spacing: 16,
        children: [
          // title and subtitle
          Column(
            crossAxisAlignment: .start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),

              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.lightAmberWhite.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),

          const Spacer(),

          // search field
          if (searchHint != null)
            SizedBox(
              height: 38,
              width: 280,
              child: TextField(
                onChanged: onSearchChanged,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.lightAmberWhite,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.windowWidgetBackgroundBlack,
                  prefixIcon: Icon(
                    Icons.search_outlined,
                    size: 18,
                    color: AppTheme.deepAmberWhite.withValues(alpha: 0.5),
                  ),
                  hintText: searchHint,
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppTheme.lightAmberWhite.withValues(alpha: 0.4),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: AppTheme.lightAmberWhite.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: AppTheme.lightAmberWhite.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: AppTheme.amber.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),

          // action button
          if (actionLabel != null)
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.amber,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    if (actionIcon != null)
                      Icon(
                        actionIcon,
                        size: 16,
                        color: AppTheme.windowWidgetBackgroundBlack,
                      ),

                    Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.windowWidgetBackgroundBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
