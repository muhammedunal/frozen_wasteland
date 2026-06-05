import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../utils/isometric_utils.dart';

/// Renders a flat-top 2:1 isometric diamond grid and supports hover
/// highlighting + optional per-tile coordinate debug text.
///
/// Coordinate system (flat-top isometric):
///   screenX = (col - row) * tileWidth  / 2
///   screenY = (col + row) * tileHeight / 2
///
/// The grid is anchored at [position] (set by the game); all tile drawing is
/// done relative to that origin.
class IsometricGrid extends PositionComponent {
  final int gridSize;

  /// Whether to draw coordinate labels on every tile.
  final bool showDebugCoords;

  /// The tile currently under the pointer (col,row), or null when none.
  Vector2? hoveredTile;

  /// A separately tracked "selected" tile (e.g. last tapped), or null.
  Vector2? highlightedTile;

  IsometricGrid({
    this.gridSize = GameConstants.gridSize,
    this.showDebugCoords = GameConstants.showGridDebugCoords,
  }) : super(priority: 0) {
    // Center the diamond horizontally and push it down a bit from the top.
    position = Vector2(
      GameConstants.viewportWidth / 2,
      GameConstants.viewportHeight / 5,
    );
  }

  // --- Paints --------------------------------------------------------------
  final Paint _fillA = Paint()
    ..color = GameConstants.tileColorA
    ..style = PaintingStyle.fill;

  final Paint _fillB = Paint()
    ..color = GameConstants.tileColorB
    ..style = PaintingStyle.fill;

  final Paint _linePaint = Paint()
    ..color = GameConstants.gridLineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  final Paint _hoverPaint = Paint()
    ..color = GameConstants.tileHighlightColor.withValues(alpha: 0.9)
    ..style = PaintingStyle.fill;

  final Paint _selectPaint = Paint()
    ..color = GameConstants.primaryColor.withValues(alpha: 0.55)
    ..style = PaintingStyle.fill;

  late final TextPaint _coordPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFF5A6B78),
      fontSize: 8,
      fontWeight: FontWeight.w500,
    ),
  );

  late final TextPaint _hoverLabelPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      backgroundColor: Color(0xCC1B2A3A),
    ),
  );

  // --- Rendering -----------------------------------------------------------
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw back-to-front so depth ordering reads naturally.
    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        _drawTile(canvas, col, row);
      }
    }

    // Floating label for the hovered tile coordinate.
    if (hoveredTile != null) {
      final c = hoveredTile!.x.toInt();
      final r = hoveredTile!.y.toInt();
      _hoverLabelPaint.render(
        canvas,
        ' Tile ($c, $r) ',
        Vector2(0, -GameConstants.viewportHeight / 5 + 8),
        anchor: Anchor.topCenter,
      );
    }
  }

  void _drawTile(Canvas canvas, int col, int row) {
    final center = IsometricUtils.tileCenterToScreen(col, row);
    final halfW = GameConstants.tileWidth / 2;
    final halfH = GameConstants.tileHeight / 2;

    // Diamond corners (flat-top): top, right, bottom, left.
    final path = Path()
      ..moveTo(center.x, center.y - halfH)
      ..lineTo(center.x + halfW, center.y)
      ..lineTo(center.x, center.y + halfH)
      ..lineTo(center.x - halfW, center.y)
      ..close();

    // Choose fill: selection > hover > alternating checkerboard.
    Paint fill;
    final isHovered = hoveredTile != null &&
        hoveredTile!.x.toInt() == col &&
        hoveredTile!.y.toInt() == row;
    final isSelected = highlightedTile != null &&
        highlightedTile!.x.toInt() == col &&
        highlightedTile!.y.toInt() == row;

    if (isSelected) {
      fill = _selectPaint;
    } else if (isHovered) {
      fill = _hoverPaint;
    } else {
      fill = ((col + row) % 2 == 0) ? _fillA : _fillB;
    }

    canvas.drawPath(path, fill);
    canvas.drawPath(path, _linePaint);

    if (showDebugCoords) {
      _coordPaint.render(
        canvas,
        '$col,$row',
        center,
        anchor: Anchor.center,
      );
    }
  }

  // --- Coordinate helpers --------------------------------------------------
  /// Converts a world-space point (in the same space as [position]) into a
  /// grid tile, or null if outside the grid bounds.
  Vector2? worldToGrid(Vector2 worldPoint) {
    final local = worldPoint - position;
    final iso = IsometricUtils.screenToIsometric(local);
    final tile = IsometricUtils.snapToTile(iso);
    final c = tile.x.toInt();
    final r = tile.y.toInt();
    if (c >= 0 && r >= 0 && c < gridSize && r < gridSize) {
      return Vector2(c.toDouble(), r.toDouble());
    }
    return null;
  }

  /// Updates the hovered tile given a world-space pointer position. Pass null
  /// to clear the hover (e.g. pointer left the canvas).
  void updateHover(Vector2? worldPoint) {
    hoveredTile = worldPoint == null ? null : worldToGrid(worldPoint);
  }
}
