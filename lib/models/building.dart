import 'package:flame/components.dart';

import 'resource.dart';

/// The category of a placeable building.
enum BuildingType { wall, door, house, barn, fence, tree }

/// Static design data + helpers for each [BuildingType].
extension BuildingTypeX on BuildingType {
  /// Stable string id used for serialization.
  String get id {
    switch (this) {
      case BuildingType.wall:
        return 'wall';
      case BuildingType.door:
        return 'door';
      case BuildingType.house:
        return 'house';
      case BuildingType.barn:
        return 'barn';
      case BuildingType.fence:
        return 'fence';
      case BuildingType.tree:
        return 'tree';
    }
  }

  /// Human-readable name shown in the UI.
  String get displayName {
    switch (this) {
      case BuildingType.wall:
        return 'Wall';
      case BuildingType.door:
        return 'Door';
      case BuildingType.house:
        return 'House';
      case BuildingType.barn:
        return 'Barn';
      case BuildingType.fence:
        return 'Fence';
      case BuildingType.tree:
        return 'Tree';
    }
  }

  /// Build cost keyed by [ResourceType].
  Map<ResourceType, int> get cost {
    switch (this) {
      case BuildingType.wall:
        return const {ResourceType.stone: 5};
      case BuildingType.door:
        return const {ResourceType.wood: 5, ResourceType.stone: 2};
      case BuildingType.house:
        return const {ResourceType.wood: 20, ResourceType.stone: 10};
      case BuildingType.barn:
        return const {ResourceType.wood: 30, ResourceType.stone: 5};
      case BuildingType.fence:
        return const {ResourceType.wood: 3};
      case BuildingType.tree:
        return const {ResourceType.food: 2};
    }
  }

  /// Footprint in tiles (width = cols, height = rows).
  Vector2 get dimensions {
    switch (this) {
      case BuildingType.wall:
      case BuildingType.door:
      case BuildingType.fence:
      case BuildingType.tree:
        return Vector2(1, 1);
      case BuildingType.house:
        return Vector2(2, 2);
      case BuildingType.barn:
        return Vector2(3, 2);
    }
  }

  /// Time required to finish construction.
  Duration get buildTime {
    switch (this) {
      case BuildingType.fence:
      case BuildingType.tree:
        return const Duration(seconds: 2);
      case BuildingType.wall:
      case BuildingType.door:
        return const Duration(seconds: 4);
      case BuildingType.house:
        return const Duration(seconds: 8);
      case BuildingType.barn:
        return const Duration(seconds: 12);
    }
  }

  static BuildingType fromId(String id) {
    return BuildingType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => BuildingType.house,
    );
  }
}

/// A building placed on the isometric grid. [gridPosition] is the top-left
/// (minimum col, minimum row) tile of the building's footprint.
class Building {
  final String id;
  final BuildingType type;

  /// Top-left grid cell (x = col, y = row).
  final Vector2 gridPosition;

  /// Upgrade level (1 = base).
  final int level;

  /// Timestamp the building was placed.
  final DateTime builtAt;

  /// Construction progress in [0, 1]; 1 = complete.
  final double buildProgress;

  Building({
    required this.id,
    required this.type,
    required this.gridPosition,
    this.level = 1,
    DateTime? builtAt,
    this.buildProgress = 1.0,
  }) : builtAt = builtAt ?? DateTime.now();

  // --- Footprint helpers ---------------------------------------------------
  /// Width of the footprint in tiles.
  int get width => type.dimensions.x.toInt();

  /// Height of the footprint in tiles.
  int get height => type.dimensions.y.toInt();

  /// Leftmost column.
  int get col => gridPosition.x.toInt();

  /// Topmost row.
  int get row => gridPosition.y.toInt();

  /// Backwards-compatible single-cell accessors.
  int get gridX => col;
  int get gridY => row;

  bool get isComplete => buildProgress >= 1.0;

  /// Whether this building's footprint covers the tile at [c],[r].
  bool occupies(int c, int r) {
    return c >= col && c < col + width && r >= row && r < row + height;
  }

  /// All tiles covered by this building's footprint.
  List<Vector2> occupiedTiles() {
    final tiles = <Vector2>[];
    for (var dx = 0; dx < width; dx++) {
      for (var dy = 0; dy < height; dy++) {
        tiles.add(Vector2((col + dx).toDouble(), (row + dy).toDouble()));
      }
    }
    return tiles;
  }

  Building copyWith({
    String? id,
    BuildingType? type,
    Vector2? gridPosition,
    int? level,
    DateTime? builtAt,
    double? buildProgress,
  }) {
    return Building(
      id: id ?? this.id,
      type: type ?? this.type,
      gridPosition: gridPosition ?? this.gridPosition,
      level: level ?? this.level,
      builtAt: builtAt ?? this.builtAt,
      buildProgress: buildProgress ?? this.buildProgress,
    );
  }

  /// Returns an upgraded copy (level + 1).
  Building upgraded() => copyWith(level: level + 1);

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.id,
        'col': col,
        'row': row,
        'level': level,
        'builtAt': builtAt.toIso8601String(),
        'buildProgress': buildProgress,
      };

  factory Building.fromJson(Map<String, dynamic> json) => Building(
        id: json['id'] as String,
        type: BuildingTypeX.fromId(json['type'] as String),
        gridPosition: Vector2(
          (json['col'] as num).toDouble(),
          (json['row'] as num).toDouble(),
        ),
        level: (json['level'] ?? 1) as int,
        builtAt: DateTime.tryParse(json['builtAt'] as String? ?? '') ??
            DateTime.now(),
        buildProgress: (json['buildProgress'] ?? 1.0).toDouble(),
      );

  @override
  String toString() =>
      'Building(${type.id} L$level @ $col,$row ${width}x$height)';
}
