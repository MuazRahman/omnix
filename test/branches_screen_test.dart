import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/branches/screens/branches_screen.dart';
import 'package:omnix/features/branches/widgets/branch_card_widget.dart';
import 'package:omnix/features/branches/widgets/branch_compact_list_widget.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put(BranchController());
  });

  tearDown(Get.reset);

  testWidgets('branches screen renders the network overview and cards', (
    WidgetTester tester,
  ) async {
    await pumpBranches(tester, const Size(1920, 1080));

    expect(find.text('Branch Management'), findsOneWidget);
    expect(find.text('NETWORK FOOTPRINT'), findsOneWidget);
    expect(find.text('COMBINED TODAY GROSS'), findsOneWidget);
    expect(find.text('STAFF DEPLOYMENT'), findsOneWidget);
    expect(find.byType(BranchCardWidget), findsNWidgets(4));
    expect(find.text('Cross-Branch Hourly Order Throughput'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('branches screen survives narrow and wide widths', (
    WidgetTester tester,
  ) async {
    for (final Size size in const <Size>[
      Size(360, 800),
      Size(600, 900),
      Size(1024, 800),
      Size(1280, 900),
      Size(1920, 1080),
    ]) {
      await pumpBranches(tester, size);
      expect(tester.takeException(), isNull, reason: 'width ${size.width}');
    }
  });

  testWidgets('compact view lists outlets and grid toggles back', (
    WidgetTester tester,
  ) async {
    await pumpBranches(tester, const Size(1920, 1080));

    await tester.tap(find.byTooltip('Compact view'));
    await tester.pumpAndSettle();

    expect(find.byType(BranchCompactListWidget), findsOneWidget);
    expect(find.byType(BranchCardWidget), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Grid view'));
    await tester.pumpAndSettle();

    expect(find.byType(BranchCardWidget), findsNWidgets(4));
  });

  testWidgets('search filters the branch grid', (WidgetTester tester) async {
    await pumpBranches(tester, const Size(1920, 1080));

    await tester.enterText(
      find.byKey(const Key('branch-search-field')),
      'khulna',
    );
    await tester.pumpAndSettle();

    expect(find.byType(BranchCardWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact view fits a narrow window', (WidgetTester tester) async {
    await pumpBranches(tester, const Size(360, 800));

    await tester.tap(find.byTooltip('Compact view'));
    await tester.pumpAndSettle();

    expect(find.byType(BranchCompactListWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add branch dialog opens and closes cleanly', (
    WidgetTester tester,
  ) async {
    await pumpBranches(tester, const Size(1280, 900));

    await tester.tap(find.text('Add New Branch'));
    await tester.pumpAndSettle();

    expect(find.text('Add New Restaurant Outlet'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('branch-dialog-close')));
    await tester.pumpAndSettle();

    expect(find.text('Add New Restaurant Outlet'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creating an outlet adds it to the network', (
    WidgetTester tester,
  ) async {
    await pumpBranches(tester, const Size(1280, 900));

    final BranchController controller = Get.find<BranchController>();

    await tester.tap(find.text('Add New Branch'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('branch-name-field')),
      'Uttara Outlet',
    );
    await tester.enterText(
      find.byKey(const Key('branch-code-field')),
      'DHK-03',
    );
    await tester.enterText(
      find.byKey(const Key('branch-address-field')),
      'Plot 18, Sector 3, Uttara, Dhaka',
    );

    await tester.tap(find.byKey(const Key('branch-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Uttara Outlet'), findsOneWidget);
    expect(controller.branchRecords.length, 5);
    expect(controller.selectedBranch.value, 'Main Branch (DHK-01)');
    expect(tester.takeException(), isNull);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets('switching outlet updates the selected branch', (
    WidgetTester tester,
  ) async {
    await pumpBranches(tester, const Size(1920, 1080));

    final BranchController controller = Get.find<BranchController>();
    expect(controller.selectedBranch.value, 'Main Branch (DHK-01)');

    await tester.tap(find.text('Switch to this Branch').first);
    await tester.pumpAndSettle();

    // The first switchable card is Khulna, so the terminal moves there.
    expect(controller.selectedBranch.value, 'Khulna Branch (KHL-01)');
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });
}

Future<void> pumpBranches(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter', useMaterial3: true),
      home: const BranchesScreen(),
    ),
  );
  await tester.pumpAndSettle();
}
