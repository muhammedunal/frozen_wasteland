import 'package:flame/components.dart';
import 'package:hive/hive.dart';

import '../models/building.dart';
import '../models/resource.dart';

/// Hand-written Hive [TypeAdapter]s so we avoid the build_runner codegen step.
///
/// Type ids are reserved here; keep them stable across releases:
///   0 - Resources
///   1 - Building
///   2 - BuildingType (enum)
class HiveTypeIds {
  HiveTypeIds._();
  static const int resources = 0;
  static const int building = 1;
  static const int buildingType = 2;
}

/// Adapter for [Resources].
class ResourcesAdapter extends TypeAdapter<Resources> {
  @override
  final int typeId = HiveTypeIds.resources;

  @override
  Resources read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return Resources(
      food: fields[0] as int? ?? 100,
      wood: fields[1] as int? ?? 50,
      stone: fields[2] as int? ?? 30,
      coin: fields[3] as int? ?? 0,
      population: fields[4] as int? ?? 0,
      maxPopulation: fields[5] as int? ?? 10,
      happiness: fields[6] as int? ?? 50,
      maxFood: fields[7] as int? ?? 200,
    );
  }

  @override
  void write(BinaryWriter writer, Resources obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.food)
      ..writeByte(1)
      ..write(obj.wood)
      ..writeByte(2)
      ..write(obj.stone)
      ..writeByte(3)
      ..write(obj.coin)
      ..writeByte(4)
      ..write(obj.population)
      ..writeByte(5)
      ..write(obj.maxPopulation)
      ..writeByte(6)
      ..write(obj.happiness)
      ..writeByte(7)
      ..write(obj.maxFood);
  }
}

/// Adapter for the [BuildingType] enum (stored as its index).
class BuildingTypeAdapter extends TypeAdapter<BuildingType> {
  @override
  final int typeId = HiveTypeIds.buildingType;

  @override
  BuildingType read(BinaryReader reader) {
    final index = reader.readByte();
    if (index < 0 || index >= BuildingType.values.length) {
      return BuildingType.house;
    }
    return BuildingType.values[index];
  }

  @override
  void write(BinaryWriter writer, BuildingType obj) {
    writer.writeByte(obj.index);
  }
}

/// Adapter for [Building]. Stores the [Vector2] footprint origin as col/row
/// ints and [DateTime] as epoch milliseconds.
class BuildingAdapter extends TypeAdapter<Building> {
  @override
  final int typeId = HiveTypeIds.building;

  @override
  Building read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return Building(
      id: fields[0] as String,
      type: fields[1] as BuildingType,
      gridPosition: Vector2(
        (fields[2] as num).toDouble(),
        (fields[3] as num).toDouble(),
      ),
      level: fields[4] as int? ?? 1,
      builtAt: DateTime.fromMillisecondsSinceEpoch(fields[5] as int? ?? 0),
      buildProgress: (fields[6] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  void write(BinaryWriter writer, Building obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.col)
      ..writeByte(3)
      ..write(obj.row)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.builtAt.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(obj.buildProgress);
  }
}
