import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Minus / plus control used on every cart line.
class PosQuantityStepperWidget extends StatelessWidget {
  const PosQuantityStepperWidget({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove, onTap: onDecrement),
          SizedBox(
            width: 22,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.tablePrimaryText,
              ),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      hoverColor: AppTheme.amber.withValues(alpha: 0.18),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(icon, size: 13, color: AppTheme.lightAmberWhite),
      ),
    );
  }
}
