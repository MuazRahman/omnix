import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/features/main_layout_shell/controller/main_layout_shell_controller.dart';

import '../../../core/theme/app_theme.dart';

class MainLayoutShellScreen extends StatelessWidget {
  MainLayoutShellScreen({super.key});

  final MainLayoutShellController _controller = Get.put(MainLayoutShellController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Entire UI will set in a row
      body: Row(
        children: [

          // Left Sidebar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.black,
            ),
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Software branding
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10, width: 0.5)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.restaurant, color: AppTheme.amber,),
                        ),
                      ),
                      const SizedBox(width: 10,),

                      // Brand name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Omnix',
                            style: TextStyle(
                                color: AppTheme.lightAmberWhite,
                                fontSize: 22,
                            ),
                          ),
                          Text('Restaurant POS',
                            style: TextStyle(
                              color: AppTheme.deepAmberWhite,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Section Header
                buildSectionHeader(title: 'OPERATIONS'),

                // Operations items
                Column(
                  spacing: 8,
                  children: [
                    _buildNavItem(index: 0, icon: Icons.dashboard, title: 'Dashboard',),
                    _buildNavItem(index: 1, icon: Icons.point_of_sale, title: 'POS',),
                    _buildNavItem(index: 2, icon: Icons.list_alt, title: 'Orders',),
                    _buildNavItem(index: 3, icon: Icons.restaurant_menu, title: 'Menu',),
                  ],
                ),

                const SizedBox(height: 10),

                // Section Header
                buildSectionHeader(title: 'INVENTORY & SUPPLY'),

                // Inventory & Supply items
                Column(
                  spacing: 8,
                  children: [
                    _buildNavItem(index: 4, icon: Icons.inventory_2, title: 'Inventory',),
                    _buildNavItem(index: 5, icon: Icons.shopping_cart, title: 'Purchases',),
                  ],
                ),

                const SizedBox(height: 10),

                // Section Header
                buildSectionHeader(title: 'MANAGEMENT'),

                // Management items
                Column(
                  spacing: 8,
                  children: [
                    _buildNavItem(index: 6, icon: Icons.group, title: 'Customers',),
                    _buildNavItem(index: 7, icon: Icons.store, title: 'Branches',),
                    _buildNavItem(index: 8, icon: Icons.bar_chart, title: 'Reports',),
                    _buildNavItem(index: 9, icon: Icons.admin_panel_settings_outlined, title: 'Staff & Settings',),
                  ],
                ),


              ],
            ),
         ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      {required int index, required IconData icon, required String title}) {
    return Obx(() {
      bool isSelected = _controller.selectedIndex.value == index;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isSelected ? AppTheme.amber : Colors.transparent,
          ),
          child: ListTile(
            onTap: () {
              _controller.changeTabIndex(index);
            },
            leading: Icon(icon, size: 20, color: isSelected ? AppTheme.black : AppTheme.lightAmberWhite,),
            title: Text(title,
              style: TextStyle(
                color: isSelected ? AppTheme.black : AppTheme.lightAmberWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget buildSectionHeader({required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          color: AppTheme.lightAmberWhite.withAlpha(200),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
