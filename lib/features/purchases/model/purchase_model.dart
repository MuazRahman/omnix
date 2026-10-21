// State of a purchase order
enum PurchaseStatus {
  draft,
  ordered,
  received,
  cancelled;

  static PurchaseStatus fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'draft':
        return PurchaseStatus.draft;
      case 'ordered':
      case 'pending':
        return PurchaseStatus.ordered;
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
}

// One purchase order
class Purchase {
  const Purchase({
    required this.id,
    required this.supplier,
    required this.itemsSummary,
    required this.status,
    required this.amount,
    required this.orderedAt,
  });

  // builds a purchase from an API response, used once the backend is live
  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '',
      itemsSummary: json['items_summary']?.toString() ?? '',
      status: PurchaseStatus.fromValue(json['status']?.toString()),
      amount: (json['amount'] as num?)?.round() ?? 0,
      orderedAt: json['ordered_at']?.toString() ?? '',
    );
  }

  final String id;
  final String supplier;
  final String itemsSummary;
  final PurchaseStatus status;
  final int amount;
  final String orderedAt;
}
