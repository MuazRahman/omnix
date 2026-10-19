import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/custom_widget_card.dart';
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

          // summary card (today's sale, active order, ticket, stock)
          buildSalesOverview(),

          // Sales velocity chart

        ],
      )
    );
  }

  Padding buildSalesOverview() {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: .start,
            spacing: 16,
            children: [

              // today's sale card
              CustomCardWidget(
                title: "Today's Sale",
                icon: Icons.credit_card,
                content: '84,650 TK',
                subtitle: '12.4% vs yesterday',
              ),

              // active order
              CustomCardWidget(
                title: "Active Order",
                icon: Icons.restaurant_menu_outlined,
                content: '6',
                subtitle: 'Orders today',
              ),

              CustomCardWidget(
                title: "Average Ticket",
                icon: Icons.bookmark_added,
                content: '525 TK',
                subtitle: 'per order',
              ),

              CustomCardWidget(
                title: "Low Stock",
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.red.shade700.withValues(alpha: 0.9),
                content: "4",
                subtitle: 'Items required restock',
              ),
            ],
          ),
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
                // Whole-pixel width so it renders crisp and never
                // anti-aliases into a fainter/narrower line.
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: SizedBox(
              // Fixed total width: the left edge stays on the same pixel
              // regardless of which label is bolded, so the border never shifts.
              width: 250,
              child: Row(
                children: List.generate(
                  dashboardController.dayRanges.length,
                      (index) => Expanded(
                        child: DayRangeButtonWidget(
                            dashBoardController: dashboardController, index: index),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


