import 'package:get/get.dart';
import 'package:omnix/features/staff/dummy_data/dummy_staff_data.dart';
import 'package:omnix/features/staff/model/staff_model.dart';

class StaffController extends GetxController {
  final staff = <Staff>[].obs;

  // settings with their on / off state
  final settings = <SettingToggle>[].obs;

  final searchText = ''.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStaff();
  }

  // TODO: replace with db fetch once backend is ready
  Future<void> fetchStaff() async {
    isLoading.value = true;

    // swap this for the API call, the shape stays the same
    // final response = await api.get('/staff');
    // staff.assignAll(
    //   (response as List)
    //       .map((e) => Staff.fromJson(e as Map<String, dynamic>))
    //       .toList(),
    // );
    staff.assignAll(DummyStaffData.staff);
    settings.assignAll(DummyStaffData.settings);

    isLoading.value = false;
  }

  void searchOnChanged(String value) {
    searchText.value = value;
  }

  // staff matching the search text
  List<Staff> get filteredStaff {
    final String query = searchText.value.trim().toLowerCase();

    return staff.where((Staff member) {
      return query.isEmpty ||
          member.name.toLowerCase().contains(query) ||
          member.id.toLowerCase().contains(query) ||
          member.branch.toLowerCase().contains(query);
    }).toList();
  }

  // flips a setting on or off
  void toggleSetting(int index) {
    final SettingToggle setting = settings[index];
    settings[index] = SettingToggle(
      label: setting.label,
      description: setting.description,
      isOn: !setting.isOn,
    );
  }

  int get activeCount {
    return staff.where((Staff member) => member.isActive).length;
  }
}
