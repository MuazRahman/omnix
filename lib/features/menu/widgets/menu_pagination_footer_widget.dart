import 'package:flutter/material.dart' hide MenuController;
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';

/// Pagination strip shared by the table and grid catalog views.
class MenuPaginationFooter extends StatelessWidget {
  const MenuPaginationFooter({super.key, required this.controller});

  final MenuController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightAmberWhite.withValues(alpha: 0.1),
            width: 0.6,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget summary = Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Text(
                'Showing ${controller.rangeStart}–${controller.rangeEnd} '
                'of ${controller.filteredItems.length} dishes',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.badgeNeutralText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.badgeNeutralBackground.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Page ${controller.currentPage.value} of '
                  '${controller.pageCount}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.badgeAmberText,
                  ),
                ),
              ),
            ],
          );

          final Widget pager = Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _PagerButton(
                label: 'Prev',
                onTap: controller.currentPage.value > 1
                    ? controller.previousPage
                    : null,
              ),
              ...List.generate(controller.pageCount, (int index) {
                final int page = index + 1;
                return _PagerButton(
                  label: '$page',
                  isCurrent: page == controller.currentPage.value,
                  onTap: () => controller.goToPage(page),
                );
              }),
              _PagerButton(
                label: 'Next',
                onTap: controller.currentPage.value < controller.pageCount
                    ? controller.nextPage
                    : null,
              ),
            ],
          );

          if (constraints.maxWidth >= 720) {
            return Row(
              children: [
                Expanded(child: summary),
                pager,
              ],
            );
          }

          return Column(
            crossAxisAlignment: .start,
            spacing: 8,
            children: [
              summary,
              Align(alignment: .centerRight, child: pager),
            ],
          );
        },
      ),
    );
  }
}

class _PagerButton extends StatelessWidget {
  const _PagerButton({required this.label, this.onTap, this.isCurrent = false});

  final String label;
  final VoidCallback? onTap;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;

    return Material(
      color: isCurrent
          ? AppTheme.amber
          : AppTheme.badgeNeutralBackground.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 26,
          constraints: const BoxConstraints(minWidth: 27),
          padding: const EdgeInsets.symmetric(horizontal: 7),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
              color: isCurrent
                  ? AppTheme.windowWidgetBackgroundBlack
                  : (isEnabled
                        ? AppTheme.tablePrimaryText
                        : AppTheme.tableHeaderText.withValues(alpha: 0.4)),
            ),
          ),
        ),
      ),
    );
  }
}
