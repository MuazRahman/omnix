import 'dart:typed_data';

import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/receipt/model/receipt_document.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Renders the invoice as an 80mm thermal print job.
///
/// This is the paper twin of [ReceiptPaperWidget]: same information, same
/// order, but laid out for a receipt roll instead of a dialog. The ৳ glyph is
/// not part of the PDF built-in fonts, so printed amounts use the `Tk` suffix.
abstract final class ReceiptPdfBuilder {
  const ReceiptPdfBuilder._();

  static const double widthMm = 80;

  static const double _horizontalMargin = 4 * PdfPageFormat.mm;
  static const double _verticalMargin = 3 * PdfPageFormat.mm;

  /// [printerName] is only used to prove which device printed the slip.
  static Future<Uint8List> buildTestPage({
    required String printerName,
    DateTime? createdAt,
  }) async {
    final DateTime now = createdAt ?? DateTime.now();
    final pw.Document pdf = pw.Document(
      title: 'Printer test',
      creator: 'Omnix POS',
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          widthMm * PdfPageFormat.mm,
          70 * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.symmetric(
          horizontal: _horizontalMargin,
          vertical: _verticalMargin,
        ),
        theme: _theme(),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                'OMNIX POS',
                textAlign: pw.TextAlign.center,
                style: _style(size: 11, bold: true, color: PdfColors.black),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'PRINTER TEST',
                textAlign: pw.TextAlign.center,
                style: _style(size: 8, bold: true),
              ),
              _divider(),
              _row('Printer', printerName),
              _row('Date', _formatDate(now)),
              _row('Time', _formatTime(now)),
              pw.SizedBox(height: 6),
              pw.Text(
                'If you can read this, the 80mm invoice printer is ready.',
                textAlign: pw.TextAlign.center,
                style: _style(size: 7.5, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '***',
                textAlign: pw.TextAlign.center,
                style: _style(size: 7.5),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> build({
    required ReceiptDocument document,
    String? qrData,
    int copies = 1,
  }) async {
    final pw.Document pdf = pw.Document(
      title: 'Invoice ${document.invoiceNumber}',
      subject: 'Sales receipt',
      creator: 'Omnix POS',
    );

    final bool hasQr = qrData != null && qrData.trim().isNotEmpty;
    final int copyCount = copies.clamp(1, 5);
    final double pageHeight = _estimatedHeight(document, hasQr: hasQr);

    for (int copy = 0; copy < copyCount; copy++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(widthMm * PdfPageFormat.mm, pageHeight),
          margin: const pw.EdgeInsets.symmetric(
            horizontal: _horizontalMargin,
            vertical: _verticalMargin,
          ),
          theme: _theme(),
          build: (pw.Context context) {
            return _buildReceipt(document, qrData: hasQr ? qrData : null);
          },
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _buildReceipt(ReceiptDocument document, {String? qrData}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          document.branchName.toUpperCase(),
          textAlign: pw.TextAlign.center,
          style: _style(size: 10.5, bold: true, color: PdfColors.black),
        ),
        pw.Text(
          document.branchCode,
          textAlign: pw.TextAlign.center,
          style: _style(size: 6.8, color: PdfColors.grey700),
        ),
        pw.Text(
          document.branchAddress,
          textAlign: pw.TextAlign.center,
          style: _style(size: 6.8, color: PdfColors.grey700),
        ),
        pw.Text(
          document.branchBin,
          textAlign: pw.TextAlign.center,
          style: _style(size: 6.8, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          'SALE INVOICE #${document.invoiceNumber}',
          textAlign: pw.TextAlign.center,
          style: _style(size: 8, bold: true, color: PdfColors.black),
        ),
        _divider(),

        _row('Date', _formatDate(document.createdAt)),
        _row('Time', _formatTime(document.createdAt)),
        if (document.tableLabel.trim().isNotEmpty)
          _row('Table', document.tableLabel),
        _row('Cashier', document.cashierName),
        _row('Customer', document.customerName),

        _divider(),
        _itemHeader(),
        pw.SizedBox(height: 2),
        ...document.items.map(_itemRow),

        _divider(),
        _row('Subtotal', _money(document.subtotal)),
        _row('VAT (${_percent(document.vatPercent)}%)', _money(document.vat)),
        if (document.isMobileWallet)
          _row(
            'bKash/Nagad cashout (${_percent(document.cashoutPercent)}%)',
            _money(document.cashout),
          ),
        pw.SizedBox(height: 2),
        _row('NET TOTAL', _money(document.total), bold: true),
        _row('Paid (${document.tenderLabel})', _money(document.paidAmount)),
        if (document.isCash && document.discount > 0)
          _row('Discount', _money(document.discount))
        else if (document.isCash)
          _row('Change returned', _money(document.changeDue)),

        pw.SizedBox(height: 8),
        if (qrData != null) _qrBlock(qrData, document.invoiceNumber),
        pw.SizedBox(height: 4),
        pw.Text(
          'Thank you for dining with us!',
          textAlign: pw.TextAlign.center,
          style: _style(size: 7.5, bold: true, color: PdfColors.black),
        ),
      ],
    );
  }

  static pw.Widget _itemHeader() {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text('ITEM', style: _style(size: 6.5, bold: true)),
        ),
        pw.SizedBox(
          width: 50,
          child: pw.Text(
            'QTY x RATE',
            textAlign: pw.TextAlign.right,
            style: _style(size: 6.5, bold: true),
          ),
        ),
        pw.SizedBox(
          width: 48,
          child: pw.Text(
            'TOTAL',
            textAlign: pw.TextAlign.right,
            style: _style(size: 6.5, bold: true),
          ),
        ),
      ],
    );
  }

  static pw.Widget _itemRow(ReceiptLineItem line) {
    final bool hasNote = line.note != null && line.note!.trim().isNotEmpty;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  line.name,
                  style: _style(size: 7.3, color: PdfColors.grey900),
                ),
                if (hasNote)
                  pw.Text(
                    line.note!,
                    style: _style(size: 6.3, color: PdfColors.grey600),
                  ),
              ],
            ),
          ),
          pw.SizedBox(
            width: 50,
            child: pw.Text(
              '${line.quantity} x ${formatNumber(line.price)}',
              textAlign: pw.TextAlign.right,
              style: _style(size: 6.8),
            ),
          ),
          pw.SizedBox(
            width: 48,
            child: pw.Text(
              _money(line.total),
              textAlign: pw.TextAlign.right,
              style: _style(size: 7.3, color: PdfColors.grey900),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _qrBlock(String data, int invoiceNumber) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(2),
          color: PdfColors.white,
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: data,
            width: 18 * PdfPageFormat.mm,
            height: 18 * PdfPageFormat.mm,
            drawText: false,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Scan for invoice details',
          style: _style(size: 6.2, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          'Invoice #$invoiceNumber',
          style: _style(size: 6.2, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _row(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: _style(
                size: bold ? 8.4 : 7.3,
                bold: bold,
                color: bold ? PdfColors.black : PdfColors.grey700,
              ),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Text(
            value,
            style: _style(
              size: bold ? 8.4 : 7.3,
              bold: bold,
              color: bold ? PdfColors.black : PdfColors.grey900,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _divider() {
    return pw.Container(
      height: 0.4,
      margin: const pw.EdgeInsets.symmetric(vertical: 4),
      color: PdfColors.grey500,
    );
  }

  // Thermal rolls have no fixed length. The estimate is deliberately generous
  // so a normal ticket never spills onto a second page; the paper simply feeds
  // a few extra millimetres at the end.
  static double _estimatedHeight(ReceiptDocument document, {required bool hasQr}) {
    double height = _verticalMargin * 2;

    height += 46; // branch block + invoice number
    height += 8; // divider
    height += 11 * 3; // date, time, cashier
    if (document.tableLabel.trim().isNotEmpty) height += 11;
    height += 11; // customer
    height += 8; // divider
    height += 10; // item header
    height += 4;

    for (final ReceiptLineItem line in document.items) {
      height += 12;
      if (line.name.length > 34) height += 10;
      if (line.note != null && line.note!.trim().isNotEmpty) height += 10;
    }

    height += 8; // divider
    height += 11 * 2; // subtotal, vat
    if (document.isMobileWallet) height += 11;
    height += 4;
    height += 12 * 2; // net total, paid
    if (document.isCash) height += 11; // discount or change
    height += 12;
    height += hasQr ? 74 : 16;
    height += 14; // footer
    height += 30; // slack for wrapped lines and the printer's feed

    return height < 120 * PdfPageFormat.mm ? 120 * PdfPageFormat.mm : height;
  }

  static pw.ThemeData _theme() {
    return pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );
  }

  static pw.TextStyle _style({
    double size = 7.5,
    bool bold = false,
    PdfColor color = PdfColors.grey800,
  }) {
    return pw.TextStyle(
      fontSize: size,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color,
      lineSpacing: 1,
    );
  }

  static String _money(num amount) => 'Tk ${formatNumber(amount)}';

  static String _percent(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  static String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${_two(date.day)}-${months[date.month - 1]}-${date.year}';
  }

  static String _formatTime(DateTime time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String period = time.hour < 12 ? 'AM' : 'PM';

    return '${_two(hour)}:${_two(time.minute)} $period';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
