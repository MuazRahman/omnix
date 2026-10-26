import 'package:omnix/features/receipt/model/receipt_document.dart';

/// Outcome of one print job, so the UI can tell the cashier what happened.
class ReceiptPrintResult {
  const ReceiptPrintResult.success(this.printerName)
    : isSuccess = true,
      error = null;

  const ReceiptPrintResult.failure(this.error)
    : isSuccess = false,
      printerName = null;

  final bool isSuccess;

  /// Name of the spooler queue that accepted the job.
  final String? printerName;

  /// Cashier-facing reason when the job could not be sent.
  final String? error;
}

/// Prints the sales invoice on the 80mm thermal printer attached to this PC.
///
/// The bank's card terminal prints its own slip; this service only handles the
/// invoice produced by this app, whatever the tender mode was.
abstract interface class ReceiptPrinter {
  Future<ReceiptPrintResult> printReceipt(
    ReceiptDocument document, {
    String? qrData,
  });

  /// Short slip used from the printer settings to verify the setup.
  Future<ReceiptPrintResult> printTestPage();
}

const String noPrinterMessage =
    'No invoice printer selected. Open printer settings and choose the 80mm '
    'printer first.';
