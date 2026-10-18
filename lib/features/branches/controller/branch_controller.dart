import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BranchController extends GetxController {
  final selectedBranch = ValueNotifier<String?>('Main Branch (DHK-01)');

  final branches = ['Main Branch (DHK-01)', 'Khulna Branch (KHL-01)', 'Dhaka Branch (DHK-02)'];

  void branchOnChanged(String? value) {
    selectedBranch.value = value!;
  }
}
