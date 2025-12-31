// models/explore_models.dart
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData? icon;

  Category({required this.id, required this.name, this.icon});
}

class ExploreItem {
  final int id;
  final String locationId;
  final String name;
  final String? imageUrl;

  ExploreItem({
    required this.id,
    required this.locationId,
    required this.name,
    this.imageUrl,
  });

  factory ExploreItem.fromJson(Map<String, dynamic> json) {
    return ExploreItem(
      id: json['id'] as int,
      locationId: json['location_id'] as String,
      name: json['name'] as String,
      imageUrl: json['image'] as String?,
    );
  }
}
