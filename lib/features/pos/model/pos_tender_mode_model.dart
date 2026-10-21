// Payment method selected for the current POS ticket
enum PosTenderMode {
  cash('Cash'),
  mobileWallet('bKash / Nagad'),
  card('POS Card');

  const PosTenderMode(this.label);

  final String label;
}
