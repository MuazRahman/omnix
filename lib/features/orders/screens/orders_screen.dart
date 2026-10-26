import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/orders/controller/order_controller.dart';
import 'package:omnix/features/orders/widgets/order_detail_panel_widget.dart';
import 'package:omnix/features/orders/widgets/order_list_panel_widget.dart';
import 'package:omnix/features/orders/widgets/orders_filter_bar_widget.dart';
import 'package:omnix/features/orders/widgets/orders_header_widget.dart';
import 'package:omnix/features/orders/widgets/orders_summary_widget.dart';
import 'package:omnix/features/receipt/widgets/printer_settings_dialog.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderController _orderController = Get.find<OrderController>();
  final BranchController _branchController = Get.find<BranchController>();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // width of the inspector when the window can afford a side panel
  static const double _detailWidth = 400;
  static const double _sidePanelBreakpoint = 940;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.f5): _refresh,
        const SingleActivator(LogicalKeyboardKey.keyP, control: true):
            _printSelected,
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _focusSearch,
        const SingleActivator(LogicalKeyboardKey.escape): _clearSelection,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppTheme.topbarBackgroundBlack,
          body: Column(
            children: [
              // Global app bar
              TopBarWidget(branchController: _branchController),

              // Order ledger workspace
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final bool showSidePanel =
                              constraints.maxWidth >= _sidePanelBreakpoint;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OrdersHeaderWidget(
                                orderController: _orderController,
                                onRefresh: _refresh,
                                onExport: _export,
                                onPrinterSettings: _openPrinterSettings,
                              ),
                              const SizedBox(height: 12),
                              OrdersSummaryWidget(
                                orderController: _orderController,
                              ),
                              const SizedBox(height: 12),
                              OrdersFilterBarWidget(
                                orderController: _orderController,
                                searchController: _searchController,
                                searchFocusNode: _searchFocusNode,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: showSidePanel
                                    ? _buildSplitView()
                                    : _buildListView(),
                              ),
                            ],
                          );
                        },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Expanded(
          child: OrderListPanelWidget(
            orderController: _orderController,
            onOrderTap: (order) => _orderController.selectOrder(order.id),
          ),
        ),
        SizedBox(
          width: _detailWidth,
          child: OrderDetailPanelWidget(
            orderController: _orderController,
            onPrinterSettings: _openPrinterSettings,
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return OrderListPanelWidget(
      orderController: _orderController,
      onOrderTap: (order) {
        _orderController.selectOrder(order.id);
        _openDetailDialog(order.id);
      },
    );
  }

  void _openDetailDialog(String orderId) {
    _orderController.selectOrder(orderId);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.76),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 470,
              maxHeight: MediaQuery.sizeOf(dialogContext).height - 56,
            ),
            child: OrderDetailPanelWidget(
              orderController: _orderController,
              onClose: () => Navigator.of(dialogContext).pop(),
              onPrinterSettings: _openPrinterSettings,
            ),
          ),
        );
      },
    );
  }

  void _refresh() {
    _orderController.fetchOrders();
  }

  void _export() {
    _orderController.exportShiftLedger();
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();
  }

  void _printSelected() {
    final order = _orderController.selectedOrder;
    if (order == null) return;

    _orderController.printReceipt(order);
  }

  void _clearSelection() {
    if (Navigator.of(context).canPop()) return;
    _orderController.selectedOrderId.value = null;
  }

  void _openPrinterSettings() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.82),
      builder: (BuildContext context) => const PrinterSettingsDialog(),
    );
  }
}
