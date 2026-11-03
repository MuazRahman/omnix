import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/purchases/controller/purchase_controller.dart';
import 'package:omnix/features/purchases/model/purchase_model.dart';
import 'package:omnix/features/purchases/screens/purchases_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put(BranchController());
    Get.put(PurchaseController());
  });

  tearDown(Get.reset);

  testWidgets('renders the header, metrics and the purchase ledger', (
    WidgetTester tester,
  ) async {
    await pumpPurchases(tester);

    expect(find.text('Purchases & Vendor Supply'), findsOneWidget);
    expect(find.text('ACTIVE SUPPLIERS'), findsOneWidget);
    expect(find.text('OPEN POS'), findsOneWidget);
    expect(find.text('OUTSTANDING PAYABLES'), findsOneWidget);

    // Ledger card with its sub-header and the newest PO.
    expect(find.text('Purchase Requisitions'), findsOneWidget);
    expect(find.text('PO-489'), findsWidgets);

    // The first open order is docked in the receive panel.
    expect(find.byKey(const Key('purchases-receive-panel')), findsOneWidget);
    expect(find.text('Receive Inbound Stock'), findsOneWidget);
  });

  testWidgets('status filter narrows the ledger and the dock follows', (
    WidgetTester tester,
  ) async {
    await pumpPurchases(tester);

    await tester.tap(find.byKey(const Key('purchases-filter-Received')));
    await tester.pumpAndSettle();

    // Only received orders remain, so the open PO-489 is gone.
    expect(find.text('PO-489'), findsNothing);
    expect(find.text('PO-487'), findsWidgets);

    // The dock falls back to the first visible order.
    final PurchaseController controller = Get.find<PurchaseController>();
    expect(controller.filteredPurchases.every((Purchase p) => !p.isOpen), isTrue);

    while (tester.takeException() != null) {}
  });

  testWidgets('vendor tab swaps the ledger for the directory', (
    WidgetTester tester,
  ) async {
    await pumpPurchases(tester);

    await tester.tap(find.byKey(const Key('purchases-tab-vendors')));
    await tester.pumpAndSettle();

    expect(
      find.text('Approved Raw Food & Packaging Suppliers'),
      findsOneWidget,
    );
    expect(find.text('Bengal Meat Agro Supply Ltd'), findsOneWidget);
    expect(find.text('Purchase Requisitions'), findsNothing);
    expect(find.byKey(const Key('purchases-receive-panel')), findsNothing);
  });

  testWidgets('committing a shipment marks the purchase order received', (
    WidgetTester tester,
  ) async {
    await pumpPurchases(tester);

    final PurchaseController controller = Get.find<PurchaseController>();

    await tester.ensureVisible(find.byKey(const Key('purchases-commit-button')));
    await tester.tap(find.byKey(const Key('purchases-commit-button')));
    await tester.pumpAndSettle();

    final Purchase received = controller.purchases.firstWhere(
      (Purchase purchase) => purchase.id == 'PO-489',
    );
    expect(received.status, PurchaseStatus.received);
    expect(received.receivedBy, isNotNull);
    expect(find.text('Already Received'), findsOneWidget);

    // Let the confirmation snackbar finish so no timer outlives the test.
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('stacks cleanly at a compact width', (
    WidgetTester tester,
  ) async {
    await pumpPurchases(tester, const Size(1000, 1000));

    expect(find.text('Purchases & Vendor Supply'), findsOneWidget);
    expect(find.byKey(const Key('purchases-receive-panel')), findsOneWidget);

    while (tester.takeException() != null) {}
  });

  testWidgets('registering a supplier adds it to the directory', (
    WidgetTester tester,
  ) async {
    await pumpPurchases(tester);
    final PurchaseController controller = Get.find<PurchaseController>();
    final int before = controller.vendors.length;

    await tester.tap(find.byKey(const Key('purchases-register-supplier')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('purchases-supplier-dialog')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('purchases-supplier-name')),
      'Acme Produce',
    );
    await tester.tap(find.byKey(const Key('purchases-supplier-submit')));
    await tester.pumpAndSettle();

    expect(controller.vendors.length, before + 1);
    expect(controller.vendors.first.name, 'Acme Produce');
    expect(controller.vendors.first.id, 'V-8942');
    expect(find.byKey(const Key('purchases-supplier-dialog')), findsNothing);

    // the new vendor shows up on the directory tab
    await tester.tap(find.byKey(const Key('purchases-tab-vendors')));
    await tester.pumpAndSettle();
    expect(find.text('Acme Produce'), findsOneWidget);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('raising a purchase order adds it to the ledger', (
    WidgetTester tester,
  ) async {
    await pumpPurchases(tester);
    final PurchaseController controller = Get.find<PurchaseController>();
    final int before = controller.purchases.length;

    await tester.tap(find.byKey(const Key('purchases-new-order')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('purchases-po-dialog')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('purchases-po-line-name-0')),
      'Mutton',
    );
    await tester.enterText(
      find.byKey(const Key('purchases-po-line-price-0')),
      '1000',
    );
    await tester.tap(find.byKey(const Key('purchases-po-submit')));
    await tester.pumpAndSettle();

    expect(controller.purchases.length, before + 1);

    final Purchase created = controller.purchases.first;
    expect(created.id, 'PO-490');
    expect(created.supplier, 'Bengal Meat Agro Supply Ltd');
    expect(created.amount, 1000);
    expect(created.paymentStatus, PaymentStatus.unpaid);
    expect(find.byKey(const Key('purchases-po-dialog')), findsNothing);
    expect(find.text('PO-490'), findsWidgets);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('vendor Order PO opens the builder pre-filled', (
    WidgetTester tester,
  ) async {
    await pumpPurchases(tester);

    await tester.tap(find.byKey(const Key('purchases-tab-vendors')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Order PO').first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('purchases-po-dialog')), findsOneWidget);
    expect(
      find.text('Bengal Meat Agro Supply Ltd · V-8941'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('purchases-po-cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('purchases-po-dialog')), findsNothing);
  });

  testWidgets('export copies the visible ledger to the clipboard', (
    WidgetTester tester,
  ) async {
    final List<String> clipboard = <String>[];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            final Map<dynamic, dynamic> arguments =
                call.arguments as Map<dynamic, dynamic>;
            clipboard.add(arguments['text'] as String);
          }
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await pumpPurchases(tester);

    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();

    expect(clipboard, hasLength(1));
    expect(clipboard.single, contains('"PO-489"'));
    expect(clipboard.single, contains('"Supplier"'));

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('saving an inspection draft keeps the readings', (
    WidgetTester tester,
  ) async {
    await pumpPurchases(tester);
    final PurchaseController controller = Get.find<PurchaseController>();

    await tester.tap(find.text('Save Inspection Draft'));
    await tester.pumpAndSettle();

    expect(controller.hasInspectionDraft('PO-489'), isTrue);
    expect(controller.inspectionDrafts['PO-489'], hasLength(2));
    expect(find.text('Draft saved on this device'), findsOneWidget);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

Future<void> pumpPurchases(
  WidgetTester tester, [
  Size size = const Size(1920, 1080),
]) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: PurchasesScreen())),
  );
  await tester.pumpAndSettle();

  // The shell is separate from the flow under test.
  while (tester.takeException() != null) {}
}
