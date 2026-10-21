import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/customers/controller/customer_controller.dart';
import 'package:omnix/features/customers/model/customer_model.dart';

enum CustomerDialogMode {
  /// Used from the POS ticket: attach an existing customer or create one.
  attachToTicket,

  /// Used from the Customers screen: add a new directory customer.
  addCustomer,
}

/// Phone-first customer dialog shared by the POS and the Customers screen.
///
/// The phone number is the customer identifier. The name field only appears
/// when no customer is found for that number, and the name can be left blank.
class CustomerPhoneDialogWidget extends StatefulWidget {
  const CustomerPhoneDialogWidget({
    super.key,
    required this.mode,
    this.initialPhone,
  });

  final CustomerDialogMode mode;
  final String? initialPhone;

  @override
  State<CustomerPhoneDialogWidget> createState() =>
      _CustomerPhoneDialogWidgetState();
}

class _CustomerPhoneDialogWidgetState extends State<CustomerPhoneDialogWidget> {
  late final CustomerController _customerController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  bool _isSaving = false;
  String _phone = '';

  bool get _isAttachMode => widget.mode == CustomerDialogMode.attachToTicket;

  String get _phoneDigits => CustomerController.normalizePhone(_phone);

  bool get _isPhoneValid => _phoneDigits.length >= 6;

  Customer? get _existingCustomer {
    if (!_isPhoneValid) return null;
    return _customerController.findByPhone(_phone);
  }

  String? get _phoneErrorText {
    if (_phone.isEmpty || _isPhoneValid) return null;
    return 'Enter at least 6 digits';
  }

  @override
  void initState() {
    super.initState();
    _customerController = Get.find<CustomerController>();
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _nameController = TextEditingController();
    _nameFocusNode = FocusNode();
    _phone = _phoneController.text.trim();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    setState(() {
      _phone = value.trim();
    });
  }

  Future<void> _submit() async {
    if (!_isPhoneValid || _existingCustomer != null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final Customer customer = await _customerController.addCustomer(
        phone: _phone.trim(),
        name: _nameController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pop(customer);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the customer. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Customer? existing = _existingCustomer;

    return AlertDialog(
      backgroundColor: AppTheme.windowWidgetBackgroundBlack,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
          width: 0.8,
        ),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 10, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              existing == null ? Icons.phone_outlined : Icons.person_outline,
              size: 18,
              color: AppTheme.amber,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAttachMode ? 'Attach Customer' : 'Add Customer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Enter the phone number first',
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
          IconButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 18),
            color: AppTheme.tableHeaderText,
            tooltip: 'Close',
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFieldLabel('CUSTOMER PHONE'),
            const SizedBox(height: 5),
            TextField(
              key: const Key('customer-phone-field'),
              controller: _phoneController,
              autofocus: true,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
              ],
              onChanged: _onPhoneChanged,
              onSubmitted: (_) {
                if (_existingCustomer == null && _isPhoneValid) {
                  _nameFocusNode.requestFocus();
                }
              },
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightAmberWhite,
              ),
              cursorColor: AppTheme.amber,
              decoration: _fieldDecoration(
                hint: 'e.g. 01819-876543',
                icon: Icons.phone_outlined,
                errorText: _phoneErrorText,
              ),
            ),
            const SizedBox(height: 10),
            if (!_isPhoneValid)
              _buildHint(
                'Enter the customer phone number to continue. If the number '
                'is already registered, the customer name will appear here.',
              )
            else if (existing != null)
              _buildExistingCustomer(existing)
            else ...[
              _buildFieldLabel('CUSTOMER NAME (OPTIONAL)'),
              const SizedBox(height: 5),
              TextField(
                key: const Key('customer-name-field'),
                controller: _nameController,
                focusNode: _nameFocusNode,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightAmberWhite,
                ),
                cursorColor: AppTheme.amber,
                decoration: _fieldDecoration(
                  hint: 'Leave blank to show N/A on the receipt',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 8),
              _buildHint(
                'No customer found for this number. Add a name or leave it '
                'blank; the phone number still identifies the customer.',
              ),
            ],
          ],
        ),
      ),
      actions: _buildActions(existing),
    );
  }

  List<Widget> _buildActions(Customer? existing) {
    if (existing != null) {
      if (!_isAttachMode) {
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: _textButtonStyle(),
            child: const Text(
              'Close',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ];
      }

      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: _textButtonStyle(),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          key: const Key('customer-use-existing-button'),
          onPressed: () => Navigator.of(context).pop(existing),
          style: _primaryButtonStyle(),
          child: const Text(
            'Use Customer',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
        style: _textButtonStyle(),
        child: const Text(
          'Cancel',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      ElevatedButton(
        key: const Key('customer-save-button'),
        onPressed: _isPhoneValid && !_isSaving ? _submit : null,
        style: _primaryButtonStyle(),
        child: _isSaving
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.windowWidgetBackgroundBlack,
                ),
              )
            : Text(
                _isAttachMode ? 'Add & Attach' : 'Add Customer',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ];
  }

  Widget _buildExistingCustomer(Customer customer) {
    return Container(
      key: const Key('customer-existing-card'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppTheme.successGreen.withValues(alpha: 0.28),
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 19,
            color: AppTheme.successGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXISTING CUSTOMER',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  customer.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  customer.phone,
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
          const SizedBox(width: 8),
          Text(
            '${customer.visits} visits',
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHint(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
          width: 0.6,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 13,
            color: AppTheme.tableHeaderText,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 9.5,
                height: 1.45,
                color: AppTheme.tableHeaderText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppTheme.tableHeaderText,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    String? errorText,
  }) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppTheme.topbarBackgroundBlack,
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppTheme.tableHeaderText,
      ),
      prefixIcon: Icon(icon, size: 17, color: AppTheme.tableHeaderText),
      prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      errorText: errorText,
      errorStyle: const TextStyle(fontSize: 9.5, height: 1.2),
      border: _fieldBorder(),
      enabledBorder: _fieldBorder(),
      focusedBorder: _fieldBorder(color: AppTheme.amber),
      errorBorder: _fieldBorder(color: AppTheme.dangerRedLight),
      focusedErrorBorder: _fieldBorder(color: AppTheme.dangerRedLight),
    );
  }

  OutlineInputBorder _fieldBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: color ?? AppTheme.lightAmberWhite.withValues(alpha: 0.12),
        width: 0.7,
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.amber,
      foregroundColor: AppTheme.windowWidgetBackgroundBlack,
      disabledBackgroundColor: AppTheme.sidebarBackgroundBlack,
      disabledForegroundColor: AppTheme.tableHeaderText,
      elevation: 0,
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  ButtonStyle _textButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: AppTheme.tableHeaderText,
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
