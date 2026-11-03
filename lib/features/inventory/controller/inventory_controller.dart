import 'package:get/get.dart';
import 'package:omnix/features/inventory/dummy_data/dummy_inventory_data.dart';
import 'package:omnix/features/inventory/model/inventory_item_model.dart';

class InventoryController extends GetxController {
  // Categories of the filter chips and the Add Stock dialog. It is a mutable
  // copy of the dummy seed so the Category manager can edit it; the first
  // entry is the fixed "All" filter.
  final RxList<String> categories = <String>[
    ...DummyInventoryData.categories,
  ].obs;

  // units offered by the Add Stock dialog
  static const List<String> units = ['kg', 'g', 'L', 'pcs', 'case'];

  final selectedCategory = 0.obs;

  final searchText = ''.obs;

  final items = <InventoryItem>[].obs;

  final isLoading = false.obs;

  // Stand-in for the server while the backend is offline: fetches read from
  // this list so items added during a session survive a refetch. It is only
  // touched by the two TODO blocks below, delete it together with them.
  final List<InventoryItem> _localStore = List<InventoryItem>.of(
    DummyInventoryData.items,
  );

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
    items.assignAll(_localStore);

    isLoading.value = false;
  }

  // Saves an item created in the Add Stock dialog and re-fetches the list
  // right after, so the table, the counts and the header totals are always
  // rendered from the same source the backend will provide later.
  Future<void> addStockItem({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required double unitCost,
    required double reorderLevel,
  }) async {
    // TODO: swap for `POST /inventory/items` (body: item.toJson()) once the
    // backend is live and take the id from the response — the server owns it.
    final InventoryItem item = InventoryItem(
      id: _nextItemId(),
      name: name.trim(),
      category: category,
      quantity: quantity,
      unit: unit,
      reorderLevel: reorderLevel,
      unitCost: unitCost,
    );
    _localStore.insert(0, item);

    // Simulated round-trip so the dialog's saving state is visible. Remove
    // it together with the TODO above when the real API is wired in.
    await Future<void>.delayed(const Duration(milliseconds: 350));

    await fetchItems();
  }

  String _nextItemId() {
    int number = _localStore.length + 1;
    String id = 'ST-${number.toString().padLeft(3, '0')}';

    while (_localStore.any((InventoryItem item) => item.id == id)) {
      number++;
      id = 'ST-${number.toString().padLeft(3, '0')}';
    }

    return id;
  }

  void categoryOnChanged(int index) {
    selectedCategory.value = index;
  }

  // selectable categories, without the fixed "All" filter
  List<String> get selectableCategories => categories
      .where((String category) => category != 'All')
      .toList();

  // Category management -----------------------------------------------------
  // TODO: swap these three for the /inventory/categories endpoints once the
  // backend is live; the duplicate and last-category checks stay server-side.

  /// Adds [name] to the filter chips. Returns false when it is blank or
  /// already exists.
  bool addCategory(String name) {
    final String value = name.trim();
    if (value.isEmpty || categories.contains(value)) return false;

    categories.add(value);
    return true;
  }

  /// Renames [oldName] and moves every item filed under it. Returns false when
  /// the new name is blank, unchanged or already taken.
  bool renameCategory(String oldName, String newName) {
    final int index = categories.indexOf(oldName);
    final String value = newName.trim();

    if (index <= 0) return false;
    if (value.isEmpty || value == oldName) return false;
    if (categories.contains(value)) return false;

    categories[index] = value;
    _reassignCategory(oldName, value);
    return true;
  }

  /// Removes [name], moving any item that used it to the first remaining
  /// category so no stock row is left orphaned. The fixed "All" filter cannot
  /// be removed.
  bool removeCategory(String name) {
    final int index = categories.indexOf(name);
    if (index <= 0) return false;

    final String previous =
        categories[selectedCategory.value.clamp(0, categories.length - 1)];
    categories.removeAt(index);

    // keep at least one real bucket so items always have a home
    if (categories.length == 1) categories.add('General');
    _reassignCategory(name, categories[1]);

    // keep the filter on the same label where it still exists
    final int restored = categories.indexOf(previous);
    selectedCategory.value = restored >= 0 ? restored : 0;
    return true;
  }

  /// Number of stock rows filed under [category], shown by the manager dialog.
  int categoryUsageCount(String category) =>
      items.where((InventoryItem item) => item.category == category).length;

  void _reassignCategory(String from, String to) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].category == from) items[i] = items[i].copyWith(category: to);
    }
    for (int i = 0; i < _localStore.length; i++) {
      if (_localStore[i].category == from) {
        _localStore[i] = _localStore[i].copyWith(category: to);
      }
    }
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
  double get totalValue {
    return items.fold<double>(
      0,
      (double sum, InventoryItem item) => sum + item.totalValue,
    );
  }
}
