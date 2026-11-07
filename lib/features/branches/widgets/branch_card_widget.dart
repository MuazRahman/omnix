import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/model/branch_model.dart';

/// Rich outlet card used by the grid view of the Branches section.
class BranchCardWidget extends StatelessWidget {
  const BranchCardWidget({
    super.key,
    required this.branch,
    required this.onSwitch,
    required this.onEdit,
    required this.onToggleActive,
    required this.onStaff,
    required this.onConfig,
  });

  final Branch branch;
  final VoidCallback onSwitch;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onStaff;
  final VoidCallback onConfig;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: branch.isCurrent
              ? AppTheme.amber.withValues(alpha: 0.55)
              : AppTheme.lightAmberWhite.withValues(alpha: 0.14),
          width: branch.isCurrent ? 1 : 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Container(height: 4, color: _accentLine()),
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: .stretch,
              spacing: 10,
              children: [
                _buildAddressRow(),
                _buildContactRow(),
                _buildSetupGrid(),
                _buildRevenueBlock(),
                _buildActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _accentLine() {
    if (branch.isCurrent) return AppTheme.amber;
    if (branch.isActive) return AppTheme.lightGreen;
    return AppTheme.badgeNeutralBackground;
  }

  Widget _buildHeader() {
    final Color tint = branch.isCloudKitchen
        ? AppTheme.lightGreen
        : (branch.isCurrent ? AppTheme.amber : AppTheme.infoBlue);

    return SizedBox(
      height: 128,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: 0.28),
                  AppTheme.sidebarBackgroundBlack,
                ],
              ),
            ),
          ),
          // large watermark icon standing in for the outlet photo
          Positioned(
            right: -14,
            top: -8,
            child: Icon(
              branch.isCloudKitchen
                  ? Icons.delivery_dining_outlined
                  : Icons.storefront_outlined,
              size: 118,
              color: tint.withValues(alpha: 0.12),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xE61C1B1B)],
                stops: [0.35, 1],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Row(
              spacing: 6,
              children: [
                _HeaderTag(
                  label: branch.isActive ? 'Active' : 'Inactive',
                  color: branch.isActive
                      ? AppTheme.lightGreen
                      : AppTheme.badgeNeutralText,
                  showDot: true,
                ),
                if (branch.isCurrent)
                  const _HeaderTag(
                    label: 'Current Terminal',
                    color: AppTheme.amber,
                  ),
                if (branch.isCloudKitchen)
                  const _HeaderTag(
                    label: 'Cloud Hub',
                    color: AppTheme.badgeNeutralText,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.topbarBackgroundBlack.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                branch.id,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppTheme.tablePrimaryText,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Row(
              crossAxisAlignment: .end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        branch.tagline.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppTheme.amber,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        branch.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: AppTheme.tablePrimaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  branch.isCurrent
                      ? Icons.verified_outlined
                      : Icons.storefront_outlined,
                  size: 22,
                  color: branch.isCurrent
                      ? AppTheme.amber
                      : AppTheme.lightAmberWhite.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow() {
    return Row(
      crossAxisAlignment: .start,
      spacing: 7,
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 15,
          color: AppTheme.tableHeaderText,
        ),
        Expanded(
          child: Text(
            branch.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.tablePrimaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow() {
    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: 6,
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 14,
                color: AppTheme.tableHeaderText,
              ),
              Flexible(
                child: Text(
                  branch.phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.badgeNeutralText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.person_outline,
          size: 14,
          color: branch.isCurrent ? AppTheme.amber : AppTheme.tableHeaderText,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            branch.manager,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.tablePrimaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetupGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: _SetupItem(
              icon: branch.isCloudKitchen
                  ? Icons.shopping_bag_outlined
                  : Icons.table_restaurant_outlined,
              label: branch.isCloudKitchen ? 'Seating Model' : 'Dine-in Setup',
              value: branch.isCloudKitchen
                  ? 'Takeaway only'
                  : '${branch.tables} Tables '
                        '(${branch.seats} Seats)',
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
          ),
          Expanded(
            child: _SetupItem(
              icon: Icons.point_of_sale_outlined,
              label: 'Lane Hardware',
              value: '${branch.posTerminals} POS Live',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBlock() {
    final bool healthy = branch.inventoryHealth >= 85;
    final Color healthColor = healthy
        ? AppTheme.lightGreen
        : (branch.inventoryHealth >= 75
              ? AppTheme.amber
              : AppTheme.dangerRedLight);

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 6,
        children: [
          Row(
            crossAxisAlignment: .end,
            children: [
              const Expanded(
                child: Text(
                  "TODAY'S REVENUE",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              Text(
                formatTakaSymbol(branch.todayRevenue),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: AppTheme.amber,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Completed Tickets',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.badgeNeutralText,
                  ),
                ),
              ),
              Text(
                '${branch.todayOrders} orders '
                '(Avg ৳${formatNumber(branch.todayAverageTicket)})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.tablePrimaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'INVENTORY HEALTH',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppTheme.tableHeaderText,
                  ),
                ),
              ),
              Text(
                '${branch.inventoryHealth.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: healthColor,
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: AppTheme.badgeNeutralBackground.withValues(alpha: 0.5),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: (branch.inventoryHealth / 100)
                    .clamp(0.0, 1.0)
                    .toDouble(),
                child: Container(color: healthColor),
              ),
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Low Stock Reorders',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.badgeNeutralText,
                  ),
                ),
              ),
              if (branch.hasLowStock)
                Row(
                  spacing: 5,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 13,
                      color: AppTheme.dangerRedLight,
                    ),
                    Text(
                      '${branch.lowStockCount} items critical',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dangerRedLight,
                      ),
                    ),
                  ],
                )
              else
                const Row(
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 13,
                      color: AppTheme.lightGreen,
                    ),
                    Text(
                      'All levels nominal',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.lightGreen,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final List<Widget> secondary = [
      _CardActionButton(
        icon: Icons.edit_outlined,
        label: 'Edit Details',
        onTap: onEdit,
      ),
      _CardActionButton(
        icon: Icons.groups_outlined,
        label: 'Staff (${branch.staffCount})',
        onTap: onStaff,
      ),
      if (branch.isCurrent)
        _CardActionButton(
          icon: Icons.settings_outlined,
          label: 'Config',
          onTap: onConfig,
        )
      else
        _CardActionButton(
          icon: branch.isActive
              ? Icons.pause_circle_outline
              : Icons.play_circle_outline,
          label: branch.isActive ? 'Deactivate' : 'Activate',
          tone: branch.isActive ? AppTheme.dangerRedLight : AppTheme.lightGreen,
          onTap: onToggleActive,
        ),
    ];

    return Column(
      crossAxisAlignment: .stretch,
      spacing: 8,
      children: [
        _buildPrimaryAction(),
        Wrap(spacing: 8, runSpacing: 8, children: secondary),
      ],
    );
  }

  Widget _buildPrimaryAction() {
    if (!branch.isActive) {
      return _PrimaryActionButton(
        icon: Icons.play_circle_outline,
        label: 'Activate This Outlet',
        onTap: onToggleActive,
      );
    }

    if (branch.isCurrent) {
      return Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.amber.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.amber.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisAlignment: .center,
          spacing: 7,
          children: [
            Icon(Icons.check_circle, size: 16, color: AppTheme.amber),
            Flexible(
              child: Text(
                'Currently Operating Here',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.amber,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _PrimaryActionButton(
      icon: Icons.sync_alt,
      label: 'Switch to this Branch',
      onTap: onSwitch,
    );
  }
}

class _SetupItem extends StatelessWidget {
  const _SetupItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Icon(icon, size: 18, color: AppTheme.tableHeaderText),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.tableHeaderText,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.tablePrimaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderTag extends StatelessWidget {
  const _HeaderTag({
    required this.label,
    required this.color,
    this.showDot = false,
  });

  final String label;
  final Color color;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          if (showDot)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.sidebarBackgroundBlack,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.amber.withValues(alpha: 0.16),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
              width: 0.6,
            ),
          ),
          child: Row(
            mainAxisAlignment: .center,
            spacing: 7,
            children: [
              Icon(icon, size: 16, color: AppTheme.badgeAmberText),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.tablePrimaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tone,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final Color foreground = tone ?? AppTheme.badgeNeutralText;

    return Material(
      color: AppTheme.topbarBackgroundBlack,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.amber.withValues(alpha: 0.08),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
              width: 0.6,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(icon, size: 14, color: foreground),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
