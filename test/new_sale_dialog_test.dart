import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/customers/controller/customer_controller.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/model/pos_order_type_model.dart';
import 'package:omnix/features/pos/widgets/new_sale_dialog_widget.dart';
import 'package:omnix/features/staff/controller/staff_controller.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put(BranchController());
    Get.put(CustomerController());
    Get.put(StaffController());
    Get.put(PosController());
  });

  tearDown(Get.reset);

  testWidgets('new sale dialog collects mode, table and customer', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Center(
              child: ElevatedButton(
                onPressed: () => openNewSaleDialog(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Start New Order Ticket'), findsOneWidget);
    expect(find.text('STEP 1 · ORDER MODE'), findsOneWidget);
    expect(find.text('STEP 2 · TABLE & SEATING DETAILS'), findsOneWidget);
    expect(find.text('T-03'), findsOneWidget);
    expect(find.text('ACTIVE'), findsWidgets);

    // Takeaway hides the floor plan but keeps the customer step.
    await tester.tap(find.text('Takeaway / Counter'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 2 · TABLE & SEATING DETAILS'), findsNothing);
    expect(find.text('STEP 3 · CUSTOMER ASSIGNMENT'), findsOneWidget);

    // Back to dine-in, then pick a free table.
    await tester.tap(find.text('Dine-In'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('T-05'));
    await tester.pumpAndSettle();

    // The guest count is clamped to the seats of the picked table.
    expect(find.text('Table Cap: 2'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('new-sale-customer-field')),
      '01819-876543',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('new-sale-matched-customer')), findsOneWidget);

    final PosController posController = Get.find<PosController>();
    final int invoiceBefore = posController.invoiceNumber.value;

    await tester.tap(find.byKey(const Key('new-sale-start-button')));
    await tester.pumpAndSettle();

    expect(find.text('Start New Order Ticket'), findsNothing);
    expect(posController.orderType.value, PosOrderType.dineIn);
    expect(posController.tableLabel.value, 'T-05 (Indoor)');
    expect(posController.paxCount.value, 2);
    expect(posController.customer.value?.name, 'Nusrat Jahan');
    expect(posController.invoiceNumber.value, invoiceBefore + 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new sale dialog fits a compact window', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(640, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Center(
              child: ElevatedButton(
                onPressed: () => openNewSaleDialog(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Start New Order Ticket'), findsOneWidget);
    expect(find.text('STEP 3 · CUSTOMER ASSIGNMENT'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('new-sale-start-button')),
        matching: find.text('Open POS Terminal & Start Adding Items'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
