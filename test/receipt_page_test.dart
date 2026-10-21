import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnix/core/routes/app_routes.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/receipt/model/receipt_document.dart';
import 'package:omnix/features/receipt/screens/public_receipt_screen.dart';
import 'package:omnix/features/receipt/utils/receipt_link.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  group('ReceiptDocument', () {
    test('encodes and decodes every receipt field', () {
      final ReceiptDocument original = sampleDocument();
      final ReceiptDocument? decoded = ReceiptDocument.tryDecode(
        original.encode(),
      );

      expect(decoded, isNotNull);
      final ReceiptDocument receipt = decoded!;

      expect(receipt.invoiceNumber, original.invoiceNumber);
      expect(receipt.branchName, original.branchName);
      expect(receipt.branchCode, original.branchCode);
      expect(receipt.branchAddress, original.branchAddress);
      expect(receipt.branchBin, original.branchBin);
      expect(receipt.cashierName, original.cashierName);
      expect(receipt.customerName, original.customerName);
      expect(receipt.tableLabel, original.tableLabel);
      expect(receipt.createdAt, original.createdAt);
      expect(receipt.items.length, original.items.length);
      expect(receipt.items.first.name, 'Beef Burger');
      expect(receipt.items.first.note, '+ Extra cheese, medium rare');
      expect(receipt.subtotal, original.subtotal);
      expect(receipt.vatPercent, original.vatPercent);
      expect(receipt.vat, original.vat);
      expect(receipt.cashoutPercent, original.cashoutPercent);
      expect(receipt.cashout, original.cashout);
      expect(receipt.total, original.total);
      expect(receipt.tenderLabel, original.tenderLabel);
      expect(receipt.paidAmount, original.paidAmount);
      expect(receipt.discount, original.discount);
      expect(receipt.changeDue, original.changeDue);
      expect(receipt.isCash, original.isCash);
      expect(receipt.isMobileWallet, original.isMobileWallet);
    });

    test('rejects missing and corrupt tokens', () {
      expect(ReceiptDocument.tryDecode(''), isNull);
      expect(ReceiptDocument.tryDecode('not-a-receipt'), isNull);
      expect(ReceiptDocument.tryDecode('eyJ2IjoxfQ'), isNull);
    });
  });

  group('ReceiptLink', () {
    test('builds a hash URL that points at the hosted receipt route with invoice only', () {
      final ReceiptDocument document = sampleDocument();
      final Uri uri = ReceiptLink.forDocument(document);

      expect(uri.fragment, startsWith('${AppRoutes.receipt}?invoice='));
      expect(uri.path, '/');

      final Uri? request = ReceiptLink.requestFromUri(uri);
      expect(request, isNotNull);
      expect(ReceiptLink.invoiceFromUri(request), document.invoiceNumber);
    });

    test('recognises both hash and path receipt URLs', () {
      final ReceiptDocument document = sampleDocument();

      final Uri hashUri = Uri.parse('https://pos.example.com/#/receipt?invoice=${document.invoiceNumber}');
      expect(ReceiptLink.requestFromUri(hashUri)?.path, AppRoutes.receipt);

      final Uri pathUri = Uri.parse('https://pos.example.com/receipt?invoice=${document.invoiceNumber}');
      expect(ReceiptLink.requestFromUri(pathUri)?.path, AppRoutes.receipt);

      expect(
        ReceiptLink.requestFromUri(Uri.parse('https://pos.example.com/')),
        isNull,
      );
    });

    test('backwards compatibility for old ?d= encoded URLs', () {
      final ReceiptDocument document = sampleDocument();
      final String token = document.encode();

      final Uri legacyUri = Uri.parse('https://pos.example.com/#/receipt?d=$token');
      final Uri? request = ReceiptLink.requestFromUri(legacyUri);
      expect(request, isNotNull);
      expect(ReceiptLink.documentFromUri(request), isNotNull);
      expect(ReceiptLink.documentFromUri(request)?.invoiceNumber, document.invoiceNumber);

      expect(ReceiptLink.invoiceFromUri(request), isNull);
    });
  });

  group('PublicReceiptScreen', () {
    testWidgets('renders the hosted page from an encoded receipt', (
      WidgetTester tester,
    ) async {
      final ReceiptDocument document = sampleDocument();

      await tester.pumpWidget(
        MaterialApp(home: PublicReceiptScreen(document: document)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Digital receipt'), findsOneWidget);
      expect(find.text('SALE INVOICE #1042'), findsOneWidget);
      expect(find.text('Beef Burger'), findsOneWidget);
      expect(find.text('NET TOTAL:'), findsOneWidget);
      expect(find.text('Scan for invoice details'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a phone width without layout errors', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(home: PublicReceiptScreen(document: sampleDocument())),
      );
      await tester.pumpAndSettle();

      expect(find.text('SALE INVOICE #1042'), findsOneWidget);
      expect(find.text('NET TOTAL:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows discount when cash is below the net total', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PublicReceiptScreen(
            document: sampleDocument(
              isCash: true,
              paidAmount: 1219,
              discount: 39,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discount:'), findsOneWidget);
      expect(find.text(formatTakaSymbol(39)), findsOneWidget);
      expect(find.text('Change Returned:'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows change returned when cash is above the net total', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PublicReceiptScreen(
            document: sampleDocument(
              isCash: true,
              paidAmount: 1300,
              changeDue: 42,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Change Returned:'), findsOneWidget);
      expect(find.text(formatTakaSymbol(42)), findsOneWidget);
      expect(find.text('Discount:'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows invoice lookup message for short invoice-only URLs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: PublicReceiptScreen(invoiceNumber: 1042)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invoice lookup'), findsOneWidget);
      expect(
        find.textContaining('This receipt link points to invoice number only'),
        findsOneWidget,
      );
      expect(find.text('Invoice #1042'), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

ReceiptDocument sampleDocument({
  bool isCash = false,
  int paidAmount = 1258,
  int discount = 0,
  int changeDue = 0,
}) {
  return ReceiptDocument(
    invoiceNumber: 1042,
    branchName: 'Sultans Dine Group',
    branchCode: 'Main Branch (DHK-01)',
    branchAddress: 'House 42, Road 11, Banani, Dhaka',
    branchBin: 'BIN: 002938172-0101 · Mushak-6.3',
    cashierName: 'Tanvir R.',
    customerName: 'Tanvir Ahmed',
    tableLabel: 'T-04 (Indoor)',
    createdAt: DateTime(2026, 10, 20, 14, 45),
    items: const <ReceiptLineItem>[
      ReceiptLineItem(
        name: 'Beef Burger',
        quantity: 2,
        price: 420,
        note: '+ Extra cheese, medium rare',
      ),
      ReceiptLineItem(name: 'Garlic Bread', quantity: 1, price: 180),
      ReceiptLineItem(name: 'Coke', quantity: 2, price: 80),
    ],
    subtotal: 1180,
    vatPercent: 5,
    vat: 59,
    cashoutPercent: 1.5,
    cashout: 19,
    total: 1258,
    tenderLabel: isCash ? 'Cash' : 'bKash / Nagad',
    paidAmount: paidAmount,
    discount: discount,
    changeDue: changeDue,
    isCash: isCash,
    isMobileWallet: !isCash,
  );
}
