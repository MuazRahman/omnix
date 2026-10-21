import 'package:get/get.dart';
import 'package:omnix/features/reports/dummy_data/dummy_report_data.dart';
import 'package:omnix/features/reports/model/report_model.dart';

class ReportController extends GetxController {
  final List<String> ranges = const ['Today', '7 Days', '30 Days'];

  final selectedRange = 0.obs;

  final salesReport = <ReportEntry>[].obs;

  final topSellingItems = <TopSellingItem>[].obs;

  final staffPerformance = <ReportEntry>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchReport() async {
    isLoading.value = true;

    // swap this for the API call, the shape stays the same
    // final response = await api.get('/reports/sales');
    // salesReport.assignAll(
    //   (response as List)
    //       .map((e) => ReportEntry.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    salesReport.assignAll(DummyReportData.salesReport);
    topSellingItems.assignAll(DummyReportData.topSellingItems);
    staffPerformance.assignAll(DummyReportData.staffPerformance);

    isLoading.value = false;
  }

  void rangeOnChanged(int index) {
    selectedRange.value = index;
  }
}
