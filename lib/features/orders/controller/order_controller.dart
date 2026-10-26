import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/orders/dummy_data/dummy_order_data.dart';
import 'package:omnix/features/orders/model/order_model.dart';
import 'package:omnix/features/orders/printer/kitchen_ticket_pdf_builder.dart';
import 'package:omnix/features/pos/dummy_data/dummy_pos_data.dart';
import 'package:omnix/features/receipt/controller/printer_settings_controller.dart';
import 'package:omnix/features/receipt/model/receipt_document.dart';
import 'package:omnix/features/receipt/printer/receipt_printer.dart';
import 'package:omnix/features/receipt/utils/receipt_link.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Status tabs above the order list.
enum OrderFilter {
  all('All'),
  live('Live'),
  ready('Ready'),
  completed('Completed'),
  cancelled('Cancelled');

  const OrderFilter(this.label);

  final String label;

  bool matches(OrderStatus status) {
    switch (this) {
      case OrderFilter.all:
        return true;
      case OrderFilter.live:
        return status.isLive;
      case OrderFilter.ready:
        return status == OrderStatus.ready;
      case OrderFilter.completed:
        return status == OrderStatus.completed;
      case OrderFilter.cancelled:
        return status == OrderStatus.cancelled;
    }
  }
}

class OrderController extends GetxController {
  /// Demo manager pin used by the void / refund dialog.
  static const String managerPin = '1234';

  final orders = <Order>[].obs;

  final isLoading = false.obs;

  final searchText = ''.obs;

  final selectedFilter = OrderFilter.all.obs;

  final selectedChannel = Rxn<OrderChannel>();

  final selectedPaymentStatus = Rxn<PaymentStatus>();

  final selectedOrderId = RxnString();

  /// Ticks every 30 seconds so elapsed labels and rush counters stay current.
  final now = DateTime.now().obs;

  final lastSyncAt = Rxn<DateTime>();

  /// Order currently being sent to the invoice printer.
  final printingOrderId = RxnString();

  /// Order currently being sent to the kitchen printer.
  final kotPrintingOrderId = RxnString();

  Timer? _clock;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      now.value = DateTime.now();
    });
  }

  @override
  void onClose() {
    _clock?.cancel();
    super.onClose();
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchOrders() async {
    if (isLoading.value) return;

    isLoading.value = true;

    // A short delay keeps the refresh button honest without blocking the UI.
    await Future<void>.delayed(const Duration(milliseconds: 280));

    final String? previousSelection = selectedOrderId.value;
    final DateTime fetchedAt = DateTime.now();

    orders.assignAll(DummyOrderData.orders(now: fetchedAt));
    now.value = fetchedAt;
    lastSyncAt.value = fetchedAt;
    isLoading.value = false;

    if (previousSelection != null &&
        orders.any((Order order) => order.id == previousSelection)) {
      selectedOrderId.value = previousSelection;
      return;
    }

    _selectFirstVisible();
  }

  // ---------------------------------------------------------------- filtering

  void filterOnChanged(OrderFilter filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    _selectFirstVisible();
  }

  void searchOnChanged(String value) {
    searchText.value = value;
    _selectFirstVisible();
  }

  void channelOnChanged(OrderChannel? channel) {
    selectedChannel.value = channel;
    _selectFirstVisible();
  }

  void paymentStatusOnChanged(PaymentStatus? status) {
    selectedPaymentStatus.value = status;
    _selectFirstVisible();
  }

  void clearFilters() {
    searchText.value = '';
    selectedFilter.value = OrderFilter.all;
    selectedChannel.value = null;
    selectedPaymentStatus.value = null;
    _selectFirstVisible();
  }

  bool get hasActiveFilters =>
      searchText.value.trim().isNotEmpty ||
      selectedFilter.value != OrderFilter.all ||
      selectedChannel.value != null ||
      selectedPaymentStatus.value != null;

  List<Order> get filteredOrders {
    final String query = searchText.value.trim().toLowerCase();
    final OrderFilter filter = selectedFilter.value;
    final OrderChannel? channel = selectedChannel.value;
    final PaymentStatus? payment = selectedPaymentStatus.value;

    final List<Order> result = orders.where((Order order) {
      final bool matchesFilter = filter.matches(order.status);
      final bool matchesChannel =
          channel == null || order.channel == channel;
      final bool matchesPayment =
          payment == null || order.paymentStatus == payment;
      final bool matchesSearch = query.isEmpty || _matchesSearch(order, query);

      return matchesFilter &&
          matchesChannel &&
          matchesPayment &&
          matchesSearch;
    }).toList();

    result.sort(
      (Order a, Order b) => b.placedAt.compareTo(a.placedAt),
    );

    return result;
  }

  bool _matchesSearch(Order order, String query) {
    if (order.id.toLowerCase().contains(query)) return true;
    if (order.customerName.toLowerCase().contains(query)) return true;
    if (order.customerPhone?.toLowerCase().contains(query) ?? false) {
      return true;
    }
    if (order.tableLabel?.toLowerCase().contains(query) ?? false) return true;
    if (order.riderCode?.toLowerCase().contains(query) ?? false) return true;

    return order.lines.any(
      (OrderLine line) => line.name.toLowerCase().contains(query),
    );
  }

  void _selectFirstVisible() {
    final List<Order> visible = filteredOrders;

    if (visible.isEmpty) {
      selectedOrderId.value = null;
      return;
    }

    if (visible.any((Order order) => order.id == selectedOrderId.value)) {
      return;
    }

    selectedOrderId.value = visible.first.id;
  }

  // --------------------------------------------------------------- selection

  void selectOrder(String id) {
    selectedOrderId.value = id;
  }

  Order? get selectedOrder {
    final String? id = selectedOrderId.value;
    if (id == null) return null;

    for (final Order order in orders) {
      if (order.id == id) return order;
    }

    return null;
  }

  // ----------------------------------------------------------------- metrics

  int countForFilter(OrderFilter filter) {
    return orders.where((Order order) => filter.matches(order.status)).length;
  }

  int get totalOrders => orders.length;

  int get liveKitchenCount {
    return orders.where((Order order) {
      return order.status == OrderStatus.pending ||
          order.status == OrderStatus.preparing;
    }).length;
  }

  int get rushCount {
    return orders.where((Order order) => order.isRush(now.value)).length;
  }

  int get unpaidCount {
    return orders.where((Order order) {
      return order.paymentStatus == PaymentStatus.unpaid;
    }).length;
  }

  /// Only settled bills count towards the shift revenue.
  int get netRevenue {
    return orders
        .where((Order order) => order.paymentStatus == PaymentStatus.paid)
        .fold(0, (int sum, Order order) => sum + order.total);
  }

  int get cashRevenue {
    return orders
        .where((Order order) {
          return order.paymentStatus == PaymentStatus.paid &&
              order.paymentMethod == PaymentMethod.cash;
        })
        .fold(0, (int sum, Order order) => sum + order.total);
  }

  int get walletRevenue => netRevenue - cashRevenue;

  int get averageTurnaround {
    final List<Order> completed = orders.where((Order order) {
      return order.status == OrderStatus.completed &&
          order.completedAt != null;
    }).toList();

    if (completed.isEmpty) return 0;

    final int total = completed.fold(
      0,
      (int sum, Order order) => sum + order.turnaroundMinutes,
    );

    return (total / completed.length).round();
  }

  // ----------------------------------------------------------------- actions

  /// Moves a live ticket one step forward. Ready tickets are settled through
  /// [completeOrder] so the bill can be collected first.
  bool advanceStatus(Order order) {
    switch (order.status) {
      case OrderStatus.pending:
        _replace(order.copyWith(status: OrderStatus.preparing));
        _notify('Kitchen started', '${order.id} is now preparing.');
        return true;
      case OrderStatus.preparing:
        _replace(order.copyWith(status: OrderStatus.ready));
        _notify('Order ready', '${order.id} is ready for the counter.');
        return true;
      case OrderStatus.ready:
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return false;
    }
  }

  void completeOrder(
    Order order, {
    PaymentMethod? method,
    int? cashReceived,
  }) {
    if (order.status == OrderStatus.cancelled) return;

    final PaymentMethod resolvedMethod = method ?? order.paymentMethod;
    final int resolvedCash = resolvedMethod == PaymentMethod.cash
        ? (cashReceived ?? order.cashReceived)
        : order.cashReceived;

    final Order updated = order.copyWith(
      status: OrderStatus.completed,
      completedAt: now.value,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: resolvedMethod,
      cashReceived: resolvedCash,
    );

    _replace(updated);
    _notify(
      'Order completed',
      '${order.id} settled at ${formatTakaSymbol(updated.total)}.',
    );
  }

  /// Returns false when the manager pin does not match.
  bool voidOrder(Order order, String pin, String reason) {
    if (pin.trim() != managerPin) return false;

    final bool wasPaid = order.paymentStatus == PaymentStatus.paid;
    final String note = reason.trim().isEmpty
        ? 'Voided by manager'
        : reason.trim();

    final Order updated = order.copyWith(
      status: OrderStatus.cancelled,
      paymentStatus: wasPaid
          ? PaymentStatus.refunded
          : PaymentStatus.voided,
      cancellationReason: note,
    );

    _replace(updated);
    _notify(
      wasPaid ? 'Refund approved' : 'Order voided',
      wasPaid
          ? '${order.id} cancelled. ${formatTakaSymbol(order.total)} refunded.'
          : '${order.id} has been voided.',
    );

    return true;
  }

  void _replace(Order updated) {
    final int index = orders.indexWhere(
      (Order order) => order.id == updated.id,
    );

    if (index == -1) return;
    orders[index] = updated;
  }

  // ---------------------------------------------------------------- printing

  bool isPrintingOrder(String id) => printingOrderId.value == id;

  bool isPrintingKot(String id) => kotPrintingOrderId.value == id;

  Future<void> printReceipt(Order order) async {
    if (printingOrderId.value != null) return;

    if (order.paymentStatus == PaymentStatus.unpaid) {
      _notify(
        'Bill not settled',
        'Collect the payment before printing invoice ${order.id}.',
        isError: true,
      );
      return;
    }

    if (order.status == OrderStatus.cancelled) {
      _notify(
        'Invoice unavailable',
        '${order.id} was cancelled. Use the refund slip instead.',
        isError: true,
      );
      return;
    }

    if (!Get.isRegistered<ReceiptPrinter>()) {
      _notify(
        'Printer not ready',
        'No invoice printer is configured on this terminal.',
        isError: true,
      );
      return;
    }

    printingOrderId.value = order.id;

    try {
      final ReceiptDocument document = buildReceiptDocument(order);
      final String receiptUrl = ReceiptLink.forDocument(document).toString();

      final ReceiptPrintResult result = await Get.find<ReceiptPrinter>()
          .printReceipt(document, qrData: receiptUrl);

      if (result.isSuccess) {
        _notify(
          'Receipt sent',
          '${order.id} printed on ${result.printerName}.',
        );
      } else {
        _notify(
          'Printing failed',
          result.error ?? 'The receipt could not be printed.',
          isError: true,
        );
      }
    } catch (error) {
      _notify(
        'Printing failed',
        'Could not reach the printer: $error',
        isError: true,
      );
    } finally {
      printingOrderId.value = null;
    }
  }

  Future<void> printKitchenTicket(Order order) async {
    if (kotPrintingOrderId.value != null) return;

    if (order.status == OrderStatus.cancelled) {
      _notify(
        'KOT unavailable',
        '${order.id} was cancelled and cannot go back to the kitchen.',
        isError: true,
      );
      return;
    }

    if (!Get.isRegistered<PrinterSettingsController>()) {
      _notify(
        'Printer not ready',
        'No kitchen printer is configured on this terminal.',
        isError: true,
      );
      return;
    }

    kotPrintingOrderId.value = order.id;

    try {
      final Printer? printer = await Get.find<PrinterSettingsController>()
          .resolvePrinter();

      if (printer == null) {
        _notify('Printer not found', noPrinterMessage, isError: true);
        return;
      }

      final Uint8List bytes = await KitchenTicketPdfBuilder.build(
        order: order,
      );

      final bool sent = await Printing.directPrintPdf(
        printer: printer,
        name: 'KOT ${order.id}',
        format: PdfPageFormat.roll80,
        onLayout: (PdfPageFormat format) async => bytes,
      );

      if (!sent) {
        _notify(
          'Printing failed',
          'The kitchen printer did not accept the ticket.',
          isError: true,
        );
        return;
      }

      _replace(order.copyWith(kotPrintedAt: now.value));
      _notify('KOT sent', '${order.id} sent to ${printer.name}.');
    } catch (error) {
      _notify(
        'Printing failed',
        'Could not print the kitchen ticket: $error',
        isError: true,
      );
    } finally {
      kotPrintingOrderId.value = null;
    }
  }

  ReceiptDocument buildReceiptDocument(Order order) {
    final String selectedBranch = Get.isRegistered<BranchController>()
        ? (Get.find<BranchController>().selectedBranch.value ?? '')
        : '';
    final String branchCode = selectedBranch.isEmpty
        ? DummyPosData.branchCode
        : selectedBranch;

    final bool isPaid = order.paymentStatus == PaymentStatus.paid;
    final bool isCash = isPaid && order.paymentMethod == PaymentMethod.cash;
    final bool isWallet =
        isPaid && order.paymentMethod.isMobileWallet;

    return ReceiptDocument(
      invoiceNumber: order.invoiceNumber,
      branchName: DummyPosData.branchName,
      branchCode: branchCode,
      branchAddress: DummyPosData.branchAddress,
      branchBin: DummyPosData.branchBin,
      cashierName: order.serverName,
      customerName: order.customerName,
      tableLabel: order.channel == OrderChannel.dineIn
          ? (order.tableLabel ?? '')
          : order.channel.label,
      createdAt: order.placedAt,
      items: order.lines.map((OrderLine line) {
        return ReceiptLineItem(
          name: line.name,
          quantity: line.quantity,
          price: line.unitPrice,
          note: _receiptNote(line),
        );
      }).toList(growable: false),
      subtotal: order.subtotal,
      vatPercent: order.vatPercent,
      vat: order.vat,
      cashoutPercent: 0,
      cashout: 0,
      total: order.total,
      tenderLabel: isPaid ? order.paymentMethod.label : 'Unpaid',
      paidAmount: isPaid ? order.tenderedAmount : 0,
      discount: order.discount,
      changeDue: order.changeDue,
      isCash: isCash,
      isMobileWallet: isWallet,
    );
  }

  String? _receiptNote(OrderLine line) {
    final List<String> parts = <String>[
      if (line.note != null && line.note!.trim().isNotEmpty) line.note!.trim(),
      ...line.modifiers,
    ];

    return parts.isEmpty ? null : parts.join(' · ');
  }

  // ----------------------------------------------------------------- export

  Future<void> copyOrderSummary(Order order) async {
    final StringBuffer buffer = StringBuffer()
      ..writeln('${order.id} · ${order.status.label}')
      ..writeln(
        order.channel == OrderChannel.dineIn
            ? 'Table ${order.tableLabel ?? '-'} · ${order.areaLabel ?? ''}'
            : order.channel.label,
      )
      ..writeln('Customer: ${order.customerName}')
      ..writeln('Server: ${order.serverName} (${order.terminal})')
      ..writeln('Placed: ${formatClock(order.placedAt)}')
      ..writeln('');

    for (final OrderLine line in order.lines) {
      buffer.writeln(
        '${line.quantity} x ${line.name}  ${formatTakaSymbol(line.total)}',
      );
    }

    buffer
      ..writeln('')
      ..writeln('Subtotal: ${formatTakaSymbol(order.subtotal)}')
      ..writeln('VAT: ${formatTakaSymbol(order.vat)}')
      ..writeln('Total: ${formatTakaSymbol(order.total)}')
      ..writeln('Payment: ${order.paymentMethod.label} · '
          '${order.paymentStatus.label}');

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    _notify('Order copied', '${order.id} summary copied to the clipboard.');
  }

  Future<void> exportShiftLedger() async {
    final List<List<String>> rows = <List<String>>[
      <String>[
        'Invoice',
        'Placed',
        'Channel',
        'Customer',
        'Table / Rider',
        'Status',
        'Payment',
        'Method',
        'Server',
        'Items',
        'Subtotal',
        'Discount',
        'VAT',
        'Total',
      ],
      ...orders.map((Order order) {
        return <String>[
          order.id,
          order.placedAt.toIso8601String(),
          order.channel.label,
          order.customerName,
          _sourceForExport(order),
          order.status.label,
          order.paymentStatus.label,
          order.paymentMethod.label,
          order.serverName,
          '${order.itemCount}',
          '${order.subtotal}',
          '${order.discount}',
          '${order.vat}',
          '${order.total}',
        ];
      }),
    ];

    final String csv = rows
        .map((List<String> row) => row.map(_csvCell).join(','))
        .join('\n');

    await Clipboard.setData(ClipboardData(text: csv));
    _notify(
      'Shift ledger exported',
      '${orders.length} tickets copied to the clipboard as CSV.',
    );
  }

  String _sourceForExport(Order order) {
    switch (order.channel) {
      case OrderChannel.dineIn:
        return '${order.tableLabel ?? ''} ${order.areaLabel ?? ''}'.trim();
      case OrderChannel.takeaway:
        return order.customerPhone ?? 'Walk-in pickup';
      case OrderChannel.delivery:
        return '${order.riderLabel ?? 'Delivery'} ${order.riderCode ?? ''}'
            .trim();
    }
  }

  String _csvCell(String value) {
    final String escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  void _notify(String title, String message, {bool isError = false}) {
    if (Get.context == null) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.sidebarBackgroundBlack,
      colorText: AppTheme.lightAmberWhite,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
      shouldIconPulse: false,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: isError ? AppTheme.dangerRedLight : AppTheme.lightGreen,
        size: 20,
      ),
    );
  }
}
