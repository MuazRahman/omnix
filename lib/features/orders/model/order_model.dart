// Lifecycle of a ticket from the moment it is placed until it is settled.
enum OrderStatus {
  pending('Pending'),
  preparing('Preparing'),
  ready('Ready'),
  completed('Completed'),
  cancelled('Cancelled');

  const OrderStatus(this.label);

  final String label;

  // maps the status coming from the backend onto the local lifecycle
  static OrderStatus fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'pending':
      case 'placed':
      case 'new':
        return OrderStatus.pending;
      case 'preparing':
      case 'cooking':
      case 'in_kitchen':
        return OrderStatus.preparing;
      case 'ready':
      case 'dispatched':
      case 'out_for_delivery':
        return OrderStatus.ready;
      case 'completed':
      case 'served':
      case 'paid':
      case 'closed':
        return OrderStatus.completed;
      case 'cancelled':
      case 'canceled':
      case 'void':
      case 'refunded':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// Tickets the kitchen or the counter still has to work on.
  bool get isLive =>
      this == OrderStatus.pending || this == OrderStatus.preparing;

  bool get isClosed =>
      this == OrderStatus.completed || this == OrderStatus.cancelled;
}

// How the guest receives the order.
enum OrderChannel {
  dineIn('Dine-in'),
  takeaway('Takeaway'),
  delivery('Delivery');

  const OrderChannel(this.label);

  final String label;

  static OrderChannel fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'dine_in':
      case 'dine-in':
      case 'dinein':
      case 'table':
        return OrderChannel.dineIn;
      case 'takeaway':
      case 'take_away':
      case 'pickup':
        return OrderChannel.takeaway;
      case 'delivery':
      case 'dispatch':
        return OrderChannel.delivery;
      default:
        return OrderChannel.dineIn;
    }
  }
}

// Tender used to settle the ticket.
enum PaymentMethod {
  cash('Cash'),
  bKash('bKash'),
  card('Card'),
  nagad('Nagad');

  const PaymentMethod(this.label);

  final String label;

  static PaymentMethod fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'bkash':
        return PaymentMethod.bKash;
      case 'card':
      case 'credit':
      case 'debit':
        return PaymentMethod.card;
      case 'nagad':
        return PaymentMethod.nagad;
      default:
        return PaymentMethod.cash;
    }
  }

  bool get isMobileWallet =>
      this == PaymentMethod.bKash || this == PaymentMethod.nagad;
}

// Settlement state of the bill.
enum PaymentStatus {
  paid('Paid'),
  unpaid('Unpaid'),
  refunded('Refunded'),
  voided('Voided');

  const PaymentStatus(this.label);

  final String label;

  static PaymentStatus fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'paid':
      case 'settled':
        return PaymentStatus.paid;
      case 'refunded':
      case 'refund':
        return PaymentStatus.refunded;
      case 'void':
      case 'voided':
        return PaymentStatus.voided;
      default:
        return PaymentStatus.unpaid;
    }
  }
}

// One item line of a ticket.
class OrderLine {
  const OrderLine({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.note,
    this.modifiers = const <String>[],
  });

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    return OrderLine(
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.round() ?? 0,
      note: json['note']?.toString(),
      modifiers:
          (json['modifiers'] as List<dynamic>?)
              ?.map((dynamic value) => value.toString())
              .toList(growable: false) ??
          const <String>[],
    );
  }

  final String name;
  final int quantity;
  final int unitPrice;
  final String? note;

  /// Kitchen choices such as "Extra aloo" or "Spice: medium".
  final List<String> modifiers;

  int get total => quantity * unitPrice;
}

// One ticket shown in the order ledger.
class Order {
  const Order({
    required this.id,
    required this.token,
    required this.customerName,
    this.customerPhone,
    required this.channel,
    this.tableLabel,
    this.areaLabel,
    this.guests = 0,
    required this.serverName,
    required this.terminal,
    this.riderLabel,
    this.riderCode,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.placedAt,
    required this.lines,
    this.vatPercent = 5,
    this.discount = 0,
    this.cashReceived = 0,
    this.completedAt,
    this.kotPrintedAt,
    this.cancellationReason,
  });

  // builds an order from an API response, used once the backend is live
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? 'Walk-in',
      customerPhone: json['customer_phone']?.toString(),
      channel: OrderChannel.fromValue(json['channel']?.toString()),
      tableLabel: json['table']?.toString(),
      areaLabel: json['area']?.toString(),
      guests: (json['guests'] as num?)?.toInt() ?? 0,
      serverName: json['server']?.toString() ?? '',
      terminal: json['terminal']?.toString() ?? '',
      riderLabel: json['rider']?.toString(),
      riderCode: json['rider_code']?.toString(),
      status: OrderStatus.fromValue(json['status']?.toString()),
      paymentStatus: PaymentStatus.fromValue(
        json['payment_status']?.toString(),
      ),
      paymentMethod: PaymentMethod.fromValue(
        json['payment_method']?.toString(),
      ),
      placedAt:
          DateTime.tryParse(json['placed_at']?.toString() ?? '') ??
          DateTime.now(),
      lines:
          (json['lines'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(OrderLine.fromJson)
              .toList(growable: false) ??
          const <OrderLine>[],
      vatPercent: (json['vat_percent'] as num?)?.toDouble() ?? 5,
      discount: (json['discount'] as num?)?.round() ?? 0,
      cashReceived: (json['cash_received'] as num?)?.round() ?? 0,
      completedAt: DateTime.tryParse(json['completed_at']?.toString() ?? ''),
      kotPrintedAt: DateTime.tryParse(json['kot_printed_at']?.toString() ?? ''),
      cancellationReason: json['cancellation_reason']?.toString(),
    );
  }

  final String id;
  final String token;
  final String customerName;
  final String? customerPhone;

  final OrderChannel channel;
  final String? tableLabel;
  final String? areaLabel;
  final int guests;

  final String serverName;
  final String terminal;

  // Rider details for delivery dispatches.
  final String? riderLabel;
  final String? riderCode;

  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;

  final DateTime placedAt;
  final List<OrderLine> lines;

  final double vatPercent;
  final int discount;

  /// Cash handed over by the guest, used to calculate the change.
  final int cashReceived;

  final DateTime? completedAt;
  final DateTime? kotPrintedAt;
  final String? cancellationReason;

  // invoice number printed on the receipt, "SD-1042" -> 1042
  int get invoiceNumber {
    final String digits = id.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  int get itemCount => lines.fold(0, (int sum, OrderLine line) {
    return sum + line.quantity;
  });

  int get subtotal => lines.fold(0, (int sum, OrderLine line) {
    return sum + line.total;
  });

  int get taxableTotal => subtotal - discount;

  int get vat => (taxableTotal * vatPercent / 100).round();

  int get total => taxableTotal + vat;

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  // amount the guest actually handed over
  int get tenderedAmount {
    if (paymentMethod == PaymentMethod.cash && cashReceived > 0) {
      return cashReceived;
    }
    return total;
  }

  int get changeDue {
    if (!isPaid || paymentMethod != PaymentMethod.cash) return 0;
    final int change = tenderedAmount - total;
    return change > 0 ? change : 0;
  }

  int get balanceDue {
    if (paymentStatus == PaymentStatus.paid ||
        paymentStatus == PaymentStatus.refunded) {
      return 0;
    }
    return total;
  }

  int elapsedMinutes(DateTime now) {
    final int minutes = now.difference(placedAt).inMinutes;
    return minutes < 0 ? 0 : minutes;
  }

  String elapsedLabel(DateTime now) {
    final int minutes = elapsedMinutes(now);
    if (minutes < 1) return 'Just now';
    if (minutes < 60) return '${minutes}m ago';

    final int hours = minutes ~/ 60;
    final int rest = minutes % 60;
    return rest == 0 ? '${hours}h ago' : '${hours}h ${rest}m ago';
  }

  /// True when a live ticket has been waiting longer than the target.
  bool isRush(DateTime now) => status.isLive && elapsedMinutes(now) >= 15;

  int get turnaroundMinutes {
    final DateTime? closedAt = completedAt;
    if (closedAt == null) return 0;

    final int minutes = closedAt.difference(placedAt).inMinutes;
    return minutes < 0 ? 0 : minutes;
  }

  Order copyWith({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    int? cashReceived,
    DateTime? completedAt,
    DateTime? kotPrintedAt,
    String? cancellationReason,
  }) {
    return Order(
      id: id,
      token: token,
      customerName: customerName,
      customerPhone: customerPhone,
      channel: channel,
      tableLabel: tableLabel,
      areaLabel: areaLabel,
      guests: guests,
      serverName: serverName,
      terminal: terminal,
      riderLabel: riderLabel,
      riderCode: riderCode,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      placedAt: placedAt,
      lines: lines,
      vatPercent: vatPercent,
      discount: discount,
      cashReceived: cashReceived ?? this.cashReceived,
      completedAt: completedAt ?? this.completedAt,
      kotPrintedAt: kotPrintedAt ?? this.kotPrintedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
