import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;

import '../config/constants.dart';
import '../config/game_config.dart';
import '../models/animal.dart';
import '../models/building.dart';
import '../models/resource.dart';
import 'components/animals/animal_component.dart';
import 'components/buildings/building_component.dart';
import 'components/grid/isometric_grid.dart';
import 'components/ui/game_ui.dart';
import 'utils/collision_detection.dart';

/// The root Flame game for Frozen Wasteland.
///
/// Responsibilities:
///  * Sets up a fixed-resolution viewport (384 x 832).
///  * Renders the isometric grid, buildings, animals, and HUD.
///  * Handles tap input to place buildings.
///  * Drives the passive resource economy.
///
/// State is intentionally held here for the Flame layer; the Riverpod providers
/// mirror this for the Flutter UI. [onStateChanged] is invoked whenever the
/// game's resources change so external listeners can stay in sync.
class FrozenWastelandGame extends FlameGame
    with TapCallbacks, PointerMoveCallbacks {
  FrozenWastelandGame({this.onStateChanged, this.onPlacementFeedback});

  /// Optional callback fired when resources change (for Riverpod bridging).
  final void Function(Resources resources)? onStateChanged;

  /// Optional callback fired with a short message after a placement attempt
  /// (e.g. "Tile occupied", "Not enough resources", "Built House").
  final void Function(String message, bool success)? onPlacementFeedback;

  final math.Random _rng = math.Random();

  late final IsometricGrid grid;
  late final GameUi hud;

  /// Translucent placement preview that follows the pointer.
  BuildingComponent? _ghost;

  final List<BuildingComponent> _buildingComponents = [];
  final List<AnimalComponent> _animalComponents = [];

  final Resources _resources = Resources(
    wood: GameConfig.startingWood,
    food: GameConfig.startingFood,
    stone: GameConfig.startingStone,
  );
  Resources get resources => _resources;

  /// Currently selected building type for placement. When null, taps do nothing
  /// and no ghost preview is shown. Driven by the Flutter UI.
  BuildingType? selectedBuildingType;

  double _resourceTimer = 0.0;
  int _idCounter = 0;

  @override
  Color backgroundColor() => GameConstants.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Fixed-resolution viewport so the game looks identical on all devices.
    camera = CameraComponent.withFixedResolution(
      width: GameConstants.viewportWidth,
      height: GameConstants.viewportHeight,
    );
    camera.viewfinder.anchor = Anchor.topLeft;

    // The grid + entities live in the world; the HUD lives in the viewport.
    grid = IsometricGrid();
    world.add(grid);

    // The resource HUD is rendered by a Flutter overlay (top-left) in
    // game_screen.dart, so the in-world [GameUi] is kept for state mirroring
    // but not attached to the viewport to avoid duplicate displays.
    hud = GameUi(resources: _resources);

    _spawnTestBuildings();
    _spawnInitialAnimals();
    _rebuildGhost();

    // Push the initial resource snapshot so listeners start in sync.
    _notifyResources();
  }

  /// Manually places a handful of buildings for testing the placement system.
  void _spawnTestBuildings() {
    final samples = <(BuildingType, int, int)>[
      (BuildingType.house, 2, 2),
      (BuildingType.barn, 6, 3),
      (BuildingType.tree, 10, 8),
      (BuildingType.wall, 4, 9),
    ];
    for (final (type, col, row) in samples) {
      final building = Building(
        id: _nextId('building'),
        type: type,
        gridPosition: Vector2(col.toDouble(), row.toDouble()),
        buildProgress: 1.0,
      );
      _addBuildingComponent(building);
    }
  }

  /// (Re)creates the ghost preview for the currently selected building type.
  void _rebuildGhost() {
    _ghost?.removeFromParent();
    final type = selectedBuildingType;
    if (type == null) {
      _ghost = null;
      return;
    }
    final ghostModel = Building(
      id: 'ghost',
      type: type,
      gridPosition: Vector2.zero(),
    );
    _ghost = BuildingComponent(
      model: ghostModel,
      gridOrigin: grid.position,
      isGhost: true,
    );
    world.add(_ghost!);
  }

  void _spawnInitialAnimals() {
    final types = AnimalType.values;
    final count = math.min(3, GameConfig.maxAnimals);
    final buildingsSnapshot = buildings;
    for (var i = 0; i < count; i++) {
      // Find an unoccupied spawn tile.
      int x, y, tries = 0;
      do {
        x = _rng.nextInt(GameConstants.gridSize);
        y = _rng.nextInt(GameConstants.gridSize);
        tries++;
      } while (CollisionDetection.isTileOccupied(x, y, buildingsSnapshot) &&
          tries < 50);

      final animal = Animal(
        id: _nextId('animal'),
        type: types[_rng.nextInt(types.length)],
        gridPosition: Vector2(x.toDouble(), y.toDouble()),
        // Stagger initial hunger so they seek food at different times.
        hunger: _rng.nextInt(40),
      );
      final comp = AnimalComponent(
        model: animal,
        gridOrigin: grid.position,
        getBuildings: () => buildings,
        random: _rng,
      );
      _animalComponents.add(comp);
      world.add(comp);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _tickEconomy(dt);
    _tickConstruction(dt);
  }

  void _tickEconomy(double dt) {
    if (!GameConfig.autoProduceResources) return;
    _resourceTimer += dt * GameConfig.gameSpeed;
    if (_resourceTimer >= GameConfig.resourceTickSeconds) {
      _resourceTimer -= GameConfig.resourceTickSeconds;
      // Each completed building of a type yields resources.
      var wood = 0, food = 0, stone = 0;
      for (final c in _buildingComponents) {
        if (!c.model.isComplete) continue;
        final lvl = c.model.level;
        switch (c.model.type) {
          case BuildingType.house:
            food += 1 * lvl;
            break;
          case BuildingType.barn:
            food += 3 * lvl;
            break;
          case BuildingType.tree:
            wood += 1 * lvl;
            break;
          case BuildingType.wall:
          case BuildingType.door:
          case BuildingType.fence:
            // Defensive structures produce no resources.
            break;
        }
      }
      // Baseline trickle so the player is never fully stuck.
      wood += 1;
      _applyResourceDelta(wood: wood, food: food, stone: stone);
    }
  }

  void _tickConstruction(double dt) {
    for (final c in _buildingComponents) {
      if (c.model.isComplete) continue;
      final seconds = c.model.type.buildTime.inMilliseconds / 1000.0;
      final increment = (dt * GameConfig.gameSpeed) / seconds;
      final progress = (c.model.buildProgress + increment).clamp(0.0, 1.0);
      c.updateModel(c.model.copyWith(buildProgress: progress));
    }
  }

  void _applyResourceDelta({int wood = 0, int food = 0, int stone = 0}) {
    _resources.produce(ResourceType.wood, wood);
    _resources.produce(ResourceType.food, food);
    _resources.produce(ResourceType.stone, stone);
    _notifyResources();
  }

  void _notifyResources() {
    hud.updateResources(_resources);
    onStateChanged?.call(_resources);
  }

  // ---------------------------------------------------------------------------
  // Input
  // ---------------------------------------------------------------------------
  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    final worldPoint = camera.globalToLocal(event.canvasPosition);
    final gridPos = grid.worldToGrid(worldPoint);
    if (gridPos == null) return;

    grid.highlightedTile = gridPos;
    _tryPlaceBuilding(gridPos.x.toInt(), gridPos.y.toInt());
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    super.onPointerMove(event);
    final worldPoint = camera.globalToLocal(event.canvasPosition);
    grid.updateHover(worldPoint);
    _updateGhost(worldPoint);
  }

  /// Moves the ghost preview to the hovered tile, tinting it by validity.
  void _updateGhost(Vector2 worldPoint) {
    final ghost = _ghost;
    final type = selectedBuildingType;
    if (ghost == null || type == null) return;

    final gridPos = grid.worldToGrid(worldPoint);
    if (gridPos == null) {
      ghost.moveGhost(ghost.model.col, ghost.model.row, false);
      return;
    }
    final col = gridPos.x.toInt();
    final row = gridPos.y.toInt();
    final valid = CollisionDetection.canPlaceBuilding(type, col, row, buildings);
    ghost.moveGhost(col, row, valid);
  }

  void _tryPlaceBuilding(int col, int row) {
    final type = selectedBuildingType;
    if (type == null) return;

    // Reject placement on an existing building (that's handled as a tap/upgrade).
    final existing = CollisionDetection.buildingAt(col, row, buildings);
    if (existing != null) return;

    final result =
        CollisionDetection.validatePlacement(type, col, row, buildings);
    if (!result.isValid) {
      onPlacementFeedback?.call(result.message, false);
      return;
    }

    final cost = type.cost;
    if (!_resources.canAfford(cost)) {
      onPlacementFeedback?.call('Not enough resources', false);
      return;
    }

    _resources.spend(cost);
    // A new house raises the population cap and adds a settler.
    if (type == BuildingType.house) {
      _resources.maxPopulation += 4;
      _resources.addPopulation(1);
      _resources.adjustHappiness(2);
    }
    _notifyResources();

    final building = Building(
      id: _nextId('building'),
      type: type,
      gridPosition: Vector2(col.toDouble(), row.toDouble()),
      buildProgress: 0.0,
    );
    _addBuildingComponent(building);
    onPlacementFeedback?.call('Built ${type.displayName}', true);
  }

  /// Creates a [BuildingComponent], wires its tap handler, and adds it.
  void _addBuildingComponent(Building building) {
    final comp = BuildingComponent(
      model: building,
      gridOrigin: grid.position,
      onTapped: _onBuildingTapped,
    );
    _buildingComponents.add(comp);
    world.add(comp);
    // Attempt to load a sprite; placeholder stays if the asset is missing.
    comp.tryLoadSprite(images);
  }

  /// Tapping a completed building upgrades it (if affordable).
  void _onBuildingTapped(Building building) {
    if (!building.isComplete) return;
    const upgradeCost = {ResourceType.wood: 10, ResourceType.stone: 5};
    if (!_resources.canAfford(upgradeCost)) {
      onPlacementFeedback?.call('Need 10 wood + 5 stone to upgrade', false);
      return;
    }
    _resources.spend(upgradeCost);
    _notifyResources();

    final comp =
        _buildingComponents.firstWhere((c) => c.model.id == building.id);
    comp.updateModel(comp.model.upgraded());
    onPlacementFeedback?.call(
        '${building.type.displayName} → L${comp.model.level}', true);
  }

  /// Removes a building by id (e.g. for a future demolish tool).
  void removeBuilding(String id) {
    final idx = _buildingComponents.indexWhere((c) => c.model.id == id);
    if (idx < 0) return;
    _buildingComponents[idx].removeFromParent();
    _buildingComponents.removeAt(idx);
  }

  /// Public API: set the building type the next tap will place.
  void selectBuilding(BuildingType? type) {
    selectedBuildingType = type;
    _rebuildGhost();
  }

  String _nextId(String prefix) => '${prefix}_${_idCounter++}';

  // ---------------------------------------------------------------------------
  // External accessors (read-only snapshots)
  // ---------------------------------------------------------------------------
  List<Building> get buildings =>
      _buildingComponents.map((c) => c.model).toList(growable: false);

  List<Animal> get animals =>
      _animalComponents.map((c) => c.model).toList(growable: false);
}
