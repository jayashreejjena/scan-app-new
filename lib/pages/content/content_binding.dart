import 'package:get/get.dart';
import 'package:odisha_air_map/pages/content/content_controller.dart';

class ContentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ContentController());
  }
}
