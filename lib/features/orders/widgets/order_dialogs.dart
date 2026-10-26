import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/orders/controller/order_controller.dart';
import 'package:omnix/features/orders/model/order_model.dart';
import 'package:omnix/features/orders/widgets/order_badges.dart';
import 'package:omnix/features/receipt/model/receipt_document.dart';
import 'package:omnix/features/receipt/utils/receipt_link.dart';
import 'package:omnix/features/receipt/widgets/receipt_paper_widget.dart';

/// Tender collected when a ready ticket is completed.
class OrderSettlement {
  const OrderSettlement({required this.method, this.cashReceived = 0});

  final PaymentMethod method;
  final int cashReceived;
}

class OrderSettlementDialog extends StatefulWidget {
  const OrderSettlementDialog({super.key, required this.order});

  final Order order;

  @override
  State<OrderSettlementDialog> createState() => _OrderSettlementDialogState();
}

class _OrderSettlementDialogState extends State<OrderSettlementDialog> {
  PaymentMethod _method = PaymentMethod.cash;
  late final TextEditingController _cashController;

  @override
  void initState() {
    super.initState();
    _cashController = TextEditingController(text: '${widget.order.total}');
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  int get _cash {
    final String digits = _cashController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    return int.tryParse(digits) ?? 0;
  }

  int get _change {
    final int change = _cash - widget.order.total;
    return change > 0 ? change : 0;
  }

  bool get _isValid =>
      _method != PaymentMethod.cash || _cash >= widget.order.total;

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      maxWidth: 430,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DialogHeader(
            icon: Icons.payments_outlined,
            title: 'Settle order',
            subtitle: '${widget.order.id} · ${widget.order.channel.label}',
            onClose: () => Navigator.of(context).pop(),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummary(),
                  const SizedBox(height: 14),
                  const _FieldLabel('PAYMENT METHOD'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: PaymentMethod.values
                        .map((PaymentMethod method) {
                          return _MethodChip(
                            method: method,
                            selected: _method == method,
                            onTap: () {
                              setState(() {
                                _method = method;
                              });
                            },
                          );
                        })
                        .toList(growable: false),
                  ),
                  if (_method == PaymentMethod.cash) ...[
                    const SizedBox(height: 14),
                    const _FieldLabel('CASH RECEIVED'),
                    const SizedBox(height: 6),
                    _buildCashField(),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _quickAmounts
                          .map((int amount) {
                            return _QuickAmountChip(
                              amount: amount,
                              selected: _cash == amount,
                              onTap: () {
                                _cashController.text = '$amount';
                                _cashController.selection =
                                    TextSelection.collapsed(
                                      offset: _cashController.text.length,
                                    );
                                setState(() {});
                              },
                            );
                          })
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 10),
                    _buildChangeRow(),
                  ],
                  if (!_isValid) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Cash received is less than the net payable amount.',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.dangerRedLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          _DialogFooter(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: _secondaryButtonStyle(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isValid ? _submit : null,
                  style: _primaryButtonStyle(),
                  child: Text(
                    'Complete · ${formatTakaSymbol(widget.order.total)}',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.tablePrimaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  orderSourceSubtitle(widget.order).isEmpty
                      ? widget.order.channel.label
                      : '${widget.order.channel.label} · '
                            '${orderSourceSubtitle(widget.order)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'NET PAYABLE',
                style: TextStyle(
                  fontSize: 8.5,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tableHeaderText,
                ),
              ),
              Text(
                formatTakaSymbol(widget.order.total),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashField() {
    return TextField(
      controller: _cashController,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(7),
      ],
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.lightAmberWhite,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppTheme.topbarBackgroundBlack,
        prefixText: '৳  ',
        prefixStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.tableHeaderText,
        ),
        suffixText: 'received',
        suffixStyle: const TextStyle(
          fontSize: 10,
          color: AppTheme.tableHeaderText,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(color: AppTheme.amber),
      ),
    );
  }

  Widget _buildChangeRow() {
    return Row(
      children: [
        const Icon(
          Icons.redeem_outlined,
          size: 14,
          color: AppTheme.tableHeaderText,
        ),
        const SizedBox(width: 6),
        const Text(
          'Change to return',
          style: TextStyle(fontSize: 11, color: AppTheme.tableHeaderText),
        ),
        const Spacer(),
        Text(
          formatTakaSymbol(_change),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _change > 0 ? AppTheme.lightGreen : AppTheme.tableHeaderText,
          ),
        ),
      ],
    );
  }

  List<int> get _quickAmounts {
    final int total = widget.order.total;
    final int first = ((total + 499) ~/ 500) * 500;

    final List<int> amounts = <int>{
      total,
      first,
      first + 500,
      first + 1000,
    }.toList()..sort();

    return amounts;
  }

  void _submit() {
    Navigator.of(context).pop(
      OrderSettlement(
        method: _method,
        cashReceived: _method == PaymentMethod.cash ? _cash : 0,
      ),
    );
  }

  OutlineInputBorder _fieldBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(
        color: color ?? AppTheme.lightAmberWhite.withValues(alpha: 0.16),
        width: color == null ? 0.6 : 0.9,
      ),
    );
  }
}

class OrderVoidDialog extends StatefulWidget {
  const OrderVoidDialog({
    super.key,
    required this.order,
    required this.onSubmit,
  });

  final Order order;

  /// Returns true when the pin is accepted and the order is voided.
  final Future<bool> Function(String pin, String reason) onSubmit;

  @override
  State<OrderVoidDialog> createState() => _OrderVoidDialogState();
}

class _OrderVoidDialogState extends State<OrderVoidDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  String? _error;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRefund = widget.order.paymentStatus == PaymentStatus.paid;

    return _DialogShell(
      maxWidth: 430,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DialogHeader(
            icon: Icons.report_gmailerrorred_outlined,
            iconColor: AppTheme.dangerRedLight,
            title: isRefund ? 'Refund order' : 'Void order',
            subtitle:
                '${widget.order.id} · ${formatTakaSymbol(widget.order.total)}',
            onClose: () => Navigator.of(context).pop(),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerRed.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.dangerRed.withValues(alpha: 0.25),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppTheme.dangerRedLight,
                        ),
                        Expanded(
                          child: Text(
                            isRefund
                                ? 'This ticket is already paid. Authorising '
                                      'will cancel it and mark the full amount '
                                      'for refund.'
                                : 'This ticket is not paid yet. Authorising '
                                      'will cancel it and remove it from the '
                                      'kitchen queue.',
                            style: const TextStyle(
                              fontSize: 10.5,
                              height: 1.4,
                              color: AppTheme.badgeNeutralText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('REASON (OPTIONAL)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _reasonController,
                    maxLines: 2,
                    maxLength: 120,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.lightAmberWhite,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.topbarBackgroundBlack,
                      hintText: 'e.g. guest changed their mind',
                      hintStyle: TextStyle(
                        fontSize: 11,
                        color: AppTheme.lightAmberWhite.withValues(alpha: 0.3),
                      ),
                      counterStyle: const TextStyle(
                        fontSize: 9,
                        color: AppTheme.tableHeaderText,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: _fieldBorder(),
                      enabledBorder: _fieldBorder(),
                      focusedBorder: _fieldBorder(color: AppTheme.amber),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _FieldLabel('MANAGER PIN'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (_) {
                      if (_error != null) {
                        setState(() => _error = null);
                      }
                    },
                    style: const TextStyle(
                      fontSize: 14,
                      letterSpacing: 4,
                      color: AppTheme.lightAmberWhite,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.topbarBackgroundBlack,
                      hintText: '••••',
                      helperText:
                          'Demo manager PIN: ${OrderController.managerPin}',
                      helperStyle: const TextStyle(
                        fontSize: 9.5,
                        color: AppTheme.tableHeaderText,
                      ),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      border: _fieldBorder(),
                      enabledBorder: _fieldBorder(),
                      focusedBorder: _fieldBorder(
                        color: _error == null
                            ? AppTheme.amber
                            : AppTheme.dangerRed,
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.dangerRedLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          _DialogFooter(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: _secondaryButtonStyle(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.gavel_outlined, size: 15),
                  label: Text(
                    _isSubmitting
                        ? 'Authorising...'
                        : (isRefund ? 'Authorise refund' : 'Authorise void'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.dangerRed,
                    foregroundColor: AppTheme.windowWidgetBackgroundBlack,
                    disabledBackgroundColor: AppTheme.dangerRed.withValues(
                      alpha: 0.4,
                    ),
                    disabledForegroundColor:
                        AppTheme.windowWidgetBackgroundBlack,
                    elevation: 0,
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final bool accepted = await widget.onSubmit(
      _pinController.text,
      _reasonController.text,
    );

    if (!mounted) return;

    if (accepted) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _error = 'Incorrect manager PIN. Try again.';
    });
  }

  OutlineInputBorder _fieldBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(
        color: color ?? AppTheme.lightAmberWhite.withValues(alpha: 0.16),
        width: color == null ? 0.6 : 0.9,
      ),
    );
  }
}

class OrderReceiptPreviewDialog extends StatelessWidget {
  const OrderReceiptPreviewDialog({
    super.key,
    required this.order,
    required this.orderController,
  });

  final Order order;
  final OrderController orderController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ReceiptDocument document = orderController.buildReceiptDocument(
        order,
      );
      final String receiptUrl = ReceiptLink.forDocument(document).toString();
      final bool isPrinting = orderController.isPrintingOrder(order.id);
      final bool isUnpaid = order.paymentStatus == PaymentStatus.unpaid;

      return _DialogShell(
        maxWidth: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(
              icon: Icons.receipt_long_outlined,
              title: 'Receipt preview',
              subtitle: '${order.id} · 80mm thermal',
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: ReceiptPaperWidget(
                  document: document,
                  qrData: receiptUrl,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 6,
                children: [
                  if (isUnpaid)
                    const Text(
                      'The bill is still unpaid. Settle the ticket before '
                      'printing the invoice.',
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.35,
                        color: AppTheme.badgeAmberText,
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: isPrinting
                        ? null
                        : () => orderController.printReceipt(order),
                    icon: isPrinting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.windowWidgetBackgroundBlack,
                            ),
                          )
                        : const Icon(Icons.print_outlined, size: 17),
                    label: Text(
                      isPrinting ? 'Sending to printer...' : 'Print receipt',
                    ),
                    style: _primaryButtonStyle(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Shared dialog chrome
// ---------------------------------------------------------------------------

class _DialogShell extends StatelessWidget {
  const _DialogShell({required this.child, required this.maxWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.sizeOf(context).height - 80,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppTheme.windowWidgetBackgroundBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onClose,
    this.iconColor = AppTheme.amber,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onClose;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBackgroundBlack,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.white,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 17),
            color: AppTheme.tableHeaderText,
            tooltip: 'Close',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
      child: Row(children: children),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 8.5,
        letterSpacing: 0.7,
        fontWeight: FontWeight.w700,
        color: AppTheme.tableHeaderText,
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    switch (method) {
      case PaymentMethod.cash:
        icon = Icons.payments_outlined;
      case PaymentMethod.bKash:
        icon = Icons.account_balance_wallet_outlined;
      case PaymentMethod.card:
        icon = Icons.credit_card_outlined;
      case PaymentMethod.nagad:
        icon = Icons.smartphone;
    }

    return Material(
      color: selected
          ? AppTheme.amber.withValues(alpha: 0.1)
          : AppTheme.topbarBackgroundBlack,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: selected
                  ? AppTheme.amber.withValues(alpha: 0.6)
                  : AppTheme.lightAmberWhite.withValues(alpha: 0.14),
              width: selected ? 0.8 : 0.6,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? AppTheme.amber : AppTheme.tableHeaderText,
              ),
              Text(
                method.label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppTheme.badgeAmberText
                      : AppTheme.lightAmberWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  final int amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.amber.withValues(alpha: 0.1)
          : AppTheme.topbarBackgroundBlack,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: selected
                  ? AppTheme.amber.withValues(alpha: 0.5)
                  : AppTheme.lightAmberWhite.withValues(alpha: 0.12),
              width: 0.6,
            ),
          ),
          child: Text(
            formatTakaSymbol(amount),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: selected
                  ? AppTheme.badgeAmberText
                  : AppTheme.tableHeaderText,
            ),
          ),
        ),
      ),
    );
  }
}

ButtonStyle _primaryButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: AppTheme.amber,
    foregroundColor: AppTheme.windowWidgetBackgroundBlack,
    disabledBackgroundColor: AppTheme.amber.withValues(alpha: 0.35),
    disabledForegroundColor: AppTheme.windowWidgetBackgroundBlack,
    elevation: 0,
    minimumSize: const Size(0, 38),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
  );
}

ButtonStyle _secondaryButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: AppTheme.lightAmberWhite,
    disabledForegroundColor: AppTheme.tableHeaderText,
    side: BorderSide(
      color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
      width: 0.6,
    ),
    minimumSize: const Size(0, 38),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
  );
}
