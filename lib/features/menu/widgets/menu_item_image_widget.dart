import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:omnix/core/theme/app_theme.dart';

/// Dish picture used by the POS grid and the menu table.
///
/// [imageUrl] is either a bundled asset path (`assets/images/menu/...`) or an
/// absolute URL once the menu editor uploads real pictures. [imageBytes] holds
/// a picture picked in the add-dish dialog until it can be uploaded. A missing
/// or broken file simply leaves an empty dark tile.
class MenuItemImageWidget extends StatelessWidget {
  const MenuItemImageWidget({
    super.key,
    required this.imageUrl,
    this.imageBytes,
  });

  final String imageUrl;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return ColoredBox(
        color: AppTheme.windowWidgetBackgroundBlack,
        child: Image.memory(
          imageBytes!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stack) {
                return _buildPlaceholder();
              },
        ),
      );
    }

    final String path = imageUrl.trim();

    if (path.isEmpty) return _buildPlaceholder();

    final Uri? uri = Uri.tryParse(path);
    final bool isRemote =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    return ColoredBox(
      color: AppTheme.windowWidgetBackgroundBlack,
      child: isRemote
          ? Image.network(
              path,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              loadingBuilder:
                  (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? progress,
                  ) {
                    return progress == null ? child : _buildPlaceholder();
                  },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stack) {
                    return _buildPlaceholder();
                  },
            )
          : Image.asset(
              path,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stack) {
                    return _buildPlaceholder();
                  },
            ),
    );
  }

  // Keeps the tile layout intact while the picture loads or if it is missing
  Widget _buildPlaceholder() {
    return const ColoredBox(color: AppTheme.windowWidgetBackgroundBlack);
  }
}
