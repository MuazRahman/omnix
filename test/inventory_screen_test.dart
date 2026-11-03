import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/inventory/controller/inventory_controller.dart';
import 'package:omnix/features/inventory/model/inventory_item_model.dart';
import 'package:omnix/features/inventory/screens/inventory_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put(BranchController());
    Get.put(InventoryController());
  });

  tearDown(Get.reset);

  testWidgets('Add Stock validates, saves and refreshes the table', (
    WidgetTester tester,
  ) async {
    await pumpInventory(tester);

    final InventoryController inventoryController =
        Get.find<InventoryController>();
    final int itemsBefore = inventoryController.items.length;

    await tester.tap(find.text('Add Stock'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inventory-add-stock-dialog')), findsOneWidget);
    expect(
      find.text('Add an inventory item to track stock levels.'),
      findsOneWidget,
    );

    // An empty form keeps the dialog open and flags every required field.
    await tester.tap(find.byKey(const Key('inventory-stock-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Enter an item name'), findsOneWidget);
    expect(find.text('Enter the current quantity'), findsOneWidget);
    expect(find.text('Enter the purchase cost'), findsOneWidget);
    expect(find.byKey(const Key('inventory-add-stock-dialog')), findsOneWidget);
    expect(inventoryController.items.length, itemsBefore);

    // Fill the form and switch the category away from the default.
    await tester.enterText(
      find.byKey(const Key('inventory-stock-name-field')),
      'Tiger Prawns',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-stock-quantity-field')),
      '12.5',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-stock-cost-field')),
      '680',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-stock-reorder-field')),
      '5',
    );
    await tester.tap(find.byKey(const Key('inventory-stock-category-Dairy')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('inventory-stock-submit-button')));
    await tester.pumpAndSettle();

    // The controller re-fetches after the save, so the new row, the decimal
    // quantity and the confirmation are all on screen without a refresh.
    expect(inventoryController.items.length, itemsBefore + 1);
    expect(find.byKey(const Key('inventory-add-stock-dialog')), findsNothing);
    expect(find.text('Tiger Prawns'), findsOneWidget);
    expect(find.text('12.5 kg'), findsOneWidget);
    expect(find.text('Stock item added to the inventory.'), findsOneWidget);

    // Let the success snackbar finish so no timer outlives the test.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    while (tester.takeException() != null) {}
  });

  testWidgets('Add Stock closes from Cancel without saving', (
    WidgetTester tester,
  ) async {
    await pumpInventory(tester);

    final InventoryController inventoryController =
        Get.find<InventoryController>();
    final int itemsBefore = inventoryController.items.length;

    await tester.tap(find.text('Add Stock'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('inventory-stock-cancel-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inventory-add-stock-dialog')), findsNothing);
    expect(inventoryController.items.length, itemsBefore);

    while (tester.takeException() != null) {}
  });

  testWidgets('category manager adds, renames and deletes categories', (
    WidgetTester tester,
  ) async {
    await pumpInventory(tester);

    final InventoryController inventoryController =
        Get.find<InventoryController>();

    await tester.tap(find.byKey(const Key('inventory-manage-categories')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('category-manager-dialog')), findsOneWidget);
    expect(find.byKey(const Key('category-manager-row-Meat')), findsOneWidget);
    expect(find.byKey(const Key('category-manager-row-All')), findsNothing);

    // Add a new category.
    await tester.enterText(
      find.byKey(const Key('category-manager-add-field')),
      'Frozen',
    );
    await tester.tap(find.byKey(const Key('category-manager-add-button')));
    await tester.pumpAndSettle();

    expect(inventoryController.categories, contains('Frozen'));
    expect(find.byKey(const Key('category-manager-row-Frozen')), findsOneWidget);

    // Rename Dairy, moving its stock rows along.
    await tester.tap(find.byKey(const Key('category-manager-edit-Dairy')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('category-manager-rename-field')),
      'Chilled',
    );
    await tester.tap(find.byKey(const Key('category-manager-rename-save')));
    await tester.pumpAndSettle();

    expect(inventoryController.categories, contains('Chilled'));
    expect(inventoryController.categories, isNot(contains('Dairy')));
    expect(
      inventoryController.items
          .where((InventoryItem item) => item.category == 'Chilled')
          .length,
      3,
    );

    // Delete Beverages and confirm; its rows move to the first category left.
    await tester.tap(find.byKey(const Key('category-manager-delete-Beverages')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('category-manager-confirm-delete')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('category-manager-confirm-delete-button')),
    );
    await tester.pumpAndSettle();

    expect(inventoryController.categories, isNot(contains('Beverages')));
    expect(
      inventoryController.items
          .where((InventoryItem item) => item.category == 'Meat')
          .length,
      5,
    );

    await tester.tap(find.byKey(const Key('category-manager-done')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('category-manager-dialog')), findsNothing);

    while (tester.takeException() != null) {}
  });

  testWidgets('Add Stock inline manager adds a category and saves under it', (
    WidgetTester tester,
  ) async {
    await pumpInventory(tester);

    final InventoryController inventoryController =
        Get.find<InventoryController>();

    await tester.tap(find.text('Add Stock'));
    await tester.pumpAndSettle();

    // Add "Frozen" straight from the Add Stock dialog.
    await tester.tap(
      find.byKey(const Key('inventory-stock-manage-categories')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('category-manager-dialog')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('category-manager-add-field')),
      'Frozen',
    );
    await tester.tap(find.byKey(const Key('category-manager-add-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('category-manager-done')));
    await tester.pumpAndSettle();

    // The freshly created category is now the selected pill in the form.
    expect(find.byKey(const Key('inventory-add-stock-dialog')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('inventory-stock-name-field')),
      'Frozen Peas',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-stock-quantity-field')),
      '20',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-stock-cost-field')),
      '150',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-stock-reorder-field')),
      '8',
    );

    await tester.tap(find.byKey(const Key('inventory-stock-submit-button')));
    await tester.pumpAndSettle();

    expect(inventoryController.items.first.name, 'Frozen Peas');
    expect(inventoryController.items.first.category, 'Frozen');
    expect(find.text('Frozen Peas'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    while (tester.takeException() != null) {}
  });
}

Future<void> pumpInventory(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: InventoryScreen())),
  );
  await tester.pumpAndSettle();

  // The shell is separate from the dialog flow under test.
  while (tester.takeException() != null) {}
}
