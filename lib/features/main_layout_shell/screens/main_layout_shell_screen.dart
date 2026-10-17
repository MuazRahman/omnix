import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/main_layout_shell/controller/main_layout_shell_controller.dart';
import 'package:omnix/features/main_layout_shell/widgets/section_header_widget.dart';
import 'package:omnix/features/main_layout_shell/widgets/sidebar_bottom_user_card.dart';
import 'package:omnix/features/main_layout_shell/widgets/sidebar_nav_item_widget.dart';


class MainLayoutShellScreen extends StatelessWidget {
  MainLayoutShellScreen({super.key});

  final MainLayoutShellController _controller = Get.put(
      MainLayoutShellController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Entire UI will set in a row
      body: Row(
        children: [

          // Left Sidebar
          buildLeftSidebar(),

          // Right Content Window
          Expanded(
            child: Obx(() {
              return IndexedStack(
                index: _controller.selectedIndex.value,
                children: _controller.screens,
              );
            })
          ),

        ],
      ),
    );
  }

  Widget buildLeftSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.black,
        border: Border(
            right: BorderSide(
                color: AppTheme.amber.withAlpha(50),
                width: 0.5,
            ),
        ),
      ),
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Top screen Software branding name
          buildSoftwareBranding(),

          // Section Header
          SectionHeaderWidget(title: 'OPERATIONS'),

          // Operations items
          Column(
            spacing: 8,
            children: [
              SidebarNavItemWidget(
                index: 0, icon: Icons.dashboard_outlined, title: 'Dashboard',),
              SidebarNavItemWidget(
                index: 1, icon: Icons.point_of_sale_outlined, title: 'POS',),
              SidebarNavItemWidget(
                index: 2, icon: Icons.list_alt_outlined, title: 'Orders',),
              SidebarNavItemWidget(
                index: 3, icon: Icons.restaurant_menu_outlined, title: 'Menu',),
            ],
          ),

          const SizedBox(height: 10),

          // Section Header
          SectionHeaderWidget(title: 'INVENTORY & SUPPLY'),

          // Inventory & Supply items
          Column(
            spacing: 8,
            children: [
              SidebarNavItemWidget(
                index: 4, icon: Icons.inventory_2_outlined, title: 'Inventory',),
              SidebarNavItemWidget(
                index: 5, icon: Icons.shopping_cart_outlined, title: 'Purchases',),
            ],
          ),

          const SizedBox(height: 10),

          // Section Header
          SectionHeaderWidget(title: 'MANAGEMENT'),

          // Management items
          Column(
            spacing: 8,
            children: [
              SidebarNavItemWidget(
                index: 6, icon: Icons.group_outlined, title: 'Customers',),
              SidebarNavItemWidget(
                index: 7, icon: Icons.store_outlined, title: 'Branches',),
              SidebarNavItemWidget(
                index: 8, icon: Icons.bar_chart_outlined, title: 'Reports',),
              SidebarNavItemWidget(index: 9,
                icon: Icons.admin_panel_settings_outlined,
                title: 'Staff & Settings',),
            ],
          ),

          const Spacer(),

          // Sidebar bottom user card
          SidebarBottomUserCard(),


        ],
      ),
    );
  }

  Widget buildSoftwareBranding() {
    return Padding(
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
    );
  }
}


