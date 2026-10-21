import 'package:get/get.dart';
import 'package:omnix/features/menu/dummy_data/dummy_menu_item_data.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';
import 'package:omnix/features/pos/dummy_data/dummy_pos_data.dart';
import 'package:omnix/features/pos/model/cart_item_model.dart';
import 'package:omnix/features/pos/model/pos_customer_model.dart';
import 'package:omnix/features/pos/model/pos_order_type_model.dart';
import 'package:omnix/features/pos/model/pos_tender_mode_model.dart';

class PosController extends GetxController {
  final List<String> categories = DummyMenuItemData.categories;

  final List<String> tables = DummyPosData.tables;

  final List<int> paxOptions = DummyPosData.paxOptions;

  // customer attached to the current ticket, empty for a walk-in sale
  final customer = Rxn<PosCustomer>();

  final String branchName = DummyPosData.branchName;

  final String branchCode = DummyPosData.branchCode;

  final String branchAddress = DummyPosData.branchAddress;

  final String branchBin = DummyPosData.branchBin;

  final String cashierName = DummyPosData.cashierName;

  final selectedCategory = 0.obs;

  final searchText = ''.obs;

  final menuItems = <MenuItem>[].obs;

  final cart = <CartItem>[].obs;

  // order being built on this ticket
  final orderType = PosOrderType.dineIn.obs;

  final tableLabel = DummyPosData.tables.first.obs;

  final paxCount = DummyPosData.defaultPax.obs;

  // checkout state
  final tenderMode = PosTenderMode.cash.obs;

  final cashReceived = 0.obs;

  // bKash/Nagad cashout charge, applied only to mobile wallet payments
  final mobileWalletCashoutPercent =
      DummyPosData.mobileWalletCashoutPercent.obs;

  final invoiceNumber = DummyPosData.invoiceNumber.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMenuItems();
    cart.assignAll(DummyPosData.initialCart);
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchMenuItems() async {
    // swap this for the API call, the shape stays the same
    // final response = await api.get('/menu/items');
    // menuItems.assignAll(
    //   (response as List)
    //       .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    menuItems.assignAll(DummyMenuItemData.menuItems);
  }

  void categoryOnChanged(int index) {
    selectedCategory.value = index;
  }

  void searchOnChanged(String value) {
    searchText.value = value;
  }

  void orderTypeOnChanged(PosOrderType value) {
    orderType.value = value;
  }

  // Tables and guest counts only apply when the ticket is served dine-in.
  bool get isDineIn => orderType.value == PosOrderType.dineIn;

  void tableOnChanged(String value) {
    tableLabel.value = value;
  }

  void paxOnChanged(int value) {
    paxCount.value = value;
  }

  void customerOnChanged(PosCustomer? value) {
    customer.value = value;
  }

  bool get hasCustomerPhone {
    return customer.value?.phone.trim().isNotEmpty ?? false;
  }

  bool get canPrint => cart.isNotEmpty && hasCustomerPhone;

  void tenderModeOnChanged(PosTenderMode value) {
    if (tenderMode.value == value) return;

    tenderMode.value = value;

    // cash is entered by the cashier; card and wallet settle the exact amount
    cashReceived.value = value == PosTenderMode.cash ? 0 : total;
  }

  void setMobileWalletCashoutPercent(double value) {
    mobileWalletCashoutPercent.value = value.clamp(0, 100).toDouble();

    // wallet payments settle the exact amount, including the cashout charge
    if (tenderMode.value == PosTenderMode.mobileWallet) {
      cashReceived.value = total;
    }
  }

  void setCashReceived(int amount) {
    tenderMode.value = PosTenderMode.cash;
    cashReceived.value = amount;
  }

  // menu items matching the current category and the search text
  List<MenuItem> get filteredItems {
    final String query = searchText.value.trim().toLowerCase();
    final String category = categories[selectedCategory.value];

    return menuItems.where((MenuItem item) {
      final bool matchesCategory =
          category == 'All' || item.category == category;
      final bool matchesSearch =
          query.isEmpty || item.name.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // quantity of one menu item already sitting in the cart
  int quantityInCart(String menuItemId) {
    final int index = cart.indexWhere(
      (CartItem line) => line.menuItemId == menuItemId,
    );
    return index == -1 ? 0 : cart[index].quantity;
  }

  // adds an item to the cart, or bumps the quantity when it is already there
  void addToCart(MenuItem item) {
    if (!item.isAvailable) return;

    final int index = cart.indexWhere(
      (CartItem line) => line.menuItemId == item.id,
    );

    if (index == -1) {
      cart.add(
        CartItem(
          menuItemId: item.id,
          name: item.name,
          price: item.price,
          quantity: 1,
        ),
      );
      return;
    }

    cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
  }

  // adds one more unit of an item already in the cart
  void addToCartId(String menuItemId) {
    final int index = cart.indexWhere(
      (CartItem line) => line.menuItemId == menuItemId,
    );
    if (index == -1) return;

    cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
  }

  // removes one unit, the line is dropped when it reaches zero
  void removeFromCart(String menuItemId) {
    final int index = cart.indexWhere(
      (CartItem line) => line.menuItemId == menuItemId,
    );
    if (index == -1) return;

    final int quantity = cart[index].quantity - 1;

    if (quantity <= 0) {
      cart.removeAt(index);
      return;
    }

    cart[index] = cart[index].copyWith(quantity: quantity);
  }

  // drops a whole line from the cart
  void removeLine(String menuItemId) {
    cart.removeWhere((CartItem line) => line.menuItemId == menuItemId);
  }

  void clearCart() {
    cart.clear();
    cashReceived.value = 0;
  }

  // clears the ticket and moves on to the next invoice number
  void startNewSale() {
    cart.clear();
    searchText.value = '';
    selectedCategory.value = 0;
    cashReceived.value = 0;
    tenderMode.value = PosTenderMode.cash;
    customer.value = null;
    invoiceNumber.value += 1;
  }

  // fills the cash amount that will be printed on the receipt
  void prepareCheckout() {
    if (tenderMode.value == PosTenderMode.cash) {
      // An untouched cash field settles at the exact total. A lower amount is
      // kept and printed as a discount.
      if (cashReceived.value == 0) {
        cashReceived.value = total;
      }
      return;
    }

    cashReceived.value = total;
  }

  void holdOrder() {
    // TODO: persist the current cart as a held ticket
  }

  void splitBill() {
    // TODO: open the split bill flow
  }

  void printKitchenTicket() {
    // TODO: send the current cart to the kitchen printer
  }

  int get itemCount {
    return cart.fold(0, (int sum, CartItem line) => sum + line.quantity);
  }

  int get subtotal {
    return cart.fold(0, (int sum, CartItem line) => sum + line.lineTotal);
  }

  double get taxPercent => DummyPosData.taxPercent;

  int get tax {
    return (subtotal * taxPercent / 100).round();
  }

  int get totalBeforeCashout => subtotal + tax;

  int get mobileWalletCashoutCharge {
    if (tenderMode.value != PosTenderMode.mobileWallet) return 0;

    return (totalBeforeCashout * mobileWalletCashoutPercent.value / 100)
        .round();
  }

  int get total => totalBeforeCashout + mobileWalletCashoutCharge;

  int get changeDue {
    if (tenderMode.value != PosTenderMode.cash) return 0;

    final int change = cashReceived.value - total;
    return change > 0 ? change : 0;
  }

  // A cash tender below the net payable is treated as a settlement discount,
  // so the receipt balances without leaving a shortfall. An empty field is not
  // a discount; prepareCheckout() fills it with the exact total.
  int get discountAmount {
    if (tenderMode.value != PosTenderMode.cash) return 0;
    if (cashReceived.value <= 0) return 0;

    final int discount = total - cashReceived.value;
    return discount > 0 ? discount : 0;
  }

  // exact, then the next two round cash notes for the tender shortcuts
  List<int> get quickCashAmounts {
    final int exact = total;
    final int first =
        ((exact / 500).ceil() * 500) + (exact % 500 == 0 ? 500 : 0);
    final int second =
        ((first / 1000).ceil() * 1000) + (first % 1000 == 0 ? 1000 : 0);

    return [exact, first, second];
  }
}
