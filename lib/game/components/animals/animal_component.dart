import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/assets.dart';
import '../../../config/constants.dart';
import '../../../config/game_config.dart';
import '../../../models/animal.dart';
import '../../../models/building.dart';
import '../../utils/isometric_utils.dart';
import '../../utils/pathfinding.dart';

/// An animal that wanders the grid, gets hungry, and paths to food (trees).
///
/// State machine:
///   idle    -> after a random-walk timer, pick an adjacent tile and walk.
///   idle    -> if hungry, A*-path to a tile next to the nearest tree.
///   walking -> follow the current path; on arrival eat (if at food) or idle.
///   eating  -> reduce hunger until sated, then idle.
///
/// Sprites are placeholders (colored shapes) but the component already supports
/// 4-direction facing + frame timing for when atlases are added.
class AnimalComponent extends PositionComponent {
  Animal model;
  final Vector2 gridOrigin;
  final math.Random _rng;

  /// Supplies the current building list for pathfinding obstacles + food.
  final List<Building> Function() getBuildings;

  /// Fractional grid position for smooth interpolation.
  late Vector2 _isoPos;

  /// Active path (tiles to walk through), and our progress along it.
  List<GridNode> _path = const [];
  int _pathIndex = 0;

  /// True when the current path leads to a food source.
  bool _seekingFood = false;

  /// Countdown until the next idle random-walk.
  double _idleTimer = 0.0;

  /// Animation bookkeeping.
  int _facingRow = AnimalAnimations.rowDown;
  double _animTime = 0.0;
  int _animFrame = 0;

  AnimalComponent({
    required this.model,
    required this.gridOrigin,
    required this.getBuildings,
    math.Random? random,
  })  : _rng = random ?? math.Random(),
        super(
          size: Vector2.all(GameConstants.tileHeight),
          anchor: Anchor.bottomCenter,
        ) {
    _isoPos = model.gridPosition.clone();
    _idleTimer = GameConfig.animalIdleSeconds + _rng.nextDouble() * 3.0;
    _syncScreenPosition();
  }

  // --- Positioning ---------------------------------------------------------
  void _syncScreenPosition() {
    final screen = IsometricUtils.isometricToScreen(
      Vector2(_isoPos.x + 0.5, _isoPos.y + 0.5),
    );
    position = gridOrigin + screen + Vector2(0, GameConstants.tileHeight / 2);
    priority = IsometricUtils.depthPriority(
          _isoPos.x.round(),
          _isoPos.y.round(),
        ) +
        2;
  }

  // --- Update loop ---------------------------------------------------------
  @override
  void update(double dt) {
    super.update(dt);
    final scaledDt = dt * GameConfig.gameSpeed;

    model.update(scaledDt);
    _advanceAnimation(scaledDt);

    switch (model.state) {
      case AnimalState.eating:
        _updateEating(scaledDt);
        break;
      case AnimalState.walking:
        _updateWalking(scaledDt);
        break;
      case AnimalState.idle:
        _updateIdle(scaledDt);
        break;
    }

    model.gridPosition = _isoPos.clone();
    _syncScreenPosition();
  }

  void _updateIdle(double dt) {
    // Hungry animals look for food immediately.
    if (model.isHungry && _tryPathToFood()) return;

    _idleTimer -= dt;
    if (_idleTimer <= 0) {
      _idleTimer = GameConfig.animalIdleSeconds + _rng.nextDouble() * 4.0;
      _startRandomWalk();
    }
  }

  void _updateEating(double dt) {
    final sated = model.eat(dt);
    if (sated) {
      model.state = AnimalState.idle;
    }
  }

  void _updateWalking(double dt) {
    if (_path.isEmpty || _pathIndex >= _path.length) {
      _arriveAtPathEnd();
      return;
    }

    final target = _path[_pathIndex];
    final targetVec = Vector2(target.x.toDouble(), target.y.toDouble());
    final delta = targetVec - _isoPos;

    if (delta.length < 0.03) {
      _isoPos = targetVec.clone();
      _pathIndex++;
      if (_pathIndex >= _path.length) _arriveAtPathEnd();
      return;
    }

    final dir = delta.normalized();
    _updateFacing(dir);
    final speed = GameConstants.animalSpeed * model.type.speedFactor;
    final tilesPerSecond = speed / GameConstants.tileWidth;
    _isoPos += dir * tilesPerSecond * dt;
  }

  void _arriveAtPathEnd() {
    _path = const [];
    _pathIndex = 0;
    if (_seekingFood) {
      _seekingFood = false;
      model.state = AnimalState.eating;
    } else {
      model.state = AnimalState.idle;
    }
  }

  // --- AI: path selection --------------------------------------------------
  void _startRandomWalk() {
    final buildings = getBuildings();
    const moves = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];
    moves.shuffle(_rng);
    for (final m in moves) {
      final nx = _isoPos.x.round() + m[0];
      final ny = _isoPos.y.round() + m[1];
      if (_isWalkable(nx, ny, buildings)) {
        _path = [
          GridNode(_isoPos.x.round(), _isoPos.y.round()),
          GridNode(nx, ny),
        ];
        _pathIndex = 1;
        _seekingFood = false;
        model.state = AnimalState.walking;
        return;
      }
    }
    // Boxed in; stay idle.
  }

  /// Finds the nearest tree, paths to an adjacent walkable tile, returns true
  /// if a path was started.
  bool _tryPathToFood() {
    final buildings = getBuildings();
    final trees = buildings.where((b) => b.type == BuildingType.tree).toList();
    if (trees.isEmpty) return false;

    final start = GridNode(_isoPos.x.round(), _isoPos.y.round());

    // Sort trees by Manhattan distance, then try to reach an adjacent tile.
    trees.sort((a, b) =>
        _manhattan(start, a).compareTo(_manhattan(start, b)));

    for (final tree in trees) {
      for (final adj in _walkableNeighbors(tree.col, tree.row, buildings)) {
        final path = Pathfinding.findPath(start, adj, buildings);
        if (path.length > 1) {
          _path = path;
          _pathIndex = 1;
          _seekingFood = true;
          model.state = AnimalState.walking;
          return true;
        }
        // Already adjacent (path is just [start]).
        if (path.length == 1 && start == adj) {
          _seekingFood = true;
          model.state = AnimalState.eating;
          return true;
        }
      }
    }
    return false;
  }

  List<GridNode> _walkableNeighbors(int c, int r, List<Building> buildings) {
    const dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];
    final out = <GridNode>[];
    for (final d in dirs) {
      final nx = c + d[0];
      final ny = r + d[1];
      if (_isWalkable(nx, ny, buildings)) out.add(GridNode(nx, ny));
    }
    return out;
  }

  bool _isWalkable(int c, int r, List<Building> buildings) {
    if (!IsometricUtils.isInBounds(c, r)) return false;
    for (final b in buildings) {
      if (b.occupies(c, r)) return false;
    }
    return true;
  }

  int _manhattan(GridNode a, Building b) =>
      (a.x - b.col).abs() + (a.y - b.row).abs();

  // --- Animation -----------------------------------------------------------
  void _updateFacing(Vector2 dir) {
    // Choose the dominant axis for a 4-direction facing.
    if (dir.x.abs() > dir.y.abs()) {
      _facingRow =
          dir.x > 0 ? AnimalAnimations.rowRight : AnimalAnimations.rowLeft;
    } else {
      _facingRow = dir.y > 0 ? AnimalAnimations.rowDown : AnimalAnimations.rowUp;
    }
  }

  void _advanceAnimation(double dt) {
    final walking = model.state == AnimalState.walking;
    final stepTime = walking
        ? AnimalAnimations.walkStepTime
        : AnimalAnimations.idleStepTime;
    final frames =
        walking ? AnimalAnimations.walkFrames : AnimalAnimations.idleFrames;
    _animTime += dt;
    if (_animTime >= stepTime) {
      _animTime -= stepTime;
      _animFrame = (_animFrame + 1) % frames;
    }
  }

  // --- Rendering (placeholder shapes) --------------------------------------
  Color get _bodyColor {
    switch (model.type) {
      case AnimalType.bear:
        return const Color(0xFF4E342E);
      case AnimalType.reindeer:
        return const Color(0xFF8D6E63);
      case AnimalType.wolf:
        return const Color(0xFF607D8B);
      case AnimalType.elk:
        return const Color(0xFF6D4C41);
      case AnimalType.fox:
        return const Color(0xFFE07A2F);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Shadow.
    canvas.drawOval(
      Rect.fromLTWH(size.x * 0.1, size.y * 0.82, size.x * 0.8, size.y * 0.18),
      Paint()..color = Colors.black26,
    );

    // Body (placeholder square; bobs slightly with the walk frame).
    final bob = (model.state == AnimalState.walking && _animFrame.isOdd)
        ? -1.5
        : 0.0;
    final bodyRect = Rect.fromLTWH(
      size.x * 0.2,
      size.y * 0.25 + bob,
      size.x * 0.6,
      size.y * 0.55,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      Paint()..color = _bodyColor,
    );

    // Facing indicator (small light triangle/dot).
    _drawFacingMarker(canvas, bodyRect);

    // State tint overlay.
    if (model.state == AnimalState.eating) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
        Paint()..color = Colors.green.withValues(alpha: 0.25),
      );
    }

    _drawHungerBar(canvas);
  }

  void _drawFacingMarker(Canvas canvas, Rect body) {
    final marker = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final cx = body.center.dx;
    final cy = body.center.dy;
    Offset p;
    switch (_facingRow) {
      case AnimalAnimations.rowLeft:
        p = Offset(body.left + 2, cy);
        break;
      case AnimalAnimations.rowRight:
        p = Offset(body.right - 2, cy);
        break;
      case AnimalAnimations.rowUp:
        p = Offset(cx, body.top + 2);
        break;
      default:
        p = Offset(cx, body.bottom - 2);
    }
    canvas.drawCircle(p, 2.0, marker);
  }

  void _drawHungerBar(Canvas canvas) {
    if (model.hunger < 30) return; // only show when noticeably hungry
    const w = 18.0;
    const h = 3.0;
    final left = (size.x - w) / 2;
    const top = 2.0;
    canvas.drawRect(
        Rect.fromLTWH(left, top, w, h), Paint()..color = Colors.black54);
    final frac = model.hunger / 100.0;
    final color = model.hunger >= Animal.hungryThreshold
        ? Colors.redAccent
        : Colors.orangeAccent;
    canvas.drawRect(
        Rect.fromLTWH(left, top, w * frac, h), Paint()..color = color);
  }

  /// Loads the sprite atlas if present (placeholder stays otherwise).
  Future<void> tryLoadAtlas(Images images) async {
    try {
      await images.load(Assets.animalAtlas(model.type));
      // Atlas wiring (SpriteAnimationComponent) can be added here later;
      // placeholder rendering is used until art is finalized.
    } catch (_) {}
  }
}
