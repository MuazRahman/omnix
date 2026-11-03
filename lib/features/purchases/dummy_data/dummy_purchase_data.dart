import 'package:omnix/features/purchases/model/purchase_model.dart';

/// Temporary data for the Purchases section.
///
/// Delete this file once the backend returns real purchase orders.
class DummyPurchaseData {
  const DummyPurchaseData._();

  static const List<String> statusFilters = [
    'All',
    'Awaiting Delivery',
    'In Transit',
    'Received',
    'Draft',
    'Cancelled',
  ];

  static const List<Purchase> purchases = [
    Purchase(
      id: 'PO-489',
      supplierId: 'V-8941',
      supplier: 'Bengal Meat Agro Supply Ltd',
      destination: 'Dhanmondi Central Commissary',
      status: PurchaseStatus.ordered,
      paymentStatus: PaymentStatus.unpaid,
      lines: [
        PurchaseLine(
          name: 'Bone-in Mutton (Halal)',
          quantity: 120,
          unit: 'kg',
          unitPrice: 1000,
        ),
        PurchaseLine(
          name: 'Prime Beef Chuck',
          quantity: 40,
          unit: 'kg',
          unitPrice: 700,
        ),
      ],
      orderedAt: 'Oct 24, 07:30 AM',
      expectedAt: 'Today, 11:00 AM',
      gate: 'Bay 02',
    ),
    Purchase(
      id: 'PO-488',
      supplierId: 'V-3312',
      supplier: 'Meghna Rice Mills',
      destination: 'Main Dry Store',
      status: PurchaseStatus.inTransit,
      paymentStatus: PaymentStatus.partial,
      lines: [
        PurchaseLine(
          name: 'Premium Kalijira Rice',
          quantity: 500,
          unit: 'kg',
          unitPrice: 90,
        ),
      ],
      paidAmount: 20000,
      orderedAt: 'Oct 23, 02:15 PM',
      expectedAt: 'Oct 25, 09:00 AM',
      carrier: 'SA Paribahan',
      gate: 'Dry Store',
    ),
    Purchase(
      id: 'PO-487',
      supplierId: 'V-1102',
      supplier: 'ACI Pure Oils & Spices',
      destination: 'Main Dry Store',
      status: PurchaseStatus.received,
      paymentStatus: PaymentStatus.paid,
      lines: [
        PurchaseLine(
          name: 'Mustard Oil',
          quantity: 80,
          unit: 'L',
          unitPrice: 350,
        ),
        PurchaseLine(
          name: 'Pure Ghee',
          quantity: 45,
          unit: 'kg',
          unitPrice: 600,
        ),
        PurchaseLine(
          name: 'Green Cardamom',
          quantity: 20,
          unit: 'kg',
          unitPrice: 350,
        ),
      ],
      paidAmount: 62000,
      orderedAt: 'Oct 21, 10:00 AM',
      receivedAt: 'Oct 22, 04:00 PM',
      receivedBy: 'Tanvir R.',
      gate: 'Dry Store',
    ),
    Purchase(
      id: 'PO-486',
      supplierId: 'V-7744',
      supplier: 'Dhaka Dairy Co-op',
      destination: 'Cold Room Intake',
      status: PurchaseStatus.received,
      paymentStatus: PaymentStatus.paid,
      lines: [
        PurchaseLine(
          name: 'Whole Buffalo Milk',
          quantity: 150,
          unit: 'L',
          unitPrice: 120,
        ),
      ],
      paidAmount: 18000,
      orderedAt: 'Oct 20, 06:00 AM',
      receivedAt: 'Oct 20, 08:30 AM',
      receivedBy: 'Tanvir R.',
      gate: 'Cold Room',
    ),
    Purchase(
      id: 'PO-485',
      supplierId: 'V-4021',
      supplier: 'Green Valley Farms',
      destination: 'Dhanmondi Central Commissary',
      status: PurchaseStatus.ordered,
      paymentStatus: PaymentStatus.unpaid,
      lines: [
        PurchaseLine(name: 'Tomato', quantity: 60, unit: 'kg', unitPrice: 70),
        PurchaseLine(name: 'Onion', quantity: 80, unit: 'kg', unitPrice: 50),
        PurchaseLine(name: 'Lettuce', quantity: 25, unit: 'kg', unitPrice: 180),
      ],
      orderedAt: 'Oct 19, 05:40 PM',
      expectedAt: 'Tomorrow, 07:00 AM',
      gate: 'Bay 01',
    ),
    Purchase(
      id: 'PO-484',
      supplierId: 'V-5560',
      supplier: 'Sultans Packaging Co.',
      destination: 'Main Dry Store',
      status: PurchaseStatus.received,
      paymentStatus: PaymentStatus.paid,
      lines: [
        PurchaseLine(
          name: 'Kraft Meal Box',
          quantity: 2000,
          unit: 'pcs',
          unitPrice: 12,
        ),
        PurchaseLine(
          name: 'Paper Carry Bag',
          quantity: 5000,
          unit: 'pcs',
          unitPrice: 2,
        ),
      ],
      paidAmount: 34000,
      orderedAt: 'Oct 18, 11:10 AM',
      receivedAt: 'Oct 19, 09:15 AM',
      receivedBy: 'Rakib H.',
      gate: 'Dry Store',
    ),
  ];
}
