import 'package:get/get.dart';
import 'package:odisha_air_map/pages/downloaddist/downloaddist_controller.dart';

class DownloaddistBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DownloaddistController());
  }
}
