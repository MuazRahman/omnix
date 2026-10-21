// Role of a staff member
enum StaffRole {
  manager,
  cashier,
  chef,
  waiter;

  static StaffRole fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'manager':
        return StaffRole.manager;
      case 'cashier':
        return StaffRole.cashier;
      case 'chef':
        return StaffRole.chef;
      case 'waiter':
        return StaffRole.waiter;
      default:
        return StaffRole.cashier;
    }
  }
}

// One member of the staff
class Staff {
  const Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.branch,
    required this.phone,
    required this.isActive,
    required this.joinedAt,
  });

  // builds a staff member from an API response, used once the backend is live
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: StaffRole.fromValue(json['role']?.toString()),
      branch: json['branch']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      joinedAt: json['joined_at']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final StaffRole role;
  final String branch;
  final String phone;
  final bool isActive;
  final String joinedAt;
}
