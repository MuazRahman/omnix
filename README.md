# omnix

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Hosted receipt QR

Every POS receipt prints a QR code that opens the hosted receipt page at
`https://<host>/#/receipt?d=<payload>`. The page is standalone, so it does not
load the POS shell or require controllers.

Set the public origin when building the app that prints the receipt:

```sh
flutter build web --dart-define=RECEIPT_BASE_URL=https://pos.example.com
```

- Web development falls back to the current origin automatically.
- Desktop builds must provide `RECEIPT_BASE_URL`; otherwise the placeholder
  `https://receipt.example.com` is used.
- Hash routing is intentional: it works on static hosts without rewrite rules.
- Today the receipt document travels inside the `d` parameter so scanning works
  without a backend. Once the receipt API is available, pass
  `?invoice=<number>` and fetch the document in `PublicReceiptScreen`; the
  shared `ReceiptPaperWidget` then renders the server response unchanged.
