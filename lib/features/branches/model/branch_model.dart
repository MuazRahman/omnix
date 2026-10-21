// One branch of the restaurant chain
class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.manager,
    required this.phone,
    required this.isActive,
    required this.openedAt,
  });

  // builds a branch from an API response, used once the backend is live
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      manager: json['manager']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      openedAt: json['opened_at']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final String address;
  final String manager;
  final String phone;
  final bool isActive;
  final String openedAt;
}
