// One customer of the restaurant
class Customer {
  const Customer({
    required this.id,
    this.name,
    required this.phone,
    required this.visits,
    required this.spent,
    required this.lastVisit,
  });

  // builds a customer from an API response, used once the backend is live
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      phone: json['phone']?.toString() ?? '',
      visits: (json['visits'] as num?)?.round() ?? 0,
      spent: (json['spent'] as num?)?.round() ?? 0,
      lastVisit: json['last_visit']?.toString() ?? '',
    );
  }

  final String id;

  // the name is optional, the phone number is the customer identifier
  final String? name;

  final String phone;
  final int visits;
  final int spent;
  final String lastVisit;

  // a regular customer, visited 5 times or more
  bool get isRegular => visits >= 5;

  // customers created with only a phone number show N/A wherever a name is
  // required
  String get displayName {
    final String value = name?.trim() ?? '';
    return value.isEmpty ? 'N/A' : value;
  }
}
