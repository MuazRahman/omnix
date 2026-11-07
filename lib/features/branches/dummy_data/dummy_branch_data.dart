import 'package:omnix/features/branches/model/branch_model.dart';

/// Temporary data for the Branches section.
///
/// Delete this file once the backend returns real branches.
class DummyBranchData {
  const DummyBranchData._();

  // network-wide revenue change against yesterday's close
  // TODO: replace with a real value once the analytics endpoint is live
  static const double networkRevenueChangePercent = 14.2;

  static const List<Branch> branches = [
    Branch(
      id: 'DHK-01',
      name: 'Main Branch',
      address: 'House 12, Road 5, Banani, Dhaka 1213',
      manager: 'Tanvir Rahman',
      phone: '01712-345678',
      isActive: true,
      openedAt: 'Jan 2019',
      area: 'Gulshan-Banani, Dhaka',
      tagline: 'Flagship Outlet',
      tables: 18,
      seats: 72,
      posTerminals: 2,
      staffCount: 12,
      todayRevenue: 84650,
      todayOrders: 142,
      inventoryHealth: 92,
      lowStockCount: 1,
      isCurrent: true,
    ),
    Branch(
      id: 'KHL-01',
      name: 'Khulna Branch',
      address: 'House 7, Sonadanga, Khulna 9102',
      manager: 'Farhana Akter',
      phone: '01819-876543',
      isActive: true,
      openedAt: 'Jun 2021',
      area: 'Sonadanga, Khulna',
      tagline: 'Regional Outlet',
      tables: 10,
      seats: 40,
      posTerminals: 1,
      staffCount: 8,
      todayRevenue: 52300,
      todayOrders: 98,
      inventoryHealth: 88,
      lowStockCount: 0,
    ),
    Branch(
      id: 'DHK-02',
      name: 'Dhaka Branch',
      address: 'House 44, Mirpur DOHS, Dhaka 1216',
      manager: 'Rakib Hasan',
      phone: '01910-223344',
      isActive: true,
      openedAt: 'Mar 2022',
      area: 'Mirpur DOHS, Dhaka',
      tagline: 'Urban Dining',
      tables: 12,
      seats: 48,
      posTerminals: 1,
      staffCount: 8,
      todayRevenue: 38900,
      todayOrders: 76,
      inventoryHealth: 74,
      lowStockCount: 3,
    ),
    Branch(
      id: 'CTG-01',
      name: 'Chattogram Branch',
      address: 'House 3, GEC Circle, Chattogram 4000',
      manager: 'Imran Kabir',
      phone: '01615-778899',
      isActive: false,
      openedAt: 'Nov 2023',
      area: 'GEC Circle, Chattogram',
      tagline: 'Coastal Outlet',
      tables: 8,
      seats: 32,
      posTerminals: 0,
      staffCount: 0,
      todayRevenue: 21400,
      todayOrders: 41,
      inventoryHealth: 66,
      lowStockCount: 4,
    ),
  ];

  // hourly order throughput of the three active outlets
  static const List<BranchThroughputSlot> throughput = [
    BranchThroughputSlot(
      hour: '12:00',
      orders: {'DHK-01': 40, 'KHL-01': 25, 'DHK-02': 15},
    ),
    BranchThroughputSlot(
      hour: '13:00',
      orders: {'DHK-01': 70, 'KHL-01': 50, 'DHK-02': 35},
    ),
    BranchThroughputSlot(
      hour: '14:00',
      orders: {'DHK-01': 95, 'KHL-01': 78, 'DHK-02': 60},
    ),
    BranchThroughputSlot(
      hour: '15:00',
      orders: {'DHK-01': 60, 'KHL-01': 45, 'DHK-02': 40},
    ),
    BranchThroughputSlot(
      hour: '16:00',
      orders: {'DHK-01': 35, 'KHL-01': 30, 'DHK-02': 48},
    ),
    BranchThroughputSlot(
      hour: '17:00',
      orders: {'DHK-01': 40, 'KHL-01': 35, 'DHK-02': 52},
    ),
    BranchThroughputSlot(
      hour: '18:00',
      orders: {'DHK-01': 65, 'KHL-01': 55, 'DHK-02': 62},
    ),
    BranchThroughputSlot(
      hour: '19:00',
      orders: {'DHK-01': 80, 'KHL-01': 68, 'DHK-02': 70},
    ),
    BranchThroughputSlot(
      hour: '20:00',
      orders: {'DHK-01': 98, 'KHL-01': 88, 'DHK-02': 90},
    ),
    BranchThroughputSlot(
      hour: '21:00',
      orders: {'DHK-01': 85, 'KHL-01': 72, 'DHK-02': 65},
    ),
    BranchThroughputSlot(
      hour: '22:00',
      orders: {'DHK-01': 55, 'KHL-01': 40, 'DHK-02': 38},
    ),
    BranchThroughputSlot(
      hour: '23:00',
      orders: {'DHK-01': 20, 'KHL-01': 15, 'DHK-02': 10},
    ),
  ];
}
