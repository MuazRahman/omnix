import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/features/branches/screens/branches_screen.dart';
import 'package:omnix/features/customers/screens/customers_screen.dart';
import 'package:omnix/features/dashboard/screens/dashboard_screen.dart';
import 'package:omnix/features/inventory/screens/inventory_screen.dart';
import 'package:omnix/features/menu/screens/menu_screen.dart';
import 'package:omnix/features/orders/screens/orders_screen.dart';
import 'package:omnix/features/pos/screens/pos_screen.dart';
import 'package:omnix/features/purchases/screens/purchases_screen.dart';
import 'package:omnix/features/reports/screens/reports_screen.dart';
import 'package:omnix/features/staff/screens/staff_settings_screen.dart';

class MainLayoutShellController extends GetxController {
  RxInt selectedIndex = 0.obs;

  // index of every section, the order must match the screens list
  static const int dashboardIndex = 0;
  static const int posIndex = 1;
  static const int ordersIndex = 2;
  static const int menuIndex = 3;
  static const int inventoryIndex = 4;
  static const int purchasesIndex = 5;
  static const int customersIndex = 6;
  static const int branchesIndex = 7;
  static const int reportsIndex = 8;
  static const int staffIndex = 9;

  // one screen per sidebar item, the order must match the sidebar index
  final List<Widget> screens = [
    const DashboardScreen(),
    const PosScreen(),
    const OrdersScreen(),
    const MenuScreen(),
    const InventoryScreen(),
    const PurchasesScreen(),
    const CustomersScreen(),
    const BranchesScreen(),
    const ReportsScreen(),
    const StaffSettingsScreen(),
  ];

  // Method to update index when a sidebar item is clicked
  void changeTabIndex(int index) {
    // ignore clicks that point past the last screen
    if (index < 0 || index >= screens.length) return;
    selectedIndex.value = index;
  }

  // switches to a section, used by the "See All" links of the dashboard
  void navigateTo(int index) {
    changeTabIndex(index);
  }
}
