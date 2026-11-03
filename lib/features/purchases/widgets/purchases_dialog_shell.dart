import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Shared chrome for every Purchases dialog: an amber accent line, a titled
/// header with a close button, a scrollable body and a pinned footer.
///
/// Keeping it in one place means the Register Supplier and New Purchase Order
/// dialogs stay visually identical to the other modals of the app.
class PurchasesDialogShell extends StatelessWidget {
  const PurchasesDialogShell({
    super.key,
    required this.dialogKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.closeKey,
    required this.onClose,
    required this.child,
    required this.footer,
    this.maxWidth = 560,
  });

  final Key dialogKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final Key closeKey;
  final VoidCallback onClose;
  final Widget child;
  final Widget footer;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: dialogKey,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
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
                const PurchasesAccentLine(),
                _buildHeader(),
                const PurchasesDialogDivider(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                    child: child,
                  ),
                ),
                const PurchasesDialogDivider(),
                footer,
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: AppTheme.amber),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 3,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: AppTheme.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: closeKey,
            tooltip: 'Close dialog',
            onPressed: onClose,
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
}

/// Cancel + submit pair pinned to the bottom of a [PurchasesDialogShell].
class PurchasesDialogFooter extends StatelessWidget {
  const PurchasesDialogFooter({
    super.key,
    required this.cancelKey,
    required this.onCancel,
    required this.submitKey,
    required this.onSubmit,
    required this.submitLabel,
    this.submitIcon = Icons.check,
    this.isBusy = false,
  });

  final Key cancelKey;
  final VoidCallback onCancel;
  final Key submitKey;
  final VoidCallback onSubmit;
  final String submitLabel;
  final IconData submitIcon;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
      child: Row(
        mainAxisAlignment: .end,
        spacing: 8,
        children: [
          OutlinedButton(
            key: cancelKey,
            onPressed: isBusy ? null : onCancel,
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
            key: submitKey,
            onPressed: isBusy ? null : onSubmit,
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
            child: isBusy
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.tableHeaderText,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 7,
                    children: [
                      Icon(submitIcon, size: 17),
                      Text(submitLabel),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Small label shown above a form field, with an optional hint on the right.
class PurchasesFieldLabel extends StatelessWidget {
  const PurchasesFieldLabel({
    super.key,
    required this.label,
    this.hint,
    this.isRequired = false,
  });

  final String label;
  final String? hint;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        // shrinks and wraps instead of overflowing a narrow column
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
              letterSpacing: 0.4,
              color: AppTheme.tableHeaderText,
            ),
          ),
      ],
    );
  }
}

/// Thin divider used between the shell sections.
class PurchasesDialogDivider extends StatelessWidget {
  const PurchasesDialogDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.7,
      color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
    );
  }
}

/// Amber line pinned to the very top of the shell.
class PurchasesAccentLine extends StatelessWidget {
  const PurchasesAccentLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 3, color: AppTheme.amber);
  }
}

/// Shared input decoration so every purchases field looks the same.
InputDecoration purchasesInputDecoration({
  String? hint,
  String? prefixText,
  TextStyle? prefixStyle,
  String? counterText,
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
    errorStyle: const TextStyle(fontSize: 10, height: 1.2),
    border: purchasesInputBorder(
      AppTheme.lightAmberWhite.withValues(alpha: 0.16),
    ),
    enabledBorder: purchasesInputBorder(
      AppTheme.lightAmberWhite.withValues(alpha: 0.16),
    ),
    focusedBorder: purchasesInputBorder(AppTheme.amber.withValues(alpha: 0.6)),
    errorBorder: purchasesInputBorder(
      AppTheme.dangerRedLight.withValues(alpha: 0.65),
    ),
    focusedErrorBorder: purchasesInputBorder(
      AppTheme.dangerRedLight.withValues(alpha: 0.85),
    ),
  );
}

OutlineInputBorder purchasesInputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: 0.8),
  );
}

/// Text style shared by every purchases input.
const TextStyle purchasesInputTextStyle = TextStyle(
  fontSize: 13,
  color: AppTheme.tablePrimaryText,
);
