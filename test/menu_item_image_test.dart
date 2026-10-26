import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnix/features/menu/dummy_data/dummy_menu_item_data.dart';
import 'package:omnix/features/menu/model/menu_item_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every dummy dish ships a branch id and a bundled picture', () async {
    for (final MenuItem item in DummyMenuItemData.menuItems) {
      expect(item.branchId, isNotEmpty, reason: '${item.id} has no branch id');
      expect(item.imageUrl, isNotEmpty, reason: '${item.id} has no picture');

      // A typo in the asset path would silently fall back to an empty tile, so
      // the bundle is checked directly instead of trusting the widget.
      final ByteData data = await rootBundle.load(item.imageUrl);
      expect(data.lengthInBytes, greaterThan(1000), reason: item.imageUrl);
    }
  });
}
