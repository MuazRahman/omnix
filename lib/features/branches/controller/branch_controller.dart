import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/branches/dummy_data/dummy_branch_data.dart';
import 'package:omnix/features/branches/model/branch_model.dart';

/// How the branch list is rendered below the toolbar.
enum BranchViewMode { grid, compact }

class BranchController extends GetxController {
  final selectedBranch = ValueNotifier<String?>('Main Branch (DHK-01)');

  // full branch records, used by the branches section
  final branchRecords = <Branch>[].obs;

  // hourly order throughput drawn by the network chart
  final throughput = <BranchThroughputSlot>[].obs;

  final searchText = ''.obs;

  final isLoading = false.obs;

  final viewMode = BranchViewMode.grid.obs;

  // network revenue change against yesterday, shown on the overview banner
  final double networkRevenueChangePercent =
      DummyBranchData.networkRevenueChangePercent;

  @override
  void onInit() {
    super.onInit();
    fetchBranches();
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchBranches() async {
    isLoading.value = true;

    // swap this for the API call, the shape stays the same
    // final response = await api.get('/branches');
    // branchRecords.assignAll(
    //   (response as List)
    //       .map((e) => Branch.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    branchRecords.assignAll(DummyBranchData.branches);
    throughput.assignAll(DummyBranchData.throughput);

    isLoading.value = false;
  }

  // The global branch selector only offers live outlets.
  List<String> get branches => branchRecords
      .where((Branch branch) => branch.isActive)
      .map((Branch branch) => branch.selectorLabel)
      .toList();

  List<Branch> get activeBranches =>
      branchRecords.where((Branch branch) => branch.isActive).toList();

  Branch? get currentBranch {
    for (final Branch branch in branchRecords) {
      if (branch.isCurrent) return branch;
    }
    return activeBranches.isEmpty ? null : activeBranches.first;
  }

  void branchOnChanged(String? value) {
    if (value == null) return;

    selectedBranch.value = value;

    // keep the "operating here" flag in sync with the global selector
    final int index = branchRecords.indexWhere(
      (Branch branch) => branch.selectorLabel == value,
    );
    if (index != -1) _setCurrentBranch(index);
  }

  void searchOnChanged(String value) {
    searchText.value = value;
  }

  void viewModeOnChanged(BranchViewMode mode) {
    viewMode.value = mode;
  }

  // Moves the terminal onto [branch] and mirrors it in the global selector.
  void switchToBranch(Branch branch) {
    if (!branch.isActive) return;

    final int index = branchRecords.indexWhere(
      (Branch record) => record.id == branch.id,
    );
    if (index == -1) return;

    _setCurrentBranch(index);
    selectedBranch.value = branch.selectorLabel;

    _notify(
      'Switched outlet',
      'This terminal now operates from ${branch.name} (${branch.id}).',
    );
  }

  void toggleBranchActive(Branch branch) {
    final int index = branchRecords.indexWhere(
      (Branch record) => record.id == branch.id,
    );
    if (index == -1) return;

    final bool nowActive = !branch.isActive;
    branchRecords[index] = branch.copyWith(
      isActive: nowActive,
      posTerminals: nowActive ? branch.posTerminals : 0,
      isCurrent: nowActive ? branch.isCurrent : false,
    );

    // never leave the selector on a deactivated outlet
    if (!nowActive && selectedBranch.value == branch.selectorLabel) {
      final Branch? fallback = activeBranches.isEmpty
          ? null
          : activeBranches.first;
      selectedBranch.value = fallback?.selectorLabel ?? '';
    }

    _notify(
      nowActive ? 'Outlet activated' : 'Outlet deactivated',
      '${branch.name} (${branch.id}) is now '
      '${nowActive ? 'live' : 'offline'}.',
    );
  }

  // Adds a new outlet to the network. Returns the created record.
  Branch addBranch({
    required String name,
    required String code,
    required String address,
    required String area,
    required String phone,
    required String manager,
    required bool isCloudKitchen,
    required int posTerminals,
  }) {
    final DateTime now = DateTime.now();

    final Branch branch = Branch(
      id: code.trim().toUpperCase(),
      name: name.trim(),
      address: address.trim(),
      manager: manager.trim(),
      phone: phone.trim(),
      isActive: true,
      openedAt: _monthYear(now),
      area: area.trim(),
      tagline: isCloudKitchen ? 'Cloud Hub' : 'Dine-in Outlet',
      isCloudKitchen: isCloudKitchen,
      tables: isCloudKitchen ? 0 : 12,
      seats: isCloudKitchen ? 0 : 48,
      posTerminals: posTerminals,
      staffCount: 0,
      todayRevenue: 0,
      todayOrders: 0,
      inventoryHealth: 100,
      lowStockCount: 0,
    );

    branchRecords.add(branch);

    _notify(
      'Branch created',
      '${branch.name} (${branch.id}) was added to the network.',
    );

    return branch;
  }

  void updateBranch(
    Branch branch, {
    required String name,
    required String code,
    required String address,
    required String area,
    required String phone,
    required String manager,
    required bool isCloudKitchen,
    required int posTerminals,
  }) {
    final int index = branchRecords.indexWhere(
      (Branch record) => record.id == branch.id,
    );
    if (index == -1) return;

    final Branch updated = branch.copyWith(
      id: code.trim().toUpperCase(),
      name: name.trim(),
      address: address.trim(),
      area: area.trim(),
      phone: phone.trim(),
      manager: manager.trim(),
      isCloudKitchen: isCloudKitchen,
      tagline: isCloudKitchen ? 'Cloud Hub' : branch.tagline,
      tables: isCloudKitchen ? 0 : branch.tables,
      seats: isCloudKitchen ? 0 : branch.seats,
      posTerminals: posTerminals,
    );

    branchRecords[index] = updated;

    // keep the selector label in sync when the name or code changed
    if (selectedBranch.value == branch.selectorLabel) {
      selectedBranch.value = updated.selectorLabel;
    }

    _notify('Branch updated', '${updated.name} (${updated.id}) was saved.');
  }

  // branches matching the search text
  List<Branch> get filteredBranches {
    final String query = searchText.value.trim().toLowerCase();

    return branchRecords.where((Branch branch) {
      return query.isEmpty ||
          branch.name.toLowerCase().contains(query) ||
          branch.id.toLowerCase().contains(query) ||
          branch.manager.toLowerCase().contains(query) ||
          branch.area.toLowerCase().contains(query);
    }).toList();
  }

  int get activeCount {
    return branchRecords.where((Branch branch) => branch.isActive).length;
  }

  int get inactiveCount {
    return branchRecords.where((Branch branch) => !branch.isActive).length;
  }

  // combined running revenue of the live outlets
  int get combinedRevenue {
    return activeBranches.fold<int>(
      0,
      (int sum, Branch branch) => sum + branch.todayRevenue,
    );
  }

  int get combinedOrders {
    return activeBranches.fold<int>(
      0,
      (int sum, Branch branch) => sum + branch.todayOrders,
    );
  }

  int get totalStaff {
    return activeBranches.fold<int>(
      0,
      (int sum, Branch branch) => sum + branch.staffCount,
    );
  }

  int get totalPosTerminals {
    return activeBranches.fold<int>(
      0,
      (int sum, Branch branch) => sum + branch.posTerminals,
    );
  }

  int get criticalLowStockCount {
    return activeBranches.fold<int>(
      0,
      (int sum, Branch branch) => sum + branch.lowStockCount,
    );
  }

  double get averageInventoryHealth {
    final List<Branch> active = activeBranches;
    if (active.isEmpty) return 0;

    final double total = active.fold<double>(
      0,
      (double sum, Branch branch) => sum + branch.inventoryHealth,
    );
    return total / active.length;
  }

  // Distinct cities the live outlets sit in, e.g. "Dhaka · Khulna".
  String get networkCoverage {
    final Set<String> cities = <String>{};
    for (final Branch branch in activeBranches) {
      final String area = branch.area.trim();
      if (area.isEmpty) continue;

      final List<String> parts = area.split(',');
      cities.add(parts.last.trim());
    }
    return cities.isEmpty ? 'No live outlets' : cities.join(' · ');
  }

  // Manager options offered by the add / edit dialog.
  List<String> get managerOptions {
    final Set<String> names = <String>{
      'Kazi Anisur Rahman (Senior Supervisor)',
      'Mithun Chakraborty (Operations Lead)',
      'Nusrat Jahan (Floor Manager)',
    };
    for (final Branch branch in branchRecords) {
      if (branch.manager.isNotEmpty) names.add(branch.manager);
    }
    final List<String> list = names.toList()..sort();
    return list;
  }

  // ---- helpers -------------------------------------------------------------

  void _setCurrentBranch(int index) {
    for (int i = 0; i < branchRecords.length; i++) {
      final bool shouldBeCurrent = i == index;
      if (branchRecords[i].isCurrent != shouldBeCurrent) {
        branchRecords[i] = branchRecords[i].copyWith(
          isCurrent: shouldBeCurrent,
        );
      }
    }
  }

  String _monthYear(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  // Used by the header and card actions until the real editor is wired.
  void showComingSoon(String feature) {
    _notify(
      '$feature is not wired yet',
      'This demo screen keeps the action local.',
    );
  }

  void _notify(String title, String message) {
    if (Get.context == null) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.sidebarBackgroundBlack,
      colorText: AppTheme.lightAmberWhite,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }
}
