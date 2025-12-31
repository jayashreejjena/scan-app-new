import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:odisha_air_map/utils/app_constants.dart';
import 'package:odisha_air_map/widgets/no_internet_widget.dart';
import '../theme/dimens.dart';
import '../theme/styles.dart';
// Added import for NumberFormat

abstract class Utility {
  static void printDLog(String message) {
    Logger().d('${'appname'.tr}: $message');
  }

  /// Print info log.
  ///
  /// [message] : The message which needed to be print.
  static void printILog(dynamic message) {
    Logger().i('${'appname'.tr}: $message');
  }

  /// Print info log.
  ///
  /// [message] : The message which needed to be print.
  static void printLog(dynamic message) {
    Logger().log(Level.info, message);
  }

  /// Print error log.
  ///
  /// [message] : The message which needed to be print.
  static void printELog(String message) {
    Logger().e('${'appname'.tr}: $message');
  }

  /// Close any open dialog.
  static void closeDialog() {
    if (Get.isDialogOpen ?? false) Get.back<void>();
  }

  /// Number Format
  static String numberFormat(num price) {
    return NumberFormat('#,##,###.##', 'en_US').format(price);
  }

  /// Show no internet dialog if there is no
  /// internet available.
  static Future<void> showNoInternetDialog() async {
    await Get.dialog<void>(NoInternetWidget(), barrierDismissible: false);
  }

  /// Show loader
  static void showLoader() async {
    await Get.dialog<void>(
      Center(child: CircularProgressIndicator.adaptive()),
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(80),
    );
  }

  /// Returns true if the internet connection is available.
  // static Future<bool> isNetworkAvailable() async {
  //   final checker =
  //       InternetConnectionChecker.createInstance(); // Create instance using createInstance
  //   return await checker.hasConnection;
  // }

  /// Show Error bottomsheet.
  ///
  static void showErrorMessage({required String? message}) {
    if (message == null || message.isEmpty) return;

    Get.snackbar(
      "Error", // Title
      message,
      snackPosition: SnackPosition.TOP, // Show at the top
      backgroundColor: Colors.red.withAlpha(230), // Simple red background
      colorText: Colors.white, // White text color
      margin: const EdgeInsets.all(10), // Some margin for better UI
      borderRadius: 8, // Rounded corners
      duration: const Duration(seconds: 3), // Auto-dismiss after 3 sec
    );
  }

  /// Show Success bottomsheet.

  static void showSuccessBottomSheet({
    required String? message,
    Function()? onPress,
    bool isDismissible = true,
  }) async {
    await Get.bottomSheet<void>(
      Container(
        padding: Dimens.edgeInsets30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$message',
              style: Styles.blackBold16.copyWith(color: Colors.black),
            ),
            Dimens.boxHeight10,
          ],
        ),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      isDismissible: isDismissible,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
    ).timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        if (Get.isBottomSheetOpen!) {
          Get.back<void>();
        }
      },
    );
  }

  static String buildFullUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    // Already full URL
    if (path.startsWith('http')) {
      return path;
    }

    // Relative path → make full URL
    return '${AppConstants.baseUrl}$path';
  }

  // static Future<void> logout() async {
  //   final commonService = Get.find<CommonService>();

  //   commonService.clearData(AppConstants.firstName);
  //   commonService.clearData(AppConstants.lastName);
  //   commonService.clearData(AppConstants.email);
  //   commonService.clearData(AppConstants.acessToken);
  //   commonService.clearData(AppConstants.userId);
  //   commonService.clearData(AppConstants.name);
  //   commonService.clearData(AppConstants.mobile);
  //   commonService.clearData(AppConstants.image);
  //   commonService.clearData(AppConstants.isAffiliate);

  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isUserLoggedIn', false);

  //   try {
  //     final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  //     await googleSignIn.signOut();
  //   } catch (e) {
  //     log("Google sign out error: $e");
  //   }
  //   RouteManagement.goToBottomNavigationView();
  // }

  // static Future<void> showAppUpdateDialog() async {
  //   await Get.dialog<void>(
  //     const AppUpdateWidget(),
  //     barrierDismissible: false,
  //   );
  // }
}
