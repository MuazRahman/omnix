import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';
import 'package:omnix/features/menu/widgets/menu_add_dish_dialog_widget.dart';
import 'package:omnix/features/menu/widgets/menu_filter_bar_widget.dart';
import 'package:omnix/features/menu/widgets/menu_grid_view_widget.dart';
import 'package:omnix/features/menu/widgets/menu_header_widget.dart';
import 'package:omnix/features/menu/widgets/menu_insight_cards_widget.dart';
import 'package:omnix/features/menu/widgets/menu_modifier_drawer_widget.dart';
import 'package:omnix/features/menu/widgets/menu_stat_ribbon_widget.dart';
import 'package:omnix/features/menu/widgets/menu_table_widget.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();
    final MenuController menuController = Get.find<MenuController>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.topbarBackgroundBlack,
      endDrawer: MenuModifierDrawerWidget(controller: menuController),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            // Global app bar
            TopBarWidget(branchController: branchController),

            // Breadcrumb, title and quick actions
            MenuHeaderWidget(
              modifierGroupCount: menuController.modifierGroups.length,
              onBulkImport: () => menuController.showComingSoon('Bulk import'),
              onOpenModifiers: () => _scaffoldKey.currentState?.openEndDrawer(),
              onAddDish: () => showMenuAddDishDialog(context, menuController),
            ),

            const SizedBox(height: 10),

            // Catalog health metrics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MenuStatRibbonWidget(controller: menuController),
            ),

            const SizedBox(height: 12),

            // Category chips, search, branch, sort and view mode
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MenuFilterBarWidget(
                controller: menuController,
                branchController: branchController,
                onManageCategories: () =>
                    menuController.showComingSoon('Category manager'),
              ),
            ),

            const SizedBox(height: 12),

            // Catalog in table or card form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final bool isTable =
                    menuController.viewMode.value == MenuViewMode.table;

                if (isTable) {
                  return MenuTableWidget(
                    controller: menuController,
                    onEdit: _editDish,
                    onDuplicate: menuController.duplicateItem,
                    onArchive: menuController.archiveItem,
                    onToggleAvailability: menuController.toggleAvailability,
                  );
                }

                return MenuGridViewWidget(
                  controller: menuController,
                  onEdit: _editDish,
                  onDuplicate: menuController.duplicateItem,
                  onArchive: menuController.archiveItem,
                  onToggleAvailability: menuController.toggleAvailability,
                );
              }),
            ),

            const SizedBox(height: 16),

            // Branch pricing, margin watch and modifier presets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MenuInsightCardsWidget(
                controller: menuController,
                onOpenModifiers: () =>
                    _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _editDish(MenuItem item) {
    Get.find<MenuController>().showComingSoon('Dish editor');
  }
}
