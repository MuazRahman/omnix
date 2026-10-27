import 'dart:typed_data';

/// Kitchen state of a dish, derived from its availability and stock flag.
enum MenuKitchenStatus { active, lowStock, soldOut }

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
    this.imageBytes,
    this.banglaName = '',
    this.recipeCost = 0,
    this.isLowStock = false,
    this.isBestseller = false,
    this.modifierCount = 0,
    this.modifierSummary = '',
    this.soldToday = 0,
    this.preparationTime = 15,
    this.kitchenStation = 'Main Kitchen',
  });

  // builds a menu item from an API response, used once the backend is live
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final int price = (json['price'] as num?)?.round() ?? 0;
    final int recipeCost =
        (json['recipe_cost'] as num?)?.round() ?? (price * 0.4).round();

    return MenuItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      price: price,
      isAvailable: json['is_available'] as bool? ?? true,
      branchId: json['branch_id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      banglaName: json['bangla_name']?.toString() ?? '',
      recipeCost: recipeCost,
      isLowStock: json['is_low_stock'] as bool? ?? false,
      isBestseller: json['is_bestseller'] as bool? ?? false,
      modifierCount: (json['modifier_count'] as num?)?.round() ?? 0,
      modifierSummary: json['modifier_summary']?.toString() ?? '',
      soldToday: (json['sold_today'] as num?)?.round() ?? 0,
      preparationTime: (json['preparation_time'] as num?)?.round() ?? 15,
      kitchenStation: json['kitchen_station']?.toString() ?? 'Main Kitchen',
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
  // New rows normally point at an uploaded picture; a missing image simply
  // renders the dark placeholder tile.
  final String imageUrl;

  // locally picked picture, kept in memory until the backend can store uploads.
  // When present it takes precedence over [imageUrl].
  final Uint8List? imageBytes;

  // local-language alias shown under the dish name
  final String banglaName;

  // food cost of one serving, used for the margin columns
  final int recipeCost;

  // kitchen warning that still allows selling, e.g. only a few portions left
  final bool isLowStock;

  final bool isBestseller;

  final int modifierCount;

  // short human summary of the attached options, e.g. 'Extra Cheese, Spicy'
  final String modifierSummary;

  // demo sales figure used by the grossing segment card
  final int soldToday;

  final int preparationTime;

  // station that prepares the dish, used by kitchen tickets and the editor
  final String kitchenStation;

  // money left after the recipe cost
  int get netMargin => price - recipeCost;

  // gross margin percentage, 0 when the dish has no price
  double get grossMargin {
    if (price <= 0) return 0;
    return (netMargin / price) * 100;
  }

  MenuKitchenStatus get kitchenStatus {
    if (!isAvailable) return MenuKitchenStatus.soldOut;
    if (isLowStock) return MenuKitchenStatus.lowStock;
    return MenuKitchenStatus.active;
  }

  String get codeLabel => '#$id';

  MenuItem copyWith({
    String? id,
    String? name,
    String? category,
    int? price,
    bool? isAvailable,
    String? branchId,
    String? imageUrl,
    Uint8List? imageBytes,
    String? banglaName,
    int? recipeCost,
    bool? isLowStock,
    bool? isBestseller,
    int? modifierCount,
    String? modifierSummary,
    int? soldToday,
    int? preparationTime,
    String? kitchenStation,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      branchId: branchId ?? this.branchId,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      banglaName: banglaName ?? this.banglaName,
      recipeCost: recipeCost ?? this.recipeCost,
      isLowStock: isLowStock ?? this.isLowStock,
      isBestseller: isBestseller ?? this.isBestseller,
      modifierCount: modifierCount ?? this.modifierCount,
      modifierSummary: modifierSummary ?? this.modifierSummary,
      soldToday: soldToday ?? this.soldToday,
      preparationTime: preparationTime ?? this.preparationTime,
      kitchenStation: kitchenStation ?? this.kitchenStation,
    );
  }
}
