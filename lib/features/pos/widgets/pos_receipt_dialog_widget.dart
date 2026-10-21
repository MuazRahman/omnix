import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/model/pos_tender_mode_model.dart';
import 'package:omnix/features/receipt/controller/printer_settings_controller.dart';
import 'package:omnix/features/receipt/model/receipt_document.dart';
import 'package:omnix/features/receipt/printer/receipt_printer.dart';
import 'package:omnix/features/receipt/utils/receipt_link.dart';
import 'package:omnix/features/receipt/widgets/printer_settings_dialog.dart';
import 'package:omnix/features/receipt/widgets/receipt_paper_widget.dart';

/// 80mm thermal receipt preview shown after the cart is charged.
class PosReceiptDialogWidget extends StatefulWidget {
  const PosReceiptDialogWidget({super.key, required this.posController});

  final PosController posController;

  @override
  State<PosReceiptDialogWidget> createState() => _PosReceiptDialogWidgetState();
}

class _PosReceiptDialogWidgetState extends State<PosReceiptDialogWidget> {
  bool _isPrinting = false;
  bool _isPrinted = false;
  late final DateTime _createdAt;

  PosController get _controller => widget.posController;

  @override
  void initState() {
    super.initState();
    // Freeze the timestamp so the printed time and the QR payload stay stable
    // for the whole lifetime of the dialog.
    _createdAt = DateTime.now();

    // Cashiers who enabled it get the invoice without pressing Print.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!Get.isRegistered<PrinterSettingsController>()) return;
      if (Get.find<PrinterSettingsController>().autoPrint.value) {
        _printReceipt();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ReceiptDocument receipt = _buildReceiptDocument();
    final String receiptUrl = ReceiptLink.forDocument(receipt).toString();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.sizeOf(context).height - 48,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.topbarBackgroundBlack,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: ReceiptPaperWidget(
                    document: receipt,
                    qrData: receiptUrl,
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  ReceiptDocument _buildReceiptDocument() {
    final PosTenderMode tender = _controller.tenderMode.value;
    final bool isCash = tender == PosTenderMode.cash;
    final bool isMobileWallet = tender == PosTenderMode.mobileWallet;

    return ReceiptDocument(
      invoiceNumber: _controller.invoiceNumber.value,
      branchName: _controller.branchName,
      branchCode: _controller.branchCode,
      branchAddress: _controller.branchAddress,
      branchBin: _controller.branchBin,
      cashierName: _controller.cashierName,
      customerName: _controller.customer.value?.displayName ?? 'N/A',
      tableLabel: _controller.isDineIn ? _controller.tableLabel.value : '',
      createdAt: _createdAt,
      items: _controller.cart
          .map(
            (line) => ReceiptLineItem(
              name: line.name,
              quantity: line.quantity,
              price: line.price,
              note: line.note,
            ),
          )
          .toList(growable: false),
      subtotal: _controller.subtotal,
      vatPercent: _controller.taxPercent,
      vat: _controller.tax,
      cashoutPercent: _controller.mobileWalletCashoutPercent.value,
      cashout: _controller.mobileWalletCashoutCharge,
      total: _controller.total,
      tenderLabel: tender.label,
      paidAmount: isCash ? _controller.cashReceived.value : _controller.total,
      discount: isCash ? _controller.discountAmount : 0,
      changeDue: _controller.changeDue,
      isCash: isCash,
      isMobileWallet: isMobileWallet,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 8),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 18,
            color: AppTheme.amber,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Receipt Preview',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
          ),
          IconButton(
            onPressed: _openPrinterSettings,
            icon: const Icon(Icons.settings_outlined, size: 17),
            color: AppTheme.tableHeaderText,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.sidebarBackgroundBlack,
            ),
            tooltip: 'Printer settings',
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 18),
            color: AppTheme.tableHeaderText,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.sidebarBackgroundBlack,
            ),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isPrinting ? null : _printReceipt,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.amber,
                disabledBackgroundColor: AppTheme.amber.withValues(alpha: 0.6),
                foregroundColor: AppTheme.windowWidgetBackgroundBlack,
                disabledForegroundColor: AppTheme.windowWidgetBackgroundBlack,
                elevation: 0,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  if (_isPrinting)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.windowWidgetBackgroundBlack,
                      ),
                    )
                  else
                    Icon(
                      _isPrinted ? Icons.check : Icons.print_outlined,
                      size: 16,
                    ),
                  Flexible(
                    child: Text(
                      _isPrinting
                          ? 'Printing...'
                          : (_isPrinted ? 'Printed' : 'Print 80mm'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: OutlinedButton(
              onPressed: _isPrinting ? null : _finishSaleAndClose,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightAmberWhite,
                side: BorderSide(
                  color: AppTheme.lightAmberWhite.withValues(alpha: 0.18),
                  width: 0.6,
                ),
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'New Sale',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPrinterSettings() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.82),
      builder: (BuildContext context) => const PrinterSettingsDialog(),
    );
  }

  Future<void> _printReceipt() async {
    if (_isPrinting) return;

    if (!Get.isRegistered<ReceiptPrinter>()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No invoice printer is configured.')),
      );
      return;
    }

    setState(() => _isPrinting = true);

    final ReceiptDocument receipt = _buildReceiptDocument();
    final String receiptUrl = ReceiptLink.forDocument(receipt).toString();

    final ReceiptPrintResult result = await Get.find<ReceiptPrinter>()
        .printReceipt(receipt, qrData: receiptUrl);

    if (!mounted) return;

    if (!result.isSuccess) {
      setState(() => _isPrinting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'The receipt could not be printed.'),
        ),
      );
      return;
    }

    setState(() {
      _isPrinting = false;
      _isPrinted = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    _finishSaleAndClose();
  }

  void _finishSaleAndClose() {
    widget.posController.startNewSale();
    Navigator.of(context).pop();
  }
}
