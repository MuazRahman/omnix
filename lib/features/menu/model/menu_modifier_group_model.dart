/// One choice inside a modifier group, e.g. "Extra Mutton Shank".
class MenuModifierOption {
  const MenuModifierOption({required this.name, this.priceDelta = 0});

  final String name;
  final int priceDelta;
}

/// A reusable set of options applied to dishes, e.g. "Spice Intensity".
class MenuModifierGroup {
  const MenuModifierGroup({
    required this.name,
    required this.options,
    required this.dishCount,
    this.isMandatory = false,
    this.multiSelect = false,
  });

  final String name;
  final List<MenuModifierOption> options;
  final int dishCount;

  // the guest has to pick exactly one option
  final bool isMandatory;

  // the guest can stack several options from this group
  final bool multiSelect;

  String get ruleLabel {
    if (isMandatory) return 'Mandatory · 1 pick';
    if (multiSelect) return 'Multi-select';
    return 'Optional';
  }
}
