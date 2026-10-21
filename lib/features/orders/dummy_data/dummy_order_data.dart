import 'package:omnix/features/orders/model/order_model.dart';

/// Temporary data for the Orders section.
///
/// Delete this file once the backend returns real orders.
class DummyOrderData {
  const DummyOrderData._();

  static const List<Order> orders = [
    Order(
      id: 'ORD-1042',
      customer: 'Walk-in',
      items: '2x Beef Burger, 1x Fries, 2x Coke',
      status: OrderStatus.pending,
      amount: 1240,
      placedAt: '2:45 PM',
      paymentMethod: 'Cash',
    ),
    Order(
      id: 'ORD-1043',
      customer: 'Rakib Hasan',
      items: '1x Chicken Pizza, 1x Salad',
      status: OrderStatus.ready,
      amount: 980,
      placedAt: '2:38 PM',
      paymentMethod: 'bKash',
    ),
    Order(
      id: 'ORD-1044',
      customer: 'Nusrat Jahan',
      items: 'Family platter with drinks and dessert',
      status: OrderStatus.completed,
      amount: 1450,
      placedAt: '2:20 PM',
      paymentMethod: 'Card',
    ),
    Order(
      id: 'ORD-1045',
      customer: 'Walk-in',
      items: '1x Grilled Steak, 1x Rice, 1x Soup',
      status: OrderStatus.cancelled,
      amount: 890,
      placedAt: '2:12 PM',
      paymentMethod: 'Cash',
    ),
    Order(
      id: 'ORD-1046',
      customer: 'Tanvir Ahmed',
      items: '3x Chicken Wings, 1x Mashed Potato',
      status: OrderStatus.preparing,
      amount: 1120,
      placedAt: '2:05 PM',
      paymentMethod: 'bKash',
    ),
    Order(
      id: 'ORD-1047',
      customer: 'Sadia Islam',
      items: '1x Margherita Pizza, 1x Garlic Bread',
      status: OrderStatus.ready,
      amount: 760,
      placedAt: '1:58 PM',
      paymentMethod: 'Card',
    ),
    Order(
      id: 'ORD-1048',
      customer: 'Walk-in',
      items: '2x Fish Platter, 2x Lemon Tea',
      status: OrderStatus.pending,
      amount: 1580,
      placedAt: '1:50 PM',
      paymentMethod: 'Cash',
    ),
    Order(
      id: 'ORD-1049',
      customer: 'Imran Kabir',
      items: '1x Caesar Salad, 1x Cold Coffee',
      status: OrderStatus.completed,
      amount: 640,
      placedAt: '1:41 PM',
      paymentMethod: 'bKash',
    ),
    Order(
      id: 'ORD-1050',
      customer: 'Walk-in',
      items: 'BBQ Platter for four with dessert',
      status: OrderStatus.cancelled,
      amount: 2450,
      placedAt: '1:30 PM',
      paymentMethod: 'Cash',
    ),
    Order(
      id: 'ORD-1051',
      customer: 'Farhana Akter',
      items: '2x Fish and Chips, 1x Coleslaw',
      status: OrderStatus.preparing,
      amount: 1340,
      placedAt: '1:22 PM',
      paymentMethod: 'Card',
    ),
    Order(
      id: 'ORD-1052',
      customer: 'Walk-in',
      items: '1x Mushroom Pizza, 1x Salad',
      status: OrderStatus.completed,
      amount: 1050,
      placedAt: '1:10 PM',
      paymentMethod: 'Cash',
    ),
  ];
}
