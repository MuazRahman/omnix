import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/branches/model/branch_model.dart';

/// Opens the branch form. Pass [branch] to edit an existing outlet.
Future<bool?> showBranchDialog(
  BuildContext context,
  BranchController controller, {
  Branch? branch,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.74),
    builder: (BuildContext context) {
      return BranchAddDialog(controller: controller, branch: branch);
    },
  );
}

class BranchAddDialog extends StatefulWidget {
  const BranchAddDialog({super.key, required this.controller, this.branch});

  final BranchController controller;

  /// Existing outlet being edited, or `null` when adding a new one.
  final Branch? branch;

  @override
  State<BranchAddDialog> createState() => _BranchAddDialogState();
}

class _BranchAddDialogState extends State<BranchAddDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _vatController = TextEditingController(
    text: '10',
  );
  final TextEditingController _posController = TextEditingController(text: '1');

  String _manager = '';
  bool _isCloudKitchen = false;

  bool get _isEditing => widget.branch != null;

  @override
  void initState() {
    super.initState();

    final Branch? branch = widget.branch;
    final List<String> managers = widget.controller.managerOptions;
    _manager = branch != null && managers.contains(branch.manager)
        ? branch.manager
        : (managers.isEmpty ? '' : managers.first);

    if (branch != null) {
      _nameController.text = branch.name;
      _codeController.text = branch.id;
      _addressController.text = branch.address;
      _areaController.text = branch.area;
      _phoneController.text = branch.phone;
      _isCloudKitchen = branch.isCloudKitchen;
      _posController.text = branch.posTerminals.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _phoneController.dispose();
    _vatController.dispose();
    _posController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('branch-add-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: MediaQuery.sizeOf(context).height - 48,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.windowWidgetBackgroundBlack,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
                width: 0.8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: .stretch,
              children: [
                const _AccentLine(),
                _buildHeader(),
                _buildDivider(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                    child: Form(
                      key: _formKey,
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints c) {
                          final bool wide = c.maxWidth >= 520;

                          return Column(
                            crossAxisAlignment: .stretch,
                            spacing: 16,
                            children: [
                              _buildNameFields(wide),
                              _buildAddressFields(wide),
                              _buildContactFields(wide),
                              _buildConceptSelector(),
                              _buildFiscalFields(wide),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                _buildDivider(),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        crossAxisAlignment: .start,
        spacing: 12,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add_business_outlined,
              size: 22,
              color: AppTheme.amber,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 3,
              children: [
                Text(
                  _isEditing
                      ? 'Edit Restaurant Outlet'
                      : 'Add New Restaurant Outlet',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: AppTheme.white,
                  ),
                ),
                const Text(
                  'Provision location POS, ledger routing, and inventory sink.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('branch-dialog-close'),
            tooltip: 'Close dialog',
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close, size: 18),
            color: AppTheme.tableHeaderText,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.sidebarBackgroundBlack,
              minimumSize: const Size(34, 34),
              maximumSize: const Size(34, 34),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameFields(bool wide) {
    final Widget name = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Outlet / Branch Name', isRequired: true),
        TextFormField(
          key: const Key('branch-name-field'),
          controller: _nameController,
          autofocus: true,
          textInputAction: TextInputAction.next,
          maxLength: 60,
          style: _inputTextStyle,
          decoration: _inputDecoration(
            hint: 'e.g. Uttara Sector 3 Outlet',
            counterText: '',
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter an outlet name';
            }
            return null;
          },
        ),
      ],
    );

    final Widget code = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Branch Code', isRequired: true),
        TextFormField(
          key: const Key('branch-code-field'),
          controller: _codeController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.characters,
          maxLength: 12,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9-]')),
          ],
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: AppTheme.tablePrimaryText,
          ),
          decoration: _inputDecoration(hint: 'e.g. DHK-04', counterText: ''),
          validator: _validateCode,
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: .stretch,
        spacing: 16,
        children: [name, code],
      );
    }

    return Row(
      crossAxisAlignment: .start,
      spacing: 12,
      children: [
        Expanded(flex: 2, child: name),
        Expanded(child: code),
      ],
    );
  }

  String? _validateCode(String? value) {
    final String code = (value ?? '').trim().toUpperCase();
    if (code.isEmpty) return 'Enter a branch code';

    final bool taken = widget.controller.branchRecords.any(
      (Branch branch) =>
          branch.id.toUpperCase() == code &&
          branch.id != (widget.branch?.id ?? ''),
    );
    if (taken) return 'This code is already used';

    return null;
  }

  Widget _buildAddressFields(bool wide) {
    final Widget address = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Physical Address', isRequired: true),
        TextFormField(
          key: const Key('branch-address-field'),
          controller: _addressController,
          textInputAction: TextInputAction.next,
          maxLength: 120,
          style: _inputTextStyle,
          decoration: _inputDecoration(
            hint: 'Plot 18, Road 4, Sector 3',
            counterText: '',
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter the outlet address';
            }
            return null;
          },
        ),
      ],
    );

    final Widget area = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Area / City Zone', hint: 'Optional'),
        TextFormField(
          key: const Key('branch-area-field'),
          controller: _areaController,
          textInputAction: TextInputAction.next,
          maxLength: 80,
          style: _inputTextStyle,
          decoration: _inputDecoration(
            hint: 'Uttara, Dhaka 1230',
            counterText: '',
          ),
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: .stretch,
        spacing: 16,
        children: [address, area],
      );
    }

    return Row(
      crossAxisAlignment: .start,
      spacing: 12,
      children: [
        Expanded(flex: 3, child: address),
        Expanded(flex: 2, child: area),
      ],
    );
  }

  Widget _buildContactFields(bool wide) {
    final Widget phone = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Direct Phone Line', hint: 'Optional'),
        TextFormField(
          key: const Key('branch-phone-field'),
          controller: _phoneController,
          textInputAction: TextInputAction.next,
          maxLength: 24,
          style: _inputTextStyle,
          decoration: _inputDecoration(
            hint: '+880 1744-567890',
            counterText: '',
          ),
        ),
      ],
    );

    final Widget manager = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Assigned Branch Manager'),
        DropdownButtonFormField<String>(
          key: const Key('branch-manager-field'),
          initialValue: _manager.isEmpty ? null : _manager,
          isExpanded: true,
          dropdownColor: AppTheme.sidebarBackgroundBlack,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppTheme.tableHeaderText,
          ),
          style: _inputTextStyle,
          decoration: _inputDecoration(hint: 'Select or invite manager'),
          items: widget.controller.managerOptions.map((String manager) {
            return DropdownMenuItem<String>(
              value: manager,
              child: Text(
                manager,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) setState(() => _manager = value);
          },
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: .stretch,
        spacing: 16,
        children: [phone, manager],
      );
    }

    return Row(
      crossAxisAlignment: .start,
      spacing: 12,
      children: [
        Expanded(child: phone),
        Expanded(flex: 2, child: manager),
      ],
    );
  }

  Widget _buildConceptSelector() {
    Widget option({
      required bool cloud,
      required String title,
      required String subtitle,
      required IconData icon,
    }) {
      final bool selected = _isCloudKitchen == cloud;

      return Expanded(
        child: Material(
          color: selected
              ? AppTheme.amber.withValues(alpha: 0.08)
              : AppTheme.topbarBackgroundBlack,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            onTap: () => setState(() => _isCloudKitchen = cloud),
            borderRadius: BorderRadius.circular(9),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: selected
                      ? AppTheme.amber.withValues(alpha: 0.7)
                      : AppTheme.lightAmberWhite.withValues(alpha: 0.14),
                  width: selected ? 1 : 0.6,
                ),
              ),
              child: Row(
                crossAxisAlignment: .start,
                spacing: 10,
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: selected ? AppTheme.amber : AppTheme.tableHeaderText,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      spacing: 3,
                      children: [
                        Row(
                          spacing: 6,
                          children: [
                            Icon(
                              icon,
                              size: 15,
                              color: AppTheme.tablePrimaryText,
                            ),
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.tablePrimaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1.35,
                            color: AppTheme.badgeNeutralText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Operational Concept'),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final List<Widget> options = [
              option(
                cloud: false,
                title: 'Dine-in + Takeaway POS',
                subtitle:
                    'Full restaurant floor with table seating grids and '
                    'captain station POS.',
                icon: Icons.table_restaurant_outlined,
              ),
              option(
                cloud: true,
                title: 'Cloud Kitchen Only',
                subtitle:
                    'Online ordering & courier pickup dispatch counter only.',
                icon: Icons.delivery_dining_outlined,
              ),
            ];

            if (c.maxWidth < 520) {
              return Column(
                crossAxisAlignment: .stretch,
                spacing: 10,
                children: options,
              );
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: .stretch,
                spacing: 10,
                children: options,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFiscalFields(bool wide) {
    final Widget vat = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Default VAT / Tax Rate'),
        TextFormField(
          key: const Key('branch-vat-field'),
          controller: _vatController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _inputTextStyle,
          decoration: _inputDecoration(
            suffixText: '%',
            suffixStyle: const TextStyle(
              fontSize: 12,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ),
      ],
    );

    final Widget currency = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Base Currency'),
        TextFormField(
          initialValue: 'BDT (৳)',
          enabled: false,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: AppTheme.tableHeaderText,
          ),
          decoration: _inputDecoration(),
        ),
      ],
    );

    final Widget pos = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Initial POS Terminals'),
        TextFormField(
          key: const Key('branch-pos-field'),
          controller: _posController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _inputTextStyle,
          decoration: _inputDecoration(),
          validator: (String? value) {
            final int count = int.tryParse(value?.trim() ?? '') ?? 0;
            if (count < 1) return 'At least 1 terminal';
            if (count > 10) return 'Maximum 10 terminals';
            return null;
          },
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: .stretch,
        spacing: 16,
        children: [vat, currency, pos],
      );
    }

    return Row(
      crossAxisAlignment: .start,
      spacing: 12,
      children: [
        Expanded(child: vat),
        Expanded(child: currency),
        Expanded(child: pos),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        mainAxisAlignment: .end,
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.tablePrimaryText,
              side: BorderSide(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.2),
                width: 0.8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            key: const Key('branch-submit-button'),
            onPressed: _submit,
            icon: Icon(
              _isEditing ? Icons.check : Icons.add_business_outlined,
              size: 17,
            ),
            label: Text(
              _isEditing
                  ? 'Save Changes'
                  : 'Create Branch & Set Up Initial Menu',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.amber,
              foregroundColor: AppTheme.windowWidgetBackgroundBlack,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final int posCount = int.tryParse(_posController.text.trim()) ?? 1;

    if (_isEditing) {
      widget.controller.updateBranch(
        widget.branch!,
        name: _nameController.text,
        code: _codeController.text,
        address: _addressController.text,
        area: _areaController.text,
        phone: _phoneController.text,
        manager: _manager,
        isCloudKitchen: _isCloudKitchen,
        posTerminals: posCount,
      );
    } else {
      widget.controller.addBranch(
        name: _nameController.text,
        code: _codeController.text,
        address: _addressController.text,
        area: _areaController.text,
        phone: _phoneController.text,
        manager: _manager,
        isCloudKitchen: _isCloudKitchen,
        posTerminals: posCount,
      );
    }

    Navigator.of(context).pop(true);
  }

  Widget _buildDivider() {
    return Container(
      height: 0.7,
      color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    String? counterText,
    String? suffixText,
    TextStyle? suffixStyle,
  }) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppTheme.topbarBackgroundBlack,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppTheme.tableHeaderText),
      counterText: counterText,
      suffixText: suffixText,
      suffixStyle: suffixStyle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      errorStyle: const TextStyle(fontSize: 10, color: AppTheme.dangerRedLight),
      border: _border(AppTheme.lightAmberWhite.withValues(alpha: 0.16)),
      enabledBorder: _border(AppTheme.lightAmberWhite.withValues(alpha: 0.16)),
      disabledBorder: _border(AppTheme.lightAmberWhite.withValues(alpha: 0.1)),
      focusedBorder: _border(AppTheme.amber.withValues(alpha: 0.6)),
      errorBorder: _border(AppTheme.dangerRedLight.withValues(alpha: 0.65)),
      focusedErrorBorder: _border(
        AppTheme.dangerRedLight.withValues(alpha: 0.85),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 0.8),
    );
  }

  TextStyle get _inputTextStyle {
    return const TextStyle(fontSize: 13, color: AppTheme.tablePrimaryText);
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.hint, this.isRequired = false});

  final String label;
  final String? hint;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.tablePrimaryText,
            ),
          ),
        ),
        if (isRequired)
          const Text(
            '*',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.amber,
            ),
          ),
        if (hint != null) ...[
          const Spacer(),
          Flexible(
            child: Text(
              hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 9,
                color: AppTheme.tableHeaderText,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AccentLine extends StatelessWidget {
  const _AccentLine();

  @override
  Widget build(BuildContext context) {
    return Container(height: 3, color: AppTheme.amber);
  }
}
