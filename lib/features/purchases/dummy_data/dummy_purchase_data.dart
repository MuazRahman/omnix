import 'package:omnix/features/purchases/model/purchase_model.dart';

/// Temporary data for the Purchases section.
///
/// Delete this file once the backend returns real purchase orders.
class DummyPurchaseData {
  const DummyPurchaseData._();

  static const List<String> statusFilters = [
    'All',
    'Draft',
    'Ordered',
    'Received',
    'Cancelled',
  ];

  static const List<Purchase> purchases = [
    Purchase(
      id: 'PO-2041',
      supplier: 'Fresh Foods Ltd',
      itemsSummary: 'Beef, Chicken, Fish',
      status: PurchaseStatus.ordered,
      amount: 42800,
      orderedAt: 'Today, 11:20 AM',
    ),
    Purchase(
      id: 'PO-2040',
      supplier: 'Green Valley Farms',
      itemsSummary: 'Tomato, Onion, Lettuce',
      status: PurchaseStatus.received,
      amount: 12400,
      orderedAt: 'Today, 9:05 AM',
    ),
    Purchase(
      id: 'PO-2039',
      supplier: 'Dairy Partners',
      itemsSummary: 'Milk, Butter, Cheese',
      status: PurchaseStatus.draft,
      amount: 18600,
      orderedAt: 'Yesterday, 6:30 PM',
    ),
    Purchase(
      id: 'PO-2038',
      supplier: 'Sunrise Beverages',
      itemsSummary: 'Coke, Lemon Tea Mix',
      status: PurchaseStatus.received,
      amount: 22300,
      orderedAt: 'Yesterday, 2:15 PM',
    ),
    Purchase(
      id: 'PO-2037',
      supplier: 'Grain Traders',
      itemsSummary: 'Rice, Flour, Cooking Oil',
      status: PurchaseStatus.cancelled,
      amount: 31500,
      orderedAt: '2 days ago',
    ),
    Purchase(
      id: 'PO-2036',
      supplier: 'Fresh Foods Ltd',
      itemsSummary: 'Chicken Breast',
      status: PurchaseStatus.received,
      amount: 9800,
      orderedAt: '3 days ago',
    ),
    Purchase(
      id: 'PO-2035',
      supplier: 'Green Valley Farms',
      itemsSummary: 'Mixed Vegetables',
      status: PurchaseStatus.ordered,
      amount: 7600,
      orderedAt: '4 days ago',
    ),
  ];
}
