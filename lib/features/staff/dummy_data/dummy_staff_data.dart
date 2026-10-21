import 'package:omnix/features/staff/model/staff_model.dart';

/// Temporary data for the Staff & Settings section.
///
/// Delete this file once the backend returns real staff.
class DummyStaffData {
  const DummyStaffData._();

  static const List<Staff> staff = [
    Staff(
      id: 'STF-001',
      name: 'Tanvir Rahman',
      role: StaffRole.manager,
      branch: 'Main Branch (DHK-01)',
      phone: '01712-345678',
      isActive: true,
      joinedAt: 'Jan 2019',
    ),
    Staff(
      id: 'STF-002',
      name: 'Farhana Akter',
      role: StaffRole.cashier,
      branch: 'Khulna Branch (KHL-01)',
      phone: '01819-876543',
      isActive: true,
      joinedAt: 'Jun 2021',
    ),
    Staff(
      id: 'STF-003',
      name: 'Rakib Hasan',
      role: StaffRole.chef,
      branch: 'Dhaka Branch (DHK-02)',
      phone: '01910-223344',
      isActive: true,
      joinedAt: 'Mar 2022',
    ),
    Staff(
      id: 'STF-004',
      name: 'Imran Kabir',
      role: StaffRole.waiter,
      branch: 'Main Branch (DHK-01)',
      phone: '01615-778899',
      isActive: true,
      joinedAt: 'Nov 2023',
    ),
    Staff(
      id: 'STF-005',
      name: 'Sadia Islam',
      role: StaffRole.cashier,
      branch: 'Main Branch (DHK-01)',
      phone: '01521-445566',
      isActive: true,
      joinedAt: 'Feb 2024',
    ),
    Staff(
      id: 'STF-006',
      name: 'Shahriar Alam',
      role: StaffRole.waiter,
      branch: 'Chattogram Branch (CTG-01)',
      phone: '01477-223344',
      isActive: false,
      joinedAt: 'Aug 2024',
    ),
  ];

  // settings of the restaurant, toggled on the settings panel
  static const List<SettingToggle> settings = [
    SettingToggle(
      label: 'Auto print kitchen ticket',
      description: 'Print the order ticket as soon as it is placed',
      isOn: true,
    ),
    SettingToggle(
      label: 'Service charge',
      description: 'Add 10 percent service charge on every bill',
      isOn: false,
    ),
    SettingToggle(
      label: 'Order sound alerts',
      description: 'Play a sound when a new order arrives',
      isOn: true,
    ),
    SettingToggle(
      label: 'Low stock alerts',
      description: 'Notify the manager when an item reaches its reorder level',
      isOn: true,
    ),
    SettingToggle(
      label: 'Compact menu grid',
      description: 'Show more items per row on the POS screen',
      isOn: false,
    ),
  ];
}

// One toggle of the settings panel
class SettingToggle {
  const SettingToggle({
    required this.label,
    required this.description,
    required this.isOn,
  });

  final String label;
  final String description;
  final bool isOn;
}
