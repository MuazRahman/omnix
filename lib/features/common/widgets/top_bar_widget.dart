import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omnix/core/responsive/app_breakpoints.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';

class TopBarWidget extends StatelessWidget {
  const TopBarWidget({super.key, required this.branchController});

  final BranchController branchController;

  // horizontal padding of the bar, also used for the width budget
  static const double _horizontalPadding = 16;

  // fixed widths of the controls that can show up in the bar
  static const double _syncWidth = 90;
  static const double _avatarSize = 35;
  static const double _newSaleLabelWidth = 220;
  static const double _newSaleIconWidth = 44;
  static const double _userReserve = 110;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: AppTheme.windowWidgetBackgroundBlack,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.deepAmberWhite.withValues(alpha: 0.7),
            width: 0.4,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double available =
              constraints.maxWidth - (_horizontalPadding * 2);

          // progressively drop low priority controls as the window narrows
          final bool showSearch = available >= AppBreakpoints.topBarSearch;
          final bool showSync = available >= AppBreakpoints.wide;
          final bool showUserName = available >= AppBreakpoints.large;
          final bool showNewSaleLabel = available >= AppBreakpoints.medium;

          final double gap = available >= AppBreakpoints.topBarRoomyGap
              ? 20
              : (available >= AppBreakpoints.small ? 12 : 8);

          final double branchWidth = _branchWidth(available);
          final double newSaleWidth = showNewSaleLabel
              ? _newSaleLabelWidth
              : _newSaleIconWidth;

          // gaps between branch, search, sync, new sale, user and avatar
          final int visibleChildren =
              4 + (showSearch ? 1 : 0) + (showSync ? 1 : 0);
          final double fixedWidth =
              branchWidth +
              newSaleWidth +
              _avatarSize +
              (showSync ? _syncWidth : 0) +
              ((visibleChildren - 1) * gap);

          // leave room for the user name, then give the search what is left
          final double maxSearchWidth =
              available >= AppBreakpoints.topBarSearchMax ? 460 : 340;
          final double searchWidth = showSearch
              ? (available - fixedWidth - (showUserName ? _userReserve : 0))
                    .clamp(150.0, maxSearchWidth)
                    .toDouble()
              : 0;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
              vertical: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: gap,
              children: [
                SizedBox(
                  width: branchWidth,
                  child: _buildBranchDropdown(branchWidth),
                ),

                if (showSearch)
                  SizedBox(
                    height: 35,
                    width: searchWidth,
                    child: _buildInvoiceSearch(),
                  ),

                if (showSync) _buildSyncBadge(),

                _buildNewSaleButton(
                  width: newSaleWidth,
                  showLabel: showNewSaleLabel,
                ),

                // keeps the avatar pinned to the right on every size
                Expanded(
                  child: showUserName
                      ? _buildUserInfo()
                      : const SizedBox.shrink(),
                ),

                _buildUserAvatar(),
              ],
            ),
          );
        },
      ),
    );
  }

  double _branchWidth(double available) {
    if (available >= AppBreakpoints.ultraWide) return 320;
    if (available >= AppBreakpoints.topBarBranchWide) return 280;
    if (available >= AppBreakpoints.topBarBranchRoom) return 240;
    if (available >= AppBreakpoints.topBarSearch) return 200;
    if (available >= AppBreakpoints.compact) return 150;
    return 100;
  }

  Widget _buildBranchDropdown(double width) {
    return DropdownButton2<String>(
      valueListenable: branchController.selectedBranch,
      isDense: true,
      isExpanded: true,

      // Dropdown options
      items: branchController.branches.map((String branch) {
        final bool isSelected = branch == branchController.selectedBranch.value;

        return DropdownItem<String>(
          value: branch,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppTheme.deepAmberWhite,
              ),
              Flexible(
                child: Text(
                  branch,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: AppTheme.lightAmberWhite,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),

      onChanged: branchController.branchOnChanged,

      // Chevron icon (rotates when open)
      iconStyleData: const IconStyleData(
        icon: Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: AppTheme.deepAmberWhite,
          ),
        ),
        openMenuIcon: Icon(
          Icons.keyboard_arrow_left_outlined,
          size: 20,
          color: AppTheme.deepAmberWhite,
        ),
      ),

      // Button decoration
      buttonStyleData: ButtonStyleData(
        height: 40,
        width: width,
        padding: const EdgeInsets.only(left: 16, right: 8),
        overlayColor: WidgetStatePropertyAll(AppTheme.amber.withAlpha(20)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.amber.withAlpha(50), width: 0.5),
          color: AppTheme.sidebarBackgroundBlack,
        ),
      ),

      // Popup menu decoration
      dropdownStyleData: DropdownStyleData(
        width: width,
        maxHeight: 240,
        elevation: 12,
        offset: const Offset(0, -5),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.amber.withAlpha(50), width: 0.5),
          borderRadius: BorderRadius.circular(6),
          color: AppTheme.sidebarBackgroundBlack,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(150),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      ),

      // Individual menu item styling
      menuItemStyleData: MenuItemStyleData(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        borderRadius: BorderRadius.circular(4),
        overlayColor: WidgetStatePropertyAll(AppTheme.amber.withAlpha(25)),
        // Highlight the currently selected branch
        selectedMenuItemBuilder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.amber.withAlpha(35),
              borderRadius: BorderRadius.circular(4),
            ),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildInvoiceSearch() {
    return TextField(
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          return newValue.copyWith(
            text: newValue.text.toUpperCase(),
            selection: newValue.selection,
          );
        }),
      ],
      style: const TextStyle(
        fontSize: 14,
        color: AppTheme.lightAmberWhite,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.sidebarBackgroundBlack,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        prefixIcon: Icon(
          Icons.search_outlined,
          size: 19,
          color: AppTheme.deepAmberWhite.withValues(alpha: 0.2),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
        hintText: 'Invoice (Ex: DHK-01-103)',
        hintStyle: TextStyle(
          fontSize: 13,
          color: AppTheme.lightAmberWhite.withValues(alpha: 0.47),
        ),
        border: _searchBorder(),
        enabledBorder: _searchBorder(),
        focusedBorder: _searchBorder(color: AppTheme.amber),
      ),
    );
  }

  OutlineInputBorder _searchBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: color ?? AppTheme.amber.withAlpha(50),
        width: 0.5,
      ),
    );
  }

  Widget _buildSyncBadge() {
    return Container(
      height: 24,
      width: _syncWidth,
      decoration: BoxDecoration(
        color: AppTheme.lightGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.lightGreen, width: 0.5),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            CircleAvatar(backgroundColor: AppTheme.lightGreen, maxRadius: 4),
            Text(
              'SYNCED',
              style: TextStyle(
                color: AppTheme.lightGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewSaleButton({required double width, required bool showLabel}) {
    final Widget icon = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.brown.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
      child: const Padding(
        padding: EdgeInsets.all(3),
        child: Icon(Icons.restaurant, color: AppTheme.deepAmberWhite, size: 16),
      ),
    );

    final Widget button = ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        fixedSize: Size(width, 38),
        backgroundColor: AppTheme.amber,
        padding: showLabel
            ? const EdgeInsets.symmetric(horizontal: 16)
            : EdgeInsets.zero,
        minimumSize: Size(width, 38),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: showLabel ? 12 : 0,
          children: [
            icon,
            if (showLabel)
              const Text(
                'New Sale',
                style: TextStyle(
                  color: AppTheme.sidebarBackgroundBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );

    if (showLabel) return button;

    return Tooltip(message: 'New Sale (F2)', child: button);
  }

  Widget _buildUserInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Tanveer Rahman',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.lightAmberWhite,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Cashier',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.deepAmberWhite,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.lightAmberWhite,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Icon(Icons.person, color: Colors.brown, size: _avatarSize),
    );
  }
}
