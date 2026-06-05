import 'package:flutter/material.dart';

/// Global constants for the Frozen Wasteland game.
class GameConstants {
  GameConstants._();

  // ---------------------------------------------------------------------------
  // Screen / Viewport
  // ---------------------------------------------------------------------------
  /// Fixed logical resolution used by the game viewport.
  static const double viewportWidth = 384.0;
  static const double viewportHeight = 832.0;

  // ---------------------------------------------------------------------------
  // Isometric tile dimensions
  // ---------------------------------------------------------------------------
  /// Width of a single isometric tile in pixels.
  static const double tileWidth = 64.0;

  /// Height of a single isometric tile in pixels (typically half the width).
  static const double tileHeight = 32.0;

  /// Number of tiles along one edge of the square grid.
  static const int gridSize = 16;

  /// Whether to draw per-tile coordinate debug text on the grid.
  static const bool showGridDebugCoords = false;

  // ---------------------------------------------------------------------------
  // Alternating grid (checkerboard) colors
  // ---------------------------------------------------------------------------
  /// Even-parity tile fill (lighter ice).
  static const Color tileColorA = Color(0xFFE8EEF2);

  /// Odd-parity tile fill (slightly darker ice) for the alternating pattern.
  static const Color tileColorB = Color(0xFFD4E2EA);

  // ---------------------------------------------------------------------------
  // Colors
  // ---------------------------------------------------------------------------
  /// Background color of the game world (light gray).
  static const Color backgroundColor = Color(0xFFF5F5F5);

  /// Primary accent color (frozen blue).
  static const Color primaryColor = Color(0xFF4A90D9);

  /// Secondary accent color (ice teal).
  static const Color secondaryColor = Color(0xFF7FD3E0);

  /// Grid line color.
  static const Color gridLineColor = Color(0xFFBDC9D1);

  /// Grid tile fill color.
  static const Color tileFillColor = Color(0xFFE8EEF2);

  /// Highlighted tile color (selection).
  static const Color tileHighlightColor = Color(0xFFA8D8EA);

  /// UI panel background.
  static const Color uiPanelColor = Color(0xCC1B2A3A);

  /// UI text color.
  static const Color uiTextColor = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Gameplay
  // ---------------------------------------------------------------------------
  /// Default movement speed of animals (pixels per second).
  static const double animalSpeed = 40.0;

  /// Maximum priority value used by pathfinding heuristics.
  static const double maxPathCost = 1e9;
}
