import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odisha_air_map/model/explore_models.dart';
import 'package:odisha_air_map/navigators/navigators.dart';

class ExploreItem {
  final String id;
  final String name;
  final String imageUrl;
  final String? description;

  ExploreItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
  });
}

class ExplorecategoryController extends GetxController {
  // Reactive district name
  final districtName = ''.obs;
  final districtId = 0.obs;

  final categories = <Category>[].obs;

  final selectedCategory = Rxn<Category>();
  final selectedItem = Rxn<ExploreItem>();

  @override
  void onInit() {
    super.onInit();
    _loadDataFromArguments();
  }

  void _loadDataFromArguments() {
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      final district = args['district'] as Map<String, dynamic>?;

      if (district != null) {
        districtId.value =
            district['id'] as int? ?? district['district_id'] as int? ?? 0;

        districtName.value = district['name'] ?? 'Unknown District';

        final catList = district['categories'] as List<dynamic>? ?? [];

        categories.value = catList.map((cat) {
          final categoryMap = cat as Map<String, dynamic>;
          return Category(
            id: categoryMap['category_id']?.toString() ?? '0',
            name: categoryMap['name'] as String? ?? 'Unnamed',
            icon: Icons.category,
          );
        }).toList();

        log(
          "Loaded district ID: ${districtId.value}, name: ${districtName.value}, "
          "with ${categories.length} categories",
        );
      }
    } else {}
  }

  void openCategoryItems(Category category) {
    // Use the stored districtId
    if (districtId.value == 0) {
      log("Error: District ID not set");
      Get.snackbar("Error", "District not loaded properly");
      return;
    }

    selectedCategory.value = category;

    RouteManagement.goToSubCategory(
      districtId: districtId.value, // Now dynamic & safe
      categoryId: int.parse(category.id),
      categoryName: category.name,
    );
  }

}
