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
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit']?.toString() ?? 'pcs',
      reorderLevel: (json['reorder_level'] as num?)?.toDouble() ?? 0,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0,
    );
  }

  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double reorderLevel;
  final double unitCost;

  // copy with the given fields replaced, used when a category is renamed or
  // removed and the stock rows need to follow it
  InventoryItem copyWith({String? category}) {
    return InventoryItem(
      id: id,
      name: name,
      category: category ?? this.category,
      quantity: quantity,
      unit: unit,
      reorderLevel: reorderLevel,
      unitCost: unitCost,
    );
  }

  // payload posted to the inventory API when this item is created
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'reorder_level': reorderLevel,
      'unit_cost': unitCost,
    };
  }

  // stock state derived from the quantity and the reorder level
  StockLevel get level {
    if (quantity <= 0) return StockLevel.outOfStock;
    if (quantity <= reorderLevel) return StockLevel.lowStock;
    return StockLevel.inStock;
  }

  // total value of the stock on hand
  double get totalValue => quantity * unitCost;
}
