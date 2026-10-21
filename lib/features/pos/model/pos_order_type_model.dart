// How the current POS ticket is served
enum PosOrderType {
  dineIn('Dine-in'),
  takeaway('Takeaway'),
  delivery('Delivery');

  const PosOrderType(this.label);

  final String label;
}
