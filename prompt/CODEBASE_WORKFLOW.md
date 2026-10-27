# Omnix — Codebase & Folder Workflow Reference

> **Purpose:** this file is the persistent map of the Omnix codebase. Read this first
> instead of re-reading every file. Use it to locate the right feature, understand the
> runtime/data flow, and follow the existing patterns when changing code.
>
> **Last verified:** 2026-10-26 · branch `master` · commit `8776000`
> ("Integrate receipt printing, update POS menu item cards with dish images, and refine
> receipt QR links") · Flutter 3.47.2 stable · Dart 3.13.2.

---

## 1. What this project is

**Omnix** is a desktop-first restaurant POS / back-office application built with Flutter.
It currently runs on **dummy data** (no backend is wired yet) and covers:

- Dashboard with sales metrics, chart, recent orders, branch performance.
- POS terminal with menu grid, live cart, customer attachment, tender/payment, receipt
  preview and 80mm thermal printing.
- Orders ledger with status workflow, settlement, void/refund, kitchen tickets (KOT),
  receipt printing and CSV export.
- Menu, Inventory, Purchases, Customers, Branches, Reports, Staff & Settings screens.
- A standalone public receipt page opened by scanning the QR printed on a receipt.

The app is a **single-window shell**: a fixed left sidebar and an `IndexedStack` of ten
feature screens. It is designed for a 1366–1920 px desktop window, but many widgets
adapt down to ~500 px content width.

### Stack / dependencies

| Dependency | Use |
| --- | --- |
| `get` | State management (`GetxController`, `Obx`), DI (`Get.put` / `Get.find`), snackbars |
| `go_router` | Declared and `appRouter` exists, but **not wired** into the app (see §6) |
| `dropdown_button2` | Branch dropdown in `TopBarWidget` |
| `fl_chart` | Sales velocity bar chart |
| `qr_flutter` | QR code rendering on the receipt |
| `pdf` + `printing` | 80mm invoice PDF and direct printing to a Windows spooler |
| `shared_preferences` | Persisting the selected printer / copies / auto-print |
| `http` | Declared but **not used yet** |
| `flutter_lints` | Lints via `analysis_options.yaml` |

No code generation, no `build_runner`, no localization files, no state library other
than GetX.

---

## 2. Runtime boot flow

```
main.dart
  └─ runApp(Omnix())
       └─ app.dart: Omnix
            ├─ ReceiptLink.requestFromLocation()   // is the browser URL a receipt URL?
            ├─ GetMaterialApp
            │    ├─ theme: Inter + AppTheme colors + scrollbar theme
            │    ├─ home:
            │    │    ├─ normal launch  → MainLayoutShellScreen
            │    │    └─ receipt URL    → PublicReceiptScreen
            │    ├─ initialBinding: ControllerBinder()  (only on normal launch)
            │    └─ onGenerateRoute: handles receipt routes pushed by Navigator
            └─ MainLayoutShellScreen
                 ├─ Get.put(MainLayoutShellController())
                 ├─ fixed 260px sidebar (branding, 3 nav groups, user card)
                 └─ IndexedStack(selectedIndex)
                      ├─ 0 Dashboard
                      ├─ 1 POS
                      ├─ 2 Orders
                      ├─ 3 Menu
                      ├─ 4 Inventory
                      ├─ 5 Purchases
                      ├─ 6 Customers
                      ├─ 7 Branches
                      ├─ 8 Reports
                      └─ 9 Staff & Settings
```

Important: `ControllerBinder` is **not** run for the public receipt page, so that page
must remain independent of GetX controllers. It only renders a `ReceiptDocument` or an
invoice-lookup placeholder.

---

## 3. Architecture in one page

```
lib/
├─ main.dart                 entry point only
├─ app.dart                  MaterialApp, theme, receipt-vs-shell decision, routes
├─ core/                     cross-feature infrastructure
│  ├─ bindings/              ControllerBinder: creates every feature controller
│  ├─ config/                AppConfig: RECEIPT_BASE_URL resolution
│  ├─ responsive/            AppBreakpoints: width thresholds
│  ├─ routes/                AppRoutes + unused GoRouter
│  ├─ theme/                 AppTheme: all colors
│  └─ utils/                 format.dart: number / taka / clock formatting
└─ features/                 one folder per feature, same internal shape
   ├─ <feature>/model/       immutable data classes + enums + fromJson
   ├─ <feature>/dummy_data/  hardcoded demo data (delete when backend lands)
   ├─ <feature>/controller/  GetxController: state, filtering, actions
   ├─ <feature>/screens/     top-level page widget(s)
   └─ <feature>/widgets/     smaller widgets used by that screen
```

**Layering rule:** screens and widgets never own business state; they read/write
controllers. Controllers own `.obs` state and expose getters. Models are plain
immutable Dart classes. Dummy data is static and imported directly by controllers.

**Feature anatomy:** almost every feature follows the same five-folder pattern. The
exceptions are:

- `common/` — shared widgets, no controller/model.
- `main_layout_shell/` — shell + sidebar, no model/dummy data.
- `receipt/` — includes `printer/` (PDF builders, printer abstraction), `utils/`,
  `controller/` for printer settings, and a public screen.
- `orders/` — includes `printer/kitchen_ticket_pdf_builder.dart`.

---

## 4. Folder / file map

### 4.1 Repository root

| Path | Purpose |
| --- | --- |
| `lib/` | All application code (see below) |
| `test/` | Widget/unit tests; see §10 |
| `assets/fonts/` | Inter variable fonts (regular + italic) |
| `assets/images/menu/` | 15 dish photos `m-001.jpg` … `m-015.jpg` + `CREDITS.md` |
| `android/ ios/ linux/ macos/ windows/ web/` | Generated Flutter platform shells |
| `pubspec.yaml` | Dependencies, assets, Inter font declaration |
| `pubspec.lock` | Locked dependency versions |
| `analysis_options.yaml` | `flutter_lints`; excludes `build/` and platform folders |
| `README.md` | Mostly the Flutter template + a receipt-QR section (partly stale) |
| `prompt/` | This workflow documentation |
| `.gitignore` | Ignores `.dart_tool/`, `build/`, `.idea/`, etc. |

Useful commands:

```sh
flutter pub get
flutter run -d windows                 # primary target (thermal printing)
flutter run -d chrome                  # web, receipt origin auto-detected
flutter test
flutter analyze
flutter build web --dart-define=RECEIPT_BASE_URL=https://pos.example.com
```

### 4.2 `lib/core`

| File | Purpose |
| --- | --- |
| `bindings/controller_binder.dart` | `Bindings` that `Get.put`s every feature controller plus `PrinterSettingsController` and `SpoolReceiptPrinter`. Main shell controller is **not** here. |
| `config/app_config.dart` | `AppConfig.receiptBaseUrl`: `--dart-define=RECEIPT_BASE_URL`, else current web origin, else `https://receipt.example.com`. |
| `responsive/app_breakpoints.dart` | Width constants used by the top bar and responsive layouts. Values describe **content width after the sidebar**, not raw window width. |
| `routes/app_routes.dart` | `AppRoutes.dashboard` (`/dashboard`), `AppRoutes.receipt` (`/receipt`). Dashboard route is currently unused. |
| `routes/app_routers.dart` | `appRouter = GoRouter(...)` for a future URL-based app. **Not referenced anywhere.** |
| `theme/app_theme.dart` | Single source of colors: amber, sidebar/topbar/window blacks, greens, whites, table colors, status colors. |
| `utils/format.dart` | `formatNumber` (84,650), `formatTaka` (`84,650 TK`), `formatTakaSymbol` (`৳ 84,650`), `formatClock` (`8:14 PM`). |

### 4.3 `lib/features/common/widgets` (shared UI)

| File | Purpose |
| --- | --- |
| `custom_container_widget.dart` | Rounded bordered container; optional height/width. Used for cards/tables. |
| `custom_widget_card.dart` | Fixed 180px dashboard metric card (title, icon, big value, subtitle). |
| `data_table_widget.dart` | Generic table: `DataTableColumn` (label, flex, alignRight, monospace), `DataTableRow` (cells, onTap), pinned header, scrollable body, empty message. `DataTableWidget.text(...)` is the standard cell text style. |
| `scrollable_table_body.dart` | `Scrollbar(thumbVisibility: true)` + `SingleChildScrollView` used by tables and dashboard lists. |
| `section_header_widget.dart` | Section title/subtitle + optional 280px search field + optional amber action button. Used by all list screens. |
| `see_all_button.dart` | Hover-underlined "See All" link used by dashboard cards. |
| `status_pill_widget.dart` | `StatusPillWidget` with `PillTone { amber, green, neutral, red, blue }`; optional leading dot. |
| `top_bar_widget.dart` | Global 74px top bar: branch dropdown, invoice search, sync badge, "New Sale" button, user info/avatar. Responsive width budgeting; many controls hide as width shrinks. Requires a `BranchController`. |

### 4.4 `lib/features/main_layout_shell`

| File | Purpose |
| --- | --- |
| `controller/main_layout_shell_controller.dart` | `selectedIndex` RxInt, index constants, `screens` list, `changeTabIndex`, `navigateTo`. |
| `screens/main_layout_shell_screen.dart` | `Row(sidebar, IndexedStack)`; creates the shell controller with `Get.put`; sidebar groups: OPERATIONS, INVENTORY & SUPPLY, MANAGEMENT. |
| `widgets/sidebar_nav_item_widget.dart` | One sidebar button; reads `selectedIndex` and calls `changeTabIndex`. |
| `widgets/sidebar_section_header_widget.dart` | Uppercase sidebar group label. |
| `widgets/sidebar_bottom_user_card.dart` | Hardcoded user card at sidebar bottom (no auth yet). |

**Critical coupling:** the order of `screens` and the order of sidebar `index` values
must match the index constants. Adding/reordering a section means updating all three
places (`MainLayoutShellController` and the sidebar widgets).

### 4.5 Feature map (purpose, data source, state)

| Feature | Purpose | Controller | Data source | Screens / key widgets |
| --- | --- | --- | --- | --- |
| `dashboard` | Shift overview: stats, sales chart, recent orders, branch performance | `DashBoardController` | 4 dummy files | `dashboard_screen.dart` + 5 widgets |
| `pos` | Sell menu items, build cart, attach customer, take payment, print receipt | `PosController` | `DummyMenuItemData`, `DummyPosData` | `pos_screen.dart` + 16 widgets |
| `orders` | Ledger of all tickets, status flow, settlement, void/refund, KOT/receipt, CSV export | `OrderController` | `DummyOrderData` | `orders_screen.dart` + 7 widgets + KOT PDF builder |
| `menu` | Browse/search/filter/sort dishes, table/grid catalog, availability, margins, modifier presets | `MenuController` | `DummyMenuItemData`, `DummyMenuModifierData` | `menu_screen.dart` + 12 widgets |
| `inventory` | Stock levels, reorder levels, stock value | `InventoryController` | `DummyInventoryData` | `inventory_screen.dart` |
| `purchases` | Purchase orders by supplier/status | `PurchaseController` | `DummyPurchaseData` | `purchases_screen.dart` |
| `customers` | Customer directory, phone-first add/attach | `CustomerController` | `DummyCustomerData` | `customers_screen.dart` + phone dialog |
| `branches` | Branch directory and branch selector data | `BranchController` | `DummyBranchData` + hardcoded labels | `branches_screen.dart` |
| `reports` | Sales metrics, top items, staff performance by range | `ReportController` | `DummyReportData` | `reports_screen.dart` |
| `staff` | Staff directory + on/off settings | `StaffController` | `DummyStaffData` | `staff_settings_screen.dart` |
| `receipt` | Shared receipt document, preview, QR link, PDF printing, public page | `PrinterSettingsController` | `ReceiptDocument` built from POS/order | `public_receipt_screen.dart`, `receipt_paper_widget.dart`, printer classes |
| `common` | Shared widgets | — | — | 8 shared widgets |
| `main_layout_shell` | App chrome / navigation | `MainLayoutShellController` | — | shell + sidebar widgets |

### 4.6 Detailed file index

#### Dashboard

| File | Purpose |
| --- | --- |
| `controller/dash_board_controller.dart` | `selectedDayRange`, `salesBuckets`, `recentOrders`, `branchPerformance`, `todayStats`, `isLoadingSales`; loads dummy data in `onInit`; `chartSubtitle`; `maxSale`. |
| `dummy_data/dummy_branch_performance_data.dart` | Branch performance rows. |
| `dummy_data/dummy_order_table_data.dart` | Recent order rows. |
| `dummy_data/dummy_sales_data.dart` | `hours` + `days(n)` sales buckets. |
| `dummy_data/dummy_today_stats_data.dart` | Today's summary numbers. |
| `model/branch_performance_model.dart` | `BranchPerformance` + `fromJson`. |
| `model/recent_order_model.dart` | Dashboard-local `OrderStatus` enum + `RecentOrder` + `fromJson`. |
| `model/sales_bucket_model.dart` | `SalesBucket(label, sales)`. |
| `model/today_stats_model.dart` | `TodayStats` immutable values. |
| `screens/dashboard_screen.dart` | Top bar, title/branch/day-range row, 4 summary cards, sales chart card, recent orders (flex 3) + branch performance (flex 2). "See All" navigates via shell controller. |
| `widgets/branch_performance_widget.dart` | Ranked branch list with sale/orders/change. |
| `widgets/day_range_button_widget.dart` | Today / 7 Days / 30 Days button. |
| `widgets/order_status_badge_widget.dart` | Status pill for recent orders. |
| `widgets/recent_order_table_widget.dart` | Pinned-header recent orders table. |
| `widgets/sales_chart_widget.dart` | `fl_chart` bar chart, horizontally scrollable. |

#### POS

| File | Purpose |
| --- | --- |
| `controller/pos_controller.dart` | Cart, menu, category/search, order type, table/pax, customer, tender, cash, invoice number; totals, tax, wallet cashout, discount/change, quick cash; add/remove cart; `prepareCheckout`, `startNewSale`. |
| `dummy_data/dummy_pos_data.dart` | Preloaded cart, tables, pax options, invoice `1042`, branch/receipt identity, tax 5%, wallet cashout 1.5%. |
| `model/cart_item_model.dart` | `CartItem(menuItemId, name, price, quantity, note)` + `lineTotal` + `copyWith`. |
| `model/pos_customer_model.dart` | `PosCustomer(name?, phone, id?)`, `displayName` → `N/A` when blank, value equality. |
| `model/pos_order_type_model.dart` | `PosOrderType { dineIn, takeaway, delivery }` with labels. |
| `model/pos_tender_mode_model.dart` | `PosTenderMode { cash, mobileWallet, card }` with labels. |
| `screens/pos_screen.dart` | Keyboard shortcuts (`Alt+S`, `F2`, `Enter`, `Esc`), catalog left / cart right, width-based cart width (340/400), opens receipt dialog after customer check. |
| `widgets/pos_cart_line_widget.dart` | One cart line + stepper + line total. |
| `widgets/pos_cart_panel_widget.dart` | Ticket header, customer bar, scrollable lines, totals, payment panel. |
| `widgets/pos_category_bar_widget.dart` | Horizontal category chips. |
| `widgets/pos_category_chip_widget.dart` | One category chip. |
| `widgets/pos_customer_bar_widget.dart` | Attached customer or "Add Phone" action; opens customer dialog. |
| `widgets/pos_menu_grid_widget.dart` | Responsive dish grid for filtered items. |
| `widgets/pos_menu_item_card_widget.dart` | Dish photo tile with bottom scrim, price, add/quantity state. |
| `widgets/pos_operational_bar_widget.dart` | Dine-in/takeaway/delivery toggle, table dropdown, pax dropdown; wraps under 780px. |
| `widgets/pos_order_totals_widget.dart` | Subtotal, VAT, cashout, net total. |
| `widgets/pos_panel_widget.dart` | Rounded dark POS surface. |
| `widgets/pos_payment_panel_widget.dart` | Tender mode chips, cash field/quick amounts, wallet cashout editor, "Complete Sale & Print" (disabled until cart + phone). |
| `widgets/pos_quantity_stepper_widget.dart` | Minus/plus control. |
| `widgets/pos_receipt_dialog_widget.dart` | Builds `ReceiptDocument`, shows `ReceiptPaperWidget` + QR, print, printer settings, auto-print, "New Sale". |
| `widgets/pos_search_bar_widget.dart` | Dish search + scan action. |
| `widgets/pos_ticket_header_widget.dart` | Ticket number, context, quick actions. |

#### Orders

| File | Purpose |
| --- | --- |
| `controller/order_controller.dart` | Order list, filters/search/selection, 30s clock timer, metrics, `advanceStatus`, `completeOrder`, `voidOrder`, `printReceipt`, `printKitchenTicket`, `buildReceiptDocument`, `copyOrderSummary`, `exportShiftLedger`. Manager PIN `1234`. |
| `dummy_data/dummy_order_data.dart` | 12 demo tickets with relative times, all channels/statuses/payments. |
| `model/order_model.dart` | `OrderStatus`, `OrderChannel`, `PaymentMethod`, `PaymentStatus`, `OrderLine`, `Order` + `fromJson` + `copyWith` + money/time getters. |
| `printer/kitchen_ticket_pdf_builder.dart` | Price-free 80mm KOT PDF: station, ticket/token, server, items, notes/modifiers. |
| `screens/orders_screen.dart` | Shortcuts (`F5`, `Ctrl+P`, `Ctrl+F`, `Esc`), split view ≥940px or list + detail dialog below. |
| `widgets/order_badges.dart` | Shared status/payment/channel colors and labels. |
| `widgets/order_detail_panel_widget.dart` | Full ticket inspector; primary action + receipt/KOT/void footer; receipt preview dialog. |
| `widgets/order_dialogs.dart` | `OrderSettlementDialog` (method + cash), `OrderVoidDialog` (PIN + reason), `OrderReceiptPreviewDialog`, shared dialog shell. |
| `widgets/order_list_panel_widget.dart` | Scrollable ticket ledger. |
| `widgets/orders_filter_bar_widget.dart` | Status tabs, search, channel/payment dropdown filters. |
| `widgets/orders_header_widget.dart` | "Order Ledger" title, sync chip, printer settings, refresh, export. |
| `widgets/orders_summary_widget.dart` | 4 shift metrics: orders today, live kitchen, net revenue, avg turnaround. |

#### Menu / Inventory / Purchases / Customers / Branches / Reports / Staff

| File | Purpose |
| --- | --- |
| `menu/controller/menu_controller.dart` | Categories, search, branch, sort, table/grid view, paging; `filteredItems`, `pagedItems`, catalog stats; availability toggle, duplicate, archive. |
| `menu/model/menu_item_model.dart` | `MenuItem` with id/name/Bangla alias/category/price/recipe cost/availability/branch/image/prep time/bestseller/low-stock/modifiers/sales + margin getters, `copyWith`, `fromJson`. |
| `menu/model/menu_modifier_group_model.dart` | `MenuModifierGroup` and `MenuModifierOption` presets. |
| `menu/dummy_data/dummy_menu_item_data.dart` | Categories + 15 dishes with asset images, Bangla aliases, costs and modifier metadata, branch `DHK-01`. |
| `menu/dummy_data/dummy_menu_modifier_data.dart` | Spice level, portion and add-on modifier presets. |
| `menu/screens/menu_screen.dart` | Header, health ribbon, filter bar, table/grid catalog, insight cards, pagination and end-drawer modifier presets. Add/edit/import/category manager remain no-ops. |
| `menu/widgets/menu_item_image_widget.dart` | Asset-or-network image; no placeholder icon (missing file = dark tile). |
| `menu/widgets/menu_header_widget.dart` | Breadcrumb, title, modifier/bulk-import/add-dish actions. |
| `menu/widgets/menu_stat_ribbon_widget.dart` | Active dishes, food-cost margin, kitchen availability and top segment metrics. |
| `menu/widgets/menu_filter_bar_widget.dart` | Category chips, search, branch, sort and table/grid toggle. |
| `menu/widgets/menu_table_widget.dart` | Responsive catalog table (full/compact/narrow columns) + row actions. |
| `menu/widgets/menu_grid_view_widget.dart` | Card catalog view for smaller widths. |
| `menu/widgets/menu_pagination_footer_widget.dart` | Page range, previous/next and page indicator. |
| `menu/widgets/menu_insight_cards_widget.dart` | Branch pricing, margin watch and modifier preset cards. |
| `menu/widgets/menu_modifier_drawer_widget.dart` | End drawer for modifier presets. |
| `inventory/controller/inventory_controller.dart` | Categories, search, items, `filteredItems`, low/out counts, total value. |
| `inventory/model/inventory_item_model.dart` | `StockLevel`, `InventoryItem` + `fromJson`; value getters. |
| `inventory/dummy_data/dummy_inventory_data.dart` | Categories + stock rows. |
| `inventory/screens/inventory_screen.dart` | Header, 3 stat cards, category chips, stock table. Add Stock is a no-op. |
| `purchases/controller/purchase_controller.dart` | Status filters, search, purchases, `filteredPurchases`, pending count, filtered total. |
| `purchases/model/purchase_model.dart` | `PurchaseStatus`, `Purchase` + `fromJson`. |
| `purchases/dummy_data/dummy_purchase_data.dart` | Status filter labels + PO rows. |
| `purchases/screens/purchases_screen.dart` | Header, status chips, purchase table. New Purchase is a no-op. |
| `customers/controller/customer_controller.dart` | Search, customers, phone normalization, `findByPhone`, `addCustomer`, `updateCustomer`, `filteredCustomers`, regular count, lifetime spend. |
| `customers/model/customer_model.dart` | `Customer(id, name?, phone, visits, spent, lastVisit)` + `fromJson` + `displayName`/`isRegular`. |
| `customers/dummy_data/dummy_customer_data.dart` | Customer rows. |
| `customers/screens/customers_screen.dart` | Header, customer table, Add Customer dialog. |
| `customers/widgets/customer_phone_dialog_widget.dart` | Shared phone-first dialog: modes `attachToTicket` / `addCustomer`; validates ≥6 digits, finds existing, reveals optional name for new numbers. Test keys: `customer-phone-field`, `customer-name-field`, `customer-save-button`, `customer-existing-card`, `customer-use-existing-button`. |
| `branches/controller/branch_controller.dart` | `selectedBranch` (`ValueNotifier<String?>`), hardcoded branch labels, `branchRecords`, search, filtered list, active count. |
| `branches/model/branch_model.dart` | `Branch` + `fromJson`. |
| `branches/dummy_data/dummy_branch_data.dart` | Branch rows. |
| `branches/screens/branches_screen.dart` | Branch table. Add Branch is a no-op. |
| `reports/controller/report_controller.dart` | Ranges, selected range, sales report, top items, staff performance, load dummy data. |
| `reports/model/report_model.dart` | `ReportEntry`, `TopSellingItem`. |
| `reports/dummy_data/dummy_report_data.dart` | Report metrics + lists. |
| `reports/screens/reports_screen.dart` | Range chips, metric grid, top-selling list, staff performance list. Export is a no-op. |
| `staff/controller/staff_controller.dart` | Staff, settings toggles, search, filtered staff, `toggleSetting`, active count. |
| `staff/model/staff_model.dart` | `StaffRole`, `Staff`, `SettingToggle` + `fromJson`. |
| `staff/dummy_data/dummy_staff_data.dart` | Staff + settings. |
| `staff/screens/staff_settings_screen.dart` | Staff table (flex 3) + settings list (flex 2). Add Staff is a no-op; toggles are in-memory only. |

#### Receipt

| File | Purpose |
| --- | --- |
| `controller/printer_settings_controller.dart` | Persists printer URL/name, copies (1–5), auto-print in `shared_preferences`; lists Windows printers (6s timeout, default first), `resolvePrinter()` saved → default → first. |
| `model/receipt_document.dart` | Full receipt data: branch identity, cashier/customer, items, subtotal/VAT/cashout/total, tender/paid/discount/change, flags. `toJson`/`fromJson`, `encode`/`tryDecode` (base64url, version 1) for legacy `?d=` links. |
| `printer/receipt_printer.dart` | `ReceiptPrinter` interface (`printReceipt`, `printTestPage`), `ReceiptPrintResult`, `noPrinterMessage`. |
| `printer/spool_receipt_printer.dart` | Builds PDF via `ReceiptPdfBuilder`, sends with `Printing.directPrintPdf` to the resolved Windows queue, `roll80`. |
| `printer/receipt_pdf_builder.dart` | 80mm invoice PDF twin of `ReceiptPaperWidget`; test page; copies; QR block; uses `Tk` because built-in PDF fonts lack `৳`. |
| `screens/public_receipt_screen.dart` | Standalone public page: renders document if present, otherwise "Invoice lookup" placeholder with invoice number. No GetX dependency. |
| `utils/receipt_link.dart` | Builds/parses `https://host/#/receipt?invoice=N`; accepts hash or path URLs; legacy `?d=` document decode. |
| `widgets/printer_settings_dialog.dart` | Printer picker, refresh, copies stepper, auto-print switch, test print. |
| `widgets/receipt_paper_widget.dart` | Shared receipt layout for POS preview and public page: header, meta, item lines, totals, discount/change, QR (custom pixel-snapped painter), footer. |

---

## 5. State management and dependency injection

### 5.1 Pattern

Controllers extend `GetxController` and expose:

```dart
final searchText = ''.obs;                 // reactive scalar
final items = <Item>[].obs;                // reactive list
final selected = Rxn<Item>();              // nullable reactive
bool get filtered => ...;                  // derived getter
void onChanged(String value) => searchText.value = value;
```

Widgets wrap reactive reads in `Obx(() => ...)`. Non-reactive values are plain fields.
Derived getters that read `.obs` **must** be evaluated inside an `Obx` to rebuild.

### 5.2 Registration

`core/bindings/controller_binder.dart` runs once at app start:

```
BranchController
DashBoardController
OrderController
MenuController
PosController
InventoryController
PurchaseController
CustomerController
ReportController
StaffController
PrinterSettingsController
ReceiptPrinter → SpoolReceiptPrinter(settings: printerSettings)
```

`MainLayoutShellController` is created by `MainLayoutShellScreen` with `Get.put`.

Screens use `Get.find<T>()` (throwing) rather than `Get.put`, except tests which put the
controllers they need. Widgets receive controllers via constructor when the screen
already has them (e.g. `TopBarWidget(branchController: ...)`) or call `Get.find` for
cross-feature dependencies (e.g. dashboard → shell controller, POS dialog → printer).

### 5.3 Controller dependency rules

- `BranchController.selectedBranch` is a `ValueNotifier`, not an Rx value. Use
  `ValueListenableBuilder` (see top bar/dashboard) or read `.value`.
- `OrderController` reads `BranchController` and `PrinterSettingsController` through
  `Get.isRegistered` / `Get.find`, so it degrades gracefully in tests.
- `PosReceiptDialogWidget` guards `Get.isRegistered<PrinterSettingsController>()` and
  `Get.isRegistered<ReceiptPrinter>()` before using them.
- Do not put UI logic in controllers beyond snackbars (`OrderController._notify` is the
  one exception).

### 5.4 Adding a controller

1. Create `features/<name>/controller/<name>_controller.dart`.
2. Register it in `ControllerBinder.dependencies()`.
3. Load data in `onInit` (keep the `// TODO: replace with db fetch once backend is ready`
   convention and the commented API shape).
4. In tests, `Get.put(...)` the controllers the screen needs; call `Get.reset()` in
   `setUp`/`tearDown`.

---

## 6. Navigation and routing

- **Primary navigation is not route-based.** `MainLayoutShellController.selectedIndex`
  drives an `IndexedStack`; screens stay alive when switched away.
- Sidebar items pass their index; dashboard "See All" links call
  `Get.find<MainLayoutShellController>().navigateTo(<index>)`.
- `AppRoutes` / `appRouter` / `go_router` are scaffolding for a future URL router and are
  currently unused. Do not assume `go_router` navigation works.
- The **only real URL route** is the public receipt:
  - `ReceiptLink.requestFromLocation()` checks `Uri.base` (path or `#` fragment).
  - `app.dart` chooses `PublicReceiptScreen` as `home` when the URL matches.
  - `onGenerateRoute` handles receipt routes pushed through the Navigator.
  - Hash routing is intentional so static hosts work without rewrite rules.
- Dialog navigation uses `showDialog` + `Navigator.pop`; no named routes.

**Adding a shell section:** add the screen to `MainLayoutShellController.screens`, add an
index constant, then add `SidebarNavItemWidget(index: ...)` in the correct sidebar group.
Keep all three in sync.

---

## 7. Data flow and backend integration

### 7.1 Current flow

```
dummy_data/*.dart
      │  imported directly
      ▼
Controller.onInit() → fetchX() → assignAll(...)
      │  .obs fields
      ▼
Obx(...) / ValueListenableBuilder(...) in screen/widget
      │
      ▼
UI table/card/chart
```

Every feature controller has the same placeholder:

```dart
// TODO: replace with db fetch once backend is ready
Future<void> fetchX() async {
  isLoading.value = true;
  // final response = await api.get('/x');
  // items.assignAll((response as List)
  //     .map((e) => X.fromJson(e as Map<String, dynamic>))
  //     .toList());
  items.assignAll(DummyXData.items);
  isLoading.value = false;
}
```

Keep that shape when connecting the API: replace the dummy assignment with the HTTP
call, keep the `fromJson` mapping, and keep the `.obs` state identical.

### 7.2 Models

- Plain immutable classes with `final` fields, `const` constructors where possible.
- `factory X.fromJson(Map<String, dynamic> json)` exists in every persisted model.
- Enums use `fromValue(String?)` to map backend spellings; unknown values fall back to a
  safe default (pending/unpaid/dine-in/in-stock/cash).
- Money is `int` taka (rounded), percentages are `double`.
- Display formatting is centralized in `core/utils/format.dart`; do not hand-format
  numbers in widgets.

### 7.3 Where data comes from today

| Feature | Dummy source | Notes |
| --- | --- | --- |
| Dashboard | `DummySalesData`, `DummyTodayStatsData`, `DummyOrderTableData`, `DummyBranchPerformanceData` | Recent orders limited to 5; branches sorted by sale and limited to 3. |
| POS | `DummyMenuItemData` + `DummyPosData` | Cart preloaded with 3 lines; invoice starts at 1042. |
| Orders | `DummyOrderData.orders(now:)` | Times relative to fetch time so elapsed/rush labels look live. |
| Menu | `DummyMenuItemData` | Same dishes as POS. |
| Inventory | `DummyInventoryData` | |
| Purchases | `DummyPurchaseData` | |
| Customers | `DummyCustomerData` | New customers are added in memory only. |
| Branches | `DummyBranchData` + hardcoded label list | |
| Reports | `DummyReportData` | |
| Staff | `DummyStaffData` | Toggles are in memory only. |

---

## 8. End-to-end business workflows

### 8.1 POS sale → receipt (the most important flow)

1. **Open POS** — `PosScreen` (index 1). It reads `PosController` and
   `BranchController` with `Get.find`.
2. **Pick order type** — `PosOperationalBarWidget` sets `PosOrderType`. Table and pax
   chips are shown only for dine-in (`isDineIn`).
3. **Find dishes** — search text/category update `filteredItems`; the grid renders
   `PosMenuItemCardWidget`. Tapping a card calls `addToCart`; the card shows quantity
   already in the cart. Disabled dishes (`isAvailable == false`) cannot be added.
4. **Edit cart** — `PosCartLineWidget` increments/decrements; quantity 0 removes the line.
   `removeLine` drops a whole line. Empty cart shows "Cart is empty".
5. **Attach customer (mandatory to print)** — `PosCustomerBarWidget` opens
   `CustomerPhoneDialogWidget` in `attachToTicket` mode. Phone is normalized to digits;
   an existing customer is attached, otherwise an optional name creates a new directory
   customer. `PosController.hasCustomerPhone` and `canPrint` gate the sale.
6. **Totals** — `PosController`: `subtotal`, 5% `tax`, `totalBeforeCashout`, wallet
   cashout percentage (only for `mobileWallet`, default 1.5%), `total`.
7. **Tender** — `PosPaymentPanelWidget`:
   - Cash: cash-received field, quick amounts (exact, next 500, next 1000).
     Cash above total → `changeDue`; cash below total → `discountAmount`; empty field
     is filled with the exact total by `prepareCheckout()`.
   - bKash/Nagad: exact total + editable cashout percentage.
   - Card: exact total.
8. **Complete Sale & Print** — disabled unless `canPrint`. `PosScreen._openReceipt`
   calls `prepareCheckout()` and opens `PosReceiptDialogWidget`.
9. **Receipt preview** — the dialog builds a `ReceiptDocument` from the controller,
   builds the short QR URL with `ReceiptLink.forDocument`, renders
   `ReceiptPaperWidget`, and optionally auto-prints if the setting is on.
10. **Print** — `Get.find<ReceiptPrinter>().printReceipt(document, qrData: url)`:
    `SpoolReceiptPrinter` → `ReceiptPdfBuilder.build` → `Printing.directPrintPdf`
    to the selected Windows queue at `roll80`.
11. **Finish** — successful print (or "New Sale") calls `startNewSale()`: clears cart,
    search, category, cash, tender, customer, and increments `invoiceNumber`.

> **Known gap:** the POS sale is a separate demo flow. It does **not** append an `Order`
> to `OrderController`, so the Orders ledger is not updated by a POS sale yet.

### 8.2 Receipt document → public page

1. POS/Orders create a `ReceiptDocument`.
2. `ReceiptLink.forDocument` produces
   `https://<receiptBaseUrl>/#/receipt?invoice=<invoiceNumber>`.
3. The QR on the preview/printed PDF encodes that short URL.
4. Scanning opens the web app at that URL. `app.dart` detects the receipt route and
   renders `PublicReceiptScreen` **without** `ControllerBinder`.
5. If the URL carries a legacy `?d=<token>`, `ReceiptDocument.tryDecode` restores the
   document and the page renders it.
6. If the URL carries only `?invoice=N` (current behavior), the page shows the
   "Invoice lookup" placeholder. **Backend fetch by invoice is not implemented.**
   `README.md` still describes the older `?d=` payload behavior and is stale on this
   point.

`AppConfig.receiptBaseUrl` resolution:
`--dart-define=RECEIPT_BASE_URL` → current web origin → `https://receipt.example.com`
(desktop fallback). Desktop production must pass the define.

### 8.3 Orders ledger workflow

1. **Load** — `OrderController.fetchOrders()` loads `DummyOrderData` with a 280ms
   delay, records `lastSyncAt`, preserves selection if possible, otherwise selects the
   first visible ticket. A 30s timer updates `now` for elapsed/rush labels.
2. **Filter/search** — status tab (`OrderFilter`), text search over id/customer/phone/
   table/rider/items, channel dropdown, payment-status dropdown. `filteredOrders` sorts
   newest first.
3. **Inspect** — ≥940px content shows list + 400px detail panel; narrower shows list and
   opens the detail in a dialog. Detail shows ticket, lines, modifiers/notes, money,
   payment and actions.
4. **Advance status** — primary action:
   - `pending` → `preparing`
   - `preparing` → `ready`
   - `ready` + unpaid → settlement dialog, then `completeOrder`
   - `ready` + paid → `completeOrder`
   - `completed` → print receipt
   - `cancelled` → disabled
5. **Settlement** — `OrderSettlementDialog` returns method + cash received; completed
   orders become `paid` with `completedAt`.
6. **Void/refund** — `OrderVoidDialog` requires manager PIN (`1234`) and optional
   reason. Paid tickets become `refunded`; unpaid become `voided`; status `cancelled`.
7. **Print receipt** — only when paid and not cancelled; builds `ReceiptDocument` from
   the order and uses the same `ReceiptPrinter`.
8. **Print KOT** — allowed unless cancelled; uses `PrinterSettingsController` +
   `KitchenTicketPdfBuilder` + `Printing.directPrintPdf`. There is **no separate
   kitchen printer setting**; it uses the same resolved printer queue.
9. **Export** — `exportShiftLedger()` copies a CSV of all orders to the clipboard;
   `copyOrderSummary()` copies a human-readable summary. Both show a GetX snackbar.

Order money rules (`Order`): `subtotal` = sum of lines; `taxableTotal = subtotal -
discount`; `vat = taxableTotal * vatPercent / 100`; `total = taxableTotal + vat`;
`tenderedAmount` = cash received for cash, otherwise total; `changeDue` only for paid
cash above total; `balanceDue` 0 when paid/refunded. A live ticket waiting ≥15 minutes
is "rush".

### 8.4 Dashboard workflow

- `DashBoardController.onInit` loads today stats, sales, recent orders, branch
  performance.
- Summary cards always show **today**; the day-range selector only changes the chart
  (`Today` = hourly 8 AM–11 PM, `7 Days`, `30 Days`) and the chart subtitle.
- Recent orders table shows the newest 5; branch performance shows the top 3 by sale.
- "See All" links jump to Orders or Branches via the shell controller.
- The branch name under the title comes from `BranchController.selectedBranch`
  (`ValueListenableBuilder`), while the top bar branch dropdown changes the same value.

### 8.5 Other sections

- **Menu:** category chips + search/sort/branch filters drive a responsive table or
  card grid with paging, availability toggles, duplicate/archive actions and margin
  metrics; modifier presets open in an end drawer. Add/edit/bulk import/category
  manager are no-ops.
- **Inventory:** stat cards (low stock, out of stock, stock value), category filter,
  table with quantity/reorder/status/value. Add Stock is a no-op.
- **Purchases:** status chips + search filter POs; table shows PO, supplier, item
  summary, status, ordered at, amount. New Purchase is a no-op.
- **Customers:** search by name/phone/id (digits-only phone matching); table shows
  visits/type/last visit/spend; Add Customer opens the shared phone dialog.
- **Branches:** search by name/id/manager; table shows address/manager/phone/since/
  status. Add Branch is a no-op.
- **Reports:** range chips, metric grid, top-selling items, staff performance. Range
  currently only changes the selected index/label; it does not re-query or filter data.
  Export is a no-op.
- **Staff & Settings:** staff table + settings toggles (in-memory). Add Staff is a
  no-op.

---

## 9. UI system and conventions

### 9.1 Theme

- `AppTheme` is the only color source. Common values: amber `#FFB020`, sidebar
  `#2A2A2A`, top bar `#131313`, widget background `#1C1B1B`, window black `#000000`,
  green `#10B981`, light green `#67F4B7`, white `#FFEEDC`, table header `#9F8E79`,
  table text `#E5E2E1`, table divider `#524533`, danger `#EF5350`, info `#4C9AFF`.
- Font: Inter (declared in `pubspec.yaml`), Material 3, dark surfaces.
- Scrollbars: amber thumb at 55% alpha, always-visible track.
- Opacity uses `withValues(alpha: ...)`, not deprecated `withOpacity`.
- Code uses modern Dart shorthands such as `crossAxisAlignment: .stretch` and
  `spacing:` on `Row`/`Column`. Follow the surrounding style.

### 9.2 Responsive strategy

- `AppBreakpoints` describes **content width after the sidebar** (sidebar is 260px).
- `TopBarWidget` budgets fixed widths and progressively hides search, sync badge, user
  name, and button label. Tests assert no overflow from 500–1920px.
- `OrdersScreen` switches between split view (≥940px) and list + dialog.
- `PosScreen` uses 340px cart under 1000px content width, otherwise 400px.
- POS operational bar wraps under 780px; order summary switches to a horizontal strip
  under 760px; report metric grid uses `maxCrossAxisExtent: 260`.
- Tables use flex columns and fixed row heights; long text is ellipsized, not wrapped.

### 9.3 Shared widget rules

- Use `SectionHeaderWidget` for list-screen titles/search/actions.
- Use `DataTableWidget` for tabular lists and `DataTableWidget.text` for cells.
- Use `StatusPillWidget` + `PillTone` for statuses; order-specific tone mapping lives in
  `orders/widgets/order_badges.dart`.
- Use `CustomContainerWidget` for bordered cards/tables and `CustomCardWidget` for
  dashboard metrics.
- Use `formatTaka` / `formatTakaSymbol` / `formatNumber` / `formatClock`; printed PDFs
  use `Tk` because the PDF built-in fonts lack `৳`.
- Interactive elements that are not obvious buttons use `Material` + `InkWell` with
  amber hover overlays.
- Test hooks use `Key('...')` on inputs/buttons (see customer/POS tests).

---

## 10. Tests

| File | What it covers |
| --- | --- |
| `widget_test.dart` | App boots into the shell at 1920×1080; sidebar branding + recent orders visible. |
| `dashboard_screen_test.dart` | Dashboard renders recent order header/row/amount; swallows known top-bar overflow. |
| `recent_order_table_test.dart` | Table headers, rows, status badges, monospaced ৳ amount. |
| `top_bar_test.dart` | Top bar fits widths 1920 → 500 with no exception. |
| `pos_screen_test.dart` | Large suite: layout sizes, dine-in vs takeaway/delivery, customer attach flow, new customer without name (`N/A`), cash change/discount, wallet cashout, cart quantity, receipt preview/QR. |
| `customers_screen_test.dart` | Add Customer phone-first flow, duplicate phone handling, table refresh. |
| `menu_item_image_test.dart` | Every dummy dish has branch id + bundled asset that loads (>1000 bytes). |
| `menu_screen_test.dart` | Catalog + health ribbon render, category/search filters, table/grid toggle, 700px and 500px layouts. |
| `receipt_page_test.dart` | `ReceiptDocument` round-trip, legacy `?d=` parsing, hash/path receipt URLs, public page rendering, phone width, discount/change, invoice-only lookup. |
| `receipt_pdf_test.dart` | PDF starts with `%PDF-`, copies add pages, no-QR build, printer test slip. |

Test conventions:

- `Get.testMode = true; Get.reset();` in `setUp`, `Get.reset` in `tearDown`.
- `Get.put(...)` the controllers the screen under test needs.
- Set `tester.view.physicalSize` + `devicePixelRatio = 1.0` and reset via
  `addTearDown(tester.view.reset)`.
- Use `pumpAndSettle()` after animations.
- Some tests intentionally drain pre-existing top-bar layout exceptions with
  `while (tester.takeException() != null) {}`; `pos_screen_test.dart` instead asserts
  no exceptions at all.
- Receipt PDF tests are pure Dart/Flutter and do not touch a real printer.

Commands: `flutter test`, `flutter test test/pos_screen_test.dart`,
`flutter analyze`.

---

## 11. Known gaps, quirks, and gotchas

1. **No backend.** All feature data is dummy; new records (customers, toggles) live only
   in memory. Every controller has a `TODO` fetch placeholder.
2. **POS does not create Orders.** The POS flow and the Orders ledger are independent
   demos. If you need one source of truth, wire `PosController` checkout into
   `OrderController` (or a shared repository).
3. **Receipt QR is invoice-only, but lookup is not implemented.** `PublicReceiptScreen`
   shows an "Invoice lookup" placeholder for `?invoice=N`. Only legacy `?d=` links
   render a full receipt. The README is stale here.
4. **GoRouter and `http` are unused.** Don't build on them without wiring them first.
5. **One printer queue for invoices and KOT.** `OrderController.printKitchenTicket`
   uses the same `PrinterSettingsController`/`resolvePrinter` as invoices. There is no
   separate kitchen-printer setting yet.
6. **`PosController.printKitchenTicket` is a TODO stub.** Use the Orders screen KOT
   flow for now.
7. **Branch selection is cosmetic.** It changes the top bar/dashboard label and the
   branch code on order receipts, but it does not filter menu/inventory/orders by branch.
8. **Reports range chips don't reload data.** `rangeOnChanged` only updates the index.
9. **Several "Add/Export" buttons are no-ops:** Add Item, Add Stock, New Purchase,
   Add Branch, Add Staff, Reports Export, TopBar New Sale/search.
10. **Manager PIN is hardcoded** to `1234` in `OrderController.managerPin` (demo).
11. **Top bar has a known overflow history** in some widget tests; new tests should
    assert `tester.takeException()` is null or deliberately drain known exceptions.
12. **Desktop printing needs a Windows queue** configured for 80mm roll paper;
    `PrinterSettingsController` lists available queues and falls back to the default.
13. **Public receipt page must stay controller-free** because `ControllerBinder` is not
    installed on that route.
14. **`IndexedStack` keeps all screens alive.** Controllers load data once at app start;
    switching tabs does not refetch. Use explicit refresh actions.
15. **No auth / roles.** Sidebar user, cashier name, branch labels and staff data are
    hardcoded/dummy.

---

## 12. Recipes: where to change what

### Add a field to a receipt
1. `features/receipt/model/receipt_document.dart`: add field, constructor, `toJson`,
   `fromJson` (bump payload version only if breaking legacy decode).
2. `features/receipt/widgets/receipt_paper_widget.dart`: render it in the preview/public
   page.
3. `features/receipt/printer/receipt_pdf_builder.dart`: render it in the PDF (and adjust
   `_estimatedHeight` if it adds a line).
4. `features/pos/widgets/pos_receipt_dialog_widget.dart` and/or
   `OrderController.buildReceiptDocument`: populate the field.
5. Add/extend tests in `test/receipt_page_test.dart` and `test/receipt_pdf_test.dart`.

### Add a POS rule (discount, tender, validation)
- State and calculations: `features/pos/controller/pos_controller.dart`.
- UI/field/button state: `features/pos/widgets/pos_payment_panel_widget.dart`.
- Receipt effect: `pos_receipt_dialog_widget.dart` → `ReceiptDocument` →
  `receipt_paper_widget.dart` / `receipt_pdf_builder.dart`.
- Tests: `test/pos_screen_test.dart` and `test/receipt_page_test.dart`.

### Add an Orders action/status
1. `features/orders/model/order_model.dart`: enum/status or `copyWith` field.
2. `features/orders/controller/order_controller.dart`: action + metrics + receipt mapping.
3. `features/orders/widgets/order_detail_panel_widget.dart`: primary/footer action.
4. `features/orders/widgets/order_badges.dart`: label/tone if new status.
5. `features/orders/widgets/order_dialogs.dart`: confirmation/input dialog if needed.
6. Tests: add a focused widget/controller test.

### Add a new list screen
1. Create `features/<name>/{model,dummy_data,controller,screens,widgets}` following an
   existing simple feature (Inventory/Purchases is the closest template).
2. Add controller to `ControllerBinder`.
3. Add screen to `MainLayoutShellController.screens` + index constant + sidebar item.
4. Build the page as `Scaffold > Column > TopBarWidget, SectionHeaderWidget, table`.
5. Add tests for empty/filtered/table rendering.

### Connect a backend endpoint
- Replace the body of the feature's `fetchX()`; keep `isLoading`, `assignAll`, and
  `fromJson`.
- Keep the dummy file for tests or move fixtures into `test/`.
- Add error handling with `lastError`/snackbar consistent with existing controllers.
- Do not call `Get.find` for the API client in widgets; inject/register it in
  `ControllerBinder` or a repository layer.

### Change theme/responsiveness
- Colors: `core/theme/app_theme.dart` only.
- Width thresholds: `core/responsive/app_breakpoints.dart`.
- Top bar behavior: `features/common/widgets/top_bar_widget.dart`.
- Table layout: `features/common/widgets/data_table_widget.dart` + screen columns.

---

## 13. Quick lookup: "I need to touch…"

| Need | File(s) |
| --- | --- |
| App start / theme / receipt routing | `lib/main.dart`, `lib/app.dart` |
| Register a controller/service | `lib/core/bindings/controller_binder.dart` |
| Sidebar / screen order | `main_layout_shell/controller/...`, `main_layout_shell/screens/...` |
| Global top bar | `features/common/widgets/top_bar_widget.dart` |
| Colors | `core/theme/app_theme.dart` |
| Money/date formatting | `core/utils/format.dart` |
| POS totals/tax/discount | `features/pos/controller/pos_controller.dart` |
| POS payment UI | `features/pos/widgets/pos_payment_panel_widget.dart` |
| Receipt preview | `features/receipt/widgets/receipt_paper_widget.dart` |
| Receipt PDF / 80mm | `features/receipt/printer/receipt_pdf_builder.dart` |
| Printer selection/persistence | `features/receipt/controller/printer_settings_controller.dart` |
| Receipt QR URL | `features/receipt/utils/receipt_link.dart` |
| Public receipt page | `features/receipt/screens/public_receipt_screen.dart` |
| Order lifecycle/settlement/void | `features/orders/controller/order_controller.dart` |
| Order detail actions | `features/orders/widgets/order_detail_panel_widget.dart` |
| KOT PDF | `features/orders/printer/kitchen_ticket_pdf_builder.dart` |
| Customer phone dialog | `features/customers/widgets/customer_phone_dialog_widget.dart` |
| Table UI | `features/common/widgets/data_table_widget.dart` |
| Responsive thresholds | `core/responsive/app_breakpoints.dart` |
| Test setup patterns | `test/pos_screen_test.dart`, `test/widget_test.dart` |

---

## 14. Keeping this document useful

Update this file when you:

- add/remove/rename a feature, controller, model, screen, or shared widget;
- change the boot flow, DI registration, navigation, or receipt routing;
- connect a backend endpoint and remove a dummy data source;
- change a business rule (tax, discount, tender, status transitions, printing);
- add a platform target or a major dependency.

Keep the file index and the "Known gaps" section honest. If a detail can be discovered
in one small file, link the file instead of duplicating the code here.
