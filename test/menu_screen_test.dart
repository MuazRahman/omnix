import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';
import 'package:omnix/features/menu/screens/menu_screen.dart';
import 'package:omnix/features/menu/widgets/menu_grid_view_widget.dart';
import 'package:omnix/features/menu/widgets/menu_table_widget.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put(BranchController());
    Get.put(MenuController());
  });

  tearDown(Get.reset);

  testWidgets('menu management renders the catalog and health ribbon', (
    WidgetTester tester,
  ) async {
    await pumpMenu(tester, const Size(1920, 1080));

    expect(find.text('Menu Management'), findsOneWidget);
    expect(find.text('ACTIVE DISHES'), findsOneWidget);
    expect(find.text('AVG FOOD COST MARGIN'), findsOneWidget);
    expect(find.text('KITCHEN AVAILABILITY'), findsOneWidget);
    expect(find.text('TOP GROSSING SEGMENT'), findsOneWidget);
    expect(find.text('Lemon Tea'), findsOneWidget);
    expect(find.byType(MenuTableWidget), findsOneWidget);

    // Biryani has a lower margin, so it lands on the second page by default.
    await tester.ensureVisible(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Kacchi Biryani'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category and search filters narrow the table', (
    WidgetTester tester,
  ) async {
    await pumpMenu(tester, const Size(1920, 1080));

    await tester.tap(find.text('Rice (3)'));
    await tester.pumpAndSettle();

    expect(find.text('Kacchi Biryani'), findsOneWidget);
    expect(find.text('Chicken Wings'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('menu-search-field')),
      'biryani',
    );
    await tester.pumpAndSettle();

    expect(find.text('Kacchi Biryani'), findsOneWidget);
    expect(find.text('Fried Rice'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('view toggle switches between table and grid', (
    WidgetTester tester,
  ) async {
    await pumpMenu(tester, const Size(1920, 1080));

    await tester.tap(find.byTooltip('Grid view'));
    await tester.pumpAndSettle();

    expect(find.byType(MenuGridViewWidget), findsOneWidget);
    expect(find.byType(MenuTableWidget), findsNothing);

    await tester.tap(find.byTooltip('Table view'));
    await tester.pumpAndSettle();

    expect(find.byType(MenuTableWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edit dish dialog is pre-filled and saves changes', (
    WidgetTester tester,
  ) async {
    await pumpMenu(tester, const Size(1920, 1080));

    await tester.tap(find.byTooltip('Edit dish').first);
    await tester.pumpAndSettle();

    // The shared form switches to its edit mode.
    expect(find.text('Edit Menu Item'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // The existing name is loaded into the field.
    final TextFormField nameField = tester.widget<TextFormField>(
      find.byKey(const Key('menu-dish-name-field')),
    );
    expect(nameField.controller?.text, 'Lemon Tea');

    await tester.enterText(
      find.byKey(const Key('menu-dish-name-field')),
      'Renamed Special',
    );
    await tester.tap(find.byKey(const Key('menu-dish-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Renamed Special'), findsOneWidget);
    expect(find.text('Lemon Tea'), findsNothing);
    expect(tester.takeException(), isNull);

    // Drop the confirmation snackbar so its timer does not outlive the test.
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  for (final Size size in const [Size(700, 1000), Size(500, 900)]) {
    testWidgets(
      'menu screen stays usable at ${size.width.toInt()}px wide',
      (WidgetTester tester) async {
        await pumpMenu(tester, size);

        expect(find.text('Menu Management'), findsOneWidget);
        expect(find.byType(MenuTableWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> pumpMenu(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter', useMaterial3: true),
      home: const MenuScreen(),
    ),
  );
  await tester.pumpAndSettle();
}
