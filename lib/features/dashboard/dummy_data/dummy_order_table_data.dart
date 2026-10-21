import 'package:omnix/features/dashboard/model/recent_order_model.dart';

// Temporary data for the Recent Orders table.
//
// This file only exists until the backend is wired up. Once the API returns
// real orders, delete this folder and let the controller map the response
// straight into `RecentOrder` (see `RecentOrder.fromJson`).
class DummyOrderTableData {
  const DummyOrderTableData._();

  // Rows shown in the Recent Orders table, newest first.
  static const List<RecentOrder> recentOrders = [
    RecentOrder(
      id: 'ORD-1042',
      items: '2x Beef Burger, 1x Fries, 2x Coke',
      status: OrderStatus.pending,
      amount: 1240,
    ),
    RecentOrder(
      id: 'ORD-1043',
      items: '1x Chicken Pizza, 1x Salad',
      status: OrderStatus.ready,
      amount: 980,
    ),
    RecentOrder(
      id: 'ORD-1044',
      items: 'Family platter with drinks and dessert',
      status: OrderStatus.completed,
      amount: 1450,
    ),
    RecentOrder(
      id: 'ORD-1045',
      items: '1x Grilled Steak, 1x Rice, 1x Soup',
      status: OrderStatus.cancelled,
      amount: 890,
    ),
    RecentOrder(
      id: 'ORD-1046',
      items: '3x Chicken Wings, 1x Mashed Potato',
      status: OrderStatus.preparing,
      amount: 1120,
    ),
    RecentOrder(
      id: 'ORD-1047',
      items: '1x Margherita Pizza, 1x Garlic Bread',
      status: OrderStatus.ready,
      amount: 760,
    ),
    RecentOrder(
      id: 'ORD-1048',
      items: '2x Fish Platter, 2x Lemon Tea',
      status: OrderStatus.pending,
      amount: 1580,
    ),
    RecentOrder(
      id: 'ORD-1049',
      items: '1x Caesar Salad, 1x Cold Coffee',
      status: OrderStatus.completed,
      amount: 640,
    ),
    RecentOrder(
      id: 'ORD-1050',
      items: 'BBQ Platter for four with dessert',
      status: OrderStatus.cancelled,
      amount: 2450,
    ),
  ];
}
