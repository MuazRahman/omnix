import 'package:omnix/core/utils/format.dart';

// Lifecycle of a purchase order
enum PurchaseStatus {
  draft,
  ordered,
  inTransit,
  received,
  cancelled;

  static PurchaseStatus fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'draft':
        return PurchaseStatus.draft;
      case 'ordered':
      case 'pending':
        return PurchaseStatus.ordered;
      case 'in transit':
      case 'in_transit':
      case 'intransit':
      case 'shipped':
        return PurchaseStatus.inTransit;
      case 'received':
      case 'completed':
        return PurchaseStatus.received;
      case 'cancelled':
      case 'canceled':
        return PurchaseStatus.cancelled;
      default:
        return PurchaseStatus.draft;
    }
  }

  // human label used by the table, the filter chips and the pills
  String get label {
    switch (this) {
      case PurchaseStatus.draft:
        return 'Draft';
      case PurchaseStatus.ordered:
        return 'Awaiting Delivery';
      case PurchaseStatus.inTransit:
        return 'In Transit';
      case PurchaseStatus.received:
        return 'Received';
      case PurchaseStatus.cancelled:
        return 'Cancelled';
    }
  }
}

// Settlement state of the vendor invoice behind a purchase order
enum PaymentStatus {
  unpaid,
  partial,
  paid;

  static PaymentStatus fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'paid':
      case 'settled':
        return PaymentStatus.paid;
      case 'partial':
      case 'partial paid':
        return PaymentStatus.partial;
      default:
        return PaymentStatus.unpaid;
    }
  }

  String get label {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.partial:
        return 'Partial Paid';
      case PaymentStatus.paid:
        return 'Paid';
    }
  }
}

// One commodity line on a purchase order
class PurchaseLine {
  const PurchaseLine({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  // builds a line from an API response, used once the backend is live
  factory PurchaseLine.fromJson(Map<String, dynamic> json) {
    return PurchaseLine(
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit']?.toString() ?? 'kg',
      unitPrice: (json['unit_price'] as num?)?.round() ?? 0,
    );
  }

  final String name;
  final double quantity;
  final String unit;

  // cost of one [unit], in BDT
  final int unitPrice;

  // quantity * unitPrice, the money this line adds to the order
  int get total => (quantity * unitPrice).round();

  // "120 kg"
  String get displayQuantity => '${formatQuantity(quantity)} $unit';

  // "120 kg Bone-in Mutton (Halal)"
  String get summary => '$displayQuantity $name';

  // "৳ 1,200 / kg"
  String get displayUnitPrice => '${formatTakaSymbol(unitPrice)} / $unit';
}

// One purchase order
class Purchase {
  const Purchase({
    required this.id,
    required this.supplierId,
    required this.supplier,
    required this.destination,
    required this.status,
    required this.paymentStatus,
    required this.lines,
    required this.orderedAt,
    this.paidAmount = 0,
    this.expectedAt,
    this.receivedAt,
    this.carrier,
    this.gate = 'Bay 01',
    this.receivedBy,
  });

  // builds a purchase from an API response, used once the backend is live
  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      status: PurchaseStatus.fromValue(json['status']?.toString()),
      paymentStatus: PaymentStatus.fromValue(json['payment_status']?.toString()),
      lines: (json['lines'] as List<dynamic>? ?? const [])
          .map((e) => PurchaseLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      orderedAt: json['ordered_at']?.toString() ?? '',
      paidAmount: (json['paid_amount'] as num?)?.round() ?? 0,
      expectedAt: json['expected_at']?.toString(),
      receivedAt: json['received_at']?.toString(),
      carrier: json['carrier']?.toString(),
      gate: json['gate']?.toString() ?? 'Bay 01',
      receivedBy: json['received_by']?.toString(),
    );
  }

  final String id;
  final String supplierId;
  final String supplier;
  final String destination;
  final PurchaseStatus status;
  final PaymentStatus paymentStatus;
  final List<PurchaseLine> lines;
  final int paidAmount;
  final String orderedAt;
  final String? expectedAt;
  final String? receivedAt;
  final String? carrier;
  final String gate;
  final String? receivedBy;

  int get lineCount => lines.length;

  // order total, always the sum of its lines so the money stays consistent
  int get amount =>
      lines.fold(0, (int sum, PurchaseLine line) => sum + line.total);

  // still needs to be received at the gate
  bool get isOpen =>
      status == PurchaseStatus.ordered || status == PurchaseStatus.inTransit;

  int get balanceDue => amount - paidAmount;

  // "120 kg Bone-in Mutton (Halal), 40 kg Prime Beef Chuck"
  String get commodities =>
      lines.map((PurchaseLine line) => line.summary).join(', ');

  Purchase copyWith({
    PurchaseStatus? status,
    PaymentStatus? paymentStatus,
    int? paidAmount,
    String? receivedAt,
    String? receivedBy,
  }) {
    return Purchase(
      id: id,
      supplierId: supplierId,
      supplier: supplier,
      destination: destination,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      lines: lines,
      orderedAt: orderedAt,
      paidAmount: paidAmount ?? this.paidAmount,
      expectedAt: expectedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      carrier: carrier,
      gate: gate,
      receivedBy: receivedBy ?? this.receivedBy,
    );
  }
}
