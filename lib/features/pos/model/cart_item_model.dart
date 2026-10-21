// One line of the POS cart
class CartItem {
  const CartItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.note,
  });

  final String menuItemId;
  final String name;
  final int price;
  final int quantity;

  // optional kitchen note shown under the item name
  final String? note;

  // line total, price times the quantity
  int get lineTotal => price * quantity;

  CartItem copyWith({int? quantity, String? note}) {
    return CartItem(
      menuItemId: menuItemId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}
