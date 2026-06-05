import 'package:flame/components.dart';

import '../../config/constants.dart';
import '../../models/building.dart';

/// Result of a placement validation, with a reason for UI feedback.
enum PlacementResult { valid, outOfBounds, overlap }

extension PlacementResultX on PlacementResult {
  bool get isValid => this == PlacementResult.valid;

  String get message {
    switch (this) {
      case PlacementResult.valid:
        return 'OK';
      case PlacementResult.outOfBounds:
        return 'Out of bounds';
      case PlacementResult.overlap:
        return 'Tile occupied';
    }
  }
}

/// Collision / occupancy checks for the isometric grid, footprint-aware.
class CollisionDetection {
  CollisionDetection._();

  /// Whether tile [c],[r] is covered by any building's footprint.
  static bool isTileOccupied(int c, int r, List<Building> buildings) {
    for (final b in buildings) {
      if (b.occupies(c, r)) return true;
    }
    return false;
  }

  /// Whether the whole [width]x[height] footprint at [col],[row] is in bounds.
  static bool footprintInBounds(int col, int row, int width, int height) {
    return col >= 0 &&
        row >= 0 &&
        col + width <= GameConstants.gridSize &&
        row + height <= GameConstants.gridSize;
  }

  /// Validates placing [type] at top-left [col],[row] against bounds + overlaps.
  /// Pass [ignoreId] to skip a building (useful when moving/upgrading it).
  static PlacementResult validatePlacement(
    BuildingType type,
    int col,
    int row,
    List<Building> buildings, {
    String? ignoreId,
  }) {
    final w = type.dimensions.x.toInt();
    final h = type.dimensions.y.toInt();

    if (!footprintInBounds(col, row, w, h)) {
      return PlacementResult.outOfBounds;
    }

    for (var dx = 0; dx < w; dx++) {
      for (var dy = 0; dy < h; dy++) {
        final c = col + dx;
        final r = row + dy;
        for (final b in buildings) {
          if (b.id == ignoreId) continue;
          if (b.occupies(c, r)) return PlacementResult.overlap;
        }
      }
    }
    return PlacementResult.valid;
  }

  /// Convenience boolean wrapper around [validatePlacement].
  static bool canPlaceBuilding(
    BuildingType type,
    int col,
    int row,
    List<Building> buildings, {
    String? ignoreId,
  }) {
    return validatePlacement(type, col, row, buildings, ignoreId: ignoreId)
        .isValid;
  }

  /// Returns the building whose footprint covers [c],[r], or null.
  static Building? buildingAt(int c, int r, List<Building> buildings) {
    for (final b in buildings) {
      if (b.occupies(c, r)) return b;
    }
    return null;
  }

  /// Axis-aligned bounding box overlap test in screen space.
  static bool aabbOverlap(
    Vector2 posA,
    Vector2 sizeA,
    Vector2 posB,
    Vector2 sizeB,
  ) {
    return posA.x < posB.x + sizeB.x &&
        posA.x + sizeA.x > posB.x &&
        posA.y < posB.y + sizeB.y &&
        posA.y + sizeA.y > posB.y;
  }

  /// Whether [point] lies inside the isometric diamond centered at
  /// [tileScreenCenter].
  static bool pointInTileDiamond(Vector2 point, Vector2 tileScreenCenter) {
    final dx = (point.x - tileScreenCenter.x).abs();
    final dy = (point.y - tileScreenCenter.y).abs();
    return (dx / (GameConstants.tileWidth / 2)) +
            (dy / (GameConstants.tileHeight / 2)) <=
        1.0;
  }
}
