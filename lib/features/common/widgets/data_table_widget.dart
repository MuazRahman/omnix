import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/common/widgets/scrollable_table_body.dart';

/// One column of a [DataTableWidget].
class DataTableColumn {
  const DataTableColumn({
    required this.label,
    required this.flex,
    this.alignRight = false,
    this.monospace = false,
  });

  final String label;

  /// share of the table width, all columns add up to the full width
  final int flex;
  final bool alignRight;

  /// render the value in a monospaced font, used for ids and amounts
  final bool monospace;
}

/// One row of a [DataTableWidget].
class DataTableRow {
  const DataTableRow({required this.cells, this.onTap});

  /// cell widgets, one per column
  final List<Widget> cells;
  final VoidCallback? onTap;
}

/// Generic table used by the list sections (orders, inventory, customers...).
///
/// The header stays pinned while the body scrolls.
class DataTableWidget extends StatelessWidget {
  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.headerHeight = 39,
    this.rowHeight = 52,
    this.emptyMessage = 'Nothing here yet',
  });

  final List<DataTableColumn> columns;
  final List<DataTableRow> rows;
  final double headerHeight;
  final double rowHeight;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        buildHeaderRow(),

        // body scrolls, the header above stays visible
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    emptyMessage,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.tableHeaderText,
                    ),
                  ),
                )
              : ScrollableTableBody(
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: rows.map(buildRow).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget buildHeaderRow() {
    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.tableDivider, width: 1),
        ),
      ),
      child: Row(
        children: columns.map((column) => buildHeaderCell(column)).toList(),
      ),
    );
  }

  Widget buildHeaderCell(DataTableColumn column) {
    return Expanded(
      flex: column.flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(
          alignment: column.alignRight ? .centerRight : .centerLeft,
          child: Text(
            column.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              height: 1.4,
              color: AppTheme.tableHeaderText,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(DataTableRow row) {
    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.tableDivider, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: .stretch,
        children: columns
            .asMap()
            .entries
            .map((entry) => buildCell(entry.key, entry.value, row))
            .toList(),
      ),
    );
  }

  Widget buildCell(int index, DataTableColumn column, DataTableRow row) {
    return Expanded(
      flex: column.flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(
          alignment: column.alignRight ? .centerRight : .centerLeft,
          child: index < row.cells.length
              ? row.cells[index]
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// Text cell, styled the same way across every section
  static Widget text(
    String value, {
    Color color = AppTheme.tablePrimaryText,
    FontWeight weight = FontWeight.w500,
    bool monospace = false,
    double fontSize = 14,
  }) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: monospace ? 'monospace' : 'Inter',
        fontFamilyFallback: monospace
            ? const ['Courier New', 'Menlo', 'DejaVu Sans Mono']
            : null,
        fontSize: fontSize,
        fontWeight: weight,
        height: 1.43,
        color: color,
      ),
    );
  }
}
