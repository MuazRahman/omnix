// Customer attached to a POS ticket
class PosCustomer {
  const PosCustomer({required this.phone, this.name, this.id});

  // the name is optional, the phone number identifies the customer
  final String? name;

  final String phone;

  // id of the customer record, when the ticket was attached from the directory
  final String? id;

  String get displayName {
    final String value = name?.trim() ?? '';
    return value.isEmpty ? 'N/A' : value;
  }

  @override
  bool operator ==(Object other) {
    return other is PosCustomer &&
        other.id == id &&
        other.name == name &&
        other.phone == phone;
  }

  @override
  int get hashCode => Object.hash(id, name, phone);
}
