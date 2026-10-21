import 'package:flutter/material.dart';

/// Scrollable body of a table with a scrollbar always visible on the right.
///
/// The scrollbar is pinned so the user can tell the table has more rows
/// below, even when they are not scrolling.
class ScrollableTableBody extends StatefulWidget {
  const ScrollableTableBody({super.key, required this.child});

  final Widget child;

  @override
  State<ScrollableTableBody> createState() => _ScrollableTableBodyState();
}

class _ScrollableTableBodyState extends State<ScrollableTableBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,

      // always show the thumb, the table is scrollable
      thumbVisibility: true,
      interactive: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: widget.child,
      ),
    );
  }
}
