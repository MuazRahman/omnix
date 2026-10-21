import 'package:omnix/features/dashboard/model/branch_performance_model.dart';

/// Temporary data for the Branch Performance card.
///
/// Delete this file once the backend returns real branch numbers.
class DummyBranchPerformanceData {
  const DummyBranchPerformanceData._();

  static const List<BranchPerformance> branchPerformance = [
    BranchPerformance(
      branchId: 'DHK-01',
      name: 'Main Branch',
      sale: 84650,
      orders: 164,
      changePercent: 12.4,
    ),
    BranchPerformance(
      branchId: 'KHL-01',
      name: 'Khulna Branch',
      sale: 52300,
      orders: 98,
      changePercent: 6.8,
    ),
    BranchPerformance(
      branchId: 'DHK-02',
      name: 'Dhaka Branch',
      sale: 38900,
      orders: 76,
      changePercent: -3.2,
    ),
    // the fourth branch is not shown, the card only lists the top 3 sellers
    BranchPerformance(
      branchId: 'CTG-01',
      name: 'Chattogram Branch',
      sale: 21400,
      orders: 41,
      changePercent: 1.7,
    ),
  ];
}
