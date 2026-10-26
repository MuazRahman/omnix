import 'dart:typed_data';

import 'package:omnix/features/orders/model/order_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Renders a kitchen order ticket (KOT) for the 80mm printer.
///
/// A KOT is deliberately price free: the line cook only needs the station,
/// the ticket number, the quantities and the preparation notes.
abstract final class KitchenTicketPdfBuilder {
  const KitchenTicketPdfBuilder._();

  static const double widthMm = 80;

  static const double _horizontalMargin = 4 * PdfPageFormat.mm;
  static const double _verticalMargin = 3 * PdfPageFormat.mm;

  static Future<Uint8List> build({
    required Order order,
    DateTime? createdAt,
  }) async {
    final DateTime printedAt = createdAt ?? DateTime.now();
    final pw.Document pdf = pw.Document(
      title: 'KOT ${order.id}',
      subject: 'Kitchen order ticket',
      creator: 'Omnix POS',
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          widthMm * PdfPageFormat.mm,
          _estimatedHeight(order) * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.symmetric(
          horizontal: _horizontalMargin,
          vertical: _verticalMargin,
        ),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        build: (pw.Context context) => _buildTicket(order, printedAt),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTicket(Order order, DateTime printedAt) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          'OMNIX KITCHEN',
          textAlign: pw.TextAlign.center,
          style: _style(size: 7.5, bold: true, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'KOT ${order.id}',
          textAlign: pw.TextAlign.center,
          style: _style(size: 15, bold: true, color: PdfColors.black),
        ),
        pw.Text(
          'Token #${order.token}',
          textAlign: pw.TextAlign.center,
          style: _style(size: 8, color: PdfColors.grey700),
        ),
        _divider(),

        // Big station callout so the ticket can be read from a distance.
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.Text(
            _stationLabel(order),
            textAlign: pw.TextAlign.center,
            style: _style(size: 11, bold: true, color: PdfColors.black),
          ),
        ),
        pw.SizedBox(height: 4),

        _row('Type', order.channel.label),
        if (order.channel == OrderChannel.dineIn && order.guests > 0)
          _row('Guests', '${order.guests} pax'),
        _row('Server', order.serverName),
        _row('Time', _formatTime(printedAt)),
        if (order.status == OrderStatus.ready)
          _row('Status', 'REPRINT · already ready'),
        if (order.kotPrintedAt != null)
          _row('Original', _formatTime(order.kotPrintedAt!)),

        _divider(),
        pw.Text(
          'PREPARE',
          style: _style(size: 7.5, bold: true, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 3),

        ...order.lines.map(_line),

        _divider(),
        pw.Text(
          'Ticket ${order.id} · ${order.itemCount} items',
          textAlign: pw.TextAlign.center,
          style: _style(size: 7.5, bold: true, color: PdfColors.black),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          'Not a customer receipt',
          textAlign: pw.TextAlign.center,
          style: _style(size: 6.5, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static String _stationLabel(Order order) {
    switch (order.channel) {
      case OrderChannel.dineIn:
        final String table = order.tableLabel ?? '—';
        final String area = order.areaLabel ?? '';
        return 'TABLE $table${area.isEmpty ? '' : ' · ${area.toUpperCase()}'}';
      case OrderChannel.takeaway:
        return 'TAKEAWAY';
      case OrderChannel.delivery:
        final String rider = order.riderLabel ?? 'Rider';
        final String code = order.riderCode ?? '';
        return 'DELIVERY${code.isEmpty ? '' : ' · $rider $code'}';
    }
  }

  static pw.Widget _line(OrderLine line) {
    final List<String> notes = <String>[
      if (line.note != null && line.note!.trim().isNotEmpty) line.note!.trim(),
      ...line.modifiers,
    ];

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 22,
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
              borderRadius: pw.BorderRadius.circular(2),
            ),
            child: pw.Text(
              '${line.quantity}x',
              textAlign: pw.TextAlign.center,
              style: _style(size: 10, bold: true, color: PdfColors.black),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  line.name,
                  style: _style(size: 9, bold: true, color: PdfColors.black),
                ),
                if (notes.isNotEmpty)
                  pw.Text(
                    notes.join(' · '),
                    style: _style(size: 7.5, color: PdfColors.grey700),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.6),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 42,
            child: pw.Text(
              label,
              style: _style(size: 7.5, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: _style(size: 7.5, bold: true, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _divider() {
    return pw.Container(
      height: 0.5,
      margin: const pw.EdgeInsets.symmetric(vertical: 5),
      color: PdfColors.grey500,
    );
  }

  static pw.TextStyle _style({
    double size = 8,
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

  // Thermal rolls have no fixed length. A generous estimate keeps every line
  // on one page while feeding only a little blank paper at the end.
  static double _estimatedHeight(Order order) {
    double height = _verticalMargin * 2;

    height += 30; // brand, ticket number, token
    height += 10; // divider
    height += 22; // station callout
    height += 13 * 4; // type, server, time, status
    height += 10; // divider
    height += 12; // prepare label

    for (final OrderLine line in order.lines) {
      height += 14;
      if (line.note != null && line.note!.trim().isNotEmpty) height += 9;
      if (line.modifiers.isNotEmpty) height += 9;
    }

    height += 30; // footer and divider
    height += 25; // feed slack

    return height < 100 ? 100 : height;
  }

  static String _formatTime(DateTime time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String period = time.hour < 12 ? 'AM' : 'PM';
    final String minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute $period';
  }
}
