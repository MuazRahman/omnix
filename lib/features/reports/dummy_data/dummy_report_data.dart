import 'package:omnix/features/reports/model/report_model.dart';

/// Temporary data for the Reports section.
///
/// Delete this file once the backend returns real report numbers.
class DummyReportData {
  const DummyReportData._();

  static const List<ReportEntry> salesReport = [
    ReportEntry(
      label: 'Gross Sales',
      value: '৳1,74,850',
      changePercent: 12.4,
      icon: '💰',
    ),
    ReportEntry(
      label: 'Net Sales',
      value: '৳1,68,200',
      changePercent: 9.8,
      icon: '📈',
    ),
    ReportEntry(
      label: 'Average Ticket',
      value: '৳525',
      changePercent: 3.1,
      icon: '🧾',
    ),
    ReportEntry(
      label: 'Total Orders',
      value: '338',
      changePercent: 8.5,
      icon: '📋',
    ),
    ReportEntry(
      label: 'Cost of Goods',
      value: '৳62,400',
      changePercent: -2.3,
      icon: '📦',
    ),
    ReportEntry(
      label: 'Gross Profit',
      value: '৳1,05,800',
      changePercent: 14.7,
      icon: '✨',
    ),
  ];

  static const List<TopSellingItem> topSellingItems = [
    TopSellingItem(name: 'Beef Burger', quantitySold: 186, revenue: 78120),
    TopSellingItem(name: 'Chicken Pizza', quantitySold: 142, revenue: 78100),
    TopSellingItem(name: 'Biryani', quantitySold: 128, revenue: 43520),
    TopSellingItem(name: 'Fish and Chips', quantitySold: 96, revenue: 49920),
    TopSellingItem(name: 'Chicken Wings', quantitySold: 88, revenue: 28160),
    TopSellingItem(name: 'Mushroom Pizza', quantitySold: 74, revenue: 43660),
  ];

  static const List<ReportEntry> staffPerformance = [
    ReportEntry(
      label: 'Tanvir Rahman',
      value: '৳42,600',
      changePercent: 11.2,
      icon: '👨‍🍳',
    ),
    ReportEntry(
      label: 'Farhana Akter',
      value: '৳36,100',
      changePercent: 6.4,
      icon: '👩‍🍳',
    ),
    ReportEntry(
      label: 'Rakib Hasan',
      value: '৳31,750',
      changePercent: -1.8,
      icon: '🧑‍🍳',
    ),
  ];
}
