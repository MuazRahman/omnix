// One item of the restaurant menu
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.isAvailable,
    this.preparationTime = 15,
  });

  // builds a menu item from an API response, used once the backend is live
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      price: (json['price'] as num?)?.round() ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      preparationTime: (json['preparation_time'] as num?)?.round() ?? 15,
    );
  }

  final String id;
  final String name;
  final String category;
  final int price;
  final bool isAvailable;
  final int preparationTime;
}
