import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/purchases/controller/purchase_controller.dart';
import 'package:omnix/features/purchases/model/vendor_model.dart';
import 'package:omnix/features/purchases/widgets/purchases_dialog_shell.dart';

/// Opens the Register Supplier dialog. Resolves to the created [Vendor] once
/// the supplier was added to the directory, or `null` when it was cancelled.
Future<Vendor?> showRegisterSupplierDialog({
  required BuildContext context,
  required PurchaseController controller,
}) {
  return showDialog<Vendor>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.78),
    builder: (BuildContext context) {
      return RegisterSupplierDialog(controller: controller);
    },
  );
}

/// Supplier onboarding form used by the purchases header and the vendor tab.
class RegisterSupplierDialog extends StatefulWidget {
  const RegisterSupplierDialog({super.key, required this.controller});

  final PurchaseController controller;

  @override
  State<RegisterSupplierDialog> createState() => _RegisterSupplierDialogState();
}

class _RegisterSupplierDialogState extends State<RegisterSupplierDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _representativeController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late String _category;
  late String _tier;
  late String _creditTerms;

  @override
  void initState() {
    super.initState();
    _category = PurchaseController.supplierCategories.first;
    _tier = PurchaseController.supplierTiers[1];
    _creditTerms = PurchaseController.creditTerms.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _representativeController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PurchasesDialogShell(
      dialogKey: const Key('purchases-supplier-dialog'),
      icon: Icons.storefront_outlined,
      title: 'Register Supplier',
      subtitle: 'Add a verified vendor to the procurement directory.',
      closeKey: const Key('purchases-supplier-close'),
      onClose: () => Navigator.of(context).pop(),
      maxWidth: 580,
      footer: PurchasesDialogFooter(
        cancelKey: const Key('purchases-supplier-cancel'),
        onCancel: () => Navigator.of(context).pop(),
        submitKey: const Key('purchases-supplier-submit'),
        onSubmit: _submit,
        submitLabel: 'Register Supplier',
        submitIcon: Icons.person_add_alt,
      ),
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 460;

            return Column(
              crossAxisAlignment: .stretch,
              spacing: 15,
              children: [
                _buildNameField(),
                _buildCategoryAndTier(wide),
                _buildRepresentativeAndPhone(wide),
                _buildCreditTerms(),
                _buildDescription(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const PurchasesFieldLabel(
          label: 'Business Name',
          isRequired: true,
        ),
        TextFormField(
          key: const Key('purchases-supplier-name'),
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 60,
          style: purchasesInputTextStyle,
          decoration: purchasesInputDecoration(
            hint: 'e.g. Bengal Meat Agro Supply Ltd',
            counterText: '',
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter the supplier name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryAndTier(bool wide) {
    final Widget category = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const PurchasesFieldLabel(label: 'Category', isRequired: true),
        DropdownButtonFormField<String>(
          key: const Key('purchases-supplier-category'),
          initialValue: _category,
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
          items: PurchaseController.supplierCategories.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? value) {
            if (value != null) setState(() => _category = value);
          },
        ),
      ],
    );

    final Widget tier = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const PurchasesFieldLabel(label: 'Supply Tier'),
        DropdownButtonFormField<String>(
          key: const Key('purchases-supplier-tier'),
          initialValue: _tier,
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
          items: PurchaseController.supplierTiers.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? value) {
            if (value != null) setState(() => _tier = value);
          },
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: .stretch,
        spacing: 15,
        children: [category, tier],
      );
    }

    return Row(
      crossAxisAlignment: .start,
      spacing: 12,
      children: [Expanded(child: category), Expanded(child: tier)],
    );
  }

  Widget _buildRepresentativeAndPhone(bool wide) {
    final Widget representative = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const PurchasesFieldLabel(label: 'Contact Representative'),
        TextFormField(
          key: const Key('purchases-supplier-representative'),
          controller: _representativeController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 40,
          style: purchasesInputTextStyle,
          decoration: purchasesInputDecoration(
            hint: 'e.g. Nazmul H.',
            counterText: '',
          ),
        ),
      ],
    );

    final Widget phone = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const PurchasesFieldLabel(label: 'Contact Phone'),
        TextFormField(
          key: const Key('purchases-supplier-phone'),
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          maxLength: 20,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
          ],
          style: purchasesInputTextStyle,
          decoration: purchasesInputDecoration(
            hint: 'e.g. +880 1711-000000',
            counterText: '',
          ),
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: .stretch,
        spacing: 15,
        children: [representative, phone],
      );
    }

    return Row(
      crossAxisAlignment: .start,
      spacing: 12,
      children: [Expanded(child: representative), Expanded(child: phone)],
    );
  }

  Widget _buildCreditTerms() {
    return Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const PurchasesFieldLabel(label: 'Credit Terms'),
        DropdownButtonFormField<String>(
          key: const Key('purchases-supplier-terms'),
          initialValue: _creditTerms,
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
          items: PurchaseController.creditTerms.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? value) {
            if (value != null) setState(() => _creditTerms = value);
          },
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const PurchasesFieldLabel(
          label: 'Supplied Commodities',
          hint: 'OPTIONAL',
        ),
        TextFormField(
          key: const Key('purchases-supplier-description'),
          controller: _descriptionController,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          maxLines: 2,
          maxLength: 140,
          style: purchasesInputTextStyle,
          decoration: purchasesInputDecoration(
            hint: 'e.g. Fresh mutton, chuck beef and marrow bones.',
            counterText: '',
          ),
          onFieldSubmitted: (_) => _submit(),
        ),
      ],
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final Vendor vendor = widget.controller.registerSupplier(
      name: _nameController.text,
      category: _category,
      tier: _tier,
      creditTerms: _creditTerms,
      representative: _representativeController.text,
      phone: _phoneController.text,
      description: _descriptionController.text,
    );

    Navigator.of(context).pop(vendor);
  }
}
