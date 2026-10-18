import 'package:get/get.dart';

class DashBoardController extends GetxController {
  final dayRanges = const ['Today', '7 Days', '30 Days'];

  final selectedDayRange = 0.obs;

  void dayRangeOnChanged(int index) {
    selectedDayRange.value = index;
  }
}
