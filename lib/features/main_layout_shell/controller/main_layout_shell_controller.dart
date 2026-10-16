import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainLayoutShellController extends GetxController{
  RxInt selectedIndex = 0.obs;

  final List<Widget> screens = [
    const Center(child: Text('Dashboard View', style: TextStyle(fontSize: 24, color: Colors.white))),
    const Center(child: Text('POS', style: TextStyle(fontSize: 24, color: Colors.white))),
    const Center(child: Text('Orders', style: TextStyle(fontSize: 24, color: Colors.white))),
    const Center(child: Text('Menu', style: TextStyle(fontSize: 24, color: Colors.white))),
    const Center(child: Text('Inventory & Stock', style: TextStyle(fontSize: 24, color: Colors.white))),
    const Center(child: Text('Purchases', style: TextStyle(fontSize: 24, color: Colors.white))),
  ];

  // Method to update index when a sidebar item is clicked
  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}