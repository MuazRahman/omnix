import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/model/cart_item_model.dart';
import 'package:omnix/features/pos/widgets/pos_cart_line_widget.dart';
import 'package:omnix/features/pos/widgets/pos_customer_bar_widget.dart';
import 'package:omnix/features/pos/widgets/pos_order_totals_widget.dart';
import 'package:omnix/features/pos/widgets/pos_panel_widget.dart';
import 'package:omnix/features/pos/widgets/pos_payment_panel_widget.dart';
import 'package:omnix/features/pos/widgets/pos_ticket_header_widget.dart';

/// Persistent live ticket on the right side of the POS screen.
class PosCartPanelWidget extends StatelessWidget {
  const PosCartPanelWidget({
    super.key,
    required this.posController,
    required this.onCompleteSale,
  });

  final PosController posController;
  final VoidCallback onCompleteSale;

  @override
  Widget build(BuildContext context) {
    return PosPanelWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PosTicketHeaderWidget(posController: posController),
          PosCustomerBarWidget(posController: posController),
          Expanded(child: _CartLinesWidget(posController: posController)),
          PosOrderTotalsWidget(posController: posController),
          PosPaymentPanelWidget(
            posController: posController,
            onCompleteSale: onCompleteSale,
          ),
        ],
      ),
    );
  }
}

class _CartLinesWidget extends StatelessWidget {
  const _CartLinesWidget({required this.posController});

  final PosController posController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (posController.cart.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 30,
                color: AppTheme.tableHeaderText.withValues(alpha: 0.55),
              ),
              const Text(
                'Cart is empty',
                style: TextStyle(fontSize: 12, color: AppTheme.tableHeaderText),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        primary: false,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: posController.cart.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 1,
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
          );
        },
        itemBuilder: (BuildContext context, int index) {
          final CartItem line = posController.cart[index];

          return PosCartLineWidget(posController: posController, line: line);
        },
      );
    });
  }
}
