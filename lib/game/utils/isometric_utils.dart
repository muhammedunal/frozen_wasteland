import 'package:flame/components.dart';

import '../../config/constants.dart';

/// Helpers for converting between screen (cartesian) space and the
/// 2:1 isometric grid space used by the game.
///
/// The isometric projection uses the standard diamond layout where one grid
/// step in X moves half a tile right and half a tile down on screen, and one
/// grid step in Y moves half a tile left and half a tile down.
class IsometricUtils {
  IsometricUtils._();

  static const double _halfTileW = GameConstants.tileWidth / 2.0;
  static const double _halfTileH = GameConstants.tileHeight / 2.0;

  /// Converts an isometric grid coordinate (can be fractional) to a screen
  /// position in pixels.
  ///
  ///   screenX = (isoX - isoY) * (tileWidth  / 2)
  ///   screenY = (isoX + isoY) * (tileHeight / 2)
  static Vector2 isometricToScreen(Vector2 isoPos) {
    final screenX = (isoPos.x - isoPos.y) * _halfTileW;
    final screenY = (isoPos.x + isoPos.y) * _halfTileH;
    return Vector2(screenX, screenY);
  }

  /// Converts a screen position in pixels back to an isometric grid coordinate.
  ///
  /// Inverse of [isometricToScreen]:
  ///   isoX = (screenX / (tileWidth/2) + screenY / (tileHeight/2)) / 2
  ///   isoY = (screenY / (tileHeight/2) - screenX / (tileWidth/2)) / 2
  static Vector2 screenToIsometric(Vector2 screenPos) {
    final a = screenPos.x / _halfTileW;
    final b = screenPos.y / _halfTileH;
    final isoX = (a + b) / 2.0;
    final isoY = (b - a) / 2.0;
    return Vector2(isoX, isoY);
  }

  /// Snaps a (possibly fractional) isometric coordinate to the nearest integer
  /// tile, returned as a [Vector2] of whole numbers.
  static Vector2 snapToTile(Vector2 isoPos) {
    return Vector2(isoPos.x.floorToDouble(), isoPos.y.floorToDouble());
  }

  /// Returns the screen-space center point of the tile at grid [x],[y].
  static Vector2 tileCenterToScreen(int x, int y) {
    // Add half a tile so the position lands on the diamond's center.
    return isometricToScreen(Vector2(x + 0.5, y + 0.5));
  }

  /// Whether a grid coordinate falls inside the playable [GameConstants.gridSize]
  /// bounds.
  static bool isInBounds(int x, int y) {
    return x >= 0 &&
        y >= 0 &&
        x < GameConstants.gridSize &&
        y < GameConstants.gridSize;
  }

  /// Depth sorting priority for an isometric tile so that objects further
  /// "back" render behind those in front. Higher value = drawn later (on top).
  static int depthPriority(int x, int y) => x + y;
}
