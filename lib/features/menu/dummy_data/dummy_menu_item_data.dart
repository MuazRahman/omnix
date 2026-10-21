import 'package:omnix/features/menu/model/menu_item_model.dart';

/// Temporary data for the Menu section.
///
/// Delete this file once the backend returns real menu items.
class DummyMenuItemData {
  const DummyMenuItemData._();

  static const List<String> categories = [
    'All',
    'Starters',
    'Main Course',
    'Rice',
    'Dessert',
    'Drinks',
  ];

  static const List<MenuItem> menuItems = [
    MenuItem(
      id: 'M-001',
      name: 'Chicken Wings',
      category: 'Starters',
      price: 320,
      isAvailable: true,
      preparationTime: 12,
    ),
    MenuItem(
      id: 'M-002',
      name: 'Caesar Salad',
      category: 'Starters',
      price: 280,
      isAvailable: true,
      preparationTime: 8,
    ),
    MenuItem(
      id: 'M-003',
      name: 'Garlic Bread',
      category: 'Starters',
      price: 180,
      isAvailable: true,
      preparationTime: 6,
    ),
    MenuItem(
      id: 'M-004',
      name: 'Beef Burger',
      category: 'Main Course',
      price: 420,
      isAvailable: true,
      preparationTime: 15,
    ),
    MenuItem(
      id: 'M-005',
      name: 'Chicken Pizza',
      category: 'Main Course',
      price: 550,
      isAvailable: true,
      preparationTime: 18,
    ),
    MenuItem(
      id: 'M-006',
      name: 'Grilled Steak',
      category: 'Main Course',
      price: 780,
      isAvailable: false,
      preparationTime: 25,
    ),
    MenuItem(
      id: 'M-007',
      name: 'Fish and Chips',
      category: 'Main Course',
      price: 520,
      isAvailable: true,
      preparationTime: 20,
    ),
    MenuItem(
      id: 'M-008',
      name: 'Mushroom Pizza',
      category: 'Main Course',
      price: 590,
      isAvailable: true,
      preparationTime: 18,
    ),
    MenuItem(
      id: 'M-009',
      name: 'Fried Rice',
      category: 'Rice',
      price: 260,
      isAvailable: true,
      preparationTime: 14,
    ),
    MenuItem(
      id: 'M-010',
      name: 'Biryani',
      category: 'Rice',
      price: 340,
      isAvailable: true,
      preparationTime: 22,
    ),
    MenuItem(
      id: 'M-011',
      name: 'Mashed Potato',
      category: 'Rice',
      price: 180,
      isAvailable: true,
      preparationTime: 10,
    ),
    MenuItem(
      id: 'M-012',
      name: 'Chocolate Cake',
      category: 'Dessert',
      price: 240,
      isAvailable: true,
      preparationTime: 5,
    ),
    MenuItem(
      id: 'M-013',
      name: 'Cold Coffee',
      category: 'Dessert',
      price: 200,
      isAvailable: true,
      preparationTime: 4,
    ),
    MenuItem(
      id: 'M-014',
      name: 'Lemon Tea',
      category: 'Drinks',
      price: 120,
      isAvailable: true,
      preparationTime: 3,
    ),
    MenuItem(
      id: 'M-015',
      name: 'Coke',
      category: 'Drinks',
      price: 80,
      isAvailable: true,
      preparationTime: 2,
    ),
  ];
}
