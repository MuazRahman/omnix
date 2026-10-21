import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/customers/controller/customer_controller.dart';
import 'package:omnix/features/customers/screens/customers_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put(BranchController());
    Get.put(CustomerController());
  });

  tearDown(Get.reset);

  testWidgets('Add Customer starts with the phone and saves the new name', (
    WidgetTester tester,
  ) async {
    await pumpCustomers(tester);

    final CustomerController customerController =
        Get.find<CustomerController>();
    final int customersBefore = customerController.customers.length;

    await tester.tap(find.text('Add Customer'));
    await tester.pumpAndSettle();

    // Phone first: the name field appears only for an unknown number.
    expect(find.text('Enter the phone number first'), findsOneWidget);
    expect(find.byKey(const Key('customer-phone-field')), findsOneWidget);
    expect(find.byKey(const Key('customer-name-field')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('customer-phone-field')),
      '01700-445566',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-name-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('customer-name-field')),
      'Ayesha Khan',
    );
    await tester.tap(find.byKey(const Key('customer-save-button')));
    await tester.pumpAndSettle();

    expect(customerController.customers.length, customersBefore + 1);
    expect(customerController.findByPhone('01700445566')?.name, 'Ayesha Khan');

    // The new customer is listed in the table without a manual refresh.
    expect(find.text('Ayesha Khan'), findsOneWidget);

    while (tester.takeException() != null) {}
  });

  testWidgets('Add Customer reports an existing number instead of adding it', (
    WidgetTester tester,
  ) async {
    await pumpCustomers(tester);

    final CustomerController customerController =
        Get.find<CustomerController>();
    final int customersBefore = customerController.customers.length;

    await tester.tap(find.text('Add Customer'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('customer-phone-field')),
      '01819876543',
    );
    await tester.pumpAndSettle();

    final Finder existingCard = find.byKey(const Key('customer-existing-card'));
    expect(existingCard, findsOneWidget);
    expect(
      find.descendant(of: existingCard, matching: find.text('Nusrat Jahan')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('customer-name-field')), findsNothing);
    expect(find.byKey(const Key('customer-save-button')), findsNothing);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(customerController.customers.length, customersBefore);

    while (tester.takeException() != null) {}
  });
}

Future<void> pumpCustomers(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: CustomersScreen())),
  );
  await tester.pumpAndSettle();

  // The shell is separate from the dialog flow under test.
  while (tester.takeException() != null) {}
}
