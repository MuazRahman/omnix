import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';

/// Dish search field with the barcode scanner action on its right.
class PosSearchBarWidget extends StatelessWidget {
  const PosSearchBarWidget({
    super.key,
    required this.posController,
    required this.textController,
    required this.focusNode,
    this.onScan,
  });

  final PosController posController;
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              onChanged: posController.searchOnChanged,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.lightAmberWhite,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.windowWidgetBackgroundBlack,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                prefixIcon: const Icon(
                  Icons.search_outlined,
                  size: 20,
                  color: AppTheme.tableHeaderText,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.sidebarBackgroundBlack,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ALT + S',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppTheme.tableHeaderText,
                      ),
                    ),
                  ),
                ),
                hintText: 'Search dishes by name, code or barcode...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: AppTheme.lightAmberWhite.withValues(alpha: 0.4),
                ),
                border: _border(),
                enabledBorder: _border(),
                focusedBorder: _border(color: AppTheme.amber),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 46,
          child: OutlinedButton.icon(
            onPressed: onScan,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppTheme.windowWidgetBackgroundBlack,
              foregroundColor: AppTheme.lightAmberWhite,
              side: BorderSide(
                color: AppTheme.lightAmberWhite.withValues(alpha: 0.2),
                width: 0.6,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(
              Icons.qr_code_scanner,
              size: 18,
              color: AppTheme.amber,
            ),
            label: const Text(
              'Scanner',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: color ?? AppTheme.lightAmberWhite.withValues(alpha: 0.14),
        width: color == null ? 0.6 : 1,
      ),
    );
  }
}
