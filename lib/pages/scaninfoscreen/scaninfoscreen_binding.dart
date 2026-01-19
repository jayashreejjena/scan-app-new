import 'package:get/get.dart';
import 'package:odisha_air_map/pages/scaninfoscreen/scaninfoscreen.dart';

class ScaninfoscreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ScaninfoscreenController());
  }
}
