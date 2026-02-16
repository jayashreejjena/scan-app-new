import 'package:get/get.dart';
import 'package:odisha_air_map/pages/login/login_controller.dart';

class LoginBinding extends Bindings{
  @override
  void dependencies() {
  Get.put(LoginController());
  }
  
}