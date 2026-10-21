import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/customers/model/customer_model.dart';
import 'package:omnix/features/customers/widgets/customer_phone_dialog_widget.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/model/pos_customer_model.dart';

/// Customer attached to the open ticket.
class PosCustomerBarWidget extends StatelessWidget {
  const PosCustomerBarWidget({super.key, required this.posController});

  final PosController posController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final PosCustomer? customer = posController.customer.value;
      final bool needsPhone = customer == null;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: needsPhone
              ? AppTheme.amber.withValues(alpha: 0.06)
              : AppTheme.topbarBackgroundBlack,
          border: Border(
            left: BorderSide(
              color: needsPhone ? AppTheme.amber : Colors.transparent,
              width: 2.4,
            ),
            bottom: BorderSide(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
              width: 0.6,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: needsPhone
                    ? AppTheme.amber.withValues(alpha: 0.14)
                    : AppTheme.lightGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                needsPhone
                    ? Icons.phone_outlined
                    : Icons.verified_user_outlined,
                size: 15,
                color: needsPhone ? AppTheme.amber : AppTheme.lightGreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    customer?.displayName ?? 'Customer phone required',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightAmberWhite,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    customer?.phone ?? 'Add a number to print',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: needsPhone
                          ? AppTheme.amber
                          : AppTheme.tableHeaderText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildActionButton(context, customer),
          ],
        ),
      );
    });
  }

  Widget _buildActionButton(BuildContext context, PosCustomer? customer) {
    if (customer == null) {
      return ElevatedButton.icon(
        key: const Key('pos-customer-action-button'),
        onPressed: () => _openCustomerDialog(context),
        icon: const Icon(Icons.add_call, size: 15),
        label: const Text('Add Phone'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.amber,
          foregroundColor: AppTheme.windowWidgetBackgroundBlack,
          elevation: 0,
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 11),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
      );
    }

    return OutlinedButton.icon(
      key: const Key('pos-customer-action-button'),
      onPressed: () => _openCustomerDialog(context),
      icon: const Icon(Icons.swap_horiz_rounded, size: 15),
      label: const Text('Change'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.amber,
        side: BorderSide(
          color: AppTheme.amber.withValues(alpha: 0.35),
          width: 0.7,
        ),
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
    );
  }

  Future<void> _openCustomerDialog(BuildContext context) async {
    final PosCustomer? current = posController.customer.value;
    final Customer? customer = await showDialog<Customer>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (BuildContext context) {
        return CustomerPhoneDialogWidget(
          mode: CustomerDialogMode.attachToTicket,
          initialPhone: current?.phone,
        );
      },
    );

    if (customer == null) return;

    posController.customerOnChanged(
      PosCustomer(id: customer.id, name: customer.name, phone: customer.phone),
    );
  }
}
