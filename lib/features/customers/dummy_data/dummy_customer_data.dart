import 'package:omnix/features/customers/model/customer_model.dart';

/// Temporary data for the Customers section.
///
/// Delete this file once the backend returns real customers.
class DummyCustomerData {
  const DummyCustomerData._();

  static const List<Customer> customers = [
    Customer(
      id: 'CUS-001',
      name: 'Rakib Hasan',
      phone: '01712-345678',
      visits: 24,
      spent: 42800,
      lastVisit: 'Today, 2:38 PM',
    ),
    Customer(
      id: 'CUS-002',
      name: 'Nusrat Jahan',
      phone: '01819-876543',
      visits: 17,
      spent: 31250,
      lastVisit: 'Today, 2:20 PM',
    ),
    Customer(
      id: 'CUS-003',
      name: 'Tanvir Ahmed',
      phone: '01910-223344',
      visits: 9,
      spent: 15600,
      lastVisit: 'Today, 2:05 PM',
    ),
    Customer(
      id: 'CUS-004',
      name: 'Sadia Islam',
      phone: '01615-778899',
      visits: 12,
      spent: 22400,
      lastVisit: 'Today, 1:58 PM',
    ),
    Customer(
      id: 'CUS-005',
      name: 'Imran Kabir',
      phone: '01521-445566',
      visits: 4,
      spent: 6800,
      lastVisit: 'Yesterday, 8:40 PM',
    ),
    Customer(
      id: 'CUS-006',
      name: 'Farhana Akter',
      phone: '01318-990011',
      visits: 31,
      spent: 56700,
      lastVisit: 'Today, 1:22 PM',
    ),
    Customer(
      id: 'CUS-007',
      name: 'Shahriar Alam',
      phone: '01477-223344',
      visits: 2,
      spent: 2450,
      lastVisit: '2 days ago',
    ),
    Customer(
      id: 'CUS-008',
      name: 'Mehjabin Rahman',
      phone: '01733-556677',
      visits: 7,
      spent: 11900,
      lastVisit: 'Yesterday, 7:15 PM',
    ),
  ];
}
