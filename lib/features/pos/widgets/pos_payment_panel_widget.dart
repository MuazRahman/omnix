import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/model/pos_tender_mode_model.dart';

/// Tender mode, payment entry and the checkout action.
class PosPaymentPanelWidget extends StatelessWidget {
  const PosPaymentPanelWidget({
    super.key,
    required this.posController,
    required this.onCompleteSale,
  });

  final PosController posController;
  final VoidCallback onCompleteSale;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isCash = posController.tenderMode.value == PosTenderMode.cash;
      final bool isMobileWallet =
          posController.tenderMode.value == PosTenderMode.mobileWallet;

      return Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: AppTheme.windowWidgetBackgroundBlack,
          border: Border(
            top: BorderSide(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
              width: 0.6,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SELECT TENDER MODE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppTheme.tableHeaderText,
              ),
            ),
            const SizedBox(height: 7),

            Row(
              spacing: 8,
              children: PosTenderMode.values.map((PosTenderMode mode) {
                return Expanded(
                  child: _TenderModeButton(
                    mode: mode,
                    isSelected: posController.tenderMode.value == mode,
                    onTap: () => posController.tenderModeOnChanged(mode),
                  ),
                );
              }).toList(),
            ),

            // bKash/Nagad cashout charge and its edit action
            if (isMobileWallet) ...[
              const SizedBox(height: 8),
              _MobileWalletChargeButton(
                percent: posController.mobileWalletCashoutPercent.value,
                charge: posController.mobileWalletCashoutCharge,
                onTap: () => _editMobileWalletCharge(context),
              ),
            ],

            // cash entry and live change calculation
            if (isCash) ...[
              const SizedBox(height: 8),
              _CashReceivedField(posController: posController),
              const SizedBox(height: 6),

              if (posController.cashReceived.value > 0) ...[
                const SizedBox(height: 7),
                _CashSettlementSummary(
                  given: posController.cashReceived.value,
                  total: posController.total,
                ),
              ],
            ],

            if (!posController.hasCustomerPhone) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.amber.withValues(alpha: 0.2),
                    width: 0.6,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 13, color: AppTheme.amber),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Add a customer phone number to print this sale.',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: AppTheme.badgeAmberText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 9),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: posController.canPrint ? onCompleteSale : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.amber,
                  disabledBackgroundColor: AppTheme.sidebarBackgroundBlack,
                  foregroundColor: AppTheme.windowWidgetBackgroundBlack,
                  disabledForegroundColor: AppTheme.tableHeaderText,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    const Icon(Icons.print_outlined, size: 18),
                    const Flexible(
                      child: Text(
                        'Complete Sale & Print',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.windowWidgetBackgroundBlack.withValues(
                          alpha: 0.16,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'ENTER',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _editMobileWalletCharge(BuildContext context) async {
    final double? percent = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return _MobileWalletChargeDialog(
          initialPercent: posController.mobileWalletCashoutPercent.value,
          billBeforeCharge: posController.totalBeforeCashout,
        );
      },
    );

    if (percent == null) return;
    posController.setMobileWalletCashoutPercent(percent);
  }
}

class _CashReceivedField extends StatefulWidget {
  const _CashReceivedField({required this.posController});

  final PosController posController;

  @override
  State<_CashReceivedField> createState() => _CashReceivedFieldState();
}

class _CashReceivedFieldState extends State<_CashReceivedField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Worker? _cashWorker;

  PosController get _posController => widget.posController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _textFor(_posController.cashReceived.value),
    );
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    _cashWorker = ever<int>(_posController.cashReceived, _syncText);
  }

  String _textFor(int amount) => amount == 0 ? '' : '$amount';

  // Keeps the field in sync with quick-cash buttons and a completed sale,
  // without resetting the cursor while the cashier is typing.
  void _syncText(int amount) {
    if (amount == 0) {
      if (_controller.text.isEmpty) return;
      // Keep a zero the cashier is currently typing.
      if (_focusNode.hasFocus && _controller.text == '0') return;

      _controller.clear();
      return;
    }

    final String next = _textFor(amount);
    if (_controller.text == next) return;

    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) return;
    _syncText(_posController.cashReceived.value);
  }

  void _onChanged(String text) {
    _posController.setCashReceived(int.tryParse(text) ?? 0);
  }

  @override
  void dispose() {
    _cashWorker?.dispose();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('pos-cash-received-field'),
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: _onChanged,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.lightAmberWhite,
      ),
      cursorColor: AppTheme.amber,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppTheme.topbarBackgroundBlack,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        prefixText: '৳ ',
        prefixStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.amber,
        ),
        hintText: 'Cash received from customer',
        hintStyle: const TextStyle(
          fontSize: 11,
          color: AppTheme.tableHeaderText,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: AppTheme.amber),
      ),
    );
  }

  OutlineInputBorder _border({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: color ?? AppTheme.lightAmberWhite.withValues(alpha: 0.12),
        width: color == null ? 0.6 : 1,
      ),
    );
  }
}

class _CashSettlementSummary extends StatelessWidget {
  const _CashSettlementSummary({required this.given, required this.total});

  final int given;
  final int total;

  @override
  Widget build(BuildContext context) {
    final bool isDiscount = given < total;
    final int difference = isDiscount ? total - given : given - total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            'Given ${formatTakaSymbol(given)}',
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.tableHeaderText,
            ),
          ),
          const Spacer(),
          Text(
            isDiscount
                ? 'Discount ${formatTakaSymbol(difference)}'
                : 'Change ${formatTakaSymbol(difference)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDiscount ? AppTheme.amber : AppTheme.lightGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileWalletChargeButton extends StatelessWidget {
  const _MobileWalletChargeButton({
    required this.percent,
    required this.charge,
    required this.onTap,
  });

  final double percent;
  final int charge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('pos-mobile-wallet-charge-button'),
      color: AppTheme.topbarBackgroundBlack,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: AppTheme.amber.withValues(alpha: 0.08),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
              width: 0.6,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 14,
                color: AppTheme.amber,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'bKash/Nagad cashout · ${_formatPercent(percent)}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.lightAmberWhite,
                  ),
                ),
              ),
              Text(
                '+ ${formatTakaSymbol(charge)}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.amber,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.edit_outlined,
                size: 12,
                color: AppTheme.tableHeaderText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPercent(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}

class _MobileWalletChargeDialog extends StatefulWidget {
  const _MobileWalletChargeDialog({
    required this.initialPercent,
    required this.billBeforeCharge,
  });

  final double initialPercent;
  final int billBeforeCharge;

  @override
  State<_MobileWalletChargeDialog> createState() =>
      _MobileWalletChargeDialogState();
}

class _MobileWalletChargeDialogState extends State<_MobileWalletChargeDialog> {
  late final TextEditingController _controller;
  double? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialPercent;
    _controller = TextEditingController(
      text: _formatPercent(widget.initialPercent),
    );
  }

  String _formatPercent(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  String? get _errorText {
    final String text = _controller.text.trim();
    if (text.isEmpty) return 'Enter a percentage';

    final double? value = double.tryParse(text);
    if (value == null || value < 0 || value > 100) {
      return 'Use a value between 0 and 100';
    }

    return null;
  }

  int get _previewCharge {
    final double value = _value ?? 0;
    return (widget.billBeforeCharge * value / 100).round();
  }

  void _submit() {
    if (_errorText != null) return;
    Navigator.of(context).pop(_value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.windowWidgetBackgroundBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
          width: 0.8,
        ),
      ),
      title: const Text(
        'bKash / Nagad Cashout Charge',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppTheme.white,
        ),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'This charge is added only when bKash / Nagad is selected.',
              style: TextStyle(fontSize: 11, color: AppTheme.tableHeaderText),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('pos-cashout-charge-field'),
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;

                  final bool valid = RegExp(r'^\d{0,3}(\.\d{0,2})?$')
                      .hasMatch(newValue.text);
                  return valid ? newValue : oldValue;
                }),
              ],
              onChanged: (String text) {
                setState(() {
                  _value = double.tryParse(text);
                });
              },
              onSubmitted: (_) => _submit(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightAmberWhite,
              ),
              cursorColor: AppTheme.amber,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppTheme.topbarBackgroundBlack,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                suffixText: '%',
                suffixStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.amber,
                ),
                errorText: _errorText,
                hintText: '1.5',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.tableHeaderText,
                ),
                border: _border(),
                enabledBorder: _border(),
                focusedBorder: _border(color: AppTheme.amber),
                errorBorder: _border(color: AppTheme.dangerRedLight),
                focusedErrorBorder: _border(color: AppTheme.dangerRedLight),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Charge on this bill',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
                const Spacer(),
                Text(
                  formatTakaSymbol(_previewCharge),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.tableHeaderText,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          key: const Key('pos-cashout-charge-apply'),
          onPressed: _errorText == null ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.amber,
            foregroundColor: AppTheme.windowWidgetBackgroundBlack,
            disabledBackgroundColor: AppTheme.sidebarBackgroundBlack,
            disabledForegroundColor: AppTheme.tableHeaderText,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            'Apply',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: color ?? AppTheme.lightAmberWhite.withValues(alpha: 0.12),
        width: color == null ? 0.6 : 1,
      ),
    );
  }
}

class _TenderModeButton extends StatelessWidget {
  const _TenderModeButton({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final PosTenderMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = isSelected
        ? AppTheme.windowWidgetBackgroundBlack
        : AppTheme.lightAmberWhite.withValues(alpha: 0.75);

    return Material(
      color: isSelected ? AppTheme.amber : AppTheme.sidebarBackgroundBlack,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        hoverColor: AppTheme.amber.withValues(alpha: 0.15),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: isSelected
                  ? AppTheme.amber
                  : AppTheme.lightAmberWhite.withValues(alpha: 0.12),
              width: 0.6,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              Icon(_iconFor(mode), size: 17, color: foreground),
              Text(
                mode.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(PosTenderMode mode) {
    switch (mode) {
      case PosTenderMode.cash:
        return Icons.payments_outlined;
      case PosTenderMode.mobileWallet:
        return Icons.account_balance_wallet_outlined;
      case PosTenderMode.card:
        return Icons.credit_card;
    }
  }
}
