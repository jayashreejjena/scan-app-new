import 'package:hive/hive.dart';

part 'location_pattern.g.dart';

@HiveType(typeId: 0)
class LocationPattern extends HiveObject {
  @HiveField(0)
  final String patternId;

  @HiveField(1)
  final String locationId;

  @HiveField(2)
  final Location location;

  @HiveField(3)
  int? dummy;

  LocationPattern({
    required this.patternId,
    required this.locationId,
    required this.location,
  });

  factory LocationPattern.fromJson(Map<String, dynamic> json) {
    return LocationPattern(
      patternId: json['pattern_id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      location: Location.fromJson(json['location'] ?? {}),
    );
  }

  // ✅ ADD THIS
  LocationPattern copyWith({Location? location}) {
    return LocationPattern(
      patternId: patternId,
      locationId: locationId,
      location: location ?? this.location,
    );
  }
}

@HiveType(typeId: 1)
class Location extends HiveObject {
  @HiveField(0)
  final String locationId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final Coordinates coordinates;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String createdAt;

  @HiveField(6)
  final String updatedAt;

  @HiveField(7)
  final Content content;

  @HiveField(8)
  final List<String> patternIds;

  @HiveField(9)
  int? dummy;

  Location({
    required this.locationId,
    required this.name,
    required this.type,
    required this.coordinates,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.content,
    required this.patternIds,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      locationId: json['location_id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      content: Content.fromJson(json['content'] ?? {}),
      patternIds: List<String>.from(json['pattern_ids'] ?? const []),
    );
  }

  // ✅ ADD THIS
  Location copyWith({Content? content}) {
    return Location(
      locationId: locationId,
      name: name,
      type: type,
      coordinates: coordinates,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      content: content ?? this.content,
      patternIds: patternIds,
    );
  }
}

@HiveType(typeId: 2)
class Coordinates extends HiveObject {
  @HiveField(0)
  final double lat;

  @HiveField(1)
  final double lng;

  @HiveField(2)
  int? dummy;

  Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

@HiveType(typeId: 3)
class Content extends HiveObject {
  @HiveField(0)
  final String? modelUrl;

  @HiveField(1)
  final String? audioUrl;

  @HiveField(2)
  final String? videoUrl;

  @HiveField(3)
  final List<String> facts;

  @HiveField(4)
  int? dummy;

  Content({this.modelUrl, this.audioUrl, this.videoUrl, required this.facts});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      modelUrl: json['model_url']?.toString(),
      audioUrl: json['audio_url']?.toString(),
      videoUrl: json['video_url']?.toString(),
      facts: List<String>.from(json['facts'] ?? const []),
    );
  }

  // ✅ ADD THIS
  Content copyWith({
    String? modelUrl,
    String? audioUrl,
    String? videoUrl,
    List<String>? facts,
  }) {
    return Content(
      modelUrl: modelUrl ?? this.modelUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      facts: facts ?? this.facts,
    );
  }
}
