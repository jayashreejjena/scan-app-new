import 'package:get/get.dart';
import 'package:odisha_air_map/pages/content/content_view.dart';

import 'app_pages.dart';

class RouteManagement {
  static void goToSplash() {
    Get.offNamed<void>(Routes.splash);
  }

  static void goToOnboarding() {
    Get.offNamed<void>(Routes.onboardingscreen);
  }

  static void goToHome() {
    Get.offNamed<void>(Routes.homepage);
  }

  static void goToScanner() {
    Get.offNamed<void>(Routes.scanner);
  }

  static void goTOSacninfo() {
    Get.offNamed<void>(Routes.scaninfo);
  }

  static void goToExploreCategory({Map<String, dynamic>? arguments}) {
    Get.toNamed<void>(Routes.explorecategory, arguments: arguments);
  }

  static void goToObjectDetected(int id) {
    Get.toNamed(Routes.objectdetected, arguments: id);
  }

  static void goToSubCategory({
    required int districtId,
    required int categoryId,
    required String categoryName,
  }) {
    Get.toNamed(
      Routes.subcategory,
      arguments: {
        'districtId': districtId,
        'categoryId': categoryId,
        'categoryName': categoryName,
      },
    );
  }

  static void goToContent() {
    Get.toNamed<void>(Routes.content);
  }
}
