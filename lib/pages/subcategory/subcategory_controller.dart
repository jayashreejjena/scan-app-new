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
      log('📡 API REQUEST URL');
      log(url);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
          'User-Agent': 'PostmanRuntime/7.32.0',
        },
      );

      // 🔹 LOG STATUS CODE
      log('📥 STATUS CODE: ${response.statusCode}');

      // 🔹 LOG RAW RESPONSE
      log('📦 RAW RESPONSE BODY:');
      log(response.body);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is! List) {
          errorMessage.value = 'Invalid response format';
          log('❌ Response is not a List');
          return;
        }

        // 🔹 LOG PARSED DATA COUNT
        log('✅ TOTAL ITEMS RECEIVED: ${decoded.length}');

        items.value = decoded.map<ExploreItem>((json) {
          return ExploreItem(
            id: json['id']?.toString() ?? '',
            name: json['name']?.toString() ?? 'Unnamed Place',
            imageUrl: json['image']?.toString() ?? '',
          );
        }).toList();

        // 🔹 LOG FINAL MAPPED LIST
        log('🎯 FINAL ITEMS LIST');
        for (var item in items) {
          log('• ID: ${item.id} | NAME: ${item.name}');
        }
      } else {
        errorMessage.value = 'Failed to load data (${response.statusCode})';
        log('❌ ERROR RESPONSE');
        log(response.body);
      }
    } catch (e, stack) {
      errorMessage.value = 'Error: $e';

      log('💥 EXCEPTION OCCURRED');
      log(e.toString());
      log('📌 STACK TRACE');
      log(stack.toString());
    } finally {
      isLoading.value = false;
      log('⏹ API CALL FINISHED');
    }
  }
}
