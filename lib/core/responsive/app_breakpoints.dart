/// Shared width breakpoints for responsive layouts.
///
/// These values describe the **available content width** — typically the
/// space left after the sidebar — not the raw window width.
abstract final class AppBreakpoints {
  // Layout buckets.
  static const double compact = 420;
  static const double small = 600;
  static const double medium = 820;
  static const double large = 1050;
  static const double wide = 1250;
  static const double ultraWide = 1400;

  // Extra thresholds used by the shared top bar.
  static const double topBarSearch = 620;
  static const double topBarBranchRoom = 850;
  static const double topBarSearchMax = 1000;
  static const double topBarBranchWide = 1100;
  static const double topBarRoomyGap = 1200;
}
