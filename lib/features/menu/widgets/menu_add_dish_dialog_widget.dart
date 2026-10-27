import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter/services.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';

/// Opens the quick-add dialog for a new menu item.
Future<bool?> showMenuAddDishDialog(
  BuildContext context,
  MenuController controller,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.74),
    builder: (BuildContext context) {
      return MenuAddDishDialog(controller: controller);
    },
  );
}

/// Opens the dish form pre-filled with [item], saving the edits on submit.
Future<bool?> showMenuEditDishDialog(
  BuildContext context,
  MenuController controller,
  MenuItem item,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.74),
    builder: (BuildContext context) {
      return MenuAddDishDialog(controller: controller, item: item);
    },
  );
}

/// Compact dish form modelled on the catalog modal.
///
/// Without [item] it adds a new dish; with one it edits that row instead.
class MenuAddDishDialog extends StatefulWidget {
  const MenuAddDishDialog({super.key, required this.controller, this.item});

  final MenuController controller;

  /// Existing row being edited, or `null` when adding a new dish.
  final MenuItem? item;

  @override
  State<MenuAddDishDialog> createState() => _MenuAddDishDialogState();
}

class _MenuAddDishDialogState extends State<MenuAddDishDialog> {
  static const int _maxImageBytes = 5 * 1024 * 1024;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _banglaController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  late String _category;
  late String _kitchenStation;

  Uint8List? _imageBytes;
  String? _imageName;
  String? _imageError;
  bool _isPickingImage = false;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();

    final MenuItem? item = widget.item;

    final List<String> selectableCategories = widget.controller.categories
        .where((String category) => category != 'All')
        .toList();
    _category = item != null && selectableCategories.contains(item.category)
        ? item.category
        : selectableCategories.firstWhere(
            (String category) => category != 'All',
            orElse: () => 'General',
          );

    final String? station = item?.kitchenStation;
    _kitchenStation =
        station != null && MenuController.kitchenStations.contains(station)
        ? station
        : MenuController.kitchenStations.first;

    _isAvailable = item?.isAvailable ?? true;

    if (item != null) {
      _nameController.text = item.name;
      _banglaController.text = item.banglaName;
      _priceController.text = item.price > 0 ? '${item.price}' : '';
      _costController.text = item.recipeCost > 0 ? '${item.recipeCost}' : '';
      _imageBytes = item.imageBytes;
      _imageName = item.imageBytes == null ? null : item.name;
    }
  }

  bool get _isEditing => widget.item != null;

  @override
  void dispose() {
    _nameController.dispose();
    _banglaController.dispose();
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('menu-add-dish-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
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
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                              final bool wide = constraints.maxWidth >= 500;

                              return Column(
                                crossAxisAlignment: .stretch,
                                spacing: 16,
                                children: [
                                  _buildImagePicker(),
                                  _buildNameFields(wide),
                                  _buildSelectFields(wide),
                                  _buildPriceFields(wide),
                                  _buildAvailabilityCard(),
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
      padding: const EdgeInsets.fromLTRB(22, 18, 12, 16),
      child: Row(
        crossAxisAlignment: .start,
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 3,
              children: [
                Text(
                  _isEditing ? 'Edit Menu Item' : 'Add Menu Item',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: AppTheme.white,
                  ),
                ),
                Text(
                  _isEditing
                      ? 'Update this dish and save the changes.'
                      : 'Quickly add a dish to your menu.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('menu-add-dish-close'),
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Dish Photo', hint: 'Optional'),
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('menu-dish-image-picker'),
            onTap: _isPickingImage ? null : _pickImage,
            borderRadius: BorderRadius.circular(10),
            hoverColor: AppTheme.amber.withValues(alpha: 0.05),
            child: Container(
              height: 148,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppTheme.topbarBackgroundBlack,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _imageError == null
                      ? AppTheme.lightAmberWhite.withValues(alpha: 0.18)
                      : AppTheme.dangerRedLight.withValues(alpha: 0.7),
                  width: 0.8,
                ),
              ),
              child: _imageBytes == null
                  ? _buildEmptyImageState()
                  : _buildImagePreview(),
            ),
          ),
        ),
        if (_imageError != null)
          Text(
            _imageError!,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.dangerRedLight,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyImageState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 7,
        children: [
          if (_isPickingImage)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.amber,
              ),
            )
          else
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 22,
                color: AppTheme.amber,
              ),
            ),
          Text(
            _isPickingImage ? 'Opening file picker...' : 'Add dish photo',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.tablePrimaryText,
            ),
          ),
          const Text(
            'PNG or JPG · up to 5 MB',
            style: TextStyle(fontSize: 10, color: AppTheme.tableHeaderText),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(
          _imageBytes!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xB3000000)],
              stops: [0.45, 1],
            ),
          ),
        ),
        Positioned(
          left: 12,
          right: 48,
          bottom: 10,
          child: Row(
            spacing: 6,
            children: [
              const Icon(
                Icons.image_outlined,
                size: 14,
                color: AppTheme.lightAmberWhite,
              ),
              Expanded(
                child: Text(
                  _imageName ?? 'Dish photo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightAmberWhite,
                  ),
                ),
              ),
              const Text(
                'Tap to change',
                style: TextStyle(fontSize: 9, color: AppTheme.tableHeaderText),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            key: const Key('menu-dish-image-remove'),
            tooltip: 'Remove photo',
            onPressed: _isPickingImage
                ? null
                : () {
                    setState(() {
                      _imageBytes = null;
                      _imageName = null;
                      _imageError = null;
                    });
                  },
            icon: const Icon(Icons.close, size: 16),
            color: AppTheme.lightAmberWhite,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.65),
              minimumSize: const Size(30, 30),
              maximumSize: const Size(30, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameFields(bool wide) {
    final Widget name = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Dish Name (English)', isRequired: true),
        TextFormField(
          key: const Key('menu-dish-name-field'),
          controller: _nameController,
          autofocus: true,
          textInputAction: TextInputAction.next,
          maxLength: 60,
          style: _inputTextStyle,
          decoration: _inputDecoration(
            hint: 'e.g. Kacchi Biryani',
            counterText: '',
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter a dish name';
            }
            return null;
          },
        ),
      ],
    );

    final Widget bangla = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Bengali Name', hint: 'Optional'),
        TextFormField(
          key: const Key('menu-dish-bangla-field'),
          controller: _banglaController,
          textInputAction: TextInputAction.next,
          maxLength: 60,
          style: _inputTextStyle,
          decoration: _inputDecoration(
            hint: 'e.g. কাচ্চি বিরিয়ানি',
            counterText: '',
          ),
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: .stretch,
        spacing: 16,
        children: [name, bangla],
      );
    }

    return Row(
      crossAxisAlignment: .start,
      spacing: 12,
      children: [
        Expanded(child: name),
        Expanded(child: bangla),
      ],
    );
  }

  Widget _buildSelectFields(bool wide) {
    final Widget category = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Category'),
        DropdownButtonFormField<String>(
          key: const Key('menu-dish-category-field'),
          initialValue: _category,
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
          items: widget.controller.categories
              .where((String category) => category != 'All')
              .map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              })
              .toList(),
          onChanged: (String? value) {
            if (value != null) setState(() => _category = value);
          },
        ),
      ],
    );

    final Widget station = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Kitchen Station'),
        DropdownButtonFormField<String>(
          key: const Key('menu-dish-station-field'),
          initialValue: _kitchenStation,
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
          items: MenuController.kitchenStations.map((String station) {
            return DropdownMenuItem<String>(
              value: station,
              child: Text(station),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) setState(() => _kitchenStation = value);
          },
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: .stretch,
        spacing: 16,
        children: [category, station],
      );
    }

    return Row(
      crossAxisAlignment: .start,
      spacing: 12,
      children: [
        Expanded(child: category),
        Expanded(child: station),
      ],
    );
  }

  Widget _buildPriceFields(bool wide) {
    final Widget price = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Selling Price', hint: 'BDT (৳)'),
        TextFormField(
          key: const Key('menu-dish-price-field'),
          controller: _priceController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.tablePrimaryText,
          ),
          decoration: _inputDecoration(
            hint: '0',
            prefixText: '৳ ',
            prefixStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.amber,
            ),
          ),
          validator: (String? value) {
            final int price = int.tryParse(value?.trim() ?? '') ?? 0;
            if (price <= 0) return 'Enter a selling price';
            return null;
          },
        ),
      ],
    );

    final Widget cost = Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        const _FieldLabel(label: 'Recipe Cost', hint: 'Optional'),
        TextFormField(
          key: const Key('menu-dish-cost-field'),
          controller: _costController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _inputTextStyle,
          decoration: _inputDecoration(
            hint: 'Auto: 40% of price',
            prefixText: '৳ ',
            prefixStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.tableHeaderText,
            ),
          ),
          onFieldSubmitted: (_) => _submit(),
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: .stretch,
        spacing: 16,
        children: [price, cost],
      );
    }

    return Row(
      crossAxisAlignment: .start,
      spacing: 12,
      children: [
        Expanded(child: price),
        Expanded(child: cost),
      ],
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
          width: 0.7,
        ),
      ),
      child: Row(
        spacing: 12,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 2,
              children: [
                Text(
                  'Available for Sale',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.tablePrimaryText,
                  ),
                ),
                Text(
                  'Show this dish on cashier POS terminals immediately.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.3,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            key: const Key('menu-dish-availability-switch'),
            value: _isAvailable,
            onChanged: (bool value) => setState(() => _isAvailable = value),
            activeThumbColor: AppTheme.amber,
            activeTrackColor: AppTheme.amber.withValues(alpha: 0.4),
            inactiveThumbColor: AppTheme.badgeNeutralText,
            inactiveTrackColor: AppTheme.badgeNeutralBackground,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
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
            key: const Key('menu-dish-submit-button'),
            onPressed: _submit,
            icon: Icon(_isEditing ? Icons.check : Icons.add, size: 17),
            label: Text(_isEditing ? 'Save Changes' : 'Add Dish'),
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

  Widget _buildDivider() {
    return Container(
      height: 0.7,
      color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
    );
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
      _imageError = null;
    });

    try {
      final PlatformFile? file = await FilePicker.pickFile(
        dialogTitle: 'Choose dish photo',
        type: FileType.image,
      );

      if (file == null) return;

      final int? size = file.lengthSync() ?? await file.length();
      if (size != null && size > _maxImageBytes) {
        setState(() => _imageError = 'Choose an image smaller than 5 MB.');
        return;
      }

      final Uint8List bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        setState(
          () => _imageError = 'Could not read that image. Try another file.',
        );
        return;
      }

      if (bytes.length > _maxImageBytes) {
        setState(() => _imageError = 'Choose an image smaller than 5 MB.');
        return;
      }

      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
        _imageError = null;
      });
    } on Exception {
      setState(() => _imageError = 'Could not open the file picker.');
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final int price = int.parse(_priceController.text.trim());
    final String costText = _costController.text.trim();
    final int? recipeCost = costText.isEmpty ? null : int.tryParse(costText);

    final MenuItem? editing = widget.item;
    if (editing == null) {
      widget.controller.addMenuItem(
        name: _nameController.text,
        banglaName: _banglaController.text,
        category: _category,
        kitchenStation: _kitchenStation,
        price: price,
        recipeCost: recipeCost,
        imageBytes: _imageBytes,
        isAvailable: _isAvailable,
      );
    } else {
      widget.controller.updateMenuItem(
        editing,
        name: _nameController.text,
        banglaName: _banglaController.text,
        category: _category,
        kitchenStation: _kitchenStation,
        price: price,
        recipeCost: recipeCost,
        imageBytes: _imageBytes,
        isAvailable: _isAvailable,
      );
    }

    Navigator.of(context).pop(true);
  }

  InputDecoration _inputDecoration({
    String? hint,
    String? counterText,
    String? prefixText,
    TextStyle? prefixStyle,
  }) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppTheme.topbarBackgroundBlack,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppTheme.tableHeaderText),
      prefixText: prefixText,
      prefixStyle: prefixStyle,
      counterText: counterText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      errorStyle: const TextStyle(fontSize: 10, color: AppTheme.dangerRedLight),
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
      spacing: 4,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.tablePrimaryText,
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
          Text(
            hint!,
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.tableHeaderText,
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
