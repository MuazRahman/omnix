// One approved raw-food or packaging supplier
class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    required this.tier,
    required this.category,
    required this.description,
    required this.creditTerms,
    required this.outstanding,
    required this.lifetimeSpend,
    required this.representative,
    required this.phone,
  });

  // builds a vendor from an API response, used once the backend is live
  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tier: json['tier']?.toString() ?? 'Tier 2',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      creditTerms: json['credit_terms']?.toString() ?? '',
      outstanding: (json['outstanding'] as num?)?.round() ?? 0,
      lifetimeSpend: (json['lifetime_spend'] as num?)?.round() ?? 0,
      representative: json['representative']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final String tier;
  final String category;
  final String description;
  final String creditTerms;
  final int outstanding;
  final int lifetimeSpend;
  final String representative;
  final String phone;

  bool get hasOutstanding => outstanding > 0;
}
