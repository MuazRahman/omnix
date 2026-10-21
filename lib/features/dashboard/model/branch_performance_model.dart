// Performance of one branch, shown on the dashboard branch card
class BranchPerformance {
  const BranchPerformance({
    required this.branchId,
    required this.name,
    required this.sale,
    required this.orders,
    required this.changePercent,
  });

  // builds a branch row from an API response, used once the backend is live
  factory BranchPerformance.fromJson(Map<String, dynamic> json) {
    return BranchPerformance(
      branchId: json['branch_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sale: (json['sale'] as num?)?.round() ?? 0,
      orders: (json['orders'] as num?)?.round() ?? 0,
      changePercent: (json['change_percent'] as num?)?.toDouble() ?? 0,
    );
  }

  final String branchId;
  final String name;
  final int sale;
  final int orders;
  final double changePercent;
}
