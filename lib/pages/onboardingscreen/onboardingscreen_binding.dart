import 'package:get/get.dart';
import 'package:odisha_air_map/pages/onboardingscreen/onboardingscreen_controller.dart';

class OnboardingscreenBinding  extends Bindings{
  @override
  void dependencies() {
   Get.put(OnboardingscreenController());
  }
}