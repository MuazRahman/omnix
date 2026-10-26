import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/orders/controller/order_controller.dart';

/// Page title, live sync state and the shift level actions.
class OrdersHeaderWidget extends StatelessWidget {
  const OrdersHeaderWidget({
    super.key,
    required this.orderController,
    required this.onRefresh,
    required this.onExport,
    required this.onPrinterSettings,
  });

  final OrderController orderController;
  final VoidCallback onRefresh;
  final VoidCallback onExport;
  final VoidCallback onPrinterSettings;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String syncLabel = orderController.lastSyncAt.value == null
          ? 'Waiting for sync'
          : 'Synced ${formatClock(orderController.lastSyncAt.value!)}';

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stackActions = constraints.maxWidth < 860;

          final Widget title = _buildTitle(syncLabel);

          final Widget actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.end,
            children: [
              _SyncChip(label: syncLabel),
              _HeaderIconButton(
                icon: Icons.print_outlined,
                tooltip: 'Invoice printer settings',
                onTap: onPrinterSettings,
              ),
              _RefreshButton(
                isLoading: orderController.isLoading.value,
                onTap: onRefresh,
              ),
              _ExportButton(onTap: onExport),
            ],
          );

          if (stackActions) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: actions),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: title),
              const SizedBox(width: 16),
              actions,
            ],
          );
        },
      );
    });
  }

  Widget _buildTitle(String syncLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 22,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppTheme.amber,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: Text(
                'Order Ledger',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: AppTheme.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 13),
          child: Text(
            '$syncLabel · POS-DHK-01 · dine-in, pickup and delivery tickets',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SyncChip extends StatelessWidget {
  const _SyncChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.lightGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: AppTheme.lightGreen.withValues(alpha: 0.25),
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppTheme.lightGreen,
                shape: BoxShape.circle,
              ),
            ),
            const Text(
              'LIVE',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppTheme.windowWidgetBackgroundBlack,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          hoverColor: AppTheme.amber.withValues(alpha: 0.1),
          child: Container(
            width: 36,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
                width: 0.6,
              ),
            ),
            child: Icon(icon, size: 17, color: AppTheme.lightAmberWhite),
          ),
        ),
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Force refresh (F5)',
      child: TextButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.amber,
                ),
              )
            : const Icon(Icons.sync, size: 15),
        label: Text(isLoading ? 'Syncing' : 'Refresh'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.lightAmberWhite,
          disabledForegroundColor: AppTheme.tableHeaderText,
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: BorderSide(
              color: AppTheme.lightAmberWhite.withValues(alpha: 0.16),
              width: 0.6,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.file_download_outlined, size: 16),
      label: const Text('Export Ledger'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.amber,
        foregroundColor: AppTheme.windowWidgetBackgroundBlack,
        elevation: 0,
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}
