import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/receipt/model/receipt_document.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// The receipt paper itself. Shared by the POS preview dialog and the hosted
/// public receipt page so both always show exactly the same content.
class ReceiptPaperWidget extends StatelessWidget {
  const ReceiptPaperWidget({
    super.key,
    required this.document,
    this.qrData,
    this.showQr = true,
  });

  final ReceiptDocument document;
  final String? qrData;
  final bool showQr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBackgroundBlack,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
          width: 0.6,
        ),
      ),
      child: DefaultTextStyle(
        style: _mono(fontSize: 10.5, color: AppTheme.badgeNeutralText),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _DashedDivider(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.24),
            ),
            const SizedBox(height: 7),
            _ReceiptRow(label: 'Date', value: _formatDate(document.createdAt)),
            _ReceiptRow(label: 'Time', value: _formatTime(document.createdAt)),
            if (document.tableLabel.trim().isNotEmpty)
              _ReceiptRow(label: 'Table', value: document.tableLabel),
            _ReceiptRow(label: 'Cashier', value: document.cashierName),
            _ReceiptRow(
              label: 'Customer',
              value: document.customerName,
              valueColor: AppTheme.lightGreen,
            ),
            const SizedBox(height: 7),
            _DashedDivider(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.24),
            ),
            const SizedBox(height: 6),
            _buildItemHeader(),
            const SizedBox(height: 3),
            ...document.items.map(_buildItemRow),
            const SizedBox(height: 7),
            _DashedDivider(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.24),
            ),
            const SizedBox(height: 7),
            _ReceiptRow(
              label: 'Subtotal:',
              value: formatTakaSymbol(document.subtotal),
            ),
            _ReceiptRow(
              label: 'VAT (${_percent(document.vatPercent)}%):',
              value: formatTakaSymbol(document.vat),
            ),
            if (document.isMobileWallet)
              _ReceiptRow(
                label:
                    'bKash/Nagad cashout '
                    '(${_percent(document.cashoutPercent)}%):',
                value: formatTakaSymbol(document.cashout),
              ),
            const SizedBox(height: 4),
            Divider(
              height: 1,
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 4),
            _ReceiptRow(
              label: 'NET TOTAL:',
              value: formatTakaSymbol(document.total),
              isTotal: true,
            ),
            _ReceiptRow(
              label: 'Paid (${document.tenderLabel}):',
              value: formatTakaSymbol(document.paidAmount),
            ),
            if (document.isCash && document.discount > 0)
              _ReceiptRow(
                label: 'Discount:',
                value: formatTakaSymbol(document.discount),
                valueColor: AppTheme.amber,
              )
            else if (document.isCash)
              _ReceiptRow(
                label: 'Change Returned:',
                value: formatTakaSymbol(document.changeDue),
                valueColor: AppTheme.lightGreen,
              ),
            const SizedBox(height: 10),
            if (showQr && qrData != null)
              _buildQrBlock(qrData!)
            else
              _buildThankYou(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          document.branchName.toUpperCase(),
          textAlign: TextAlign.center,
          style: _mono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppTheme.white,
          ),
        ),
        Text(
          document.branchCode,
          textAlign: TextAlign.center,
          style: _mono(fontSize: 9.5, color: AppTheme.tableHeaderText),
        ),
        Text(
          document.branchAddress,
          textAlign: TextAlign.center,
          style: _mono(fontSize: 9.5, color: AppTheme.tableHeaderText),
        ),
        Text(
          document.branchBin,
          textAlign: TextAlign.center,
          style: _mono(fontSize: 9.5, color: AppTheme.tableHeaderText),
        ),
        const SizedBox(height: 6),
        Text(
          'SALE INVOICE #${document.invoiceNumber}',
          textAlign: TextAlign.center,
          style: _mono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: AppTheme.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildItemHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'ITEM',
            style: _mono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.tablePrimaryText,
            ),
          ),
        ),
        SizedBox(
          width: 66,
          child: Text(
            'QTY x RATE',
            textAlign: TextAlign.right,
            style: _mono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.tablePrimaryText,
            ),
          ),
        ),
        SizedBox(
          width: 62,
          child: Text(
            'TOTAL',
            textAlign: TextAlign.right,
            style: _mono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.tablePrimaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(ReceiptLineItem line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: _mono(color: AppTheme.tablePrimaryText)),
                if (line.note != null && line.note!.isNotEmpty)
                  Text(
                    line.note!,
                    style: _mono(fontSize: 9, color: AppTheme.tableHeaderText),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 66,
            child: Text(
              '${line.quantity} x ${line.price}',
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 62,
            child: Text(
              formatTakaSymbol(line.total),
              textAlign: TextAlign.right,
              style: _mono(color: AppTheme.tablePrimaryText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrBlock(String data) {
    const double boxSize = 116;

    return Column(
      spacing: 3,
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: _ReceiptQr(
            data: data,
            size: boxSize - 8,
            semanticsLabel: 'Invoice ${document.invoiceNumber} QR code',
          ),
        ),
        const Text(
          'Scan for invoice details',
          style: TextStyle(fontSize: 7.5, color: AppTheme.tableHeaderText),
        ),
        _buildThankYou(),
      ],
    );
  }

  Widget _buildThankYou() {
    return Text(
      'Thank you for dining with us!',
      textAlign: TextAlign.center,
      style: _mono(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: AppTheme.white,
      ),
    );
  }
}

class _ReceiptQr extends StatefulWidget {
  const _ReceiptQr({
    required this.data,
    required this.size,
    required this.semanticsLabel,
  });

  final String data;
  final double size;
  final String semanticsLabel;

  @override
  State<_ReceiptQr> createState() => _ReceiptQrState();
}

class _ReceiptQrState extends State<_ReceiptQr> {
  QrImage? _image;

  @override
  void initState() {
    super.initState();
    _image = _encode(widget.data);
  }

  @override
  void didUpdateWidget(covariant _ReceiptQr oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _image = _encode(widget.data);
    }
  }

  static QrImage? _encode(String data) {
    if (data.trim().isEmpty) return null;
    try {
      return QrImage(
        QrCode.fromData(
          data: data,
          errorCorrectLevel: QrErrorCorrectLevel.Q,
        ),
      );
    } on Exception {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final QrImage? image = _image;

    return Semantics(
      label: widget.semanticsLabel,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: image == null
            ? Icon(
                Icons.qr_code_2,
                size: widget.size - 8,
                color: Colors.black87,
              )
            : CustomPaint(
                painter: _ReceiptQrPainter(
                  image,
                  MediaQuery.devicePixelRatioOf(context),
                ),
              ),
      ),
    );
  }
}

/// Paints the QR module grid straight onto the canvas.
///
/// [QrImageView] sizes every module by rounding its width to half a pixel and
/// then centres the result, which leaves a visible white frame and soft,
/// unreadable modules once the code is made small. This painter fills the whole
/// box edge to edge, merges each run of dark modules into one rectangle and
/// snaps the edges to physical pixels, so the QR stays sharp at any size.
class _ReceiptQrPainter extends CustomPainter {
  const _ReceiptQrPainter(this.image, this.devicePixelRatio);

  final QrImage image;
  final double devicePixelRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final int moduleCount = image.moduleCount;
    if (moduleCount <= 0) return;

    final double edge = size.shortestSide;
    final double moduleSize = edge / moduleCount;
    final double ratio = devicePixelRatio <= 0 ? 1 : devicePixelRatio;

    double snap(double value) => (value * ratio).roundToDouble() / ratio;

    final Paint dark = Paint()
      ..color = Colors.black
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    for (int row = 0; row < moduleCount; row++) {
      final double top = snap(row * moduleSize);
      final double bottom = snap((row + 1) * moduleSize);
      if (bottom <= top) continue;

      int column = 0;
      while (column < moduleCount) {
        if (!image.isDark(row, column)) {
          column++;
          continue;
        }

        final int runStart = column;
        while (column < moduleCount && image.isDark(row, column)) {
          column++;
        }

        canvas.drawRect(
          Rect.fromLTRB(
            snap(runStart * moduleSize),
            top,
            snap(column * moduleSize),
            bottom,
          ),
          dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReceiptQrPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.devicePixelRatio != devicePixelRatio;
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 11 : 10,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
                color: isTotal
                    ? AppTheme.tablePrimaryText
                    : AppTheme.badgeNeutralText,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color:
                  valueColor ??
                  (isTotal ? AppTheme.amber : AppTheme.tablePrimaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashedLinePainter(color)),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const double dash = 4;
    const double gap = 3;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

String _percent(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}

String _formatDate(DateTime date) {
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

String _formatTime(DateTime time) {
  final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final String period = time.hour < 12 ? 'AM' : 'PM';

  return '${_two(hour)}:${_two(time.minute)} $period';
}

String _two(int value) => value.toString().padLeft(2, '0');

TextStyle _mono({
  double fontSize = 10.5,
  FontWeight fontWeight = FontWeight.w400,
  Color? color,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: const ['Courier New', 'Menlo', 'DejaVu Sans Mono'],
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: 1.4,
    color: color ?? AppTheme.badgeNeutralText,
  );
}
