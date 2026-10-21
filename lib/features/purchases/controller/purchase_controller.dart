import 'package:get/get.dart';
import 'package:omnix/features/purchases/dummy_data/dummy_purchase_data.dart';
import 'package:omnix/features/purchases/model/purchase_model.dart';

class PurchaseController extends GetxController {
  final List<String> statusFilters = DummyPurchaseData.statusFilters;

  final selectedStatus = 0.obs;

  final searchText = ''.obs;

  final purchases = <Purchase>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPurchases();
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchPurchases() async {
    isLoading.value = true;

    // swap this for the API call, the shape stays the same
    // final response = await api.get('/purchases');
    // purchases.assignAll(
    //   (response as List)
    //       .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    purchases.assignAll(DummyPurchaseData.purchases);

    isLoading.value = false;
  }

  void statusFilterOnChanged(int index) {
    selectedStatus.value = index;
  }

  void searchOnChanged(String value) {
    searchText.value = value;
  }

  // purchases matching the current status filter and the search text
  List<Purchase> get filteredPurchases {
    final String query = searchText.value.trim().toLowerCase();

    return purchases.where((Purchase purchase) {
      final bool matchesStatus = _matchesStatus(purchase.status);
      final bool matchesSearch =
          query.isEmpty ||
          purchase.id.toLowerCase().contains(query) ||
          purchase.supplier.toLowerCase().contains(query) ||
          purchase.itemsSummary.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  bool _matchesStatus(PurchaseStatus status) {
    final int index = selectedStatus.value;

    // the first filter is "All"
    if (index == 0) return true;

    return statusFilters[index] == _statusLabel(status);
  }

  String _statusLabel(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.draft:
        return 'Draft';
      case PurchaseStatus.ordered:
        return 'Ordered';
      case PurchaseStatus.received:
        return 'Received';
      case PurchaseStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get pendingCount {
    return purchases
        .where((Purchase p) => p.status == PurchaseStatus.ordered)
        .length;
  }

  int get filteredTotal {
    return filteredPurchases.fold(
      0,
      (int sum, Purchase purchase) => sum + purchase.amount,
    );
  }
}
