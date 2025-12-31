part of 'app_pages.dart';

abstract class Routes {
  static const splash = _Paths.splash;
  static const homepage = _Paths.homepage;
  static const scanner = _Paths.scanner;
  static const content = _Paths.content;
  static const onboardingscreen = _Paths.onboardingscreen;
  static const explorecategory = _Paths.explorecategory;
  static const subcategory = _Paths.subcategory;
  static const objectdetected = _Paths.objectdetected;
}

abstract class _Paths {
  static const splash = '/splash-screen';
  static const homepage = '/homepage-view';
  static const scanner = '/scanner-view';
  static const content = '/content-view';
  static const onboardingscreen = '/onboardingscreen-view';
  static const explorecategory = '/explorecategory-view';
  static const subcategory = '/subcategory-view';
  static const objectdetected = '/objectdetected-view';
}
