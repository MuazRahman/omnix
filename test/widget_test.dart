import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:omnix/app.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  testWidgets('app boots into the main layout shell', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const Omnix());
    await tester.pumpAndSettle();

    expect(find.text('Omnix'), findsOneWidget);
    expect(find.text('Restaurant POS'), findsOneWidget);
    expect(find.text('Recent Orders'), findsOneWidget);
  });
}
