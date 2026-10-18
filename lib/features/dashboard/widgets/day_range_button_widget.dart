import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/dashboard/controller/dash_board_controller.dart';

class DayRangeButtonWidget extends StatelessWidget {
  DayRangeButtonWidget({super.key, required this.dashBoardController, required this.index});

  final DashBoardController dashBoardController;
  int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isSelected = dashBoardController.selectedDayRange.value == index;

      return InkWell(
        onTap: () => dashBoardController.dayRangeOnChanged(index),
        borderRadius: BorderRadius.circular(6),
        highlightColor: AppTheme.amber.withAlpha(15),
        splashColor: AppTheme.amber.withAlpha(25),
        // Padding between segment border and the selected rounded rect
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.amber : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              dashBoardController.dayRanges[index],
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? .w700 : .w500,
                color: isSelected
                    ? AppTheme.windowWidgetBackgroundBlack
                    : AppTheme.lightAmberWhite.withAlpha(140),
              ),
            ),
          ),
        ),
      );
    });
  }
}
