import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';

/// Ticket number, order context and quick actions.
class PosTicketHeaderWidget extends StatelessWidget {
  const PosTicketHeaderWidget({super.key, required this.posController});

  final PosController posController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          color: AppTheme.sidebarBackgroundBlack,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
              width: 0.6,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Flexible(
                        child: Text(
                          'Ticket #${posController.invoiceNumber.value}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                      const StatusPillWidget(
                        label: 'Active',
                        tone: PillTone.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    posController.isDineIn
                        ? '${posController.orderType.value.label} · '
                              'Table ${posController.tableLabel.value} · '
                              'Server: ${posController.cashierName}'
                        : '${posController.orderType.value.label} · '
                              'Server: ${posController.cashierName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.tableHeaderText,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderIconButton(
              icon: Icons.delete_outline,
              tooltip: 'Clear ticket',
              onTap: posController.clearCart,
            ),
            const SizedBox(width: 4),
            _HeaderIconButton(
              icon: Icons.print_outlined,
              tooltip: 'Print KOT',
              onTap: posController.printKitchenTicket,
            ),
          ],
        ),
      );
    });
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: AppTheme.amber.withValues(alpha: 0.12),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 16, color: AppTheme.tableHeaderText),
          ),
        ),
      ),
    );
  }
}
