import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which printer receives the invoice and how it is printed.
///
/// The values live in shared preferences so a cashier only has to pick the
/// 80mm printer once per PC. Everything degrades to sensible defaults when the
/// settings store is not available (tests, first run).
class PrinterSettingsController extends GetxController {
  static const String _urlKey = 'receipt.printer.url';
  static const String _nameKey = 'receipt.printer.name';
  static const String _copiesKey = 'receipt.printer.copies';
  static const String _autoPrintKey = 'receipt.printer.auto_print';

  /// Spooler id of the selected queue, empty until a printer is picked.
  final printerUrl = ''.obs;

  /// Human readable name of the selected queue.
  final printerName = ''.obs;

  /// How many copies of the invoice are printed per sale (1-5).
  final copies = 1.obs;

  /// Print as soon as the receipt dialog opens for a completed sale.
  final autoPrint = false.obs;

  final printers = <Printer>[].obs;

  final isLoadingPrinters = false.obs;

  final lastError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      printerUrl.value = prefs.getString(_urlKey) ?? '';
      printerName.value = prefs.getString(_nameKey) ?? '';
      copies.value = (prefs.getInt(_copiesKey) ?? 1).clamp(1, 5);
      autoPrint.value = prefs.getBool(_autoPrintKey) ?? false;
    } catch (_) {
      // Keep the defaults when settings cannot be read.
    }
  }

  /// Reads the Windows printer queues, used by the settings dialog.
  Future<void> refreshPrinters() async {
    isLoadingPrinters.value = true;
    lastError.value = '';

    try {
      // The Windows spooler can stall while it starts; never keep the dialog
      // waiting on it forever.
      final List<Printer> found = await Printing.listPrinters().timeout(
        const Duration(seconds: 6),
      );
      final List<Printer> available =
          found.where((Printer printer) => printer.isAvailable).toList();

      available.sort((Printer a, Printer b) {
        if (a.isDefault) return -1;
        if (b.isDefault) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      printers.assignAll(available);

      if (available.isEmpty) {
        lastError.value =
            'No printer found. Install the 80mm thermal printer in Windows '
            'first, then refresh.';
      }
    } catch (_) {
      printers.clear();
      lastError.value = 'Could not read the Windows printer list.';
    } finally {
      isLoadingPrinters.value = false;
    }
  }

  Future<void> selectPrinter(Printer printer) async {
    printerUrl.value = printer.url;
    printerName.value = printer.name;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_urlKey, printer.url);
      await prefs.setString(_nameKey, printer.name);
    } catch (_) {
      // The selection still works for this session.
    }
  }

  Future<void> setCopies(int value) async {
    copies.value = value.clamp(1, 5);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_copiesKey, copies.value);
    } catch (_) {
      // Keep the in-memory value.
    }
  }

  Future<void> setAutoPrint(bool value) async {
    autoPrint.value = value;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoPrintKey, value);
    } catch (_) {
      // Keep the in-memory value.
    }
  }

  /// The printer to use for the next job: the saved queue, otherwise the
  /// Windows default.
  Future<Printer?> resolvePrinter() async {
    if (printers.isEmpty) {
      await refreshPrinters();
    }

    for (final Printer printer in printers) {
      if (printer.url == printerUrl.value) return printer;
    }

    for (final Printer printer in printers) {
      if (printer.isDefault) return printer;
    }

    return printers.isEmpty ? null : printers.first;
  }
}
