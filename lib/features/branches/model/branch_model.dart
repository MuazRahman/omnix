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
    this.area = '',
    this.tagline = '',
    this.isCloudKitchen = false,
    this.tables = 0,
    this.seats = 0,
    this.posTerminals = 0,
    this.staffCount = 0,
    this.todayRevenue = 0,
    this.todayOrders = 0,
    this.inventoryHealth = 100,
    this.lowStockCount = 0,
    this.isCurrent = false,
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
      area: json['area']?.toString() ?? '',
      tagline: json['tagline']?.toString() ?? '',
      isCloudKitchen: json['is_cloud_kitchen'] as bool? ?? false,
      tables: (json['tables'] as num?)?.toInt() ?? 0,
      seats: (json['seats'] as num?)?.toInt() ?? 0,
      posTerminals: (json['pos_terminals'] as num?)?.toInt() ?? 0,
      staffCount: (json['staff_count'] as num?)?.toInt() ?? 0,
      todayRevenue: (json['today_revenue'] as num?)?.toInt() ?? 0,
      todayOrders: (json['today_orders'] as num?)?.toInt() ?? 0,
      inventoryHealth: (json['inventory_health'] as num?)?.toDouble() ?? 100,
      lowStockCount: (json['low_stock_count'] as num?)?.toInt() ?? 0,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String address;
  final String manager;
  final String phone;
  final bool isActive;
  final String openedAt;

  // location grouping shown under the branch name, e.g. "Gulshan, Dhaka"
  final String area;

  // short descriptor shown on the branch card, e.g. "Flagship Outlet"
  final String tagline;

  // cloud kitchens have no dine-in floor
  final bool isCloudKitchen;

  final int tables;
  final int seats;

  // live POS terminals attached to this outlet
  final int posTerminals;

  // staff currently deployed at the outlet
  final int staffCount;

  // today's running numbers, sourced from the analytics service later
  final int todayRevenue;
  final int todayOrders;

  // stock health of the outlet's store, 0 - 100
  final double inventoryHealth;

  // number of SKUs sitting below their reorder level
  final int lowStockCount;

  // the outlet this terminal is currently operating from
  final bool isCurrent;

  // label used by the global branch selector, e.g. "Main Branch (DHK-01)"
  String get selectorLabel => '$name ($id)';

  int get todayAverageTicket =>
      todayOrders == 0 ? 0 : (todayRevenue / todayOrders).round();

  bool get hasLowStock => lowStockCount > 0;

  Branch copyWith({
    String? id,
    String? name,
    String? address,
    String? manager,
    String? phone,
    bool? isActive,
    String? openedAt,
    String? area,
    String? tagline,
    bool? isCloudKitchen,
    int? tables,
    int? seats,
    int? posTerminals,
    int? staffCount,
    int? todayRevenue,
    int? todayOrders,
    double? inventoryHealth,
    int? lowStockCount,
    bool? isCurrent,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      manager: manager ?? this.manager,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      openedAt: openedAt ?? this.openedAt,
      area: area ?? this.area,
      tagline: tagline ?? this.tagline,
      isCloudKitchen: isCloudKitchen ?? this.isCloudKitchen,
      tables: tables ?? this.tables,
      seats: seats ?? this.seats,
      posTerminals: posTerminals ?? this.posTerminals,
      staffCount: staffCount ?? this.staffCount,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      todayOrders: todayOrders ?? this.todayOrders,
      inventoryHealth: inventoryHealth ?? this.inventoryHealth,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}

/// One hour of the cross-branch order throughput chart.
class BranchThroughputSlot {
  const BranchThroughputSlot({required this.hour, required this.orders});

  // label under the bar group, e.g. "14:00"
  final String hour;

  // branch id -> orders served in this hour
  final Map<String, int> orders;
}
