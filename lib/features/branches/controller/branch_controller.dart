import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omnix/features/branches/dummy_data/dummy_branch_data.dart';
import 'package:omnix/features/branches/model/branch_model.dart';

class BranchController extends GetxController {
  final selectedBranch = ValueNotifier<String?>('Main Branch (DHK-01)');

  final List<String> branches = [
    'Main Branch (DHK-01)',
    'Khulna Branch (KHL-01)',
    'Dhaka Branch (DHK-02)',
  ];

  // full branch records, used by the branches section
  final branchRecords = <Branch>[].obs;

  final searchText = ''.obs;

  final isLoading = false.obs;

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

    isLoading.value = false;
  }

  void branchOnChanged(String? value) {
    if (value != null) selectedBranch.value = value;
  }

  void searchOnChanged(String value) {
    searchText.value = value;
  }

  // branches matching the search text
  List<Branch> get filteredBranches {
    final String query = searchText.value.trim().toLowerCase();

    return branchRecords.where((Branch branch) {
      return query.isEmpty ||
          branch.name.toLowerCase().contains(query) ||
          branch.id.toLowerCase().contains(query) ||
          branch.manager.toLowerCase().contains(query);
    }).toList();
  }

  int get activeCount {
    return branchRecords.where((Branch branch) => branch.isActive).length;
  }
}
