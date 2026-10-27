import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';
import 'package:omnix/features/menu/model/menu_modifier_group_model.dart';

/// Three supporting cards below the catalog: branch pricing, margin watch,
/// and the modifier presets.
class MenuInsightCardsWidget extends StatelessWidget {
  const MenuInsightCardsWidget({
    super.key,
    required this.controller,
    required this.onOpenModifiers,
  });

  final MenuController controller;
  final VoidCallback onOpenModifiers;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final MenuItem? worstMarginItem = controller.worstMarginItem;

      final List<Widget> cards = [
        const _BranchSyncCard(),
        _MarginWarningCard(
          item: worstMarginItem,
          targetMargin: MenuController.targetMargin,
          suggestedPrice: worstMarginItem == null
              ? null
              : controller.suggestedPriceFor(worstMarginItem),
          onRecalculate: () =>
              controller.showComingSoon('Recipe cost recalculation'),
        ),
        _ModifierPresetsCard(
          groups: controller.modifierGroups,
          onOpenModifiers: onOpenModifiers,
        ),
      ];

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double gap = 12;

          if (constraints.maxWidth >= 1180) {
            return Row(
              crossAxisAlignment: .start,
              spacing: gap,
              children: cards
                  .map((Widget card) => Expanded(child: card))
                  .toList(),
            );
          }

          if (constraints.maxWidth >= 760) {
            final double width = (constraints.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: cards
                  .map((Widget card) => SizedBox(width: width, child: card))
                  .toList(),
            );
          }

          return Column(
            crossAxisAlignment: .stretch,
            spacing: gap,
            children: cards,
          );
        },
      );
    });
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.windowWidgetBackgroundBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
            width: 0.6,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _BranchSyncCard extends StatelessWidget {
  const _BranchSyncCard();

  @override
  Widget build(BuildContext context) {
    return _InsightCard(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'BRANCH SYNC MATRIX',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              _StatusDot(label: 'Auto-sync on', color: AppTheme.lightGreen),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Location Price Overrides',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.tablePrimaryText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'DHK-01 keeps standard rates. Dhaka Hub carries a +10% service '
            'premium on rice and grill SKUs.',
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: AppTheme.badgeNeutralText,
            ),
          ),
          const SizedBox(height: 12),
          const _BranchPriceRow(
            name: 'Main Branch (DHK-01)',
            badge: 'Base Price',
            color: AppTheme.badgeAmberText,
          ),
          const SizedBox(height: 6),
          const _BranchPriceRow(
            name: 'Dhaka Branch (DHK-02)',
            badge: '+10.0% Premium',
            color: AppTheme.lightGreen,
          ),
          const SizedBox(height: 6),
          const _BranchPriceRow(
            name: 'Khulna Branch (KHL-01)',
            badge: 'Delivery Standard',
            color: AppTheme.badgeNeutralText,
          ),
        ],
      ),
    );
  }
}

class _BranchPriceRow extends StatelessWidget {
  const _BranchPriceRow({
    required this.name,
    required this.badge,
    required this.color,
  });

  final String name;
  final String badge;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBackgroundBlack.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 15,
            color: AppTheme.tableHeaderText,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.tablePrimaryText,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarginWarningCard extends StatelessWidget {
  const _MarginWarningCard({
    required this.item,
    required this.targetMargin,
    required this.suggestedPrice,
    required this.onRecalculate,
  });

  final MenuItem? item;
  final double targetMargin;
  final int? suggestedPrice;
  final VoidCallback onRecalculate;

  @override
  Widget build(BuildContext context) {
    final MenuItem? dish = item;
    final double margin = dish?.grossMargin ?? 0;
    final bool belowTarget = margin < targetMargin;

    return _InsightCard(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'MARGIN WARNING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              Icon(
                Icons.show_chart,
                size: 18,
                color: belowTarget
                    ? AppTheme.dangerRedLight
                    : AppTheme.lightGreen,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Raw Ingredient Impact',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.tablePrimaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dish == null
                ? 'No dish is below the target margin right now.'
                : '${dish.name} is the thinnest margin after the latest '
                      'recipe cost update.',
            style: const TextStyle(
              fontSize: 11,
              height: 1.4,
              color: AppTheme.badgeNeutralText,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.sidebarBackgroundBlack.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Target margin',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.badgeNeutralText,
                        ),
                      ),
                    ),
                    Text(
                      '${targetMargin.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.lightGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 6,
                    color: AppTheme.badgeNeutralBackground.withValues(
                      alpha: 0.5,
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (margin / 100).clamp(0.0, 1.0).toDouble(),
                      child: Container(
                        color: belowTarget
                            ? AppTheme.amber
                            : AppTheme.lightGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Actual: ${margin.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: belowTarget
                              ? AppTheme.dangerRedLight
                              : AppTheme.lightGreen,
                        ),
                      ),
                    ),
                    if (suggestedPrice != null)
                      Text(
                        'Suggested: ${formatTakaSymbol(suggestedPrice!)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.badgeAmberText,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onRecalculate,
            icon: const Icon(Icons.calculate_outlined, size: 15),
            label: const Text('Recalculate Dish Margins'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.badgeAmberText,
              side: BorderSide(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
                width: 0.6,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModifierPresetsCard extends StatelessWidget {
  const _ModifierPresetsCard({
    required this.groups,
    required this.onOpenModifiers,
  });

  final List<MenuModifierGroup> groups;
  final VoidCallback onOpenModifiers;

  @override
  Widget build(BuildContext context) {
    final List<MenuModifierGroup> preview = groups.take(2).toList();

    return _InsightCard(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'MODIFIER GROUPS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              TextButton(
                onPressed: onOpenModifiers,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                child: const Text('+ NEW GROUP'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Active Add-On Presets',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.tablePrimaryText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Reusable option groups applied across POS terminals and the '
            'online menu.',
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: AppTheme.badgeNeutralText,
            ),
          ),
          const SizedBox(height: 12),
          ...preview.map(
            (MenuModifierGroup group) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _ModifierPresetRow(group: group),
            ),
          ),
          const Spacer(),
          Text(
            '${groups.length} groups · '
            '${groups.fold<int>(0, (int sum, MenuModifierGroup group) => sum + group.dishCount)} '
            'dish links',
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModifierPresetRow extends StatelessWidget {
  const _ModifierPresetRow({required this.group});

  final MenuModifierGroup group;

  @override
  Widget build(BuildContext context) {
    final String options = group.options
        .take(2)
        .map((MenuModifierOption option) {
          if (option.priceDelta == 0) return option.name;
          return '${option.name} (+৳${formatNumber(option.priceDelta)})';
        })
        .join(', ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBackgroundBlack.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.tablePrimaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  options,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.badgeNeutralBackground.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${group.dishCount} dishes',
              style: const TextStyle(
                fontSize: 9,
                color: AppTheme.badgeNeutralText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
