// Status of a recent order, drives the badge look in the recent orders table
enum OrderStatus {
  pending,
  preparing,
  ready,
  completed,
  cancelled;

  // maps the status coming from the backend onto the badge styles
  static OrderStatus fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'preparing':
      case 'cooking':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'completed':
      case 'served':
        return OrderStatus.completed;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

// One row of the Recent Orders table
class RecentOrder {
  const RecentOrder({
    required this.id,
    required this.items,
    required this.status,
    required this.amount,
  });

  // builds a row from an API response, used once the backend is live
  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      id: json['id']?.toString() ?? '',
      items: json['items']?.toString() ?? '',
      status: OrderStatus.fromValue(json['status']?.toString()),
      amount: (json['amount'] as num?)?.round() ?? 0,
    );
  }

  final String id;
  final String items;
  final OrderStatus status;
  final int amount;
}
