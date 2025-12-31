// content_controller.dart
import 'package:get/get.dart';
import 'package:odisha_air_map/pages/objectdetected/object_detected_controller.dart';

class ContentController extends GetxController {
  late final ObjectDetectedController objectCtrl;

  @override
  void onInit() {
    super.onInit();
    objectCtrl = Get.find<ObjectDetectedController>();
  }

  LocationDetails? get details => objectCtrl.locationDetails.value;

  String? get modelUrl => objectCtrl.getResolvedModelUrl();
  String? get audioUrl => objectCtrl.getResolvedAudioUrl();
  String? get videoUrl => objectCtrl.getResolvedVideoUrl();

  bool get hasData => details != null;
}
