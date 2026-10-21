import 'package:get/get.dart';
import 'package:omnix/features/customers/dummy_data/dummy_customer_data.dart';
import 'package:omnix/features/customers/model/customer_model.dart';

class CustomerController extends GetxController {
  final searchText = ''.obs;

  final customers = <Customer>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchCustomers() async {
    isLoading.value = true;

    // swap this for the API call, the shape stays the same
    // final response = await api.get('/customers');
    // customers.assignAll(
    //   (response as List)
    //       .map((e) => Customer.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    customers.assignAll(DummyCustomerData.customers);

    isLoading.value = false;
  }

  void searchOnChanged(String value) {
    searchText.value = value;
  }

  // Finds a customer by phone number. Phones are compared by digits only so
  // 01819-876543 and 01819876543 match the same customer.
  Customer? findByPhone(String phone) {
    final String digits = normalizePhone(phone);
    if (digits.isEmpty) return null;

    for (final Customer customer in customers) {
      if (normalizePhone(customer.phone) == digits) return customer;
    }

    return null;
  }

  static String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  // Saves a customer created from the POS or the Customers screen. Swap the
  // body for a POST request once the customers API is available, keeping the
  // returned shape the same. A name is optional; the phone is the identifier.
  Future<Customer> addCustomer({required String phone, String? name}) async {
    // The phone number is the customer identifier, never add it twice.
    final Customer? existing = findByPhone(phone);
    if (existing != null) return existing;

    final Customer customer = Customer(
      id: _nextCustomerId(),
      name: _cleanName(name),
      phone: phone.trim(),
      visits: 0,
      spent: 0,
      lastVisit: 'Just now',
    );

    customers.insert(0, customer);
    return customer;
  }

  // Keeps the directory in sync when a customer is edited.
  Future<Customer> updateCustomer({
    required String id,
    required String phone,
    String? name,
  }) async {
    final int index = customers.indexWhere(
      (Customer customer) => customer.id == id,
    );

    if (index == -1) {
      return addCustomer(name: name, phone: phone);
    }

    final Customer current = customers[index];
    final Customer updated = Customer(
      id: current.id,
      name: _cleanName(name),
      phone: phone.trim(),
      visits: current.visits,
      spent: current.spent,
      lastVisit: current.lastVisit,
    );

    customers[index] = updated;
    return updated;
  }

  String? _cleanName(String? name) {
    final String value = name?.trim() ?? '';
    return value.isEmpty ? null : value;
  }

  String _nextCustomerId() {
    int number = customers.length + 1;
    String id = 'CUS-${number.toString().padLeft(3, '0')}';

    while (customers.any((Customer customer) => customer.id == id)) {
      number++;
      id = 'CUS-${number.toString().padLeft(3, '0')}';
    }

    return id;
  }

  // customers matching the search text
  List<Customer> get filteredCustomers {
    final String query = searchText.value.trim().toLowerCase();
    final String phoneQuery = normalizePhone(query);

    return customers.where((Customer customer) {
      final String name = (customer.name ?? '').toLowerCase();

      return query.isEmpty ||
          name.contains(query) ||
          customer.phone.toLowerCase().contains(query) ||
          (phoneQuery.isNotEmpty &&
              normalizePhone(customer.phone).contains(phoneQuery)) ||
          customer.id.toLowerCase().contains(query);
    }).toList();
  }

  int get regularCount {
    return customers.where((Customer customer) => customer.isRegular).length;
  }

  int get totalSpent {
    return customers.fold(
      0,
      (int sum, Customer customer) => sum + customer.spent,
    );
  }
}
