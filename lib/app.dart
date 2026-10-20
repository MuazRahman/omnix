import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/bindings/controller_binder.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/main_layout_shell/screens/main_layout_shell_screen.dart';
import 'package:omnix/features/receipt/screens/public_receipt_screen.dart';
import 'package:omnix/features/receipt/utils/receipt_link.dart';

class Omnix extends StatelessWidget {
  const Omnix({super.key});

  @override
  Widget build(BuildContext context) {
    final Uri? receiptRequest = ReceiptLink.requestFromLocation();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Omnix',
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppTheme.windowWidgetBackgroundBlack,
        useMaterial3: true,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStatePropertyAll(
            AppTheme.amber.withValues(alpha: 0.55),
          ),
          trackColor: WidgetStatePropertyAll(
            AppTheme.lightAmberWhite.withValues(alpha: 0.05),
          ),
          trackVisibility: const WidgetStatePropertyAll(true),
          radius: const Radius.circular(4),
          thickness: const WidgetStatePropertyAll(6),
        ),
      ),
      home: receiptRequest == null
          ? MainLayoutShellScreen()
          : PublicReceiptScreen(
              document: ReceiptLink.documentFromUri(receiptRequest),
              invoiceNumber: ReceiptLink.invoiceFromUri(receiptRequest),
            ),
      onGenerateRoute: _onGenerateRoute,
      initialBinding: receiptRequest == null ? ControllerBinder() : null,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final Uri? receiptRequest = ReceiptLink.requestFromRoute(settings.name);
    if (receiptRequest == null) return null;

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) {
        return PublicReceiptScreen(
          document: ReceiptLink.documentFromUri(receiptRequest),
          invoiceNumber: ReceiptLink.invoiceFromUri(receiptRequest),
        );
      },
    );
  }
}
