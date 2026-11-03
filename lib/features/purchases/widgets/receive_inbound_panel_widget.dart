import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/purchases/controller/purchase_controller.dart';
import 'package:omnix/features/purchases/model/purchase_model.dart';

/// Right-hand dock that verifies an inbound shipment against the dock scale
/// before the stock is committed to the ledger.
class ReceiveInboundPanelWidget extends StatelessWidget {
  const ReceiveInboundPanelWidget({super.key, required this.controller});

  final PurchaseController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Purchase? purchase = controller.selectedPurchase;

      if (purchase == null) {
        return const _EmptyDock();
      }

      // keyed by PO so the scale inputs reset when a different order is picked
      return _ReceiveForm(
        key: ValueKey<String>(purchase.id),
        purchase: purchase,
        hasDraft: controller.inspectionDrafts.containsKey(purchase.id),
        onCommit: () => controller.receivePurchase(purchase),
        onSaveDraft: (List<double> readings) =>
            controller.saveInspectionDraft(purchase, readings),
      );
    });
  }
}

class _EmptyDock extends StatelessWidget {
  const _EmptyDock();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('purchases-receive-panel'),
      height: 220,
      alignment: Alignment.center,
      decoration: _dockDecoration(),
      child: const Text(
        'Select a purchase order to verify its delivery.',
        style: TextStyle(fontSize: 12, color: AppTheme.tableHeaderText),
      ),
    );
  }
}

class _ReceiveForm extends StatefulWidget {
  const _ReceiveForm({
    super.key,
    required this.purchase,
    required this.hasDraft,
    required this.onCommit,
    required this.onSaveDraft,
  });

  final Purchase purchase;
  final bool hasDraft;
  final VoidCallback onCommit;
  final ValueChanged<List<double>> onSaveDraft;

  @override
  State<_ReceiveForm> createState() => _ReceiveFormState();
}

class _ReceiveFormState extends State<_ReceiveForm> {
  late final List<TextEditingController> _scale;

  @override
  void initState() {
    super.initState();
    _scale = widget.purchase.lines
        .map(
          (PurchaseLine line) =>
              TextEditingController(text: formatQuantity(line.quantity)),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _scale) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Purchase purchase = widget.purchase;

    return Container(
      key: const Key('purchases-receive-panel'),
      decoration: _dockDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: .stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _DockHeader(isSettled: !purchase.isOpen),
          const SizedBox(height: 14),
          _PoMetaCard(purchase: purchase),
          const SizedBox(height: 14),
          for (int index = 0; index < purchase.lines.length; index++) ...[
            _CommodityVerifier(
              line: purchase.lines[index],
              controller: _scale[index],
              onChanged: () => setState(() {}),
            ),
            if (index < purchase.lines.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          const _LedgerNotice(),
          const SizedBox(height: 14),
          _CommitButton(
            enabled: purchase.isOpen,
            onPressed: widget.onCommit,
          ),
          const SizedBox(height: 8),
          _DraftButton(onPressed: _saveDraft),
          if (widget.hasDraft) ...[
            const SizedBox(height: 8),
            const _DraftSavedNote(),
          ],
        ],
      ),
    );
  }

  // collects the current dock scale readings and stores them as a draft
  void _saveDraft() {
    final List<PurchaseLine> lines = widget.purchase.lines;
    final List<double> readings = <double>[];

    for (int index = 0; index < lines.length; index++) {
      readings.add(
        double.tryParse(_scale[index].text.trim()) ?? lines[index].quantity,
      );
    }

    widget.onSaveDraft(readings);
  }
}

class _DockHeader extends StatelessWidget {
  const _DockHeader({required this.isSettled});

  final bool isSettled;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.amber,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.scale_outlined,
            size: 19,
            color: AppTheme.windowWidgetBackgroundBlack,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Receive Inbound Stock',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tablePrimaryText,
                ),
              ),
              Text(
                'DOCK SCALE VERIFICATION',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.amber.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        StatusPillWidget(
          label: isSettled ? 'Settled' : 'Calibrated',
          tone: isSettled ? PillTone.green : PillTone.neutral,
          showDot: false,
        ),
      ],
    );
  }
}

class _PoMetaCard extends StatelessWidget {
  const _PoMetaCard({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.badgeNeutralBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                purchase.id,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontFamilyFallback: ['Courier New', 'Menlo'],
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.badgeAmberText,
                ),
              ),
              const Spacer(),
              Text(
                'Gate: ${purchase.gate}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.tableHeaderText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            purchase.supplier,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.tablePrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  purchase.isOpen
                      ? 'Expected: ${purchase.expectedAt ?? '—'}'
                      : 'Received: ${purchase.receivedAt ?? '—'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              Text(
                purchase.receivedBy != null
                    ? 'Inspector: ${purchase.receivedBy}'
                    : 'Inspector: Chief Store',
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.tableHeaderText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommodityVerifier extends StatelessWidget {
  const _CommodityVerifier({
    required this.line,
    required this.controller,
    required this.onChanged,
  });

  final PurchaseLine line;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final double expected = line.quantity;
    final double received = double.tryParse(controller.text.trim()) ?? 0;
    final double variance = received - expected;
    final bool isExact = variance.abs() < 0.001;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.badgeNeutralBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            line.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.tablePrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: _ScaleBox(
                  label: 'PO Expected',
                  child: Text(
                    line.displayQuantity,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.tablePrimaryText,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _ScaleBox(
                  label: 'Dock Scale (${line.unit})',
                  isInput: true,
                  child: TextField(
                    controller: controller,
                    onChanged: (_) => onChanged(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.deepAmberWhite,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _VariancePill(
            variance: variance,
            expected: expected,
            isExact: isExact,
            unit: line.unit,
          ),
        ],
      ),
    );
  }
}

class _ScaleBox extends StatelessWidget {
  const _ScaleBox({
    required this.label,
    required this.child,
    this.isInput = false,
  });

  final String label;
  final Widget child;
  final bool isInput;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isInput
              ? AppTheme.amber.withValues(alpha: 0.4)
              : AppTheme.lightAmberWhite.withValues(alpha: 0.12),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppTheme.tableHeaderText,
            ),
          ),
          const SizedBox(height: 3),
          child,
        ],
      ),
    );
  }
}

class _VariancePill extends StatelessWidget {
  const _VariancePill({
    required this.variance,
    required this.expected,
    required this.isExact,
    required this.unit,
  });

  final double variance;
  final double expected;
  final bool isExact;
  final String unit;

  @override
  Widget build(BuildContext context) {
    if (isExact) {
      return _pill(
        icon: Icons.check_circle_outline,
        color: AppTheme.lightGreen,
        label: 'Exact weight match',
      );
    }

    final double percent = expected == 0 ? 0 : (variance / expected) * 100;
    final bool short = variance < 0;

    return _pill(
      icon: short ? Icons.warning_amber_rounded : Icons.add_circle_outline,
      color: short ? AppTheme.amber : AppTheme.lightGreen,
      label:
          '${short ? '' : '+'}${formatQuantity(variance)} $unit variance '
          '(${percent.toStringAsFixed(1)}%)',
    );
  }

  Widget _pill({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.6),
      ),
      child: Row(
        spacing: 6,
        children: [
          Icon(icon, size: 15, color: color),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerNotice extends StatelessWidget {
  const _LedgerNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.badgeNeutralBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
          width: 0.6,
        ),
      ),
      child: Row(
        crossAxisAlignment: .start,
        spacing: 8,
        children: [
          const Icon(
            Icons.account_tree_outlined,
            size: 16,
            color: AppTheme.deepAmberWhite,
          ),
          Expanded(
            child: Text(
              'Committing updates the raw store balances and posts the '
              'supplier bill to payables.',
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommitButton extends StatelessWidget {
  const _CommitButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppTheme.amber
          : AppTheme.badgeNeutralBackground.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: const Key('purchases-commit-button'),
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.deepAmberWhite,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Icon(
                enabled ? Icons.verified_outlined : Icons.check_circle_outline,
                size: 18,
                color: enabled
                    ? AppTheme.windowWidgetBackgroundBlack
                    : AppTheme.tableHeaderText,
              ),
              Text(
                enabled ? 'Commit to Stock Ledger' : 'Already Received',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: enabled
                      ? AppTheme.windowWidgetBackgroundBlack
                      : AppTheme.tableHeaderText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DraftButton extends StatelessWidget {
  const _DraftButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(38),
        foregroundColor: AppTheme.lightAmberWhite,
        side: BorderSide(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
          width: 0.6,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Save Inspection Draft',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Small confirmation shown once scale readings were kept as a draft.
class _DraftSavedNote extends StatelessWidget {
  const _DraftSavedNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      spacing: 6,
      children: [
        const Icon(Icons.check_circle_outline, size: 14, color: AppTheme.lightGreen),
        Text(
          'Draft saved on this device',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.lightGreen.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

BoxDecoration _dockDecoration() {
  return BoxDecoration(
    color: AppTheme.windowWidgetBackgroundBlack,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
      width: 0.6,
    ),
  );
}
