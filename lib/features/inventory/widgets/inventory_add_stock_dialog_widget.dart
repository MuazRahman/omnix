import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/common/widgets/category_manager_dialog_widget.dart';
import 'package:omnix/features/inventory/controller/inventory_controller.dart';

/// Opens the Add Stock dialog and resolves to `true` once an item was saved
/// and the controller re-fetched the list behind it.
Future<bool?> showAddStockDialog(
  BuildContext context,
  InventoryController controller,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.78),
    builder: (BuildContext context) {
      return InventoryAddStockDialog(controller: controller);
    },
  );
}

/// Alert dialog used by the Inventory screen's "Add Stock" button.
///
/// Collects the item name, category, unit, quantity, purchase cost and the
/// reorder level, hands them to [InventoryController.addStockItem] and lets
/// the controller re-fetch the list so the screen shows the saved row.
class InventoryAddStockDialog extends StatefulWidget {
  const InventoryAddStockDialog({super.key, required this.controller});

  final InventoryController controller;

  @override
  State<InventoryAddStockDialog> createState() =>
      _InventoryAddStockDialogState();
}

class _InventoryAddStockDialogState extends State<InventoryAddStockDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _reorderController = TextEditingController();

  late String _category;
  late String _unit;

  bool _isSaving = false;

  // categories the dialog can file the item under, read live from the
  // controller so the manager's changes show up without reopening the dialog
  List<String> get _selectableCategories =>
      widget.controller.selectableCategories;

  @override
  void initState() {
    super.initState();

    final List<String> selectableCategories = _selectableCategories;

    // Default to the category the screen is already filtered by (or the
    // first one) so the saved row is visible in the table right away.
    final String activeCategory =
        widget.controller.categories[widget.controller.selectedCategory.value];
    _category = activeCategory != 'All' &&
            selectableCategories.contains(activeCategory)
        ? activeCategory
        : selectableCategories.isNotEmpty
        ? selectableCategories.first
        : 'General';

    _unit = InventoryController.units.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _reorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('inventory-add-stock-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 540,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AccentLine(),
                _buildHeader(),
                const _Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                    child: Form(
                      key: _formKey,
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                              final bool wide = constraints.maxWidth >= 440;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                spacing: 15,
                                children: [
                                  _buildNameField(),
                                  _buildCategoryField(),
                                  _buildUnitAndQuantityFields(wide),
                                  _buildCostAndReorderFields(wide),
                                ],
                              );
                            },
                      ),
                    ),
                  ),
                ),
                const _Divider(),
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
      padding: const EdgeInsets.fromLTRB(22, 18, 12, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 19,
              color: AppTheme.amber,
            ),
          ),
          const SizedBox(width: 2),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  'Add Stock Item',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: AppTheme.white,
                  ),
                ),
                Text(
                  'Add an inventory item to track stock levels.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('inventory-stock-close-button'),
            tooltip: 'Close dialog',
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
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

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Item Name', isRequired: true),
        TextFormField(
          key: const Key('inventory-stock-name-field'),
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 60,
          style: _inputTextStyle,
          decoration: _inputDecoration(
            hint: 'e.g. Beef (Boneless) / গরুর মাংস',
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter an item name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 7,
      children: [
        Row(
          children: [
            const Expanded(
              child: _FieldLabel(label: 'Category', isRequired: true),
            ),
            TextButton.icon(
              key: const Key('inventory-stock-manage-categories'),
              onPressed: _isSaving ? null : _manageCategories,
              icon: const Icon(Icons.tune, size: 14),
              label: const Text('Manage'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.amber,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        Obx(() {
          final List<String> categories = _selectableCategories;

          // the manager may have removed the selected category underneath us
          if (!categories.contains(_category) && categories.isNotEmpty) {
            _category = categories.first;
          }

          return Wrap(
            key: const Key('inventory-stock-category-field'),
            spacing: 8,
            runSpacing: 8,
            children: categories.map((String category) {
              final bool isSelected = category == _category;

              return InkWell(
                key: Key('inventory-stock-category-$category'),
                onTap: _isSaving
                    ? null
                    : () => setState(() => _category = category),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.amber
                        : AppTheme.topbarBackgroundBlack,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.amber
                          : AppTheme.lightAmberWhite.withValues(alpha: 0.16),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.windowWidgetBackgroundBlack
                          : AppTheme.tablePrimaryText,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // Opens the shared category manager and selects anything created from it.
  Future<void> _manageCategories() async {
    FocusScope.of(context).unfocus();

    await showCategoryManagerDialog(
      context: context,
      title: 'Inventory Categories',
      subtitle: 'Add, rename or remove the categories used to file stock.',
      categories: widget.controller.categories,
      usageCount: widget.controller.categoryUsageCount,
      onCreate: widget.controller.addCategory,
      onRename: widget.controller.renameCategory,
      onDelete: widget.controller.removeCategory,
      onCreated: (String name) {
        if (mounted) setState(() => _category = name);
      },
    );
  }

  Widget _buildUnitAndQuantityFields(bool wide) {
    final Widget unit = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Unit of Measurement'),
        DropdownButtonFormField<String>(
          key: const Key('inventory-stock-unit-field'),
          initialValue: _unit,
          isExpanded: true,
          dropdownColor: AppTheme.sidebarBackgroundBlack,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppTheme.tableHeaderText,
          ),
          style: _inputTextStyle,
          decoration: _inputDecoration(),
          items: InventoryController.units.map((String unit) {
            return DropdownMenuItem<String>(
              value: unit,
              child: Text(unit),
            );
          }).toList(),
          onChanged: _isSaving
              ? null
              : (String? value) {
                  if (value != null) setState(() => _unit = value);
                },
        ),
      ],
    );

    final Widget quantity = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Current Stock Quantity', isRequired: true),
        TextFormField(
          key: const Key('inventory-stock-quantity-field'),
          controller: _quantityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          style: _inputTextStyle,
          decoration: _inputDecoration(hint: 'e.g. 25 or 12.5'),
          validator: (String? value) => _validateNumber(
            value,
            emptyMessage: 'Enter the current quantity',
            invalidMessage: 'Enter a valid quantity',
          ),
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 15,
        children: [unit, quantity],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [Expanded(child: unit), Expanded(child: quantity)],
    );
  }

  Widget _buildCostAndReorderFields(bool wide) {
    final Widget cost = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Purchase Cost per Unit (BDT)', isRequired: true),
        TextFormField(
          key: const Key('inventory-stock-cost-field'),
          controller: _costController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          style: _inputTextStyle,
          decoration: _inputDecoration(hint: 'e.g. 780', prefixText: '৳ '),
          validator: (String? value) {
            final String? error = _validateNumber(
              value,
              emptyMessage: 'Enter the purchase cost',
              invalidMessage: 'Enter a valid amount',
            );
            if (error != null) return error;

            if (double.parse(value!.trim()) <= 0) {
              return 'Cost must be greater than 0';
            }
            return null;
          },
        ),
      ],
    );

    final Widget reorder = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        const _FieldLabel(
          label: 'Notify When Stock Falls Below',
          hint: 'OPTIONAL',
        ),
        TextFormField(
          key: const Key('inventory-stock-reorder-field'),
          controller: _reorderController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          style: _inputTextStyle,
          decoration: _inputDecoration(hint: 'e.g. 10'),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) return null;
            return _validateNumber(
              value,
              emptyMessage: '',
              invalidMessage: 'Enter a valid level',
            );
          },
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 15,
        children: [cost, reorder],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [Expanded(child: cost), Expanded(child: reorder)],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 8,
        children: [
          OutlinedButton(
            key: const Key('inventory-stock-cancel-button'),
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.tablePrimaryText,
              disabledForegroundColor: AppTheme.tableHeaderText,
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
          FilledButton(
            key: const Key('inventory-stock-submit-button'),
            onPressed: _isSaving ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.amber,
              foregroundColor: AppTheme.windowWidgetBackgroundBlack,
              disabledBackgroundColor: AppTheme.sidebarBackgroundBlack,
              disabledForegroundColor: AppTheme.tableHeaderText,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.tableHeaderText,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 7,
                    children: [
                      Icon(Icons.add, size: 17),
                      Text('Save Item'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      await widget.controller.addStockItem(
        name: _nameController.text.trim(),
        category: _category,
        quantity: double.parse(_quantityController.text.trim()),
        unit: _unit,
        unitCost: double.parse(_costController.text.trim()),
        reorderLevel: _reorderController.text.trim().isEmpty
            ? 0
            : double.parse(_reorderController.text.trim()),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the stock item. Please try again.'),
        ),
      );
    }
  }

  // Shared number validation: an empty [emptyMessage] lets the field be left
  // blank, anything else falls back to [invalidMessage].
  String? _validateNumber(
    String? value, {
    required String emptyMessage,
    required String invalidMessage,
  }) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) return emptyMessage.isEmpty ? null : emptyMessage;
    if (double.tryParse(text) == null) return invalidMessage;
    return null;
  }

  InputDecoration _inputDecoration({String? hint, String? prefixText}) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppTheme.topbarBackgroundBlack,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppTheme.tableHeaderText),
      prefixText: prefixText,
      prefixStyle: prefixText == null
          ? null
          : const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.amber,
            ),
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      errorStyle: const TextStyle(fontSize: 10, height: 1.2),
      border: _border(AppTheme.lightAmberWhite.withValues(alpha: 0.16)),
      enabledBorder: _border(AppTheme.lightAmberWhite.withValues(alpha: 0.16)),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 6,
      children: [
        // Shrinks and wraps instead of overflowing narrow columns.
        Flexible(
          child: Text.rich(
            TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.tablePrimaryText,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.amber,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hint != null)
          Text(
            hint!,
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 0.6,
              color: AppTheme.tableHeaderText,
            ),
          ),
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.7,
      color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
    );
  }
}
