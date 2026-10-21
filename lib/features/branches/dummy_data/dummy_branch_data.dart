import 'package:omnix/features/branches/model/branch_model.dart';

/// Temporary data for the Branches section.
///
/// Delete this file once the backend returns real branches.
class DummyBranchData {
  const DummyBranchData._();

  static const List<Branch> branches = [
    Branch(
      id: 'DHK-01',
      name: 'Main Branch',
      address: 'House 12, Road 5, Banani, Dhaka 1213',
      manager: 'Tanvir Rahman',
      phone: '01712-345678',
      isActive: true,
      openedAt: 'Jan 2019',
    ),
    Branch(
      id: 'KHL-01',
      name: 'Khulna Branch',
      address: 'House 7, Sonadanga, Khulna 9102',
      manager: 'Farhana Akter',
      phone: '01819-876543',
      isActive: true,
      openedAt: 'Jun 2021',
    ),
    Branch(
      id: 'DHK-02',
      name: 'Dhaka Branch',
      address: 'House 44, Mirpur DOHS, Dhaka 1216',
      manager: 'Rakib Hasan',
      phone: '01910-223344',
      isActive: true,
      openedAt: 'Mar 2022',
    ),
    Branch(
      id: 'CTG-01',
      name: 'Chattogram Branch',
      address: 'House 3, GEC Circle, Chattogram 4000',
      manager: 'Imran Kabir',
      phone: '01615-778899',
      isActive: false,
      openedAt: 'Nov 2023',
    ),
  ];
}
