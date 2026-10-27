import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/menu/dummy_data/dummy_menu_item_data.dart';
import 'package:omnix/features/menu/dummy_data/dummy_menu_modifier_data.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';
import 'package:omnix/features/menu/model/menu_modifier_group_model.dart';

/// Ordering options of the menu table.
enum MenuSortMode { marginHigh, priceLow, priceHigh, nameAsc }

extension MenuSortModeLabel on MenuSortMode {
  String get label {
    switch (this) {
      case MenuSortMode.marginHigh:
        return 'Margin: High to Low';
      case MenuSortMode.priceLow:
        return 'Price: Low to High';
      case MenuSortMode.priceHigh:
        return 'Price: High to Low';
      case MenuSortMode.nameAsc:
        return 'Name: A to Z';
    }
  }
}

/// How the catalog is rendered below the toolbar.
enum MenuViewMode { table, grid }

class MenuController extends GetxController {
  final List<String> categories = DummyMenuItemData.categories;

  final List<MenuModifierGroup> modifierGroups = DummyMenuModifierData.groups;

  // prep stations offered by the add-dish dialog
  static const List<String> kitchenStations = [
    'Main Kitchen',
    'Grill Station',
    'Beverage Bar',
    'Dessert Counter',
  ];

  // rows per page of the catalog table
  static const int pageSize = 8;

  // margin the kitchen aims for, used by the warning card
  static const double targetMargin = 65;

  final selectedCategory = 0.obs;

  final searchText = ''.obs;

  final menuItems = <MenuItem>[].obs;

  final isLoading = false.obs;

  final sortMode = MenuSortMode.marginHigh.obs;

  final viewMode = MenuViewMode.table.obs;

  final currentPage = 1.obs;

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
    currentPage.value = 1;
  }

  void searchOnChanged(String value) {
    searchText.value = value;
    currentPage.value = 1;
  }

  void sortOnChanged(MenuSortMode value) {
    sortMode.value = value;
    currentPage.value = 1;
  }

  void viewModeOnChanged(MenuViewMode value) {
    viewMode.value = value;
  }

  /// Adds a dish created in the quick-add dialog to the in-memory catalog.
  ///
  /// The picture is kept as bytes until the backend can store uploads. Passing
  /// [recipeCost] as `null` estimates food cost at 40% of the selling price,
  /// matching the API fallback in [MenuItem.fromJson].
  MenuItem addMenuItem({
    required String name,
    required String category,
    required int price,
    String banglaName = '',
    String kitchenStation = 'Main Kitchen',
    int? recipeCost,
    Uint8List? imageBytes,
    bool isAvailable = true,
  }) {
    final MenuItem item = MenuItem(
      id: _nextMenuId(),
      name: name.trim(),
      banglaName: banglaName.trim(),
      category: category,
      price: price,
      recipeCost: recipeCost ?? (price * 0.4).round(),
      isAvailable: isAvailable,
      branchId: DummyMenuItemData.branchId,
      imageUrl: '',
      imageBytes: imageBytes,
      kitchenStation: kitchenStation,
    );

    menuItems.insert(0, item);

    // Keep the new dish visible: switch to its category and the first page.
    final int categoryIndex = categories.indexOf(category);
    if (categoryIndex >= 0) selectedCategory.value = categoryIndex;
    currentPage.value = 1;

    _notify('Dish added', '${item.name} is now in the catalog.');

    return item;
  }

  /// Applies edits made in the dish dialog to an existing catalog row.
  ///
  /// Passing [recipeCost] as `null` re-estimates food cost at 40% of the new
  /// selling price, matching [addMenuItem]. [imageBytes] replaces the current
  /// picture; passing `null` clears a locally picked one and falls back to
  /// [MenuItem.imageUrl].
  MenuItem? updateMenuItem(
    MenuItem item, {
    required String name,
    required String category,
    required int price,
    String banglaName = '',
    String kitchenStation = 'Main Kitchen',
    int? recipeCost,
    Uint8List? imageBytes,
    required bool isAvailable,
  }) {
    final int index = menuItems.indexWhere((MenuItem row) => row.id == item.id);
    if (index == -1) return null;

    final MenuItem updated = MenuItem(
      id: item.id,
      name: name.trim(),
      banglaName: banglaName.trim(),
      category: category,
      price: price,
      recipeCost: recipeCost ?? (price * 0.4).round(),
      isAvailable: isAvailable,
      branchId: item.branchId,
      imageUrl: item.imageUrl,
      imageBytes: imageBytes,
      isLowStock: isAvailable ? item.isLowStock : false,
      isBestseller: item.isBestseller,
      modifierCount: item.modifierCount,
      modifierSummary: item.modifierSummary,
      soldToday: item.soldToday,
      preparationTime: item.preparationTime,
      kitchenStation: kitchenStation,
    );

    menuItems[index] = updated;

    _notify('Dish updated', '${updated.name} was saved to the catalog.');

    return updated;
  }

  String _nextMenuId() {
    final RegExp trailingNumber = RegExp(r'(\d+)$');
    int highest = 0;

    for (final MenuItem item in menuItems) {
      final RegExpMatch? match = trailingNumber.firstMatch(item.id);
      final int number = int.tryParse(match?.group(1) ?? '') ?? 0;
      highest = math.max(highest, number);
    }

    return 'M-${(highest + 1).toString().padLeft(3, '0')}';
  }

  void goToPage(int page) {
    currentPage.value = page.clamp(1, pageCount);
  }

  void nextPage() => goToPage(currentPage.value + 1);

  void previousPage() => goToPage(currentPage.value - 1);

  // items matching the current category and the search text, then sorted
  List<MenuItem> get filteredItems {
    final String query = searchText.value.trim().toLowerCase();
    final String category = categories[selectedCategory.value];

    final List<MenuItem> items = menuItems.where((MenuItem item) {
      final bool matchesCategory =
          category == 'All' || item.category == category;
      final bool matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.banglaName.toLowerCase().contains(query) ||
          item.id.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();

    switch (sortMode.value) {
      case MenuSortMode.marginHigh:
        items.sort((MenuItem a, MenuItem b) {
          final int byMargin = b.grossMargin.compareTo(a.grossMargin);
          return byMargin != 0 ? byMargin : a.name.compareTo(b.name);
        });
      case MenuSortMode.priceLow:
        items.sort((MenuItem a, MenuItem b) => a.price.compareTo(b.price));
      case MenuSortMode.priceHigh:
        items.sort((MenuItem a, MenuItem b) => b.price.compareTo(a.price));
      case MenuSortMode.nameAsc:
        items.sort(
          (MenuItem a, MenuItem b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }

    return items;
  }

  // rows of the current page, the table and the grid share the pagination
  List<MenuItem> get pagedItems {
    final List<MenuItem> items = filteredItems;
    if (items.isEmpty) return const [];

    final int start = (currentPage.value - 1) * pageSize;
    final int end = math.min(start + pageSize, items.length);

    if (start >= items.length) return const [];
    return items.sublist(start, end);
  }

  int get pageCount {
    final int count = filteredItems.length;
    return count == 0 ? 1 : (count / pageSize).ceil();
  }

  int get rangeStart {
    if (filteredItems.isEmpty) return 0;
    return ((currentPage.value - 1) * pageSize) + 1;
  }

  int get rangeEnd =>
      math.min(currentPage.value * pageSize, filteredItems.length);

  int countForCategory(String category) {
    if (category == 'All') return menuItems.length;
    return menuItems.where((MenuItem item) => item.category == category).length;
  }

  int get activeCount {
    return menuItems.where((MenuItem item) => item.isAvailable).length;
  }

  int get unavailableCount => menuItems.length - activeCount;

  int get lowStockCount {
    return menuItems.where((MenuItem item) => item.isLowStock).length;
  }

  int get soldOutCount {
    return menuItems.where((MenuItem item) => !item.isAvailable).length;
  }

  int get alertCount => lowStockCount + soldOutCount;

  // average gross margin across the catalog, shown in the stat ribbon
  double get averageMargin {
    if (menuItems.isEmpty) return 0;

    final double total = menuItems.fold<double>(
      0,
      (double sum, MenuItem item) => sum + item.grossMargin,
    );
    return total / menuItems.length;
  }

  Map<String, int> get categoryRevenue {
    final Map<String, int> revenue = <String, int>{};

    for (final MenuItem item in menuItems) {
      final int value = item.price * item.soldToday;
      revenue.update(
        item.category,
        (int current) => current + value,
        ifAbsent: () => value,
      );
    }

    return revenue;
  }

  String get topCategoryName {
    final Map<String, int> revenue = categoryRevenue;
    if (revenue.isEmpty) return '—';

    return revenue.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  int get topCategoryRevenue {
    final Map<String, int> revenue = categoryRevenue;
    if (revenue.isEmpty) return 0;

    return revenue.values.reduce((int a, int b) => math.max(a, b));
  }

  double get topCategoryShare {
    final int total = menuItems.fold<int>(
      0,
      (int sum, MenuItem item) => sum + (item.price * item.soldToday),
    );
    if (total == 0) return 0;

    return (topCategoryRevenue / total) * 100;
  }

  // dish furthest below the target margin, highlighted by the warning card
  MenuItem? get worstMarginItem {
    if (menuItems.isEmpty) return null;

    return menuItems.reduce(
      (MenuItem a, MenuItem b) => a.grossMargin <= b.grossMargin ? a : b,
    );
  }

  // price needed to bring a dish back to [targetMargin]
  int suggestedPriceFor(MenuItem item) {
    if (targetMargin >= 100) return item.price;
    final double price = item.recipeCost / (1 - (targetMargin / 100));
    return price.ceil();
  }

  void toggleAvailability(MenuItem item) {
    final int index = menuItems.indexWhere((MenuItem row) => row.id == item.id);
    if (index == -1) return;

    final bool nextAvailable = !item.isAvailable;
    menuItems[index] = item.copyWith(
      isAvailable: nextAvailable,
      isLowStock: nextAvailable ? item.isLowStock : false,
    );

    _notify(
      nextAvailable ? 'Dish is live' : 'Dish paused',
      nextAvailable
          ? '${item.name} is available on the POS again.'
          : '${item.name} is hidden from new POS tickets.',
      isError: !nextAvailable,
    );
  }

  void duplicateItem(MenuItem item) {
    final int index = menuItems.indexWhere((MenuItem row) => row.id == item.id);
    if (index == -1) return;

    final MenuItem copy = item.copyWith(
      id: '${item.id}-C${menuItems.length + 1}',
      name: '${item.name} (Copy)',
      isBestseller: false,
      soldToday: 0,
    );

    menuItems.insert(index + 1, copy);
    _notify('Dish duplicated', '${item.name} was copied as ${copy.name}.');
  }

  void archiveItem(MenuItem item) {
    menuItems.removeWhere((MenuItem row) => row.id == item.id);
    goToPage(currentPage.value);
    _notify('Dish archived', '${item.name} was removed from the active menu.');
  }

  // Used by the header and insight cards until the real editor is wired.
  void showComingSoon(String feature) {
    _notify(
      '$feature is not wired yet',
      'This demo screen keeps the action local.',
    );
  }

  void broadcastModifiers() {
    _notify(
      'Modifiers broadcast',
      'Pricing and availability were pushed to every POS terminal.',
    );
  }

  void _notify(String title, String message, {bool isError = false}) {
    if (Get.context == null) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.sidebarBackgroundBlack,
      colorText: AppTheme.lightAmberWhite,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
      shouldIconPulse: false,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: isError ? AppTheme.dangerRedLight : AppTheme.lightGreen,
        size: 20,
      ),
    );
  }
}
