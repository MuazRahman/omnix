import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/customers/controller/customer_controller.dart';
import 'package:omnix/features/customers/model/customer_model.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/screens/pos_screen.dart';
import 'package:omnix/features/pos/widgets/pos_cart_line_widget.dart';
import 'package:omnix/features/pos/widgets/pos_menu_item_card_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put(BranchController());
    Get.put(CustomerController());
    Get.put(PosController());
  });

  tearDown(Get.reset);

  testWidgets('POS screen renders the menu, cart and receipt preview', (
    WidgetTester tester,
  ) async {
    await pumpPos(tester, const Size(1920, 1080));

    // catalog and live ticket are both on screen
    expect(find.text('Ticket #1042'), findsOneWidget);
    expect(find.text('Complete Sale & Print'), findsOneWidget);
    expect(find.text('Beef Burger'), findsWidgets);

    // A customer phone must be attached before the ticket can be printed.
    await attachExistingCustomer(tester);
    expect(find.text('Nusrat Jahan'), findsOneWidget);

    // charging the ticket opens the thermal receipt preview
    await tester.tap(find.text('Complete Sale & Print'));
    await tester.pumpAndSettle();

    expect(find.text('Receipt Preview'), findsOneWidget);
    expect(find.text('Print 80mm'), findsOneWidget);

    final Finder qrFinder = find.byType(QrImageView);
    expect(qrFinder, findsOneWidget);
    expect(
      tester.widget<QrImageView>(qrFinder).semanticsLabel,
      contains('1042'),
    );

    expectNoLayoutExceptions(tester);
  });

  testWidgets('POS screen fits the app shell at 1440x900', (
    WidgetTester tester,
  ) async {
    await pumpPos(tester, const Size(1440, 900), contentWidth: 1180);

    expect(find.text('Complete Sale & Print'), findsOneWidget);
    expect(find.text('Ticket #1042'), findsOneWidget);

    expectNoLayoutExceptions(tester);
  });

  testWidgets('POS screen stays usable in a compact window', (
    WidgetTester tester,
  ) async {
    await pumpPos(tester, const Size(1024, 768), contentWidth: 764);

    expect(find.text('Complete Sale & Print'), findsOneWidget);
    expect(find.text('All Items'), findsOneWidget);

    expectNoLayoutExceptions(tester);
  });

  testWidgets('table and guest count are only shown for dine-in', (
    WidgetTester tester,
  ) async {
    await pumpPos(tester, const Size(1920, 1080));

    expect(find.text('ASSIGNED TABLE'), findsOneWidget);
    expect(find.text('3 Pax'), findsOneWidget);
    expect(
      find.text('Dine-in · Table T-04 (Indoor) · Server: Tanvir R.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Takeaway'));
    await tester.pumpAndSettle();

    expect(find.text('ASSIGNED TABLE'), findsNothing);
    expect(find.text('3 Pax'), findsNothing);
    expect(find.text('Takeaway · Server: Tanvir R.'), findsOneWidget);

    await tester.tap(find.text('Delivery'));
    await tester.pumpAndSettle();

    expect(find.text('ASSIGNED TABLE'), findsNothing);
    expect(find.text('3 Pax'), findsNothing);
    expect(find.text('Delivery · Server: Tanvir R.'), findsOneWidget);

    // Going back to dine-in restores the table and guest selector.
    await tester.tap(find.text('Dine-in'));
    await tester.pumpAndSettle();

    expect(find.text('ASSIGNED TABLE'), findsOneWidget);
    expect(find.text('3 Pax'), findsOneWidget);

    expectNoLayoutExceptions(tester);
  });

  testWidgets('takeaway receipt omits the table row', (
    WidgetTester tester,
  ) async {
    await pumpPos(tester, const Size(1920, 1080));
    await attachExistingCustomer(tester);

    await tester.tap(find.text('Takeaway'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Sale & Print'));
    await tester.pumpAndSettle();

    expect(find.text('Receipt Preview'), findsOneWidget);
    expect(find.text('Table'), findsNothing);
    expect(find.text('T-04 (Indoor)'), findsNothing);

    expectNoLayoutExceptions(tester);
  });

  testWidgets('menu card quantity follows cart additions and removals', (
    WidgetTester tester,
  ) async {
    await pumpPos(tester, const Size(1920, 1080));

    Finder cardFor(String name) => find.ancestor(
      of: find.text(name),
      matching: find.byType(PosMenuItemCardWidget),
    );

    // Chicken Wings is not part of the preloaded ticket.
    expect(
      find.descendant(of: cardFor('Chicken Wings'), matching: find.text('Add')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: cardFor('Chicken Wings'), matching: find.text('Add')),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: cardFor('Chicken Wings'),
        matching: find.text('Add · 1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: cardFor('Chicken Wings'), matching: find.text('×1')),
      findsOneWidget,
    );

    // Removing the only unit clears the quantity badge and amber state.
    final Finder cartLine = find.widgetWithText(
      PosCartLineWidget,
      'Chicken Wings',
    );
    expect(cartLine, findsOneWidget);

    await tester.tap(
      find.descendant(of: cartLine, matching: find.byIcon(Icons.remove)),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: cardFor('Chicken Wings'), matching: find.text('Add')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: cardFor('Chicken Wings'), matching: find.text('×1')),
      findsNothing,
    );

    expectNoLayoutExceptions(tester);
  });

  testWidgets(
    'phone lookup attaches an existing customer and enables printing',
    (WidgetTester tester) async {
      await pumpPos(tester, const Size(1920, 1080));

      final PosController posController = Get.find<PosController>();
      final Finder printButton = find.widgetWithText(
        ElevatedButton,
        'Complete Sale & Print',
      );

      expect(posController.customer.value, isNull);
      expect(find.text('Customer phone required'), findsOneWidget);
      expect(find.text('Add a number to print'), findsOneWidget);
      expect(find.text('Add Phone'), findsOneWidget);
      expect(
        find.text('Add a customer phone number to print this sale.'),
        findsOneWidget,
      );
      expect(tester.widget<ElevatedButton>(printButton).onPressed, isNull);

      await tester.tap(find.byKey(const Key('pos-customer-action-button')));
      await tester.pumpAndSettle();

      // The phone comes first; the name field is not shown yet.
      expect(find.text('Attach Customer'), findsOneWidget);
      expect(find.byKey(const Key('customer-phone-field')), findsOneWidget);
      expect(find.byKey(const Key('customer-name-field')), findsNothing);

      // A short number is not enough to start a customer.
      await tester.enterText(
        find.byKey(const Key('customer-phone-field')),
        '01819',
      );
      await tester.pump();
      expect(find.byKey(const Key('customer-name-field')), findsNothing);
      expect(find.text('Enter at least 6 digits'), findsOneWidget);

      // The formatted number in the directory still matches digit-only input.
      await tester.enterText(
        find.byKey(const Key('customer-phone-field')),
        '01819876543',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer-existing-card')), findsOneWidget);
      expect(find.text('Nusrat Jahan'), findsOneWidget);
      expect(find.byKey(const Key('customer-name-field')), findsNothing);

      await tester.tap(find.byKey(const Key('customer-use-existing-button')));
      await tester.pumpAndSettle();

      expect(posController.customer.value?.name, 'Nusrat Jahan');
      expect(posController.customer.value?.phone, '01819-876543');
      expect(posController.customer.value?.id, 'CUS-002');
      expect(find.text('Nusrat Jahan'), findsOneWidget);
      expect(find.text('01819-876543'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(tester.widget<ElevatedButton>(printButton).onPressed, isNotNull);

      await tester.tap(find.text('Complete Sale & Print'));
      await tester.pumpAndSettle();

      expect(find.text('Receipt Preview'), findsOneWidget);
      expect(find.text('Nusrat Jahan'), findsWidgets);

      expectNoLayoutExceptions(tester);
    },
  );

  testWidgets('a new customer can be added without a name and prints N/A', (
    WidgetTester tester,
  ) async {
    await pumpPos(tester, const Size(1920, 1080));

    final PosController posController = Get.find<PosController>();
    final CustomerController customerController =
        Get.find<CustomerController>();

    await tester.tap(find.byKey(const Key('pos-customer-action-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('customer-phone-field')),
      '01700-112233',
    );
    await tester.pumpAndSettle();

    // A new number reveals the optional name field.
    expect(find.byKey(const Key('customer-name-field')), findsOneWidget);
    expect(
      find.textContaining('No customer found for this number'),
      findsOneWidget,
    );

    // Leaving the name blank saves a null name.
    await tester.tap(find.byKey(const Key('customer-save-button')));
    await tester.pumpAndSettle();

    expect(posController.customer.value?.name, isNull);
    expect(posController.customer.value?.displayName, 'N/A');
    expect(find.text('N/A'), findsOneWidget);
    expect(find.text('01700-112233'), findsOneWidget);

    final Customer savedCustomer = customerController.customers.first;
    expect(savedCustomer.name, isNull);
    expect(savedCustomer.displayName, 'N/A');
    expect(savedCustomer.phone, '01700-112233');
    expect(savedCustomer.visits, 0);

    // The receipt shows N/A for the blank customer name as well.
    await tester.tap(find.text('Complete Sale & Print'));
    await tester.pumpAndSettle();

    expect(find.text('Receipt Preview'), findsOneWidget);
    expect(find.text('N/A'), findsWidgets);

    expectNoLayoutExceptions(tester);
  });

  testWidgets('cash received entry shows change and discount', (
    WidgetTester tester,
  ) async {
    await pumpPos(tester, const Size(1920, 1080));

    final PosController posController = Get.find<PosController>();
    final Finder cashField = find.byKey(const Key('pos-cash-received-field'));
    expect(cashField, findsOneWidget);

    // More than the total: show the change to return.
    await tester.enterText(cashField, '2000');
    await tester.pump();

    expect(find.text('Given ${formatTakaSymbol(2000)}'), findsOneWidget);
    expect(
      find.text('Change ${formatTakaSymbol(2000 - posController.total)}'),
      findsOneWidget,
    );

    // Less than the total: the difference is treated as a discount.
    await tester.enterText(cashField, '1000');
    await tester.pump();

    expect(
      find.text('Discount ${formatTakaSymbol(posController.total - 1000)}'),
      findsOneWidget,
    );

    // Paying the exact total leaves no change.
    await tester.enterText(cashField, '${posController.total}');
    await tester.pump();

    expect(
      find.text('Given ${formatTakaSymbol(posController.total)}'),
      findsOneWidget,
    );
    expect(find.text('Change ${formatTakaSymbol(0)}'), findsOneWidget);

    expectNoLayoutExceptions(tester);
  });

  testWidgets('cash below net payable prints a discount on the receipt', (
    WidgetTester tester,
  ) async {
    await pumpPos(tester, const Size(1920, 1080));
    await attachExistingCustomer(tester);

    final PosController posController = Get.find<PosController>();
    final int discount = 39;
    final int cash = posController.total - discount;

    await tester.enterText(
      find.byKey(const Key('pos-cash-received-field')),
      '$cash',
    );
    await tester.pump();

    expect(posController.discountAmount, discount);
    expect(find.text('Discount ${formatTakaSymbol(discount)}'), findsOneWidget);

    await tester.tap(find.text('Complete Sale & Print'));
    await tester.pumpAndSettle();

    // The lower cash amount is kept as paid, and the difference is a discount.
    expect(posController.cashReceived.value, cash);
    expect(find.text('Receipt Preview'), findsOneWidget);
    expect(find.text('Paid (Cash):'), findsOneWidget);
    expect(find.text('Discount:'), findsOneWidget);
    expect(find.text(formatTakaSymbol(discount)), findsWidgets);
    expect(find.text('Change Returned:'), findsNothing);

    expectNoLayoutExceptions(tester);
  });

  testWidgets('cash above net payable prints the change returned', (
    WidgetTester tester,
  ) async {
    await pumpPos(tester, const Size(1920, 1080));
    await attachExistingCustomer(tester);

    final PosController posController = Get.find<PosController>();
    final int change = 61;
    final int cash = posController.total + change;

    await tester.enterText(
      find.byKey(const Key('pos-cash-received-field')),
      '$cash',
    );
    await tester.pump();

    expect(find.text('Change ${formatTakaSymbol(change)}'), findsOneWidget);

    await tester.tap(find.text('Complete Sale & Print'));
    await tester.pumpAndSettle();

    expect(posController.cashReceived.value, cash);
    expect(find.text('Receipt Preview'), findsOneWidget);
    expect(find.text('Change Returned:'), findsOneWidget);
    expect(find.text(formatTakaSymbol(change)), findsWidgets);
    expect(find.text('Discount:'), findsNothing);

    expectNoLayoutExceptions(tester);
  });

  testWidgets('bKash/Nagad adds an editable cashout charge', (
    WidgetTester tester,
  ) async {
    await pumpPos(tester, const Size(1920, 1080));

    final PosController posController = Get.find<PosController>();
    final int billBeforeCharge = posController.total;

    await tester.tap(find.text('bKash / Nagad'));
    await tester.pump();

    final int defaultCharge = (billBeforeCharge * 1.5 / 100).round();
    expect(posController.mobileWalletCashoutCharge, defaultCharge);
    expect(posController.total, billBeforeCharge + defaultCharge);

    final Finder chargeButton = find.byKey(
      const Key('pos-mobile-wallet-charge-button'),
    );
    expect(chargeButton, findsOneWidget);

    await tester.tap(chargeButton);
    await tester.pumpAndSettle();

    final Finder percentField = find.byKey(
      const Key('pos-cashout-charge-field'),
    );
    expect(percentField, findsOneWidget);
    expect(tester.widget<TextField>(percentField).controller?.text, '1.5');

    await tester.enterText(percentField, '2.5');
    await tester.pump();
    await tester.tap(find.byKey(const Key('pos-cashout-charge-apply')));
    await tester.pumpAndSettle();

    final int editedCharge = (billBeforeCharge * 2.5 / 100).round();
    expect(posController.mobileWalletCashoutPercent.value, 2.5);
    expect(posController.mobileWalletCashoutCharge, editedCharge);
    expect(posController.total, billBeforeCharge + editedCharge);
    expect(find.textContaining('2.5%'), findsWidgets);

    // The cashout charge applies only to bKash/Nagad.
    await tester.tap(find.text('Cash'));
    await tester.pump();
    expect(posController.mobileWalletCashoutCharge, 0);
    expect(posController.total, billBeforeCharge);

    await tester.tap(find.text('POS Card'));
    await tester.pump();
    expect(posController.mobileWalletCashoutCharge, 0);
    expect(posController.total, billBeforeCharge);

    expectNoLayoutExceptions(tester);
  });
}

Future<void> pumpPos(
  WidgetTester tester,
  Size window, {
  double? contentWidth,
}) async {
  tester.view.physicalSize = window;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final Widget screen = contentWidth == null
      ? const PosScreen()
      : SizedBox(width: contentWidth, child: const PosScreen());

  await tester.pumpWidget(
    GetMaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Align(alignment: Alignment.centerLeft, child: screen),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> attachExistingCustomer(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('pos-customer-action-button')));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(const Key('customer-phone-field')),
    '01819-876543',
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('customer-use-existing-button')));
  await tester.pumpAndSettle();
}

// Any layout exception (including the shared top bar) fails the test.
void expectNoLayoutExceptions(WidgetTester tester) {
  final List<Object> exceptions = <Object>[];

  Object? exception = tester.takeException();
  while (exception != null) {
    exceptions.add(exception);
    exception = tester.takeException();
  }

  expect(exceptions, isEmpty);
}
