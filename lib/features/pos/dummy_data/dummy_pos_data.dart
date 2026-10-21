import 'package:omnix/features/pos/model/cart_item_model.dart';

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

  // tables available to the current branch
  static const List<String> tables = [
    'T-04 (Indoor)',
    'T-01 (Indoor)',
    'T-02 (Indoor)',
    'T-07 (Terrace)',
    'T-09 (Terrace)',
  ];

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

  // tax added on top of the subtotal, in percent
  static const double taxPercent = 5;

  // default bKash/Nagad cashout charge, in percent
  static const double mobileWalletCashoutPercent = 1.5;
}
