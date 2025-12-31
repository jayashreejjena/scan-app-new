import 'package:get/get.dart';
import 'package:odisha_air_map/pages/home/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
  }
}
