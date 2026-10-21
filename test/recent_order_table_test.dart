import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/dashboard/controller/dash_board_controller.dart';
import 'package:omnix/features/dashboard/widgets/recent_order_table_widget.dart';

void main() {
  testWidgets('recent order table renders header, rows and badges', (
    WidgetTester tester,
  ) async {
    final DashBoardController controller = Get.put(DashBoardController());

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: AppTheme.topbarBackgroundBlack,
          body: SizedBox(
            width: 622,
            height: 243.5,
            child: RecentOrderTableWidget(dashBoardController: controller),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // headers
    expect(find.text('ORDER ID'), findsOneWidget);
    expect(find.text('ORDERED ITEMS'), findsOneWidget);
    expect(find.text('STATUS'), findsOneWidget);
    expect(find.text('AMOUNT'), findsOneWidget);

    // rows
    expect(find.text('ORD-1042'), findsOneWidget);
    expect(find.text('ORD-1043'), findsOneWidget);

    // status badges
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);

    // amount is monospaced and prefixed with the taka sign
    expect(find.text('৳1,240'), findsOneWidget);
  });
}
