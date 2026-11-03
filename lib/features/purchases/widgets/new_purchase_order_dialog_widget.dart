import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/purchases/controller/purchase_controller.dart';
import 'package:omnix/features/purchases/model/purchase_model.dart';
import 'package:omnix/features/purchases/model/vendor_model.dart';
import 'package:omnix/features/purchases/widgets/purchases_dialog_shell.dart';

/// Opens the New Purchase Order dialog, optionally pre-filled with the vendor
/// the buyer clicked (used by the "Order PO" button of the vendor directory).
Future<bool?> showNewPurchaseOrderDialog({
  required BuildContext context,
  required PurchaseController controller,
  Vendor? initialVendor,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.78),
    builder: (BuildContext context) {
      return NewPurchaseOrderDialog(
        controller: controller,
        initialVendor: initialVendor,
      );
    },
  );
}

/// Editable purchase order builder: supplier, destination, expected delivery,
/// payment plan and a dynamic list of commodity lines.
class NewPurchaseOrderDialog extends StatefulWidget {
  const NewPurchaseOrderDialog({
    super.key,
    required this.controller,
    this.initialVendor,
  });

  final PurchaseController controller;
  final Vendor? initialVendor;

  @override
  State<NewPurchaseOrderDialog> createState() => _NewPurchaseOrderDialogState();
}

class _NewPurchaseOrderDialogState extends State<NewPurchaseOrderDialog> {
  static const int _maxLines = 8;

  final TextEditingController _paidController = TextEditingController();

  final List<_LineDraft> _lines = <_LineDraft>[];

  String? _vendorId;
  late String _destination;
  late DateTime _expectedAt;
  PaymentStatus _payment = PaymentStatus.unpaid;
  String? _error;

  @override
  void initState() {
    super.initState();

    final List<Vendor> vendors = widget.controller.vendors;
    final Vendor? initial = widget.initialVendor;

    if (initial != null) {
      _vendorId = initial.id;
    } else if (vendors.isNotEmpty) {
      _vendorId = vendors.first.id;
    }

    _destination = PurchaseController.destinations.first;

    // default the delivery window to tomorrow morning
    final DateTime now = DateTime.now();
    final DateTime tomorrow = now.add(const Duration(days: 1));
    _expectedAt = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);

    _lines.add(_LineDraft(PurchaseController.lineUnits.first));
  }

  @override
  void dispose() {
    _paidController.dispose();
    for (final _LineDraft line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Vendor? get _selectedVendor {
    final String? id = _vendorId;
    if (id == null) return null;

    for (final Vendor vendor in widget.controller.vendors) {
      if (vendor.id == id) return vendor;
    }
    return null;
  }

  int get _orderTotal =>
      _lines.fold(0, (int sum, _LineDraft line) => sum + line.total);

  @override
  Widget build(BuildContext context) {
    return PurchasesDialogShell(
      dialogKey: const Key('purchases-po-dialog'),
      icon: Icons.post_add,
      title: 'New Purchase Order',
      subtitle: 'Raise a requisition and schedule the inbound delivery.',
      closeKey: const Key('purchases-po-close'),
      onClose: () => Navigator.of(context).pop(false),
      maxWidth: 720,
      footer: PurchasesDialogFooter(
        cancelKey: const Key('purchases-po-cancel'),
        onCancel: () => Navigator.of(context).pop(false),
        submitKey: const Key('purchases-po-submit'),
        onSubmit: _submit,
        submitLabel: 'Raise Purchase Order',
        submitIcon: Icons.send_outlined,
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 16,
        children: [
          _buildSupplierField(),
          _buildDestinationAndSchedule(),
          _buildPaymentFields(),
          _buildLinesSection(),
          if (_error != null) _buildError(),
          _buildTotalCard(),
        ],
      ),
    );
  }

  Widget _buildSupplierField() {
    final List<Vendor> vendors = widget.controller.vendors;

    return Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const PurchasesFieldLabel(label: 'Supplier', isRequired: true),
        if (vendors.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.topbarBackgroundBlack,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.dangerRedLight.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
            child: const Text(
              'Register a supplier before raising a purchase order.',
              style: TextStyle(fontSize: 12, color: AppTheme.dangerRedLight),
            ),
          )
        else
          DropdownButtonFormField<String>(
            key: const Key('purchases-po-supplier'),
            initialValue: _vendorId,
            isExpanded: true,
            dropdownColor: AppTheme.sidebarBackgroundBlack,
            borderRadius: BorderRadius.circular(8),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppTheme.tableHeaderText,
            ),
            style: purchasesInputTextStyle,
            decoration: purchasesInputDecoration(),
            items: vendors.map((Vendor vendor) {
              return DropdownMenuItem<String>(
                value: vendor.id,
                child: Text('${vendor.name} · ${vendor.id}'),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) setState(() => _vendorId = value);
            },
          ),
      ],
    );
  }

  Widget _buildDestinationAndSchedule() {
    final Widget destination = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const PurchasesFieldLabel(label: 'Deliver To'),
        DropdownButtonFormField<String>(
          key: const Key('purchases-po-destination'),
          initialValue: _destination,
          isExpanded: true,
          dropdownColor: AppTheme.sidebarBackgroundBlack,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppTheme.tableHeaderText,
          ),
          style: purchasesInputTextStyle,
          decoration: purchasesInputDecoration(),
          items: PurchaseController.destinations.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? value) {
            if (value != null) setState(() => _destination = value);
          },
        ),
      ],
    );

    final Widget schedule = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const PurchasesFieldLabel(label: 'Expected Delivery'),
        _ScheduleField(
          key: const Key('purchases-po-expected'),
          value: formatSchedule(_expectedAt),
          onTap: _pickExpected,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: .stretch,
            spacing: 15,
            children: [destination, schedule],
          );
        }

        return Row(
          crossAxisAlignment: .start,
          spacing: 12,
          children: [Expanded(child: destination), Expanded(child: schedule)],
        );
      },
    );
  }

  Widget _buildPaymentFields() {
    final Widget payment = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const PurchasesFieldLabel(label: 'Payment Plan'),
        DropdownButtonFormField<PaymentStatus>(
          key: const Key('purchases-po-payment'),
          initialValue: _payment,
          isExpanded: true,
          dropdownColor: AppTheme.sidebarBackgroundBlack,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppTheme.tableHeaderText,
          ),
          style: purchasesInputTextStyle,
          decoration: purchasesInputDecoration(),
          items: PaymentStatus.values.map((PaymentStatus value) {
            return DropdownMenuItem<PaymentStatus>(
              value: value,
              child: Text(value.label),
            );
          }).toList(),
          onChanged: (PaymentStatus? value) {
            if (value != null) setState(() => _payment = value);
          },
        ),
      ],
    );

    if (_payment != PaymentStatus.partial) return payment;

    return Row(
      crossAxisAlignment: .start,
      spacing: 12,
      children: [
        Expanded(child: payment),
        Expanded(
          child: Column(
            crossAxisAlignment: .stretch,
            spacing: 6,
            children: [
              const PurchasesFieldLabel(
                label: 'Advance Paid',
                hint: 'BDT (৳)',
              ),
              TextField(
                key: const Key('purchases-po-paid'),
                controller: _paidController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: purchasesInputTextStyle,
                decoration: purchasesInputDecoration(
                  hint: 'e.g. 20000',
                  prefixText: '৳ ',
                  prefixStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.amber,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinesSection() {
    return Column(
      crossAxisAlignment: .stretch,
      spacing: 10,
      children: [
        Row(
          children: [
            const Expanded(
              child: PurchasesFieldLabel(
                label: 'Commodity Lines',
                isRequired: true,
              ),
            ),
            Text(
              '${_lines.length} / $_maxLines',
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.tableHeaderText,
              ),
            ),
          ],
        ),
        for (int index = 0; index < _lines.length; index++) ...[
          _buildLineCard(index),
          if (index < _lines.length - 1) const SizedBox(height: 10),
        ],
        Align(
          alignment: .centerLeft,
          child: TextButton.icon(
            key: const Key('purchases-po-add-line'),
            onPressed: _lines.length >= _maxLines ? null : _addLine,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Line'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.amber,
              disabledForegroundColor: AppTheme.tableHeaderText,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineCard(int index) {
    final _LineDraft line = _lines[index];
    final bool canRemove = _lines.length > 1;

    void refresh() => setState(() {});

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
          width: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 10,
        children: [
          Row(
            children: [
              Text(
                'Line ${index + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppTheme.tableHeaderText,
                ),
              ),
              const Spacer(),
              Text(
                formatTakaSymbol(line.total),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.badgeAmberText,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                key: Key('purchases-po-line-remove-$index'),
                tooltip: canRemove ? 'Remove line' : 'At least one line',
                onPressed: canRemove ? () => _removeLine(index) : null,
                icon: const Icon(Icons.delete_outline, size: 16),
                color: AppTheme.dangerRedLight,
                disabledColor: AppTheme.tableHeaderText,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.sidebarBackgroundBlack,
                  minimumSize: const Size(30, 30),
                  maximumSize: const Size(30, 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            ],
          ),
          TextField(
            key: Key('purchases-po-line-name-$index'),
            controller: line.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            style: purchasesInputTextStyle,
            onChanged: (_) => refresh(),
            decoration: purchasesInputDecoration(hint: 'Item name'),
          ),
          Row(
            crossAxisAlignment: .start,
            spacing: 8,
            children: [
              Expanded(
                child: TextField(
                  key: Key('purchases-po-line-qty-$index'),
                  controller: line.quantity,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  style: purchasesInputTextStyle,
                  onChanged: (_) => refresh(),
                  decoration: purchasesInputDecoration(hint: 'Qty'),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
                      width: 0.8,
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    key: Key('purchases-po-line-unit-$index'),
                    initialValue: line.unit,
                    isExpanded: true,
                    dropdownColor: AppTheme.sidebarBackgroundBlack,
                    borderRadius: BorderRadius.circular(8),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppTheme.tableHeaderText,
                    ),
                    style: purchasesInputTextStyle,
                    decoration: purchasesInputDecoration(),
                    items: PurchaseController.lineUnits.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) setState(() => line.unit = value);
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  key: Key('purchases-po-line-price-$index'),
                  controller: line.unitPrice,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: purchasesInputTextStyle,
                  onChanged: (_) => refresh(),
                  decoration: purchasesInputDecoration(
                    hint: 'Unit price',
                    prefixText: '৳ ',
                    prefixStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.amber,
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

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.amber.withValues(alpha: 0.3),
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, size: 16, color: AppTheme.amber),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Order Total',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.tablePrimaryText,
              ),
            ),
          ),
          Text(
            formatTakaSymbol(_orderTotal),
            key: const Key('purchases-po-total'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.badgeAmberText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Row(
      spacing: 6,
      children: [
        const Icon(
          Icons.error_outline,
          size: 14,
          color: AppTheme.dangerRedLight,
        ),
        Expanded(
          child: Text(
            _error!,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.dangerRedLight,
            ),
          ),
        ),
      ],
    );
  }

  void _addLine() {
    setState(() {
      _lines.add(_LineDraft(PurchaseController.lineUnits.first));
      _error = null;
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lines.removeAt(index).dispose();
      _error = null;
    });
  }

  Future<void> _pickExpected() async {
    final DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _expectedAt,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expectedAt),
    );
    if (!mounted) return;

    final TimeOfDay resolved = time ?? TimeOfDay.fromDateTime(_expectedAt);
    setState(() {
      _expectedAt = DateTime(
        date.year,
        date.month,
        date.day,
        resolved.hour,
        resolved.minute,
      );
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    final Vendor? vendor = _selectedVendor;
    if (vendor == null) {
      setState(() => _error = 'Select a supplier for this order.');
      return;
    }

    // ignore leftover blank rows, only keep lines the buyer actually filled
    final List<_LineDraft> drafts = _lines
        .where(
          (_LineDraft line) =>
              line.name.text.trim().isNotEmpty ||
              line.unitPrice.text.trim().isNotEmpty,
        )
        .toList();

    if (drafts.isEmpty) {
      setState(() => _error = 'Add at least one commodity line.');
      return;
    }

    for (final _LineDraft line in drafts) {
      if (line.name.text.trim().isEmpty) {
        setState(() => _error = 'Every line needs an item name.');
        return;
      }
      if (line.parsedQuantity <= 0) {
        setState(() => _error = 'Enter a quantity greater than 0.');
        return;
      }
      if (line.parsedUnitPrice <= 0) {
        setState(() => _error = 'Enter a unit price greater than 0.');
        return;
      }
    }

    final int total = drafts.fold(
      0,
      (int sum, _LineDraft line) => sum + line.total,
    );
    final int paid = _resolvePaidAmount(total);

    widget.controller.createPurchase(
      vendor: vendor,
      destination: _destination,
      expectedAt: _expectedAt,
      paymentStatus: _payment,
      paidAmount: paid,
      lines: drafts.map((_LineDraft line) => line.toLine()).toList(),
    );

    Navigator.of(context).pop(true);
  }

  int _resolvePaidAmount(int total) {
    switch (_payment) {
      case PaymentStatus.unpaid:
        return 0;
      case PaymentStatus.paid:
        return total;
      case PaymentStatus.partial:
        final int paid = int.tryParse(_paidController.text.trim()) ?? 0;
        return paid.clamp(0, total);
    }
  }
}

/// Mutable controllers behind one commodity line of the builder.
class _LineDraft {
  _LineDraft(this.unit) : quantity = TextEditingController(text: '1');

  final TextEditingController name = TextEditingController();
  final TextEditingController quantity;
  final TextEditingController unitPrice = TextEditingController();

  String unit;

  double get parsedQuantity => double.tryParse(quantity.text.trim()) ?? 0;

  int get parsedUnitPrice => int.tryParse(unitPrice.text.trim()) ?? 0;

  int get total => (parsedQuantity * parsedUnitPrice).round();

  PurchaseLine toLine() => PurchaseLine(
    name: name.text.trim(),
    quantity: parsedQuantity,
    unit: unit,
    unitPrice: parsedUnitPrice,
  );

  void dispose() {
    name.dispose();
    quantity.dispose();
    unitPrice.dispose();
  }
}

/// Read-only field that opens a date + time picker when tapped.
class _ScheduleField extends StatelessWidget {
  const _ScheduleField({super.key, required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.topbarBackgroundBlack,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.amber.withValues(alpha: 0.08),
        child: Container(
          height: 47,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
              width: 0.8,
            ),
          ),
          child: Row(
            spacing: 8,
            children: [
              const Icon(
                Icons.event_outlined,
                size: 16,
                color: AppTheme.tableHeaderText,
              ),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: purchasesInputTextStyle,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AppTheme.tableHeaderText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
