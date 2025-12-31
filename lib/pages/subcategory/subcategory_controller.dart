// lib/pages/subcategory/subcategory_controller.dart
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:odisha_air_map/pages/explorecategory/explorecategory_controller.dart';

class SubcategoryController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final items = <ExploreItem>[].obs;

  late int districtId;
  late int categoryId;
  late String categoryName; 

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null ||
        !args.containsKey('districtId') ||
        !args.containsKey('categoryId')) {
      errorMessage.value = 'Missing required parameters';
      isLoading.value = false;
      return;
    }

    districtId = args['districtId'] as int;
    categoryId = args['categoryId'] as int;
    categoryName = args['categoryName'] as String? ?? 'Explore';

    fetchObjects();
  }

  Future<void> fetchObjects() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final url =
          'http://omap.okcl.org/api/districts/$districtId/categories/$categoryId/objects/';

      // 🔹 LOG REQUEST
      log("📡 API Request URL:");
      log(url);

      final response = await http.get(Uri.parse(url));

      // 🔹 LOG STATUS CODE
      log("📥 API Response Status Code:");
      log(response.statusCode.toString());

      // 🔹 LOG RAW RESPONSE BODY
      log("📦 API Raw Response Body:");
      log(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // 🔹 LOG PARSED JSON
        log("✅ Parsed JSON Data:");
        print(data);

        items.value = data.map((json) {
          return ExploreItem(
            id: json['id']?.toString() ?? '',
            name: json['name'] as String? ?? 'Unnamed Place',
            imageUrl: json['image'] as String? ?? '',
          );
        }).toList();

        // 🔹 LOG FINAL ITEMS LIST
        log("🎯 Mapped ExploreItem List:");
        for (var item in items) {
          log("• ${item.id} | ${item.name} | ${item.imageUrl}");
        }
      } else {
        errorMessage.value = 'Failed to load data: ${response.statusCode}';

        // 🔴 LOG ERROR RESPONSE
        log("❌ API Error Response:");
        log(response.body);
      }
    } catch (e, stack) {
      errorMessage.value = 'Error: $e';

      // 🔴 LOG EXCEPTION
      log("💥 Exception occurred:");
      log(e.toString());
      log("📌 Stack Trace:");
      log(stack.toString());
    } finally {
      isLoading.value = false;
      log("⏹ API Call Finished");
    }
  }
}
