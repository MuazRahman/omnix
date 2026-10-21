import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/core/utils/format.dart';
import 'package:omnix/features/branches/controller/branch_controller.dart';
import 'package:omnix/features/common/widgets/custom_container_widget.dart';
import 'package:omnix/features/common/widgets/data_table_widget.dart';
import 'package:omnix/features/common/widgets/section_header_widget.dart';
import 'package:omnix/features/common/widgets/status_pill_widget.dart';
import 'package:omnix/features/common/widgets/top_bar_widget.dart';
import 'package:omnix/features/customers/controller/customer_controller.dart';
import 'package:omnix/features/customers/model/customer_model.dart';
import 'package:omnix/features/customers/widgets/customer_phone_dialog_widget.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController branchController = Get.find<BranchController>();
    final CustomerController customerController =
        Get.find<CustomerController>();

    return Scaffold(
      backgroundColor: AppTheme.topbarBackgroundBlack,
      body: Column(
        children: [
          // Appbar Header
          TopBarWidget(branchController: branchController),

          // Title, search and add button
          Obx(
            () => SectionHeaderWidget(
              title: 'Customers',
              subtitle:
                  '${customerController.customers.length} customers · ${formatTaka(customerController.totalSpent)} lifetime',
              searchHint: 'Search by name, phone or id',
              onSearchChanged: customerController.searchOnChanged,
              actionLabel: 'Add Customer',
              actionIcon: Icons.person_add_alt,
              onAction: () => _openAddCustomerDialog(context),
            ),
          ),

          // Customer table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomContainerWidget(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Obx(() {
                    final List<Customer> customers =
                        customerController.filteredCustomers;

                    return DataTableWidget(
                      columns: const [
                        DataTableColumn(label: 'Customer', flex: 232),
                        DataTableColumn(
                          label: 'Phone',
                          flex: 150,
                          monospace: true,
                        ),
                        DataTableColumn(
                          label: 'Visits',
                          flex: 111,
                          alignRight: true,
                        ),
                        DataTableColumn(label: 'Type', flex: 129),
                        DataTableColumn(label: 'Last Visit', flex: 150),
                        DataTableColumn(
                          label: 'Spent',
                          flex: 111,
                          alignRight: true,
                          monospace: true,
                        ),
                      ],
                      rows: customers
                          .map(
                            (Customer customer) =>
                                DataTableRow(cells: buildCells(customer)),
                          )
                          .toList(),
                      emptyMessage: 'No customers match the search',
                    );
                  }),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _openAddCustomerDialog(BuildContext context) async {
    await showDialog<Customer>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (BuildContext context) {
        return const CustomerPhoneDialogWidget(
          mode: CustomerDialogMode.addCustomer,
        );
      },
    );
  }

  List<Widget> buildCells(Customer customer) {
    return [
      DataTableWidget.text(
        customer.displayName,
        color: AppTheme.badgeAmberText,
        weight: FontWeight.w600,
      ),
      DataTableWidget.text(customer.phone, color: AppTheme.tableHeaderText),
      DataTableWidget.text(
        '${customer.visits}',
        weight: FontWeight.w600,
        monospace: true,
      ),
      StatusPillWidget(
        label: customer.isRegular ? 'Regular' : 'New',
        tone: customer.isRegular ? PillTone.green : PillTone.blue,
      ),
      DataTableWidget.text(customer.lastVisit, color: AppTheme.tableHeaderText),
      DataTableWidget.text(
        '৳${formatNumber(customer.spent)}',
        weight: FontWeight.w700,
        monospace: true,
      ),
    ];
  }
}
