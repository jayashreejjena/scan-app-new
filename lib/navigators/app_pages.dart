import 'package:get/get.dart';
import 'package:odisha_air_map/pages/content/content_binding.dart';
import 'package:odisha_air_map/pages/content/content_view.dart';
import 'package:odisha_air_map/pages/explorecategory/explorecategory_binding.dart';
import 'package:odisha_air_map/pages/explorecategory/explorecategory_view.dart';
import 'package:odisha_air_map/pages/home/home_binding.dart';
import 'package:odisha_air_map/pages/home/home_view.dart';
import 'package:odisha_air_map/pages/objectdetected/object_detected_binding.dart';
import 'package:odisha_air_map/pages/objectdetected/object_detected_view.dart';
import 'package:odisha_air_map/pages/onboardingscreen/onboardingscreen_binding.dart';
import 'package:odisha_air_map/pages/onboardingscreen/onboardingscreen_view.dart';
import 'package:odisha_air_map/pages/scannerscreen/scanner_binding.dart';
import 'package:odisha_air_map/pages/scannerscreen/scanner_view.dart';
import 'package:odisha_air_map/pages/splash/splash_binding.dart';
import 'package:odisha_air_map/pages/splash/splash_view.dart';
import 'package:odisha_air_map/pages/subcategory/subcategory_binding.dart';
import 'package:odisha_air_map/pages/subcategory/subcategory_view.dart';

part 'app_routes.dart';

class AppPages {
  static var transistionDuration = const Duration(milliseconds: 350);

  static const initial = Routes.splash;

  static final pages = [
    GetPage(
      name: _Paths.splash,
      transitionDuration: transistionDuration,
      page: () => SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: _Paths.homepage,
      transitionDuration: transistionDuration,
      page: () => HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.onboardingscreen,
      transitionDuration: transistionDuration,
      page: () => OnboardingScreen(),
      binding: OnboardingscreenBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.explorecategory,
      transitionDuration: transistionDuration,
      page: () => ExploreCategoriesSheet(),
      binding: ExplorecategoryBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: _Paths.scanner,
      transitionDuration: transistionDuration,
      page: () => const ScannerScreen(),
      binding: ScannerBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: _Paths.subcategory,
      transitionDuration: transistionDuration,
      page: () => const SubCategoryItemsScreen(),
      binding: SubcategoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.objectdetected,
      transitionDuration: transistionDuration,
      page: () => ObjectDetectedScreen(),
      binding: ObjectDetectedBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.content,
      transitionDuration: transistionDuration,
      page: () => ContentScreen(),
      binding: ContentBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
