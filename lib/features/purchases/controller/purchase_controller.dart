import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/purchases/dummy_data/dummy_purchase_data.dart';
import 'package:omnix/features/purchases/dummy_data/dummy_vendor_data.dart';
import 'package:omnix/features/purchases/model/purchase_model.dart';
import 'package:omnix/features/purchases/model/vendor_model.dart';

/// Which panel the purchases page shows below the tabs.
enum PurchasesTab { purchaseOrders, vendors }

class PurchaseController extends GetxController {
  final List<String> statusFilters = DummyPurchaseData.statusFilters;

  // choices offered by the Register Supplier dialog
  static const List<String> supplierCategories = [
    'Protein & Meat',
    'Rice & Grains',
    'Oils & Masala',
    'Dairy',
    'Produce',
    'Packaging',
    'Beverages',
    'Other',
  ];

  static const List<String> supplierTiers = ['Tier 1', 'Tier 2', 'Tier 3'];

  static const List<String> creditTerms = [
    'Immediate / EFT',
    'Cash on Delivery',
    'Net 7 Days',
    'Net 15 Days',
    'Net 30 Days',
    '50% Advance / Net 30',
  ];

  // destinations a purchase order can be delivered to
  static const List<String> destinations = [
    'Dhanmondi Central Commissary',
    'Main Dry Store',
    'Cold Room Intake',
  ];

  // units a commodity line can be measured in, mirrors the stock units
  static const List<String> lineUnits = ['kg', 'g', 'L', 'pcs', 'case'];

  final selectedStatus = 0.obs;

  final selectedTab = PurchasesTab.purchaseOrders.obs;

  final searchText = ''.obs;

  final purchases = <Purchase>[].obs;

  final vendors = <Vendor>[].obs;

  // scale readings kept per PO when an inspection is saved as a draft
  final RxMap<String, List<double>> inspectionDrafts =
      <String, List<double>>{}.obs;

  // purchase order shown in the receive dock, null when nothing is selected
  final RxnString selectedPurchaseId = RxnString();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPurchases();
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchPurchases() async {
    isLoading.value = true;

    // swap this for the API call, the shape stays the same
    // final response = await api.get('/purchases');
    // purchases.assignAll(
    //   (response as List)
    //       .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    purchases.assignAll(DummyPurchaseData.purchases);
    vendors.assignAll(DummyVendorData.vendors);

    _ensureSelection();
    isLoading.value = false;
  }

  void selectTab(PurchasesTab tab) => selectedTab.value = tab;

  void statusFilterOnChanged(int index) {
    selectedStatus.value = index;
    _ensureSelection();
  }

  void searchOnChanged(String value) {
    searchText.value = value;
    _ensureSelection();
  }

  void selectPurchase(String id) => selectedPurchaseId.value = id;

  // purchases matching the current status filter and the search text
  List<Purchase> get filteredPurchases {
    final String query = searchText.value.trim().toLowerCase();

    return purchases.where((Purchase purchase) {
      final bool matchesStatus = _matchesStatus(purchase.status);
      final bool matchesSearch =
          query.isEmpty ||
          purchase.id.toLowerCase().contains(query) ||
          purchase.supplier.toLowerCase().contains(query) ||
          purchase.supplierId.toLowerCase().contains(query) ||
          purchase.commodities.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  // purchase shown in the receive dock, kept inside the visible filter
  Purchase? get selectedPurchase {
    final String? id = selectedPurchaseId.value;
    if (id == null) return null;

    for (final Purchase purchase in filteredPurchases) {
      if (purchase.id == id) return purchase;
    }

    return null;
  }

  bool _matchesStatus(PurchaseStatus status) {
    final int index = selectedStatus.value;

    // the first filter is "All"
    if (index == 0) return true;

    return statusFilters[index] == status.label;
  }

  // Headline numbers of the stat ribbon --------------------------------------

  int get activeSupplierCount => vendors.length;

  int get openPurchaseCount =>
      purchases.where((Purchase purchase) => purchase.isOpen).length;

  // open POs expected to land today, used by the second metric caption
  int get arrivingTodayCount => purchases
      .where(
        (Purchase purchase) =>
            purchase.isOpen && (purchase.expectedAt ?? '').contains('Today'),
      )
      .length;

  int get monthToDateSpend => purchases
      .where((Purchase purchase) => purchase.status != PurchaseStatus.cancelled)
      .fold(0, (int sum, Purchase purchase) => sum + purchase.amount);

  int get outstandingPayables => purchases
      .where((Purchase purchase) => purchase.status != PurchaseStatus.cancelled)
      .fold(0, (int sum, Purchase purchase) => sum + purchase.balanceDue);

  int get payableInvoiceCount => purchases
      .where(
        (Purchase purchase) =>
            purchase.status != PurchaseStatus.cancelled &&
            purchase.balanceDue > 0,
      )
      .length;

  int get filteredTotal => filteredPurchases.fold(
    0,
    (int sum, Purchase purchase) => sum + purchase.amount,
  );

  // Supplier onboarding ------------------------------------------------------

  /// Adds a supplier to the directory from the Register Supplier dialog.
  // TODO: swap for POST /vendors once the API is live and use the id the
  // server returns; it owns the id sequence.
  Vendor registerSupplier({
    required String name,
    required String category,
    required String tier,
    required String creditTerms,
    required String representative,
    required String phone,
    required String description,
  }) {
    final Vendor vendor = Vendor(
      id: _nextVendorId(),
      name: name.trim(),
      tier: tier,
      category: category,
      description: description.trim(),
      creditTerms: creditTerms,
      outstanding: 0,
      lifetimeSpend: 0,
      representative: representative.trim(),
      phone: phone.trim(),
    );

    vendors.insert(0, vendor);
    _notify(
      'Supplier registered',
      '${vendor.name} is now an approved vendor.',
    );
    return vendor;
  }

  // Purchase order creation --------------------------------------------------

  /// Raises a new purchase order from the New Purchase Order dialog and puts
  /// it at the top of the ledger so it is visible right away.
  // TODO: swap for POST /purchases once the API is live and use the id the
  // server returns.
  Purchase createPurchase({
    required Vendor vendor,
    required String destination,
    required DateTime? expectedAt,
    required PaymentStatus paymentStatus,
    required int paidAmount,
    required List<PurchaseLine> lines,
  }) {
    final int total = lines.fold(
      0,
      (int sum, PurchaseLine line) => sum + line.total,
    );

    final Purchase purchase = Purchase(
      id: _nextPurchaseId(),
      supplierId: vendor.id,
      supplier: vendor.name,
      destination: destination,
      status: PurchaseStatus.ordered,
      paymentStatus: paymentStatus,
      lines: lines,
      paidAmount: paidAmount.clamp(0, total),
      orderedAt: 'Today, ${formatClock(DateTime.now())}',
      expectedAt: expectedAt == null ? null : formatSchedule(expectedAt),
      gate: 'Bay 01',
    );

    purchases.insert(0, purchase);

    // clear any filter so the new order is guaranteed to be visible
    searchText.value = '';
    selectedStatus.value = 0;
    selectedTab.value = PurchasesTab.purchaseOrders;
    selectedPurchaseId.value = purchase.id;

    _notify(
      'Purchase order raised',
      '${purchase.id} was sent to ${vendor.name}.',
    );
    return purchase;
  }

  // Inspection drafts --------------------------------------------------------

  /// Keeps the dock scale readings of [purchase] while the inspector finishes
  /// the physical check.
  // TODO: swap for POST /purchases/:id/inspection once the API is live.
  void saveInspectionDraft(Purchase purchase, List<double> readings) {
    inspectionDrafts[purchase.id] = List<double>.of(readings);
    _notify(
      'Inspection draft saved',
      '${purchase.id} verified weights were kept on this device.',
    );
  }

  bool hasInspectionDraft(String id) => inspectionDrafts.containsKey(id);

  // Receive actions ----------------------------------------------------------

  /// Marks [purchase] as fully received at the gate. Kept in memory while the
  /// backend is offline.
  // TODO: swap for POST /purchases/:id/receive once the API is live
  void receivePurchase(Purchase purchase) {
    final int index = purchases.indexOf(purchase);
    if (index < 0) return;

    purchases[index] = purchase.copyWith(
      status: PurchaseStatus.received,
      receivedAt: 'Today, ${formatClock(DateTime.now())}',
      receivedBy: 'Tanvir R.',
    );
    inspectionDrafts.remove(purchase.id);

    _notify(
      'Stock received',
      '${purchase.id} was committed to the inventory ledger.',
    );
  }

  // Export -------------------------------------------------------------------

  /// Copies the visible purchase orders to the clipboard as CSV, the same
  /// shape the reports screen will download once the backend is live.
  Future<void> exportPurchases() async {
    final List<Purchase> rows = filteredPurchases;

    final List<List<String>> table = <List<String>>[
      <String>[
        'PO',
        'Supplier',
        'Vendor ID',
        'Destination',
        'Status',
        'Payment',
        'Ordered',
        'Expected',
        'Received',
        'Lines',
        'Commodities',
        'Amount',
        'Paid',
        'Balance',
      ],
      ...rows.map((Purchase purchase) {
        return <String>[
          purchase.id,
          purchase.supplier,
          purchase.supplierId,
          purchase.destination,
          purchase.status.label,
          purchase.paymentStatus.label,
          purchase.orderedAt,
          purchase.expectedAt ?? '',
          purchase.receivedAt ?? '',
          '${purchase.lineCount}',
          purchase.commodities,
          '${purchase.amount}',
          '${purchase.paidAmount}',
          '${purchase.balanceDue}',
        ];
      }),
    ];

    final String csv = table
        .map((List<String> row) => row.map(_csvCell).join(','))
        .join('\n');

    await Clipboard.setData(ClipboardData(text: csv));
    _notify(
      'Ledger exported',
      '${rows.length} purchase orders copied to the clipboard as CSV.',
    );
  }

  String _csvCell(String value) {
    final String escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  void _notify(String title, String message) {
    if (Get.context == null) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.sidebarBackgroundBlack,
      colorText: AppTheme.lightAmberWhite,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  // keeps the receive dock pointed at a visible open PO, falling back to the
  // first visible row so the dock is never empty while the list has data
  void _ensureSelection() {
    final List<Purchase> visible = filteredPurchases;

    if (visible.isEmpty) {
      selectedPurchaseId.value = null;
      return;
    }

    final String? current = selectedPurchaseId.value;
    if (current != null && visible.any((Purchase p) => p.id == current)) {
      return;
    }

    final Purchase first = visible.firstWhere(
      (Purchase purchase) => purchase.isOpen,
      orElse: () => visible.first,
    );
    selectedPurchaseId.value = first.id;
  }

  // finds the highest number in use so ids never collide with a dummy row
  String _nextPurchaseId() {
    int highest = 0;

    for (final Purchase purchase in purchases) {
      final int? number = int.tryParse(
        purchase.id.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (number != null && number > highest) highest = number;
    }

    return 'PO-${highest + 1}';
  }

  String _nextVendorId() {
    int highest = 0;

    for (final Vendor vendor in vendors) {
      final int? number = int.tryParse(vendor.id.replaceAll(RegExp(r'[^0-9]'), ''));
      if (number != null && number > highest) highest = number;
    }

    return 'V-${(highest + 1).toString().padLeft(4, '0')}';
  }
}
