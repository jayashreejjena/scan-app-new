import 'package:get/get.dart';
import 'package:odisha_air_map/pages/objectdetected/object_detected_controller.dart';

class ObjectDetectedBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ObjectDetectedController());
  }
}
