import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/orders/controller/order_controller.dart';
import 'package:omnix/features/orders/model/order_model.dart';

/// Status tabs, search and the channel / payment filters.
class OrdersFilterBarWidget extends StatelessWidget {
  const OrdersFilterBarWidget({
    super.key,
    required this.orderController,
    required this.searchController,
    required this.searchFocusNode,
  });

  final OrderController orderController;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Widget tabs = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 6,
          children: OrderFilter.values
              .map((OrderFilter filter) {
                return _StatusTab(
                  filter: filter,
                  count: orderController.countForFilter(filter),
                  selected: orderController.selectedFilter.value == filter,
                  onTap: () => orderController.filterOnChanged(filter),
                );
              })
              .toList(growable: false),
        ),
      );

      final Widget search = SizedBox(
        height: 34,
        child: TextField(
          controller: searchController,
          focusNode: searchFocusNode,
          onChanged: orderController.searchOnChanged,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.deny(RegExp(r'\n')),
          ],
          style: const TextStyle(
            fontSize: 12.5,
            color: AppTheme.lightAmberWhite,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppTheme.topbarBackgroundBlack,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            prefixIcon: Icon(
              Icons.search,
              size: 17,
              color: AppTheme.tableHeaderText.withValues(alpha: 0.9),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 0,
            ),
            suffixIcon: orderController.searchText.value.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      searchController.clear();
                      orderController.searchOnChanged('');
                    },
                    icon: const Icon(Icons.close, size: 14),
                    color: AppTheme.tableHeaderText,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: 'Clear search',
                  ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 0,
            ),
            hintText: 'Order #, guest, item or table...',
            hintStyle: TextStyle(
              fontSize: 11.5,
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.35),
            ),
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(color: AppTheme.amber, width: 0.8),
          ),
        ),
      );

      final Widget channelChip = _ChannelFilterChip(
        selected: orderController.selectedChannel.value,
        onChanged: orderController.channelOnChanged,
      );

      final Widget paymentChip = _PaymentFilterChip(
        selected: orderController.selectedPaymentStatus.value,
        onChanged: orderController.paymentStatusOnChanged,
      );

      final Widget? clearButton = orderController.hasActiveFilters
          ? Tooltip(
              message: 'Clear all filters',
              child: Material(
                color: AppTheme.dangerRed.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(7),
                child: InkWell(
                  onTap: () {
                    searchController.clear();
                    orderController.clearFilters();
                  },
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: AppTheme.dangerRed.withValues(alpha: 0.3),
                        width: 0.6,
                      ),
                    ),
                    child: const Icon(
                      Icons.filter_alt_off_outlined,
                      size: 15,
                      color: AppTheme.dangerRedLight,
                    ),
                  ),
                ),
              ),
            )
          : null;

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.windowWidgetBackgroundBlack,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.14),
            width: 0.6,
          ),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth >= 960) {
              return Row(
                children: [
                  Expanded(child: tabs),
                  const SizedBox(width: 12),
                  SizedBox(width: 240, child: search),
                  const SizedBox(width: 8),
                  channelChip,
                  const SizedBox(width: 8),
                  paymentChip,
                  if (clearButton != null) ...[
                    const SizedBox(width: 8),
                    clearButton,
                  ],
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 34, child: tabs),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: 8),
                    channelChip,
                    const SizedBox(width: 8),
                    paymentChip,
                    if (clearButton != null) ...[
                      const SizedBox(width: 8),
                      clearButton,
                    ],
                  ],
                ),
              ],
            );
          },
        ),
      );
    });
  }

  OutlineInputBorder _border({Color? color, double width = 0.6}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(
        color: color ?? AppTheme.lightAmberWhite.withValues(alpha: 0.14),
        width: width,
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  const _StatusTab({
    required this.filter,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final OrderFilter filter;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor = selected
        ? AppTheme.windowWidgetBackgroundBlack
        : AppTheme.lightAmberWhite.withValues(alpha: 0.72);

    return Material(
      color: selected ? AppTheme.amber : AppTheme.topbarBackgroundBlack,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        hoverColor: AppTheme.amber.withValues(alpha: 0.08),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: selected
                  ? AppTheme.amber
                  : AppTheme.lightAmberWhite.withValues(alpha: 0.14),
              width: 0.6,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              if (filter == OrderFilter.live && !selected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppTheme.amber,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                filter.label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.windowWidgetBackgroundBlack.withValues(
                          alpha: 0.14,
                        )
                      : AppTheme.sidebarBackgroundBlack,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? AppTheme.windowWidgetBackgroundBlack
                        : AppTheme.tableHeaderText,
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

class _ChannelFilterChip extends StatelessWidget {
  const _ChannelFilterChip({required this.selected, required this.onChanged});

  final OrderChannel? selected;
  final ValueChanged<OrderChannel?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Filter by order type',
      color: AppTheme.sidebarBackgroundBlack,
      position: PopupMenuPosition.under,
      onSelected: (String value) {
        if (value == 'all') {
          onChanged(null);
          return;
        }

        onChanged(
          OrderChannel.values.firstWhere(
            (OrderChannel channel) => channel.name == value,
          ),
        );
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          _menuItem('all', 'All channels', selected == null),
          ...OrderChannel.values.map((OrderChannel channel) {
            return _menuItem(channel.name, channel.label, selected == channel);
          }),
        ];
      },
      child: _FilterChipBody(
        icon: selected == null ? Icons.storefront_outlined : Icons.storefront,
        label: selected?.label ?? 'All channels',
        active: selected != null,
        trailing: Icons.keyboard_arrow_down,
      ),
    );
  }
}

class _PaymentFilterChip extends StatelessWidget {
  const _PaymentFilterChip({required this.selected, required this.onChanged});

  final PaymentStatus? selected;
  final ValueChanged<PaymentStatus?> onChanged;

  static const List<PaymentStatus> _options = <PaymentStatus>[
    PaymentStatus.paid,
    PaymentStatus.unpaid,
    PaymentStatus.refunded,
    PaymentStatus.voided,
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Filter by payment state',
      color: AppTheme.sidebarBackgroundBlack,
      position: PopupMenuPosition.under,
      onSelected: (String value) {
        if (value == 'all') {
          onChanged(null);
          return;
        }

        onChanged(
          PaymentStatus.values.firstWhere(
            (PaymentStatus status) => status.name == value,
          ),
        );
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          _menuItem('all', 'All payments', selected == null),
          ..._options.map((PaymentStatus status) {
            return _menuItem(status.name, status.label, selected == status);
          }),
        ];
      },
      child: _FilterChipBody(
        icon: Icons.payments_outlined,
        label: selected?.label ?? 'All payments',
        active: selected != null,
        trailing: Icons.keyboard_arrow_down,
      ),
    );
  }
}

PopupMenuItem<String> _menuItem(String value, String label, bool selected) {
  return PopupMenuItem<String>(
    value: value,
    height: 38,
    child: Row(
      spacing: 8,
      children: [
        Icon(
          selected ? Icons.check : Icons.remove,
          size: 14,
          color: selected ? AppTheme.amber : Colors.transparent,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppTheme.amber : AppTheme.lightAmberWhite,
          ),
        ),
      ],
    ),
  );
}

class _FilterChipBody extends StatelessWidget {
  const _FilterChipBody({
    required this.icon,
    required this.label,
    required this.active,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final bool active;
  final IconData trailing;

  @override
  Widget build(BuildContext context) {
    final Color color = active
        ? AppTheme.amber
        : AppTheme.lightAmberWhite.withValues(alpha: 0.72);

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.topbarBackgroundBlack,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: active
              ? AppTheme.amber.withValues(alpha: 0.5)
              : AppTheme.lightAmberWhite.withValues(alpha: 0.14),
          width: active ? 0.8 : 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Icon(icon, size: 14, color: color),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
          Icon(trailing, size: 15, color: AppTheme.tableHeaderText),
        ],
      ),
    );
  }
}
