import 'package:get/get.dart';
import 'package:omnix/features/orders/dummy_data/dummy_order_data.dart';
import 'package:omnix/features/orders/model/order_model.dart';

class OrderController extends GetxController {
  final List<String> statusFilters = const [
    'All',
    'Pending',
    'Preparing',
    'Ready',
    'Completed',
    'Cancelled',
  ];

  final selectedStatus = 0.obs;

  final searchText = ''.obs;

  final orders = <Order>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchOrders() async {
    isLoading.value = true;

    // swap this for the API call, the shape stays the same
    // final response = await api.get('/orders');
    // orders.assignAll(
    //   (response as List)
    //       .map((e) => Order.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    orders.assignAll(DummyOrderData.orders);

    isLoading.value = false;
  }

  void statusFilterOnChanged(int index) {
    selectedStatus.value = index;
  }

  void searchOnChanged(String value) {
    searchText.value = value;
  }

  // orders matching the current status filter and the search text
  List<Order> get filteredOrders {
    final String query = searchText.value.trim().toLowerCase();

    return orders.where((Order order) {
      final bool matchesStatus = _matchesStatus(order.status);
      final bool matchesSearch =
          query.isEmpty ||
          order.id.toLowerCase().contains(query) ||
          order.customer.toLowerCase().contains(query) ||
          order.items.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  bool _matchesStatus(OrderStatus status) {
    final int index = selectedStatus.value;

    // the first filter is "All"
    if (index == 0) return true;

    return statusFilters[index] == _statusLabel(status);
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // totals of the filtered orders, shown on top of the table
  int get filteredTotal {
    return filteredOrders.fold(0, (int sum, Order order) => sum + order.amount);
  }

  int get filteredCount {
    return filteredOrders.length;
  }
}
