import 'package:omnix/core/config/app_config.dart';
import 'package:omnix/core/routes/app_routes.dart';
import 'package:omnix/features/receipt/model/receipt_document.dart';

/// Builds and reads the hosted receipt URL.
///
/// Hash routing is used on purpose: `https://host/#/receipt?d=...` works on
/// static hosts without a rewrite rule. The page can later accept an
/// `invoice` query parameter and fetch the document from the API instead.
abstract final class ReceiptLink {
  const ReceiptLink._();

  static Uri forDocument(ReceiptDocument document) {
    final Uri base = Uri.parse(AppConfig.receiptBaseUrl);
    final String path = base.path.isEmpty
        ? '/'
        : (base.path.endsWith('/') ? base.path : '${base.path}/');
    final Uri normalizedBase = base.replace(path: path);

    return normalizedBase.replace(
      fragment:
          '${AppRoutes.receipt}?d=${Uri.encodeQueryComponent(document.encode())}',
    );
  }

  /// The receipt request carried by the current browser URL, if any.
  static Uri? requestFromLocation() => requestFromUri(Uri.base);

  /// Parses a route name supplied by Flutter's navigator.
  static Uri? requestFromRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty) return null;
    return requestFromUri(Uri.parse(routeName));
  }

  /// Accepts both path URLs (`/receipt?d=...`) and hash URLs
  /// (`/#/receipt?d=...`).
  static Uri? requestFromUri(Uri uri) {
    if (_isReceiptUri(uri)) return uri;

    if (uri.fragment.isNotEmpty) {
      final Uri fragment = Uri.parse(uri.fragment);
      if (_isReceiptUri(fragment)) return fragment;
    }

    return null;
  }

  static ReceiptDocument? documentFromUri(Uri? uri) {
    final String? token = uri?.queryParameters['d'];
    if (token == null || token.isEmpty) return null;
    return ReceiptDocument.tryDecode(token);
  }

  static int? invoiceFromUri(Uri? uri) {
    return int.tryParse(uri?.queryParameters['invoice'] ?? '');
  }

  static bool _isReceiptUri(Uri uri) {
    String path = uri.path;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path == AppRoutes.receipt;
  }
}
