import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/model/pos_tender_mode_model.dart';

/// Subtotal, VAT and the net payable total.
class PosOrderTotalsWidget extends StatelessWidget {
  const PosOrderTotalsWidget({super.key, required this.posController});

  final PosController posController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: AppTheme.topbarBackgroundBlack,
          border: Border(
            top: BorderSide(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
              width: 0.6,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TotalRow(
              label: 'Subtotal (${posController.itemCount} items)',
              value: formatTakaSymbol(posController.subtotal),
            ),
            const SizedBox(height: 5),
            _TotalRow(
              label: 'Govt VAT (${_percent(posController.taxPercent)}%)',
              value: '+ ${formatTakaSymbol(posController.tax)}',
            ),
            if (posController.tenderMode.value ==
                PosTenderMode.mobileWallet) ...[
              const SizedBox(height: 5),
              _TotalRow(
                label:
                    'bKash/Nagad cashout '
                    '(${_percent(posController.mobileWalletCashoutPercent.value)}%)',
                value:
                    '+ ${formatTakaSymbol(posController.mobileWalletCashoutCharge)}',
              ),
            ],
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL NET PAYABLE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppTheme.tableHeaderText,
                        ),
                      ),
                      Text(
                        'Rounded off',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppTheme.tableHeaderText,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatTakaSymbol(posController.total),
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: -0.5,
                    color: AppTheme.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _percent(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.tablePrimaryText,
          ),
        ),
      ],
    );
  }
}
