// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_pattern.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationPatternAdapter extends TypeAdapter<LocationPattern> {
  @override
  final int typeId = 0;

  @override
  LocationPattern read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationPattern(
      patternId: fields[0] as String,
      locationId: fields[1] as String,
      location: fields[2] as Location,
    )..dummy = fields[3] as int?;
  }

  @override
  void write(BinaryWriter writer, LocationPattern obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.patternId)
      ..writeByte(1)
      ..write(obj.locationId)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.dummy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationPatternAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationAdapter extends TypeAdapter<Location> {
  @override
  final int typeId = 1;

  @override
  Location read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Location(
      locationId: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      coordinates: fields[3] as Coordinates,
      description: fields[4] as String,
      createdAt: fields[5] as String,
      updatedAt: fields[6] as String,
      content: fields[7] as Content,
      patternIds: (fields[8] as List).cast<String>(),
    )..dummy = fields[9] as int?;
  }

  @override
  void write(BinaryWriter writer, Location obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.locationId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.coordinates)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.content)
      ..writeByte(8)
      ..write(obj.patternIds)
      ..writeByte(9)
      ..write(obj.dummy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CoordinatesAdapter extends TypeAdapter<Coordinates> {
  @override
  final int typeId = 2;

  @override
  Coordinates read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Coordinates(
      lat: fields[0] as double,
      lng: fields[1] as double,
    )..dummy = fields[2] as int?;
  }

  @override
  void write(BinaryWriter writer, Coordinates obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lng)
      ..writeByte(2)
      ..write(obj.dummy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoordinatesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContentAdapter extends TypeAdapter<Content> {
  @override
  final int typeId = 3;

  @override
  Content read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Content(
      modelUrl: fields[0] as String?,
      audioUrl: fields[1] as String?,
      videoUrl: fields[2] as String?,
      facts: (fields[3] as List).cast<String>(),
    )..dummy = fields[4] as int?;
  }

  @override
  void write(BinaryWriter writer, Content obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.modelUrl)
      ..writeByte(1)
      ..write(obj.audioUrl)
      ..writeByte(2)
      ..write(obj.videoUrl)
      ..writeByte(3)
      ..write(obj.facts)
      ..writeByte(4)
      ..write(obj.dummy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
