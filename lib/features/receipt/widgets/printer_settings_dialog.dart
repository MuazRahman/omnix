import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/receipt/controller/printer_settings_controller.dart';
import 'package:omnix/features/receipt/printer/receipt_printer.dart';
import 'package:printing/printing.dart';

/// Picks the 80mm printer attached to this PC and how the invoice is printed.
class PrinterSettingsDialog extends StatefulWidget {
  const PrinterSettingsDialog({super.key});

  @override
  State<PrinterSettingsDialog> createState() => _PrinterSettingsDialogState();
}

class _PrinterSettingsDialogState extends State<PrinterSettingsDialog> {
  final PrinterSettingsController _settings =
      Get.find<PrinterSettingsController>();

  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _settings.refreshPrinters();
  }

  Future<void> _printTestPage() async {
    setState(() => _isTesting = true);

    final ReceiptPrintResult result = await Get.find<ReceiptPrinter>()
        .printTestPage();

    if (!mounted) return;
    setState(() => _isTesting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Test slip sent to ${result.printerName}.'
              : (result.error ?? 'Printing failed.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AlertDialog(
        backgroundColor: AppTheme.windowWidgetBackgroundBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
            width: 0.8,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        title: const Row(
          spacing: 8,
          children: [
            Icon(Icons.print_outlined, size: 17, color: AppTheme.amber),
            Text(
              'Invoice Printer',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.white,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 430,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '80mm thermal printer attached to this PC. The card terminal '
                'prints its own bank slip; this printer prints the invoice.\n'
                'Set the Windows paper size of that queue to 80mm roll so the '
                'slip is not scaled to A4.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: AppTheme.tableHeaderText,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'PRINTER',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.tableHeaderText,
                      ),
                    ),
                  ),
                  _HeaderAction(
                    label: 'Refresh',
                    icon: Icons.refresh,
                    onTap: _settings.isLoadingPrinters.value
                        ? null
                        : _settings.refreshPrinters,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildPrinterList(),

              if (_settings.lastError.value.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _settings.lastError.value,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.dangerRedLight,
                  ),
                ),
              ],

              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Copies',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightAmberWhite,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Merchant + customer copies',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.tableHeaderText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CopiesStepper(
                    value: _settings.copies.value,
                    onChanged: _settings.setCopies,
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Print automatically',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightAmberWhite,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Send the invoice as soon as the sale is charged',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.tableHeaderText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _settings.autoPrint.value,
                    onChanged: _settings.setAutoPrint,
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected)
                          ? AppTheme.windowWidgetBackgroundBlack
                          : AppTheme.lightAmberWhite;
                    }),
                    trackColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected)
                          ? AppTheme.amber
                          : AppTheme.sidebarBackgroundBlack;
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: _isTesting || _settings.printers.isEmpty
                ? null
                : _printTestPage,
            icon: _isTesting
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.receipt_long_outlined, size: 15),
            label: Text(_isTesting ? 'Sending...' : 'Test print'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.lightAmberWhite,
              disabledForegroundColor: AppTheme.tableHeaderText,
              side: BorderSide(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.18),
                width: 0.6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.amber,
              foregroundColor: AppTheme.windowWidgetBackgroundBlack,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPrinterList() {
    if (_settings.isLoadingPrinters.value) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_settings.printers.isEmpty) {
      return Container(
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.topbarBackgroundBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
            width: 0.6,
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Icon(
              Icons.print_disabled_outlined,
              size: 20,
              color: AppTheme.tableHeaderText,
            ),
            Text(
              'No printer detected on this PC',
              style: TextStyle(fontSize: 11, color: AppTheme.tableHeaderText),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 168),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _settings.printers.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 6),
        itemBuilder: (BuildContext context, int index) {
          final Printer printer = _settings.printers[index];
          final bool isSelected =
              printer.url == _settings.printerUrl.value ||
              (printer.isDefault && _settings.printerUrl.value.isEmpty);

          return _PrinterTile(
            printer: printer,
            isSelected: isSelected,
            onTap: () => _settings.selectPrinter(printer),
          );
        },
      ),
    );
  }
}

class _PrinterTile extends StatelessWidget {
  const _PrinterTile({
    required this.printer,
    required this.isSelected,
    required this.onTap,
  });

  final Printer printer;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppTheme.amber.withValues(alpha: 0.1)
          : AppTheme.topbarBackgroundBlack,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.amber.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppTheme.amber.withValues(alpha: 0.6)
                  : AppTheme.lightAmberWhite.withValues(alpha: 0.12),
              width: isSelected ? 0.9 : 0.6,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 16,
                color: isSelected ? AppTheme.amber : AppTheme.tableHeaderText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  printer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.lightAmberWhite
                        : AppTheme.badgeNeutralText,
                  ),
                ),
              ),
              if (printer.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.sidebarBackgroundBlack,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: AppTheme.tableHeaderText,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CopiesStepper extends StatelessWidget {
  const _CopiesStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 26,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.amber,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: value < 5 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      hoverColor: AppTheme.amber.withValues(alpha: 0.1),
      child: SizedBox(
        width: 28,
        height: 34,
        child: Icon(
          icon,
          size: 14,
          color: onTap == null ? AppTheme.tableHeaderText : AppTheme.amber,
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        hoverColor: AppTheme.amber.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Row(
            spacing: 4,
            children: [
              Icon(
                icon,
                size: 12,
                color: onTap == null
                    ? AppTheme.tableHeaderText
                    : AppTheme.amber,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: onTap == null
                      ? AppTheme.tableHeaderText
                      : AppTheme.amber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
