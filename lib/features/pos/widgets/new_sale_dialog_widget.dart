import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/customers/controller/customer_controller.dart';
import 'package:omnix/features/customers/model/customer_model.dart';
import 'package:omnix/features/customers/widgets/customer_phone_dialog_widget.dart';
import 'package:omnix/features/main_layout_shell/controller/main_layout_shell_controller.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/pos/dummy_data/dummy_pos_data.dart';
import 'package:omnix/features/pos/model/pos_customer_model.dart';
import 'package:omnix/features/pos/model/pos_order_type_model.dart';
import 'package:omnix/features/staff/controller/staff_controller.dart';
import 'package:omnix/features/staff/model/staff_model.dart';

/// Selection collected by the new sale modal.
class NewSaleDraft {
  const NewSaleDraft({
    required this.orderType,
    required this.table,
    required this.pax,
    required this.server,
    required this.customer,
  });

  final PosOrderType orderType;

  // empty when the ticket is not served dine-in
  final String table;

  final int pax;
  final String server;
  final PosCustomer? customer;
}

/// Opens the "Start New Order Ticket" modal, applies the selection to the POS
/// ticket and switches the shell to the POS screen.
Future<void> openNewSaleDialog(BuildContext context) async {
  final NewSaleDraft? draft = await showDialog<NewSaleDraft>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder: (BuildContext context) => const NewSaleDialogWidget(),
  );

  if (draft == null) return;

  final PosController posController = Get.find<PosController>();
  posController.startNewSale();
  posController.orderTypeOnChanged(draft.orderType);
  posController.paxOnChanged(draft.pax);
  posController.serverOnChanged(draft.server);

  if (draft.table.isNotEmpty) {
    posController.tableOnChanged(draft.table);
  }

  if (draft.customer != null) {
    posController.customerOnChanged(draft.customer);
  }

  if (Get.isRegistered<MainLayoutShellController>()) {
    Get.find<MainLayoutShellController>().navigateTo(
      MainLayoutShellController.posIndex,
    );
  }
}

/// Quick-start ticket dialog: dining mode, table and customer in one step.
class NewSaleDialogWidget extends StatefulWidget {
  const NewSaleDialogWidget({super.key});

  @override
  State<NewSaleDialogWidget> createState() => _NewSaleDialogWidgetState();
}

class _NewSaleDialogWidgetState extends State<NewSaleDialogWidget> {
  final TextEditingController _customerFieldController =
      TextEditingController();

  PosOrderType _orderType = PosOrderType.dineIn;
  PosFloor _floor = PosFloor.indoor;
  PosFloorTable? _selectedTable;
  int _pax = DummyPosData.defaultPax;
  String _server = DummyPosData.defaultServer;
  String? _customerError;
  bool _isSubmitting = false;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<PosController>()) {
      final PosController posController = Get.find<PosController>();
      final PosFloorTable? current = _tableFor(posController.tableLabel.value);

      _selectedTable = current != null && current.isFree
          ? current
          : _firstFreeTable(PosFloor.indoor);
      _floor = _selectedTable?.floor ?? PosFloor.indoor;
      _pax = posController.paxCount.value
          .clamp(1, _selectedTable?.seats ?? 30)
          .toInt();
      _server = _serverOptions.contains(posController.serverName.value)
          ? posController.serverName.value
          : _serverOptions.first;
    } else {
      _selectedTable = _firstFreeTable(PosFloor.indoor);
      _pax = DummyPosData.defaultPax
          .clamp(1, _selectedTable?.seats ?? 30)
          .toInt();
      _server = _serverOptions.first;
    }
  }

  @override
  void dispose() {
    _customerFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.enter): _handleEnter,
        const SingleActivator(LogicalKeyboardKey.escape): _dismiss,
      },
      child: Focus(
        autofocus: true,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 920,
              maxHeight: screen.height - 48,
            ),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppTheme.windowWidgetBackgroundBlack,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 20,
                        children: [
                          _buildOrderModeSection(),
                          if (_orderType == PosOrderType.dineIn)
                            _buildTableSection(),
                          _buildCustomerSection(),
                        ],
                      ),
                    ),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.amber,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.add_circle_outline,
              size: 20,
              color: AppTheme.windowWidgetBackgroundBlack,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    const Flexible(
                      child: Text(
                        'Start New Order Ticket',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.amber.withValues(alpha: 0.3),
                          width: 0.6,
                        ),
                      ),
                      child: const Text(
                        'SHORTCUT: F2',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppTheme.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Select dining mode and assign a customer or table to begin '
                  'the billing sequence.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('new-sale-close-button'),
            tooltip: 'Close dialog',
            onPressed: _dismiss,
            icon: const Icon(Icons.close, size: 18),
            color: AppTheme.tableHeaderText,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.sidebarBackgroundBlack,
              minimumSize: const Size(32, 32),
              maximumSize: const Size(32, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1 - order mode
  // ---------------------------------------------------------------------------

  Widget _buildOrderModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _buildStepHeader(
          'STEP 1 · ORDER MODE',
          'Select service operational stream',
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final List<Widget> cards = PosOrderType.values.map((
              PosOrderType type,
            ) {
              return _OrderTypeCard(
                type: type,
                selected: type == _orderType,
                onTap: () => _orderTypeOnChanged(type),
              );
            }).toList();

            if (constraints.maxWidth < 640) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: cards,
              );
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: cards
                    .map((Widget card) => Expanded(child: card))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  void _orderTypeOnChanged(PosOrderType type) {
    setState(() {
      _orderType = type;
      if (type == PosOrderType.dineIn && _selectedTable == null) {
        _selectedTable = _firstFreeTable(_floor);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Step 2 - floor plan
  // ---------------------------------------------------------------------------

  Widget _buildTableSection() {
    final List<PosFloorTable> tables = DummyPosData.floorTables
        .where((PosFloorTable table) => table.floor == _floor)
        .toList();
    final int freeCount = tables
        .where((PosFloorTable table) => table.isFree)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            const Widget title = Text(
              'STEP 2 · TABLE & SEATING DETAILS',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
                color: AppTheme.amber,
              ),
            );

            const Widget legend = Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                _LegendDot(color: AppTheme.successGreen, label: 'Free'),
                _LegendDot(color: AppTheme.dangerRedLight, label: 'Occupied'),
                _LegendDot(color: AppTheme.amber, label: 'Selected'),
              ],
            );

            if (constraints.maxWidth < 600) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [title, legend],
              );
            }

            return const Row(children: [title, Spacer(), legend]);
          },
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.topbarBackgroundBlack,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
              width: 0.6,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              _buildFloorBar(freeCount),
              _buildTableGrid(tables),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final Widget pax = _buildPaxCard();
                  final Widget server = _buildServerCard();

                  if (constraints.maxWidth < 560) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [pax, server],
                    );
                  }

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [
                        Expanded(child: pax),
                        Expanded(child: server),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloorBar(int freeCount) {
    final Widget pills = Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: PosFloor.values.map((PosFloor floor) {
          final bool selected = floor == _floor;

          return Material(
            color: selected
                ? AppTheme.sidebarBackgroundBlack
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () => _selectFloor(floor),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                child: Text(
                  floor.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppTheme.amber
                        : AppTheme.badgeNeutralText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    final Widget section = Text(
      'Section: Zone ${_zoneLetter(_floor)} ($freeCount Tables Available)',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.end,
      style: const TextStyle(fontSize: 10.5, color: AppTheme.tableHeaderText),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [pills, section],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: pills),
            const SizedBox(width: 12),
            Flexible(child: section),
          ],
        );
      },
    );
  }

  Widget _buildTableGrid(List<PosFloorTable> tables) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 760
            ? 6
            : (constraints.maxWidth >= 520 ? 4 : 3);
        const double gap = 8;
        final double chipWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: tables.map((PosFloorTable table) {
            return SizedBox(
              width: chipWidth,
              height: 68,
              child: _TableCard(
                table: table,
                selected: table.label == _selectedTable?.label,
                onTap: table.isFree ? () => _selectTable(table) : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPaxCard() {
    final int cap = _selectedTable?.seats ?? 30;

    return _InnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            spacing: 6,
            children: [
              const Icon(
                Icons.groups_outlined,
                size: 15,
                color: AppTheme.amber,
              ),
              const Expanded(
                child: Text(
                  'Guest Count (Pax)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
              ),
              Text(
                'Table Cap: $cap',
                style: const TextStyle(
                  fontSize: 9.5,
                  color: AppTheme.tableHeaderText,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.windowBackgroundBlack.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _PaxButton(
                  icon: Icons.remove,
                  onTap: _pax > 1 ? () => _changePax(-1) : null,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    spacing: 4,
                    children: [
                      Text(
                        '$_pax',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.amber,
                        ),
                      ),
                      const Text(
                        'Guests',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.tableHeaderText,
                        ),
                      ),
                    ],
                  ),
                ),
                _PaxButton(
                  icon: Icons.add,
                  onTap: _pax < cap ? () => _changePax(1) : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard() {
    return _InnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          const Row(
            spacing: 6,
            children: [
              Icon(Icons.badge_outlined, size: 15, color: AppTheme.amber),
              Expanded(
                child: Text(
                  'Assigned Floor Server',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.windowBackgroundBlack.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
                width: 0.6,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                key: const Key('new-sale-server-dropdown'),
                value: _server,
                isExpanded: true,
                isDense: true,
                dropdownColor: AppTheme.sidebarBackgroundBlack,
                borderRadius: BorderRadius.circular(8),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppTheme.tableHeaderText,
                ),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightAmberWhite,
                ),
                items: _serverOptions.map((String name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) setState(() => _server = value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3 - customer
  // ---------------------------------------------------------------------------

  Widget _buildCustomerSection() {
    final Customer? matched = _findCustomer(_customerFieldController.text);

    final Widget field = TextField(
      key: const Key('new-sale-customer-field'),
      controller: _customerFieldController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onChanged: (_) {
        if (_customerError != null) {
          setState(() => _customerError = null);
        } else {
          setState(() {});
        }
      },
      onSubmitted: (_) => _submit(),
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: AppTheme.lightAmberWhite,
      ),
      cursorColor: AppTheme.amber,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppTheme.topbarBackgroundBlack,
        hintText: 'Type phone (017...) or customer name',
        hintStyle: const TextStyle(
          fontSize: 11.5,
          color: AppTheme.tableHeaderText,
        ),
        prefixIcon: const Icon(
          Icons.person_search_outlined,
          size: 18,
          color: AppTheme.tableHeaderText,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(
          color: _customerError == null ? null : AppTheme.dangerRedLight,
        ),
        focusedBorder: _fieldBorder(
          color: _customerError == null
              ? AppTheme.amber
              : AppTheme.dangerRedLight,
        ),
      ),
    );

    final Widget action = OutlinedButton.icon(
      key: const Key('new-sale-new-customer-button'),
      onPressed: _isSubmitting ? null : _openNewCustomer,
      icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
      label: const Text('New VIP Member'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.amber,
        side: BorderSide(
          color: AppTheme.amber.withValues(alpha: 0.35),
          width: 0.7,
        ),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _buildStepHeader(
          'STEP 3 · CUSTOMER ASSIGNMENT',
          'Optional for loyalty points',
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 620) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [field, action],
              );
            }

            return Row(
              spacing: 8,
              children: [
                Expanded(child: field),
                action,
              ],
            );
          },
        ),
        if (matched != null) _buildMatchedCustomer(matched),
        if (_customerError != null)
          Text(
            _customerError!,
            style: const TextStyle(
              fontSize: 10,
              height: 1.35,
              color: AppTheme.dangerRedLight,
            ),
          ),
      ],
    );
  }

  Widget _buildMatchedCustomer(Customer customer) {
    return Container(
      key: const Key('new-sale-matched-customer'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.successGreen.withValues(alpha: 0.25),
          width: 0.7,
        ),
      ),
      child: Row(
        spacing: 8,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 17,
            color: AppTheme.successGreen,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 1,
              children: [
                const Text(
                  'EXISTING CUSTOMER',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppTheme.successGreen,
                  ),
                ),
                Text(
                  '${customer.displayName} · ${customer.phone}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightAmberWhite,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${customer.visits} visits',
            style: const TextStyle(
              fontSize: 9.5,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Footer
  // ---------------------------------------------------------------------------

  Widget _buildFooter() {
    final Widget cancel = TextButton(
      key: const Key('new-sale-cancel-button'),
      onPressed: _isSubmitting ? null : _dismiss,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.lightAmberWhite,
        disabledForegroundColor: AppTheme.tableHeaderText,
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Icon(Icons.close, size: 15),
          Text('Cancel'),
          Text(
            '[Esc]',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ],
      ),
    );

    final Widget status = const Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Icon(Icons.circle, size: 6, color: AppTheme.lightGreen),
        Flexible(
          child: Text(
            'Terminal ready for order generation',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: AppTheme.tableHeaderText),
          ),
        ),
      ],
    );

    final Widget submit = ElevatedButton(
      key: const Key('new-sale-start-button'),
      onPressed: _isSubmitting ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.amber,
        foregroundColor: AppTheme.windowWidgetBackgroundBlack,
        disabledBackgroundColor: AppTheme.amber.withValues(alpha: 0.4),
        disabledForegroundColor: AppTheme.windowWidgetBackgroundBlack,
        elevation: 0,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            if (_isSubmitting)
              const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.windowWidgetBackgroundBlack,
                ),
              )
            else ...[
              const Text('Open POS Terminal & Start Adding Items', maxLines: 1),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.windowWidgetBackgroundBlack.withValues(
                    alpha: 0.16,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'ENTER ↵',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, size: 16),
            ],
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
            width: 0.6,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                submit,
                Row(
                  children: [
                    cancel,
                    if (constraints.maxWidth >= 460) ...[
                      const SizedBox(width: 12),
                      Expanded(child: status),
                    ],
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              cancel,
              const SizedBox(width: 12),
              Expanded(flex: 2, child: status),
              const SizedBox(width: 12),
              Flexible(
                flex: 3,
                child: Align(alignment: Alignment.centerRight, child: submit),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _buildStepHeader(String title, String note) {
    return Row(
      spacing: 10,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
            color: AppTheme.amber,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            note,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _fieldBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: color ?? AppTheme.lightAmberWhite.withValues(alpha: 0.14),
        width: color == null ? 0.6 : 0.9,
      ),
    );
  }

  List<String> get _serverOptions {
    final List<String> names = <String>[DummyPosData.defaultServer];

    if (Get.isRegistered<StaffController>()) {
      for (final Staff member in Get.find<StaffController>().staff) {
        final bool isFloorServer =
            member.isActive &&
            (member.role == StaffRole.waiter ||
                member.role == StaffRole.manager);

        if (isFloorServer && !names.contains(member.name)) {
          names.add(member.name);
        }
      }
    }

    return names;
  }

  PosFloorTable? _firstFreeTable(PosFloor floor) {
    for (final PosFloorTable table in DummyPosData.floorTables) {
      if (table.floor == floor && table.isFree) return table;
    }
    return null;
  }

  PosFloorTable? _tableFor(String label) {
    for (final PosFloorTable table in DummyPosData.floorTables) {
      if (table.selectionLabel == label) return table;
    }
    return null;
  }

  void _selectFloor(PosFloor floor) {
    if (floor == _floor) return;

    setState(() {
      _floor = floor;

      if (_selectedTable?.floor != floor) {
        _selectedTable = _firstFreeTable(floor);
        _pax = _pax.clamp(1, _selectedTable?.seats ?? 30).toInt();
      }
    });
  }

  void _selectTable(PosFloorTable table) {
    if (!table.isFree) return;

    setState(() {
      _selectedTable = table;
      if (_pax > table.seats) _pax = table.seats;
    });
  }

  void _changePax(int delta) {
    final int cap = _selectedTable?.seats ?? 30;
    setState(() => _pax = (_pax + delta).clamp(1, cap).toInt());
  }

  String _zoneLetter(PosFloor floor) {
    switch (floor) {
      case PosFloor.indoor:
        return 'A';
      case PosFloor.rooftop:
        return 'B';
      case PosFloor.family:
        return 'C';
    }
  }

  Customer? _findCustomer(String text) {
    final String value = text.trim();
    if (value.isEmpty || !Get.isRegistered<CustomerController>()) {
      return null;
    }

    final CustomerController controller = Get.find<CustomerController>();
    final String digits = CustomerController.normalizePhone(value);

    if (digits.length >= 6) {
      final Customer? byPhone = controller.findByPhone(digits);
      if (byPhone != null) return byPhone;
    }

    final String needle = value.toLowerCase();
    for (final Customer customer in controller.customers) {
      final String name = (customer.name ?? '').trim().toLowerCase();
      if (name.isNotEmpty && name == needle) return customer;
    }

    return null;
  }

  String? _namePart(String text) {
    final String name = text
        .replaceAll(RegExp(r'[0-9+\-()]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return name.isEmpty ? null : name;
  }

  Future<void> _openNewCustomer() async {
    final Customer? customer = await showDialog<Customer>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (BuildContext context) =>
          const CustomerPhoneDialogWidget(mode: CustomerDialogMode.addCustomer),
    );

    if (!mounted || customer == null) return;

    setState(() {
      _customerFieldController.text = customer.phone;
      _customerFieldController.selection = TextSelection.collapsed(
        offset: customer.phone.length,
      );
      _customerError = null;
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting || _isClosing) return;

    final String text = _customerFieldController.text.trim();
    Customer? customer;

    if (text.isNotEmpty) {
      setState(() => _isSubmitting = true);

      final String digits = CustomerController.normalizePhone(text);

      if (digits.length >= 6) {
        final CustomerController controller = Get.find<CustomerController>();
        customer =
            controller.findByPhone(digits) ??
            await controller.addCustomer(phone: text, name: _namePart(text));
      } else {
        customer = _findCustomer(text);
      }

      if (!mounted) return;

      if (customer == null) {
        setState(() {
          _isSubmitting = false;
          _customerError =
              'Enter a phone number (at least 6 digits) or leave the field '
              'blank for a walk-in guest.';
        });
        return;
      }
    }

    if (!mounted) return;

    final PosFloorTable? table = _selectedTable;

    _isClosing = true;
    Navigator.of(context).pop(
      NewSaleDraft(
        orderType: _orderType,
        table: _orderType == PosOrderType.dineIn && table != null
            ? table.selectionLabel
            : '',
        pax: _pax,
        server: _server,
        customer: customer == null
            ? null
            : PosCustomer(
                id: customer.id,
                name: customer.name,
                phone: customer.phone,
              ),
      ),
    );
  }

  void _dismiss() {
    if (_isSubmitting || _isClosing) return;
    _isClosing = true;
    Navigator.of(context).pop();
  }

  void _handleEnter() {
    if (_isTyping) return;
    _submit();
  }

  bool get _isTyping {
    final BuildContext? focusContext =
        FocusManager.instance.primaryFocus?.context;

    return focusContext != null &&
        focusContext.findAncestorWidgetOfExactType<EditableText>() != null;
  }
}

// -----------------------------------------------------------------------------
// Small presentational widgets
// -----------------------------------------------------------------------------

class _OrderTypeCard extends StatelessWidget {
  const _OrderTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final PosOrderType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = selected
        ? AppTheme.amber.withValues(alpha: 0.55)
        : AppTheme.lightAmberWhite.withValues(alpha: 0.12);

    return Material(
      color: selected
          ? AppTheme.amber.withValues(alpha: 0.1)
          : AppTheme.topbarBackgroundBlack,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: AppTheme.amber.withValues(alpha: 0.06),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: selected ? 0.9 : 0.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.amber
                          : AppTheme.sidebarBackgroundBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _iconFor(type),
                      size: 20,
                      color: selected
                          ? AppTheme.windowWidgetBackgroundBlack
                          : AppTheme.badgeNeutralText,
                    ),
                  ),
                  if (selected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 3,
                        children: [
                          Icon(
                            Icons.check,
                            size: 10,
                            color: AppTheme.windowWidgetBackgroundBlack,
                          ),
                          Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: AppTheme.windowWidgetBackgroundBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 1,
                children: [
                  Text(
                    _titleFor(type),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppTheme.white
                          : AppTheme.lightAmberWhite,
                    ),
                  ),
                  Text(
                    _subtitleFor(type),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.35,
                      color: AppTheme.tableHeaderText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(PosOrderType type) {
    switch (type) {
      case PosOrderType.dineIn:
        return Icons.restaurant;
      case PosOrderType.takeaway:
        return Icons.shopping_bag_outlined;
      case PosOrderType.delivery:
        return Icons.delivery_dining;
    }
  }

  String _titleFor(PosOrderType type) {
    switch (type) {
      case PosOrderType.dineIn:
        return 'Dine-In';
      case PosOrderType.takeaway:
        return 'Takeaway / Counter';
      case PosOrderType.delivery:
        return 'Direct Delivery';
    }
  }

  String _subtitleFor(PosOrderType type) {
    switch (type) {
      case PosOrderType.dineIn:
        return 'Assign floor table & guest count';
      case PosOrderType.takeaway:
        return 'Direct pickup without table assignment';
      case PosOrderType.delivery:
        return 'Assign dispatch rider or street address';
    }
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.table,
    required this.selected,
    required this.onTap,
  });

  final PosFloorTable table;
  final bool selected;

  // null for tables that cannot be picked right now
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    switch (table.status) {
      case PosTableStatus.free:
        statusColor = AppTheme.successGreen;
      case PosTableStatus.occupied:
        statusColor = AppTheme.dangerRedLight;
      case PosTableStatus.reserved:
        statusColor = AppTheme.badgeAmberText;
    }

    final Widget card = Material(
      color: selected
          ? AppTheme.amber
          : AppTheme.sidebarBackgroundBlack.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.amber.withValues(alpha: 0.08),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? AppTheme.amber
                  : AppTheme.lightAmberWhite.withValues(alpha: 0.12),
              width: selected ? 0.9 : 0.6,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 1,
            children: [
              Text(
                table.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppTheme.windowWidgetBackgroundBlack
                      : AppTheme.lightAmberWhite,
                ),
              ),
              Text(
                selected ? 'ACTIVE' : _statusLabel(table.status),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: selected
                      ? AppTheme.windowWidgetBackgroundBlack
                      : statusColor,
                ),
              ),
              Text(
                table.detail ?? '${table.seats} Seats',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: selected
                      ? AppTheme.windowWidgetBackgroundBlack.withValues(
                          alpha: 0.7,
                        )
                      : AppTheme.tableHeaderText,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap != null) return card;

    return Opacity(opacity: 0.45, child: card);
  }

  String _statusLabel(PosTableStatus status) {
    switch (status) {
      case PosTableStatus.free:
        return 'FREE';
      case PosTableStatus.occupied:
        return 'OCCUPIED';
      case PosTableStatus.reserved:
        return 'RESERVED';
    }
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            color: AppTheme.tableHeaderText,
          ),
        ),
      ],
    );
  }
}

class _PaxButton extends StatelessWidget {
  const _PaxButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: AppTheme.sidebarBackgroundBlack,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: AppTheme.amber.withValues(alpha: 0.12),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              size: 18,
              color: enabled
                  ? AppTheme.lightAmberWhite
                  : AppTheme.tableHeaderText,
            ),
          ),
        ),
      ),
    );
  }
}

class _InnerCard extends StatelessWidget {
  const _InnerCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
          width: 0.6,
        ),
      ),
      child: child,
    );
  }
}
