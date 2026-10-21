import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/main_layout_shell/controller/main_layout_shell_controller.dart';

class SidebarNavItemWidget extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;

  const SidebarNavItemWidget({
    super.key,
    required this.index,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // find the existing controller, putting a new one here would reset the
    // selected index on every rebuild
    final MainLayoutShellController controller =
        Get.find<MainLayoutShellController>();

    return Obx(() {
      bool isSelected = controller.selectedIndex.value == index;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GestureDetector(
          onTap: () => controller.changeTabIndex(index),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isSelected ? AppTheme.amber : Colors.transparent,
            ),
            child: ListTile(
              leading: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppTheme.sidebarBackgroundBlack
                    : AppTheme.lightAmberWhite,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.sidebarBackgroundBlack
                      : AppTheme.lightAmberWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
