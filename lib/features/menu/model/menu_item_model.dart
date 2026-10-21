// One item of the restaurant menu
//
// Menu rows are stored per branch, so the same dish sold at two branches is
// two records that share nothing but the name and price.
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.isAvailable,
    required this.branchId,
    required this.imageUrl,
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
      branchId: json['branch_id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      preparationTime: (json['preparation_time'] as num?)?.round() ?? 15,
    );
  }

  final String id;
  final String name;
  final String category;
  final int price;
  final bool isAvailable;

  // branch this row belongs to, e.g. 'DHK-01'
  final String branchId;

  // bundled asset path in the dummy data, remote URL once the API serves one.
  // A picture is mandatory when a menu item is created, so this is never empty
  // for rows created in the app.
  final String imageUrl;

  final int preparationTime;
}
