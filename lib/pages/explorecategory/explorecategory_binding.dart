import 'package:get/get.dart';
import 'package:odisha_air_map/pages/explorecategory/explorecategory_controller.dart';

class ExplorecategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ExplorecategoryController());
  }
}
