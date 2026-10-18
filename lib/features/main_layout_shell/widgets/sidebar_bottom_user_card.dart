import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

class SidebarBottomUserCard extends StatelessWidget {
  const SidebarBottomUserCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: Colors.white10, width: 0.5)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),

            // User Card
            child: Container(
              height: 56,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: AppTheme.black,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.amber.withAlpha(50), width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Column(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanvir Rahman',
                          style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        Text('Casher',
                          style: TextStyle(
                              color: AppTheme.lightAmberWhite.withAlpha(220),
                              fontSize: 11,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // User Image
                    const CircleAvatar(
                        radius: 17,
                        backgroundColor: AppTheme.background,
                        child: Icon(Icons.person)

                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 4),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.amber.withAlpha(50), width: 0.5),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 4,
                        children: [
                          Icon(Icons.lock_outline,
                            color: AppTheme.lightAmberWhite.withAlpha(240),
                            size: 15,
                          ),
                          Text('Lock',
                            style: TextStyle(
                                color: AppTheme.lightAmberWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.amber.withAlpha(50), width: 0.5),
                    ),
                    child: Center(
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.exit_to_app_outlined,
                            color: AppTheme.lightAmberWhite.withAlpha(240),
                            size: 15,
                          ),
                          Text('Exit',
                            style: TextStyle(
                                color: AppTheme.lightAmberWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}