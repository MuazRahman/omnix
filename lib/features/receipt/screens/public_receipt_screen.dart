import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/receipt/model/receipt_document.dart';
import 'package:omnix/features/receipt/utils/receipt_link.dart';
import 'package:omnix/features/receipt/widgets/receipt_paper_widget.dart';

/// Public receipt page opened by scanning the QR code on a printed receipt.
///
/// The URL carries only the invoice number (`invoice=...`). When a document
/// is available (e.g. from local state or after a backend fetch) it is
/// rendered directly; otherwise the page shows the invoice number and waits
/// for the hosted API to return the receipt data.
class PublicReceiptScreen extends StatelessWidget {
  const PublicReceiptScreen({super.key, this.document, this.invoiceNumber});

  final ReceiptDocument? document;
  final int? invoiceNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.windowWidgetBackgroundBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.topbarBackgroundBlack,
              AppTheme.windowWidgetBackgroundBlack,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: document == null
                    ? _ReceiptLookup(
                        invoiceNumber: invoiceNumber,
                      )
                    : _ReceiptContent(document: document!),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptContent extends StatelessWidget {
  const _ReceiptContent({required this.document});

  final ReceiptDocument document;

  @override
  Widget build(BuildContext context) {
    // Short URL that points to the hosted receipt page with only the invoice
    // number — easy for any modern phone scanner to read.
    final Uri qrUri = ReceiptLink.forDocument(document);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _BrandHeader(),
        const SizedBox(height: 22),
        Text(
          'Invoice #${document.invoiceNumber}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.white,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${document.itemCount} items · ${formatTakaSymbol(document.total)}',
          style: const TextStyle(
            fontSize: 12.5,
            color: AppTheme.tableHeaderText,
          ),
        ),
        const SizedBox(height: 14),
        ReceiptPaperWidget(document: document, qrData: qrUri.toString()),
        const SizedBox(height: 4),
        const _ReceiptFooter(),
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.amber,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            size: 20,
            color: AppTheme.windowWidgetBackgroundBlack,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OMNIX',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: AppTheme.white,
                ),
              ),
              Text(
                'Digital receipt',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppTheme.tableHeaderText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.amber.withValues(alpha: 0.3),
              width: 0.6,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              Icon(Icons.cloud_done_outlined, size: 12, color: AppTheme.amber),
              Text(
                'ONLINE COPY',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: AppTheme.amber,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shown when a receipt URL only carries an invoice number (no embedded
/// document). The hosted backend is expected to fetch the data by invoice.
class _ReceiptLookup extends StatelessWidget {
  const _ReceiptLookup({this.invoiceNumber});

  final int? invoiceNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _BrandHeader(),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: AppTheme.sidebarBackgroundBlack,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.amber.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 26,
                  color: AppTheme.amber,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Invoice lookup',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This receipt link points to invoice number only. '
                'The hosted page will fetch the full receipt data '
                'from the server using this invoice ID.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppTheme.tableHeaderText,
                ),
              ),
              if (invoiceNumber != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.badgeNeutralBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Invoice #$invoiceNumber',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.badgeNeutralText,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Keep this link for your records.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            height: 1.5,
            color: AppTheme.tableHeaderText,
          ),
        ),
      ],
    );
  }
}

class _ReceiptFooter extends StatelessWidget {
  const _ReceiptFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: const [
            Icon(
              Icons.lock_outline_rounded,
              size: 13,
              color: AppTheme.tableHeaderText,
            ),
            Flexible(
              child: Text(
                'Digitally generated by Omnix POS',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppTheme.tableHeaderText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        const Text(
          'Keep this link for your records.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: AppTheme.tableHeaderText),
        ),
      ],
    );
  }
}
