import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:omnix/features/receipt/model/receipt_document.dart';
import 'package:omnix/features/receipt/printer/receipt_pdf_builder.dart';

void main() {
  ReceiptDocument receipt() {
    return ReceiptDocument(
      invoiceNumber: 1042,
      branchName: 'Sultans Dine Group',
      branchCode: 'Main Branch (DHK-01)',
      branchAddress: 'House 42, Road 11, Banani, Dhaka',
      branchBin: 'BIN: 002938172-0101',
      cashierName: 'Tanvir R.',
      customerName: 'Nusrat Jahan',
      tableLabel: 'T-04 (Indoor)',
      createdAt: DateTime(2026, 10, 22, 19, 5),
      items: const [
        ReceiptLineItem(
          name: 'Beef Burger',
          quantity: 2,
          price: 420,
          note: '+ Extra cheese',
        ),
        ReceiptLineItem(name: 'Coke', quantity: 2, price: 80),
      ],
      subtotal: 1000,
      vatPercent: 5,
      vat: 50,
      cashoutPercent: 1.5,
      cashout: 0,
      total: 1050,
      tenderLabel: 'POS Card',
      paidAmount: 1050,
      discount: 0,
      changeDue: 0,
      isCash: false,
      isMobileWallet: false,
    );
  }

  test('builds one 80mm receipt page per copy', () async {
    final Uint8List single = await ReceiptPdfBuilder.build(
      document: receipt(),
      qrData: 'https://example.com/#/receipt?d=token',
    );
    final Uint8List triple = await ReceiptPdfBuilder.build(
      document: receipt(),
      qrData: 'https://example.com/#/receipt?d=token',
      copies: 3,
    );

    expect(String.fromCharCodes(single.take(5)), '%PDF-');
    expect(single.length, greaterThan(1000));
    // Three copies add pages, so the file has to grow.
    expect(triple.length, greaterThan(single.length));
  });

  test('prints without a QR block', () async {
    final Uint8List bytes = await ReceiptPdfBuilder.build(document: receipt());

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('builds the printer test slip', () async {
    final Uint8List bytes = await ReceiptPdfBuilder.buildTestPage(
      printerName: 'EPSON TM-T82',
    );

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
