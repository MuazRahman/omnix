import 'package:get/get.dart';
import 'package:omnix/features/inventory/dummy_data/dummy_inventory_data.dart';
import 'package:omnix/features/inventory/model/inventory_item_model.dart';

class InventoryController extends GetxController {
  final List<String> categories = DummyInventoryData.categories;

  final selectedCategory = 0.obs;

  final searchText = ''.obs;

  final items = <InventoryItem>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchItems() async {
    isLoading.value = true;

    // swap this for the API call, the shape stays the same
    // final response = await api.get('/inventory/items');
    // items.assignAll(
    //   (response as List)
    //       .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    items.assignAll(DummyInventoryData.items);

    isLoading.value = false;
  }

  void categoryOnChanged(int index) {
    selectedCategory.value = index;
  }

  void searchOnChanged(String value) {
    searchText.value = value;
  }

  // items matching the current category and the search text
  List<InventoryItem> get filteredItems {
    final String query = searchText.value.trim().toLowerCase();
    final String category = categories[selectedCategory.value];

    return items.where((InventoryItem item) {
      final bool matchesCategory =
          category == 'All' || item.category == category;
      final bool matchesSearch =
          query.isEmpty || item.name.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get lowStockCount {
    return items
        .where((InventoryItem item) => item.level == StockLevel.lowStock)
        .length;
  }

  int get outOfStockCount {
    return items
        .where((InventoryItem item) => item.level == StockLevel.outOfStock)
        .length;
  }

  // value of all the stock on hand
  int get totalValue {
    return items.fold(
      0,
      (int sum, InventoryItem item) => sum + item.totalValue,
    );
  }
}
