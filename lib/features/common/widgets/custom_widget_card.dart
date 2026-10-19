import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

class CustomCardWidget extends StatelessWidget {
  const CustomCardWidget({super.key, required this.title, required this.icon, required this.content, required this.subtitle, this.iconColor});

  final String title;
  final IconData icon;
  final Color? iconColor;
  final String content;
  final String subtitle;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: 280,
      child: Container(
        decoration: BoxDecoration(
            color: AppTheme.windowWidgetBackgroundBlack,
            border: Border.all(
                color: AppTheme.deepAmberWhite.withValues(alpha: 0.2),
                width: 0.5
            ),
            borderRadius: BorderRadiusGeometry.circular(8)
        ),

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title,
                      style: TextStyle(
                        color: AppTheme.lightAmberWhite,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  Icon(
                    icon,
                    color: iconColor ?? AppTheme.lightAmberWhite ,
                  ),
                ],
              ),

              const Spacer(),

              Text(content,
                style: TextStyle(
                    color: iconColor ?? AppTheme.white,
                    fontSize: 35,
                    fontWeight: .bold
                ),
              ),

              const SizedBox(height: 4,),

              Row(
                children: [
                  Text(subtitle,
                    style: TextStyle(
                        color: AppTheme.lightAmberWhite.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: .w400
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}