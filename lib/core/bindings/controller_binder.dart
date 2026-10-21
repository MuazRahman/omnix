import 'package:get/get.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/customers/controller/customer_controller.dart';
import 'package:omnix/features/dashboard/controller/dash_board_controller.dart';
import 'package:omnix/features/inventory/controller/inventory_controller.dart';
import 'package:omnix/features/menu/controller/menu_controller.dart';
import 'package:omnix/features/orders/controller/order_controller.dart';
import 'package:omnix/features/pos/controller/pos_controller.dart';
import 'package:omnix/features/purchases/controller/purchase_controller.dart';
import 'package:omnix/features/receipt/controller/printer_settings_controller.dart';
import 'package:omnix/features/receipt/printer/receipt_printer.dart';
import 'package:omnix/features/receipt/printer/spool_receipt_printer.dart';
import 'package:omnix/features/reports/controller/report_controller.dart';
import 'package:omnix/features/staff/controller/staff_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(BranchController());
    Get.put(DashBoardController());
    Get.put(OrderController());
    Get.put(MenuController());
    Get.put(PosController());
    Get.put(InventoryController());
    Get.put(PurchaseController());
    Get.put(CustomerController());
    Get.put(ReportController());
    Get.put(StaffController());

    // receipt printing on the 80mm printer attached to this PC
    final PrinterSettingsController printerSettings =
        Get.put(PrinterSettingsController());
    Get.put<ReceiptPrinter>(
      SpoolReceiptPrinter(settings: printerSettings),
    );
  }
}
