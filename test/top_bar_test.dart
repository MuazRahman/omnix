import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';

void main() {
  late BranchController branchController;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    branchController = Get.put(BranchController());
  });

  tearDown(Get.reset);

  for (final double width in <double>[
    1920,
    1440,
    1366,
    1200,
    1024,
    900,
    764,
    700,
    620,
    500,
  ]) {
    testWidgets('top bar fits a ${width.toInt()}px window', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = Size(width, 200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: TopBarWidget(branchController: branchController),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Main Branch (DHK-01)'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
