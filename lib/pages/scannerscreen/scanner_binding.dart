import 'package:get/get.dart';
import 'package:odisha_air_map/pages/scannerscreen/scanner_controller.dart';

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ScannerController());
  }
}
