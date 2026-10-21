import 'package:omnix/features/dashboard/model/sales_bucket_model.dart';

// Temporary data for the Sales Velocity chart.
//
// Delete this file once the backend returns real sales buckets.
class DummySalesData {
  const DummySalesData._();

  // hourly buckets of today, 8 AM to 11 PM
  static const List<double> hourlySales = [
    1200,
    2400,
    3600,
    5200,
    7400,
    9600,
    8100,
    6400,
    5800,
    7200,
    9800,
    14200,
    16800,
    15400,
    9600,
    4200,
  ];

  // base sale of a regular weekday
  static const double weekdaySale = 38000;

  // base sale of a weekend, weekends sell more
  static const double weekendSale = 46000;

  // extra sale added every 5th day of the range
  static const double dayStep = 1500;

  // hourly buckets of today
  static List<SalesBucket> get hours {
    return List.generate(hourlySales.length, (int i) {
      return SalesBucket(label: _hourLabel(8 + i), sales: hourlySales[i]);
    });
  }

  // last N days ending today
  static List<SalesBucket> days(int days) {
    final DateTime today = DateTime.now();

    return List.generate(days, (int i) {
      final DateTime date = today.subtract(Duration(days: days - 1 - i));
      final bool weekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      final double sales =
          (weekend ? weekendSale : weekdaySale) + (i % 5) * dayStep;
      return SalesBucket(label: _dayLabel(date), sales: sales);
    });
  }

  static String _hourLabel(int hour) {
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h $period';
  }

  static String _dayLabel(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
