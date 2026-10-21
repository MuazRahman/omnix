import 'package:flutter/foundation.dart';

/// Build-time configuration shared by the POS and the public receipt page.
abstract final class AppConfig {
  const AppConfig._();

  /// Public origin where the receipt page is hosted.
  ///
  /// Set it when building the app that prints the QR code:
  /// `flutter build web --dart-define=RECEIPT_BASE_URL=https://pos.example.com`
  ///
  /// During local web development the current origin is used, so a receipt
  /// opened on the same machine works without extra configuration.
  static const String _receiptBaseUrl = String.fromEnvironment(
    'RECEIPT_BASE_URL',
    defaultValue: '',
  );

  static String get receiptBaseUrl {
    if (_receiptBaseUrl.isNotEmpty) {
      return _receiptBaseUrl;
    }

    if (kIsWeb) {
      final Uri base = Uri.base;
      if (base.scheme == 'http' || base.scheme == 'https') {
        return base.origin;
      }
    }

    // Desktop builds have no browser origin. Production must provide
    // RECEIPT_BASE_URL so the QR code points at the hosted receipt page.
    return 'https://receipt.example.com';
  }
}
