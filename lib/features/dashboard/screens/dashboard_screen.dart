import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/dashboard/controller/dash_board_controller.dart';
import 'package:omnix/features/dashboard/widgets/day_range_button_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();
    final DashBoardController dashboardController = Get.find<DashBoardController>();
    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,

      body: Column(
        children: [

          // Appbar Header
          TopBarWidget(branchController: branchController,),

          // Dashboard Overview, current branch name & day range selection
          buildDashboardOverViewAndDayRangeSelector(branchController, dashboardController),
        ],
      )
    );
  }

  Widget buildDashboardOverViewAndDayRangeSelector(
      BranchController branchController,
      DashBoardController dashboardController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
      child: Row(
        children: [

          // Dashboard Overview & current branch name
          Column(
            crossAxisAlignment: .start,
            spacing: 5,
            children: [
              Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: .bold,
                  color: AppTheme.white,
                ),
              ),

              Row(
                spacing: 8,
                children: [
                  Text(
                    "Sultans Dine",
                    style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.lightAmberWhite,
                        fontWeight: .w200
                    ),
                  ),

                  CircleAvatar(
                    backgroundColor: AppTheme.deepAmberWhite,
                    radius: 3,
                  ),

                  // branch name
                  Text(
                    branchController.selectedBranch.value!,
                    style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.lightAmberWhite,
                        fontWeight: .w200
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Day range selection (Today / 7 Days / 30 Days)
          Container(
            decoration: BoxDecoration(
              color: AppTheme.windowWidgetBackgroundBlack,
              border: Border.all(
                color: AppTheme.lightAmberWhite.withValues(alpha: 50),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: .min,
              children: List.generate(
                dashboardController.dayRanges.length,
                    (index) =>
                    DayRangeButtonWidget(
                        dashBoardController: dashboardController, index: index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
