import 'package:flutter/material.dart' hide MenuController;
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';
import 'package:omnix/features/menu/model/menu_modifier_group_model.dart';

/// Right-side drawer that previews and edits the global modifier presets.
class MenuModifierDrawerWidget extends StatelessWidget {
  const MenuModifierDrawerWidget({super.key, required this.controller});

  final MenuController controller;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 420,
      backgroundColor: AppTheme.windowWidgetBackgroundBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: .stretch,
                  spacing: 12,
                  children: [
                    const Text(
                      'Changes to modifier pricing and availability update '
                      'instantly across POS terminals during active service.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.45,
                        color: AppTheme.badgeNeutralText,
                      ),
                    ),
                    ...controller.modifierGroups.map(
                      (MenuModifierGroup group) =>
                          _ModifierGroupCard(group: group),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          controller.showComingSoon('New modifier group'),
                      icon: const Icon(Icons.add_circle_outline, size: 17),
                      label: const Text('Create New Modifier Group'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.badgeAmberText,
                        side: BorderSide(
                          color: AppTheme.lightAmberWhite.withValues(
                            alpha: 0.2,
                          ),
                          width: 0.6,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        spacing: 8,
        children: [
          const Icon(Icons.tune, size: 21, color: AppTheme.amber),
          Expanded(
            child: Text(
              'Modifier Groups (${controller.modifierGroups.length})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.tablePrimaryText,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 19),
            color: AppTheme.tableHeaderText,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: .end,
        spacing: 8,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.tablePrimaryText,
              backgroundColor: AppTheme.badgeNeutralBackground.withValues(
                alpha: 0.45,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.broadcastModifiers();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.amber,
              foregroundColor: AppTheme.windowWidgetBackgroundBlack,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save & Broadcast'),
          ),
        ],
      ),
    );
  }
}

class _ModifierGroupCard extends StatelessWidget {
  const _ModifierGroupCard({required this.group});

  final MenuModifierGroup group;

  @override
  Widget build(BuildContext context) {
    final Color ruleColor = group.isMandatory
        ? AppTheme.lightGreen
        : (group.multiSelect
              ? AppTheme.badgeAmberText
              : AppTheme.badgeNeutralText);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBackgroundBlack.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.12),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.tablePrimaryText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ruleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  group.ruleLabel,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: ruleColor,
                  ),
                ),
              ),
            ],
          ),
          ...group.options.map(
            (MenuModifierOption option) => _ModifierOptionRow(option: option),
          ),
        ],
      ),
    );
  }
}

class _ModifierOptionRow extends StatelessWidget {
  const _ModifierOptionRow({required this.option});

  final MenuModifierOption option;

  @override
  Widget build(BuildContext context) {
    final bool isPaid = option.priceDelta > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.tablePrimaryText,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+৳ ${formatNumber(option.priceDelta)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isPaid ? FontWeight.w700 : FontWeight.w400,
              color: isPaid
                  ? AppTheme.badgeAmberText
                  : AppTheme.tableHeaderText,
            ),
          ),
        ],
      ),
    );
  }
}
