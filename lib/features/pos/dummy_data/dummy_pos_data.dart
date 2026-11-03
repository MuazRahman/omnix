import 'package:omnix/features/pos/model/cart_item_model.dart';

/// Service floor of the branch, used by the new sale floor plan.
enum PosFloor {
  indoor('Indoor AC Hall', 'Indoor'),
  rooftop('Rooftop Terrace', 'Terrace'),
  family('Family Lounge', 'Family');

  const PosFloor(this.label, this.shortLabel);

  final String label;

  // short name stored on the ticket, e.g. "T-03 (Indoor)"
  final String shortLabel;
}

/// Availability of a table on the floor plan.
enum PosTableStatus { free, occupied, reserved }

/// One table of the floor plan.
class PosFloorTable {
  const PosFloorTable({
    required this.label,
    required this.floor,
    required this.seats,
    this.status = PosTableStatus.free,
    this.detail,
  });

  final String label;
  final PosFloor floor;
  final int seats;
  final PosTableStatus status;

  // shown under the status, e.g. "6 Guests" or "19:30"
  final String? detail;

  bool get isFree => status == PosTableStatus.free;

  // label stored on the POS ticket, e.g. "T-03 (Indoor)"
  String get selectionLabel => '$label (${floor.shortLabel})';
}

/// Temporary data for the POS section.
///
/// The cart starts empty, a few items are pre loaded so the screen has
/// something to show before the cashier starts an order.
class DummyPosData {
  const DummyPosData._();

  static const List<CartItem> initialCart = [
    CartItem(
      menuItemId: 'M-004',
      name: 'Beef Burger',
      price: 420,
      quantity: 2,
      note: '+ Extra cheese, medium rare',
    ),
    CartItem(
      menuItemId: 'M-003',
      name: 'Garlic Bread',
      price: 180,
      quantity: 1,
    ),
    CartItem(menuItemId: 'M-015', name: 'Coke', price: 80, quantity: 2),
  ];

  // floor plan of the current branch
  static const List<PosFloorTable> floorTables = [
    // Indoor AC Hall
    PosFloorTable(
      label: 'T-01',
      floor: PosFloor.indoor,
      seats: 6,
      status: PosTableStatus.occupied,
      detail: '6 Guests',
    ),
    PosFloorTable(
      label: 'T-02',
      floor: PosFloor.indoor,
      seats: 4,
      status: PosTableStatus.reserved,
      detail: '19:30',
    ),
    PosFloorTable(label: 'T-03', floor: PosFloor.indoor, seats: 4),
    PosFloorTable(label: 'T-04', floor: PosFloor.indoor, seats: 4),
    PosFloorTable(label: 'T-05', floor: PosFloor.indoor, seats: 2),
    PosFloorTable(label: 'T-06', floor: PosFloor.indoor, seats: 8),

    // Rooftop Terrace
    PosFloorTable(label: 'T-07', floor: PosFloor.rooftop, seats: 4),
    PosFloorTable(
      label: 'T-08',
      floor: PosFloor.rooftop,
      seats: 2,
      status: PosTableStatus.occupied,
      detail: '2 Guests',
    ),
    PosFloorTable(label: 'T-09', floor: PosFloor.rooftop, seats: 4),
    PosFloorTable(label: 'T-10', floor: PosFloor.rooftop, seats: 6),
    PosFloorTable(
      label: 'T-11',
      floor: PosFloor.rooftop,
      seats: 4,
      status: PosTableStatus.reserved,
      detail: '20:00',
    ),
    PosFloorTable(label: 'T-12', floor: PosFloor.rooftop, seats: 8),

    // Family Lounge
    PosFloorTable(label: 'F-01', floor: PosFloor.family, seats: 6),
    PosFloorTable(
      label: 'F-02',
      floor: PosFloor.family,
      seats: 8,
      status: PosTableStatus.occupied,
      detail: '8 Guests',
    ),
    PosFloorTable(label: 'F-03', floor: PosFloor.family, seats: 10),
    PosFloorTable(label: 'F-04', floor: PosFloor.family, seats: 6),
    PosFloorTable(
      label: 'F-05',
      floor: PosFloor.family,
      seats: 12,
      status: PosTableStatus.reserved,
      detail: '21:00',
    ),
    PosFloorTable(label: 'F-06', floor: PosFloor.family, seats: 4),
  ];

  // tables available to the current branch
  static List<String> get tables => floorTables
      .map((PosFloorTable table) => table.selectionLabel)
      .toList(growable: false);

  static const String defaultTable = 'T-04 (Indoor)';

  static const List<int> paxOptions = [1, 2, 3, 4, 5, 6, 7, 8, 10, 12];

  static const int defaultPax = 3;

  // current invoice / ticket number
  static const int invoiceNumber = 1042;

  // branch details printed on the thermal receipt
  static const String branchName = 'Sultans Dine Group';
  static const String branchCode = 'Main Branch (DHK-01)';
  static const String branchAddress = 'House 42, Road 11, Banani, Dhaka';
  static const String branchBin = 'BIN: 002938172-0101 · Mushak-6.3';
  static const String cashierName = 'Tanvir R.';

  // floor server pre selected on a fresh ticket
  static const String defaultServer = cashierName;

  // tax added on top of the subtotal, in percent
  static const double taxPercent = 5;

  // default bKash/Nagad cashout charge, in percent
  static const double mobileWalletCashoutPercent = 1.5;
}
