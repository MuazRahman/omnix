import 'package:get/get.dart';
import 'package:omnix/features/menu/dummy_data/dummy_menu_item_data.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';

class MenuController extends GetxController {
  final List<String> categories = DummyMenuItemData.categories;

  final selectedCategory = 0.obs;

  final searchText = ''.obs;

  final menuItems = <MenuItem>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMenuItems();
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchMenuItems() async {
    isLoading.value = true;

    // swap this for the API call, the shape stays the same
    // final response = await api.get('/menu/items');
    // menuItems.assignAll(
    //   (response as List)
    //       .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    menuItems.assignAll(DummyMenuItemData.menuItems);

    isLoading.value = false;
  }

  void categoryOnChanged(int index) {
    selectedCategory.value = index;
  }

  void searchOnChanged(String value) {
    searchText.value = value;
  }

  // items matching the current category and the search text
  List<MenuItem> get filteredItems {
    final String query = searchText.value.trim().toLowerCase();
    final String category = categories[selectedCategory.value];

    return menuItems.where((MenuItem item) {
      final bool matchesCategory =
          category == 'All' || item.category == category;
      final bool matchesSearch =
          query.isEmpty || item.name.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get availableCount {
    return menuItems.where((MenuItem item) => item.isAvailable).length;
  }

  int get unavailableCount {
    return menuItems.where((MenuItem item) => !item.isAvailable).length;
  }
}
