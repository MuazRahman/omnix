// Stock state of an inventory item
enum StockLevel {
  inStock,
  lowStock,
  outOfStock;

  static StockLevel fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'out_of_stock':
      case 'outofstock':
        return StockLevel.outOfStock;
      case 'low_stock':
      case 'lowstock':
        return StockLevel.lowStock;
      default:
        return StockLevel.inStock;
    }
  }
}

// One item tracked in the inventory
class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.reorderLevel,
    required this.unitCost,
  });

  // builds an item from an API response, used once the backend is live
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      quantity: (json['quantity'] as num?)?.round() ?? 0,
      unit: json['unit']?.toString() ?? 'pcs',
      reorderLevel: (json['reorder_level'] as num?)?.round() ?? 0,
      unitCost: (json['unit_cost'] as num?)?.round() ?? 0,
    );
  }

  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final int reorderLevel;
  final int unitCost;

  // stock state derived from the quantity and the reorder level
  StockLevel get level {
    if (quantity == 0) return StockLevel.outOfStock;
    if (quantity <= reorderLevel) return StockLevel.lowStock;
    return StockLevel.inStock;
  }

  // total value of the stock on hand
  int get totalValue => quantity * unitCost;
}
