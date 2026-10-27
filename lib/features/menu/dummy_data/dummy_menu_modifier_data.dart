import 'package:omnix/features/menu/model/menu_modifier_group_model.dart';

/// Temporary modifier presets for the Menu section.
///
/// Delete this file once the backend returns real modifier groups.
class DummyMenuModifierData {
  const DummyMenuModifierData._();

  static const List<MenuModifierGroup> groups = [
    MenuModifierGroup(
      name: 'Spice Intensity Tier',
      isMandatory: true,
      dishCount: 12,
      options: [
        MenuModifierOption(name: 'Standard Dhaka Traditional'),
        MenuModifierOption(name: 'Naga Fire Spicy', priceDelta: 25),
        MenuModifierOption(name: 'Mild / Less Chili (Family)'),
      ],
    ),
    MenuModifierGroup(
      name: 'Protein Add-ons',
      multiSelect: true,
      dishCount: 8,
      options: [
        MenuModifierOption(name: 'Extra Mutton Shank (180g)', priceDelta: 180),
        MenuModifierOption(name: 'Extra Shahi Potato (আলু)', priceDelta: 30),
        MenuModifierOption(name: 'Boiled Masala Egg', priceDelta: 25),
      ],
    ),
    MenuModifierGroup(
      name: 'Sides & Extras',
      multiSelect: true,
      dishCount: 10,
      options: [
        MenuModifierOption(name: 'Extra Butter', priceDelta: 15),
        MenuModifierOption(name: 'Cheese Slice', priceDelta: 40),
        MenuModifierOption(name: 'Green Salad', priceDelta: 20),
      ],
    ),
    MenuModifierGroup(
      name: 'Drink Pairings',
      multiSelect: true,
      dishCount: 6,
      options: [
        MenuModifierOption(name: 'Borhani Glass (250ml)', priceDelta: 90),
        MenuModifierOption(name: 'Soft Drink Can', priceDelta: 60),
      ],
    ),
  ];
}
