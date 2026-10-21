import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/widgets/pos_cart_panel_widget.dart';
import 'package:omnix/features/pos/widgets/pos_category_bar_widget.dart';
import 'package:omnix/features/pos/widgets/pos_menu_grid_widget.dart';
import 'package:omnix/features/pos/widgets/pos_operational_bar_widget.dart';
import 'package:omnix/features/pos/widgets/pos_receipt_dialog_widget.dart';
import 'package:omnix/features/pos/widgets/pos_search_bar_widget.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final PosController _posController = Get.find<PosController>();
  final BranchController _branchController = Get.find<BranchController>();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

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
        SingleActivator(LogicalKeyboardKey.keyS, alt: true): _focusSearch,
        const SingleActivator(LogicalKeyboardKey.f2): _startNewSale,
        const SingleActivator(LogicalKeyboardKey.enter): _handleEnter,
        const SingleActivator(LogicalKeyboardKey.escape): _handleEscape,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppTheme.topbarBackgroundBlack,
          body: Column(
            children: [
              // Appbar Header
              TopBarWidget(branchController: _branchController),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          // keep the cart usable when the window gets narrower
                          final double cartWidth = constraints.maxWidth < 1000
                              ? 340
                              : 400;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 16,
                            children: [
                              Expanded(child: _buildCatalog()),
                              SizedBox(
                                width: cartWidth,
                                child: PosCartPanelWidget(
                                  posController: _posController,
                                  onCompleteSale: _openReceipt,
                                ),
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

  Widget _buildCatalog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PosOperationalBarWidget(posController: _posController),
        const SizedBox(height: 10),
        PosSearchBarWidget(
          posController: _posController,
          textController: _searchController,
          focusNode: _searchFocusNode,
          onScan: _focusSearch,
        ),
        const SizedBox(height: 10),
        PosCategoryBarWidget(posController: _posController),
        const SizedBox(height: 10),
        Expanded(child: PosMenuGridWidget(posController: _posController)),
      ],
    );
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();
  }

  void _openReceipt() {
    if (_posController.cart.isEmpty) return;

    if (!_posController.hasCustomerPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a customer phone number before printing.'),
        ),
      );
      return;
    }

    _posController.prepareCheckout();

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.82),
      builder: (BuildContext context) {
        return PosReceiptDialogWidget(posController: _posController);
      },
    );
  }

  void _startNewSale() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    _posController.startNewSale();
  }

  // Enter charges the ticket, unless a dialog is open or the cashier is typing
  void _handleEnter() {
    if (Navigator.of(context).canPop()) return;
    if (_isTyping) return;

    _openReceipt();
  }

  void _handleEscape() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  bool get _isTyping {
    final BuildContext? focusContext =
        FocusManager.instance.primaryFocus?.context;

    return focusContext != null &&
        focusContext.findAncestorWidgetOfExactType<EditableText>() != null;
  }
}
