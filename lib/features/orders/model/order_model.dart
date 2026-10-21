// Status of an order in the orders list
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

// One order of the orders list
class Order {
  const Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.status,
    required this.amount,
    required this.placedAt,
    required this.paymentMethod,
  });

  // builds an order from an API response, used once the backend is live
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      customer: json['customer']?.toString() ?? 'Walk-in',
      items: json['items']?.toString() ?? '',
      status: OrderStatus.fromValue(json['status']?.toString()),
      amount: (json['amount'] as num?)?.round() ?? 0,
      placedAt: json['placed_at']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? 'Cash',
    );
  }

  final String id;
  final String customer;
  final String items;
  final OrderStatus status;
  final int amount;
  final String placedAt;
  final String paymentMethod;
}
