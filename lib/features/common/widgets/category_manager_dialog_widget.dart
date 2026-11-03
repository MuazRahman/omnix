import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Opens the shared category manager used by the Inventory and Menu sections.
///
/// [categories] is the live controller list; its entry named [allLabel] is the
/// fixed "All" filter and is never shown, renamed or deleted. Every change goes
/// through the callbacks so the controller stays the single source of truth.
Future<void> showCategoryManagerDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
  required RxList<String> categories,
  required void Function(String name) onCreate,
  required void Function(String oldName, String newName) onRename,
  required void Function(String name) onDelete,
  int Function(String category)? usageCount,
  ValueChanged<String>? onCreated,
  String allLabel = 'All',
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.78),
    builder: (BuildContext context) {
      return CategoryManagerDialog(
        title: title,
        subtitle: subtitle,
        categories: categories,
        onCreate: onCreate,
        onRename: onRename,
        onDelete: onDelete,
        usageCount: usageCount,
        onCreated: onCreated,
        allLabel: allLabel,
      );
    },
  );
}

/// Alert dialog that lists the editable categories of a section.
///
/// It adds at the top, renames inline and deletes with a confirmation. The
/// dialog renders straight from [categories], so the chips on the screen behind
/// it update as soon as the controller mutates the list.
class CategoryManagerDialog extends StatefulWidget {
  const CategoryManagerDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.categories,
    required this.onCreate,
    required this.onRename,
    required this.onDelete,
    this.usageCount,
    this.onCreated,
    this.allLabel = 'All',
  });

  final String title;
  final String subtitle;
  final RxList<String> categories;
  final void Function(String name) onCreate;
  final void Function(String oldName, String newName) onRename;
  final void Function(String name) onDelete;
  final int Function(String category)? usageCount;
  final ValueChanged<String>? onCreated;
  final String allLabel;

  @override
  State<CategoryManagerDialog> createState() => _CategoryManagerDialogState();
}

class _CategoryManagerDialogState extends State<CategoryManagerDialog> {
  final TextEditingController _addController = TextEditingController();
  final TextEditingController _renameController = TextEditingController();

  String? _editing;
  String? _error;

  @override
  void dispose() {
    _addController.dispose();
    _renameController.dispose();
    super.dispose();
  }

  List<String> get _managedCategories => widget.categories
      .where((String category) => category != widget.allLabel)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('category-manager-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        _buildAddRow(),
                        if (_error != null) _buildError(),
                        Obx(() => _buildList()),
                      ],
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
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
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
            child: const Icon(Icons.tune, size: 19, color: AppTheme.amber),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: AppTheme.white,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('category-manager-close'),
            tooltip: 'Close dialog',
            onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildAddRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Expanded(
          child: TextField(
            key: const Key('category-manager-add-field'),
            controller: _addController,
            textInputAction: TextInputAction.done,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(30),
            ],
            onSubmitted: (_) => _submitAdd(),
            style: _inputTextStyle,
            decoration: _inputDecoration(hint: 'New category name'),
          ),
        ),
        FilledButton(
          key: const Key('category-manager-add-button'),
          onPressed: _submitAdd,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.amber,
            foregroundColor: AppTheme.windowWidgetBackgroundBlack,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [Icon(Icons.add, size: 16), Text('Add')],
          ),
        ),
      ],
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

  Widget _buildList() {
    final List<String> categories = _managedCategories;

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Text(
          'No categories yet. Add one above to organise the catalog.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.tableHeaderText.withValues(alpha: 0.8),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: categories.map(_buildRow).toList(),
    );
  }

  Widget _buildRow(String category) {
    if (_editing == category) return _buildRenameRow(category);

    final int usage = widget.usageCount?.call(category) ?? 0;

    return Container(
      key: Key('category-manager-row-$category'),
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
          width: 0.7,
        ),
      ),
      child: Row(
        spacing: 10,
        children: [
          const Icon(
            Icons.sell_outlined,
            size: 15,
            color: AppTheme.tableHeaderText,
          ),
          Expanded(
            child: Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.tablePrimaryText,
              ),
            ),
          ),
          if (usage > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$usage ${usage == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.badgeAmberText,
                ),
              ),
            ),
          IconButton(
            key: Key('category-manager-edit-$category'),
            tooltip: 'Rename category',
            onPressed: () => _startRename(category),
            icon: const Icon(Icons.edit_outlined, size: 16),
            color: AppTheme.tableHeaderText,
            style: _rowIconButtonStyle,
          ),
          IconButton(
            key: Key('category-manager-delete-$category'),
            tooltip: 'Delete category',
            onPressed: () => _confirmDelete(category, usage),
            icon: const Icon(Icons.delete_outline, size: 16),
            color: AppTheme.dangerRedLight,
            style: _rowIconButtonStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildRenameRow(String category) {
    return Container(
      key: Key('category-manager-row-$category'),
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppTheme.amber.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: TextField(
              key: const Key('category-manager-rename-field'),
              controller: _renameController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(30),
              ],
              onSubmitted: (_) => _submitRename(category),
              style: _inputTextStyle,
              decoration: _inputDecoration(hint: 'Category name'),
            ),
          ),
          IconButton(
            key: const Key('category-manager-rename-save'),
            tooltip: 'Save name',
            onPressed: () => _submitRename(category),
            icon: const Icon(Icons.check, size: 17),
            color: AppTheme.windowWidgetBackgroundBlack,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.amber,
              minimumSize: const Size(32, 32),
              maximumSize: const Size(32, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          IconButton(
            key: const Key('category-manager-rename-cancel'),
            tooltip: 'Cancel rename',
            onPressed: _cancelRename,
            icon: const Icon(Icons.close, size: 17),
            color: AppTheme.tableHeaderText,
            style: _rowIconButtonStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton(
            key: const Key('category-manager-done'),
            onPressed: () => Navigator.of(context).pop(),
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
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _submitAdd() {
    final String name = _addController.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Enter a category name');
      return;
    }
    if (widget.categories.contains(name)) {
      setState(() => _error = 'That category already exists');
      return;
    }

    widget.onCreate(name);
    _addController.clear();
    setState(() => _error = null);
    widget.onCreated?.call(name);
    FocusScope.of(context).unfocus();
  }

  void _startRename(String category) {
    setState(() {
      _editing = category;
      _error = null;
      _renameController.text = category;
    });
    _renameController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: category.length,
    );
  }

  void _cancelRename() {
    setState(() {
      _editing = null;
      _error = null;
    });
  }

  void _submitRename(String oldName) {
    final String name = _renameController.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Enter a category name');
      return;
    }
    if (name != oldName && widget.categories.contains(name)) {
      setState(() => _error = 'That category already exists');
      return;
    }

    widget.onRename(oldName, name);
    setState(() {
      _editing = null;
      _error = null;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _confirmDelete(String category, int usage) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (BuildContext context) {
        return AlertDialog(
          key: const Key('category-manager-confirm-delete'),
          backgroundColor: AppTheme.windowWidgetBackgroundBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Delete "$category"?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.white,
            ),
          ),
          content: Text(
            usage > 0
                ? 'This category is used by $usage '
                      '${usage == 1 ? 'entry' : 'entries'} that will move to '
                      'another category.'
                : 'This category is not used by any entry yet.',
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: AppTheme.tablePrimaryText,
            ),
          ),
          actions: [
            TextButton(
              key: const Key('category-manager-confirm-cancel'),
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.tablePrimaryText,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('category-manager-confirm-delete-button'),
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.dangerRed,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    widget.onDelete(category);
    if (_editing == category) setState(() => _editing = null);
  }

  ButtonStyle get _rowIconButtonStyle => IconButton.styleFrom(
    backgroundColor: AppTheme.sidebarBackgroundBlack,
    minimumSize: const Size(32, 32),
    maximumSize: const Size(32, 32),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppTheme.topbarBackgroundBlack,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppTheme.tableHeaderText),
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      errorStyle: const TextStyle(fontSize: 10, height: 1.2),
      border: _border(AppTheme.lightAmberWhite.withValues(alpha: 0.16)),
      enabledBorder: _border(AppTheme.lightAmberWhite.withValues(alpha: 0.16)),
      focusedBorder: _border(AppTheme.amber.withValues(alpha: 0.6)),
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
