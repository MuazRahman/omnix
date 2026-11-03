import 'package:omnix/features/purchases/model/vendor_model.dart';

/// Temporary vendor directory for the Purchases section.
///
/// Delete this file once the backend returns real suppliers.
class DummyVendorData {
  const DummyVendorData._();

  static const List<Vendor> vendors = [
    Vendor(
      id: 'V-8941',
      name: 'Bengal Meat Agro Supply Ltd',
      tier: 'Tier 1',
      category: 'Protein & Meat',
      description: 'Fresh mutton, chuck beef, tenderloin and marrow bones.',
      creditTerms: 'Net 15 Days',
      outstanding: 148000,
      lifetimeSpend: 1845000,
      representative: 'Nazmul H.',
      phone: '+880 1711-000000',
    ),
    Vendor(
      id: 'V-3312',
      name: 'Meghna Rice Mills',
      tier: 'Tier 1',
      category: 'Rice & Grains',
      description: 'Kataribhog, Kalijira and aged long-grain biryani rice.',
      creditTerms: '50% Advance / Net 30',
      outstanding: 24500,
      lifetimeSpend: 912000,
      representative: 'Farhan K.',
      phone: '+880 1912-111222',
    ),
    Vendor(
      id: 'V-1102',
      name: 'ACI Pure Oils & Spices',
      tier: 'Tier 2',
      category: 'Oils & Masala',
      description: 'Mustard oil, butter ghee, cardamom, cinnamon and cloves.',
      creditTerms: 'Immediate / EFT',
      outstanding: 0,
      lifetimeSpend: 680000,
      representative: 'Asif M.',
      phone: '+880 1819-333444',
    ),
    Vendor(
      id: 'V-7744',
      name: 'Dhaka Dairy Co-op',
      tier: 'Tier 2',
      category: 'Dairy',
      description: 'Whole buffalo milk, cream, paneer and yoghurt starter.',
      creditTerms: 'Cash on Delivery',
      outstanding: 0,
      lifetimeSpend: 415000,
      representative: 'Shirin A.',
      phone: '+880 1755-444555',
    ),
    Vendor(
      id: 'V-4021',
      name: 'Green Valley Farms',
      tier: 'Tier 2',
      category: 'Produce',
      description: 'Seasonal vegetables, herbs and salad greens.',
      creditTerms: 'Net 7 Days',
      outstanding: 12600,
      lifetimeSpend: 268000,
      representative: 'Rasel B.',
      phone: '+880 1733-666777',
    ),
    Vendor(
      id: 'V-5560',
      name: 'Sultans Packaging Co.',
      tier: 'Tier 3',
      category: 'Packaging',
      description: 'Kraft meal boxes, paper bags and thermal receipt rolls.',
      creditTerms: 'Immediate / EFT',
      outstanding: 0,
      lifetimeSpend: 154000,
      representative: 'Mita D.',
      phone: '+880 1722-888999',
    ),
  ];
}
