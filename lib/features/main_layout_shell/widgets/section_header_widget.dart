import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;

  const SectionHeaderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          color: AppTheme.lightAmberWhite.withAlpha(200),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
