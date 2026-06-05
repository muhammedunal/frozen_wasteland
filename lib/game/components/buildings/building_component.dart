import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../../config/assets.dart';
import '../../../config/constants.dart';
import '../../../models/building.dart';
import '../../utils/isometric_utils.dart';

/// Visual + interactive representation of a [Building] on the isometric grid.
///
/// Supports:
///  * Sprite rendering with a colored placeholder fallback.
///  * Multi-tile footprint positioning (anchored at footprint center base).
///  * Tap detection (fires [onTapped]).
///  * A "ghost" mode for placement preview, tinted by [ghostValid].
class BuildingComponent extends PositionComponent with TapCallbacks {
  Building model;
  Sprite? sprite;

  /// Must match the IsometricGrid origin so tiles line up.
  final Vector2 gridOrigin;

  /// When true this is a translucent placement preview (not a real building).
  final bool isGhost;

  /// For ghost mode: whether the current position is a legal placement.
  bool ghostValid;

  /// Invoked when a (non-ghost) building is tapped.
  final void Function(Building building)? onTapped;

  BuildingComponent({
    required this.model,
    required this.gridOrigin,
    this.sprite,
    this.isGhost = false,
    this.ghostValid = true,
    this.onTapped,
  }) : super(anchor: Anchor.bottomCenter) {
    _applyFootprintSize();
    _updatePosition();
  }

  void _applyFootprintSize() {
    // A footprint of W x H tiles spans (W+H) half-tile-widths across the
    // diamond; height grows with the building's tile span too.
    final w = model.width;
    final h = model.height;
    size = Vector2(
      (w + h) * GameConstants.tileWidth / 2,
      (w + h) * GameConstants.tileHeight / 2 + GameConstants.tileHeight,
    );
  }

  void _updatePosition() {
    // Anchor on the bottom-center of the footprint's far corner tile.
    final centerCol = model.col + model.width / 2.0;
    final centerRow = model.row + model.height / 2.0;
    final screen =
        IsometricUtils.isometricToScreen(Vector2(centerCol, centerRow));
    position = gridOrigin + screen + Vector2(0, GameConstants.tileHeight / 2);
    priority = IsometricUtils.depthPriority(
          model.col + model.width,
          model.row + model.height,
        ) +
        1;
  }

  /// Replaces the model and refreshes size/position/priority.
  void updateModel(Building newModel) {
    model = newModel;
    _applyFootprintSize();
    _updatePosition();
  }

  /// Moves a ghost preview to a new top-left grid cell with validity tint.
  void moveGhost(int col, int row, bool valid) {
    model = model.copyWith(gridPosition: Vector2(col.toDouble(), row.toDouble()));
    ghostValid = valid;
    _updatePosition();
  }

  // --- Rendering -----------------------------------------------------------
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (sprite != null) {
      sprite!.render(canvas, size: size, overridePaint: _spritePaint());
    } else {
      _renderPlaceholder(canvas);
    }

    if (!isGhost && model.level > 1) {
      _renderLevelBadge(canvas);
    }
    if (!isGhost && !model.isComplete) {
      _renderProgressBar(canvas);
    }
  }

  Paint? _spritePaint() {
    if (!isGhost) return null;
    return Paint()
      ..color = (ghostValid ? Colors.white : Colors.red)
          .withValues(alpha: 0.5);
  }

  void _renderPlaceholder(Canvas canvas) {
    var color = WinterPalette.forBuilding(model.type);
    if (isGhost) {
      color = (ghostValid ? color : Colors.red).withValues(alpha: 0.5);
    } else if (!model.isComplete) {
      color = color.withValues(alpha: 0.4);
    }

    final w = size.x;
    final h = size.y;
    // Simple isometric prism: top diamond + two side faces.
    final topPath = Path()
      ..moveTo(w / 2, h * 0.15)
      ..lineTo(w, h * 0.4)
      ..lineTo(w / 2, h * 0.65)
      ..lineTo(0, h * 0.4)
      ..close();
    canvas.drawPath(topPath, Paint()..color = color);

    final leftPath = Path()
      ..moveTo(0, h * 0.4)
      ..lineTo(w / 2, h * 0.65)
      ..lineTo(w / 2, h)
      ..lineTo(0, h * 0.75)
      ..close();
    canvas.drawPath(
        leftPath, Paint()..color = _darken(color, 0.15));

    final rightPath = Path()
      ..moveTo(w, h * 0.4)
      ..lineTo(w / 2, h * 0.65)
      ..lineTo(w / 2, h)
      ..lineTo(w, h * 0.75)
      ..close();
    canvas.drawPath(
        rightPath, Paint()..color = _darken(color, 0.3));
  }

  void _renderLevelBadge(Canvas canvas) {
    final tp = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        backgroundColor: GameConstants.primaryColor,
      ),
    );
    tp.render(canvas, ' L${model.level} ', Vector2(size.x / 2, size.y * 0.1),
        anchor: Anchor.center);
  }

  void _renderProgressBar(Canvas canvas) {
    final barWidth = size.x * 0.6;
    final barLeft = (size.x - barWidth) / 2;
    const barHeight = 4.0;
    final barTop = size.y * 0.05;
    canvas.drawRect(
      Rect.fromLTWH(barLeft, barTop, barWidth, barHeight),
      Paint()..color = Colors.black54,
    );
    canvas.drawRect(
      Rect.fromLTWH(barLeft, barTop, barWidth * model.buildProgress, barHeight),
      Paint()..color = GameConstants.secondaryColor,
    );
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  // --- Interaction ---------------------------------------------------------
  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (!isGhost) onTapped?.call(model);
  }

  /// Loads the sprite for this building type from the game's image cache.
  /// Silently keeps the placeholder if the asset is missing.
  Future<void> tryLoadSprite(Images images) async {
    try {
      final image = await images.load(Assets.buildingSprite(model.type));
      sprite = Sprite(image);
    } catch (_) {
      // Asset not present yet — placeholder is used.
    }
  }
}
